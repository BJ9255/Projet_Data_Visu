# Script oral — projet actuel — 15 minutes

Environ 2 090 mots à prononcer : à 150 mots par minute, environ 14 minutes de
parole et une minute de manipulations et de pauses. À un débit plus lent,
raccourcir le texte après une répétition chronométrée.
Les horaires sont des repères de répétition : chronométrer une lecture réelle
avant l’examen et adapter le débit. Les instructions entre crochets ne se lisent pas.
Le « nous » convient à une présentation de groupe ; les passages peuvent être répartis.

| Temps | Page | Durée |
|---|---|---:|
| 0:00–2:00 | Cadrer : question et données | 2 min |
| 2:00–5:00 | Observer : légumes et activité physique | 3 min |
| 5:00–8:30 | Tester : χ² et V de Cramér | 3 min 30 |
| 8:30–13:00 | Explorer l’AFDM : méthode et démonstration | 4 min 30 |
| 13:00–15:00 | Conclure : réponse, limites et perspectives | 2 min |

## 0:00–2:00 — Cadrer

[Afficher l’accueil. Pointer la problématique, puis le panneau des chiffres.]

Bonjour. Nous allons vous présenter notre application de visualisation consacrée
aux habitudes de vie et aux catégories de poids. Nous avons organisé le site
autour d’une question : quelles habitudes sont associées aux catégories de poids
dans cet échantillon, et comment s’organisent-elles en profils de vie ?

L’objectif est de passer progressivement d’une lecture simple des répartitions
à une exploration de plusieurs caractéristiques ensemble. Le parcours comporte
cinq étapes : cadrer les données, observer les différences, tester les associations,
explorer l’AFDM et conclure. Cette organisation guide la lecture et permet de
revenir aux données pour vérifier les résultats.

Notre fichier contient mille six cent dix réponses à une enquête en ligne menée
en Turquie, présentée par Koklu et Sulak dans un article de 2024. Les personnes
du fichier ont entre dix-huit et cinquante-quatre ans. Nous étudions quatorze
caractéristiques : dix habitudes de vie et quatre caractéristiques individuelles.
Parmi elles figurent les légumes, l’activité physique, les repas, le transport,
mais aussi l’âge, la taille, le sexe déclaré et les antécédents familiaux.

La variable que nous cherchons à caractériser comporte quatre modalités :
insuffisance pondérale, normal, surpoids et obésité. Les groupes sont de tailles
différentes : soixante-treize personnes en insuffisance pondérale, six cent
cinquante-huit dans la catégorie normale, cinq cent quatre-vingt-douze en
surpoids et deux cent quatre-vingt-sept en obésité.

Au total, cinquante-quatre virgule six pour cent des répondants sont classés en
surpoids ou en obésité. C’est un premier repère descriptif, pas une estimation
pour toute la population turque. Le drapeau et la silhouette rappellent l’origine
de l’enquête ; ils ne représentent pas une répartition régionale.

Nous allons maintenant observer comment ces catégories se répartissent selon
les réponses au questionnaire.

## 2:00–5:00 — Observer

[Passer à « Observer ». Sélectionner « Légumes ». Laisser quelques secondes
pour lire les trois barres.]

Nous commençons par un graphique en barres horizontales empilées à cent pour
cent. Chaque barre correspond à une réponse au questionnaire. Chaque couleur
représente une catégorie de poids, et les couleurs restent les mêmes sur les
différentes pages pour faciliter les comparaisons.

Ce choix répond à une difficulté : les groupes n’ont pas tous le même effectif.
Une comparaison des seuls nombres de personnes pourrait surtout refléter la
taille des groupes. Les proportions permettent de comparer les répartitions.
Nous affichons donc aussi le nombre de personnes derrière chaque barre : il
reste indispensable pour comprendre ce que représente un pourcentage.

Pour les légumes, les personnes répondant « rarement » sont quatre cents ;
celles répondant « parfois » sont sept cent huit ; et celles répondant « toujours »
sont cinq cent deux. La part de surpoids ou d’obésité est de quatre-vingt-six
virgule huit pour cent dans le premier groupe, soixante virgule sept dans le
deuxième et vingt virgule trois dans le troisième.

La différence entre « rarement » et « toujours » est donc d’environ soixante-six
points de pourcentage. C’est un contraste net dans le fichier. Mais il faut bien
distinguer ce que nous observons de ce que nous pourrions expliquer. Ces données
ne permettent pas de dire que manger des légumes provoque une baisse du poids.
Les groupes peuvent aussi différer par l’âge, l’activité ou d’autres habitudes.

[Changer pour « Activité physique ». Pointer « Aucune », puis « Plus de 6 j/sem ».
Laisser environ dix secondes pour la comparaison.]

Une deuxième comparaison montre pourquoi il faut garder une lecture critique.
Pour l’activité physique, la part de surpoids ou d’obésité passe d’environ
dix-neuf virgule quatre pour cent chez les personnes déclarant aucune activité
à soixante-quatorze virgule neuf pour cent chez celles déclarant plus de six
jours par semaine. Les effectifs sont respectivement deux cent six et trois
cent quatre-vingt-six personnes.

Ce sens d’association peut surprendre. Nous ne le transformons pas en conclusion
selon laquelle l’activité physique ferait augmenter le poids. Le questionnaire
ne donne pas la chronologie : certaines personnes pourraient avoir commencé
une activité après une prise de poids, mais ce n’est qu’une hypothèse. Il peut
aussi y avoir des différences de profils, ou des questions de déclaration et
de codage à examiner.

L’intérêt de l’interactivité est justement de pouvoir confronter plusieurs
comparaisons, plutôt que de retenir uniquement un graphique conforme à nos
attentes. Le site affiche les résultats tels qu’ils apparaissent dans le fichier.

Enfin, l’âge et la taille peuvent être sélectionnés dans ces graphiques.
Ils sont alors regroupés en tranches d’âge et en quartiles de taille uniquement
pour faciliter la description. Dans l’AFDM, ils restent quantitatifs.

Nous avons décrit des écarts. L’étape suivante consiste à examiner l’indépendance
des variables avec un test statistique.

## 5:00–8:30 — Tester les associations et mesurer leur intensité

[Revenir aux légumes et cliquer sur « Tester cette association ».]

Pour chaque caractéristique qualitative, nous construisons un tableau de
contingence. Les lignes correspondent aux réponses et les colonnes aux quatre
catégories de poids. Nous utilisons le test du khi-deux d’indépendance.

Son hypothèse nulle est que les deux variables sont indépendantes. Le test
compare les effectifs réellement observés à ceux que nous attendrions si cette
hypothèse était vérifiée. Pour chaque cellule, l’effectif attendu est le total
de la ligne multiplié par le total de la colonne, divisé par l’effectif global.

[Montrer le tableau observé, puis cocher « Afficher les effectifs attendus sous H₀ ».
Pointer la case « Rarement » × « Obésité ».]

Prenons un exemple concret : le groupe « rarement » compte quatre cents
personnes et la catégorie obésité en compte deux cent quatre-vingt-sept dans
l’ensemble du fichier. Sous l’hypothèse d’indépendance, nous attendrions environ
soixante et onze personnes dans cette case. Nous en observons cent quatre-vingt-quatre.
Le test prend en compte les écarts dans toutes les cases, pas seulement celle-ci.

Avant d’interpréter le test, nous contrôlons ses conditions sur les effectifs
attendus. La règle retenue est qu’aucun attendu ne soit inférieur à un et qu’au
moins quatre-vingts pour cent soient supérieurs ou égaux à cinq. Les douze
tableaux qualitatifs satisfont ces conditions. Le programme prévoit Fisher
si elles ne sont pas satisfaites, mais ici les résultats présentés sont des
tests du khi-deux.

Pour les légumes, le khi-deux vaut environ cinq cent cinquante-quatre virgule
soixante-sept, avec six degrés de liberté. La p-value est inférieure à zéro
virgule zéro zéro un. Nous rejetons donc l’indépendance au seuil de cinq pour
cent : une association est mise en évidence dans ce tableau.

Le test porte bien sur les quatre catégories. Le regroupement « surpoids ou
obésité » utilisé précédemment était un résumé descriptif, pas un changement
de la variable analysée dans le test.

[Pointer le V de Cramér, puis descendre au tableau des douze associations.]

Toutes les variables qualitatives testées donnent ici une association significative.
Cela ne veut pas dire qu’elles sont toutes aussi importantes. Avec mille six
cent dix personnes, le test peut détecter des différences relativement modestes.
Plusieurs caractéristiques peuvent également être liées entre elles.

Nous avons donc ajouté le V de Cramér pour compléter la p-value. Il mesure
l’intensité de l’association observée entre deux variables qualitatives. Il va
de zéro à un : plus sa valeur est élevée, plus l’association est marquée dans
le tableau. Ce n’est pas un pourcentage de poids expliqué ni une preuve de causalité.

Pour les légumes, le V vaut environ zéro virgule quatre cent quinze. Pour le
temps d’écran, il vaut environ zéro virgule douze. Les deux tests sont
significatifs, mais ils ne résument pas des associations de même intensité.
Les dimensions des tableaux interviennent aussi dans la comparaison ; nous
n’appliquons donc pas de seuils automatiques « faible, moyen ou fort ».

Enfin, ces douze tests sont exploratoires et leurs p-values sont brutes.
Le seuil de cinq pour cent vaut pour chaque test, pas comme garantie globale
sur les douze. Ces analyses ne prennent pas non plus en compte simultanément
les autres caractéristiques. Nous allons maintenant compléter cette lecture
deux à deux par une exploration multivariée.

## 8:30–13:00 — Explorer les profils avec l’AFDM

[Passer à « Explorer l’AFDM ». Commencer sans ellipses et sans réponse mise en avant.
Cliquer sur « Agrandir la carte » si l’écran le permet.]

Nous utilisons une analyse factorielle des données mixtes, ou AFDM. Pourquoi
cette méthode ? Parce que nos caractéristiques actives mélangent deux variables
quantitatives, l’âge et la taille, et douze variables qualitatives. Une ACP
conviendrait à des variables quantitatives ; une ACM à des variables qualitatives.
L’AFDM permet ici de conserver la nature des deux types de données.

Elle résume l’information à travers de nouvelles dimensions. Les axes
représentent des combinaisons de caractéristiques, et non des variables choisies
arbitrairement. L’objectif est de rendre lisible une structure qui serait
difficile à observer dans quatorze colonnes à la fois.

Les quatorze caractéristiques participent à la construction des axes.
L’âge est donc bien actif : il n’est pas seulement affiché au survol. La catégorie
de poids, en revanche, est supplémentaire. Elle est projetée après la construction
du plan et aide à lire les profils sans définir les axes. Cette distinction
évite de construire directement la carte pour séparer les classes que nous
souhaitons ensuite observer.

[Pointer quelques points, puis la légende latérale.]

Chaque petit point représente une personne. Les couleurs et les formes
permettent de distinguer les quatre catégories de poids. Les grands pictogrammes
représentent les modalités, pas des personnes supplémentaires. La légende
latérale donne leur correspondance et se met à jour quand nous changeons la
caractéristique étudiée. Les quatre pictogrammes de poids restent présents
comme références permanentes.

La proximité entre personnes se lit sur les dimensions affichées : deux points
proches ont des positions proches sur ce plan. Mais cette proximité n’est pas
une identité de profil sur toutes les variables. De même, la proximité d’un
point et d’une icône ne constitue pas une prédiction de sa catégorie de poids.

Les pourcentages des axes sont essentiels. Le premier restitue environ douze
virgule trois pour cent de l’inertie et le deuxième sept virgule deux pour cent.
Ensemble, ils représentent dix-neuf virgule cinq pour cent. Cela correspond à
une part de l’information factorielle, pas à un pourcentage de bonnes prédictions.

Cette projection est donc partielle. Si certaines catégories se superposent,
on ne peut pas conclure qu’elles sont identiques dans toutes les dimensions.
À l’inverse, une séparation sur le plan ne fournit pas automatiquement une
règle de classification. L’AFDM sert ici à explorer les données.

[Sélectionner « Légumes », puis mettre « Toujours » en avant. Survoler un point.
Laisser dix à quinze secondes pour lire la carte et le résumé.]

Nous pouvons mettre une réponse en avant. Les personnes concernées deviennent
plus visibles et les autres restent en arrière-plan. Le résumé indique l’effectif
du groupe et sa répartition entre catégories de poids. Cela relie la carte au
graphique descriptif présenté au début : nous regardons les mêmes personnes
dans un espace construit avec plusieurs caractéristiques.

Il faut souligner que cette sélection ne recalcule pas l’AFDM. Les coordonnées
restent les mêmes, comme les axes et leur échelle. Nous changeons la mise en
évidence, pas la structure statistique. Cela facilite les comparaisons entre réponses.

[Remettre « Toutes les réponses », choisir « Activité physique », puis activer les ellipses.
Laisser quelques secondes pour observer leurs superpositions.]

Les ellipses ajoutent un repère de dispersion pour chaque catégorie. Elles sont
remplies avec une faible opacité afin que les points et les superpositions
restent visibles. Elles sont calculées à partir du centre et de la covariance
des points de chaque catégorie dans ce plan, sous une approximation normale.

Le repère indiqué est de quatre-vingts pour cent, mais cela ne signifie pas que
chaque ellipse contient exactement quatre-vingts pour cent des personnes
observées. Ce n’est ni un intervalle de confiance, ni une frontière entre classes.
Quand une réponse est sélectionnée, les ellipses restent celles des catégories
entières : elles fournissent un contexte fixe pour la lecture du sous-groupe.

La carte complète donc les tableaux : elle permet d’examiner plusieurs
caractéristiques ensemble, tout en laissant visibles les limites de cette
représentation. Nous pouvons maintenant revenir à notre question initiale.

## 13:00–15:00 — Conclure

[Réduire la carte et afficher « Conclure ».]

Quelles habitudes sont associées aux catégories de poids, et comment
s’organisent-elles en profils de vie ? Notre analyse apporte trois éléments.

Premièrement, les répartitions varient selon les réponses. La consommation
de légumes illustre un contraste important, tandis que l’activité physique
montre qu’un résultat peut demander davantage de vérifications avant d’être
interprété. Deuxièmement, les tests détectent des associations, et le V de Cramér
permet de compléter la significativité par une mesure d’intensité. Troisièmement,
l’AFDM propose une exploration des caractéristiques conjointes, avec la classe
de poids comme repère supplémentaire.

Nous avons choisi de rendre ces étapes interactives afin que le lecteur puisse
changer de variable, examiner les effectifs, vérifier un tableau et mettre un
groupe en évidence sur la carte. Le site donne ainsi accès au raisonnement
derrière les résultats, pas seulement à des chiffres isolés.

Les limites restent centrales. L’enquête est en ligne et sa représentativité
n’est pas établie. Les réponses sont déclaratives et recueillies à un seul
moment : nous ne connaissons pas la chronologie des liens. Le fichier ne
contient ni poids ni IMC, donc nous ne pouvons pas recalculer les catégories
fournies. Enfin, le plan AFDM ne restitue qu’une partie de l’information.

Pour prolonger le projet, nous pourrions examiner d’autres axes et les qualités
de représentation des modalités, puis vérifier si les associations se
retrouvent dans d’autres échantillons. Un modèle multivarié pourrait aussi
étudier les associations en tenant compte simultanément des autres caractéristiques.
Ce serait un prolongement à valider, pas un résultat actuellement affiché dans l’application.

Notre conclusion est donc précise : nous caractérisons les associations
observées dans cet échantillon ; nous n’identifions pas les causes du poids
et nous ne calculons pas un risque médical individuel.

Une visualisation utile rend les liens visibles et leurs limites compréhensibles.
Merci pour votre attention.

---

## Aide-mémoire, hors des 15 minutes

- Légumes : n = 400 / 708 / 502 ; surpoids ou obésité = 86,8 % / 60,7 % / 20,3 %.
- Cellule « Rarement × Obésité » : observé 184 ; attendu 400 × 287 / 1610 = 71,30.
- χ² légumes : 554,67 ; ddl = (3 − 1) × (4 − 1) = 6 ; p < 0,001 ; V = 0,415.
- V temps d’écran : 0,120. Comparaison descriptive, sans classement causal.
- Activité : aucune, n = 206 et 19,4 % ; >6 jours, n = 386 et 74,9 %.
- AFDM : 14 caractéristiques actives ; classe de poids supplémentaire ; axes 12,349 % + 7,179 % = 19,529 %.
- V de Cramér : √[χ² / (n × min(r − 1, c − 1))], version classique non corrigée du biais.
- Ne pas présenter les valeurs de `afdm$var$coord` comme des contributions : ce sont des indicateurs de liaison aux axes, distincts des contributions.

**Si le jury demande les modèles explorés :** « Nous avons essayé une régression
ordinale, dont l’hypothèse des odds proportionnels était rejetée, puis une
multinomiale. Certaines combinaisons vides créaient une séparation et des
estimations extrêmes. Ces essais ne sont pas intégrés aux résultats du site.
Une estimation avec réduction du biais ou pénalisation serait une perspective. »

**Si le jury demande pourquoi tout est significatif :** « La significativité
dépend des écarts et de l’effectif. Les variables peuvent aussi être liées entre
elles. Nos douze tests sont séparés et ne démontrent pas douze effets indépendants.
Le V de Cramér et les proportions complètent la lecture des p-values. »

**Si le jury demande une explication culturelle :** « La Turquie définit le
contexte de recueil. Sans comparaison entre pays ni variables culturelles
détaillées, nous ne pouvons pas attribuer les associations à une culture. »

## Répétition

Préparer les pages dans l’ordre du menu et garder le serveur R actif.
Les cinq durées comprennent les manipulations. Faire une répétition chronométrée :
si vous dépassez, raccourcir l’explication des ellipses ; si vous terminez trop tôt,
laisser le public lire les tableaux et les sélections sans ajouter de nouvelles analyses.
Pour plusieurs intervenants, répartir les blocs et répéter les transitions ensemble.
Tester le plein écran, la légende et la taille des textes sur l’écran de présentation.

## Sources

Les valeurs sont recalculées depuis le fichier et les fonctions du projet actuel.
Le papier source ne fournit pas les résultats de nos propres analyses.

- Jeu de données : [Koklu et Sulak, 2024](https://doi.org/10.33484/sinopfbd.1445215).
- [χ², documentation R](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/chisq.test.html).
- [Fisher, documentation R](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/fisher.test.html).
- [V de Cramér, documentation SciPy](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.contingency.association.html).
- [AFDM, documentation FactoMineR](https://search.r-project.org/CRAN/refmans/FactoMineR/html/FAMD.html).
