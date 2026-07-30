import { useRef, useState } from 'react';
import { subirFotoProducto } from '../lib/imagenes';

interface ImagenInputProps {
  url: string | null;
  onSubido: (url: string) => void;
}

/** Botón de foto: en el celular abre cámara/galería directo (input file nativo). */
export function ImagenInput({ url, onSubido }: ImagenInputProps) {
  const ref = useRef<HTMLInputElement>(null);
  const [subiendo, setSubiendo] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function alElegir(e: React.ChangeEvent<HTMLInputElement>) {
    const archivo = e.target.files?.[0];
    if (!archivo) return;
    setSubiendo(true);
    setError(null);
    try {
      const urlSubida = await subirFotoProducto(archivo);
      onSubido(urlSubida);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No se pudo subir la foto');
    } finally {
      setSubiendo(false);
      if (ref.current) ref.current.value = '';
    }
  }

  return (
    <div>
      <input ref={ref} type="file" accept="image/*" capture="environment" className="hidden" onChange={alElegir} />
      <button
        type="button"
        onClick={() => ref.current?.click()}
        disabled={subiendo}
        className="flex h-24 w-24 items-center justify-center overflow-hidden rounded-lg border border-dashed border-[var(--border)] bg-[var(--surface-2)] disabled:opacity-50"
      >
        {subiendo ? (
          <span className="text-xs text-[var(--text-muted)]">Subiendo…</span>
        ) : url ? (
          <img src={url} alt="" className="h-full w-full object-cover" />
        ) : (
          <span className="text-2xl">📷</span>
        )}
      </button>
      {error && <p className="mt-1 text-xs text-[var(--bad)]">{error}</p>}
    </div>
  );
}
