import { useState, type ReactNode } from 'react';
import { Link } from 'react-router-dom';
import { NEGOCIO } from '../lib/negocio';
import { compartirFacturaPdf, type DatosFacturaPdf } from '../lib/generarPdf';

interface FacturaLayoutProps {
  backTo: string;
  etiqueta: string; // "ESTADO DE CUENTA" | "PREFORMA" | "COTIZACIÓN" | "FACTURA"
  numero?: string;
  datosPdf: DatosFacturaPdf;
  children: ReactNode;
}

export function FacturaLayout({ backTo, etiqueta, numero, datosPdf, children }: FacturaLayoutProps) {
  const fechaEmision = new Date().toLocaleDateString('es-VE', { day: '2-digit', month: '2-digit', year: 'numeric' });
  const [generando, setGenerando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function compartir() {
    setGenerando(true);
    setError(null);
    try {
      const nombreArchivo = `${etiqueta.replace(/\s+/g, '_')}${numero ? `_${numero}` : ''}.pdf`;
      const resultado = await compartirFacturaPdf(datosPdf, nombreArchivo);
      if (resultado === 'descargado') {
        setError('Tu navegador no soporta compartir directo — se descargó el PDF, adjuntalo a mano en WhatsApp.');
      }
    } catch (err) {
      // El usuario cancelando el share sheet también cae acá — no es un error real.
      if (err instanceof Error && err.name !== 'AbortError') {
        setError('No se pudo generar el PDF: ' + err.message);
      }
    } finally {
      setGenerando(false);
    }
  }

  return (
    <div className="min-h-screen bg-[#e9e9e9]">
      <div className="no-imprimir sticky top-0 z-10 border-b border-black/10 bg-white px-4 py-3">
        <div className="flex items-center justify-between">
          <Link to={backTo} className="text-sm font-bold text-black hover:opacity-70">
            ← Volver
          </Link>
          <div className="flex gap-2">
            <button
              onClick={compartir}
              disabled={generando}
              className="rounded border border-black/20 px-3 py-1.5 text-sm font-bold text-black hover:bg-black/5 disabled:opacity-50"
            >
              {generando ? 'Generando…' : '📤 Compartir PDF'}
            </button>
            <button onClick={() => window.print()} className="rounded bg-black px-3 py-1.5 text-sm font-bold text-white hover:opacity-80">
              🖨 Imprimir
            </button>
          </div>
        </div>
        {error && <p className="mt-2 text-right text-xs text-[#b91c1c]">{error}</p>}
      </div>

      <div className="hoja-factura mx-auto max-w-3xl bg-white text-black shadow-lg print:shadow-none">
        <header className="flex items-start justify-between gap-4 bg-black px-6 py-5 text-white">
          <div className="flex items-center gap-3">
            {NEGOCIO.logoUrl ? (
              <img src={NEGOCIO.logoUrl} alt="" className="h-14 w-14 rounded-lg bg-white object-contain p-1" />
            ) : (
              <div className="flex h-14 w-14 items-center justify-center rounded-lg bg-white font-display text-xl font-bold text-black">
                {NEGOCIO.nombre.slice(0, 1)}
              </div>
            )}
            <div>
              <p className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/70">{NEGOCIO.categoria}</p>
              <p className="font-display text-2xl font-bold uppercase leading-tight">{NEGOCIO.nombre}</p>
            </div>
          </div>
          <div className="text-right">
            <div className="rounded border border-[#3a6fd8] bg-[#1d3f8f] px-3 py-1.5">
              <p className="text-[10px] font-bold uppercase tracking-wide text-white/80">{etiqueta}</p>
              {numero && <p className="font-display text-lg font-bold">Nº {numero}</p>}
            </div>
            <p className="mt-1 text-[10px] text-white/70">Emitido: {fechaEmision}</p>
          </div>
        </header>

        <div className="grid grid-cols-2 gap-4 bg-[#f4f4f4] px-6 py-3">
          <div>
            <p className="text-[10px] font-bold uppercase tracking-wide text-black/50">Ubicación</p>
            <p className="text-sm">{NEGOCIO.ubicacion}</p>
          </div>
          <div>
            <p className="text-[10px] font-bold uppercase tracking-wide text-black/50">Teléfono</p>
            <p className="text-sm">{NEGOCIO.telefono}</p>
          </div>
        </div>

        <div className="px-6 py-4">{children}</div>

        <footer className="border-t border-black/10 px-6 py-4 text-center text-[10px] text-black/50">
          {NEGOCIO.notaPie}
        </footer>
      </div>
    </div>
  );
}
