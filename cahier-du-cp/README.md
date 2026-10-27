# Mon cahier du CP

Application web éducative pour les enfants de CP (6-7 ans). Elle s'ouvre dans n'importe quel navigateur (iPhone, iPad, ordinateur), tient dans un seul fichier `index.html` et n'a besoin ni d'installation ni de compte.

L'interface imite un cahier à lignes Seyès, avec de gros boutons faciles à toucher, des sons et une voix qui lit les mots à voix haute. Les activités s'inspirent du programme de CP (cycle 2) du ministère de l'Éducation nationale. Le tableau ci-dessous dit honnêtement ce qui correspond au programme et ce qui reste à faire.

## Les activités

**Lecture et écriture**
- **Lecture** : retrouver le mot qui correspond à une image, ou écouter un mot et le retrouver.
- **Écriture** : reconnaître un mot en écriture attachée (cursive) ou en écriture bâton.
- **Mots à compléter** : retrouver la ou les lettres manquantes d'un mot.
- **Phrases** : remettre des étiquettes dans l'ordre pour construire une phrase, avec la majuscule au début et le point à la fin. Chaque étiquette touchée est lue à voix haute.

**Mathématiques**
- **Additions** et **soustractions** : de 0 à 5 jusqu'à 99, avec le passage de la dizaine aux niveaux avancés.
- **Compléments** : 7 + ? = 10, puis jusqu'à 20 et 100.
- **Problèmes** : petites histoires de la vie courante (donner des pommes, la monnaie rendue par la marchande, des boîtes qui contiennent le même nombre d'objets), lues à voix haute sur demande.
- **Compter** : dénombrer des objets à l'écran.
- **Doubles et moitiés** : doubles, moitiés, groupes égaux, puis les tables de 2, 3, 4, 5 et 10 aux derniers niveaux seulement.
- **Maths mélangées** : un défi qui combine additions, soustractions, compléments et doubles.

**Jeux**
- **Memory** : associer chaque image à son mot.
- **Suites** : trouver ce qui vient ensuite dans une suite d'images ou de nombres.
- **Morpion** : jouer contre l'ordinateur.
- **Intrus** : trouver l'élément qui n'est pas comme les autres.

## Lien avec le programme de CP

| Domaine du programme | Ce que fait l'application | État |
| --- | --- | --- |
| Lire des mots, mots fréquents | Lecture de mots à partir d'images ou d'un mot entendu | Couvert en partie |
| Écrire en cursive | L'enfant reconnaît les mots en cursive et en bâton, mais il ne les trace pas | Partiel |
| Encoder et orthographier des mots | Lettres manquantes dans un mot | Partiel |
| Phrase : majuscule, ponctuation, ordre des mots | Reconstruction de phrases avec étiquettes | Couvert en partie |
| Nombres jusqu'à 100 | Additions et soustractions jusqu'à 99, compter par dizaines et unités | Couvert en partie |
| Problèmes additifs en une ou deux étapes | Problèmes en une étape | Partiel |
| Problèmes multiplicatifs en une étape (nombres jusqu'à 30, sans les signes × et :) | Problèmes de boîtes à contenu égal, mais certains dépassent 30 | À ajuster |
| Compléments à 10, doubles, moitiés | Activités « Compléments » et « Doubles et moitiés » | Couvert |
| Tables de multiplication | Tables de 2, 3, 4, 5 et 10 aux derniers niveaux | Au-delà du programme de CP |

Les attendus de fin de CP en mathématiques ne mentionnent pas les tables de multiplication : le champ multiplicatif y apparaît seulement sous forme de problèmes. Cette activité est donc un bonus pour les enfants en avance, pas un attendu.

## Niveaux et progression

- Chaque activité a **10 niveaux** (🌱 1 à 3 facile, 🌿 4 à 7 moyen, 🌳 8 à 10 difficile). La difficulté monte toute seule, sans lien avec les semaines des manuels : l'enfant avance à son rythme, en complément de la classe.
- Tous les niveaux restent accessibles : l'enfant peut aller plus vite ou reprendre un niveau plus facile quand il veut. Rejouer un niveau plus facile ne fait pas baisser son niveau.
- Les anciens profils et codes de sauvegarde (3 niveaux) sont convertis automatiquement.
- Une série compte 10 questions. Les étoiles (1 à 3) dépendent des bonnes réponses du premier coup.
- Le niveau s'adapte aux résultats : il monte avec 9 bonnes réponses ou plus, et baisse avec 4 ou moins.
- À partir du niveau 4 en maths, l'enfant tape la réponse sur un clavier de chiffres au lieu de choisir parmi des propositions.
- **Mode clair ou sombre** : un bouton du menu change les couleurs (clair, pastel et coloré par défaut).
- **Consignes audio** : chaque énoncé est lu à voix haute automatiquement, et un bouton 🔊 Écouter permet de le réécouter. « Essaie encore » est aussi dit en cas d’erreur ; une bonne réponse est signalée par un son, sans message. L'option « Consignes » du menu permet de couper la lecture automatique.
- Un son distingue les bonnes et les mauvaises réponses, et un petit son accompagne chaque bouton.

## Joueurs et sauvegarde

- Chaque enfant a son profil, créé avec un simple prénom. Les étoiles et les niveaux sont gardés sur l'appareil, dans le navigateur.
- Pour passer d'un appareil à un autre, un **code de sauvegarde** (commençant par `CP1-`) se copie depuis le bouton « Sauvegarde » et se colle sur le nouvel appareil.
- Aucune donnée n'est envoyée sur un serveur. Seul le prénom saisi est conservé, sur l'appareil.

## Espace parents

- Un compteur affiche le temps de jeu restant. Par défaut, une session dure **15 minutes**.
- À la fin, l'écran se verrouille. Un adulte doit résoudre un petit calcul (par exemple 7 × 4) pour accéder à l'espace parents.
- Les parents peuvent choisir la durée (5, 10, 15, 20, 30, 45 ou 60 minutes, ou sans limite), relancer une session ou gérer la sauvegarde.
- Une nouvelle session démarre automatiquement chaque jour.
- Ce contrôle n'est pas une protection absolue : vider les données du navigateur ou changer de navigateur remet le compteur à zéro.

## Utiliser l'application

1. Ouvrir `index.html` dans un navigateur, ou publier le dépôt avec GitHub Pages (Settings > Pages, branche `main`, dossier `/ (root)`).
2. Avec GitHub Pages, l'application est alors disponible à l'adresse `https://l33ko.github.io/mini-apps/cahier-du-cp/`.

## Notes techniques

- Un seul fichier HTML avec son CSS et son JavaScript, sans dépendance ni outil de build.
- Seules les polices Andika et Playwrite FR Trad (écriture cursive) viennent de Google Fonts. Sans connexion, le navigateur utilise une police de secours.
- La voix utilise la synthèse vocale du navigateur (`speechSynthesis`), en choisissant de préférence une voix française féminine. Les sons sont générés avec l'API Web Audio.
- Pour que l'application joue des sons et parle sur iPhone, le bouton de sourdine doit être désactivé et le volume média monté.
- Les données sont dans le `localStorage` du navigateur : elles disparaissent si on vide les données du site ou en navigation privée.

## Idées pour la suite

- Dictée de mots, copie de phrases, singulier et pluriel, accents.
- Lecture de l'heure, rangement de nombres, labyrinthe.

## Sources

- Attendus de fin d'année de CP en mathématiques : [ministère de l'Éducation nationale](https://education.gouv.fr/media/28958/download)
- Résumé des attendus de français au CP : [résumé par niveaux du programme de français du cycle 2](https://maitresselunicole.fr/wp-content/uploads/2025/03/resume-par-niveaux-programme-de-francais-cycle-2-2024-3.pdf) (document d'une enseignante, à comparer avec le texte officiel)
