import base64
import hashlib
import hmac
import json
import secrets
import time
from datetime import timedelta

from odoo import api, fields, models
from odoo.exceptions import AccessDenied


class MupiMobileAuthToken(models.Model):
    _name = "mupi.mobile.auth.token"
    _description = "MUPI Mobile Auth Token"
    _order = "create_date desc"
    _sql_constraints = [
        (
            "token_jti_unique",
            "unique(token_jti)",
            "Mobile authentication token JTI must be unique.",
        ),
    ]
    
    @api.model
    def _get_jwt_secret(self):
        config = self.env["ir.config_parameter"].sudo()
        secret = config.get_param("mupi_mobile_auth.jwt_secret")

        if not secret:
            secret = secrets.token_urlsafe(48)
            config.set_param("mupi_mobile_auth.jwt_secret", secret)

        return secret

    @api.model
    def _base64url_encode(self, value):
        return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")
    
    @api.model
    def _base64url_decode(self, value):
        padding = "=" * (-len(value) % 4)
        return base64.urlsafe_b64decode((value + padding).encode("ascii"))

    @api.model
    def _hash_token(self, token):
        return hashlib.sha256(token.encode("utf-8")).hexdigest()

    @api.model
    def _encode_jwt(self, payload):
        header = {
            "alg": "HS256",
            "typ": "JWT",
        }

        header_data = self._base64url_encode(
            json.dumps(header, separators=(",", ":")).encode("utf-8")
        )
        payload_data = self._base64url_encode(
            json.dumps(payload, separators=(",", ":")).encode("utf-8")
        )

        signing_input = f"{header_data}.{payload_data}"

        signature = hmac.new(
            self._get_jwt_secret().encode("utf-8"),
            signing_input.encode("utf-8"),
            hashlib.sha256,
        ).digest()

        signature_data = self._base64url_encode(signature)

        return f"{signing_input}.{signature_data}"
    
    @api.model
    def _decode_jwt(self, token):
        try:
            header_data, payload_data, signature_data = token.split(".")
        except ValueError:
            raise AccessDenied("Invalid token format.")

        signing_input = f"{header_data}.{payload_data}"

        expected_signature = hmac.new(
            self._get_jwt_secret().encode("utf-8"),
            signing_input.encode("utf-8"),
            hashlib.sha256,
        ).digest()

        actual_signature = self._base64url_decode(signature_data)

        if not hmac.compare_digest(expected_signature, actual_signature):
            raise AccessDenied("Invalid token signature.")

        try:
            payload = json.loads(self._base64url_decode(payload_data).decode("utf-8"))
        except Exception:
            raise AccessDenied("Invalid token payload.")

        return payload
    
    

    @api.model
    def issue_for_challenge(self, challenge_record):
        challenge_record.ensure_one()

        issued_at = fields.Datetime.now()
        expires_at = issued_at + timedelta(hours=8)

        issued_at_ts = int(time.time())
        expires_at_ts = issued_at_ts + (8 * 60 * 60)

        token_jti = secrets.token_urlsafe(24)
        scopes = (
            "product:read "
            "product:price_update "
            "product:name_update "
            "reference:read"
        )

        payload = {
            "iss": "mupi_mobile_auth",
            "sub": str(challenge_record.user_id.id),
            "jti": token_jti,
            "user_id": challenge_record.user_id.id,
            "employee_id": challenge_record.employee_id.id if challenge_record.employee_id else False,
            "pos_session_id": challenge_record.pos_session_id.id,
            "pos_config_id": challenge_record.pos_config_id.id,
            "company_id": challenge_record.company_id.id,
            "scopes": scopes,
            "iat": issued_at_ts,
            "exp": expires_at_ts,
        }

        access_token = self._encode_jwt(payload)


        token_record = self.sudo().create({
            "token_jti": token_jti,
            "token_hash": self._hash_token(access_token),
            "user_id": challenge_record.user_id.id,
            "employee_id": challenge_record.employee_id.id if challenge_record.employee_id else False,
            "pos_session_id": challenge_record.pos_session_id.id,
            "pos_config_id": challenge_record.pos_config_id.id,
            "company_id": challenge_record.company_id.id,
            "scopes": scopes,
            "state": "active",
            "issued_at": issued_at,
            "expires_at": expires_at,
        })

        return token_record, access_token
    
    def action_expire(self):
        for record in self:
            if record.state == "active":
                record.write({
                    "state": "expired",
                })

    def action_revoke(self):
        for record in self:
            if record.state == "active":
                record.write({
                    "state": "revoked",
                    "revoked_at": fields.Datetime.now(),
                })

    def action_touch(self):
        for record in self:
            record.write({
                "last_used_at": fields.Datetime.now(),
            })
    
    @api.model
    def validate_access_token(self, access_token, required_scope=None):
        if not access_token:
            raise AccessDenied("Missing access token.")

        payload = self._decode_jwt(access_token)

        if payload.get("exp") and int(payload["exp"]) < int(time.time()):
            token_record = self.sudo().search([
                ("token_jti", "=", payload.get("jti")),
            ], limit=1)

            if token_record:
                token_record.action_expire()

            raise AccessDenied("Token has expired.")

        token_jti = payload.get("jti")

        if not token_jti:
            raise AccessDenied("Invalid token identifier.")

        token_record = self.sudo().search([
            ("token_jti", "=", token_jti),
        ], limit=1)

        if not token_record:
            raise AccessDenied("Token not found.")

        if token_record.token_hash != self._hash_token(access_token):
            raise AccessDenied("Token does not match stored record.")

        if token_record.state != "active":
            raise AccessDenied("Token is not active.")

        if token_record.expires_at <= fields.Datetime.now():
            token_record.action_expire()
            raise AccessDenied("Token has expired.")

        if token_record.pos_session_id.state != "opened":
            token_record.action_revoke()
            raise AccessDenied("POS session is no longer opened.")

        if required_scope:
            scopes = token_record.scopes.split()
            if required_scope not in scopes:
                raise AccessDenied("Token does not have required permission.")

        token_record.action_touch()

        return token_record, payload

    token_jti = fields.Char(required=True, index=True, copy=False)
    token_hash = fields.Char(required=True, index=True, copy=False)

    user_id = fields.Many2one(
        "res.users",
        required=True,
        index=True,
        ondelete="cascade",
    )
    employee_id = fields.Many2one(
        "hr.employee",
        index=True,
        ondelete="set null",
    )
    pos_session_id = fields.Many2one(
        "pos.session",
        required=True,
        index=True,
        ondelete="cascade",
    )
    pos_config_id = fields.Many2one(
        "pos.config",
        required=True,
        index=True,
        ondelete="cascade",
    )
    company_id = fields.Many2one(
        "res.company",
        required=True,
        index=True,
        ondelete="cascade",
    )

    scopes = fields.Char(
        default=(
            "product:read "
            "product:price_update "
            "product:name_update "
            "product:stock_update "
            "product:audit_read "
            "reference:read"
        ),
        copy=False,
    )
    
    state = fields.Selection(
        [
            ("active", "Active"),
            ("revoked", "Revoked"),
            ("expired", "Expired"),
        ],
        required=True,
        default="active",
        index=True,
    )

    issued_at = fields.Datetime(required=True, index=True, copy=False)
    expires_at = fields.Datetime(required=True, index=True, copy=False)
    last_used_at = fields.Datetime(copy=False)
    revoked_at = fields.Datetime(copy=False)