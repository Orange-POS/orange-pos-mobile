{
    "name": "Orange Mobile Auth",
    
    "summary": "Secure mobile authentication foundation for POS QR login",
    
    "description": """
Secure mobile authentication models for POS QR based mobile login.
This module stores short-lived login challenges and issued mobile token metadata.
    """,
    
    "author": "SwissAlps",
    
    "website": "https://www.swissalps.io",
    
    "category": "Point of Sale",
    
    "version": "19.0.1.0.0",
    
    "depends": ["point_of_sale", "hr"],
    
    "data": [
        "security/ir.model.access.csv",
        "views/pos_config_view.xml",
    ],
    
     "assets": {
    "point_of_sale._assets_pos": [
        "mupi_mobile_auth/static/src/app/connect_mobile/connect_mobile_button.js",
        "mupi_mobile_auth/static/src/app/connect_mobile/connect_mobile_button.xml",
        "mupi_mobile_auth/static/src/app/mobile_qr_popup/mobile_qr_popup.js",
        "mupi_mobile_auth/static/src/app/mobile_qr_popup/mobile_qr_popup.xml",
    ],
},
    
    "license": "LGPL-3",
    
    "installable": True,
    
    "application": False,
}