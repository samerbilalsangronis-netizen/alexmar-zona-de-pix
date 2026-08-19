import { useRef, useState, type PointerEvent as ReactPointerEvent } from 'react';

interface LightboxProps {
  url: string | null;
  onCerrar: () => void;
}

const ESCALA_ZOOM = 2.5;
const UMBRAL_ARRASTRE = 4;

interface ArrastreInfo {
  x: number;
  y: number;
  offsetX: number;
  offsetY: number;
  movido: boolean;
}

/** Visor de imagen a pantalla completa: tocar hace zoom, y con el zoom activo se puede arrastrar para recorrer la foto. */
export function Lightbox({ url, onCerrar }: LightboxProps) {
  const [zoom, setZoom] = useState(false);
  const [offset, setOffset] = useState({ x: 0, y: 0 });
  const arrastre = useRef<ArrastreInfo | null>(null);

  if (!url) return null;

  function onPointerDown(e: ReactPointerEvent<HTMLImageElement>) {
    arrastre.current = { x: e.clientX, y: e.clientY, offsetX: offset.x, offsetY: offset.y, movido: false };
    if (zoom) e.currentTarget.setPointerCapture(e.pointerId);
  }

  function onPointerMove(e: ReactPointerEvent<HTMLImageElement>) {
    if (!zoom || !arrastre.current) return;
    const dx = e.clientX - arrastre.current.x;
    const dy = e.clientY - arrastre.current.y;
    if (Math.abs(dx) > UMBRAL_ARRASTRE || Math.abs(dy) > UMBRAL_ARRASTRE) arrastre.current.movido = true;
    setOffset({ x: arrastre.current.offsetX + dx, y: arrastre.current.offsetY + dy });
  }

  function onImagenClick(e: ReactPointerEvent<HTMLImageElement>) {
    e.stopPropagation();
    const fueArrastre = arrastre.current?.movido ?? false;
    arrastre.current = null;
    if (fueArrastre) return;
    setZoom((z) => !z);
    setOffset({ x: 0, y: 0 });
  }

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center overflow-hidden bg-black/90 p-4" onClick={onCerrar}>
      <img
        src={url}
        alt=""
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onImagenClick}
        style={{
          transform: `translate(${offset.x}px, ${offset.y}px) scale(${zoom ? ESCALA_ZOOM : 1})`,
          touchAction: 'none',
          cursor: zoom ? 'grab' : 'zoom-in',
        }}
        className="max-h-full max-w-full rounded object-contain"
      />
      <button onClick={onCerrar} className="absolute top-4 right-4 text-2xl text-white hover:opacity-70">
        ✕
      </button>
      {!zoom && (
        <p className="absolute bottom-4 left-1/2 -translate-x-1/2 text-xs text-white/70">Tocá la imagen para hacer zoom</p>
      )}
    </div>
  );
}
