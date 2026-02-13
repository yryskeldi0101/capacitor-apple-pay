import { WebPlugin } from '@capacitor/core';

import type {
  AddCardProvisioningData,
  CanAddCardResult,
  CanMakePaymentsResult,
  CapacitorApplyPayPlugin,
  CompleteAddCardResult,
  CompletePaymentResult,
  IsCardInWalletResult,
  ObserveResult,
  PaymentAuthorizationResult,
} from './definitions';

export class CapacitorApplyPayWeb extends WebPlugin implements CapacitorApplyPayPlugin {
  async canAddCard(): Promise<CanAddCardResult> {
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

  async canMakePayments(): Promise<CanMakePaymentsResult> {
    return { canMakePayments: false };
  }

  async isCardInWallet(): Promise<IsCardInWalletResult> {
    return { isCardInWallet: false, matches: [] };
  }

  async startAddCard(): Promise<AddCardProvisioningData> {
    throw this.unavailable('Apple Pay card provisioning is available only on iOS.');
  }

  async completeAddCard(): Promise<CompleteAddCardResult> {
    throw this.unavailable('Apple Pay card provisioning is available only on iOS.');
  }

  async presentPaymentSheet(): Promise<PaymentAuthorizationResult> {
    throw this.unavailable('Apple Pay payment sheet is available only on iOS.');
  }

  async completePayment(): Promise<CompletePaymentResult> {
    throw this.unavailable('Apple Pay payment sheet is available only on iOS.');
  }

  async onTokenStatusChanged(): Promise<ObserveResult> {
    return { listening: false };
  }

  async onCardRemoved(): Promise<ObserveResult> {
    return { listening: false };
  }

  async onDeviceChanged(): Promise<ObserveResult> {
    return { listening: false };
  }
}
