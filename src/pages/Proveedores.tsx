import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { Link } from 'react-router-dom';
import { Screen } from '../components/Screen';
import { supabase } from '../lib/supabaseClient';
import { money } from '../lib/format';
import type { Proveedor } from '../types';

export function Proveedores() {
  const [proveedores, setProveedores] = useState<Proveedor[]>([]);
  const [cargando, setCargando] = useState(true);
  const [busqueda, setBusqueda] = useState('');
  const [mostrarForm, setMostrarForm] = useState(false);

  async function cargar() {
    setCargando(true);
    const { data } = await supabase
      .from('vista_saldos_proveedores')
      .select('*')
      .eq('eliminado', false)
      .order('nombre_proveedor');
    setProveedores((data as Proveedor[]) ?? []);
    setCargando(false);
  }

  useEffect(() => {
    cargar();
    const canal = supabase
      .channel('proveedores-realtime')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'proveedores' }, cargar)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'movimientos_proveedor' }, cargar)
      .subscribe();
    return () => {
      supabase.removeChannel(canal);
    };
  }, []);

  const filtrados = useMemo(() => {
    const q = busqueda.trim().toLowerCase();
    if (!q) return proveedores;
    return proveedores.filter(
      (p) =>
        p.nombre_proveedor.toLowerCase().includes(q) ||
        (p.nombre_distribuidor ?? '').toLowerCase().includes(q) ||
        (p.telefono ?? '').toLowerCase().includes(q),
    );
  }, [proveedores, busqueda]);

  const totalAdeudado = proveedores.reduce((acc, p) => acc + p.saldo_pendiente, 0);

  return (
    <Screen
      title="Proveedores"
      backTo="/"
      actions={
        <div className="flex items-center gap-2">
          <Link to="/garantias" className="text-xs text-[var(--accent-2)] hover:underline">
            📋 Garantías
          </Link>
          <button onClick={() => setMostrarForm((v) => !v)} className="rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black">
            + Proveedor
          </button>
        </div>
      }
    >
      <div className="rounded-lg border border-[var(--warn)] bg-[var(--surface-1)] p-4">
        <p className="font-display text-xs text-[var(--warn)]">💰 TOTAL QUE LES DEBEMOS</p>
        <p className="mt-1 font-display text-3xl text-[var(--text-primary)]">{money(totalAdeudado)}</p>
      </div>

      {mostrarForm && (
        <NuevoProveedorForm
          onCreado={() => {
            setMostrarForm(false);
            cargar();
          }}
        />
      )}

      <input
        className="mt-4 w-full"
        placeholder="Buscar por nombre, distribuidor o teléfono…"
        value={busqueda}
        onChange={(e) => setBusqueda(e.target.value)}
      />

      <div className="mt-4 divide-y divide-[var(--border)] rounded-lg border border-[var(--border)]">
        {cargando && <p className="p-4 text-sm text-[var(--text-muted)]">Cargando…</p>}
        {!cargando && filtrados.length === 0 && (
          <p className="p-4 text-sm text-[var(--text-muted)]">No hay proveedores que coincidan.</p>
        )}
        {filtrados.map((p) => (
          <div key={p.id} className="flex items-center justify-between gap-3 px-4 py-3 hover:bg-[var(--surface-1)]">
            <Link to={`/proveedores/${p.id}`} className="min-w-0 flex-1">
              <p className="font-bold text-[var(--text-primary)]">{p.nombre_proveedor}</p>
              <p className="text-xs text-[var(--text-muted)]">
                {p.nombre_distribuidor ? `${p.nombre_distribuidor} · ` : ''}
                {p.telefono ?? 'sin teléfono'}
              </p>
            </Link>
            <Link to={`/proveedores/${p.id}`} className={`font-display text-lg ${p.saldo_pendiente > 0 ? 'text-[var(--bad)]' : 'text-[var(--good)]'}`}>
              {money(p.saldo_pendiente)}
            </Link>
            <button
              onClick={async () => {
                if (!confirm(`¿Quitar a "${p.nombre_proveedor}" de la lista?\n\nSus datos no se destruyen.`)) return;
                await supabase.from('proveedores').update({ eliminado: true }).eq('id', p.id);
                cargar();
              }}
              className="shrink-0 rounded p-1.5 text-[var(--text-muted)] hover:bg-[var(--bad)]/20 hover:text-[var(--bad)]"
            >
              🗑
            </button>
          </div>
        ))}
      </div>
    </Screen>
  );
}

function NuevoProveedorForm({ onCreado }: { onCreado: () => void }) {
  const [nombre, setNombre] = useState('');
  const [distribuidor, setDistribuidor] = useState('');
  const [telefono, setTelefono] = useState('');
  const [ubicacion, setUbicacion] = useState('');
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar(e: FormEvent) {
    e.preventDefault();
    if (!nombre.trim()) return;
    setGuardando(true);
    setError(null);
    const { error } = await supabase.from('proveedores').insert({
      nombre_proveedor: nombre.trim(),
      nombre_distribuidor: distribuidor.trim() || null,
      telefono: telefono.trim() || null,
      ubicacion: ubicacion.trim() || null,
    });
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    setNombre('');
    setDistribuidor('');
    setTelefono('');
    setUbicacion('');
    onCreado();
  }

  return (
    <form onSubmit={guardar} className="mt-4 rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
      <p className="font-display text-sm text-[var(--text-primary)]">Nuevo proveedor</p>
      <div className="mt-3 grid gap-3 sm:grid-cols-2">
        <input placeholder="Nombre del proveedor *" required value={nombre} onChange={(e) => setNombre(e.target.value)} />
        <input placeholder="Nombre del distribuidor/contacto" value={distribuidor} onChange={(e) => setDistribuidor(e.target.value)} />
        <input placeholder="Teléfono" value={telefono} onChange={(e) => setTelefono(e.target.value)} />
        <input placeholder="Sede / ubicación" value={ubicacion} onChange={(e) => setUbicacion(e.target.value)} />
      </div>
      {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}
      <button disabled={guardando} className="mt-3 rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black disabled:opacity-50">
        {guardando ? 'Guardando…' : 'Guardar proveedor'}
      </button>
    </form>
  );
}
