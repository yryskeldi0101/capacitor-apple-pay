import { WebPlugin } from '@capacitor/core';
export class CapacitorApplePayWeb extends WebPlugin {
    async canAddCard() {
        return {
            canAddCard: false,
            canAddPaymentPass: false,
            entitlementChecks: {
                inAppPayments: false,
                paymentPassProvisioning: false,
            },
            reasons: ['Apple Pay card provisioning is available only on iOS.'],
        };
    }
    async canMakePayments() {
        return { canMakePayments: false };
    }
    async isCardInWallet() {
        return { isCardInWallet: false, matches: [] };
    }
    async startAddCard() {
        throw this.unavailable('Apple Pay card provisioning is available only on iOS.');
    }
    async completeAddCard() {
        throw this.unavailable('Apple Pay card provisioning is available only on iOS.');
    }
    async presentPaymentSheet() {
        throw this.unavailable('Apple Pay payment sheet is available only on iOS.');
    }
    async completePayment() {
        throw this.unavailable('Apple Pay payment sheet is available only on iOS.');
    }
    async onTokenStatusChanged() {
        return { listening: false };
    }
    async onCardRemoved() {
        return { listening: false };
    }
    async onDeviceChanged() {
        return { listening: false };
    }
}
//# sourceMappingURL=web.js.map