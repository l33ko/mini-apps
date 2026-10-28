# mini-apps

Petites applications web, simples et accessibles à tous. Chaque application tient dans un seul fichier `index.html` et fonctionne directement dans le navigateur, sur ordinateur comme sur téléphone.

| Application | Dossier | Description |
|---|---|---|
| Mon cahier du CP | [`cahier-du-cp/`](cahier-du-cp/) | Lecture, écriture et calcul pour les enfants de CP. |
| Mon jardin | [`mon-jardin/`](mon-jardin/) | Éditeur de plan de jardin à l'échelle, façon paysagiste. |

## Mon jardin

Concevoir et visualiser son jardin, à l'échelle :

- **Plusieurs plans nommés**, retrouvés sur la page d'accueil (aperçu, surface, nombre de végétaux) ; renommer, dupliquer, exporter, supprimer.
- **Trois façons de commencer** : feuille blanche (rectangle), contour libre point par point, ou photo aérienne / plan scanné mis à l'échelle à partir d'une distance connue.
- **Relevé de l'existant sur la photo** : détection automatique des arbres et des piscines (à valider d'un toucher), et outils rapides pour tracer maison, piscine, terrasse, arbres et arbustes existants.
- **Formes orientables** : toute zone carrée ou rectangulaire (maison, piscine, terrasse, potager, serre…) pivote avec sa poignée, au degré près.
- **Plus de 200 espèces**, avec une large palette méditerranéenne (oliviers, agrumes, fruits à coque, arbustes de garrigue, palmiers, aromatiques…). On peut ajouter ses propres espèces et variétés.
- **Aménagements** : maison, terrasse, piscine, potager, poulailler, serre, bassin, ruche, chemins, clôtures, haies, irrigation, repères et étiquettes.
- **Deux vues** : détaillée (avec les noms des végétaux) et simplifiée ; curseur de croissance (de la plantation à l'âge adulte) ; contrôle des distances de plantation par rapport aux limites (art. 671 du Code civil).
- **Export** du plan en image PNG et en sauvegarde `.json`, importable sur un autre appareil.

Un exemple de plan est fourni au premier lancement : une maison avec piscine et un jardin méditerranéen.

Les plans sont enregistrés dans le navigateur de l'appareil utilisé (aucun compte, aucun serveur). Pour les garder en sécurité ou les transférer, utilisez l'export.
