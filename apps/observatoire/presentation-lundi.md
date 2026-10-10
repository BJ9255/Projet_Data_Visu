# Présentation de lundi — environ cinq minutes

## 0:00–0:50 · La cible, le besoin et la question

Bonjour à toutes et à tous. Je vous présente l’Observatoire des profils, une application qui explore les caractéristiques individuelles et les habitudes de vie.

J’ai choisi de m’adresser à des étudiants qui découvrent l’analyse de données. Leur besoin est de comprendre une analyse multivariée sans avoir à maîtriser immédiatement tous ses détails mathématiques.

Mon objectif est donc de rendre les profils visibles et explorables. Ma problématique est la suivante : quels profils se ressemblent et comment les classes de poids se répartissent-elles parmi ces profils ?

Le fichier contient 1 610 personnes, âgées de 18 à 54 ans, et 15 variables, notamment l’âge, la taille, l’alimentation et l’activité physique.

**À l’écran :** présenter le bandeau d’accueil, puis cliquer sur « Explorer la carte ».

## 0:50–1:50 · Pourquoi une carte d’AFDM ?

Pour répondre à cette question, j’ai choisi l’analyse factorielle des données mixtes, ou AFDM. Elle permet d’étudier ensemble des variables numériques, comme l’âge et la taille, et des variables qualitatives, comme les réponses sur les habitudes.

Chaque point représente une personne. Les couleurs indiquent les classes de poids. Sur les deux axes affichés, deux points proches ont des profils qui se ressemblent davantage. Les contours aident à lire la dispersion des classes : ce ne sont pas des frontières de classification.

Un choix important est que le sexe et la classe de poids ne participent pas à la construction des axes. Ils servent ensuite à interpréter les profils. La représentation est donc construite à partir des autres caractéristiques.

**À l’écran :** montrer les trois repères de lecture, puis la carte. Survoler un point pour afficher ses informations.

## 1:50–2:50 · Une exploration concrète

Pour éviter de présenter toutes les variables en même temps, l’application propose d’explorer une caractéristique à la fois. Je commence par l’activité physique.

Les icônes situent les différentes réponses sur la carte : un canapé pour aucune activité, une silhouette pour la marche ou la course. Les libellés donnent les fréquences exactes. Si je sélectionne « Aucune », les personnes ayant donné cette réponse sont mises en évidence. Les autres restent en arrière-plan et les axes restent les mêmes.

Le site donne ensuite des chiffres pour compléter la lecture. Ici, cette réponse concerne 206 personnes. Parmi elles, 53 sont dans la classe d’insuffisance pondérale, 113 dans celle du poids normal, 31 dans celle du surpoids et 9 dans celle de l’obésité.

Ces résultats décrivent ce groupe dans ce fichier. Ils ne permettent pas d’affirmer qu’une absence d’activité protège contre l’obésité : les autres caractéristiques, la collecte et la composition de l’échantillon doivent être prises en compte.

**À l’écran :** choisir « Aucune », montrer la mise en évidence et l’encadré de répartition. Ne pas présenter cet exemple comme une recommandation de santé.

## 2:50–3:45 · Passer de la carte aux proportions

Une carte peut suggérer une piste, mais elle ne suffit pas pour quantifier une comparaison. Le deuxième onglet permet donc d’examiner les réponses au sein de chaque classe de poids.

Chaque barre représente 100 % d’une classe. On peut ainsi comparer la répartition des niveaux d’activité physique d’une classe à l’autre.

Cette lecture est différente de l’encadré précédent : tout à l’heure, nous partions d’une réponse et regardions les classes de poids. Ici, nous partons d’une classe et regardons ses réponses. Le site précise ce changement pour éviter de confondre les pourcentages.

Il est également possible de sélectionner un groupe selon le sexe ou l’âge. Le nombre de personnes retenues reste visible. Ces filtres s’appliquent à la comparaison ; la carte d’AFDM conserve le jeu complet.

**À l’écran :** cliquer sur « Comparer les habitudes », sélectionner « Femme », puis réinitialiser. Montrer une proportion réellement affichée si le temps le permet.

## 3:45–4:30 · Ce que la méthode permet de voir

Le troisième onglet explique ce qui construit la carte et quelles variables contribuent le plus aux axes.

Les deux premiers axes représentent environ 19,8 % de l’inertie totale. Cela signifie que la carte est une projection partielle des profils : des points proches à l’écran peuvent présenter des différences sur d’autres dimensions.

J’ai donc choisi d’accompagner la carte de comparaisons descriptives et d’afficher ses limites directement dans le parcours.

**À l’écran :** ouvrir « Comprendre la méthode » et montrer brièvement l’inertie et les contributions.

## 4:30–5:00 · Conclusion

Pour répondre à ma problématique, l’application propose trois étapes : explorer les ressemblances entre profils, comparer les habitudes selon les classes de poids, puis comprendre les limites de la méthode.

L’intérêt du projet est de rendre une analyse complexe accessible à la cible choisie et de lui permettre de poser ses propres questions. Les résultats restent des associations observées dans cet échantillon : ils ne démontrent pas une causalité et ne constituent pas un diagnostic.

Merci pour votre attention.

## Questions possibles

- **Pourquoi l’AFDM ?** Elle traite ensemble les variables quantitatives et qualitatives.
- **Pourquoi des variables supplémentaires ?** Le sexe et la classe de poids servent à interpréter des axes construits indépendamment de ces deux variables.
- **Pourquoi garder les axes fixes ?** Pour conserver un repère commun lorsqu’on change la caractéristique explorée.
- **Pourquoi seulement deux axes ?** Pour rendre l’exploration lisible. La part d’inertie et les limites sont affichées ; les deux axes ne suffisent pas à résumer toute l’analyse.
- **Peut-on généraliser ?** Pas sans vérifier la collecte et la représentativité de l’échantillon.
- **Que montrent les ellipses ?** Des contours normaux à 80 % construits à partir des centres et covariances de chaque classe, pas une classification ni une garantie que exactement 80 % des points observés sont à l’intérieur.
- **D’où viennent les données ?** La référence affichée est Koklu et Sulak (2024). Les conditions de collecte doivent être vérifiées dans l’article avant de les détailler.

## Répétition

Lancer l’application avant la séance, garder les filtres réinitialisés et la carte sur « Toutes les réponses ». Répéter le parcours avec un chronomètre en visant 4 min 30, puis préparer quelques captures de secours des trois onglets.

## Variante : intégrer l’assistant en 45 secondes

Remplacer une partie de la démonstration d’exploration, pour garder le même temps total :

« Pour rendre cette exploration plus accessible, j’ai ajouté un assistant. L’utilisateur décrit ses habitudes avec ses mots ; un modèle de langage les traduit en réponses compatibles avec le fichier. Il doit ensuite vérifier et confirmer ces réponses.

Par exemple, l’activité physique un à deux jours par semaine et les déplacements à pied correspondent simultanément à 36 personnes dans ce fichier. Les calculs sont faits par R ; le modèle aide à comprendre le résultat. Un bouton permet de retrouver ces personnes sur la carte.

Cette comparaison n’est pas une estimation du risque individuel. L’assistant est une porte d’entrée vers les données, et ses réponses restent accompagnées des limites de l’échantillon. »

**Parcours :** « Explorer mon profil » → « Essayer un exemple » → « Comprendre mon profil » → vérifier « 1-2 jours » et « Marche » → « Confirmer et comparer » → « Voir ces personnes sur la carte ».

Pour la démonstration, vérifier le fournisseur réellement affiché. Ne pas annoncer une connexion OpenAI tant que la clé API n’a pas été configurée et un appel réel vérifié. Le modèle local peut servir à répéter le parcours sans appel externe.
