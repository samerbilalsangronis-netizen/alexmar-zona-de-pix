export type Rol = 'ADMIN' | 'VENDEDOR';

export interface Perfil {
  id: string;
  nombre_completo: string;
  rol: Rol;
  activo: boolean;
}

export interface Cliente {
  id: string;
  cedula: string | null;
  nombre_cliente: string;
  telefono: string | null;
  direccion: string | null;
  factura_n: string | null;
  fecha_ultimo_abono: string | null;
  eliminado: boolean;
  total_cargado: number;
  total_abonado: number;
  saldo_pendiente: number;
}

export type TipoLinea = 'CARGO' | 'ABONO' | 'TITULO';

export interface LineaCuenta {
  id: string;
  id_cliente: string;
  tipo_linea: TipoLinea;
  fecha: string;
  cantidad: number;
  descripcion: string;
  precio_unitario: number | null;
  costo_unitario: number | null;
  total_linea: number;
  id_producto: string | null;
  eliminado: boolean;
  created_at: string;
}

export interface Producto {
  id: string;
  nombre_producto: string;
  descripcion: string | null;
  categoria_tags: string;
  compatibilidad_vehiculos: string;
  costo: number | null;
  pvp: number | null;
  stock_actual: number;
  stock_minimo: number;
  url_foto: string | null;
  eliminado: boolean;
}

export interface Nota {
  id: string;
  titulo: string | null;
  contenido: string | null;
  color: string;
  eliminado: boolean;
  created_at: string;
}

export const CATEGORIAS_INVENTARIO = [
  'FORD',
  'CHEVROLET',
  'TOYOTA',
  'HYUNDAI',
  'RENAULT',
  'CHERY',
  'FIAT',
  'DONGFENG-JAC-FOTON',
  'MACK-IVECO-ENCAVA',
  'GENERICO-UNIVERSAL',
  'ILUMINACION AUTOMOTRIZ',
  'SISTEMA ELECTRICO',
  'CUIDADO Y ESTETICA',
  'ACCESORIOS INT-EXT',
] as const;

/** Estatus de cartera según hace cuánto abonó el cliente por última vez. */
export type EstatusCartera = 'AL_DIA' | 'REVISAR' | 'MORA';

export function calcularEstatus(fechaUltimoAbono: string | null, saldoPendiente: number): EstatusCartera {
  if (saldoPendiente <= 0) return 'AL_DIA';
  if (!fechaUltimoAbono) return 'MORA';
  const dias = Math.floor((Date.now() - new Date(fechaUltimoAbono).getTime()) / 86_400_000);
  if (dias <= 15) return 'AL_DIA';
  if (dias <= 27) return 'REVISAR';
  return 'MORA';
}

export function diasDesde(fechaIso: string | null): number | null {
  if (!fechaIso) return null;
  return Math.floor((Date.now() - new Date(fechaIso).getTime()) / 86_400_000);
}
