import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { Screen } from '../components/Screen';
import { supabase } from '../lib/supabaseClient';
import type { Fusiblera } from '../types';

function rangoAnios(f: Fusiblera): string {
  if (!f.anio_desde) return '';
  if (!f.anio_hasta || f.anio_hasta === f.anio_desde) return `${f.anio_desde}`;
  return `${f.anio_desde}-${f.anio_hasta}`;
}

export function Fusibleras() {
  const [fusibleras, setFusibleras] = useState<Fusiblera[]>([]);
  const [cargando, setCargando] = useState(true);
  const [busqueda, setBusqueda] = useState('');

  async function cargar() {
    setCargando(true);
    const { data } = await supabase
      .from('fusibleras')
      .select('*')
      .eq('eliminado', false)
      .order('marca')
      .order('modelo');
    setFusibleras((data as Fusiblera[]) ?? []);
    setCargando(false);
  }

  useEffect(() => {
    cargar();
    const canal = supabase
      .channel('fusibleras-realtime')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'fusibleras' }, cargar)
      .subscribe();
    return () => {
      supabase.removeChannel(canal);
    };
  }, []);

  const filtradas = useMemo(() => {
    const q = busqueda.trim().toLowerCase();
    if (!q) return fusibleras;
    return fusibleras.filter(
      (f) =>
        f.marca.toLowerCase().includes(q) ||
        f.modelo.toLowerCase().includes(q) ||
        rangoAnios(f).includes(q) ||
        (f.ubicacion ?? '').toLowerCase().includes(q),
    );
  }, [fusibleras, busqueda]);

  return (
    <Screen title="Fusibleras" backTo="/">
      <p className="text-sm text-[var(--text-muted)]">
        Buscá el vehículo para ver el diagrama de la caja de fusibles y qué hace cada uno.
      </p>

      <input
        className="mt-4 w-full"
        placeholder="Buscar por marca, modelo o año…"
        value={busqueda}
        onChange={(e) => setBusqueda(e.target.value)}
      />

      <div className="mt-4 divide-y divide-[var(--border)] rounded-lg border border-[var(--border)]">
        {cargando && <p className="p-4 text-sm text-[var(--text-muted)]">Cargando…</p>}
        {!cargando && filtradas.length === 0 && (
          <p className="p-4 text-sm text-[var(--text-muted)]">
            {busqueda ? 'No hay vehículos que coincidan.' : 'Todavía no hay fusibleras cargadas.'}
          </p>
        )}
        {filtradas.map((f) => (
          <Link
            key={f.id}
            to={`/fusibleras/${f.id}`}
            className="flex items-center justify-between gap-3 px-4 py-3 hover:bg-[var(--surface-1)]"
          >
            <div className="min-w-0 flex-1">
              <p className="font-bold text-[var(--text-primary)]">
                {f.marca} {f.modelo} {rangoAnios(f) && <span className="text-[var(--text-muted)]">({rangoAnios(f)})</span>}
              </p>
              {f.ubicacion && <p className="text-xs text-[var(--text-muted)]">{f.ubicacion}</p>}
            </div>
            <span className="text-[var(--text-muted)]">›</span>
          </Link>
        ))}
      </div>
    </Screen>
  );
}
