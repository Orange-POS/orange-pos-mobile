import json
from datetime import timezone

from odoo import fields, http
from odoo.exceptions import AccessDenied, ValidationError
from odoo.http import request


class MupiMobileAuthController(http.Controller):
    
    def _get_bearer_token(self):
        auth_header = request.httprequest.headers.get("Authorization")

        if not auth_header:
            return None

        parts = auth_header.split()

        if len(parts) != 2:
            return None

        if parts[0].lower() != "bearer":
            return None

        return parts[1]

    @http.route(
        "/mupi/mobile/auth/challenge/create",
        type="json",
        auth="user",
        methods=["POST"],
        csrf=False,
    )
    
    
    def create_challenge(self, pos_session_id=None):
        if not pos_session_id:
            return {
                "ok": False,
                "error": "Missing POS session.",
            }

        try:
            pos_session_id = int(pos_session_id)
        except (TypeError, ValueError):
            return {
                "ok": False,
                "error": "Invalid POS session.",
            }

        session = request.env["pos.session"].sudo().browse(pos_session_id).exists()

        if not session:
            return {
                "ok": False,
                "error": "POS session not found.",
            }

        if session.state != "opened":
            return {
                "ok": False,
                "error": "POS session is not opened.",
            }

        challenge_record, nonce = request.env[
            "mupi.mobile.auth.challenge"
        ].create_for_pos_session(
            session,
            request.env.user,
        )
        
        base_url = session.config_id.mupi_mobile_auth_base_url

        if not base_url:
            base_url = request.env["ir.config_parameter"].sudo().get_param("web.base.url")

        base_url = base_url.rstrip("/")
        rest_endpoint_url = base_url + "/mupi/mobile/auth/challenge/validate"

        expires_at_iso = self._to_utc_isoformat(challenge_record.expires_at)
        
        qr_payload = {
            "challenge": challenge_record.challenge,
            "nonce": nonce,
            "pos_session_id": session.id,
            "pos_config_id": session.config_id.id,
            "backend_url": base_url,
            "rest_endpoint_url": rest_endpoint_url,
            "expires_at": expires_at_iso,
        }

        return {
            "ok": True,
            "challenge_id": challenge_record.id,
            "expires_at": expires_at_iso,
            "qr_payload": json.dumps(qr_payload),
        }
        
    @http.route(
        "/mupi/mobile/auth/challenge/validate",
        type="json",
        auth="public",
        methods=["POST"],
        csrf=False,
    )
    def validate_challenge(
        self,
        challenge=None,
        nonce=None,
        pos_session_id=None,
        pos_config_id=None,
        device_name=None,
    ):
        if not challenge:
            return {
                "ok": False,
                "error": "Missing challenge.",
            }

        if not nonce:
            return {
                "ok": False,
                "error": "Missing nonce.",
            }

        Challenge = request.env["mupi.mobile.auth.challenge"].sudo()

        challenge_record = Challenge.search([
            ("challenge", "=", challenge),
        ], limit=1)

        if not challenge_record:
            return {
                "ok": False,
                "error": "Invalid QR code.",
            }

        if pos_session_id:
            try:
                pos_session_id = int(pos_session_id)
            except (TypeError, ValueError):
                return {
                    "ok": False,
                    "error": "Invalid POS session.",
                }

            if challenge_record.pos_session_id.id != pos_session_id:
                return {
                    "ok": False,
                    "error": "QR code does not match POS session.",
                }

        if pos_config_id:
            try:
                pos_config_id = int(pos_config_id)
            except (TypeError, ValueError):
                return {
                    "ok": False,
                    "error": "Invalid POS config.",
                }

            if challenge_record.pos_config_id.id != pos_config_id:
                return {
                    "ok": False,
                    "error": "QR code does not match POS config.",
                }

        if challenge_record.pos_session_id.state != "opened":
            return {
                "ok": False,
                "error": "POS session is no longer opened.",
            }

        mobile_ip = request.httprequest.remote_addr

        try:
            challenge_record.consume_for_mobile(
                nonce,
                mobile_device_name=device_name,
                mobile_ip=mobile_ip,
            )
        except ValidationError as error:
            return {
                "ok": False,
                "error": error.args[0] if error.args else "Invalid QR code.",
            }

        token_record, access_token = request.env[
            "mupi.mobile.auth.token"
        ].sudo().issue_for_challenge(challenge_record)
        
        return {
            "ok": True,
            "message": "QR code validated successfully.",
            "challenge_id": challenge_record.id,
            "access_token": access_token,
            "token_type": "Bearer",
            "expires_at": fields.Datetime.to_string(token_record.expires_at),
            "token_id": token_record.id,
            "pos_session_id": challenge_record.pos_session_id.id,
            "pos_config_id": challenge_record.pos_config_id.id,
            "user_id": challenge_record.user_id.id,
            "employee_id": challenge_record.employee_id.id if challenge_record.employee_id else False,
            "company_id": challenge_record.company_id.id,
        }


    def _to_utc_isoformat(self, value):
        dt = fields.Datetime.to_datetime(value)

        if not dt:
            return None

        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        else:
            dt = dt.astimezone(timezone.utc)

        return dt.isoformat().replace("+00:00", "Z")
    
    
    @http.route(
        "/mupi/mobile/auth/token/check",
        type="json",
        auth="public",
        methods=["POST"],
        csrf=False,
    )
    
    
    def check_token(self):
        access_token = self._get_bearer_token()

        try:
            token_record, payload = request.env[
                "mupi.mobile.auth.token"
            ].sudo().validate_access_token(access_token)
        except AccessDenied as error:
            return {
                "ok": False,
                "error": error.args[0] if error.args else "Invalid token.",
            }

        return {
            "ok": True,
            "message": "Token is valid.",
            "token_id": token_record.id,
            "user_id": token_record.user_id.id,
            "pos_session_id": token_record.pos_session_id.id,
            "pos_config_id": token_record.pos_config_id.id,
            "company_id": token_record.company_id.id,
            "scopes": token_record.scopes,
            "expires_at": fields.Datetime.to_string(token_record.expires_at),
        }
