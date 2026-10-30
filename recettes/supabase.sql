-- =============================================================
--  SynApps · Recettes — script pour le projet Supabase PUBLIC
--  SQL Editor > New query > coller > Run. Peut être relancé sans risque.
--
--  Principe : chaque compte appartient à une ou plusieurs « familles ».
--  Une recette appartient à une famille ; tous les membres de la famille
--  la voient et peuvent la modifier. Personne d'autre n'y a accès.
-- =============================================================

-- ---------- Tables ----------
create table if not exists public.familles (
  id         uuid primary key default gen_random_uuid(),
  nom        text not null default 'Mes recettes' check (char_length(nom) between 1 and 60),
  code       text not null unique,                       -- code d'invitation
  created_at timestamptz not null default now()
);

create table if not exists public.membres_famille (
  famille_id uuid not null references public.familles(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  role       text not null default 'membre' check (role in ('admin', 'membre')),
  email      text,                                       -- pour afficher « ajoutée par … »
  created_at timestamptz not null default now(),
  primary key (famille_id, user_id)
);
create index if not exists membres_famille_user on public.membres_famille(user_id);

create table if not exists public.recettes (
  id            uuid primary key default gen_random_uuid(),
  famille_id    uuid not null references public.familles(id) on delete cascade,
  titre         text not null check (char_length(titre) between 1 and 200),
  categorie     text,
  portions      int  default 4,
  temps_prep    int,
  temps_cuisson int,
  ingredients   text default '' check (char_length(ingredients) < 20000),
  etapes        text default '' check (char_length(etapes) < 40000),
  notes         text default '' check (char_length(notes) < 20000),
  tags          text[] default '{}',
  source        text,
  photo         text,
  favori        boolean default false,
  cree_par      uuid default auth.uid() references auth.users(id) on delete set null,
  modifie_par   uuid default auth.uid() references auth.users(id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index if not exists recettes_famille on public.recettes(famille_id);
-- copie d'une recette d'exemple (devient une recette normale dès qu'on la modifie)
alter table public.recettes add column if not exists exemple boolean not null default false;

-- Recettes d'exemple, copiées dans chaque nouveau carnet (voir plus bas)
create table if not exists public.recettes_exemples (
  titre         text primary key,
  ordre         int  not null default 0,
  categorie     text,
  portions      int,
  temps_prep    int,
  temps_cuisson int,
  ingredients   text,
  etapes        text,
  notes         text,
  tags          text[] default '{}'
);

-- ---------- Fonctions d'appartenance (utilisées par les règles) ----------
create or replace function public.est_membre(f uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from membres_famille where famille_id = f and user_id = auth.uid());
$$;

create or replace function public.est_admin(f uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from membres_famille where famille_id = f and user_id = auth.uid() and role = 'admin');
$$;

create or replace function public.nouveau_code() returns text
language plpgsql volatile set search_path = public as $$
declare
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';   -- sans 0/O ni 1/I
  c text;
begin
  loop
    c := '';
    for i in 1..6 loop
      c := c || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    exit when not exists (select 1 from familles where code = c);
  end loop;
  return c;
end; $$;

-- ---------- Règles d'accès (RLS) ----------
alter table public.familles        enable row level security;
alter table public.membres_famille enable row level security;
alter table public.recettes        enable row level security;

drop policy if exists "familles_voir"     on public.familles;
drop policy if exists "familles_renommer" on public.familles;
create policy "familles_voir"     on public.familles for select to authenticated using (est_membre(id));
create policy "familles_renommer" on public.familles for update to authenticated using (est_admin(id)) with check (est_admin(id));

drop policy if exists "membres_voir"    on public.membres_famille;
drop policy if exists "membres_retirer" on public.membres_famille;
create policy "membres_voir"    on public.membres_famille for select to authenticated using (est_membre(famille_id));
-- on peut se retirer soi-même ; un admin peut retirer les autres
create policy "membres_retirer" on public.membres_famille for delete to authenticated
  using (user_id = auth.uid() or est_admin(famille_id));

drop policy if exists "recettes_voir"      on public.recettes;
drop policy if exists "recettes_ajouter"   on public.recettes;
drop policy if exists "recettes_modifier"  on public.recettes;
drop policy if exists "recettes_supprimer" on public.recettes;
create policy "recettes_voir"      on public.recettes for select to authenticated using (est_membre(famille_id));
create policy "recettes_ajouter"   on public.recettes for insert to authenticated with check (est_membre(famille_id));
create policy "recettes_modifier"  on public.recettes for update to authenticated using (est_membre(famille_id)) with check (est_membre(famille_id));
create policy "recettes_supprimer" on public.recettes for delete to authenticated using (est_membre(famille_id));

alter table public.recettes_exemples enable row level security;
drop policy if exists "exemples_voir" on public.recettes_exemples;
create policy "exemples_voir" on public.recettes_exemples for select to authenticated using (true);

revoke all on public.familles, public.membres_famille, public.recettes, public.recettes_exemples from anon;
grant select on public.recettes_exemples to authenticated;
grant select, update (nom)       on public.familles        to authenticated;
grant select, delete             on public.membres_famille to authenticated;
grant select, insert, update, delete on public.recettes    to authenticated;

-- ---------- Date et auteur de modification automatiques ----------
create or replace function public.recettes_maj() returns trigger
language plpgsql as $$
begin
  -- Mise à jour faite par la base elle-même (compte supprimé → auteur effacé) : on laisse faire.
  if (old.cree_par is not null and new.cree_par is null) or (old.modifie_par is not null and new.modifie_par is null) then
    return new;
  end if;
  new.updated_at := now();
  new.modifie_par := coalesce(auth.uid(), new.modifie_par);
  -- une recette d'exemple modifiée devient une recette de la famille
  if (new.titre, new.categorie, new.portions, new.temps_prep, new.temps_cuisson, new.ingredients, new.etapes, new.notes, new.tags, new.source, new.photo)
     is distinct from (old.titre, old.categorie, old.portions, old.temps_prep, old.temps_cuisson, old.ingredients, old.etapes, old.notes, old.tags, old.source, old.photo) then
    new.exemple := false;
  end if;
  new.famille_id := old.famille_id;           -- une recette ne change pas de famille
  new.cree_par := old.cree_par;
  return new;
end; $$;
drop trigger if exists recettes_maj on public.recettes;
create trigger recettes_maj before update on public.recettes for each row execute function public.recettes_maj();

-- Une famille sans membre disparaît (avec ses recettes)
create or replace function public.famille_orpheline() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  delete from familles f where f.id = old.famille_id
    and not exists (select 1 from membres_famille m where m.famille_id = old.famille_id);
  -- s'il reste des membres mais plus d'admin, le plus ancien devient admin
  update membres_famille set role = 'admin'
   where (famille_id, user_id) = (
     select famille_id, user_id from membres_famille
      where famille_id = old.famille_id order by created_at limit 1)
     and not exists (select 1 from membres_famille where famille_id = old.famille_id and role = 'admin');
  return null;
end; $$;
drop trigger if exists famille_orpheline on public.membres_famille;
create trigger famille_orpheline after delete on public.membres_famille
  for each row execute function public.famille_orpheline();

-- ---------- Actions appelées par l'app ----------

-- Copie les recettes d'exemple manquantes dans une famille (sans auteur)
create or replace function public.copier_exemples(f uuid) returns int
language plpgsql security definer set search_path = public as $$
declare n int;
begin
  insert into recettes (famille_id, titre, categorie, portions, temps_prep, temps_cuisson, ingredients, etapes, notes, tags, exemple, cree_par, modifie_par)
    select f, e.titre, e.categorie, e.portions, e.temps_prep, e.temps_cuisson, e.ingredients, e.etapes, e.notes, e.tags, true, null, null
      from recettes_exemples e
     where not exists (select 1 from recettes r where r.famille_id = f and r.titre = e.titre)
     order by e.ordre;
  get diagnostics n = row_count;
  return n;
end; $$;

-- Bouton « Ajouter des recettes d'exemple » (familles existantes)
create or replace function public.ajouter_exemples(f uuid) returns int
language plpgsql security definer set search_path = public as $$
begin
  if not est_membre(f) then raise exception 'Réservé aux membres de la famille'; end if;
  return copier_exemples(f);
end; $$;

-- À l'ouverture : crée « Mes recettes » si le compte n'a encore aucune famille.
create or replace function public.mes_familles()
returns table (id uuid, nom text, code text, role text, nb_membres bigint, nb_recettes bigint)
language plpgsql security definer set search_path = public as $$
declare f uuid;
begin
  if auth.uid() is null then raise exception 'non connecté'; end if;
  if not exists (select 1 from membres_famille m where m.user_id = auth.uid()) then
    insert into familles (nom, code) values ('Mes recettes', nouveau_code()) returning familles.id into f;
    insert into membres_famille (famille_id, user_id, role, email) values (f, auth.uid(), 'admin', auth.jwt() ->> 'email');
    perform copier_exemples(f);
  end if;
  update membres_famille m set email = auth.jwt() ->> 'email'
   where m.user_id = auth.uid() and m.email is distinct from auth.jwt() ->> 'email';
  return query
    select fa.id, fa.nom, fa.code, m.role,
           (select count(*) from membres_famille x where x.famille_id = fa.id),
           (select count(*) from recettes r where r.famille_id = fa.id)
      from familles fa join membres_famille m on m.famille_id = fa.id and m.user_id = auth.uid()
     order by m.created_at;
end; $$;

-- Aperçu avant de rejoindre (nom de la famille correspondant au code)
create or replace function public.apercu_famille(p_code text)
returns table (nom text, nb_membres bigint)
language sql stable security definer set search_path = public as $$
  select f.nom, (select count(*) from membres_famille m where m.famille_id = f.id)
    from familles f where f.code = upper(replace(trim(p_code), '-', ''));
$$;

-- Rejoindre une famille avec son code. Si l'on était seul dans une famille
-- vide (créée automatiquement), celle-ci est supprimée.
create or replace function public.rejoindre_famille(p_code text) returns uuid
language plpgsql security definer set search_path = public as $$
declare f uuid;
begin
  if auth.uid() is null then raise exception 'non connecté'; end if;
  select id into f from familles where code = upper(replace(trim(p_code), '-', ''));
  if f is null then raise exception 'Code d’invitation inconnu'; end if;
  if (select count(*) from membres_famille where user_id = auth.uid()) >= 10 then
    raise exception 'Nombre maximum de familles atteint';
  end if;
  insert into membres_famille (famille_id, user_id, role, email)
    values (f, auth.uid(), 'membre', auth.jwt() ->> 'email')
    on conflict do nothing;
  delete from membres_famille m
   where m.user_id = auth.uid() and m.famille_id <> f
     and not exists (select 1 from recettes r where r.famille_id = m.famille_id and not r.exemple)
     and (select count(*) from membres_famille x where x.famille_id = m.famille_id) = 1;
  return f;
end; $$;

-- Créer une famille supplémentaire
create or replace function public.creer_famille(p_nom text) returns uuid
language plpgsql security definer set search_path = public as $$
declare f uuid;
begin
  if auth.uid() is null then raise exception 'non connecté'; end if;
  if (select count(*) from membres_famille where user_id = auth.uid()) >= 10 then
    raise exception 'Nombre maximum de familles atteint';
  end if;
  insert into familles (nom, code) values (left(coalesce(nullif(trim(p_nom), ''), 'Mes recettes'), 60), nouveau_code())
    returning id into f;
  insert into membres_famille (famille_id, user_id, role, email) values (f, auth.uid(), 'admin', auth.jwt() ->> 'email');
  return f;
end; $$;

-- Nouveau code d'invitation (l'ancien ne fonctionne plus)
create or replace function public.nouveau_code_famille(f uuid) returns text
language plpgsql security definer set search_path = public as $$
declare c text;
begin
  if not est_admin(f) then raise exception 'Réservé aux administrateurs de la famille'; end if;
  c := nouveau_code();
  update familles set code = c where id = f;
  return c;
end; $$;

-- Supprimer son compte. Par cascade : ses adhésions disparaissent, ainsi que
-- les familles dont il était le seul membre (et leurs recettes).
create or replace function public.supprimer_mon_compte() returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  if auth.uid() is null then raise exception 'non connecté'; end if;
  delete from auth.users where id = auth.uid();
end; $$;

revoke execute on function public.mes_familles(), public.apercu_famille(text), public.rejoindre_famille(text),
  public.creer_famille(text), public.nouveau_code_famille(uuid), public.supprimer_mon_compte(),
  public.nouveau_code(), public.est_membre(uuid), public.est_admin(uuid),
  public.copier_exemples(uuid), public.ajouter_exemples(uuid) from anon, public;
revoke execute on function public.copier_exemples(uuid) from authenticated;
grant execute on function public.mes_familles(), public.apercu_famille(text), public.rejoindre_famille(text),
  public.creer_famille(text), public.nouveau_code_famille(uuid), public.supprimer_mon_compte(),
  public.est_membre(uuid), public.est_admin(uuid), public.ajouter_exemples(uuid) to authenticated;

-- ---------- Temps réel : les modifications arrivent sur les autres appareils ----------
do $$ begin
  alter publication supabase_realtime add table public.recettes;
exception when duplicate_object then null; end $$;
alter table public.recettes replica identity full;

-- ---------- Contenu des recettes d'exemple (textes SynApps) ----------
insert into public.recettes_exemples (titre, ordre, categorie, portions, temps_prep, temps_cuisson, ingredients, etapes, notes, tags) values
  ($t$Gougères au fromage$t$, 1, $t$Apéro$t$, 6, 20, 25, $t$25 cl d'eau
80 g de beurre
150 g de farine
4 œufs
100 g de comté râpé
1 pincée de sel
1 pincée de poivre
1 pincée de noix de muscade$t$, $t$Préchauffer le four à 200 °C et couvrir une plaque de papier cuisson.
Dans une casserole, porter l'eau à ébullition avec le beurre en morceaux, le sel, le poivre et la muscade.
Hors du feu, verser toute la farine d'un coup et mélanger vivement à la spatule.
Remettre sur feu doux 1 à 2 minutes en remuant : la pâte doit former une boule qui se détache des parois.
Laisser tiédir 5 minutes, puis ajouter les œufs un par un en mélangeant bien entre chaque.
Incorporer les trois quarts du fromage.
Déposer des petits tas de pâte bien espacés sur la plaque et parsemer du reste de fromage.
Cuire 20 à 25 minutes sans ouvrir le four, jusqu'à ce qu'elles soient bien dorées et gonflées.$t$, $t$Elles se congèlent très bien une fois cuites : 5 minutes au four pour les réchauffer.$t$, array[$t$exemple$t$, $t$apéro$t$, $t$fromage$t$]),
  ($t$Crackers aux graines$t$, 2, $t$Apéro$t$, 6, 15, 50, $t$60 g de graines de tournesol
50 g de graines de courge
40 g de graines de lin
30 g de graines de sésame
20 g de graines de chia
60 g de flocons d'avoine
1 c. à c. de sel
2 c. à s. d'huile d'olive
20 cl d'eau bouillante$t$, $t$Préchauffer le four à 160 °C.
Mélanger toutes les graines, les flocons d'avoine et le sel dans un saladier.
Ajouter l'huile et l'eau bouillante, mélanger, puis laisser reposer 10 minutes : le lin et le chia lient la pâte.
Étaler la pâte très finement entre deux feuilles de papier cuisson au rouleau, puis retirer la feuille du dessus.
Tracer des carrés au couteau pour faciliter la découpe.
Cuire 45 à 50 minutes, jusqu'à ce que les crackers soient secs et légèrement dorés.
Laisser refroidir complètement avant de les casser.$t$, $t$Se gardent une semaine dans une boîte hermétique. Varier avec des herbes, du paprika ou du fromage râpé.$t$, array[$t$exemple$t$, $t$végé$t$, $t$apéro$t$]),
  ($t$Gaufres légères$t$, 3, $t$Petit-déj$t$, 6, 15, 20, $t$250 g de farine
1 sachet de levure chimique
2 c. à s. de sucre
1 sachet de sucre vanillé
1 pincée de sel
3 œufs
50 cl de lait
60 g de beurre fondu$t$, $t$Séparer les blancs des jaunes.
Dans un saladier, mélanger la farine, la levure, les sucres et le sel.
Ajouter les jaunes, puis verser le lait petit à petit en fouettant pour éviter les grumeaux.
Incorporer le beurre fondu.
Monter les blancs en neige ferme et les ajouter délicatement à la pâte avec une spatule.
Cuire dans le gaufrier bien chaud et légèrement graissé, 3 à 4 minutes par gaufre.$t$, $t$Les blancs en neige rendent les gaufres aériennes. Avec du sucre glace, de la confiture ou de la chantilly.$t$, array[$t$exemple$t$, $t$goûter$t$, $t$enfants$t$]),
  ($t$Gâteau au chocolat fondant rapide$t$, 4, $t$Dessert$t$, 6, 10, 25, $t$200 g de chocolat noir pâtissier
125 g de beurre
100 g de sucre
4 œufs
50 g de farine$t$, $t$Préchauffer le four à 180 °C et beurrer un moule d'environ 22 cm.
Faire fondre le chocolat avec le beurre, au micro-ondes ou au bain-marie, puis lisser.
Hors du feu, ajouter le sucre, puis les œufs un par un en mélangeant.
Incorporer la farine sans trop travailler la pâte.
Verser dans le moule et cuire 20 à 25 minutes : le centre doit rester légèrement tremblant.
Laisser tiédir avant de démouler.$t$, $t$Encore meilleur le lendemain. Une pincée de fleur de sel sur le dessus le rend irrésistible.$t$, array[$t$exemple$t$, $t$chocolat$t$, $t$rapide$t$]),
  ($t$Tarte au citron meringuée$t$, 5, $t$Dessert$t$, 8, 40, 35, $t$1 pâte sablée
3 citrons non traités
4 œufs
150 g de sucre pour la crème
100 g de sucre pour la meringue
20 g de fécule de maïs
50 g de beurre$t$, $t$— La pâte —
Préchauffer le four à 180 °C. Garnir un moule à tarte avec la pâte et piquer le fond à la fourchette.
Cuire à blanc 20 minutes, recouverte de papier cuisson et de légumes secs, puis 5 minutes à découvert.
— La crème au citron —
Râper le zeste d'un citron et presser le jus des trois.
Séparer trois œufs : garder les blancs pour la meringue.
Dans une casserole, fouetter les trois jaunes, l'œuf entier restant, 150 g de sucre et la fécule, puis ajouter le jus et le zeste.
Faire épaissir sur feu doux sans cesser de fouetter, puis ajouter le beurre en morceaux hors du feu.
Verser la crème sur le fond de tarte cuit.
— La meringue —
Monter les trois blancs en neige ; dès qu'ils moussent, ajouter 100 g de sucre petit à petit jusqu'à une meringue ferme et brillante.
Étaler la meringue sur la crème en formant des pics.
Passer 5 à 10 minutes sous le gril du four en surveillant : la meringue doit juste dorer.$t$, $t$Laisser refroidir au moins une heure avant de servir.$t$, array[$t$exemple$t$, $t$citron$t$, $t$fête$t$])
on conflict (titre) do update set ordre = excluded.ordre, categorie = excluded.categorie, portions = excluded.portions,
  temps_prep = excluded.temps_prep, temps_cuisson = excluded.temps_cuisson, ingredients = excluded.ingredients,
  etapes = excluded.etapes, notes = excluded.notes, tags = excluded.tags;
