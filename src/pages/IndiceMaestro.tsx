import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { Link } from 'react-router-dom';
import { Screen } from '../components/Screen';
import { EstatusBadge } from '../components/Badge';
import { supabase } from '../lib/supabaseClient';
import { money } from '../lib/format';
import { calcularEstatus, type Cliente } from '../types';

export function IndiceMaestro() {
  const [clientes, setClientes] = useState<Cliente[]>([]);
  const [cargando, setCargando] = useState(true);
  const [busqueda, setBusqueda] = useState('');
  const [mostrarForm, setMostrarForm] = useState(false);

  async function cargar() {
    setCargando(true);
    const { data } = await supabase
      .from('vista_saldos_clientes')
      .select('*')
      .eq('eliminado', false)
      .order('nombre_cliente');
    setClientes((data as Cliente[]) ?? []);
    setCargando(false);
  }

  useEffect(() => {
    cargar();
    const canal = supabase
      .channel('clientes-realtime')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'clientes' }, cargar)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'detalle_cuentas' }, cargar)
      .subscribe();
    return () => {
      supabase.removeChannel(canal);
    };
  }, []);

  const filtrados = useMemo(() => {
    const q = busqueda.trim().toLowerCase();
    if (!q) return clientes;
    return clientes.filter(
      (c) =>
        c.nombre_cliente.toLowerCase().includes(q) ||
        (c.cedula ?? '').toLowerCase().includes(q) ||
        (c.telefono ?? '').toLowerCase().includes(q),
    );
  }, [clientes, busqueda]);

  const totalEnLaCalle = clientes.reduce((acc, c) => acc + c.saldo_pendiente, 0);

  return (
    <Screen
      title="Índice Maestro"
      backTo="/"
      actions={
        <button onClick={() => setMostrarForm((v) => !v)} className="rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black">
          + Cliente
        </button>
      }
    >
      <div className="rounded-lg border border-[var(--accent)] bg-[var(--surface-1)] p-4">
        <p className="font-display text-xs text-[var(--accent)]">🔥 TOTAL GENERAL EN LA CALLE</p>
        <p className="mt-1 font-display text-3xl text-white">{money(totalEnLaCalle)}</p>
      </div>

      {mostrarForm && <NuevoClienteForm onCreado={() => { setMostrarForm(false); cargar(); }} />}

      <input
        className="mt-4 w-full"
        placeholder="Buscar por nombre, cédula o teléfono…"
        value={busqueda}
        onChange={(e) => setBusqueda(e.target.value)}
      />

      <div className="mt-4 divide-y divide-[var(--border)] rounded-lg border border-[var(--border)]">
        {cargando && <p className="p-4 text-sm text-[var(--text-muted)]">Cargando…</p>}
        {!cargando && filtrados.length === 0 && (
          <p className="p-4 text-sm text-[var(--text-muted)]">No hay clientes que coincidan.</p>
        )}
        {filtrados.map((c) => {
          const estatus = calcularEstatus(c.fecha_ultimo_abono, c.saldo_pendiente);
          const dias = c.fecha_ultimo_abono
            ? Math.floor((Date.now() - new Date(c.fecha_ultimo_abono).getTime()) / 86_400_000)
            : null;
          return (
            <div
              key={c.id}
              className={`flex items-center justify-between gap-3 border-l-4 px-4 py-3 hover:bg-[var(--surface-1)] ${
                estatus === 'MORA' ? 'border-l-[var(--bad)]' : estatus === 'REVISAR' ? 'border-l-[var(--warn)]' : 'border-l-[var(--good)]'
              }`}
            >
              <Link to={`/clientes/${c.id}`} className="min-w-0 flex-1">
                <p className="font-bold text-white">{c.nombre_cliente}</p>
                {c.telefono && <p className="text-xs text-[var(--text-muted)]">{c.telefono}</p>}
                <div className="mt-1 flex items-center gap-2">
                  <EstatusBadge estatus={estatus} />
                  {dias !== null && <span className="text-xs text-[var(--text-muted)]">{dias} días</span>}
                </div>
              </Link>
              <Link to={`/clientes/${c.id}`} className={`font-display text-lg ${c.saldo_pendiente > 0 ? 'text-[var(--bad)]' : 'text-[var(--good)]'}`}>
                {money(c.saldo_pendiente)}
              </Link>
              <button
                onClick={async () => {
                  if (!confirm(`¿Quitar a "${c.nombre_cliente}" del Índice Maestro?\n\nSus datos no se destruyen, solo deja de aparecer en la lista.`)) return;
                  await supabase.from('clientes').update({ eliminado: true }).eq('id', c.id);
                  cargar();
                }}
                title="Quitar cliente"
                className="shrink-0 rounded p-1.5 text-[var(--text-muted)] hover:bg-[var(--bad)]/20 hover:text-[var(--bad)]"
              >
                🗑
              </button>
            </div>
          );
        })}
      </div>
    </Screen>
  );
}

function NuevoClienteForm({ onCreado }: { onCreado: () => void }) {
  const [nombre, setNombre] = useState('');
  const [cedula, setCedula] = useState('');
  const [telefono, setTelefono] = useState('');
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar(e: FormEvent) {
    e.preventDefault();
    if (!nombre.trim()) return;
    setGuardando(true);
    setError(null);
    const { error } = await supabase.from('clientes').insert({
      nombre_cliente: nombre.trim(),
      cedula: cedula.trim() || null,
      telefono: telefono.trim() || null,
    });
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    setNombre('');
    setCedula('');
    setTelefono('');
    onCreado();
  }

  return (
    <form onSubmit={guardar} className="mt-4 rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
      <p className="font-display text-sm text-white">Nuevo cliente</p>
      <div className="mt-3 grid gap-3 sm:grid-cols-3">
        <input placeholder="Nombre *" required value={nombre} onChange={(e) => setNombre(e.target.value)} />
        <input placeholder="Cédula" value={cedula} onChange={(e) => setCedula(e.target.value)} />
        <input placeholder="Teléfono" value={telefono} onChange={(e) => setTelefono(e.target.value)} />
      </div>
      {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}
      <button disabled={guardando} className="mt-3 rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black disabled:opacity-50">
        {guardando ? 'Guardando…' : 'Guardar cliente'}
      </button>
    </form>
  );
}
