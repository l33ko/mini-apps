-- Synchronisation des apps publiques de SynApps (cahier du CP, jardin…).
-- Une ligne par compte (adresse e-mail) et par application.
-- À exécuter une fois dans un projet Supabase DÉDIÉ aux apps publiques :
-- SQL Editor > New query > Run.

create table if not exists public.app_saves (
  user_id    uuid not null references auth.users(id) on delete cascade,
  app        text not null check (char_length(app) between 1 and 40),
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, app),
  constraint app_saves_taille check (pg_column_size(data) < 500000)
);

alter table public.app_saves enable row level security;

-- Chaque compte ne voit et ne modifie que ses propres lignes.
create policy "app_saves_select" on public.app_saves
  for select to authenticated using (auth.uid() = user_id);
create policy "app_saves_insert" on public.app_saves
  for insert to authenticated with check (auth.uid() = user_id);
create policy "app_saves_update" on public.app_saves
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "app_saves_delete" on public.app_saves
  for delete to authenticated using (auth.uid() = user_id);
