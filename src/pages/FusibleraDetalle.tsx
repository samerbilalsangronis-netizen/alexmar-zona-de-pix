import { useEffect, useMemo, useState } from 'react';
import { useParams } from 'react-router-dom';
import { Screen } from '../components/Screen';
import { supabase } from '../lib/supabaseClient';
import type { Fusible, Fusiblera } from '../types';

export function FusibleraDetalle() {
  const { id } = useParams<{ id: string }>();
  const [fusiblera, setFusiblera] = useState<Fusiblera | null>(null);
  const [fusibles, setFusibles] = useState<Fusible[]>([]);
  const [cargando, setCargando] = useState(true);
  const [seleccionado, setSeleccionado] = useState<string | null>(null);

  useEffect(() => {
    if (!id) return;
    async function cargar() {
      setCargando(true);
      const [{ data: f }, { data: fs }] = await Promise.all([
        supabase.from('fusibleras').select('*').eq('id', id).single(),
        supabase.from('fusibles').select('*').eq('id_fusiblera', id).eq('eliminado', false),
      ]);
      setFusiblera(f as Fusiblera);
      setFusibles((fs as Fusible[]) ?? []);
      setCargando(false);
    }
    cargar();
    const canal = supabase
      .channel(`fusiblera-${id}-realtime`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'fusibles', filter: `id_fusiblera=eq.${id}` }, cargar)
      .subscribe();
    return () => {
      supabase.removeChannel(canal);
    };
  }, [id]);

  const ordenados = useMemo(
    () => [...fusibles].sort((a, b) => a.numero.localeCompare(b.numero, undefined, { numeric: true })),
    [fusibles],
  );

  const activo = ordenados.find((f) => f.id === seleccionado) ?? null;
  const rango =
    fusiblera?.anio_desde && (!fusiblera.anio_hasta || fusiblera.anio_hasta === fusiblera.anio_desde)
      ? `${fusiblera.anio_desde}`
      : fusiblera?.anio_desde
        ? `${fusiblera.anio_desde}-${fusiblera.anio_hasta}`
        : '';

  if (cargando) {
    return (
      <Screen title="Fusiblera" backTo="/fusibleras">
        <p className="text-sm text-[var(--text-muted)]">Cargando…</p>
      </Screen>
    );
  }

  if (!fusiblera) {
    return (
      <Screen title="Fusiblera" backTo="/fusibleras">
        <p className="text-sm text-[var(--text-muted)]">No se encontró este vehículo.</p>
      </Screen>
    );
  }

  return (
    <Screen title={`${fusiblera.marca} ${fusiblera.modelo}`} backTo="/fusibleras">
      <p className="text-sm text-[var(--text-muted)]">
        {rango && `${rango} · `}
        {fusiblera.ubicacion || 'Toca un fusible en el diagrama para ver su función.'}
      </p>

      <div className="mt-4 relative inline-block w-full overflow-hidden rounded-lg border border-[var(--border)] bg-white">
        <img src={fusiblera.imagen_url} alt={`Diagrama de fusibles ${fusiblera.marca} ${fusiblera.modelo}`} className="block h-auto w-full" />
        {ordenados.map((f) => {
          const esActivo = f.id === seleccionado;
          return (
            <button
              key={f.id}
              onClick={() => setSeleccionado(f.id === seleccionado ? null : f.id)}
              title={f.funcion}
              style={{ left: `${f.pos_x}%`, top: `${f.pos_y}%` }}
              className={`absolute flex h-7 w-7 -translate-x-1/2 -translate-y-1/2 items-center justify-center rounded-full border-2 text-xs font-bold shadow ${
                esActivo
                  ? 'z-10 scale-125 border-[var(--bad)] bg-[var(--bad)] text-white'
                  : 'border-[var(--accent)] bg-[var(--accent)]/90 text-black'
              }`}
            >
              {f.numero}
            </button>
          );
        })}
      </div>

      {activo && (
        <div className="mt-4 rounded-lg border border-[var(--bad)] bg-[var(--surface-1)] p-4">
          <p className="font-display text-xs text-[var(--bad)]">FUSIBLE #{activo.numero}</p>
          <p className="mt-1 text-lg font-bold text-[var(--text-primary)]">{activo.funcion}</p>
          {activo.amperaje && <p className="text-sm text-[var(--text-muted)]">{activo.amperaje}</p>}
        </div>
      )}

      <div className="mt-4 divide-y divide-[var(--border)] rounded-lg border border-[var(--border)]">
        {ordenados.length === 0 && (
          <p className="p-4 text-sm text-[var(--text-muted)]">Este vehículo todavía no tiene fusibles cargados.</p>
        )}
        {ordenados.map((f) => (
          <button
            key={f.id}
            onClick={() => setSeleccionado(f.id === seleccionado ? null : f.id)}
            className={`flex w-full items-center gap-3 px-4 py-2.5 text-left hover:bg-[var(--surface-1)] ${
              f.id === seleccionado ? 'bg-[var(--surface-1)]' : ''
            }`}
          >
            <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-[var(--accent)] text-xs font-bold text-black">
              {f.numero}
            </span>
            <span className="min-w-0 flex-1 text-sm text-[var(--text-primary)]">{f.funcion}</span>
            {f.amperaje && <span className="shrink-0 text-xs text-[var(--text-muted)]">{f.amperaje}</span>}
          </button>
        ))}
      </div>
    </Screen>
  );
}
