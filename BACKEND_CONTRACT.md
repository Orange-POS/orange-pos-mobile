# Odoo Mobile Backend Contract

## QR Login Flow

The POS "Connect Mobile" action generates a QR code containing JSON.

Expected QR JSON:

```json
{
  "challenge": "string",
  "nonce": "string",
  "pos_session_id": 40,
  "pos_config_id": 1,
  "expires_at": "2026-05-25 22:35:15"
}