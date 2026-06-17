from odoo import fields, models


class PosConfig(models.Model):
    _inherit = "pos.config"

    mupi_mobile_auth_base_url = fields.Char(
        string="Mobile App Base URL",
        help="Mobile-reachable Odoo URL used in QR login payload.",
    )