# SynApps

Petites applications web, simples et accessibles à tous. Chaque application tient (sauf Rétro Console) dans un seul fichier `index.html` et fonctionne directement dans le navigateur, sur ordinateur comme sur téléphone.

La page d'accueil ([`index.html`](index.html)) présente toutes les applications, avec un lien vers chacune.

| Application | Dossier | Description |
|---|---|---|
| Mon cahier du CP | [`cahier-du-cp/`](cahier-du-cp/) | Lecture, écriture et calcul pour les enfants de CP. |
| Mon jardin | [`mon-jardin/`](mon-jardin/) | Éditeur de plan de jardin à l'échelle, façon paysagiste. |
| Lego Builder | [`lego-builder/`](lego-builder/) | Constructions Lego en 3D à monter pas à pas, pour les 8-10 ans. |
| Pixel arts | [`pixel-arts/`](pixel-arts/) | Modèles de pixel art à recopier sur papier ou en perles à repasser. |
| Rétro Console | [`retro-console/`](retro-console/) | Émulateur de consoles rétro (SNES, NES, Neo Geo, Mega Drive, Game Boy…) dans le navigateur. |

## Mon jardin

Concevoir et visualiser son jardin, à l'échelle :

- **Plusieurs plans nommés**, retrouvés sur la page d'accueil (aperçu, surface, nombre de végétaux) ; renommer, dupliquer, exporter, supprimer.
- **Trois façons de commencer** : feuille blanche (rectangle), contour libre point par point, ou photo aérienne / plan scanné mis à l'échelle à partir d'une distance connue.
- **Relevé de l'existant sur la photo** : détection automatique des arbres et des piscines (à valider d'un toucher), et outils rapides pour tracer maison, piscine, terrasse, arbres et arbustes existants.
- **Formes orientables** : toute zone carrée ou rectangulaire (maison, piscine, terrasse, potager, serre…) pivote avec sa poignée, au degré près.
- **Palette végétale commune à tous les plans** (bouton ⚙), plus de 200 espèces dont une large sélection méditerranéenne, rangées par catégories : fruitiers à noyau, à pépins, à coque, agrumes, autres fruitiers, arbres d'ombrage, arbustes et haies, grimpantes, subtropicaux, potager, fleurs. Chaque espèce regroupe ses variétés ; on ajoute, modifie ou supprime espèces et variétés pour tous les plans à la fois. Sur le plan, l'espèce s'affiche en gras et la variété en petit italique.
- **Aménagements** : maison, terrasse, piscine, potager, poulailler, serre, bassin, ruche, chemins, clôtures, haies, irrigation, repères et étiquettes.
- **Deux vues** : détaillée (avec les noms des végétaux) et simplifiée ; curseur de croissance (de la plantation à l'âge adulte) ; contrôle des distances de plantation par rapport aux limites (art. 671 du Code civil).
- **Export** du plan en image PNG et en sauvegarde `.json`, importable sur un autre appareil.
- **Partage par lien** : 🔗 sur un plan crée un lien qui contient tout le plan ; la personne qui l'ouvre l'ajoute à ses propres plans et récupère les espèces et variétés dans sa palette. Aucun compte ni serveur.
- **Jardin-forêt** : chaque espèce a une strate (canopée, petits arbres, arbustes, herbacées, couvre-sol, racines, grimpantes) et des fonctions (fixatrice d'azote, mellifère, accumulatrice, brise-vent, fourragère), réglables dans la palette ; vue « Strates », filtres par fonction et bilan dans l'inventaire.
- **Import / export de la palette** en tableur (`.csv`) ou en fichier `.json`. Des palettes prêtes à charger se trouvent dans [`mon-jardin/palettes/`](mon-jardin/palettes/), dont la liste complète du jardin-forêt Sylvaniers.

Un exemple de plan est fourni au premier lancement : une maison avec piscine et un jardin méditerranéen.

Les plans sont enregistrés dans le navigateur de l'appareil utilisé (aucun compte, aucun serveur). Pour les garder en sécurité ou les transférer, utilisez l'export.

## Pixel arts

Des modèles de pixel art pour les enfants, à recopier sur papier quadrillé ou à reproduire en perles à repasser :

- **Catalogue de 30 modèles originaux** (animaux, mer, nature, fruits, objets, fêtes), avec la taille, le nombre de perles et un niveau de difficulté.
- **Mode papier** : grille avec repères (chiffres et lettres) et un trait plus marqué tous les 5 carreaux ; option « Numéros » + « Grille vide » pour un coloriage magique.
- **Mode perles** : le modèle sur une plaque à picots, avec la liste des perles à préparer par couleur et le total.
- **Image à garder** : une image du modèle avec sa légende, à enregistrer ou imprimer.
- **Créer** : transformer une image en pixel art (taille et nombre de couleurs réglables, couleurs de perles courantes) ou dessiner case par case. Les créations s'ajoutent au catalogue dans « Mes modèles », enregistrées dans le navigateur de l'appareil.

## Rétro Console

Une console de jeux rétro dans le navigateur, sur ordinateur comme sur iPhone :

- **8 familles de consoles** : Super Nintendo, NES, Neo Geo / Arcade (FBNeo), Mega Drive (+ Master System, Game Gear), Game Boy / Color, Game Boy Advance, PC Engine, Atari 2600.
- **Commandes** : boutons tactiles sur téléphone, clavier ou manette sur ordinateur ; sauvegardes et états de jeu dans le menu de l'émulateur.
- **Ludothèque** : les jeux lancés sont gardés dans le navigateur pour les relancer en un geste. Le BIOS Neo Geo (`neogeo.zip`) est mémorisé après le premier chargement.
- **Fichiers acceptés** : ROM non compressée ou `.zip` (le `.7z` n'est pas pris en charge).

Aucun jeu n'est fourni : utilisez des jeux libres (homebrew, par exemple sur itch.io, PDRoms ou Homebrew Hub) ou vos propres sauvegardes de cartouches.

Contrairement aux autres applications, celle-ci n'est pas un fichier unique : elle embarque [EmulatorJS](https://github.com/EmulatorJS/EmulatorJS) 4.2.3 et des cœurs libretro dans [`retro-console/data/`](retro-console/data/), sous licence GPL-3.0 (voir [`retro-console/data/LICENSE`](retro-console/data/LICENSE)). Modifications apportées : décompression des archives par [fflate](https://github.com/101arrowz/fflate) au lieu des extracteurs d'origine, cœurs reconditionnés en `.zip` (extension `.wasm`), chargement du cœur sans URL `blob:` pour respecter une politique de sécurité stricte, et désactivation de la vérification de mise à jour.

