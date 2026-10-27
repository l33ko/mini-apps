# Mon cahier du CP

Petite application web éducative pour une enfant de 6 ans en CP. Elle s'ouvre dans n'importe quel navigateur (iPhone, iPad, ordinateur), tient dans un seul fichier `index.html` et n'a besoin ni d'installation ni de compte.

L'interface imite un cahier à lignes Seyès, avec de gros boutons faciles à toucher, des sons et une voix qui lit les mots à voix haute.

## Les activités

**Lecture et écriture**
- **Lecture** : retrouver le mot qui correspond à une image, ou écouter un mot et le retrouver.
- **Écriture** : reconnaître un mot en écriture attachée (cursive) ou en écriture bâton.
- **Mots à compléter** : retrouver la ou les lettres manquantes d'un mot.
- **Phrases** : remettre des étiquettes dans l'ordre pour construire une phrase. Chaque étiquette touchée est lue à voix haute.

**Mathématiques**
- **Additions** et **soustractions** jusqu'à 20.
- **Multiplications** avec les tables de 2, 3, 4, 5 et 10.
- **Problèmes** : petites histoires de la vie courante (partager des pommes, la monnaie rendue par la marchande), lues à voix haute sur demande.
- **Compter** : dénombrer des objets à l'écran.
- **Maths mélangées** : un défi qui combine les trois opérations.

**Jeux**
- **Memory** : associer chaque image à son mot.
- **Suites** : trouver ce qui vient ensuite dans une suite d'images ou de nombres.
- **Morpion** : jouer contre l'ordinateur.
- **Intrus** : trouver l'élément qui n'est pas comme les autres.

## Niveaux et progression

- Chaque activité a trois niveaux : facile, moyen et difficile. L'enfant choisit son niveau avant de jouer.
- Une série compte 10 questions. Les étoiles (1 à 3) dépendent des bonnes réponses du premier coup.
- Le niveau s'adapte aux résultats : il monte avec 9 bonnes réponses ou plus, et baisse avec 4 ou moins.
- Aux niveaux 2 et 3 des maths, l'enfant tape la réponse sur un clavier de chiffres au lieu de choisir parmi des propositions.
- Un son distingue les bonnes et les mauvaises réponses, et un petit son accompagne chaque bouton.

## Joueurs et sauvegarde

- Chaque enfant a son profil, créé avec un simple prénom. Les étoiles et les niveaux sont gardés sur l'appareil, dans le navigateur.
- Pour passer d'un appareil à un autre, un **code de sauvegarde** (commençant par `CP1-`) se copie depuis le bouton « Sauvegarde » et se colle sur le nouvel appareil.
- Aucune donnée n'est envoyée sur un serveur. Seul le prénom saisi est conservé, sur l'appareil.

## Espace parents

- Un compteur affiche le temps de jeu restant. Par défaut, une session dure **15 minutes**.
- À la fin, l'écran se verrouille. Un adulte doit résoudre une multiplication (par exemple 17 × 8) pour accéder à l'espace parents.
- Les parents peuvent choisir la durée (5, 10, 15, 20, 30, 45 ou 60 minutes, ou sans limite), relancer une session ou gérer la sauvegarde.
- Une nouvelle session démarre automatiquement chaque jour.
- Ce contrôle n'est pas une protection absolue : vider les données du navigateur ou changer de navigateur remet le compteur à zéro.

## Utiliser l'application

1. Ouvrir `index.html` dans un navigateur, ou publier le dépôt avec GitHub Pages (Settings > Pages, branche `main`, dossier `/ (root)`).
2. Avec GitHub Pages, l'application est alors disponible à l'adresse `https://l33ko.github.io/mini-apps/cahier-du-cp/`.

## Notes techniques

- Un seul fichier HTML avec son CSS et son JavaScript, sans dépendance ni outil de build.
- Seule la police Andika (et Playwrite FR Trad pour l'écriture cursive) vient de Google Fonts. Sans connexion, le navigateur utilise une police de secours.
- La voix utilise la synthèse vocale du navigateur (`speechSynthesis`), en choisissant de préférence une voix française féminine. Les sons sont générés avec l'API Web Audio.
- Pour que l'appli joue des sons et parle sur iPhone, le bouton de sourdine doit être désactivé et le volume média monté.
- Les données sont dans le `localStorage` du navigateur : elles disparaissent si on vide les données du site ou en navigation privée.

## Idées pour la suite

- Dictée de mots, lecture de l'heure, rangement de nombres, labyrinthe.
- Davantage de mots, de phrases et de problèmes.
