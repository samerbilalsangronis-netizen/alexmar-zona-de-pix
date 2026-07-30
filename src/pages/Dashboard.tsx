import { Link } from 'react-router-dom';
import { useAuth } from '../lib/AuthContext';

const ITEMS = [
  {
    to: '/clientes',
    icono: '💳',
    color: 'border-l-[var(--good)]',
    titulo: 'ÍNDICE MAESTRO',
    detalle: 'Clientes, deudas y total en la calle ($)',
  },
  {
    to: '/catalogo',
    icono: '📦',
    color: 'border-l-[var(--accent-2)]',
    titulo: 'CATÁLOGO E INVENTARIO',
    detalle: 'Productos, costos, PVP y stock',
  },
  {
    to: '/rendimiento',
    icono: '📈',
    color: 'border-l-[var(--accent)]',
    titulo: 'RENDIMIENTO (BI)',
    detalle: 'Facturado, cobrado y ganancia neta ($)',
  },
  {
    to: '/notas',
    icono: '📝',
    color: 'border-l-[var(--accent)]',
    titulo: 'MIS NOTAS',
    detalle: 'Pizarra de pendientes, compras y recordatorios',
  },
  {
    to: '/facturacion',
    icono: '🧾',
    color: 'border-l-[var(--accent-2)]',
    titulo: 'FACTURACIÓN RÁPIDA',
    detalle: 'Factura, preforma o cotización para clientes ocasionales',
  },
];

export function Dashboard() {
  const { perfil, cerrarSesion } = useAuth();

  return (
    <div className="min-h-screen bg-[var(--bg)] pb-16">
      <header className="border-b border-[var(--border)] px-6 py-6">
        <div className="flex items-start justify-between">
          <div>
            <p className="font-display text-xs text-[var(--accent)]">MODO JEFE</p>
            <p className="font-display text-2xl text-white/40">Zona De Pix</p>
          </div>
          <button onClick={cerrarSesion} className="text-xl text-[var(--accent)] hover:opacity-80" title="Cerrar sesión">
            ⏻
          </button>
        </div>
        <p className="mt-4 font-display text-xs text-[var(--accent-2)]">
          OPERADOR: {(perfil?.nombre_completo || '').toUpperCase() || '—'}
        </p>
        <h1 className="mt-1 font-display text-3xl text-white">Panel de control general</h1>
      </header>

      <nav className="mx-auto max-w-3xl divide-y divide-[var(--border)] px-4">
        {ITEMS.map((item) => (
          <Link
            key={item.to}
            to={item.to}
            className={`flex items-center justify-between gap-4 border-l-4 ${item.color} px-4 py-5 hover:bg-[var(--surface-1)]`}
          >
            <div className="flex items-center gap-4">
              <span className="text-xl">{item.icono}</span>
              <div>
                <p className="font-display text-sm text-white">{item.titulo}</p>
                <p className="text-xs text-[var(--text-muted)]">{item.detalle}</p>
              </div>
            </div>
            <span className="text-[var(--text-muted)]">›</span>
          </Link>
        ))}
      </nav>
    </div>
  );
}
