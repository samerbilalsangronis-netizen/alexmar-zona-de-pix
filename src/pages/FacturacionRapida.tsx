import { useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { FacturaLayout } from '../components/FacturaLayout';
import { TablaFactura, type ItemFactura } from '../components/TablaFactura';
import { GrillaItems, filaVacia, type FilaGrid } from '../components/GrillaItems';
import { money } from '../lib/format';

const TIPOS = [
  { valor: 'FACTURA', etiqueta: 'FACTURA' },
  { valor: 'PREFORMA', etiqueta: 'PREFORMA' },
  { valor: 'COTIZACION', etiqueta: 'COTIZACIÓN' },
] as const;

export function FacturacionRapida() {
  const [tipo, setTipo] = useState<(typeof TIPOS)[number]['valor']>('FACTURA');
  const [numero, setNumero] = useState('');
  const [nombreCliente, setNombreCliente] = useState('');
  const [telefonoCliente, setTelefonoCliente] = useState('');
  const [filas, setFilas] = useState<FilaGrid[]>(() => Array.from({ length: 8 }, filaVacia));

  const filasCompletas = useMemo(
    () => filas.filter((f) => f.descripcion.trim() && f.precio !== '' && Number(f.precio) >= 0),
    [filas],
  );

  const items: ItemFactura[] = filasCompletas.map((f) => {
    const cant = Number(f.cantidad) || 1;
    const precio = Number(f.precio) || 0;
    return { tipo: 'ITEM', cantidad: cant, descripcion: f.descripcion.trim(), precioUnitario: precio, total: cant * precio };
  });
  const total = items.reduce((acc, it) => acc + it.total, 0);
  const etiqueta = TIPOS.find((t) => t.valor === tipo)!.etiqueta;

  return (
    <div className="min-h-screen bg-[var(--bg)] pb-16">
      <header className="no-imprimir sticky top-0 z-10 flex items-center gap-3 border-b border-[var(--border)] bg-[var(--bg)]/95 px-4 py-3 backdrop-blur">
        <Link to="/" className="text-xl text-[var(--accent-2)] hover:opacity-80">
          ←
        </Link>
        <h1 className="font-display text-lg uppercase text-white">Facturación Rápida</h1>
      </header>

      <div className="no-imprimir mx-auto max-w-3xl space-y-4 px-4 py-4">
        <p className="text-sm text-[var(--text-muted)]">
          Para clientes ocasionales que no están en tu Índice Maestro. Esto no guarda nada en la base de datos —
          solo genera el documento para imprimir o compartir.
        </p>

        <div className="rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
          <div className="flex gap-2">
            {TIPOS.map((t) => (
              <button
                key={t.valor}
                type="button"
                onClick={() => setTipo(t.valor)}
                className={`flex-1 rounded py-2 text-sm font-bold ${
                  tipo === t.valor ? 'bg-[var(--accent)] text-black' : 'border border-[var(--border)] text-[var(--text-secondary)]'
                }`}
              >
                {t.etiqueta}
              </button>
            ))}
          </div>

          <div className="mt-3 grid gap-3 sm:grid-cols-3">
            <input placeholder="Nombre del cliente" value={nombreCliente} onChange={(e) => setNombreCliente(e.target.value)} />
            <input placeholder="Teléfono (opcional)" value={telefonoCliente} onChange={(e) => setTelefonoCliente(e.target.value)} />
            <input placeholder={`Nº de ${etiqueta.toLowerCase()} (opcional)`} value={numero} onChange={(e) => setNumero(e.target.value)} />
          </div>

          <GrillaItems filas={filas} onCambiar={setFilas} />
        </div>

        {items.length > 0 && (
          <p className="text-right font-display text-lg text-[var(--accent)]">Total: {money(total)}</p>
        )}
      </div>

      <FacturaLayout
        backTo="/"
        etiqueta={etiqueta}
        numero={numero || undefined}
        datosPdf={{
          etiqueta,
          numero: numero || undefined,
          clienteNombre: nombreCliente,
          clienteContacto: telefonoCliente ? `Tel: ${telefonoCliente}` : '—',
          items,
          totales: [{ etiqueta: 'Total', valor: total, destacado: true }],
        }}
      >
        <div className="mb-4 grid grid-cols-2 gap-4 rounded border border-black/10 p-3">
          <div>
            <p className="text-[10px] font-bold uppercase tracking-wide text-black/50">Cliente</p>
            <p className="text-lg font-bold">{nombreCliente || '—'}</p>
          </div>
          <div>
            <p className="text-[10px] font-bold uppercase tracking-wide text-black/50">Contacto</p>
            <p className="text-sm">{telefonoCliente ? `Tel: ${telefonoCliente}` : '—'}</p>
          </div>
        </div>

        {items.length === 0 ? (
          <p className="py-6 text-center text-sm text-black/50">Agregá ítems arriba para verlos reflejados acá.</p>
        ) : (
          <TablaFactura items={items} />
        )}

        <div className="mt-4 flex justify-end">
          <div className="flex w-full max-w-xs justify-between rounded bg-[#1d3f8f] px-3 py-2 text-white">
            <span className="text-xs font-bold uppercase tracking-wide">Total</span>
            <span className="font-display font-bold">{money(total)}</span>
          </div>
        </div>
      </FacturaLayout>
    </div>
  );
}
