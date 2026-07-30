import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { Screen } from '../components/Screen';
import { ImagenInput } from '../components/ImagenInput';
import { ProductoDetalle } from '../components/ProductoDetalle';
import { supabase } from '../lib/supabaseClient';
import { money } from '../lib/format';
import { iconoCategoria } from '../lib/categorias';
import { CATEGORIAS_INVENTARIO, type Producto } from '../types';

export function Catalogo() {
  const [productos, setProductos] = useState<Producto[]>([]);
  const [cargando, setCargando] = useState(true);
  const [busqueda, setBusqueda] = useState('');
  const [categoriaActual, setCategoriaActual] = useState<string | null>(null);
  const [mostrarForm, setMostrarForm] = useState(false);
  const [productoEditar, setProductoEditar] = useState<Producto | null>(null);

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

  // Al cambiar de carpeta, la búsqueda no debería arrastrarse de un contexto al otro.
  function irACategoria(cat: string | null) {
    setCategoriaActual(cat);
    setBusqueda('');
  }

  const q = busqueda.trim().toLowerCase();

  const productosVisibles = useMemo(() => {
    let lista = productos;
    if (categoriaActual) lista = lista.filter((p) => p.categoria_tags.toUpperCase() === categoriaActual);
    if (q) lista = lista.filter((p) => p.nombre_producto.toLowerCase().includes(q));
    return lista;
  }, [productos, categoriaActual, q]);

  // Búsqueda global (sin carpeta elegida) muestra resultados de todo el inventario.
  const buscandoGlobal = !categoriaActual && q.length > 0;

  const conteosPorCategoria = useMemo(() => {
    const mapa = new Map<string, { total: number; alerta: number }>();
    for (const p of productos) {
      const cat = p.categoria_tags.toUpperCase();
      const actual = mapa.get(cat) ?? { total: 0, alerta: 0 };
      actual.total++;
      if (p.stock_actual <= 0 || (p.stock_minimo > 0 && p.stock_actual <= p.stock_minimo)) actual.alerta++;
      mapa.set(cat, actual);
    }
    return mapa;
  }, [productos]);

  const enAlertaGlobal = productos.filter((p) => p.stock_actual <= p.stock_minimo && p.stock_minimo > 0).length;

  return (
    <Screen
      title={categoriaActual ?? 'Catálogo'}
      backTo={categoriaActual ? undefined : '/'}
      actions={
        <div className="flex items-center gap-2">
          {categoriaActual && (
            <button onClick={() => irACategoria(null)} className="text-xs text-[var(--accent-2)] hover:underline">
              ← Categorías
            </button>
          )}
          {!categoriaActual && enAlertaGlobal > 0 && (
            <span className="rounded border border-[var(--bad)] px-2 py-0.5 text-xs text-[var(--bad)]">{enAlertaGlobal} en alerta</span>
          )}
          <button onClick={() => setMostrarForm((v) => !v)} className="rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black">
            + Producto
          </button>
        </div>
      }
    >
      {mostrarForm && (
        <NuevoProductoForm
          categoriaInicial={categoriaActual ?? CATEGORIAS_INVENTARIO[0]}
          onCreado={() => {
            setMostrarForm(false);
            cargar();
          }}
        />
      )}

      <input
        className="mt-4 w-full"
        placeholder={categoriaActual ? `Buscar en ${categoriaActual}…` : 'Buscar en todo el inventario…'}
        value={busqueda}
        onChange={(e) => setBusqueda(e.target.value)}
      />

      {cargando && <p className="mt-4 text-sm text-[var(--text-muted)]">Cargando…</p>}

      {!cargando && !categoriaActual && !buscandoGlobal && (
        <div className="mt-4 grid gap-3 sm:grid-cols-2">
          {CATEGORIAS_INVENTARIO.map((cat) => {
            const info = conteosPorCategoria.get(cat);
            return (
              <button
                key={cat}
                onClick={() => irACategoria(cat)}
                className="flex items-center justify-between rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4 text-left hover:border-[var(--accent)]"
              >
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{iconoCategoria(cat)}</span>
                  <div>
                    <p className="font-bold text-white">{cat}</p>
                    <p className="text-xs text-[var(--text-muted)]">{info?.total ?? 0} producto(s)</p>
                  </div>
                </div>
                {info && info.alerta > 0 && (
                  <span className="rounded border border-[var(--bad)] px-1.5 py-0.5 text-[10px] text-[var(--bad)]">{info.alerta}</span>
                )}
              </button>
            );
          })}
        </div>
      )}

      {!cargando && (categoriaActual || buscandoGlobal) && (
        <div className="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {productosVisibles.length === 0 && <p className="text-sm text-[var(--text-muted)]">No hay productos que coincidan.</p>}
          {productosVisibles.map((p) => {
            const agotado = p.stock_actual <= 0;
            const alerta = !agotado && p.stock_minimo > 0 && p.stock_actual <= p.stock_minimo;
            return (
              <button
                key={p.id}
                onClick={() => setProductoEditar(p)}
                className="flex gap-3 rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-3 text-left hover:border-[var(--accent)]"
              >
                <div className="h-16 w-16 shrink-0 overflow-hidden rounded bg-[var(--surface-2)]">
                  {p.url_foto ? (
                    <img src={p.url_foto} alt="" className="h-full w-full object-cover" />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center text-xl">{iconoCategoria(p.categoria_tags)}</div>
                  )}
                </div>
                <div className="min-w-0 flex-1">
                  <span
                    className={`rounded border px-1.5 py-0.5 text-[10px] font-bold ${
                      agotado ? 'border-[var(--bad)] text-[var(--bad)]' : alerta ? 'border-[var(--warn)] text-[var(--warn)]' : 'border-[var(--good)] text-[var(--good)]'
                    }`}
                  >
                    {agotado ? 'AGOTADO' : `STOCK ${p.stock_actual}`}
                  </span>
                  <p className="mt-1 truncate font-bold text-white">{p.nombre_producto}</p>
                  {buscandoGlobal && <p className="truncate text-xs text-[var(--text-muted)]">{p.categoria_tags}</p>}
                  <p className="mt-0.5 font-display text-sm text-[var(--accent-2)]">{p.pvp ? money(p.pvp) : 'SIN PRECIO'}</p>
                </div>
              </button>
            );
          })}
        </div>
      )}

      {productoEditar && (
        <ProductoDetalle producto={productoEditar} onCerrar={() => setProductoEditar(null)} onGuardado={cargar} />
      )}
    </Screen>
  );
}

function NuevoProductoForm({ categoriaInicial, onCreado }: { categoriaInicial: string; onCreado: () => void }) {
  const [nombre, setNombre] = useState('');
  const [categoria, setCategoria] = useState<string>(categoriaInicial);
  const [pvp, setPvp] = useState('');
  const [costo, setCosto] = useState('');
  const [stock, setStock] = useState('0');
  const [urlFoto, setUrlFoto] = useState<string | null>(null);
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
      url_foto: urlFoto,
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
    setUrlFoto(null);
    onCreado();
  }

  return (
    <form onSubmit={guardar} className="mt-4 rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
      <p className="font-display text-sm text-white">Nuevo producto</p>
      <div className="mt-3 flex gap-4">
        <ImagenInput url={urlFoto} onSubido={setUrlFoto} />
        <div className="flex-1 space-y-3">
          <input placeholder="Nombre *" required value={nombre} onChange={(e) => setNombre(e.target.value)} className="w-full" />
          <select value={categoria} onChange={(e) => setCategoria(e.target.value)} className="w-full">
            {CATEGORIAS_INVENTARIO.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>
        </div>
      </div>
      <div className="mt-3 grid gap-3 sm:grid-cols-3">
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
