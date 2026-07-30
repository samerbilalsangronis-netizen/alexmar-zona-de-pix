import { useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { ImagenInput } from './ImagenInput';
import { Lightbox } from './Lightbox';
import { subirFotoFacturaProveedor } from '../lib/imagenes';
import type { MovimientoProveedor } from '../types';

interface Props {
  movimiento: MovimientoProveedor;
  onCerrar: () => void;
  onGuardado: () => void;
}

export function MovimientoProveedorDetalle({ movimiento, onCerrar, onGuardado }: Props) {
  const [descripcion, setDescripcion] = useState(movimiento.descripcion ?? '');
  const [monto, setMonto] = useState(String(movimiento.monto));
  const [facturaUrl, setFacturaUrl] = useState(movimiento.factura_url);
  const [ampliar, setAmpliar] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar() {
    const montoNum = Number(monto);
    if (!montoNum || montoNum <= 0) {
      setError('El monto debe ser mayor a 0.');
      return;
    }
    setGuardando(true);
    setError(null);
    const { error } = await supabase
      .from('movimientos_proveedor')
      .update({ descripcion: descripcion.trim() || null, monto: montoNum, factura_url: facturaUrl })
      .eq('id', movimiento.id);
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    onGuardado();
    onCerrar();
  }

  async function eliminar() {
    if (!confirm('¿Eliminar este movimiento?')) return;
    await supabase.from('movimientos_proveedor').update({ eliminado: true }).eq('id', movimiento.id);
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
          <p className="font-display text-sm text-[var(--text-primary)]">Editar {movimiento.tipo === 'COMPRA' ? 'compra' : 'pago'}</p>
          <button onClick={onCerrar} className="text-xl text-[var(--text-muted)] hover:text-[var(--text-primary)]">
            ✕
          </button>
        </div>

        <div className="mt-4 flex gap-4">
          <div className="flex flex-col items-center gap-1">
            <ImagenInput url={facturaUrl} onSubido={setFacturaUrl} subir={subirFotoFacturaProveedor} />
            {facturaUrl && (
              <button type="button" onClick={() => setAmpliar(true)} className="text-[10px] text-[var(--accent-2)] hover:underline">
                🔍 Ampliar
              </button>
            )}
          </div>
          <div className="flex-1 space-y-3">
            {movimiento.tipo === 'COMPRA' && (
              <div>
                <label className="block text-xs uppercase text-[var(--text-secondary)]">Descripción</label>
                <input value={descripcion} onChange={(e) => setDescripcion(e.target.value)} className="mt-1 w-full" />
              </div>
            )}
            <div>
              <label className="block text-xs uppercase text-[var(--text-secondary)]">Monto</label>
              <input type="number" min="0" step="0.01" value={monto} onChange={(e) => setMonto(e.target.value)} className="mt-1 w-full" />
            </div>
          </div>
        </div>

        {ampliar && <Lightbox url={facturaUrl} onCerrar={() => setAmpliar(false)} />}

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
