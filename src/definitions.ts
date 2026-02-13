export interface CapacitorApplyPayPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
