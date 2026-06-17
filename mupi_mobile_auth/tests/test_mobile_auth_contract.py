from datetime import timedelta

from odoo import fields
from odoo.exceptions import AccessDenied, ValidationError
from odoo.tests import tagged
from odoo.tests.common import TransactionCase
from odoo.addons.mupi_mobile_auth.controllers.mobile_auth import MupiMobileAuthController

@tagged("post_install", "-at_install", "mupi_mobile_auth")

class TestMupiMobileAuthContract(TransactionCase):

    def setUp(self):
        super().setUp()
        self.Challenge = self.env["mupi.mobile.auth.challenge"]
        self.Token = self.env["mupi.mobile.auth.token"]

        self.config = self.env["pos.config"].create({
            "name": "Mobile Auth POS Config",
            "payment_method_ids": [(6, 0, [])],
        })
        
        self.session = self.env["pos.session"].create({
            "name": "Mobile Auth POS Session",
            "config_id": self.config.id,
        })
        self.session.write({"state": "opened"})

    def test_create_challenge_expires_previous_pending_challenge(self):
        first, first_nonce = self.Challenge.create_for_pos_session(
            self.session, self.env.user
        )
        second, second_nonce = self.Challenge.create_for_pos_session(
            self.session, self.env.user
        )

        self.assertEqual(first.state, "expired")
        self.assertEqual(second.state, "pending")
        self.assertNotEqual(first.challenge, second.challenge)
        self.assertNotEqual(first_nonce, second_nonce)

    def test_challenge_is_single_use_and_rejects_bad_nonce(self):
        challenge, nonce = self.Challenge.create_for_pos_session(
            self.session, self.env.user
        )

        with self.assertRaises(ValidationError):
            challenge.validate_for_mobile("wrong-nonce")
        
        challenge.invalidate_recordset()

        self.assertTrue(challenge.validate_for_mobile(nonce))

        challenge.action_mark_used(
            mobile_device_name="Test phone",
            mobile_ip="127.0.0.1",
        )
        
        challenge.invalidate_recordset()

        self.assertEqual(challenge.state, "used")
        self.assertTrue(challenge.used_at)
        self.assertEqual(challenge.mobile_device_name, "Test phone")

        with self.assertRaises(ValidationError):
            challenge.validate_for_mobile(nonce)
        challenge.invalidate_recordset()

    def test_expired_challenge_is_marked_expired_and_rejected(self):
        challenge, nonce = self.Challenge.create_for_pos_session(
            self.session, self.env.user
        )
        challenge.write({
            "expires_at": fields.Datetime.now() - timedelta(minutes=1),
        })

        try:
            challenge.validate_for_mobile(nonce)
            self.fail("Expired challenge should be rejected")
        except ValidationError:
            pass

        challenge.invalidate_recordset()
        self.assertEqual(challenge.state, "expired")

    def test_token_validation_scope_revoke_and_expiry(self):
        challenge, nonce = self.Challenge.create_for_pos_session(
            self.session, self.env.user
        )
        challenge.validate_for_mobile(nonce)

        token_record, access_token = self.Token.issue_for_challenge(challenge)

        checked_token, payload = self.Token.validate_access_token(
            access_token,
            required_scope="product:read",
        )

        self.assertEqual(checked_token, token_record)
        self.assertEqual(payload["user_id"], self.env.user.id)
        self.assertTrue(token_record.last_used_at)

        with self.assertRaises(AccessDenied):
            self.Token.validate_access_token(
                access_token,
                required_scope="missing:scope",
            )

        token_record.action_revoke()

        with self.assertRaises(AccessDenied):
            self.Token.validate_access_token(access_token)

    def test_token_expires_and_session_close_revokes_token(self):
        challenge, nonce = self.Challenge.create_for_pos_session(
            self.session, self.env.user
        )
        challenge.validate_for_mobile(nonce)

        expired_record, expired_access_token = self.Token.issue_for_challenge(challenge)
        expired_record.write({
            "expires_at": fields.Datetime.now() - timedelta(minutes=1),
        })

        try:
            self.Token.validate_access_token(expired_access_token)
            self.fail("Expired token should be rejected")
        except AccessDenied:
            pass

        expired_record.invalidate_recordset()
        self.assertEqual(expired_record.state, "expired")

        active_record, active_access_token = self.Token.issue_for_challenge(challenge)
        self.session.write({"state": "closed"})

        try:
            self.Token.validate_access_token(active_access_token)
            self.fail("Token should be rejected when POS session is closed")
        except AccessDenied:
            pass

        active_record.invalidate_recordset()
        self.assertEqual(active_record.state, "revoked")
    
    def test_replay_does_not_issue_second_token(self):
        challenge, nonce = self.Challenge.create_for_pos_session(
            self.session, self.env.user
        )

        challenge.consume_for_mobile(nonce)
        token_record, access_token = self.Token.issue_for_challenge(challenge)

        token_count = self.Token.search_count([
            ("pos_session_id", "=", self.session.id),
        ])

        with self.assertRaises(ValidationError):
            challenge.validate_for_mobile(nonce)

        self.assertEqual(token_count, 1)
        self.assertTrue(token_record)
        self.assertTrue(access_token)
    
    def test_qr_expiry_timestamp_is_utc_iso8601(self):
        challenge, nonce = self.Challenge.create_for_pos_session(
            self.session, self.env.user
        )

        controller = MupiMobileAuthController()
        expires_at = controller._to_utc_isoformat(challenge.expires_at)

        self.assertTrue(expires_at.endswith("Z"))
        self.assertIn("T", expires_at)
        self.assertNotIn(" ", expires_at)
        
    def test_challenge_consume_is_single_use(self):
        challenge, nonce = self.Challenge.create_for_pos_session(
            self.session, self.env.user
        )

        self.assertTrue(challenge.consume_for_mobile(nonce))
        challenge.invalidate_recordset()
        self.assertEqual(challenge.state, "used")

        with self.assertRaises(ValidationError):
            challenge.consume_for_mobile(nonce)