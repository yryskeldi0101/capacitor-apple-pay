import { CapacitorApplePay } from 'capacitor-apple-pay';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    CapacitorApplePay.echo({ value: inputValue })
}
