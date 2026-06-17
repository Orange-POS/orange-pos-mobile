from odoo import fields, models


class MupiMobileProductAudit(models.Model):
    _name = "mupi.mobile.product.audit"
    _description = "Mobile Product Audit"
    _order = "create_date desc, id desc"

    product_id = fields.Many2one(
        "product.product",
        required=True,
        index=True,
        ondelete="cascade",
    )
    action = fields.Selection(
        [
            ("create", "Create"),
            ("price_update", "Price Update"),
            ("stock_update", "Stock Update"),
            ("product_update", "Product Update"),
            ("archive", "Archive"),
        ],
        required=True,
        index=True,
    )

    old_name = fields.Char()
    new_name = fields.Char()
    old_price = fields.Float()
    new_price = fields.Float()
    old_stock = fields.Float()
    new_stock = fields.Float()

    user_id = fields.Many2one("res.users", required=True)
    employee_id = fields.Many2one("hr.employee")
    pos_session_id = fields.Many2one("pos.session")
    pos_config_id = fields.Many2one("pos.config")
    company_id = fields.Many2one("res.company", required=True)
    token_id = fields.Many2one("mupi.mobile.auth.token")