-- Synchronisation de « Mon jardin » entre appareils (plans, photos de fond, palette végétale).
-- À exécuter une fois dans Supabase : SQL Editor > New query > Run.
-- Peut partager le même projet Supabase que les autres apps SynApps (Cahier du CP…).

-- Un plan par ligne. Une suppression laisse une ligne « deleted » pour prévenir les autres appareils.
create table if not exists public.jardin_plans (
  user_id  uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id       text not null,
  name     text not null default '',
  data     jsonb,                     -- le plan (vide si supprimé)
  bg       text,                      -- photo de fond éventuelle (image JPEG encodée)
  bg_hash  text,
  updated  bigint not null,           -- date de dernière modification, en millisecondes
  deleted  boolean not null default false,
  primary key (user_id, id),
  constraint jardin_plans_taille check (coalesce(pg_column_size(data), 0) < 3000000 and coalesce(length(bg), 0) < 6000000)
);

-- La palette végétale du compte (espèces et variétés), une ligne par compte.
create table if not exists public.jardin_palette (
  user_id  uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data     jsonb not null,
  updated  bigint not null,
  constraint jardin_palette_taille check (pg_column_size(data) < 3000000)
);

alter table public.jardin_plans   enable row level security;
alter table public.jardin_palette enable row level security;

-- Chaque compte ne voit et ne modifie que ses propres lignes.
create policy "jardin_plans_select" on public.jardin_plans for select to authenticated using (auth.uid() = user_id);
create policy "jardin_plans_insert" on public.jardin_plans for insert to authenticated with check (auth.uid() = user_id);
create policy "jardin_plans_update" on public.jardin_plans for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "jardin_plans_delete" on public.jardin_plans for delete to authenticated using (auth.uid() = user_id);

create policy "jardin_palette_select" on public.jardin_palette for select to authenticated using (auth.uid() = user_id);
create policy "jardin_palette_insert" on public.jardin_palette for insert to authenticated with check (auth.uid() = user_id);
create policy "jardin_palette_update" on public.jardin_palette for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "jardin_palette_delete" on public.jardin_palette for delete to authenticated using (auth.uid() = user_id);
