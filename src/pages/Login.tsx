import { useState, type FormEvent } from 'react';
import { Navigate } from 'react-router-dom';
import { supabase, supabaseConfigurado } from '../lib/supabaseClient';
import { useAuth } from '../lib/AuthContext';

export function Login() {
  const { sesion } = useAuth();
  const [usuario, setUsuario] = useState('');
  const [clave, setClave] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);

  if (sesion) return <Navigate to="/" replace />;

  async function entrar(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setEnviando(true);
    const { error } = await supabase.auth.signInWithPassword({ email: usuario, password: clave });
    setEnviando(false);
    if (error) setError('Usuario o contraseña incorrectos.');
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-[var(--bg)] px-4">
      <form onSubmit={entrar} className="w-full max-w-sm rounded-lg border border-[var(--border)] bg-[var(--surface-1)] p-6">
        <p className="font-display text-sm text-[var(--accent)]">MODO JEFE</p>
        <h1 className="mt-1 font-display text-2xl text-white">Zona De Pix</h1>
        <p className="mt-1 text-sm text-[var(--text-muted)]">Escudería Alexmar</p>

        {!supabaseConfigurado && (
          <p className="mt-4 rounded border border-[var(--warn)] px-3 py-2 text-xs text-[var(--warn)]">
            Supabase no está configurado (ver README).
          </p>
        )}

        <label className="mt-6 block text-xs uppercase text-[var(--text-secondary)]">Correo</label>
        <input
          type="email"
          required
          value={usuario}
          onChange={(e) => setUsuario(e.target.value)}
          className="mt-1 w-full"
          placeholder="tucorreo@ejemplo.com"
        />

        <label className="mt-4 block text-xs uppercase text-[var(--text-secondary)]">Contraseña</label>
        <input
          type="password"
          required
          value={clave}
          onChange={(e) => setClave(e.target.value)}
          className="mt-1 w-full"
        />

        {error && <p className="mt-3 text-sm text-[var(--bad)]">{error}</p>}

        <button
          type="submit"
          disabled={enviando}
          className="mt-6 w-full rounded bg-[var(--accent)] py-2 font-bold text-black hover:opacity-90 disabled:opacity-50"
        >
          {enviando ? 'Entrando…' : 'ENTRAR'}
        </button>
      </form>
    </div>
  );
}
