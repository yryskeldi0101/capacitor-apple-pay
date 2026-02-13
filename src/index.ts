import { registerPlugin } from '@capacitor/core';

import type { CapacitorApplePayPlugin } from './definitions';

const CapacitorApplePay = registerPlugin<CapacitorApplePayPlugin>('CapacitorApplePay', {
  web: () => import('./web').then((m) => new m.CapacitorApplePayWeb()),
});

export * from './definitions';
export { CapacitorApplePay };
