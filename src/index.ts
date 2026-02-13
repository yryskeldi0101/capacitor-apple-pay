import { registerPlugin } from '@capacitor/core';

import type { CapacitorApplyPayPlugin } from './definitions';

const CapacitorApplyPay = registerPlugin<CapacitorApplyPayPlugin>('CapacitorApplyPay', {
  web: () => import('./web').then((m) => new m.CapacitorApplyPayWeb()),
});

export * from './definitions';
export { CapacitorApplyPay };
