interface LightboxProps {
  url: string | null;
  onCerrar: () => void;
}

export function Lightbox({ url, onCerrar }: LightboxProps) {
  if (!url) return null;
  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/90 p-4" onClick={onCerrar}>
      <img src={url} alt="" className="max-h-full max-w-full rounded object-contain" />
      <button onClick={onCerrar} className="absolute top-4 right-4 text-2xl text-white hover:opacity-70">
        ✕
      </button>
    </div>
  );
}
