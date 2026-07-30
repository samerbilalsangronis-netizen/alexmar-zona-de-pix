import { useEffect, useState, type FormEvent } from 'react';
import { useParams } from 'react-router-dom';
import { Screen } from '../components/Screen';
import { supabase } from '../lib/supabaseClient';
import { money, fecha } from '../lib/format';
import type { Cliente, LineaCuenta } from '../types';

export function HojaCliente() {
  const { id } = useParams<{ id: string }>();
  const [cliente, setCliente] = useState<Cliente | null>(null);
  const [lineas, setLineas] = useState<LineaCuenta[]>([]);
  const [cargando, setCargando] = useState(true);

  async function cargar() {
    if (!id) return;
    setCargando(true);
    const [{ data: c }, { data: l }] = await Promise.all([
      supabase.from('vista_saldos_clientes').select('*').eq('id', id).single(),
      supabase
        .from('detalle_cuentas')
        .select('*')
        .eq('id_cliente', id)
        .eq('eliminado', false)
        .order('fecha'),
    ]);
    setCliente(c as Cliente | null);
    setLineas((l as LineaCuenta[]) ?? []);
    setCargando(false);
  }

  useEffect(() => {
    cargar();
    if (!id) return;
    const canal = supabase
      .channel(`cliente-${id}`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'detalle_cuentas', filter: `id_cliente=eq.${id}` }, cargar)
      .subscribe();
    return () => {
      supabase.removeChannel(canal);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  if (cargando) return <Screen title="Cargando…" backTo="/clientes"><p /></Screen>;
  if (!cliente) return <Screen title="Cliente no encontrado" backTo="/clientes"><p /></Screen>;

  return (
    <Screen title={`Hoja Nº ${cliente.factura_n ?? '—'}`} backTo="/clientes">
      <div className="rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
        <p className="font-display text-lg text-white">{cliente.nombre_cliente}</p>
        <p className="text-sm text-[var(--text-muted)]">
          {cliente.telefono ?? 'sin teléfono'} {cliente.cedula ? `· C.I. ${cliente.cedula}` : ''}
        </p>
      </div>

      <div className="mt-4 divide-y divide-[var(--border)] rounded-lg border border-[var(--border)]">
        {lineas.length === 0 && <p className="p-4 text-sm text-[var(--text-muted)]">Sin movimientos todavía.</p>}
        {lineas.map((l) => (
          <div key={l.id} className={`flex items-center justify-between px-4 py-3 ${l.tipo_linea === 'ABONO' ? 'bg-[var(--good)]/10' : ''}`}>
            <div>
              <p className="text-white">{l.tipo_linea === 'ABONO' ? 'ABONO recibido' : l.descripcion}</p>
              <p className="text-xs text-[var(--text-muted)]">
                {fecha(l.fecha)} {l.tipo_linea === 'CARGO' && l.precio_unitario ? `· ${l.cantidad} x ${money(l.precio_unitario)}` : ''}
              </p>
            </div>
            <p className={l.tipo_linea === 'ABONO' ? 'text-[var(--good)]' : 'text-white'}>
              {l.tipo_linea === 'ABONO' ? '− ' : ''}
              {money(l.total_linea)}
            </p>
          </div>
        ))}
      </div>

      <div className="mt-4 grid grid-cols-3 gap-2 rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4 text-center">
        <div>
          <p className="text-xs text-[var(--text-muted)]">TOTAL CONSUMIDO</p>
          <p className="font-display text-white">{money(cliente.total_cargado)}</p>
        </div>
        <div>
          <p className="text-xs text-[var(--text-muted)]">TOTAL ABONADO</p>
          <p className="font-display text-[var(--good)]">− {money(cliente.total_abonado)}</p>
        </div>
        <div className="rounded border border-[var(--accent)] p-1">
          <p className="text-xs text-[var(--text-muted)]">SALDO PENDIENTE</p>
          <p className="font-display text-[var(--accent)]">{money(cliente.saldo_pendiente)}</p>
        </div>
      </div>

      <CargaRapida idCliente={cliente.id} onGuardado={cargar} />
    </Screen>
  );
}

function CargaRapida({ idCliente, onGuardado }: { idCliente: string; onGuardado: () => void }) {
  const [tipo, setTipo] = useState<'CARGO' | 'ABONO'>('CARGO');
  const [descripcion, setDescripcion] = useState('');
  const [cantidad, setCantidad] = useState('1');
  const [precio, setPrecio] = useState('');
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar(e: FormEvent) {
    e.preventDefault();
    const cant = Number(cantidad) || 1;
    const precioNum = Number(precio) || 0;
    const total = tipo === 'ABONO' ? precioNum : cant * precioNum;
    if (tipo === 'CARGO' && !descripcion.trim()) return;

    setGuardando(true);
    setError(null);
    const { error } = await supabase.from('detalle_cuentas').insert({
      id_cliente: idCliente,
      tipo_linea: tipo,
      cantidad: cant,
      descripcion: tipo === 'ABONO' ? 'Abono' : descripcion.trim(),
      precio_unitario: tipo === 'CARGO' ? precioNum : null,
      total_linea: total,
      fecha: new Date().toISOString(),
    });
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    setDescripcion('');
    setCantidad('1');
    setPrecio('');
    onGuardado();
  }

  return (
    <form onSubmit={guardar} className="mt-4 rounded-lg border border-[var(--accent)] bg-[var(--surface-1)] p-4">
      <div className="flex gap-2">
        <button type="button" onClick={() => setTipo('CARGO')} className={`flex-1 rounded py-1.5 text-sm font-bold ${tipo === 'CARGO' ? 'bg-[var(--accent)] text-black' : 'border border-[var(--border)] text-[var(--text-secondary)]'}`}>
          CARGO
        </button>
        <button type="button" onClick={() => setTipo('ABONO')} className={`flex-1 rounded py-1.5 text-sm font-bold ${tipo === 'ABONO' ? 'bg-[var(--good)] text-black' : 'border border-[var(--border)] text-[var(--text-secondary)]'}`}>
          ABONO
        </button>
      </div>

      {tipo === 'CARGO' ? (
        <div className="mt-3 grid gap-2 sm:grid-cols-3">
          <input placeholder="Producto o servicio" required value={descripcion} onChange={(e) => setDescripcion(e.target.value)} className="sm:col-span-1" />
          <input type="number" min="0" step="1" placeholder="Cant." value={cantidad} onChange={(e) => setCantidad(e.target.value)} />
          <input type="number" min="0" step="0.01" placeholder="Precio unit." value={precio} onChange={(e) => setPrecio(e.target.value)} />
        </div>
      ) : (
        <input type="number" min="0" step="0.01" placeholder="Monto abonado" required value={precio} onChange={(e) => setPrecio(e.target.value)} className="mt-3 w-full" />
      )}

      {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}
      <button disabled={guardando} className="mt-3 w-full rounded bg-white py-2 text-sm font-bold text-black disabled:opacity-50">
        {guardando ? 'Guardando…' : 'Agregar'}
      </button>
    </form>
  );
}
