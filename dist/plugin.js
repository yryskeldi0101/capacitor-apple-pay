var capacitorCapacitorApplePay = (function (exports, core) {
    'use strict';

    const CapacitorApplePay = core.registerPlugin('CapacitorApplePay', {
        web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.CapacitorApplePayWeb()),
    });

    class CapacitorApplePayWeb extends core.WebPlugin {
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

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        CapacitorApplePayWeb: CapacitorApplePayWeb
    });

    exports.CapacitorApplePay = CapacitorApplePay;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
