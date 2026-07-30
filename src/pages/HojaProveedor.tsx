import { useEffect, useState, type FormEvent } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Screen } from '../components/Screen';
import { ImagenInput } from '../components/ImagenInput';
import { Lightbox } from '../components/Lightbox';
import { MovimientoProveedorDetalle } from '../components/MovimientoProveedorDetalle';
import { supabase } from '../lib/supabaseClient';
import { subirFotoFacturaProveedor } from '../lib/imagenes';
import { money, fecha } from '../lib/format';
import type { MovimientoProveedor, Proveedor } from '../types';

export function HojaProveedor() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [proveedor, setProveedor] = useState<Proveedor | null>(null);
  const [movimientos, setMovimientos] = useState<MovimientoProveedor[]>([]);
  const [cargando, setCargando] = useState(true);
  const [movEditar, setMovEditar] = useState<MovimientoProveedor | null>(null);
  const [ampliar, setAmpliar] = useState<string | null>(null);

  async function cargar() {
    if (!id) return;
    setCargando(true);
    const [{ data: p }, { data: m }] = await Promise.all([
      supabase.from('vista_saldos_proveedores').select('*').eq('id', id).single(),
      supabase.from('movimientos_proveedor').select('*').eq('id_proveedor', id).eq('eliminado', false).order('fecha'),
    ]);
    setProveedor(p as Proveedor | null);
    setMovimientos((m as MovimientoProveedor[]) ?? []);
    setCargando(false);
  }

  useEffect(() => {
    cargar();
    if (!id) return;
    const canal = supabase
      .channel(`proveedor-${id}`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'movimientos_proveedor', filter: `id_proveedor=eq.${id}` }, cargar)
      .subscribe();
    return () => {
      supabase.removeChannel(canal);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  async function eliminarRapido(m: MovimientoProveedor) {
    if (!confirm('¿Eliminar este movimiento?')) return;
    await supabase.from('movimientos_proveedor').update({ eliminado: true }).eq('id', m.id);
    cargar();
  }

  if (cargando) return <Screen title="Cargando…" backTo="/proveedores"><p /></Screen>;
  if (!proveedor) return <Screen title="Proveedor no encontrado" backTo="/proveedores"><p /></Screen>;

  return (
    <Screen title={proveedor.nombre_proveedor} backTo="/proveedores">
      <div className="rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
        <div className="flex items-start justify-between">
          <div>
            <p className="font-display text-lg text-[var(--text-primary)]">{proveedor.nombre_proveedor}</p>
            <p className="text-sm text-[var(--text-muted)]">
              {proveedor.nombre_distribuidor ?? 'sin distribuidor'} · {proveedor.telefono ?? 'sin teléfono'}
            </p>
            {proveedor.ubicacion && <p className="text-xs text-[var(--text-muted)]">{proveedor.ubicacion}</p>}
          </div>
          <button
            onClick={async () => {
              if (!confirm(`¿Quitar a "${proveedor.nombre_proveedor}" de la lista?`)) return;
              await supabase.from('proveedores').update({ eliminado: true }).eq('id', proveedor.id);
              navigate('/proveedores');
            }}
            className="text-xs text-[var(--text-muted)] hover:text-[var(--bad)]"
          >
            🗑 Quitar
          </button>
        </div>
      </div>

      <div className="mt-4 divide-y divide-[var(--border)] rounded-lg border border-[var(--border)]">
        {movimientos.length === 0 && <p className="p-4 text-sm text-[var(--text-muted)]">Sin movimientos todavía.</p>}
        {movimientos.map((m) => {
          const esPago = m.tipo === 'PAGO';
          return (
            <div key={m.id} className={`flex items-center justify-between gap-2 px-4 py-3 ${esPago ? 'bg-[var(--good)]/10' : ''}`}>
              <div className="flex min-w-0 items-center gap-3">
                {m.factura_url && (
                  <button onClick={() => setAmpliar(m.factura_url)} className="h-10 w-10 shrink-0 overflow-hidden rounded">
                    <img src={m.factura_url} alt="" className="h-full w-full object-cover" />
                  </button>
                )}
                <div className="min-w-0">
                  <p className="text-[var(--text-primary)]">{esPago ? 'PAGO' : m.descripcion || 'Compra'}</p>
                  <p className="text-xs text-[var(--text-muted)]">{fecha(m.fecha)}</p>
                </div>
              </div>
              <div className="flex shrink-0 items-center gap-2">
                <p className={esPago ? 'text-[var(--good)]' : 'text-[var(--text-primary)]'}>
                  {esPago ? '− ' : ''}
                  {money(m.monto)}
                </p>
                <button onClick={() => setMovEditar(m)} className="text-sm text-[var(--text-muted)] hover:text-[var(--text-primary)]" title="Editar">
                  ✏️
                </button>
                <button onClick={() => eliminarRapido(m)} className="text-sm text-[var(--text-muted)] hover:text-[var(--bad)]" title="Eliminar">
                  🗑
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {movEditar && <MovimientoProveedorDetalle movimiento={movEditar} onCerrar={() => setMovEditar(null)} onGuardado={cargar} />}
      <Lightbox url={ampliar} onCerrar={() => setAmpliar(null)} />

      <div className="mt-4 grid grid-cols-3 gap-2 rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4 text-center">
        <div>
          <p className="text-xs text-[var(--text-muted)]">TOTAL COMPRADO</p>
          <p className="font-display text-[var(--text-primary)]">{money(proveedor.total_comprado)}</p>
        </div>
        <div>
          <p className="text-xs text-[var(--text-muted)]">TOTAL PAGADO</p>
          <p className="font-display text-[var(--good)]">− {money(proveedor.total_pagado)}</p>
        </div>
        <div className="rounded border border-[var(--warn)] p-1">
          <p className="text-xs text-[var(--text-muted)]">SE LE DEBE</p>
          <p className="font-display text-[var(--warn)]">{money(proveedor.saldo_pendiente)}</p>
        </div>
      </div>

      <RegistrarCompra idProveedor={proveedor.id} onGuardado={cargar} />
      <RegistrarPago idProveedor={proveedor.id} onGuardado={cargar} />
    </Screen>
  );
}

function RegistrarCompra({ idProveedor, onGuardado }: { idProveedor: string; onGuardado: () => void }) {
  const [descripcion, setDescripcion] = useState('');
  const [monto, setMonto] = useState('');
  const [facturaUrl, setFacturaUrl] = useState<string | null>(null);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar(e: FormEvent) {
    e.preventDefault();
    const montoNum = Number(monto);
    if (!montoNum || montoNum <= 0) return;
    setGuardando(true);
    setError(null);
    const { error } = await supabase.from('movimientos_proveedor').insert({
      id_proveedor: idProveedor,
      tipo: 'COMPRA',
      descripcion: descripcion.trim() || null,
      monto: montoNum,
      factura_url: facturaUrl,
      fecha: new Date().toISOString(),
    });
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    setDescripcion('');
    setMonto('');
    setFacturaUrl(null);
    onGuardado();
  }

  return (
    <form onSubmit={guardar} className="mt-4 rounded-lg border border-[var(--warn)] bg-[var(--surface-1)] p-4">
      <p className="font-display text-sm text-[var(--text-primary)]">Registrar compra</p>
      <div className="mt-3 flex gap-4">
        <ImagenInput url={facturaUrl} onSubido={setFacturaUrl} subir={subirFotoFacturaProveedor} />
        <div className="flex-1 space-y-2">
          <input placeholder="Descripción (opcional)" value={descripcion} onChange={(e) => setDescripcion(e.target.value)} className="w-full" />
          <input type="number" min="0" step="0.01" placeholder="Monto de la compra" required value={monto} onChange={(e) => setMonto(e.target.value)} className="w-full" />
        </div>
      </div>
      {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}
      <button disabled={guardando} className="mt-3 w-full rounded bg-[var(--warn)] py-2 text-sm font-bold text-black disabled:opacity-50">
        {guardando ? 'Guardando…' : 'Registrar compra'}
      </button>
    </form>
  );
}

function RegistrarPago({ idProveedor, onGuardado }: { idProveedor: string; onGuardado: () => void }) {
  const [monto, setMonto] = useState('');
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar(e: FormEvent) {
    e.preventDefault();
    const montoNum = Number(monto);
    if (!montoNum || montoNum <= 0) return;
    setGuardando(true);
    setError(null);
    const { error } = await supabase.from('movimientos_proveedor').insert({
      id_proveedor: idProveedor,
      tipo: 'PAGO',
      monto: montoNum,
      fecha: new Date().toISOString(),
    });
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    setMonto('');
    onGuardado();
  }

  return (
    <form onSubmit={guardar} className="mt-4 rounded-lg border border-[var(--good)] bg-[var(--surface-1)] p-4">
      <p className="font-display text-sm text-[var(--text-primary)]">Registrar pago</p>
      <input type="number" min="0" step="0.01" placeholder="Monto pagado" required value={monto} onChange={(e) => setMonto(e.target.value)} className="mt-3 w-full" />
      {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}
      <button disabled={guardando} className="mt-3 w-full rounded bg-[var(--good)] py-2 text-sm font-bold text-black disabled:opacity-50">
        {guardando ? 'Guardando…' : 'Registrar pago'}
      </button>
    </form>
  );
}
