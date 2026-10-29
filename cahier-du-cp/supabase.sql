-- Synchronisation du cahier du CP : une ligne par compte (adresse e-mail).
-- À exécuter une fois dans Supabase : SQL Editor > New query > Run.

create table if not exists public.cp_saves (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  constraint cp_saves_taille check (pg_column_size(data) < 200000)
);

alter table public.cp_saves enable row level security;

-- Chaque compte ne voit et ne modifie que sa propre ligne.
create policy "cp_saves_select" on public.cp_saves
  for select to authenticated using (auth.uid() = user_id);
create policy "cp_saves_insert" on public.cp_saves
  for insert to authenticated with check (auth.uid() = user_id);
create policy "cp_saves_update" on public.cp_saves
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "cp_saves_delete" on public.cp_saves
  for delete to authenticated using (auth.uid() = user_id);
