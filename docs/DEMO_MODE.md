# Demo Mode

Demo Mode exists to support Apple App Review and internal testing when an Odoo POS server is not available.

## Purpose

The production app normally requires:

- Odoo POS backend
- Login QR code
- Product barcode lookup endpoint
- Product create/update endpoints

Apple reviewers cannot access the local/customer Odoo setup, so Demo Mode provides a safe offline test path.

## Demo Mode Requirements

Demo Mode must:

1. Work without Odoo.
2. Work without a real login QR code.
3. Work without printed barcodes.
4. Support core app flows.
5. Be clearly visible to reviewers.
6. Be easy to disable or remove.
7. Not affect real users when disabled.

## Supported Demo Flows

Demo Mode supports:

- Login without Odoo
- Product scan using demo barcode picker
- View product details
- Update price
- Edit product name and sales tax
- Add product for unknown barcode

## Demo Barcodes

Existing product:

```text
100001