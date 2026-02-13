import type { PluginListenerHandle } from '@capacitor/core';

export type ApplePayNetwork =
  | 'amex'
  | 'carteBancaires'
  | 'chinaUnionPay'
  | 'discover'
  | 'eftpos'
  | 'electron'
  | 'idCredit'
  | 'interac'
  | 'JCB'
  | 'mada'
  | 'maestro'
  | 'masterCard'
  | 'privateLabel'
  | 'quicPay'
  | 'suica'
  | 'visa'
  | 'vPay';

export type MerchantCapability = 'threeDS' | 'credit' | 'debit' | 'emv';

export type ContactField = 'name' | 'emailAddress' | 'phoneNumber' | 'postalAddress' | 'phoneticName';

export type ShippingType = 'shipping' | 'delivery' | 'storePickup' | 'servicePickup';

export type PaymentSummaryItemType = 'final' | 'pending';

export type PaymentCompletionStatus =
  | 'success'
  | 'failure'
  | 'canceled'
  | 'invalidBillingPostalAddress'
  | 'invalidShippingPostalAddress'
  | 'invalidShippingContact'
  | 'pinRequired'
  | 'pinIncorrect'
  | 'pinLockout';

export interface EntitlementChecks {
  inAppPayments: boolean;
  paymentPassProvisioning: boolean;
}

export interface CanAddCardResult {
  canAddCard: boolean;
  canAddPaymentPass: boolean;
  entitlementChecks: EntitlementChecks;
  reasons: string[];
}

export interface CanMakePaymentsOptions {
  supportedNetworks?: ApplePayNetwork[];
}

export interface CanMakePaymentsResult {
  canMakePayments: boolean;
}

export interface IsCardInWalletOptions {
  cardId?: string;
  cardSuffix?: string;
}

export interface WalletCardMatch {
  serialNumber: string;
  primaryAccountIdentifier?: string;
  primaryAccountNumberSuffix?: string;
  deviceAccountIdentifier?: string;
  isRemote: boolean;
  deviceName?: string;
}

export interface IsCardInWalletResult {
  isCardInWallet: boolean;
  matches: WalletCardMatch[];
}

export interface StartAddCardOptions {
  cardId: string;
  cardholderName?: string;
  primaryAccountSuffix?: string;
  localizedDescription?: string;
  paymentNetwork?: ApplePayNetwork;
}

export interface AddCardProvisioningData {
  cardId: string;
  certificates: string[];
  nonce: string;
  nonceSignature: string;
}

export interface CompleteAddCardOptions {
  activationData: string;
  encryptedPassData: string;
  ephemeralPublicKey: string;
}

export interface CompleteAddCardResult {
  submitted: boolean;
}

export interface PaymentSummaryItem {
  label: string;
  amount: string;
  type?: PaymentSummaryItemType;
}

export interface PresentPaymentSheetOptions {
  merchantIdentifier: string;
  countryCode: string;
  currencyCode: string;
  paymentSummaryItems: PaymentSummaryItem[];
  supportedNetworks?: ApplePayNetwork[];
  merchantCapabilities?: MerchantCapability[];
  requiredBillingContactFields?: ContactField[];
  requiredShippingContactFields?: ContactField[];
  shippingType?: ShippingType;
}

export interface PaymentMethodInfo {
  displayName?: string;
  network?: string;
  type?: string;
}

export interface PaymentAuthorizationResult {
  tokenData: string;
  transactionIdentifier: string;
  paymentMethod: PaymentMethodInfo;
}

export interface CompletePaymentOptions {
  status: PaymentCompletionStatus;
  errors?: string[];
}

export interface CompletePaymentResult {
  completed: boolean;
}

export interface ObserveResult {
  listening: boolean;
}

export interface TokenStatusChangedEvent {
  status: string;
  serialNumber?: string;
  primaryAccountIdentifier?: string;
  primaryAccountNumberSuffix?: string;
  activationState?: string;
  isRemote?: boolean;
  deviceName?: string;
}

export interface CardRemovedEvent {
  serialNumber: string;
  primaryAccountIdentifier?: string;
  primaryAccountNumberSuffix?: string;
  deviceAccountIdentifier?: string;
  isRemote: boolean;
  deviceName?: string;
}

export interface DeviceChangedEvent {
  remotePassCount: number;
}

export interface CapacitorApplePayPlugin {
  canAddCard(): Promise<CanAddCardResult>;
  canMakePayments(options?: CanMakePaymentsOptions): Promise<CanMakePaymentsResult>;
  isCardInWallet(options?: IsCardInWalletOptions): Promise<IsCardInWalletResult>;
  startAddCard(options: StartAddCardOptions): Promise<AddCardProvisioningData>;
  completeAddCard(options: CompleteAddCardOptions): Promise<CompleteAddCardResult>;
  presentPaymentSheet(options: PresentPaymentSheetOptions): Promise<PaymentAuthorizationResult>;
  completePayment(options: CompletePaymentOptions): Promise<CompletePaymentResult>;
  onTokenStatusChanged(): Promise<ObserveResult>;
  onCardRemoved(): Promise<ObserveResult>;
  onDeviceChanged(): Promise<ObserveResult>;
  addListener(
    eventName: 'tokenStatusChanged',
    listenerFunc: (event: TokenStatusChangedEvent) => void,
  ): Promise<PluginListenerHandle>;
  addListener(eventName: 'cardRemoved', listenerFunc: (event: CardRemovedEvent) => void): Promise<PluginListenerHandle>;
  addListener(
    eventName: 'deviceChanged',
    listenerFunc: (event: DeviceChangedEvent) => void,
  ): Promise<PluginListenerHandle>;
  removeAllListeners(): Promise<void>;
}
