import { supabase } from './supabaseClient';

const LADO_MAXIMO = 1280;
const CALIDAD_JPEG = 0.82;

/** Redimensiona una foto (de cámara o galería) a un tamaño razonable para catálogo, en el propio navegador. */
function redimensionar(archivo: File): Promise<Blob> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    const url = URL.createObjectURL(archivo);
    img.onload = () => {
      URL.revokeObjectURL(url);
      const escala = Math.min(1, LADO_MAXIMO / Math.max(img.width, img.height));
      const ancho = Math.round(img.width * escala);
      const alto = Math.round(img.height * escala);
      const canvas = document.createElement('canvas');
      canvas.width = ancho;
      canvas.height = alto;
      const ctx = canvas.getContext('2d');
      if (!ctx) return reject(new Error('No se pudo procesar la imagen'));
      ctx.drawImage(img, 0, 0, ancho, alto);
      canvas.toBlob((blob) => (blob ? resolve(blob) : reject(new Error('No se pudo procesar la imagen'))), 'image/jpeg', CALIDAD_JPEG);
    };
    img.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error('No se pudo leer la imagen'));
    };
    img.src = url;
  });
}

/** Redimensiona y sube una foto de producto a Supabase Storage. Devuelve la URL pública. */
export async function subirFotoProducto(archivo: File): Promise<string> {
  const blob = await redimensionar(archivo);
  const nombre = `${crypto.randomUUID()}.jpg`;
  const { error } = await supabase.storage.from('productos').upload(nombre, blob, {
    contentType: 'image/jpeg',
    cacheControl: '31536000',
  });
  if (error) throw error;
  const { data } = supabase.storage.from('productos').getPublicUrl(nombre);
  return data.publicUrl;
}
