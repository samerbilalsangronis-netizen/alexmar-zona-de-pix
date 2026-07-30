import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { Screen } from '../components/Screen';
import { supabase } from '../lib/supabaseClient';
import { fecha } from '../lib/format';
import type { EstadoGarantia, Garantia, Proveedor } from '../types';

const ESTILOS_ESTADO: Record<EstadoGarantia, string> = {
  ENVIADA: 'border-[var(--warn)] text-[var(--warn)]',
  DEVUELTA: 'border-[var(--good)] text-[var(--good)]',
  RECHAZADA: 'border-[var(--bad)] text-[var(--bad)]',
};

export function Garantias() {
  const [garantias, setGarantias] = useState<Garantia[]>([]);
  const [proveedores, setProveedores] = useState<Proveedor[]>([]);
  const [cargando, setCargando] = useState(true);
  const [soloPendientes, setSoloPendientes] = useState(true);
  const [mostrarForm, setMostrarForm] = useState(false);

  async function cargar() {
    setCargando(true);
    const [{ data: g }, { data: p }] = await Promise.all([
      supabase.from('garantias').select('*').order('fecha_envio', { ascending: false }),
      supabase.from('proveedores').select('*').eq('eliminado', false).order('nombre_proveedor'),
    ]);
    setGarantias((g as Garantia[]) ?? []);
    setProveedores((p as Proveedor[]) ?? []);
    setCargando(false);
  }

  useEffect(() => {
    cargar();
    const canal = supabase
      .channel('garantias-realtime')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'garantias' }, cargar)
      .subscribe();
    return () => {
      supabase.removeChannel(canal);
    };
  }, []);

  const visibles = useMemo(
    () => (soloPendientes ? garantias.filter((g) => g.estado === 'ENVIADA') : garantias),
    [garantias, soloPendientes],
  );

  const nombreProveedor = (id: string | null) => proveedores.find((p) => p.id === id)?.nombre_proveedor ?? '—';

  async function actualizarEstado(g: Garantia, estado: EstadoGarantia) {
    await supabase
      .from('garantias')
      .update({ estado, fecha_retorno: estado === 'ENVIADA' ? null : new Date().toISOString() })
      .eq('id', g.id);
    cargar();
  }

  return (
    <Screen
      title="Garantías"
      backTo="/proveedores"
      actions={
        <button onClick={() => setMostrarForm((v) => !v)} className="rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black">
          + Garantía
        </button>
      }
    >
      {mostrarForm && (
        <NuevaGarantiaForm
          proveedores={proveedores}
          onCreado={() => {
            setMostrarForm(false);
            cargar();
          }}
        />
      )}

      <div className="mt-4 flex items-center gap-2">
        <button
          onClick={() => setSoloPendientes(true)}
          className={`rounded px-3 py-1.5 text-xs font-bold ${soloPendientes ? 'bg-[var(--accent)] text-black' : 'border border-[var(--border)] text-[var(--text-secondary)]'}`}
        >
          Pendientes
        </button>
        <button
          onClick={() => setSoloPendientes(false)}
          className={`rounded px-3 py-1.5 text-xs font-bold ${!soloPendientes ? 'bg-[var(--accent)] text-black' : 'border border-[var(--border)] text-[var(--text-secondary)]'}`}
        >
          Todas
        </button>
      </div>

      <div className="mt-4 divide-y divide-[var(--border)] rounded-lg border border-[var(--border)]">
        {cargando && <p className="p-4 text-sm text-[var(--text-muted)]">Cargando…</p>}
        {!cargando && visibles.length === 0 && <p className="p-4 text-sm text-[var(--text-muted)]">No hay garantías acá.</p>}
        {visibles.map((g) => (
          <div key={g.id} className="flex items-center justify-between gap-3 px-4 py-3">
            <div className="min-w-0">
              <p className="font-bold text-[var(--text-primary)]">{g.producto}</p>
              <p className="text-xs text-[var(--text-muted)]">
                {nombreProveedor(g.id_proveedor)} · enviada {fecha(g.fecha_envio)}
                {g.fecha_retorno ? ` · vuelta ${fecha(g.fecha_retorno)}` : ''}
              </p>
              {g.notas && <p className="mt-0.5 text-xs text-[var(--text-secondary)]">{g.notas}</p>}
            </div>
            <div className="flex shrink-0 items-center gap-2">
              <span className={`rounded border px-2 py-0.5 text-[10px] font-bold ${ESTILOS_ESTADO[g.estado]}`}>{g.estado}</span>
              {g.estado === 'ENVIADA' && (
                <div className="flex gap-1">
                  <button
                    onClick={() => actualizarEstado(g, 'DEVUELTA')}
                    className="rounded border border-[var(--good)] px-2 py-1 text-[10px] font-bold text-[var(--good)] hover:bg-[var(--good)]/10"
                  >
                    Devuelta
                  </button>
                  <button
                    onClick={() => actualizarEstado(g, 'RECHAZADA')}
                    className="rounded border border-[var(--bad)] px-2 py-1 text-[10px] font-bold text-[var(--bad)] hover:bg-[var(--bad)]/10"
                  >
                    Rechazada
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </Screen>
  );
}

function NuevaGarantiaForm({ proveedores, onCreado }: { proveedores: Proveedor[]; onCreado: () => void }) {
  const [producto, setProducto] = useState('');
  const [idProveedor, setIdProveedor] = useState('');
  const [notas, setNotas] = useState('');
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar(e: FormEvent) {
    e.preventDefault();
    if (!producto.trim()) return;
    setGuardando(true);
    setError(null);
    const { error } = await supabase.from('garantias').insert({
      producto: producto.trim(),
      id_proveedor: idProveedor || null,
      notas: notas.trim() || null,
    });
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    setProducto('');
    setIdProveedor('');
    setNotas('');
    onCreado();
  }

  return (
    <form onSubmit={guardar} className="mt-4 rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
      <p className="font-display text-sm text-[var(--text-primary)]">Enviar a garantía</p>
      <div className="mt-3 grid gap-3 sm:grid-cols-2">
        <input placeholder="Producto *" required value={producto} onChange={(e) => setProducto(e.target.value)} className="sm:col-span-2" />
        <select value={idProveedor} onChange={(e) => setIdProveedor(e.target.value)}>
          <option value="">Proveedor (opcional)</option>
          {proveedores.map((p) => (
            <option key={p.id} value={p.id}>
              {p.nombre_proveedor}
            </option>
          ))}
        </select>
        <input placeholder="Notas (opcional)" value={notas} onChange={(e) => setNotas(e.target.value)} />
      </div>
      {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}
      <button disabled={guardando} className="mt-3 rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black disabled:opacity-50">
        {guardando ? 'Guardando…' : 'Enviar a garantía'}
      </button>
    </form>
  );
}
