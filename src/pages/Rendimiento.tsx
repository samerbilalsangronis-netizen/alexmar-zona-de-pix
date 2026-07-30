import { useEffect, useState } from 'react';
import { Screen } from '../components/Screen';
import { supabase } from '../lib/supabaseClient';
import { money } from '../lib/format';
import type { LineaCuenta } from '../types';

export function Rendimiento() {
  const [lineas, setLineas] = useState<LineaCuenta[]>([]);
  const [cargando, setCargando] = useState(true);

  useEffect(() => {
    supabase
      .from('detalle_cuentas')
      .select('*')
      .eq('eliminado', false)
      .then(({ data }) => {
        setLineas((data as LineaCuenta[]) ?? []);
        setCargando(false);
      });
  }, []);

  const facturado = lineas.filter((l) => l.tipo_linea === 'CARGO').reduce((a, l) => a + l.total_linea, 0);
  const cobrado = lineas.filter((l) => l.tipo_linea === 'ABONO').reduce((a, l) => a + l.total_linea, 0);
  const gananciaNeta = lineas
    .filter((l) => l.tipo_linea === 'CARGO')
    .reduce((a, l) => a + (l.total_linea - (l.costo_unitario ?? 0) * l.cantidad), 0);

  return (
    <Screen title="Rendimiento (BI)" backTo="/">
      {cargando ? (
        <p className="text-sm text-[var(--text-muted)]">Cargando…</p>
      ) : (
        <div className="grid gap-3 sm:grid-cols-3">
          <Stat label="Total facturado" value={money(facturado)} />
          <Stat label="Total cobrado" value={money(cobrado)} color="text-[var(--good)]" />
          <Stat label="Ganancia neta" value={money(gananciaNeta)} color="text-[var(--accent)]" />
        </div>
      )}
      <p className="mt-6 text-sm text-[var(--text-muted)]">
        Próximamente: gráficos por mes y cierre mensual automático (tabla <code>cierres_mensuales</code> ya
        está creada en Supabase, lista para usarse).
      </p>
    </Screen>
  );
}

function Stat({ label, value, color = 'text-[var(--text-primary)]' }: { label: string; value: string; color?: string }) {
  return (
    <div className="rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
      <p className="text-xs text-[var(--text-muted)]">{label.toUpperCase()}</p>
      <p className={`mt-1 font-display text-2xl ${color}`}>{value}</p>
    </div>
  );
}
