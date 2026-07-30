import { useRef, type KeyboardEvent } from 'react';

export interface FilaGrid {
  cantidad: string;
  descripcion: string;
  precio: string;
}

export function filaVacia(): FilaGrid {
  return { cantidad: '1', descripcion: '', precio: '' };
}

interface GrillaItemsProps {
  filas: FilaGrid[];
  onCambiar: (filas: FilaGrid[]) => void;
  filasPorTanda?: number;
}

/** Grilla estilo planilla: navegación con las flechas del teclado entre casillas. */
export function GrillaItems({ filas, onCambiar, filasPorTanda = 8 }: GrillaItemsProps) {
  const refs = useRef<(HTMLInputElement | null)[][]>([]);

  function actualizar(fila: number, campo: keyof FilaGrid, valor: string) {
    onCambiar(filas.map((f, i) => (i === fila ? { ...f, [campo]: valor } : f)));
  }

  function moverFoco(fila: number, col: number) {
    const destino = refs.current[fila]?.[col];
    destino?.focus();
    destino?.select();
  }

  function alPresionarTecla(e: KeyboardEvent<HTMLInputElement>, fila: number, col: number) {
    const totalFilas = filas.length;
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (fila + 1 < totalFilas) moverFoco(fila + 1, col);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (fila - 1 >= 0) moverFoco(fila - 1, col);
    } else if (e.key === 'ArrowRight') {
      const input = e.currentTarget;
      if (input.selectionStart === input.value.length) {
        if (col + 1 < 3) {
          e.preventDefault();
          moverFoco(fila, col + 1);
        } else if (fila + 1 < totalFilas) {
          e.preventDefault();
          moverFoco(fila + 1, 0);
        }
      }
    } else if (e.key === 'ArrowLeft') {
      const input = e.currentTarget;
      if (input.selectionStart === 0) {
        if (col - 1 >= 0) {
          e.preventDefault();
          moverFoco(fila, col - 1);
        } else if (fila - 1 >= 0) {
          e.preventDefault();
          moverFoco(fila - 1, 2);
        }
      }
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (fila + 1 < totalFilas) moverFoco(fila + 1, col);
      else agregarFilas();
    }
  }

  function agregarFilas() {
    onCambiar([...filas, ...Array.from({ length: filasPorTanda }, filaVacia)]);
  }

  return (
    <>
      <div className="mt-3 overflow-x-auto">
        <table className="w-full min-w-[420px] border-separate border-spacing-y-1 text-sm">
          <thead>
            <tr className="text-left text-xs text-[var(--text-muted)]">
              <th className="w-16 px-1 font-normal">Cant.</th>
              <th className="px-1 font-normal">Producto o servicio</th>
              <th className="w-28 px-1 font-normal">Precio unit.</th>
            </tr>
          </thead>
          <tbody>
            {filas.map((f, fila) => {
              if (!refs.current[fila]) refs.current[fila] = [null, null, null];
              return (
                <tr key={fila}>
                  <td className="px-1">
                    <input
                      ref={(el) => {
                        refs.current[fila][0] = el;
                      }}
                      value={f.cantidad}
                      onChange={(e) => actualizar(fila, 'cantidad', e.target.value)}
                      onKeyDown={(e) => alPresionarTecla(e, fila, 0)}
                      type="number"
                      min="0"
                      className="w-full"
                    />
                  </td>
                  <td className="px-1">
                    <input
                      ref={(el) => {
                        refs.current[fila][1] = el;
                      }}
                      value={f.descripcion}
                      onChange={(e) => actualizar(fila, 'descripcion', e.target.value)}
                      onKeyDown={(e) => alPresionarTecla(e, fila, 1)}
                      className="w-full"
                    />
                  </td>
                  <td className="px-1">
                    <input
                      ref={(el) => {
                        refs.current[fila][2] = el;
                      }}
                      value={f.precio}
                      onChange={(e) => actualizar(fila, 'precio', e.target.value)}
                      onKeyDown={(e) => alPresionarTecla(e, fila, 2)}
                      type="number"
                      min="0"
                      step="0.01"
                      className="w-full"
                    />
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      <button type="button" onClick={agregarFilas} className="mt-2 text-xs text-[var(--accent-2)] hover:underline">
        + más filas
      </button>
    </>
  );
}
