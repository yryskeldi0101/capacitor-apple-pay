import { WebPlugin } from '@capacitor/core';

import type { CapacitorApplyPayPlugin } from './definitions';

export class CapacitorApplyPayWeb extends WebPlugin implements CapacitorApplyPayPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
