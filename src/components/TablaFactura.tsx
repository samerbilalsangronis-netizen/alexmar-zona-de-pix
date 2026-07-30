import { money, fecha } from '../lib/format';

export interface ItemFactura {
  tipo: 'ITEM' | 'ABONO' | 'TITULO';
  fecha?: string | null;
  cantidad?: number | null;
  descripcion: string;
  precioUnitario?: number | null;
  total: number;
  metodoPago?: string | null;
}

export function TablaFactura({ items }: { items: ItemFactura[] }) {
  return (
    <table className="w-full border-collapse text-sm">
      <thead>
        <tr className="bg-black text-white">
          <th className="px-2 py-2 text-left text-xs font-bold uppercase">Fecha</th>
          <th className="px-2 py-2 text-left text-xs font-bold uppercase">Cant.</th>
          <th className="px-2 py-2 text-left text-xs font-bold uppercase">Producto / Servicio</th>
          <th className="px-2 py-2 text-right text-xs font-bold uppercase">P. Unit.</th>
          <th className="px-2 py-2 text-right text-xs font-bold uppercase">P. Total</th>
        </tr>
      </thead>
      <tbody>
        {items.map((it, i) => {
          if (it.tipo === 'TITULO') {
            return (
              <tr key={i}>
                <td colSpan={5} className="bg-[var(--accent)] px-2 py-1 text-center text-xs font-bold uppercase text-black">
                  « {it.descripcion} »
                </td>
              </tr>
            );
          }
          const esAbono = it.tipo === 'ABONO';
          return (
            <tr key={i} className={`border-b border-black/10 ${esAbono ? 'bg-[#e8f8ef]' : ''}`}>
              <td className="px-2 py-1.5 whitespace-nowrap">{it.fecha ? fecha(it.fecha) : ''}</td>
              <td className="px-2 py-1.5">{esAbono ? '' : it.cantidad}</td>
              <td className="px-2 py-1.5">
                {esAbono ? `ABONO${it.metodoPago ? ` · ${it.metodoPago}` : ''}${it.descripcion && it.descripcion !== 'Abono' ? ` — ${it.descripcion}` : ''}` : it.descripcion}
              </td>
              <td className="px-2 py-1.5 text-right">{esAbono ? '' : it.precioUnitario ? money(it.precioUnitario) : ''}</td>
              <td className={`px-2 py-1.5 text-right font-medium ${esAbono ? 'text-[#1baf7a]' : ''}`}>
                {esAbono ? '− ' : ''}
                {money(it.total)}
              </td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}
