import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../lib/AuthContext';
import { supabaseConfigurado } from '../lib/supabaseClient';

export function ProtectedRoute() {
  const { cargando, sesion } = useAuth();

  if (!supabaseConfigurado) {
    return (
      <div className="flex h-screen items-center justify-center bg-[var(--bg)] p-6 text-center text-[var(--text-secondary)]">
        <div>
          <p className="font-display text-lg text-[var(--accent)]">FALTA CONFIGURAR SUPABASE</p>
          <p className="mt-2 text-sm">
            Creá <code>.env.local</code> con <code>VITE_SUPABASE_URL</code> y{' '}
            <code>VITE_SUPABASE_ANON_KEY</code> (ver README).
          </p>
        </div>
      </div>
    );
  }

  if (cargando) {
    return <div className="flex h-screen items-center justify-center text-[var(--text-secondary)]">Cargando…</div>;
  }

  if (!sesion) return <Navigate to="/login" replace />;

  return <Outlet />;
}
