import Capacitor
import Foundation
import PassKit

// swiftlint:disable type_body_length
@objc(CapacitorApplePayPlugin)
public class CapacitorApplePayPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "CapacitorApplePayPlugin"
    public let jsName = "CapacitorApplePay"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "canAddCard", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "canMakePayments", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isCardInWallet", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "startAddCard", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "completeAddCard", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "presentPaymentSheet", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "completePayment", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "onTokenStatusChanged", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "onCardRemoved", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "onDeviceChanged", returnType: CAPPluginReturnPromise)
    ]

    private let passLibrary = PKPassLibrary()

    private var pendingAddCardCall: CAPPluginCall?
    private var pendingAddCardCompletion: ((PKAddPaymentPassRequest) -> Void)?
    private var pendingAddCardCardId: String?

    private var pendingPaymentCall: CAPPluginCall?
    private var pendingPaymentCompletion: ((PKPaymentAuthorizationResult) -> Void)?
    private var paymentController: PKPaymentAuthorizationController?

    private var isObservingPassLibrary = false
    private var passSnapshot: [String: PaymentPassSnapshot] = [:]

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func load() {
        super.load()
        startPassLibraryObserversIfNeeded()
    }

    @objc func canAddCard(_ call: CAPPluginCall) {
        let entitlementChecks = entitlementChecks()
        let canAddPaymentPass = PKAddPaymentPassViewController.canAddPaymentPass()

        var reasons: [String] = []
        if !entitlementChecks.inAppPayments {
            reasons.append("Missing com.apple.developer.in-app-payments entitlement.")
        }
        if !entitlementChecks.paymentPassProvisioning {
            reasons.append("Missing com.apple.developer.payment-pass-provisioning entitlement.")
        }
        if !canAddPaymentPass {
            reasons.append("Device does not support adding payment passes or Wallet is unavailable.")
        }

        let canAddCard = entitlementChecks.inAppPayments && entitlementChecks.paymentPassProvisioning && canAddPaymentPass
        call.resolve([
            "canAddCard": canAddCard,
            "canAddPaymentPass": canAddPaymentPass,
            "entitlementChecks": [
                "inAppPayments": entitlementChecks.inAppPayments,
                "paymentPassProvisioning": entitlementChecks.paymentPassProvisioning
            ],
            "reasons": reasons
        ])
    }

    @objc func canMakePayments(_ call: CAPPluginCall) {
        let options = call.options ?? [:]
        let supportedNetworksRaw = options["supportedNetworks"] as? [String] ?? []
        let supportedNetworks = supportedNetworksRaw.compactMap { Self.paymentNetwork(from: $0) }

        let canMakePayments: Bool
        if supportedNetworks.isEmpty {
            canMakePayments = PKPaymentAuthorizationController.canMakePayments()
        } else {
            canMakePayments = PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
        }

        call.resolve(["canMakePayments": canMakePayments])
    }

    @objc func isCardInWallet(_ call: CAPPluginCall) {
        let cardId = call.getString("cardId")
        let cardSuffix = call.getString("cardSuffix")

        let matches = paymentPasses().filter { pass in
            guard cardId != nil || cardSuffix != nil else { return true }

            let matchesCardId = cardId == nil
                || pass.primaryAccountIdentifier == cardId
                || pass.deviceAccountIdentifier == cardId
            let matchesSuffix = cardSuffix == nil || pass.primaryAccountNumberSuffix == cardSuffix

            return matchesCardId && matchesSuffix
        }

        let serializedMatches = matches.map { paymentPassDictionary(from: snapshot(for: $0)) }

        call.resolve([
            "isCardInWallet": !matches.isEmpty,
            "matches": serializedMatches
        ])
    }

    @objc func startAddCard(_ call: CAPPluginCall) {
        guard pendingAddCardCall == nil && pendingAddCardCompletion == nil else {
            call.reject("Card provisioning is already in progress.")
            return
        }

        guard PKAddPaymentPassViewController.canAddPaymentPass() else {
            call.reject("This device cannot add cards to Apple Wallet.")
            return
        }

        guard let cardId = call.getString("cardId"), !cardId.isEmpty else {
            call.reject("cardId is required.")
            return
        }

        guard let addCardController = makeAddCardController(from: call, cardId: cardId) else {
            call.reject("Unable to initialize PKAddPaymentPassViewController.")
            return
        }

        pendingAddCardCall = call
        pendingAddCardCardId = cardId

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let viewController = self.bridge?.viewController else {
                self.pendingAddCardCall?.reject("Unable to access root view controller.")
                self.resetAddCardState()
                return
            }

            viewController.present(addCardController, animated: true)
        }
    }

    @objc func completeAddCard(_ call: CAPPluginCall) {
        guard let completion = pendingAddCardCompletion else {
            call.reject("No pending add-card request found. Call startAddCard first.")
            return
        }

        guard
            let activationDataBase64 = call.getString("activationData"),
            let encryptedPassDataBase64 = call.getString("encryptedPassData"),
            let ephemeralPublicKeyBase64 = call.getString("ephemeralPublicKey")
        else {
            call.reject("activationData, encryptedPassData and ephemeralPublicKey are required.")
            return
        }

        guard
            let activationData = Data(base64Encoded: activationDataBase64, options: .ignoreUnknownCharacters),
            let encryptedPassData = Data(base64Encoded: encryptedPassDataBase64, options: .ignoreUnknownCharacters),
            let ephemeralPublicKey = Data(base64Encoded: ephemeralPublicKeyBase64, options: .ignoreUnknownCharacters)
        else {
            call.reject("Add card payload must be base64-encoded.")
            return
        }

        let request = PKAddPaymentPassRequest()
        request.activationData = activationData
        request.encryptedPassData = encryptedPassData
        request.ephemeralPublicKey = ephemeralPublicKey

        completion(request)
        pendingAddCardCompletion = nil

        call.resolve(["submitted": true])
    }

    @objc func presentPaymentSheet(_ call: CAPPluginCall) {
        guard pendingPaymentCall == nil && pendingPaymentCompletion == nil else {
            call.reject("Payment authorization is already in progress.")
            return
        }

        guard PKPaymentAuthorizationController.canMakePayments() else {
            call.reject("Apple Pay payments are not available on this device.")
            return
        }

        guard let paymentRequest = makePaymentRequest(from: call) else {
            return
        }

        let controller = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        controller.delegate = self

        pendingPaymentCall = call
        paymentController = controller

        controller.present { [weak self] presented in
            guard let self else { return }
            guard presented else {
                self.pendingPaymentCall?.reject("Unable to present Apple Pay payment sheet.")
                self.resetPaymentState()
                return
            }
        }
    }

    @objc func completePayment(_ call: CAPPluginCall) {
        guard let completion = pendingPaymentCompletion else {
            call.reject("No pending payment authorization found. Call presentPaymentSheet first.")
            return
        }

        let status = Self.paymentAuthorizationStatus(from: call.getString("status") ?? "failure")
        let errorMessages = call.getArray("errors", String.self) ?? []
        let errors: [Error] = errorMessages.map { message in
            NSError(
                domain: "CapacitorApplePay",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: message]
            )
        }

        completion(PKPaymentAuthorizationResult(status: status, errors: errors.isEmpty ? nil : errors))
        pendingPaymentCompletion = nil

        call.resolve(["completed": true])
    }

    @objc func onTokenStatusChanged(_ call: CAPPluginCall) {
        startPassLibraryObserversIfNeeded()
        call.resolve(["listening": true])
    }

    @objc func onCardRemoved(_ call: CAPPluginCall) {
        startPassLibraryObserversIfNeeded()
        call.resolve(["listening": true])
    }

    @objc func onDeviceChanged(_ call: CAPPluginCall) {
        startPassLibraryObserversIfNeeded()
        call.resolve(["listening": true])
    }

    @objc private func handlePassLibraryDidChange() {
        processPassSnapshotChanges()
    }

    @objc private func handleRemotePassesDidChange() {
        processPassSnapshotChanges(forceDeviceEvent: true)
    }

    private func processPassSnapshotChanges(forceDeviceEvent: Bool = false) {
        let previousSnapshot = passSnapshot
        let currentSnapshot = snapshotBySerialNumber()

        for (serialNumber, removedPass) in previousSnapshot where currentSnapshot[serialNumber] == nil {
            notifyListeners("cardRemoved", data: paymentPassDictionary(from: removedPass))

            var event = paymentPassDictionary(from: removedPass)
            event["status"] = "removed"
            notifyListeners("tokenStatusChanged", data: event)
        }

        for (serialNumber, currentPass) in currentSnapshot {
            guard let previousPass = previousSnapshot[serialNumber] else {
                var event = paymentPassDictionary(from: currentPass)
                event["status"] = "added"
                notifyListeners("tokenStatusChanged", data: event)
                continue
            }

            if previousPass.activationState != currentPass.activationState {
                var event = paymentPassDictionary(from: currentPass)
                event["status"] = "activationChanged"
                notifyListeners("tokenStatusChanged", data: event)
            }
        }

        let previousRemoteCount = previousSnapshot.values.filter { $0.isRemote }.count
        let currentRemoteCount = currentSnapshot.values.filter { $0.isRemote }.count

        if forceDeviceEvent || previousRemoteCount != currentRemoteCount {
            notifyListeners("deviceChanged", data: ["remotePassCount": currentRemoteCount])
        }

        passSnapshot = currentSnapshot
    }

    private func startPassLibraryObserversIfNeeded() {
        guard !isObservingPassLibrary else { return }

        passSnapshot = snapshotBySerialNumber()
        isObservingPassLibrary = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePassLibraryDidChange),
            name: Notification.Name(
                PKPassLibraryNotificationName.PKPassLibraryDidChange.rawValue
            ),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemotePassesDidChange),
            name: Notification.Name(
                PKPassLibraryNotificationName.PKPassLibraryRemotePaymentPassesDidChange.rawValue
            ),
            object: nil
        )
    }

    private func makeAddCardController(from call: CAPPluginCall, cardId: String) -> PKAddPaymentPassViewController? {
        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
            return nil
        }
        configuration.primaryAccountIdentifier = cardId

        if let cardholderName = call.getString("cardholderName"), !cardholderName.isEmpty {
            configuration.cardholderName = cardholderName
        }

        let suffix = call.getString("primaryAccountSuffix")?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedSuffix = (suffix?.isEmpty == false ? suffix : nil) ?? String(cardId.suffix(4))
        configuration.primaryAccountSuffix = resolvedSuffix

        if let localizedDescription = call.getString("localizedDescription"), !localizedDescription.isEmpty {
            configuration.localizedDescription = localizedDescription
        } else {
            configuration.localizedDescription = "Card ending \(resolvedSuffix)"
        }

        if let paymentNetworkRaw = call.getString("paymentNetwork"),
           let paymentNetwork = Self.paymentNetwork(from: paymentNetworkRaw) {
            configuration.paymentNetwork = paymentNetwork
        }

        return PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: self)
    }

    private func makePaymentRequest(from call: CAPPluginCall) -> PKPaymentRequest? {
        let options = call.options ?? [:]

        guard let merchantIdentifier = call.getString("merchantIdentifier"), !merchantIdentifier.isEmpty else {
            call.reject("merchantIdentifier is required.")
            return nil
        }

        guard let countryCode = call.getString("countryCode"), !countryCode.isEmpty else {
            call.reject("countryCode is required.")
            return nil
        }

        guard let currencyCode = call.getString("currencyCode"), !currencyCode.isEmpty else {
            call.reject("currencyCode is required.")
            return nil
        }

        guard let summaryItemsRaw = options["paymentSummaryItems"] as? [JSObject], !summaryItemsRaw.isEmpty else {
            call.reject("paymentSummaryItems must contain at least one item.")
            return nil
        }

        var summaryItems: [PKPaymentSummaryItem] = []
        for item in summaryItemsRaw {
            guard let label = item["label"] as? String, !label.isEmpty else {
                call.reject("Each paymentSummaryItem must include a non-empty label.")
                return nil
            }

            guard let amountString = item["amount"] as? String else {
                call.reject("Each paymentSummaryItem must include amount as string.")
                return nil
            }

            let amount = NSDecimalNumber(string: amountString)
            if amount == NSDecimalNumber.notANumber {
                call.reject("Invalid paymentSummaryItem amount: \(amountString)")
                return nil
            }

            let typeRaw = (item["type"] as? String)?.lowercased()
            let type: PKPaymentSummaryItemType = typeRaw == "pending" ? .pending : .final
            summaryItems.append(PKPaymentSummaryItem(label: label, amount: amount, type: type))
        }

        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = merchantIdentifier
        paymentRequest.countryCode = countryCode
        paymentRequest.currencyCode = currencyCode
        paymentRequest.paymentSummaryItems = summaryItems

        let supportedNetworksRaw = (options["supportedNetworks"] as? [String]) ?? []
        let supportedNetworks = supportedNetworksRaw.compactMap { Self.paymentNetwork(from: $0) }
        paymentRequest.supportedNetworks = supportedNetworks.isEmpty
            ? [.visa, .masterCard, .amex]
            : supportedNetworks

        let merchantCapabilitiesRaw = (options["merchantCapabilities"] as? [String]) ?? []
        let merchantCapabilities = merchantCapabilitiesRaw.compactMap { Self.merchantCapability(from: $0) }
        paymentRequest.merchantCapabilities = merchantCapabilities.isEmpty
            ? [.capability3DS]
            : PKMerchantCapability(rawValue: merchantCapabilities.reduce(0) { $0 | $1.rawValue })

        let billingFieldsRaw = (options["requiredBillingContactFields"] as? [String]) ?? []
        let billingFields = Set(billingFieldsRaw.compactMap { Self.contactField(from: $0) })
        paymentRequest.requiredBillingContactFields = billingFields

        let shippingFieldsRaw = (options["requiredShippingContactFields"] as? [String]) ?? []
        let shippingFields = Set(shippingFieldsRaw.compactMap { Self.contactField(from: $0) })
        paymentRequest.requiredShippingContactFields = shippingFields

        if let shippingTypeRaw = call.getString("shippingType"),
           let shippingType = Self.shippingType(from: shippingTypeRaw) {
            paymentRequest.shippingType = shippingType
        }

        return paymentRequest
    }

    private func paymentPasses() -> [PKPaymentPass] {
        passLibrary.passes(of: .payment).compactMap { $0 as? PKPaymentPass }
    }

    private func snapshot(for pass: PKPaymentPass) -> PaymentPassSnapshot {
        PaymentPassSnapshot(
            serialNumber: pass.serialNumber,
            primaryAccountIdentifier: pass.primaryAccountIdentifier,
            primaryAccountNumberSuffix: pass.primaryAccountNumberSuffix,
            deviceAccountIdentifier: pass.deviceAccountIdentifier,
            activationState: Self.activationStateString(from: pass.activationState),
            isRemote: pass.isRemotePass,
            deviceName: pass.deviceName
        )
    }

    private func snapshotBySerialNumber() -> [String: PaymentPassSnapshot] {
        var bySerialNumber: [String: PaymentPassSnapshot] = [:]
        for pass in paymentPasses() {
            bySerialNumber[pass.serialNumber] = snapshot(for: pass)
        }
        return bySerialNumber
    }

    private func paymentPassDictionary(from pass: PaymentPassSnapshot) -> JSObject {
        var data: JSObject = [
            "serialNumber": pass.serialNumber,
            "isRemote": pass.isRemote,
            "activationState": pass.activationState
        ]

        if let primaryAccountIdentifier = pass.primaryAccountIdentifier {
            data["primaryAccountIdentifier"] = primaryAccountIdentifier
        }
        if let primaryAccountNumberSuffix = pass.primaryAccountNumberSuffix {
            data["primaryAccountNumberSuffix"] = primaryAccountNumberSuffix
        }
        if let deviceAccountIdentifier = pass.deviceAccountIdentifier {
            data["deviceAccountIdentifier"] = deviceAccountIdentifier
        }
        if let deviceName = pass.deviceName {
            data["deviceName"] = deviceName
        }

        return data
    }

    private func entitlementChecks() -> (inAppPayments: Bool, paymentPassProvisioning: Bool) {
        let inAppPayments = hasEntitlement("com.apple.developer.in-app-payments")
        let paymentPassProvisioning = hasEntitlement("com.apple.developer.payment-pass-provisioning")
        return (inAppPayments, paymentPassProvisioning)
    }

    private func hasEntitlement(_ key: String) -> Bool {
        if let explicitEntitlement = Bundle.main.object(forInfoDictionaryKey: key) {
            if let boolValue = explicitEntitlement as? Bool {
                return boolValue
            }
            if let numberValue = explicitEntitlement as? NSNumber {
                return numberValue.boolValue
            }
            if let stringValue = explicitEntitlement as? String {
                return !stringValue.isEmpty
            }
            if let arrayValue = explicitEntitlement as? [Any] {
                return !arrayValue.isEmpty
            }
        }

        switch key {
        case "com.apple.developer.in-app-payments":
            return PKPaymentAuthorizationController.canMakePayments()
        case "com.apple.developer.payment-pass-provisioning":
            return PKAddPaymentPassViewController.canAddPaymentPass()
        default:
            return false
        }
    }

    private func resetAddCardState() {
        pendingAddCardCall = nil
        pendingAddCardCompletion = nil
        pendingAddCardCardId = nil
    }

    private func resetPaymentState() {
        pendingPaymentCall = nil
        pendingPaymentCompletion = nil
        paymentController = nil
    }

    private static func paymentNetwork(from rawValue: String) -> PKPaymentNetwork? {
        switch rawValue.lowercased() {
        case "amex": return .amex
        case "cartebancaires": return .cartesBancaires
        case "chinaunionpay": return .chinaUnionPay
        case "discover": return .discover
        case "eftpos": return .eftpos
        case "electron": return .electron
        case "idcredit": return .idCredit
        case "interac": return .interac
        case "jcb": return .JCB
        case "mada": return .mada
        case "maestro": return .maestro
        case "mastercard": return .masterCard
        case "privatelabel": return .privateLabel
        case "quicpay": return .quicPay
        case "suica": return .suica
        case "visa": return .visa
        case "vpay": return .vPay
        default: return nil
        }
    }

    private static func merchantCapability(from rawValue: String) -> PKMerchantCapability? {
        switch rawValue.lowercased() {
        case "threeds": return .capability3DS
        case "credit": return .capabilityCredit
        case "debit": return .capabilityDebit
        case "emv": return .capabilityEMV
        default: return nil
        }
    }

    private static func contactField(from rawValue: String) -> PKContactField? {
        switch rawValue.lowercased() {
        case "name": return .name
        case "emailaddress": return .emailAddress
        case "phonenumber": return .phoneNumber
        case "postaladdress": return .postalAddress
        case "phoneticname": return .phoneticName
        default: return nil
        }
    }

    private static func shippingType(from rawValue: String) -> PKShippingType? {
        switch rawValue.lowercased() {
        case "shipping": return .shipping
        case "delivery": return .delivery
        case "storepickup": return .storePickup
        case "servicepickup": return .servicePickup
        default: return nil
        }
    }

    private static func paymentAuthorizationStatus(from rawValue: String) -> PKPaymentAuthorizationStatus {
        switch rawValue.lowercased() {
        case "success":
            return .success
        case "canceled":
            return .failure
        case "invalidbillingpostaladdress":
            return .invalidBillingPostalAddress
        case "invalidshippingpostaladdress":
            return .invalidShippingPostalAddress
        case "invalidshippingcontact":
            return .invalidShippingContact
        case "pinrequired":
            return .pinRequired
        case "pinincorrect":
            return .pinIncorrect
        case "pinlockout":
            return .pinLockout
        default:
            return .failure
        }
    }

    private static func activationStateString(from activationState: PKPaymentPassActivationState) -> String {
        switch activationState {
        case .activated:
            return "activated"
        case .requiresActivation:
            return "requiresActivation"
        case .activating:
            return "activating"
        case .suspended:
            return "suspended"
        case .deactivated:
            return "deactivated"
        @unknown default:
            return "unknown"
        }
    }
}

private struct PaymentPassSnapshot {
    let serialNumber: String
    let primaryAccountIdentifier: String?
    let primaryAccountNumberSuffix: String?
    let deviceAccountIdentifier: String?
    let activationState: String
    let isRemote: Bool
    let deviceName: String?
}

extension CapacitorApplePayPlugin: PKAddPaymentPassViewControllerDelegate {
    public func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        generateRequestWithCertificateChain certificates: [Data],
        nonce: Data,
        nonceSignature: Data,
        completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
    ) {
        pendingAddCardCompletion = handler

        let cardId = pendingAddCardCardId ?? ""
        let payload: JSObject = [
            "cardId": cardId,
            "certificates": certificates.map { $0.base64EncodedString() },
            "nonce": nonce.base64EncodedString(),
            "nonceSignature": nonceSignature.base64EncodedString()
        ]

        pendingAddCardCall?.resolve(payload)
        pendingAddCardCall = nil
    }

    public func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        didFinishAdding pass: PKPaymentPass?,
        error: Error?
    ) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true)
        }

        defer {
            resetAddCardState()
            passSnapshot = snapshotBySerialNumber()
        }

        if let error {
            pendingAddCardCall?.reject(error.localizedDescription, nil, error)
            notifyListeners("tokenStatusChanged", data: [
                "status": "addCardFailed",
                "message": error.localizedDescription
            ])
            return
        }

        if let pass {
            var payload = paymentPassDictionary(from: snapshot(for: pass))
            payload["status"] = "added"
            notifyListeners("tokenStatusChanged", data: payload)
            return
        }

        pendingAddCardCall?.reject("Card provisioning was cancelled.")
        notifyListeners("tokenStatusChanged", data: ["status": "cancelled"])
    }
}

extension CapacitorApplePayPlugin: PKPaymentAuthorizationControllerDelegate {
    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        pendingPaymentCompletion = completion

        let tokenData = payment.token.paymentData.base64EncodedString()
        let paymentMethod = payment.token.paymentMethod

        var paymentMethodInfo: JSObject = [:]
        if let displayName = paymentMethod.displayName {
            paymentMethodInfo["displayName"] = displayName
        }
        if let network = paymentMethod.network?.rawValue {
            paymentMethodInfo["network"] = network
        }
        paymentMethodInfo["type"] = Self.paymentMethodTypeString(from: paymentMethod.type)

        pendingPaymentCall?.resolve([
            "tokenData": tokenData,
            "transactionIdentifier": payment.token.transactionIdentifier,
            "paymentMethod": paymentMethodInfo
        ])
        pendingPaymentCall = nil

        notifyListeners("tokenStatusChanged", data: ["status": "paymentAuthorized"])
    }

    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss(completion: nil)

        if let pendingCall = pendingPaymentCall {
            pendingCall.reject("Payment sheet was closed before authorization.")
            pendingPaymentCall = nil
        }

        if let completion = pendingPaymentCompletion {
            completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
            pendingPaymentCompletion = nil
        }

        paymentController = nil
    }

    private static func paymentMethodTypeString(from type: PKPaymentMethodType) -> String {
        switch type {
        case .debit:
            return "debit"
        case .credit:
            return "credit"
        case .prepaid:
            return "prepaid"
        case .store:
            return "store"
        case .eMoney:
            return "eMoney"
        default:
            return "unknown"
        }
    }
}
// swiftlint:enable type_body_length
