-- Sauvegarde de « Synapse » (entraînement cérébral) : l'historique des exercices de chaque compte.
-- À exécuter une fois dans Supabase : SQL Editor > New query > Run.
-- Projet Supabase des apps publiques (« Synapps_public »), le même que Recettes et Mon jardin.

-- Une ligne par compte : la liste des parties jouées (date, exercice, score, évolution du niveau).
create table if not exists public.synapse_profil (
  user_id  uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data     jsonb not null,
  updated  bigint not null,
  constraint synapse_profil_taille check (pg_column_size(data) < 2000000)
);

alter table public.synapse_profil enable row level security;

-- Chaque compte ne voit et ne modifie que sa propre ligne.
create policy "synapse_profil_select" on public.synapse_profil for select to authenticated using (auth.uid() = user_id);
create policy "synapse_profil_insert" on public.synapse_profil for insert to authenticated with check (auth.uid() = user_id);
create policy "synapse_profil_update" on public.synapse_profil for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "synapse_profil_delete" on public.synapse_profil for delete to authenticated using (auth.uid() = user_id);
