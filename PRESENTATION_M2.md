# Présentation M2 — Proportions, χ² et AFDM

## Notre cadrage

**Cible :** étudiants et acteurs de prévention souhaitant comprendre les associations entre habitudes de vie et catégories de poids.

**Problématique :** « Quelles habitudes sont associées aux catégories de poids dans cet échantillon, et comment s’organisent-elles en profils de vie ? »

**But :** rendre les associations observées compréhensibles, explorer les profils et expliciter les limites de leur interprétation.

**Parcours :** Cadrer → Observer → Tester → Explorer l’AFDM → Conclure.

Les méthodes utilisées sont celles du cours : tableaux de proportions, test du χ² d’indépendance, Fisher si les conditions du χ² ne sont pas satisfaites, et AFDM. Le choix de l’AFDM repose sur la présence de variables quantitatives et qualitatives. Nous ne cherchons pas à utiliser toutes les méthodes vues en cours : chacune doit répondre à une question précise.

Source du jeu de données : [Koklu et Sulak (2024)](https://doi.org/10.33484/sinopfbd.1445215). Les résultats ci-dessous sont calculés à partir du fichier du projet. Implémentation des tests : documentation officielle R du [χ²](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/chisq.test.html) et de [Fisher](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/fisher.test.html).

## Speech — environ 5 à 7 minutes

### 1. Cadrer

« Notre projet cherche à répondre à une question : quelles habitudes sont associées aux catégories de poids dans cet échantillon, et comment s’organisent-elles en profils de vie ?

Nous nous adressons à des étudiants et à des acteurs de prévention qui souhaitent comprendre les associations observées et leurs limites. Le site permet d’explorer les données, de comparer des répartitions et de lire une carte de profils.

Notre fichier contient 1 610 réponses à une enquête en ligne réalisée en Turquie, présentée par Koklu et Sulak en 2024. Les répondants ont entre 18 et 54 ans. Nous disposons de 14 caractéristiques : 10 habitudes de vie et 4 caractéristiques individuelles. La variable étudiée comporte quatre catégories de poids.

Dans le fichier, 54,6 % des répondants sont classés en surpoids ou en obésité. Cela décrit cet échantillon. La représentativité de l’enquête n’est pas établie, donc nous ne présentons pas ce chiffre comme une prévalence dans la population turque.

Notre parcours est simple : observer les répartitions, tester l’indépendance, puis explorer les profils avec l’AFDM. »

**Montrer :** problématique, cible et répartition de l’accueil.

### 2. Observer

« Nous commençons par les proportions. Chaque barre représente 100 % des personnes ayant donné une réponse, et son effectif est affiché. Cela permet de comparer les répartitions sans confondre proportion et nombre de personnes.

Pour la consommation de légumes, la part observée de surpoids ou d’obésité est de 86,8 % chez les personnes répondant “rarement”, contre 20,3 % chez celles répondant “toujours”. Ces groupes comptent respectivement 400 et 502 personnes.

Il s’agit d’un écart descriptif. Ce graphique ne démontre pas que la consommation de légumes provoque une modification du poids. D’autres caractéristiques peuvent intervenir, et l’enquête ne renseigne pas sur la chronologie.

Le site permet de changer la caractéristique étudiée et de retrouver les quatre catégories dans chaque réponse. L’âge et la taille sont regroupés uniquement pour ces graphiques descriptifs ; ils restent quantitatifs dans l’AFDM. »

**Montrer :** barres des légumes, puis une autre variable. Ne pas dire que les légumes sont « la variable la plus importante » : nous n’avons pas établi ce classement.

### 3. Tester

« Pour étudier l’association entre une caractéristique qualitative et la catégorie de poids, nous utilisons un tableau de contingence et le test du χ² d’indépendance.

L’hypothèse nulle est l’indépendance des deux variables. Le test compare les effectifs observés aux effectifs attendus sous cette hypothèse. Pour une cellule, l’effectif attendu est le produit du total de sa ligne par le total de sa colonne, divisé par l’effectif total.

Il faut vérifier les conditions à partir des effectifs attendus. Nous retenons la règle suivante : aucun attendu inférieur à 1, et au moins 80 % des cellules avec un attendu supérieur ou égal à 5. Dans les douze tableaux de variables qualitatives du fichier, ces conditions sont satisfaites. Si elles ne l’étaient pas, le programme utiliserait Fisher.

Pour les légumes, le χ² vaut environ 554,67 avec 6 degrés de liberté et une p-value inférieure à 0,001. Nous rejetons l’hypothèse d’indépendance au seuil de 5 % : une association est détectée dans ce tableau.

Le résumé “surpoids ou obésité” regroupait deux catégories pour décrire l’écart. Le test utilise bien les quatre catégories d’origine, sur l’ensemble du tableau.

La p-value ne donne ni la force du lien ni la probabilité que l’hypothèse nulle soit vraie. Les douze comparaisons sont exploratoires, avec des p-values brutes : le seuil de 5 % s’applique à chaque test, sans garantie globale sur l’ensemble. Enfin, ce test ne tient pas compte des autres caractéristiques et ne démontre pas une causalité. »

**Montrer :** variable “Légumes”, résultat, conditions, puis cocher “Effectifs attendus” pour expliquer une cellule.

### 4. Explorer l’AFDM

« Les tableaux et les tests examinent les variables deux à deux. Pour explorer les caractéristiques conjointement, nous utilisons l’analyse factorielle des données mixtes, ou AFDM.

Elle est adaptée ici parce que nous combinons deux variables quantitatives, l’âge et la taille, avec douze variables qualitatives. Les quatorze caractéristiques construisent les axes. La catégorie de poids est supplémentaire : elle est projetée pour aider à lire la carte, sans participer à sa construction.

Un point représente une personne. Les icônes indiquent les modalités de la caractéristique sélectionnée, et les couleurs et formes distinguent les catégories de poids. Nous pouvons mettre en avant les personnes ayant donné une réponse et consulter leur répartition observée.

Les deux premiers axes représentent 19,5 % de l’inertie. Cette carte est donc une projection partielle : des points proches sur le plan ne sont pas nécessairement proches sur toutes les dimensions. Les modalités donnent des repères pour lire les profils, pas des frontières qui permettraient de classer une nouvelle personne.

Nous pouvons ainsi explorer comment les habitudes et les caractéristiques individuelles s’organisent ensemble, en gardant cette limite de projection visible. »

**Montrer :** sélectionner “Légumes”, mettre “Toujours” en avant, puis afficher l’activité physique. Garder les ellipses désactivées pour la première lecture.

### 5. Conclure

« Pour répondre à notre problématique, les répartitions des catégories de poids diffèrent selon certaines habitudes, comme la consommation de légumes. Le χ² détecte une association dans ce tableau, et l’AFDM permet d’explorer les caractéristiques dans leur ensemble.

Notre site apporte trois réflexes : regarder les effectifs derrière les proportions, distinguer description et test statistique, et tenir compte des limites d’une projection.

Nous restons prudents : l’enquête est en ligne, sa représentativité n’est pas établie et les réponses sont recueillies à un seul moment. Nous ne pouvons pas établir de causalité. Le fichier ne contient ni poids ni IMC, donc nous ne pouvons pas recalculer les catégories fournies.

Notre contribution est une lecture interactive et argumentée de cet échantillon. Une visualisation utile rend les liens visibles et leurs limites compréhensibles. »

## Les chiffres à connaître

| Élément | Résultat |
|---|---|
| Effectif | 1 610 personnes, 18–54 ans |
| Catégories | Insuffisance pondérale 73 ; Normal 658 ; Surpoids 592 ; Obésité 287 |
| Surpoids ou obésité | 879 / 1 610 = 54,6 % |
| Légumes : Rarement | Surpoids ou obésité 86,8 %, n = 400 |
| Légumes : Toujours | Surpoids ou obésité 20,3 %, n = 502 |
| χ² légumes × catégorie | 554,67 ; ddl = 6 ; p < 0,001 |
| AFDM | 14 caractéristiques actives, catégorie de poids supplémentaire |
| Plan affiché | 19,5 % de l’inertie |

## Questions possibles du jury

**Pourquoi une AFDM ?** Deux variables sont quantitatives et douze qualitatives. L’AFDM permet de les combiner. Une ACP convient à des variables quantitatives ; une ACM à des variables qualitatives.

**Pourquoi le χ² ?** Nous croisons deux variables qualitatives dans un tableau d’effectifs. Le test évalue l’hypothèse d’indépendance.

**Pourquoi pas Student ?** Student compare des moyennes d’une variable quantitative entre deux groupes. Il conviendrait à une question dédiée de comparaison de moyennes, mais pas directement à celle de la répartition des quatre catégories de poids selon les réponses qualitatives.

**Quand utiliser Fisher ?** Quand les conditions retenues pour l’approximation du χ² sur les effectifs attendus ne sont pas satisfaites. Ici, tous les tableaux complets satisfont ces conditions ; Fisher est une possibilité de repli, pas un résultat présenté comme utilisé.

**Une cellule observée nulle invalide-t-elle le χ² ?** Pas automatiquement. Le contrôle porte sur les effectifs attendus sous H₀, pas sur les seuls effectifs observés.

**Le transport a une cellule attendue inférieure à 5 : est-ce acceptable ?** Le minimum est environ 4,26, mais aucune cellule n’est inférieure à 1 et 95 % des cellules sont au moins égales à 5. La règle retenue est donc satisfaite. Si le cours impose la règle plus stricte “tous les attendus ≥ 5”, il faut adapter ce choix à cette consigne.

**Comment calcule-t-on les degrés de liberté ?** (Nombre de lignes − 1) × (nombre de colonnes − 1). Pour les légumes : (3 − 1) × (4 − 1) = 6.

**Une p-value très faible signifie-t-elle un lien très fort ?** Non. Elle indique une incompatibilité avec H₀ selon le test. Elle dépend aussi de l’effectif et ne mesure pas une taille d’effet.

**Si H₀ n’est pas rejetée, l’indépendance est-elle démontrée ?** Non. Le test n’a pas mis en évidence une association au seuil retenu ; cela n’est pas une preuve d’indépendance.

**La proximité sur la carte suffit-elle à interpréter un profil ?** La carte ne conserve qu’une partie de l’inertie. Les distances sur le plan doivent être lues comme une projection, en regardant les axes et leurs pourcentages.

**Les ellipses contiennent-elles exactement 80 % des personnes ?** Non. Ce sont des repères de dispersion fondés sur une approximation normale et sur la covariance de chaque catégorie, pas une couverture empirique garantie ni un intervalle de confiance. Elles restent calculées sur la catégorie entière lorsqu’une réponse est sélectionnée.

**Le projet permet-il de connaître le risque d’une personne ?** Les proportions sont observées dans l’échantillon et l’AFDM sert à explorer. Nous n’estimons pas un risque futur ni un diagnostic individuel.

## Préparation pratique

1. Ouvrir et actualiser le site avant l’oral ; garder le serveur R actif.
2. Suivre les cinq étapes du menu. Le mode présentation agrandit les textes secondaires ; le quitter pour ouvrir une annexe fermée.
3. Répéter une comparaison en barres, l’explication d’un attendu dans le χ² et deux sélections sur la carte. Cela suffit pour montrer l’interactivité.
4. Répartir les étapes entre les membres du groupe, avec une seule problématique commune.
5. Vérifier le rendu sur l’ordinateur et le vidéoprojecteur de présentation. Les contrôles automatiques vérifient les calculs et les sorties Shiny, mais le navigateur n’a pas pu être inspecté pendant cette intervention.
