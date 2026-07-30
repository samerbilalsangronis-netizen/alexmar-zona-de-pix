import type { ReactNode } from 'react';
import { Link } from 'react-router-dom';
import { ThemeToggle } from './ThemeToggle';

interface ScreenProps {
  title: string;
  backTo?: string;
  actions?: ReactNode;
  children: ReactNode;
}

export function Screen({ title, backTo, actions, children }: ScreenProps) {
  return (
    <div className="min-h-screen bg-[var(--bg)] pb-24">
      <header className="sticky top-0 z-10 flex items-center justify-between border-b border-[var(--border)] bg-[var(--bg)]/95 px-4 py-3 backdrop-blur">
        <div className="flex items-center gap-3">
          {backTo && (
            <Link to={backTo} className="text-xl text-[var(--accent-2)] hover:opacity-80">
              ←
            </Link>
          )}
          <h1 className="font-display text-lg uppercase text-[var(--text-primary)]">{title}</h1>
        </div>
        <div className="flex items-center gap-3">
          {actions}
          <ThemeToggle />
        </div>
      </header>
      <main className="mx-auto max-w-5xl px-4 py-4">{children}</main>
    </div>
  );
}
