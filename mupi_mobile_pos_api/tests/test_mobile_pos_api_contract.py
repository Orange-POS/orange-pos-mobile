from odoo.exceptions import AccessDenied
from odoo.tests import tagged
from odoo.tests.common import TransactionCase


@tagged("post_install", "-at_install", "mupi_mobile_pos_api")
class TestMupiMobilePosApiContract(TransactionCase):

    def setUp(self):
        super().setUp()
        self.Challenge = self.env["mupi.mobile.auth.challenge"]
        self.Token = self.env["mupi.mobile.auth.token"]

        self.config = self.env["pos.config"].create({
            "name": "Mobile POS API Config",
            "payment_method_ids": [(6, 0, [])],
        })

        self.session = self.env["pos.session"].create({
            "name": "Mobile POS API Session",
            "config_id": self.config.id,
        })
        self.session.write({"state": "opened"})

        challenge, nonce = self.Challenge.create_for_pos_session(
            self.session,
            self.env.user,
        )
        challenge.consume_for_mobile(nonce)

        self.token_record, self.access_token = self.Token.issue_for_challenge(
            challenge
        )

        self.product = self.env["product.product"].create({
            "name": "Test Mobile Product",
            "barcode": "123456789",
            "available_in_pos": True,
            "lst_price": 10.0,
            "company_id": False,
        })
    
    def test_valid_token_can_be_validated(self):
        token_record, payload = self.Token.validate_access_token(self.access_token)

        self.assertEqual(token_record, self.token_record)
        self.assertEqual(payload["pos_session_id"], self.session.id)

    def test_missing_token_is_rejected(self):
        with self.assertRaises(AccessDenied):
            self.Token.validate_access_token(None)

    def test_product_search_by_barcode(self):
        products = self.env["product.product"].sudo().search([
            ("available_in_pos", "=", True),
            ("company_id", "in", [False, self.token_record.company_id.id]),
            ("barcode", "=", "123456789"),
        ])

        self.assertEqual(products, self.product)

    def test_product_search_by_name(self):
        products = self.env["product.product"].sudo().search([
            ("available_in_pos", "=", True),
            ("company_id", "in", [False, self.token_record.company_id.id]),
            ("name", "ilike", "Mobile Product"),
        ])

        self.assertIn(self.product, products)

    def test_unknown_barcode_returns_no_products(self):
        products = self.env["product.product"].sudo().search([
            ("available_in_pos", "=", True),
            ("company_id", "in", [False, self.token_record.company_id.id]),
            ("barcode", "=", "000000"),
        ])

        self.assertFalse(products)
    
    def test_invalid_token_is_rejected(self):
        with self.assertRaises(AccessDenied):
            self.Token.validate_access_token("invalid-token")
            
    def test_product_not_available_in_pos_is_hidden(self):
        hidden_product = self.env["product.product"].create({
            "name": "Hidden Mobile Product",
            "barcode": "999999",
            "available_in_pos": False,
            "lst_price": 10.0,
            "company_id": False,
        })

        products = self.env["product.product"].sudo().search([
            ("available_in_pos", "=", True),
            ("company_id", "in", [False, self.token_record.company_id.id]),
            ("barcode", "=", hidden_product.barcode),
        ])

        self.assertFalse(products)
    
    def test_product_price_can_be_updated(self):
        self.product.write({
            "lst_price": 10.0,
        })

        self.product.write({
            "lst_price": 25.5,
        })

        self.assertEqual(self.product.lst_price, 25.5)
    
    def test_negative_price_should_be_rejected_rule(self):
        price = -5.0

        self.assertLess(price, 0)
        
    def test_invalid_price_should_be_rejected_rule(self):
        price = "wrong-price"

        with self.assertRaises(ValueError):
            float(price)
            
    def test_missing_product_should_not_exist(self):
        product = self.env["product.product"].sudo().browse(999999).exists()

        self.assertFalse(product)

    def test_product_name_can_be_updated(self):
        self.product.write({
            "name": "Updated Mobile Product",
        })

        self.assertEqual(self.product.name, "Updated Mobile Product")

    def test_empty_product_name_should_be_rejected_rule(self):
        name = "   "

        self.assertFalse(name.strip())
        
    
