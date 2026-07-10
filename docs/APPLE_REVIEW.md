# Apple Review Checklist

This document tracks the Apple App Review readiness items for OrangeONE.

## App Review Access

Apple reviewers must be able to test the app without a live Odoo POS server.

Use Demo Mode for review.

Demo Mode must support:

- Login without Odoo backend
- Scan existing demo product
- Scan unknown demo barcode
- Add product from unknown barcode
- Update price
- Edit product name and tax

## App Review Notes

App Review notes should explain:

```text
This app is used with an Odoo POS backend in production.

For Apple review, Demo Mode is available so the reviewer can test the app without access to our private POS server.

Please use Demo Mode from the app settings/login screen and follow the demo flow:
1. Continue in Demo Mode.
2. Scan the existing demo product.
3. Update the product price.
4. Edit the product name and tax.
5. Scan the unknown demo barcode.
6. Add a new product.