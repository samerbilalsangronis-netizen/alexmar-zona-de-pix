import { useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { METODOS_PAGO, type LineaCuenta } from '../types';

interface LineaDetalleProps {
  linea: LineaCuenta;
  onCerrar: () => void;
  onGuardado: () => void;
}

export function LineaDetalle({ linea, onCerrar, onGuardado }: LineaDetalleProps) {
  const [descripcion, setDescripcion] = useState(linea.descripcion);
  const [cantidad, setCantidad] = useState(String(linea.cantidad ?? 1));
  const [precio, setPrecio] = useState(linea.precio_unitario?.toString() ?? '');
  const [monto, setMonto] = useState(String(linea.total_linea));
  const [metodo, setMetodo] = useState(linea.metodo_pago ?? METODOS_PAGO[0]);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar() {
    setGuardando(true);
    setError(null);
    let cambios: Record<string, unknown>;

    if (linea.tipo_linea === 'CARGO') {
      const cant = Number(cantidad) || 1;
      const precioNum = Number(precio) || 0;
      if (!descripcion.trim()) {
        setError('El producto/servicio no puede estar vacío.');
        setGuardando(false);
        return;
      }
      cambios = { descripcion: descripcion.trim(), cantidad: cant, precio_unitario: precioNum, total_linea: cant * precioNum };
    } else if (linea.tipo_linea === 'ABONO') {
      const montoNum = Number(monto);
      if (!montoNum || montoNum <= 0) {
        setError('El monto del abono debe ser mayor a 0.');
        setGuardando(false);
        return;
      }
      cambios = { total_linea: montoNum, metodo_pago: metodo };
    } else {
      if (!descripcion.trim()) {
        setError('El nombre del vehículo no puede estar vacío.');
        setGuardando(false);
        return;
      }
      cambios = { descripcion: descripcion.trim().toUpperCase() };
    }

    const { error } = await supabase.from('detalle_cuentas').update(cambios).eq('id', linea.id);
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    onGuardado();
    onCerrar();
  }

  async function eliminar() {
    if (!confirm('¿Eliminar este ítem? No afecta al resto de la cuenta.')) return;
    await supabase.from('detalle_cuentas').update({ eliminado: true }).eq('id', linea.id);
    onGuardado();
    onCerrar();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/70 sm:items-center" onClick={onCerrar}>
      <div
        className="w-full max-w-md rounded-t-2xl border border-[var(--border)] bg-[var(--surface-1)] p-4 sm:rounded-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between">
          <p className="font-display text-sm text-[var(--text-primary)]">
            Editar {linea.tipo_linea === 'ABONO' ? 'abono' : linea.tipo_linea === 'TITULO' ? 'vehículo' : 'ítem'}
          </p>
          <button onClick={onCerrar} className="text-xl text-[var(--text-muted)] hover:text-[var(--text-primary)]">
            ✕
          </button>
        </div>

        <div className="mt-4 space-y-3">
          {linea.tipo_linea === 'CARGO' && (
            <>
              <div>
                <label className="block text-xs uppercase text-[var(--text-secondary)]">Producto o servicio</label>
                <input value={descripcion} onChange={(e) => setDescripcion(e.target.value)} className="mt-1 w-full" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs uppercase text-[var(--text-secondary)]">Cantidad</label>
                  <input type="number" min="0" value={cantidad} onChange={(e) => setCantidad(e.target.value)} className="mt-1 w-full" />
                </div>
                <div>
                  <label className="block text-xs uppercase text-[var(--text-secondary)]">Precio unit.</label>
                  <input type="number" min="0" step="0.01" value={precio} onChange={(e) => setPrecio(e.target.value)} className="mt-1 w-full" />
                </div>
              </div>
            </>
          )}

          {linea.tipo_linea === 'ABONO' && (
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs uppercase text-[var(--text-secondary)]">Monto</label>
                <input type="number" min="0" step="0.01" value={monto} onChange={(e) => setMonto(e.target.value)} className="mt-1 w-full" />
              </div>
              <div>
                <label className="block text-xs uppercase text-[var(--text-secondary)]">Método de pago</label>
                <select value={metodo} onChange={(e) => setMetodo(e.target.value)} className="mt-1 w-full">
                  {METODOS_PAGO.map((m) => (
                    <option key={m} value={m}>
                      {m}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          )}

          {linea.tipo_linea === 'TITULO' && (
            <div>
              <label className="block text-xs uppercase text-[var(--text-secondary)]">Nombre del vehículo</label>
              <input value={descripcion} onChange={(e) => setDescripcion(e.target.value)} className="mt-1 w-full" />
            </div>
          )}
        </div>

        {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}

        <div className="mt-4 flex gap-2">
          <button onClick={eliminar} className="rounded border border-[var(--bad)] px-3 py-2 text-sm font-bold text-[var(--bad)] hover:bg-[var(--bad)]/10">
            🗑 Eliminar
          </button>
          <button
            onClick={guardar}
            disabled={guardando}
            className="flex-1 rounded bg-[var(--accent)] py-2 text-sm font-bold text-black disabled:opacity-50"
          >
            {guardando ? 'Guardando…' : 'Guardar cambios'}
          </button>
        </div>
      </div>
    </div>
  );
}
