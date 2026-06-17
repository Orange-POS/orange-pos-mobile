import hashlib
import secrets
from datetime import timedelta

from odoo import api, fields, models
from odoo.exceptions import ValidationError


class MupiMobileAuthChallenge(models.Model):
    _name = "mupi.mobile.auth.challenge"
    _description = "MUPI Mobile Auth Challenge"
    _order = "create_date desc"
    
    _sql_constraints = [
        (
            "challenge_unique",
            "unique(challenge)",
            "Mobile authentication challenge must be unique.",
        ),
    ]

    challenge = fields.Char(required=True, index=True, copy=False)
    nonce_hash = fields.Char(required=True, copy=False)

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
    company_id = fields.Many2one(
        "res.company",
        required=True,
        index=True,
        ondelete="cascade",
    )

    state = fields.Selection(
        [
            ("pending", "Pending"),
            ("used", "Used"),
            ("expired", "Expired"),
            ("revoked", "Revoked"),
        ],
        required=True,
        default="pending",
        index=True,
    )

    expires_at = fields.Datetime(required=True, index=True, copy=False)
    used_at = fields.Datetime(copy=False)

    mobile_device_name = fields.Char(copy=False)
    mobile_ip = fields.Char(copy=False)

    @api.model
    def _hash_nonce(self, nonce):
        return hashlib.sha256(nonce.encode("utf-8")).hexdigest()

    def _is_expired(self):
        self.ensure_one()
        return self.expires_at <= fields.Datetime.now()
    
    def _verify_nonce(self, nonce):
        self.ensure_one()

        if not nonce:
            return False

        return self.nonce_hash == self._hash_nonce(nonce)
    
    def validate_for_mobile(self, nonce):
        self.ensure_one()

        if self.state == "used":
            raise ValidationError("This QR code has already been used.")

        if self.state == "expired":
            raise ValidationError("This QR code has expired.")

        if self.state == "revoked":
            raise ValidationError("This QR code has been revoked.")

        if self.state != "pending":
            raise ValidationError("Invalid QR code state.")

        if self._is_expired():
            self.action_expire()
            raise ValidationError("This QR code has expired.")

        if not self._verify_nonce(nonce):
            raise ValidationError("Invalid QR code verification data.")

        return True
    
    
    def action_expire(self):
        for record in self:
            if record.state == "pending":
                record.write({
                    "state": "expired",
                })

    def action_mark_used(self, mobile_device_name=None, mobile_ip=None):
        for record in self:
            if record.state != "pending":
                continue

            values = {
                "state": "used",
                "used_at": fields.Datetime.now(),
            }

            if mobile_device_name:
                values["mobile_device_name"] = mobile_device_name

            if mobile_ip:
                values["mobile_ip"] = mobile_ip

            record.write(values)
    def consume_for_mobile(self, nonce, mobile_device_name=None, mobile_ip=None):
        self.ensure_one()

        self.env.cr.execute(
            "SELECT id FROM mupi_mobile_auth_challenge WHERE id = %s FOR UPDATE",
            [self.id],
        )

        self.invalidate_recordset()

        self.validate_for_mobile(nonce)

        self.action_mark_used(
            mobile_device_name=mobile_device_name,
            mobile_ip=mobile_ip,
        )

        return True
    
    
    @api.model
    def create_for_pos_session(self, session, user):
        self.sudo().search([
            ("pos_session_id", "=", session.id),
            ("user_id", "=", user.id),
            ("state", "=", "pending"),
        ]).action_expire()
        
        challenge = secrets.token_urlsafe(32)
        nonce = secrets.token_urlsafe(32)
        expires_at = fields.Datetime.now() + timedelta(days=1)

        record = self.sudo().create({
            "challenge": challenge,
            "nonce_hash": self._hash_nonce(nonce),
            "pos_session_id": session.id,
            "pos_config_id": session.config_id.id,
            "user_id": user.id,
            "employee_id": session.employee_id.id if "employee_id" in session._fields and session.employee_id else False,
            "company_id": session.company_id.id,
            "expires_at": expires_at,
            "state": "pending",
        })

        return record, nonce