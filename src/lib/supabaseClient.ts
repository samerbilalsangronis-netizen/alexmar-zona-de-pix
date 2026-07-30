import { createClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

export const supabaseConfigurado = Boolean(url && anonKey);

// Con valores vacíos createClient no explota, pero cualquier llamada de red
// fallará — supabaseConfigurado permite mostrar un aviso claro en vez de un
// error críptico cuando falten las variables de entorno.
export const supabase = createClient(url || 'https://placeholder.supabase.co', anonKey || 'placeholder');
