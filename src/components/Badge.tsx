import type { EstatusCartera } from '../types';

const ESTILOS: Record<EstatusCartera, { label: string; className: string }> = {
  AL_DIA: { label: 'AL DÍA', className: 'text-[var(--good)] border-[var(--good)]' },
  REVISAR: { label: 'REVISAR', className: 'text-[var(--warn)] border-[var(--warn)]' },
  MORA: { label: 'MORA', className: 'text-[var(--bad)] border-[var(--bad)]' },
};

export function EstatusBadge({ estatus }: { estatus: EstatusCartera }) {
  const s = ESTILOS[estatus];
  return (
    <span className={`rounded border px-2 py-0.5 text-xs font-bold tracking-wide ${s.className}`}>{s.label}</span>
  );
}
