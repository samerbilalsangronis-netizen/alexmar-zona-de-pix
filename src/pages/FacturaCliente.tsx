import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { FacturaLayout } from '../components/FacturaLayout';
import { TablaFactura, type ItemFactura } from '../components/TablaFactura';
import { supabase } from '../lib/supabaseClient';
import { money } from '../lib/format';
import type { Cliente, LineaCuenta } from '../types';

export function FacturaCliente() {
  const { id } = useParams<{ id: string }>();
  const [cliente, setCliente] = useState<Cliente | null>(null);
  const [lineas, setLineas] = useState<LineaCuenta[]>([]);
  const [cargando, setCargando] = useState(true);

  useEffect(() => {
    if (!id) return;
    Promise.all([
      supabase.from('vista_saldos_clientes').select('*').eq('id', id).single(),
      supabase.from('detalle_cuentas').select('*').eq('id_cliente', id).eq('eliminado', false).order('fecha'),
    ]).then(([{ data: c }, { data: l }]) => {
      setCliente(c as Cliente | null);
      setLineas((l as LineaCuenta[]) ?? []);
      setCargando(false);
    });
  }, [id]);

  if (cargando || !cliente) {
    return (
      <div className="flex h-screen items-center justify-center text-[var(--text-secondary)]">Cargando…</div>
    );
  }

  const items: ItemFactura[] = lineas.map((l) => ({
    tipo: l.tipo_linea === 'ABONO' ? 'ABONO' : l.tipo_linea === 'TITULO' ? 'TITULO' : 'ITEM',
    fecha: l.fecha,
    cantidad: l.cantidad,
    descripcion: l.descripcion,
    precioUnitario: l.precio_unitario,
    total: l.total_linea,
    metodoPago: l.metodo_pago,
  }));

  return (
    <FacturaLayout
      backTo={`/clientes/${cliente.id}`}
      etiqueta="ESTADO DE CUENTA"
      numero={cliente.factura_n ?? undefined}
      datosPdf={{
        etiqueta: 'ESTADO DE CUENTA',
        numero: cliente.factura_n ?? undefined,
        clienteNombre: cliente.nombre_cliente,
        clienteContacto: cliente.telefono ? `Tel: ${cliente.telefono}` : '—',
        items,
        totales: [
          { etiqueta: 'Total consumido', valor: cliente.total_cargado },
          { etiqueta: 'Total abonado', valor: cliente.total_abonado, prefijo: '− ' },
          { etiqueta: 'Saldo pendiente', valor: cliente.saldo_pendiente, destacado: true },
        ],
      }}
    >
      <div className="mb-4 grid grid-cols-2 gap-4 rounded border border-black/10 p-3">
        <div>
          <p className="text-[10px] font-bold uppercase tracking-wide text-black/50">Cliente</p>
          <p className="text-lg font-bold">{cliente.nombre_cliente}</p>
        </div>
        <div>
          <p className="text-[10px] font-bold uppercase tracking-wide text-black/50">Contacto</p>
          <p className="text-sm">{cliente.telefono ? `Tel: ${cliente.telefono}` : '—'}</p>
        </div>
      </div>

      {items.length === 0 ? (
        <p className="py-6 text-center text-sm text-black/50">Este cliente todavía no tiene movimientos.</p>
      ) : (
        <TablaFactura items={items} />
      )}

      <div className="mt-4 flex justify-end">
        <div className="w-full max-w-xs space-y-1 text-sm">
          <div className="flex justify-between">
            <span className="text-black/60">Total consumido</span>
            <span className="font-medium">{money(cliente.total_cargado)}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-black/60">Total abonado</span>
            <span className="font-medium text-[#1baf7a]">− {money(cliente.total_abonado)}</span>
          </div>
          <div className="mt-2 flex justify-between rounded bg-[#1d3f8f] px-3 py-2 text-white">
            <span className="text-xs font-bold uppercase tracking-wide">Saldo pendiente</span>
            <span className="font-display font-bold">{money(cliente.saldo_pendiente)}</span>
          </div>
        </div>
      </div>
    </FacturaLayout>
  );
}
