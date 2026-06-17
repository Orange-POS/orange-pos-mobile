/** @odoo-module **/

import { ControlButtons } from "@point_of_sale/app/screens/product_screen/control_buttons/control_buttons";
import { patch } from "@web/core/utils/patch";
import { MobileQrPopup } from "../mobile_qr_popup/mobile_qr_popup";

patch(ControlButtons.prototype, {
    async onClickConnectMobile(ev) {
        ev?.preventDefault();
        ev?.stopPropagation();

        try {
            const sessionId = this.pos?.session?.id || this.env.services.pos?.session?.id;

            const response = await fetch("/mupi/mobile/auth/challenge/create", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    jsonrpc: "2.0",
                    method: "call",
                    params: {
                        pos_session_id: sessionId,
                    },
                }),
            });

            const data = await response.json();
            const result = data.result;

            if (!result?.ok) {
                alert(result?.error || "Failed to create challenge.");
                return;
            }

            this.dialog.add(MobileQrPopup, {
                qrPayload: result.qr_payload,
                expiresAt: result.expires_at,
            });
        } catch (error) {
            console.error("[Mobile Auth] QR popup error", error);
            alert("Failed to open mobile QR popup.");
        }
    },
});