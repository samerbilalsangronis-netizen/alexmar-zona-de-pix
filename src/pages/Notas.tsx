import { useEffect, useState, type FormEvent } from 'react';
import { Screen } from '../components/Screen';
import { supabase } from '../lib/supabaseClient';
import type { Nota } from '../types';

const COLORES: Record<string, string> = {
  NARANJA: 'border-[var(--accent)]',
  CYAN: 'border-[var(--accent-2)]',
  VERDE: 'border-[var(--good)]',
  AMARILLO: 'border-[var(--warn)]',
};

export function Notas() {
  const [notas, setNotas] = useState<Nota[]>([]);
  const [titulo, setTitulo] = useState('');
  const [contenido, setContenido] = useState('');
  const [color, setColor] = useState('NARANJA');
  const [editando, setEditando] = useState<string | null>(null);

  async function cargar() {
    const { data } = await supabase.from('notas').select('*').eq('eliminado', false).order('created_at', { ascending: false });
    setNotas((data as Nota[]) ?? []);
  }

  useEffect(() => {
    cargar();
    const canal = supabase
      .channel('notas-realtime')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'notas' }, cargar)
      .subscribe();
    return () => {
      supabase.removeChannel(canal);
    };
  }, []);

  async function agregar(e: FormEvent) {
    e.preventDefault();
    if (!titulo.trim() && !contenido.trim()) return;
    await supabase.from('notas').insert({ titulo: titulo.trim() || null, contenido: contenido.trim() || null, color });
    setTitulo('');
    setContenido('');
    cargar();
  }

  async function borrar(id: string) {
    if (!confirm('¿Eliminar esta nota?')) return;
    await supabase.from('notas').update({ eliminado: true }).eq('id', id);
    cargar();
  }

  return (
    <Screen title="Mis Notas" backTo="/">
      <form onSubmit={agregar} className="rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-4">
        <input placeholder="Título" value={titulo} onChange={(e) => setTitulo(e.target.value)} className="w-full" />
        <textarea placeholder="Contenido…" value={contenido} onChange={(e) => setContenido(e.target.value)} className="mt-2 w-full" rows={2} />
        <div className="mt-2 flex items-center justify-between">
          <div className="flex gap-2">
            {Object.keys(COLORES).map((c) => (
              <button
                type="button"
                key={c}
                onClick={() => setColor(c)}
                className={`h-6 w-6 rounded-full border-2 ${COLORES[c]} ${color === c ? 'ring-2 ring-[var(--text-primary)]' : ''}`}
              />
            ))}
          </div>
          <button className="rounded bg-[var(--accent)] px-3 py-1.5 text-sm font-bold text-black">Agregar nota</button>
        </div>
      </form>

      <div className="mt-4 grid gap-3 sm:grid-cols-2">
        {notas.map((n) =>
          editando === n.id ? (
            <NotaEditar key={n.id} nota={n} onCancelar={() => setEditando(null)} onGuardado={() => { setEditando(null); cargar(); }} />
          ) : (
            <div key={n.id} className={`rounded-lg border-l-4 ${COLORES[n.color] ?? COLORES.NARANJA} border border-[var(--border)] bg-[var(--surface-1)] p-3`}>
              <div className="flex items-start justify-between gap-2">
                {n.titulo && <p className="font-bold text-[var(--text-primary)]">{n.titulo}</p>}
                <div className="ml-auto flex shrink-0 gap-2">
                  <button onClick={() => setEditando(n.id)} className="text-xs text-[var(--text-muted)] hover:text-[var(--text-primary)]" title="Editar">
                    ✏️
                  </button>
                  <button onClick={() => borrar(n.id)} className="text-xs text-[var(--text-muted)] hover:text-[var(--bad)]" title="Eliminar">
                    ✕
                  </button>
                </div>
              </div>
              {n.contenido && <p className="mt-1 whitespace-pre-wrap text-sm text-[var(--text-secondary)]">{n.contenido}</p>}
            </div>
          ),
        )}
      </div>
    </Screen>
  );
}

function NotaEditar({ nota, onCancelar, onGuardado }: { nota: Nota; onCancelar: () => void; onGuardado: () => void }) {
  const [titulo, setTitulo] = useState(nota.titulo ?? '');
  const [contenido, setContenido] = useState(nota.contenido ?? '');
  const [color, setColor] = useState(nota.color);
  const [guardando, setGuardando] = useState(false);

  async function guardar() {
    setGuardando(true);
    await supabase
      .from('notas')
      .update({ titulo: titulo.trim() || null, contenido: contenido.trim() || null, color })
      .eq('id', nota.id);
    setGuardando(false);
    onGuardado();
  }

  return (
    <div className={`rounded-lg border-l-4 ${COLORES[color] ?? COLORES.NARANJA} border border-[var(--accent)] bg-[var(--surface-1)] p-3`}>
      <input placeholder="Título" value={titulo} onChange={(e) => setTitulo(e.target.value)} className="w-full" />
      <textarea placeholder="Contenido…" value={contenido} onChange={(e) => setContenido(e.target.value)} className="mt-2 w-full" rows={2} />
      <div className="mt-2 flex items-center justify-between">
        <div className="flex gap-2">
          {Object.keys(COLORES).map((c) => (
            <button
              key={c}
              onClick={() => setColor(c)}
              className={`h-6 w-6 rounded-full border-2 ${COLORES[c]} ${color === c ? 'ring-2 ring-[var(--text-primary)]' : ''}`}
            />
          ))}
        </div>
        <div className="flex gap-2">
          <button onClick={onCancelar} className="rounded border border-[var(--border)] px-3 py-1.5 text-xs font-bold text-[var(--text-secondary)]">
            Cancelar
          </button>
          <button
            onClick={guardar}
            disabled={guardando}
            className="rounded bg-[var(--accent)] px-3 py-1.5 text-xs font-bold text-black disabled:opacity-50"
          >
            {guardando ? 'Guardando…' : 'Guardar'}
          </button>
        </div>
      </div>
    </div>
  );
}
