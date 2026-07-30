import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import { Screen } from '../components/Screen';
import { GrillaItems, filaVacia, type FilaGrid } from '../components/GrillaItems';
import { LineaDetalle } from '../components/LineaDetalle';
import { supabase } from '../lib/supabaseClient';
import { money, fecha } from '../lib/format';
import { METODOS_PAGO, type Cliente, type LineaCuenta } from '../types';

const FILAS_INICIALES = 8;

export function HojaCliente() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [cliente, setCliente] = useState<Cliente | null>(null);
  const [lineas, setLineas] = useState<LineaCuenta[]>([]);
  const [cargando, setCargando] = useState(true);
  const [lineaEditar, setLineaEditar] = useState<LineaCuenta | null>(null);

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

  async function vaciarCuenta() {
    if (!cliente) return;
    if (
      !confirm(
        `¿Vaciar la cuenta de "${cliente.nombre_cliente}"?\n\nSe borran los ${lineas.length} movimiento(s) (cargos y abonos), pero el cliente sigue en el Índice Maestro. Usalo cuando paga todo pero seguís haciéndole trabajos.`,
      )
    )
      return;
    await supabase.from('detalle_cuentas').update({ eliminado: true }).eq('id_cliente', cliente.id).eq('eliminado', false);
    cargar();
  }

  if (cargando) return <Screen title="Cargando…" backTo="/clientes"><p /></Screen>;
  if (!cliente) return <Screen title="Cliente no encontrado" backTo="/clientes"><p /></Screen>;

  return (
    <Screen
      title={`Hoja Nº ${cliente.factura_n ?? '—'}`}
      backTo="/clientes"
      actions={
        <>
          <Link
            to={`/clientes/${cliente.id}/factura`}
            className="rounded border border-[var(--accent-2)] px-3 py-1.5 text-xs font-bold text-[var(--accent-2)] hover:bg-[var(--accent-2)]/10"
          >
            🧾 Factura
          </Link>
          <button
            onClick={vaciarCuenta}
            disabled={lineas.length === 0}
            className="rounded border border-[var(--warn)] px-3 py-1.5 text-xs font-bold text-[var(--warn)] hover:bg-[var(--warn)]/10 disabled:opacity-30"
            title="Vaciar cuenta (el cliente sigue existiendo)"
          >
            🧹 Vaciar cuenta
          </button>
        </>
      }
    >
      <div className="rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
        <div className="flex items-start justify-between">
          <div>
            <p className="font-display text-lg text-[var(--text-primary)]">{cliente.nombre_cliente}</p>
            <p className="text-sm text-[var(--text-muted)]">
              {cliente.telefono ?? 'sin teléfono'} {cliente.cedula ? `· C.I. ${cliente.cedula}` : ''}
            </p>
          </div>
          <button
            onClick={async () => {
              if (!confirm(`¿Quitar a "${cliente.nombre_cliente}" del Índice Maestro?`)) return;
              await supabase.from('clientes').update({ eliminado: true }).eq('id', cliente.id);
              navigate('/clientes');
            }}
            className="text-xs text-[var(--text-muted)] hover:text-[var(--bad)]"
          >
            🗑 Quitar cliente
          </button>
        </div>
      </div>

      <Libro lineas={lineas} onEditar={setLineaEditar} onCambio={cargar} />

      {lineaEditar && <LineaDetalle linea={lineaEditar} onCerrar={() => setLineaEditar(null)} onGuardado={cargar} />}

      <div className="mt-4 grid grid-cols-3 gap-2 rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4 text-center">
        <div>
          <p className="text-xs text-[var(--text-muted)]">TOTAL CONSUMIDO</p>
          <p className="font-display text-[var(--text-primary)]">{money(cliente.total_cargado)}</p>
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

      <CargaCargos idCliente={cliente.id} onGuardado={cargar} />
      <CargaAbono idCliente={cliente.id} onGuardado={cargar} />
    </Screen>
  );
}

function Libro({
  lineas,
  onEditar,
  onCambio,
}: {
  lineas: LineaCuenta[];
  onEditar: (linea: LineaCuenta) => void;
  onCambio: () => void;
}) {
  async function eliminarRapido(linea: LineaCuenta) {
    if (!confirm('¿Eliminar este ítem? No afecta al resto de la cuenta.')) return;
    await supabase.from('detalle_cuentas').update({ eliminado: true }).eq('id', linea.id);
    onCambio();
  }

  if (lineas.length === 0) {
    return (
      <div className="mt-4 rounded-lg border border-[var(--border)] p-4">
        <p className="text-sm text-[var(--text-muted)]">Sin movimientos todavía.</p>
      </div>
    );
  }
  return (
    <div className="mt-4 divide-y divide-[var(--border)] rounded-lg border border-[var(--border)]">
      {lineas.map((l) => {
        if (l.tipo_linea === 'TITULO') {
          return (
            <div key={l.id} className="flex items-center justify-between bg-[var(--accent)] px-4 py-1.5 text-black">
              <span className="font-display text-xs font-bold">« {l.descripcion} »</span>
              <div className="flex gap-2">
                <button onClick={() => onEditar(l)} className="text-xs hover:opacity-70" title="Editar">
                  ✏️
                </button>
                <button onClick={() => eliminarRapido(l)} className="text-xs hover:opacity-70" title="Eliminar">
                  🗑
                </button>
              </div>
            </div>
          );
        }
        const esAbono = l.tipo_linea === 'ABONO';
        return (
          <div key={l.id} className={`flex items-center justify-between gap-2 px-4 py-3 ${esAbono ? 'bg-[var(--good)]/10' : ''}`}>
            <div className="min-w-0">
              <p className="text-[var(--text-primary)]">{esAbono ? `ABONO${l.metodo_pago ? ` · ${l.metodo_pago}` : ''}` : l.descripcion}</p>
              <p className="text-xs text-[var(--text-muted)]">
                {fecha(l.fecha)} {!esAbono && l.precio_unitario ? `· ${l.cantidad} x ${money(l.precio_unitario)}` : ''}
              </p>
            </div>
            <div className="flex shrink-0 items-center gap-2">
              <p className={esAbono ? 'text-[var(--good)]' : 'text-[var(--text-primary)]'}>
                {esAbono ? '− ' : ''}
                {money(l.total_linea)}
              </p>
              <button onClick={() => onEditar(l)} className="text-sm text-[var(--text-muted)] hover:text-[var(--text-primary)]" title="Editar">
                ✏️
              </button>
              <button onClick={() => eliminarRapido(l)} className="text-sm text-[var(--text-muted)] hover:text-[var(--bad)]" title="Eliminar">
                🗑
              </button>
            </div>
          </div>
        );
      })}
    </div>
  );
}

function CargaCargos({ idCliente, onGuardado }: { idCliente: string; onGuardado: () => void }) {
  const [vehiculo, setVehiculo] = useState('');
  const [filas, setFilas] = useState<FilaGrid[]>(() => Array.from({ length: FILAS_INICIALES }, filaVacia));
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const filasCompletas = useMemo(
    () => filas.filter((f) => f.descripcion.trim() && Number(f.precio) >= 0 && f.precio !== ''),
    [filas],
  );

  async function guardar(e: FormEvent) {
    e.preventDefault();
    if (filasCompletas.length === 0) {
      setError('Completá al menos un ítem (producto/servicio y precio).');
      return;
    }
    setGuardando(true);
    setError(null);

    const ahora = Date.now();
    const filasNuevas: Record<string, unknown>[] = [];

    if (vehiculo.trim()) {
      filasNuevas.push({
        id_cliente: idCliente,
        tipo_linea: 'TITULO',
        descripcion: vehiculo.trim().toUpperCase(),
        cantidad: 0,
        total_linea: 0,
        fecha: new Date(ahora).toISOString(),
      });
    }

    filasCompletas.forEach((f, i) => {
      const cant = Number(f.cantidad) || 1;
      const precio = Number(f.precio) || 0;
      filasNuevas.push({
        id_cliente: idCliente,
        tipo_linea: 'CARGO',
        cantidad: cant,
        descripcion: f.descripcion.trim(),
        precio_unitario: precio,
        total_linea: cant * precio,
        fecha: new Date(ahora + i + 1).toISOString(),
      });
    });

    const { error } = await supabase.from('detalle_cuentas').insert(filasNuevas);
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    setVehiculo('');
    setFilas(Array.from({ length: FILAS_INICIALES }, filaVacia));
    onGuardado();
  }

  return (
    <form onSubmit={guardar} className="mt-4 rounded-lg border border-[var(--accent)] bg-[var(--surface-1)] p-4">
      <p className="font-display text-sm text-[var(--text-primary)]">Cargar ítems</p>

      <label className="mt-3 block text-xs uppercase text-[var(--text-secondary)]">
        Vehículo (opcional — para separar la factura por vehículo)
      </label>
      <input
        value={vehiculo}
        onChange={(e) => setVehiculo(e.target.value)}
        placeholder="Ej: FORD F-150, TRITON BLANCO…"
        className="mt-1 w-full"
      />

      <GrillaItems filas={filas} onCambiar={setFilas} filasPorTanda={FILAS_INICIALES} />

      {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}
      <button disabled={guardando} className="mt-3 w-full rounded bg-[var(--text-primary)] py-2 text-sm font-bold text-[var(--bg)] disabled:opacity-50">
        {guardando ? 'Guardando…' : `Guardar ${filasCompletas.length || ''} ítem(s)`}
      </button>
    </form>
  );
}

function CargaAbono({ idCliente, onGuardado }: { idCliente: string; onGuardado: () => void }) {
  const [monto, setMonto] = useState('');
  const [metodo, setMetodo] = useState<string>(METODOS_PAGO[0]);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar(e: FormEvent) {
    e.preventDefault();
    const montoNum = Number(monto);
    if (!montoNum || montoNum <= 0) return;
    setGuardando(true);
    setError(null);
    const { error } = await supabase.from('detalle_cuentas').insert({
      id_cliente: idCliente,
      tipo_linea: 'ABONO',
      cantidad: 1,
      descripcion: 'Abono',
      total_linea: montoNum,
      metodo_pago: metodo,
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
      <p className="font-display text-sm text-[var(--text-primary)]">Registrar abono</p>
      <div className="mt-3 grid gap-2 sm:grid-cols-2">
        <input
          type="number"
          min="0"
          step="0.01"
          placeholder="Monto abonado"
          required
          value={monto}
          onChange={(e) => setMonto(e.target.value)}
        />
        <select value={metodo} onChange={(e) => setMetodo(e.target.value)}>
          {METODOS_PAGO.map((m) => (
            <option key={m} value={m}>
              {m}
            </option>
          ))}
        </select>
      </div>
      {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}
      <button disabled={guardando} className="mt-3 w-full rounded bg-[var(--good)] py-2 text-sm font-bold text-black disabled:opacity-50">
        {guardando ? 'Guardando…' : 'Registrar abono'}
      </button>
    </form>
  );
}
