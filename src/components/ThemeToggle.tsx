import { useTheme } from '../lib/ThemeContext';

export function ThemeToggle() {
  const { tema, alternar } = useTheme();
  return (
    <button
      onClick={alternar}
      title={tema === 'dark' ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro'}
      className="text-lg text-[var(--text-muted)] hover:text-[var(--text-primary)]"
    >
      {tema === 'dark' ? '☀️' : '🌙'}
    </button>
  );
}
