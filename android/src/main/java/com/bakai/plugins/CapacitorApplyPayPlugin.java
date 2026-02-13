package com.bakai.plugins;

import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "CapacitorApplyPay")
public class CapacitorApplyPayPlugin extends Plugin {

    @PluginMethod
    public void canAddCard(PluginCall call) {
        call.unimplemented("Apple Pay card provisioning is available only on iOS.");
    }

    @PluginMethod
    public void canMakePayments(PluginCall call) {
        call.unimplemented("Apple Pay payments are available only on iOS.");
    }

    @PluginMethod
    public void isCardInWallet(PluginCall call) {
        call.unimplemented("Wallet card checks are available only on iOS.");
    }

    @PluginMethod
    public void startAddCard(PluginCall call) {
        call.unimplemented("Apple Pay card provisioning is available only on iOS.");
    }

    @PluginMethod
    public void completeAddCard(PluginCall call) {
        call.unimplemented("Apple Pay card provisioning is available only on iOS.");
    }

    @PluginMethod
    public void presentPaymentSheet(PluginCall call) {
        call.unimplemented("Apple Pay payment sheet is available only on iOS.");
    }

    @PluginMethod
    public void completePayment(PluginCall call) {
        call.unimplemented("Apple Pay payment completion is available only on iOS.");
    }

    @PluginMethod
    public void onTokenStatusChanged(PluginCall call) {
        call.unimplemented("Apple Pay token status observers are available only on iOS.");
    }

    @PluginMethod
    public void onCardRemoved(PluginCall call) {
        call.unimplemented("Wallet card observers are available only on iOS.");
    }

    @PluginMethod
    public void onDeviceChanged(PluginCall call) {
        call.unimplemented("Wallet device observers are available only on iOS.");
    }
}
