export const ICONOS_CATEGORIA: Record<string, string> = {
  FORD: '🔵',
  CHEVROLET: '🟡',
  TOYOTA: '🔴',
  HYUNDAI: '⚪',
  RENAULT: '🟠',
  CHERY: '🟣',
  FIAT: '🟤',
  'DONGFENG-JAC-FOTON': '🚛',
  'MACK-IVECO-ENCAVA': '🚚',
  'GENERICO-UNIVERSAL': '🔧',
  'ILUMINACION AUTOMOTRIZ': '💡',
  'SISTEMA ELECTRICO': '⚡',
  'CUIDADO Y ESTETICA': '🧴',
  'ACCESORIOS INT-EXT': '🎨',
};

export function iconoCategoria(categoria: string): string {
  return ICONOS_CATEGORIA[categoria.toUpperCase()] ?? '📦';
}
