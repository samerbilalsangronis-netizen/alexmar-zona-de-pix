import { useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { ImagenInput } from './ImagenInput';
import { Lightbox } from './Lightbox';
import { CATEGORIAS_INVENTARIO, type Producto } from '../types';

interface ProductoDetalleProps {
  producto: Producto;
  onCerrar: () => void;
  onGuardado: () => void;
}

export function ProductoDetalle({ producto, onCerrar, onGuardado }: ProductoDetalleProps) {
  const [form, setForm] = useState({
    nombre_producto: producto.nombre_producto,
    categoria_tags: producto.categoria_tags,
    compatibilidad_vehiculos: producto.compatibilidad_vehiculos,
    pvp: producto.pvp?.toString() ?? '',
    costo: producto.costo?.toString() ?? '',
    stock_actual: producto.stock_actual.toString(),
    stock_minimo: producto.stock_minimo.toString(),
    url_foto: producto.url_foto,
  });
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [ampliar, setAmpliar] = useState(false);

  function set<K extends keyof typeof form>(campo: K, valor: (typeof form)[K]) {
    setForm((f) => ({ ...f, [campo]: valor }));
  }

  async function guardar() {
    if (!form.nombre_producto.trim()) {
      setError('El nombre no puede estar vacío.');
      return;
    }
    setGuardando(true);
    setError(null);
    const { error } = await supabase
      .from('inventario')
      .update({
        nombre_producto: form.nombre_producto.trim(),
        categoria_tags: form.categoria_tags,
        compatibilidad_vehiculos: form.compatibilidad_vehiculos.trim() || 'UNIVERSAL',
        pvp: form.pvp === '' ? null : Number(form.pvp),
        costo: form.costo === '' ? null : Number(form.costo),
        stock_actual: Number(form.stock_actual) || 0,
        stock_minimo: Number(form.stock_minimo) || 0,
        url_foto: form.url_foto,
      })
      .eq('id', producto.id);
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    onGuardado();
    onCerrar();
  }

  async function quitar() {
    if (!confirm(`¿Quitar "${producto.nombre_producto}" del catálogo?\n\nNo se destruye, solo deja de aparecer.`)) return;
    await supabase.from('inventario').update({ eliminado: true }).eq('id', producto.id);
    onGuardado();
    onCerrar();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/70 sm:items-center" onClick={onCerrar}>
      <div
        className="max-h-[90vh] w-full max-w-lg overflow-y-auto rounded-t-2xl border border-[var(--border)] bg-[var(--surface-1)] p-4 sm:rounded-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between">
          <p className="font-display text-sm text-[var(--text-primary)]">Editar producto</p>
          <button onClick={onCerrar} className="text-xl text-[var(--text-muted)] hover:text-[var(--text-primary)]">
            ✕
          </button>
        </div>

        <div className="mt-4 flex gap-4">
          <div className="flex flex-col items-center gap-1">
            <ImagenInput url={form.url_foto} onSubido={(url) => set('url_foto', url)} />
            {form.url_foto && (
              <button type="button" onClick={() => setAmpliar(true)} className="text-[10px] text-[var(--accent-2)] hover:underline">
                🔍 Ampliar
              </button>
            )}
          </div>
          <div className="flex-1">
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Nombre</label>
            <input value={form.nombre_producto} onChange={(e) => set('nombre_producto', e.target.value)} className="mt-1 w-full" />
          </div>
        </div>

        {ampliar && <Lightbox url={form.url_foto} onCerrar={() => setAmpliar(false)} />}

        <div className="mt-3 grid gap-3 sm:grid-cols-2">
          <div>
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Categoría</label>
            <select value={form.categoria_tags} onChange={(e) => set('categoria_tags', e.target.value)} className="mt-1 w-full">
              {CATEGORIAS_INVENTARIO.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Vehículos a los que aplica</label>
            <input
              value={form.compatibilidad_vehiculos}
              onChange={(e) => set('compatibilidad_vehiculos', e.target.value)}
              placeholder="UNIVERSAL, FORD F-150…"
              className="mt-1 w-full"
            />
          </div>
          <div>
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Precio de venta</label>
            <input type="number" min="0" step="0.01" value={form.pvp} onChange={(e) => set('pvp', e.target.value)} className="mt-1 w-full" />
          </div>
          <div>
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Precio de compra</label>
            <input type="number" min="0" step="0.01" value={form.costo} onChange={(e) => set('costo', e.target.value)} className="mt-1 w-full" />
          </div>
          <div>
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Stock actual</label>
            <input type="number" min="0" value={form.stock_actual} onChange={(e) => set('stock_actual', e.target.value)} className="mt-1 w-full" />
          </div>
          <div>
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Stock mínimo (alerta)</label>
            <input type="number" min="0" value={form.stock_minimo} onChange={(e) => set('stock_minimo', e.target.value)} className="mt-1 w-full" />
          </div>
        </div>

        {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}

        <div className="mt-4 flex gap-2">
          <button onClick={quitar} className="rounded border border-[var(--bad)] px-3 py-2 text-sm font-bold text-[var(--bad)] hover:bg-[var(--bad)]/10">
            🗑 Quitar
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
