import { WebPlugin } from '@capacitor/core';
import type { AddCardProvisioningData, CanAddCardResult, CanMakePaymentsResult, CapacitorApplePayPlugin, CompleteAddCardResult, CompletePaymentResult, IsCardInWalletResult, ObserveResult, PaymentAuthorizationResult } from './definitions';
export declare class CapacitorApplePayWeb extends WebPlugin implements CapacitorApplePayPlugin {
    canAddCard(): Promise<CanAddCardResult>;
    canMakePayments(): Promise<CanMakePaymentsResult>;
    isCardInWallet(): Promise<IsCardInWalletResult>;
    startAddCard(): Promise<AddCardProvisioningData>;
    completeAddCard(): Promise<CompleteAddCardResult>;
    presentPaymentSheet(): Promise<PaymentAuthorizationResult>;
    completePayment(): Promise<CompletePaymentResult>;
    onTokenStatusChanged(): Promise<ObserveResult>;
    onCardRemoved(): Promise<ObserveResult>;
    onDeviceChanged(): Promise<ObserveResult>;
}
