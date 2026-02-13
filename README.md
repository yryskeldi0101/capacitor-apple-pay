# capacitor-apple-pay

Implement apple pay to mobile app

## Install

```bash
npm install capacitor-apple-pay
npx cap sync
```

## API

<docgen-index>

* [`canAddCard()`](#canaddcard)
* [`canMakePayments(...)`](#canmakepayments)
* [`isCardInWallet(...)`](#iscardinwallet)
* [`startAddCard(...)`](#startaddcard)
* [`completeAddCard(...)`](#completeaddcard)
* [`presentPaymentSheet(...)`](#presentpaymentsheet)
* [`completePayment(...)`](#completepayment)
* [`onTokenStatusChanged()`](#ontokenstatuschanged)
* [`onCardRemoved()`](#oncardremoved)
* [`onDeviceChanged()`](#ondevicechanged)
* [`addListener('tokenStatusChanged', ...)`](#addlistenertokenstatuschanged-)
* [`addListener('cardRemoved', ...)`](#addlistenercardremoved-)
* [`addListener('deviceChanged', ...)`](#addlistenerdevicechanged-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### canAddCard()

```typescript
canAddCard() => Promise<CanAddCardResult>
```

**Returns:** <code>Promise&lt;<a href="#canaddcardresult">CanAddCardResult</a>&gt;</code>

--------------------


### canMakePayments(...)

```typescript
canMakePayments(options?: CanMakePaymentsOptions | undefined) => Promise<CanMakePaymentsResult>
```

| Param         | Type                                                                      |
| ------------- | ------------------------------------------------------------------------- |
| **`options`** | <code><a href="#canmakepaymentsoptions">CanMakePaymentsOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#canmakepaymentsresult">CanMakePaymentsResult</a>&gt;</code>

--------------------


### isCardInWallet(...)

```typescript
isCardInWallet(options?: IsCardInWalletOptions | undefined) => Promise<IsCardInWalletResult>
```

| Param         | Type                                                                    |
| ------------- | ----------------------------------------------------------------------- |
| **`options`** | <code><a href="#iscardinwalletoptions">IsCardInWalletOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#iscardinwalletresult">IsCardInWalletResult</a>&gt;</code>

--------------------


### startAddCard(...)

```typescript
startAddCard(options: StartAddCardOptions) => Promise<AddCardProvisioningData>
```

| Param         | Type                                                                |
| ------------- | ------------------------------------------------------------------- |
| **`options`** | <code><a href="#startaddcardoptions">StartAddCardOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#addcardprovisioningdata">AddCardProvisioningData</a>&gt;</code>

--------------------


### completeAddCard(...)

```typescript
completeAddCard(options: CompleteAddCardOptions) => Promise<CompleteAddCardResult>
```

| Param         | Type                                                                      |
| ------------- | ------------------------------------------------------------------------- |
| **`options`** | <code><a href="#completeaddcardoptions">CompleteAddCardOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#completeaddcardresult">CompleteAddCardResult</a>&gt;</code>

--------------------


### presentPaymentSheet(...)

```typescript
presentPaymentSheet(options: PresentPaymentSheetOptions) => Promise<PaymentAuthorizationResult>
```

| Param         | Type                                                                              |
| ------------- | --------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#presentpaymentsheetoptions">PresentPaymentSheetOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#paymentauthorizationresult">PaymentAuthorizationResult</a>&gt;</code>

--------------------


### completePayment(...)

```typescript
completePayment(options: CompletePaymentOptions) => Promise<CompletePaymentResult>
```

| Param         | Type                                                                      |
| ------------- | ------------------------------------------------------------------------- |
| **`options`** | <code><a href="#completepaymentoptions">CompletePaymentOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#completepaymentresult">CompletePaymentResult</a>&gt;</code>

--------------------


### onTokenStatusChanged()

```typescript
onTokenStatusChanged() => Promise<ObserveResult>
```

**Returns:** <code>Promise&lt;<a href="#observeresult">ObserveResult</a>&gt;</code>

--------------------


### onCardRemoved()

```typescript
onCardRemoved() => Promise<ObserveResult>
```

**Returns:** <code>Promise&lt;<a href="#observeresult">ObserveResult</a>&gt;</code>

--------------------


### onDeviceChanged()

```typescript
onDeviceChanged() => Promise<ObserveResult>
```

**Returns:** <code>Promise&lt;<a href="#observeresult">ObserveResult</a>&gt;</code>

--------------------


### addListener('tokenStatusChanged', ...)

```typescript
addListener(eventName: 'tokenStatusChanged', listenerFunc: (event: TokenStatusChangedEvent) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                                            |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'tokenStatusChanged'</code>                                                               |
| **`listenerFunc`** | <code>(event: <a href="#tokenstatuschangedevent">TokenStatusChangedEvent</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('cardRemoved', ...)

```typescript
addListener(eventName: 'cardRemoved', listenerFunc: (event: CardRemovedEvent) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                              |
| ------------------ | --------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'cardRemoved'</code>                                                        |
| **`listenerFunc`** | <code>(event: <a href="#cardremovedevent">CardRemovedEvent</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('deviceChanged', ...)

```typescript
addListener(eventName: 'deviceChanged', listenerFunc: (event: DeviceChangedEvent) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                                  |
| ------------------ | ------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'deviceChanged'</code>                                                          |
| **`listenerFunc`** | <code>(event: <a href="#devicechangedevent">DeviceChangedEvent</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

--------------------


### Interfaces


#### CanAddCardResult

| Prop                    | Type                                                            |
| ----------------------- | --------------------------------------------------------------- |
| **`canAddCard`**        | <code>boolean</code>                                            |
| **`canAddPaymentPass`** | <code>boolean</code>                                            |
| **`entitlementChecks`** | <code><a href="#entitlementchecks">EntitlementChecks</a></code> |
| **`reasons`**           | <code>string[]</code>                                           |


#### EntitlementChecks

| Prop                          | Type                 |
| ----------------------------- | -------------------- |
| **`inAppPayments`**           | <code>boolean</code> |
| **`paymentPassProvisioning`** | <code>boolean</code> |


#### CanMakePaymentsResult

| Prop                  | Type                 |
| --------------------- | -------------------- |
| **`canMakePayments`** | <code>boolean</code> |


#### CanMakePaymentsOptions

| Prop                    | Type                           |
| ----------------------- | ------------------------------ |
| **`supportedNetworks`** | <code>ApplePayNetwork[]</code> |


#### IsCardInWalletResult

| Prop                 | Type                           |
| -------------------- | ------------------------------ |
| **`isCardInWallet`** | <code>boolean</code>           |
| **`matches`**        | <code>WalletCardMatch[]</code> |


#### WalletCardMatch

| Prop                             | Type                 |
| -------------------------------- | -------------------- |
| **`serialNumber`**               | <code>string</code>  |
| **`primaryAccountIdentifier`**   | <code>string</code>  |
| **`primaryAccountNumberSuffix`** | <code>string</code>  |
| **`deviceAccountIdentifier`**    | <code>string</code>  |
| **`isRemote`**                   | <code>boolean</code> |
| **`deviceName`**                 | <code>string</code>  |


#### IsCardInWalletOptions

| Prop             | Type                |
| ---------------- | ------------------- |
| **`cardId`**     | <code>string</code> |
| **`cardSuffix`** | <code>string</code> |


#### AddCardProvisioningData

| Prop                 | Type                  |
| -------------------- | --------------------- |
| **`cardId`**         | <code>string</code>   |
| **`certificates`**   | <code>string[]</code> |
| **`nonce`**          | <code>string</code>   |
| **`nonceSignature`** | <code>string</code>   |


#### StartAddCardOptions

| Prop                       | Type                                                        |
| -------------------------- | ----------------------------------------------------------- |
| **`cardId`**               | <code>string</code>                                         |
| **`cardholderName`**       | <code>string</code>                                         |
| **`primaryAccountSuffix`** | <code>string</code>                                         |
| **`localizedDescription`** | <code>string</code>                                         |
| **`paymentNetwork`**       | <code><a href="#applepaynetwork">ApplePayNetwork</a></code> |


#### CompleteAddCardResult

| Prop            | Type                 |
| --------------- | -------------------- |
| **`submitted`** | <code>boolean</code> |


#### CompleteAddCardOptions

| Prop                     | Type                |
| ------------------------ | ------------------- |
| **`activationData`**     | <code>string</code> |
| **`encryptedPassData`**  | <code>string</code> |
| **`ephemeralPublicKey`** | <code>string</code> |


#### PaymentAuthorizationResult

| Prop                        | Type                                                            |
| --------------------------- | --------------------------------------------------------------- |
| **`tokenData`**             | <code>string</code>                                             |
| **`transactionIdentifier`** | <code>string</code>                                             |
| **`paymentMethod`**         | <code><a href="#paymentmethodinfo">PaymentMethodInfo</a></code> |


#### PaymentMethodInfo

| Prop              | Type                |
| ----------------- | ------------------- |
| **`displayName`** | <code>string</code> |
| **`network`**     | <code>string</code> |
| **`type`**        | <code>string</code> |


#### PresentPaymentSheetOptions

| Prop                                | Type                                                  |
| ----------------------------------- | ----------------------------------------------------- |
| **`merchantIdentifier`**            | <code>string</code>                                   |
| **`countryCode`**                   | <code>string</code>                                   |
| **`currencyCode`**                  | <code>string</code>                                   |
| **`paymentSummaryItems`**           | <code>PaymentSummaryItem[]</code>                     |
| **`supportedNetworks`**             | <code>ApplePayNetwork[]</code>                        |
| **`merchantCapabilities`**          | <code>MerchantCapability[]</code>                     |
| **`requiredBillingContactFields`**  | <code>ContactField[]</code>                           |
| **`requiredShippingContactFields`** | <code>ContactField[]</code>                           |
| **`shippingType`**                  | <code><a href="#shippingtype">ShippingType</a></code> |


#### PaymentSummaryItem

| Prop         | Type                                                                      |
| ------------ | ------------------------------------------------------------------------- |
| **`label`**  | <code>string</code>                                                       |
| **`amount`** | <code>string</code>                                                       |
| **`type`**   | <code><a href="#paymentsummaryitemtype">PaymentSummaryItemType</a></code> |


#### CompletePaymentResult

| Prop            | Type                 |
| --------------- | -------------------- |
| **`completed`** | <code>boolean</code> |


#### CompletePaymentOptions

| Prop         | Type                                                                        |
| ------------ | --------------------------------------------------------------------------- |
| **`status`** | <code><a href="#paymentcompletionstatus">PaymentCompletionStatus</a></code> |
| **`errors`** | <code>string[]</code>                                                       |


#### ObserveResult

| Prop            | Type                 |
| --------------- | -------------------- |
| **`listening`** | <code>boolean</code> |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### TokenStatusChangedEvent

| Prop                             | Type                 |
| -------------------------------- | -------------------- |
| **`status`**                     | <code>string</code>  |
| **`serialNumber`**               | <code>string</code>  |
| **`primaryAccountIdentifier`**   | <code>string</code>  |
| **`primaryAccountNumberSuffix`** | <code>string</code>  |
| **`activationState`**            | <code>string</code>  |
| **`isRemote`**                   | <code>boolean</code> |
| **`deviceName`**                 | <code>string</code>  |


#### CardRemovedEvent

| Prop                             | Type                 |
| -------------------------------- | -------------------- |
| **`serialNumber`**               | <code>string</code>  |
| **`primaryAccountIdentifier`**   | <code>string</code>  |
| **`primaryAccountNumberSuffix`** | <code>string</code>  |
| **`deviceAccountIdentifier`**    | <code>string</code>  |
| **`isRemote`**                   | <code>boolean</code> |
| **`deviceName`**                 | <code>string</code>  |


#### DeviceChangedEvent

| Prop                  | Type                |
| --------------------- | ------------------- |
| **`remotePassCount`** | <code>number</code> |


### Type Aliases


#### ApplePayNetwork

<code>'amex' | 'carteBancaires' | 'chinaUnionPay' | 'discover' | 'eftpos' | 'electron' | 'idCredit' | 'interac' | 'JCB' | 'mada' | 'maestro' | 'masterCard' | 'privateLabel' | 'quicPay' | 'suica' | 'visa' | 'vPay'</code>


#### PaymentSummaryItemType

<code>'final' | 'pending'</code>


#### MerchantCapability

<code>'threeDS' | 'credit' | 'debit' | 'emv'</code>


#### ContactField

<code>'name' | 'emailAddress' | 'phoneNumber' | 'postalAddress' | 'phoneticName'</code>


#### ShippingType

<code>'shipping' | 'delivery' | 'storePickup' | 'servicePickup'</code>


#### PaymentCompletionStatus

<code>'success' | 'failure' | 'canceled' | 'invalidBillingPostalAddress' | 'invalidShippingPostalAddress' | 'invalidShippingContact' | 'pinRequired' | 'pinIncorrect' | 'pinLockout'</code>

</docgen-api>
