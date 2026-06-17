/** @odoo-module **/

import { Component } from "@odoo/owl";
import { Dialog } from "@web/core/dialog/dialog";

export class MobileQrPopup extends Component {
    static template = "mupi_mobile_auth.MobileQrPopup";
    static components = { Dialog };

    static props = {
        close: Function,
        qrPayload: String,
        expiresAt: String,
    };

    get qrImage() {
        return `/report/barcode/QR/${encodeURIComponent(this.props.qrPayload)}?width=250&height=250`;
    }

    close() {
        this.props.close();
    }
}