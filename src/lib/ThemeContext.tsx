import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';

type Tema = 'dark' | 'light';
const CLAVE = 'alexmar_tema';

interface ThemeState {
  tema: Tema;
  alternar: () => void;
}

const ThemeContext = createContext<ThemeState | null>(null);

function temaGuardado(): Tema {
  const guardado = localStorage.getItem(CLAVE);
  return guardado === 'light' ? 'light' : 'dark';
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [tema, setTema] = useState<Tema>(temaGuardado);

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', tema);
    localStorage.setItem(CLAVE, tema);
  }, [tema]);

  const alternar = () => setTema((t) => (t === 'dark' ? 'light' : 'dark'));

  return <ThemeContext.Provider value={{ tema, alternar }}>{children}</ThemeContext.Provider>;
}

export function useTheme(): ThemeState {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme debe usarse dentro de <ThemeProvider>');
  return ctx;
}
