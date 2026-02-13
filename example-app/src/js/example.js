import { CapacitorApplyPay } from 'capacitor-apply-pay';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    CapacitorApplyPay.echo({ value: inputValue })
}
