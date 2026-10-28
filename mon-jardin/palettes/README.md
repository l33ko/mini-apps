# Palettes végétales

Bases d'espèces et de variétés à charger dans l'app **Mon jardin** : ⚙ Palette → ⇅ Importer / exporter. Sur la version GitHub Pages, un bouton « Palettes prêtes à charger » les importe en un clic ; ailleurs, importez le fichier .csv ou .json.
L'import ajoute uniquement les espèces et variétés absentes ; rien n'est supprimé ni remplacé.

| Fichier | Contenu |
|---|---|
| [`jardin-foret-sylvaniers.csv`](jardin-foret-sylvaniers.csv) | Liste complète du jardin-forêt Sylvaniers : 108 espèces, 227 lignes espèce / variété. À ouvrir dans un tableur. |
| [`jardin-foret-sylvaniers.json`](jardin-foret-sylvaniers.json) | La même liste, au format de l'app. |

## Format CSV

Format CSV standard : séparateur virgule, décimales avec un point, encodage UTF-8. GitHub l'affiche comme un tableau ; Google Sheets l'ouvre directement (Fichier → Importer). Une ligne par variété :

| Colonne | Obligatoire | Exemple |
|---|---|---|
| Catégorie | non | `Arbres fruitiers à pépins` |
| Espèce | **oui** | `Poirier` |
| Variété | non (vide = espèce sans variété précisée) | `Guyot` |
| Envergure (m) | non | `5` |
| Hauteur (m) | non | `2.5` |
| Couleur feuillage | non | `#5f9c45` |
| Couleur fruits/fleurs | non | `#c9c43a` |

L'app accepte aussi les fichiers séparés par des points-virgules (export Excel en français).

Catégories reconnues : arbres fruitiers à noyau, à pépins, à coque, agrumes, autres fruitiers, arbres d'ombrage / forestiers / d'ornement, arbustes / haies / brise-vent, plantes grimpantes, subtropicaux / palmiers / succulentes, potager / aromatiques / épices, fleurs / vivaces.

Plusieurs variétés peuvent aussi tenir dans une même cellule, séparées par des virgules, la cellule étant alors entre guillemets (`Poirier,"William, Guyot, Conférence"`). Une colonne absente prend la valeur de l'espèce déjà connue, ou une valeur par défaut.

Pour compléter la base : ajoutez des lignes au CSV puis réimportez-le, ou exportez votre palette depuis l'app (⇩ Tableur) et remplacez ce fichier.
