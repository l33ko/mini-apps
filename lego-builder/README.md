# Lego Builder

Application web qui guide un enfant de 8-10 ans pour monter des constructions en briques Lego classiques, étape par étape, comme une notice. Elle tient dans un seul fichier `index.html`, s'ouvre dans n'importe quel navigateur (iPhone, iPad, ordinateur) et n'a besoin ni d'installation ni de compte.

## Les modèles

| Modèle | Difficulté | Pièces |
|---|---|---|
| 🦩 Le flamant rose | ★★☆☆ | 36 |
| 🚁 L'hélicoptère de secours | ★★☆☆ | 30 |
| 🚒 Le camion de pompiers | ★★☆☆ | 57 |
| 🐕 Le berger australien (tricolore) | ★★★☆ | 60 |
| 🦖 Le T-rex | ★★★☆ | 47 |
| 🎄 La cabane de Noël | ★★★☆ | 78 |
| 👑 La maison de princesse | ★★★☆ | 80 |
| 🏴‍☠️ Le bateau pirate | ★★★☆ | 62 |
| 🏰 Le château fort | ★★★★ | 129 |
| 🚀 Le chasseur stellaire | ★★★★ | 99 |

Les modèles sont des créations originales, pas des notices officielles Lego.

## Comment ça marche

- **Rassemble tes pièces** : avant de commencer, la liste de toutes les pièces avec leur image, leur taille et leur couleur. On touche une pièce pour la cocher quand on l'a trouvée.
- **Étapes en 3D** : le modèle se tourne avec le doigt et se zoome en pinçant. Les nouvelles pièces tombent en place et des flèches orange montrent où les poser. Au plus 6 pièces par étape.
- **Voix** : le bouton 🔊 lit la consigne à voix haute.
- **Progression** : l'étape en cours est gardée dans le navigateur ; les modèles terminés sont marqués « ✓ Réussi ».
- **Fin** : confettis, fanfare et mode « Admirer » où le modèle tourne tout seul.

## Ajouter un modèle

Les modèles sont décrits « en cubes » dans le code (classe `Vox`) : on remplit les cases de chaque rangée avec une couleur, et l'application découpe automatiquement chaque rangée en briques classiques (1×1 à 2×8) en croisant les joints d'une rangée à l'autre, comme pour un vrai mur. Les pièces spéciales (plaques, pentes, cônes, roues, tuiles) s'ajoutent à la main avant, entre ou après les rangées.
