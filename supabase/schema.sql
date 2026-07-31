-- ═══════════════════════════════════════════════════════════════════
--  ALEXMAR / ZONA DE PIX · Esquema Supabase (Postgres)
--  Reemplaza a Google Sheets + Apps Script como fuente de verdad.
--  Ejecutar completo en: Supabase Dashboard → SQL Editor → New query.
-- ═══════════════════════════════════════════════════════════════════

create extension if not exists "pgcrypto";

-- ── Función auxiliar: mantener updated_at al día en cada UPDATE ──
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ═══════════════════════════════════════════════════════════════════
--  PERFILES — un perfil por usuario de Supabase Auth (rol, nombre)
-- ═══════════════════════════════════════════════════════════════════
create table if not exists perfiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre_completo text not null default '',
  rol text not null default 'VENDEDOR' check (rol in ('ADMIN', 'VENDEDOR')),
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_perfiles_updated_at
  before update on perfiles
  for each row execute function set_updated_at();

-- Crear el perfil automáticamente cuando alguien se registra en Auth.
-- Por defecto entra como VENDEDOR; para hacer a alguien ADMIN corré:
--   update perfiles set rol = 'ADMIN' where id = '<uuid-del-usuario>';
create or replace function crear_perfil_nuevo_usuario()
returns trigger as $$
begin
  insert into perfiles (id, nombre_completo)
  values (new.id, coalesce(new.raw_user_meta_data->>'nombre_completo', new.email));
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_crear_perfil on auth.users;
create trigger trg_crear_perfil
  after insert on auth.users
  for each row execute function crear_perfil_nuevo_usuario();

-- ═══════════════════════════════════════════════════════════════════
--  CLIENTES — espejo de la pestaña CLIENTES del Sheet original
-- ═══════════════════════════════════════════════════════════════════
create table if not exists clientes (
  id uuid primary key default gen_random_uuid(),
  cedula text,
  nombre_cliente text not null,
  telefono text,
  direccion text,
  factura_n text,
  fecha_ultimo_abono timestamptz,
  total_adeudado numeric not null default 0,
  eliminado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_clientes_nombre on clientes (nombre_cliente);
create index if not exists idx_clientes_eliminado on clientes (eliminado);

create trigger trg_clientes_updated_at
  before update on clientes
  for each row execute function set_updated_at();

-- ═══════════════════════════════════════════════════════════════════
--  INVENTARIO — espejo de la pestaña INVENTARIO
-- ═══════════════════════════════════════════════════════════════════
create table if not exists inventario (
  id uuid primary key default gen_random_uuid(),
  nombre_producto text not null,
  descripcion text,
  categoria_tags text not null default 'GENERICO-UNIVERSAL',
  compatibilidad_vehiculos text not null default 'UNIVERSAL',
  costo numeric,
  pvp numeric,
  stock_actual integer not null default 0,
  stock_minimo integer not null default 0,
  url_foto text,
  eliminado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_inventario_categoria on inventario (categoria_tags);
create index if not exists idx_inventario_eliminado on inventario (eliminado);

create trigger trg_inventario_updated_at
  before update on inventario
  for each row execute function set_updated_at();

-- ═══════════════════════════════════════════════════════════════════
--  DETALLE_CUENTAS — cargos y abonos por cliente (una tabla, dos tipos)
-- ═══════════════════════════════════════════════════════════════════
create table if not exists detalle_cuentas (
  id uuid primary key default gen_random_uuid(),
  id_cliente uuid not null references clientes(id) on delete cascade,
  tipo_linea text not null default 'CARGO' check (tipo_linea in ('CARGO', 'ABONO', 'TITULO')),
  fecha timestamptz not null default now(),
  cantidad numeric not null default 1,
  descripcion text not null default '',
  precio_unitario numeric,
  costo_unitario numeric,
  total_linea numeric not null default 0,
  metodo_pago text, -- solo para ABONO: EFECTIVO | BINANCE | ZELLE | BOLIVARES | PESOS | OTRO
  id_producto uuid references inventario(id) on delete set null,
  eliminado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_detalle_cliente on detalle_cuentas (id_cliente);
create index if not exists idx_detalle_eliminado on detalle_cuentas (eliminado);

create trigger trg_detalle_updated_at
  before update on detalle_cuentas
  for each row execute function set_updated_at();

-- ═══════════════════════════════════════════════════════════════════
--  NOTAS — la pizarra del jefe
-- ═══════════════════════════════════════════════════════════════════
create table if not exists notas (
  id uuid primary key default gen_random_uuid(),
  titulo text,
  contenido text,
  color text not null default 'NARANJA',
  eliminado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_notas_updated_at
  before update on notas
  for each row execute function set_updated_at();

-- ═══════════════════════════════════════════════════════════════════
--  CIERRES_MENSUALES — fotografías financieras de cada mes cerrado
-- ═══════════════════════════════════════════════════════════════════
create table if not exists cierres_mensuales (
  id uuid primary key default gen_random_uuid(),
  anio integer not null,
  mes integer not null check (mes between 1 and 12),
  total_facturado numeric not null default 0,
  total_cobrado numeric not null default 0,
  ganancia_neta numeric not null default 0,
  cartera_pendiente_cierre numeric not null default 0,
  fecha_cierre timestamptz not null default now()
);

-- ═══════════════════════════════════════════════════════════════════
--  VISTA: saldo real de cada cliente, recalculado desde las líneas
--  (igual que hacía la app Flutter al bajar datos: nunca confiar en
--  total_adeudado a ciegas, siempre poder recalcularlo desde el detalle)
-- ═══════════════════════════════════════════════════════════════════
create or replace view vista_saldos_clientes as
select
  c.id,
  c.nombre_cliente,
  c.cedula,
  c.telefono,
  c.direccion,
  c.factura_n,
  c.fecha_ultimo_abono,
  c.eliminado,
  coalesce(sum(case when d.tipo_linea = 'CARGO' then d.total_linea else 0 end), 0) as total_cargado,
  coalesce(sum(case when d.tipo_linea = 'ABONO' then d.total_linea else 0 end), 0) as total_abonado,
  coalesce(sum(case when d.tipo_linea = 'CARGO' then d.total_linea else 0 end), 0)
    - coalesce(sum(case when d.tipo_linea = 'ABONO' then d.total_linea else 0 end), 0) as saldo_pendiente
from clientes c
left join detalle_cuentas d
  on d.id_cliente = c.id and d.eliminado = false
group by c.id;

-- ═══════════════════════════════════════════════════════════════════
--  RLS — Row Level Security
--  Herramienta interna de un solo negocio: cualquier usuario logueado
--  (con perfil activo) puede leer y escribir todo. Si más adelante
--  querés que un VENDEDOR no vea costos/compras, se restringe en la
--  app (ya lo hace la UI) y opcionalmente acá con políticas por rol.
-- ═══════════════════════════════════════════════════════════════════
alter table perfiles enable row level security;
alter table clientes enable row level security;
alter table inventario enable row level security;
alter table detalle_cuentas enable row level security;
alter table notas enable row level security;
alter table cierres_mensuales enable row level security;

create policy "perfiles: ver el propio" on perfiles
  for select using (auth.uid() = id);
create policy "perfiles: editar el propio" on perfiles
  for update using (auth.uid() = id);

create policy "clientes: acceso autenticado" on clientes
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "inventario: acceso autenticado" on inventario
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "detalle_cuentas: acceso autenticado" on detalle_cuentas
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "notas: acceso autenticado" on notas
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "cierres_mensuales: acceso autenticado" on cierres_mensuales
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ═══════════════════════════════════════════════════════════════════
--  REALTIME — para que varios dispositivos vean los cambios al instante
-- ═══════════════════════════════════════════════════════════════════
alter publication supabase_realtime add table clientes;
alter publication supabase_realtime add table detalle_cuentas;
alter publication supabase_realtime add table inventario;
alter publication supabase_realtime add table notas;

-- ═══════════════════════════════════════════════════════════════════
--  MIGRACIONES — cambios posteriores al esquema inicial. Cada bloque es
--  idempotente (se puede correr de nuevo sin romper nada), así que si
--  ejecutás este archivo entero en un proyecto nuevo, ya queda con todo.
-- ═══════════════════════════════════════════════════════════════════

-- 2026-07 · método de pago del abono (solo informativo)
alter table detalle_cuentas add column if not exists metodo_pago text;

-- 2026-07 · bucket de Storage para fotos de productos del inventario
insert into storage.buckets (id, name, public)
  values ('productos', 'productos', true)
  on conflict (id) do nothing;

drop policy if exists "productos: lectura publica" on storage.objects;
create policy "productos: lectura publica" on storage.objects
  for select using (bucket_id = 'productos');

drop policy if exists "productos: subir autenticado" on storage.objects;
create policy "productos: subir autenticado" on storage.objects
  for insert with check (bucket_id = 'productos' and auth.role() = 'authenticated');

drop policy if exists "productos: actualizar autenticado" on storage.objects;
create policy "productos: actualizar autenticado" on storage.objects
  for update using (bucket_id = 'productos' and auth.role() = 'authenticated');

drop policy if exists "productos: borrar autenticado" on storage.objects;
create policy "productos: borrar autenticado" on storage.objects
  for delete using (bucket_id = 'productos' and auth.role() = 'authenticated');

-- 2026-07 · PROVEEDORES — lo que le compramos y le debemos a cada proveedor
create table if not exists proveedores (
  id uuid primary key default gen_random_uuid(),
  nombre_proveedor text not null,
  nombre_distribuidor text,
  telefono text,
  ubicacion text,
  eliminado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_proveedores_updated_at
  before update on proveedores
  for each row execute function set_updated_at();

-- Un solo historial para COMPRA (sube la deuda) y PAGO (la baja), con la
-- foto de la factura adjunta (igual que las fotos de productos: se sube
-- redimensionada desde el navegador, no se "lee" el monto automáticamente).
create table if not exists movimientos_proveedor (
  id uuid primary key default gen_random_uuid(),
  id_proveedor uuid not null references proveedores(id) on delete cascade,
  tipo text not null default 'COMPRA' check (tipo in ('COMPRA', 'PAGO')),
  fecha timestamptz not null default now(),
  descripcion text,
  monto numeric not null default 0,
  factura_url text,
  eliminado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_movimientos_proveedor_proveedor on movimientos_proveedor (id_proveedor);

create trigger trg_movimientos_proveedor_updated_at
  before update on movimientos_proveedor
  for each row execute function set_updated_at();

create or replace view vista_saldos_proveedores as
select
  p.id,
  p.nombre_proveedor,
  p.nombre_distribuidor,
  p.telefono,
  p.ubicacion,
  p.eliminado,
  coalesce(sum(case when m.tipo = 'COMPRA' then m.monto else 0 end), 0) as total_comprado,
  coalesce(sum(case when m.tipo = 'PAGO' then m.monto else 0 end), 0) as total_pagado,
  coalesce(sum(case when m.tipo = 'COMPRA' then m.monto else 0 end), 0)
    - coalesce(sum(case when m.tipo = 'PAGO' then m.monto else 0 end), 0) as saldo_pendiente
from proveedores p
left join movimientos_proveedor m
  on m.id_proveedor = p.id and m.eliminado = false
group by p.id;

-- Control de garantías: qué se mandó al proveedor y qué volvió (o no).
create table if not exists garantias (
  id uuid primary key default gen_random_uuid(),
  id_proveedor uuid references proveedores(id) on delete set null,
  producto text not null,
  fecha_envio timestamptz not null default now(),
  fecha_retorno timestamptz,
  estado text not null default 'ENVIADA' check (estado in ('ENVIADA', 'DEVUELTA', 'RECHAZADA')),
  notas text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_garantias_updated_at
  before update on garantias
  for each row execute function set_updated_at();

alter table proveedores enable row level security;
alter table movimientos_proveedor enable row level security;
alter table garantias enable row level security;

create policy "proveedores: acceso autenticado" on proveedores
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "movimientos_proveedor: acceso autenticado" on movimientos_proveedor
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "garantias: acceso autenticado" on garantias
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

alter publication supabase_realtime add table proveedores;
alter publication supabase_realtime add table movimientos_proveedor;
alter publication supabase_realtime add table garantias;

-- Storage: fotos de facturas de proveedor (mismo patrón que "productos")
insert into storage.buckets (id, name, public)
  values ('facturas-proveedor', 'facturas-proveedor', true)
  on conflict (id) do nothing;

drop policy if exists "facturas-proveedor: lectura publica" on storage.objects;
create policy "facturas-proveedor: lectura publica" on storage.objects
  for select using (bucket_id = 'facturas-proveedor');

drop policy if exists "facturas-proveedor: subir autenticado" on storage.objects;
create policy "facturas-proveedor: subir autenticado" on storage.objects
  for insert with check (bucket_id = 'facturas-proveedor' and auth.role() = 'authenticated');

drop policy if exists "facturas-proveedor: actualizar autenticado" on storage.objects;
create policy "facturas-proveedor: actualizar autenticado" on storage.objects
  for update using (bucket_id = 'facturas-proveedor' and auth.role() = 'authenticated');

drop policy if exists "facturas-proveedor: borrar autenticado" on storage.objects;
create policy "facturas-proveedor: borrar autenticado" on storage.objects
  for delete using (bucket_id = 'facturas-proveedor' and auth.role() = 'authenticated');

-- 2026-07 · FUSIBLERAS — diagramas de caja de fusibles por vehículo, solo
-- de consulta. Los diagramas/fusibles los carga el dueño del negocio (vía
-- un script puntual con la service_role key), no hay pantalla de carga en
-- la app todavía.
create table if not exists fusibleras (
  id uuid primary key default gen_random_uuid(),
  marca text not null,
  modelo text not null,
  anio_desde smallint,
  anio_hasta smallint,
  ubicacion text,
  imagen_url text not null,
  eliminado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_fusibleras_marca_modelo on fusibleras (marca, modelo);

create trigger trg_fusibleras_updated_at
  before update on fusibleras
  for each row execute function set_updated_at();

-- Un punto tocable por fusible sobre el diagrama. pos_x/pos_y son
-- porcentaje (0-100) relativo al ancho/alto de la imagen, para que el
-- punto quede bien ubicado sin importar el tamaño en que se renderice.
create table if not exists fusibles (
  id uuid primary key default gen_random_uuid(),
  id_fusiblera uuid not null references fusibleras(id) on delete cascade,
  numero text not null,
  funcion text not null,
  amperaje text,
  pos_x numeric(5, 2) not null,
  pos_y numeric(5, 2) not null,
  eliminado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_fusibles_fusiblera on fusibles (id_fusiblera);

create trigger trg_fusibles_updated_at
  before update on fusibles
  for each row execute function set_updated_at();

alter table fusibleras enable row level security;
alter table fusibles enable row level security;

create policy "fusibleras: acceso autenticado" on fusibleras
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "fusibles: acceso autenticado" on fusibles
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

alter publication supabase_realtime add table fusibleras;
alter publication supabase_realtime add table fusibles;

-- Storage: fotos de diagramas de fusibleras (mismo patrón que "productos")
insert into storage.buckets (id, name, public)
  values ('fusibleras', 'fusibleras', true)
  on conflict (id) do nothing;

drop policy if exists "fusibleras: lectura publica" on storage.objects;
create policy "fusibleras: lectura publica" on storage.objects
  for select using (bucket_id = 'fusibleras');

drop policy if exists "fusibleras: subir autenticado" on storage.objects;
create policy "fusibleras: subir autenticado" on storage.objects
  for insert with check (bucket_id = 'fusibleras' and auth.role() = 'authenticated');

drop policy if exists "fusibleras: actualizar autenticado" on storage.objects;
create policy "fusibleras: actualizar autenticado" on storage.objects
  for update using (bucket_id = 'fusibleras' and auth.role() = 'authenticated');

drop policy if exists "fusibleras: borrar autenticado" on storage.objects;
create policy "fusibleras: borrar autenticado" on storage.objects
  for delete using (bucket_id = 'fusibleras' and auth.role() = 'authenticated');
