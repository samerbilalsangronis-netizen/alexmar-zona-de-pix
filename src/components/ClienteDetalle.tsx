import { useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import type { Cliente } from '../types';

interface ClienteDetalleProps {
  cliente: Cliente;
  onCerrar: () => void;
  onGuardado: () => void;
}

export function ClienteDetalle({ cliente, onCerrar, onGuardado }: ClienteDetalleProps) {
  const [nombre, setNombre] = useState(cliente.nombre_cliente);
  const [cedula, setCedula] = useState(cliente.cedula ?? '');
  const [telefono, setTelefono] = useState(cliente.telefono ?? '');
  const [direccion, setDireccion] = useState(cliente.direccion ?? '');
  const [facturaN, setFacturaN] = useState(cliente.factura_n ?? '');
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function guardar() {
    if (!nombre.trim()) {
      setError('El nombre no puede estar vacío.');
      return;
    }
    setGuardando(true);
    setError(null);
    const { error } = await supabase
      .from('clientes')
      .update({
        nombre_cliente: nombre.trim(),
        cedula: cedula.trim() || null,
        telefono: telefono.trim() || null,
        direccion: direccion.trim() || null,
        factura_n: facturaN.trim() || null,
      })
      .eq('id', cliente.id);
    setGuardando(false);
    if (error) {
      setError(error.message);
      return;
    }
    onGuardado();
    onCerrar();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/70 sm:items-center" onClick={onCerrar}>
      <div
        className="w-full max-w-md rounded-t-2xl border border-[var(--border)] bg-[var(--surface-1)] p-4 sm:rounded-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between">
          <p className="font-display text-sm text-[var(--text-primary)]">Editar cliente</p>
          <button onClick={onCerrar} className="text-xl text-[var(--text-muted)] hover:text-[var(--text-primary)]">
            ✕
          </button>
        </div>

        <div className="mt-4 space-y-3">
          <div>
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Nombre *</label>
            <input value={nombre} onChange={(e) => setNombre(e.target.value)} className="mt-1 w-full" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs uppercase text-[var(--text-secondary)]">Cédula</label>
              <input value={cedula} onChange={(e) => setCedula(e.target.value)} className="mt-1 w-full" />
            </div>
            <div>
              <label className="block text-xs uppercase text-[var(--text-secondary)]">Teléfono</label>
              <input value={telefono} onChange={(e) => setTelefono(e.target.value)} className="mt-1 w-full" />
            </div>
          </div>
          <div>
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Dirección</label>
            <input value={direccion} onChange={(e) => setDireccion(e.target.value)} className="mt-1 w-full" />
          </div>
          <div>
            <label className="block text-xs uppercase text-[var(--text-secondary)]">Nº de factura/hoja</label>
            <input value={facturaN} onChange={(e) => setFacturaN(e.target.value)} className="mt-1 w-full" />
          </div>
        </div>

        {error && <p className="mt-2 text-sm text-[var(--bad)]">{error}</p>}

        <button
          onClick={guardar}
          disabled={guardando}
          className="mt-4 w-full rounded bg-[var(--accent)] py-2 text-sm font-bold text-black disabled:opacity-50"
        >
          {guardando ? 'Guardando…' : 'Guardar cambios'}
        </button>
      </div>
    </div>
  );
}
