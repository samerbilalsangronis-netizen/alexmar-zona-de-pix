import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { Screen } from '../components/Screen';
import { supabase } from '../lib/supabaseClient';
import { money } from '../lib/format';
import { CATEGORIAS_INVENTARIO, type Producto } from '../types';

export function Catalogo() {
  const [productos, setProductos] = useState<Producto[]>([]);
  const [cargando, setCargando] = useState(true);
  const [busqueda, setBusqueda] = useState('');
  const [categoria, setCategoria] = useState('TODAS');
  const [mostrarForm, setMostrarForm] = useState(false);

  async function cargar() {
    setCargando(true);
    const { data } = await supabase.from('inventario').select('*').eq('eliminado', false).order('nombre_producto');
    setProductos((data as Producto[]) ?? []);
    setCargando(false);
  }

  useEffect(() => {
    cargar();
    const canal = supabase
      .channel('inventario-realtime')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'inventario' }, cargar)
      .subscribe();
    return () => {
      supabase.removeChannel(canal);
    };
  }, []);

  const filtrados = useMemo(() => {
    return productos.filter((p) => {
      if (categoria !== 'TODAS' && !p.categoria_tags.toUpperCase().includes(categoria)) return false;
      const q = busqueda.trim().toLowerCase();
      if (q && !p.nombre_producto.toLowerCase().includes(q)) return false;
      return true;
    });
  }, [productos, busqueda, categoria]);

  const enAlerta = productos.filter((p) => p.stock_actual <= p.stock_minimo && p.stock_minimo > 0).length;

  return (
    <Screen
      title="Catálogo"
      backTo="/"
      actions={
        <div className="flex items-center gap-2">
          {enAlerta > 0 && <span className="rounded border border-[var(--bad)] px-2 py-0.5 text-xs text-[var(--bad)]">{enAlerta} en alerta</span>}
          <button onClick={() => setMostrarForm((v) => !v)} className="rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black">
            + Producto
          </button>
        </div>
      }
    >
      {mostrarForm && <NuevoProductoForm onCreado={() => { setMostrarForm(false); cargar(); }} />}

      <div className="mt-4 grid gap-2 sm:grid-cols-2">
        <input placeholder="Buscar…" value={busqueda} onChange={(e) => setBusqueda(e.target.value)} />
        <select value={categoria} onChange={(e) => setCategoria(e.target.value)}>
          <option value="TODAS">Todas las categorías</option>
          {CATEGORIAS_INVENTARIO.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
      </div>

      <div className="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {cargando && <p className="text-sm text-[var(--text-muted)]">Cargando…</p>}
        {!cargando && filtrados.length === 0 && <p className="text-sm text-[var(--text-muted)]">No hay productos que coincidan.</p>}
        {filtrados.map((p) => {
          const agotado = p.stock_actual <= 0;
          const alerta = !agotado && p.stock_minimo > 0 && p.stock_actual <= p.stock_minimo;
          return (
            <div key={p.id} className="rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-3">
              <div className="flex items-center justify-between">
                <span
                  className={`rounded border px-2 py-0.5 text-xs font-bold ${
                    agotado ? 'border-[var(--bad)] text-[var(--bad)]' : alerta ? 'border-[var(--warn)] text-[var(--warn)]' : 'border-[var(--good)] text-[var(--good)]'
                  }`}
                >
                  {agotado ? 'AGOTADO' : `STOCK ${p.stock_actual}`}
                </span>
              </div>
              <p className="mt-2 font-bold text-white">{p.nombre_producto}</p>
              <p className="text-xs text-[var(--text-muted)]">{p.categoria_tags} · {p.compatibilidad_vehiculos}</p>
              <p className="mt-2 font-display text-[var(--accent-2)]">{p.pvp ? money(p.pvp) : 'SIN PRECIO'}</p>
            </div>
          );
        })}
      </div>
    </Screen>
  );
}

function NuevoProductoForm({ onCreado }: { onCreado: () => void }) {
  const [nombre, setNombre] = useState('');
  const [categoria, setCategoria] = useState<string>(CATEGORIAS_INVENTARIO[0]);
  const [pvp, setPvp] = useState('');
  const [costo, setCosto] = useState('');
  const [stock, setStock] = useState('0');
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar(e: FormEvent) {
    e.preventDefault();
    if (!nombre.trim()) return;
    setGuardando(true);
    setError(null);
    const { error } = await supabase.from('inventario').insert({
      nombre_producto: nombre.trim(),
      categoria_tags: categoria,
      pvp: pvp ? Number(pvp) : null,
      costo: costo ? Number(costo) : null,
      stock_actual: Number(stock) || 0,
    });
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    setNombre('');
    setPvp('');
    setCosto('');
    setStock('0');
    onCreado();
  }

  return (
    <form onSubmit={guardar} className="mt-4 rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
      <p className="font-display text-sm text-white">Nuevo producto</p>
      <div className="mt-3 grid gap-3 sm:grid-cols-2">
        <input placeholder="Nombre *" required value={nombre} onChange={(e) => setNombre(e.target.value)} className="sm:col-span-2" />
        <select value={categoria} onChange={(e) => setCategoria(e.target.value)}>
          {CATEGORIAS_INVENTARIO.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
        <input type="number" min="0" placeholder="Stock" value={stock} onChange={(e) => setStock(e.target.value)} />
        <input type="number" min="0" step="0.01" placeholder="Precio público" value={pvp} onChange={(e) => setPvp(e.target.value)} />
        <input type="number" min="0" step="0.01" placeholder="Precio compra" value={costo} onChange={(e) => setCosto(e.target.value)} />
      </div>
      {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}
      <button disabled={guardando} className="mt-3 rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black disabled:opacity-50">
        {guardando ? 'Guardando…' : 'Guardar producto'}
      </button>
    </form>
  );
}
