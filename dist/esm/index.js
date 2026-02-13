import { registerPlugin } from '@capacitor/core';
const CapacitorApplePay = registerPlugin('CapacitorApplePay', {
    web: () => import('./web').then((m) => new m.CapacitorApplePayWeb()),
});
export * from './definitions';
export { CapacitorApplePay };
//# sourceMappingURL=index.js.map