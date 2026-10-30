# SynApps — consignes pour Claude

Dépôt des mini apps publiques de l33ko, publiées sur **https://app.synapsium.com** (GitHub Pages, branche `main`, fichier `CNAME`). Tout ce qui arrive sur `main` est **immédiatement en production**.

## Règle n°0 : maquettes validées avant de coder une grosse fonctionnalité

**Grosse fonctionnalité** = nouvelle app, nouveau module ou nouvel écran, refonte d'un écran existant, nouveau parcours (connexion, partage, famille…). Les corrections de bugs, retouches de textes et petits ajustements passent directement par la règle n°1. En cas de doute, demander.

1. **Reformuler le besoin** en quelques lignes et poser les questions qui changent le design (pour qui, sur quel appareil, ce qui compte le plus). Ne pas écrire de code de l'app à ce stade.
2. **Proposer 2 ou 3 pistes de maquettes vraiment différentes** (disposition, parcours, manière d'interagir — pas seulement des couleurs), chacune montrée **sur iPhone et sur ordinateur**, avec des données fictives réalistes, en français, dans le style SynApps. Les principaux enchaînements d'écrans peuvent être cliquables, sans logique réelle derrière.
3. Les publier sur une **branche `maquettes-<sujet>`**, dans `maquettes/<sujet>/index.html` (une seule page qui présente toutes les pistes côte à côte, chacune avec ses points forts et ses limites). **Pas de pull request** : cette branche n'est jamais fusionnée.
4. Donner au propriétaire le lien de la version test : `https://maquettes-<sujet>.synapps-bhl.pages.dev/maquettes/<sujet>/`
5. **Attendre son choix explicite** (« piste B », « A avec le menu de C », retouches…). Les retouches se font sur la même branche, la version test se met à jour.
6. Une fois la maquette validée, coder sur une **nouvelle branche** selon la règle n°1, en respectant la maquette choisie. Rappeler le lien de la maquette dans la pull request et signaler tout écart qui s'est imposé en cours de route.

## Règle n°1 : rien ne part en production sans validation

1. **Ne jamais pousser directement sur `main`**, ni fusionner une pull request de sa propre initiative.
2. Travailler sur une **branche dédiée** au nom parlant (ex. `jardin-panneau-mobile`), créée à partir de `origin/main` à jour.
3. Pousser la branche et **ouvrir une pull request sans la fusionner**.
4. Donner au propriétaire :
   - le **lien de la version test** (voir ci-dessous) vers l'app concernée ;
   - un résumé simple de ce qui change et de ce qu'il faut tester ;
   - si utile, des captures d'écran (ordinateur et iPhone).
5. **Attendre une validation explicite** (« validé », « ok pour la prod »…) avant de fusionner (squash).
   Une demande de correction se fait sur la même branche : la version test se met à jour.
6. Après la fusion, rappeler que la mise en ligne prend quelques minutes et que le bandeau « Une nouvelle version est disponible » proposera la mise à jour.

## Versions test (Cloudflare Pages)

Le dépôt est relié à Cloudflare Pages, projet `synapps` (sous-domaine **`synapps-bhl.pages.dev`**). Chaque branche poussée obtient automatiquement une adresse de test :

```
https://<nom-de-branche>.synapps-bhl.pages.dev/<dossier-de-l-app>/
```

Exemple : `https://jardin-panneau-mobile.synapps-bhl.pages.dev/mon-jardin/`. La branche `main` y est aussi publiée (`https://synapps-bhl.pages.dev/`), simple copie de la production. Les caractères spéciaux du nom de branche deviennent des tirets ; l'adresse exacte figure aussi dans le statut « Cloudflare Pages » de la pull request.

La version test a sa propre adresse : ses données locales (plans, réglages…) sont séparées de celles de la production. La connexion Supabase y fonctionne si `https://*.synapps-bhl.pages.dev/**` figure dans les Redirect URLs du projet Supabase.

Si la version test n'est pas disponible, publier la page modifiée en aperçu privé et le signaler, sans fusionner pour autant.

## Organisation du dépôt

- Une app = un dossier avec un seul `index.html` autonome (HTML, CSS, JS dans le fichier, sans outil de build). Page d'accueil : `index.html` à la racine.
- Apps : `cahier-du-cp`, `lego-builder`, `mon-jardin`, `pixel-arts`, `recettes`, `retro-console`.
- Interface et textes **en français**, pensés pour iPhone autant que pour ordinateur.
- Chaque page se termine par le script « SynApps — nouvelle version disponible ? » (bandeau de mise à jour contre le cache) : le conserver dans toute nouvelle page.
- Synchronisation des apps publiques : projet Supabase **Synapps_public** (URL et clé publique *publishable* dans la constante `SB` de chaque app), session commune `synapps-auth`, connexion par lien reçu par e-mail (envoi via Brevo). Les scripts `supabase.sql` de chaque app sont à exécuter par le propriétaire dans le SQL Editor. Ne jamais mettre de clé secrète (`service_role`, `sb_secret_…`) dans le dépôt.
- Messages de commit et descriptions de pull request en français.
