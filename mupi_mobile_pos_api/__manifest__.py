{
    "name": "MUPI Mobile POS API",
    "summary": "Protected mobile APIs for POS product operations",
    "description": """
Protected mobile business APIs for the Flutter mobile app.
This module depends on mupi_mobile_auth for QR login and JWT validation.
    """,
    "author": "SwissAlps",
    "website": "https://www.swissalps.io",
    "category": "Point of Sale",
    "version": "19.0.1.0.0",
    "depends": [
        "mupi_mobile_auth",
        "point_of_sale",
        "product",
        "hr",
    ],
    "data": [
        "security/ir.model.access.csv",
    ],
    "license": "LGPL-3",
    "installable": True,
    "application": False,
}