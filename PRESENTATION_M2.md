# Présentation M2 — Habitudes de vie et catégories de poids

## Le cadrage à annoncer

**Cible :** étudiants et acteurs de prévention qui souhaitent comprendre les associations entre habitudes de vie et catégories de poids.

**Problématique :** « Quelles habitudes sont associées aux catégories de poids dans cet échantillon, et comment s’organisent-elles en profils de vie ? »

**But :** rendre les associations observées compréhensibles, explorer les profils et expliciter les limites de leur interprétation.

**Support :** l’application Shiny commune, en cinq étapes. La carte AFDM intervient après un graphique de proportions accessible. La synthèse apporte une réponse explicite à la question initiale.

Les informations sur l’enquête et le codage proviennent de [Koklu et Sulak (2024)](https://doi.org/10.33484/sinopfbd.1445215), notamment du tableau 1 de l’[article](https://dergipark.org.tr/en/download/article-file/3764172). Les chiffres analytiques ci-dessous proviennent de notre fichier et de nos calculs, pas des performances des modèles de l’article.

## Speech — environ 6 à 8 minutes, à adapter au temps accordé

### 1. Cadrer — environ 1 minute

« Notre projet cherche à répondre à une question : quelles habitudes sont associées aux catégories de poids dans cet échantillon, et comment s’organisent-elles en profils de vie ?

Nous avons choisi de nous adresser à des étudiants et à des acteurs de prévention. L’objectif est de leur permettre de lire des associations, de comparer les profils et de comprendre les limites de ces résultats.

Notre source est l’Obesity Dataset présenté par Koklu et Sulak en 2024. Le fichier contient 1 610 réponses à une enquête en ligne réalisée en Turquie, auprès de personnes âgées de 18 à 54 ans. Nous disposons de 14 caractéristiques, dont 10 habitudes de vie, et de quatre catégories de poids.

Dans ce fichier, 54,6 % des répondants sont classés en surpoids ou en obésité. Ce chiffre décrit l’échantillon ; sa représentativité n’est pas établie, donc nous ne le présentons pas comme une prévalence dans la population turque.

Nous avons construit le site comme un parcours : observer les liens, prendre les autres caractéristiques en compte, regrouper les profils, puis conclure. »

**À montrer :** accueil, cible, problématique, répartition. Ne pas lire toutes les cartes.

### 2. Observer — environ 1 minute 30

« Nous commençons par un graphique simple. Chaque barre représente 100 % des personnes ayant donné une réponse, et son effectif est affiché. Cela permet de comparer les répartitions sans confondre proportion et nombre de personnes.

La consommation de légumes est un exemple marquant. La part de surpoids ou d’obésité est de 86,8 % chez les personnes répondant “rarement”, contre 20,3 % chez celles répondant “toujours”. Ces groupes comptent respectivement 400 et 502 personnes.

Parmi les neuf habitudes ordonnées ou binaires, les légumes présentent la plus forte corrélation de Spearman en valeur absolue, avec un coefficient d’environ −0,55. Le moyen de transport est traité séparément : voiture, vélo et marche n’ont pas d’ordre naturel permettant cette corrélation.

Nous passons ensuite à l’AFDM pour lire plusieurs caractéristiques ensemble. Elle convient à nos données mixtes : deux variables quantitatives, l’âge et la taille, et douze variables qualitatives.

Sur la carte, chaque point représente une personne. Les icônes indiquent les modalités de la caractéristique sélectionnée. Les couleurs et les formes distinguent les catégories de poids. La catégorie de poids est supplémentaire : elle ne construit pas les axes.

Les deux axes représentent seulement 19,5 % de l’inertie. La carte donne donc une vue partielle des profils. Une proximité sur ce plan ne doit pas être interprétée comme une prédiction individuelle. »

**À montrer :** graphique des légumes ; carte, sélection “Légumes”, mise en avant de “Toujours”. Garder les ellipses désactivées pendant la première explication.

### 3. Ajuster — environ 1 minute 45

« Une association brute ne tient pas compte des autres caractéristiques. Nous utilisons donc une régression logistique multinomiale ajustée sur les 14 caractéristiques.

Pour chaque variable, nous comparons le modèle complet au modèle qui l’omet, puis nous corrigeons les 14 p-values par la méthode de Holm. Les légumes et le nombre de repas restent associés aux catégories de poids après cet ajustement. Une p-value faible indique une évidence statistique dans ce modèle ; elle ne mesure ni une taille d’effet ni une causalité.

Le tabac illustre pourquoi les hypothèses du modèle comptent. Le modèle ordinal ne détecte pas son association ajustée, mais son hypothèse de cotes proportionnelles est rejetée. Le modèle multinomial, qui n’impose pas cette hypothèse, détecte une association. Nous ne concluons donc pas que le lien disparaît après ajustement. Les odds ratios de l’ordinal sont conservés uniquement dans une annexe exploratoire.

Le simulateur permet ensuite de comparer des profils fictifs. Les quatorze caractéristiques sont réglables. Quand je modifie une réponse, le modèle recalcule une distribution estimée des catégories. Cela montre le fonctionnement du modèle ; cela ne démontre pas l’effet réel d’un changement d’habitude.

Nous avons reproduit la validation croisée à dix plis : le modèle est réajusté sur neuf plis et évalué sur le dernier. Son exactitude moyenne est de 74,7 %, contre une référence descriptive de 40,9 % en prédisant toujours la catégorie majoritaire “Normal”.

Les catégories étant déséquilibrées, nous regardons aussi l’exactitude équilibrée : 68,3 %. Le rappel de l’insuffisance pondérale est seulement de 52,1 %, ce qui montre les limites du score global. La calibration des probabilités et la validation externe restent à étudier. »

**À montrer :** messages ajustés ; une modification du simulateur ; tuiles de validation. Ouvrir la matrice seulement si le jury souhaite approfondir.

### 4. Regrouper — environ 1 minute

« Nous cherchons enfin des profils de caractéristiques et d’habitudes proches. Une classification hiérarchique de Ward, suivie d’une consolidation HCPC, utilise les cinq premiers axes de la même AFDM. Ces axes représentent 35,3 % de l’inertie.

HCPC choisit ici huit groupes. La catégorie de poids ne participe pas à leur construction. Nous comparons ensuite sa répartition entre groupes et nous les ordonnons pour faciliter la lecture.

La part observée de surpoids ou d’obésité va de 4,2 % à 96,0 %. Les portraits décrivent trois modalités surreprésentées dans chaque groupe ; ils ne décrivent pas nécessairement tous les membres.

Cette partition reste exploratoire. Nous n’avons pas évalué sa stabilité ni sa sensibilité au nombre d’axes ou de groupes. Nous ne présentons donc pas ces huit groupes comme une typologie universelle. »

**À montrer :** barres par groupe et deux portraits contrastés. Bien distinguer les huit groupes des quatre catégories de poids.

### 5. Conclure — environ 45 secondes

« Pour répondre à notre problématique, les habitudes alimentaires présentent des associations brutes marquées, également détectées dans le modèle ajusté. Les caractéristiques forment des groupes aux répartitions de poids contrastées.

Pour notre public, le site apporte trois réflexes : regarder les effectifs, distinguer les associations brutes des associations ajustées, et questionner le sens du lien.

Notre enquête est réalisée à un seul moment. Elle ne permet pas de déterminer si une habitude précède ou suit une prise de poids. Le fichier ne contient ni poids ni IMC, donc nous ne pouvons pas recalculer les catégories. Enfin, les modèles et les groupes doivent encore être validés sur d’autres données.

Notre contribution est donc une lecture interactive et argumentée de cet échantillon. Une visualisation utile rend les liens visibles et leurs limites compréhensibles. »

## Les chiffres à connaître

| Élément | Résultat et portée |
|---|---|
| Échantillon | 1 610 personnes, 18–54 ans, enquête en ligne en Turquie |
| Catégories | Insuffisance pondérale 73 ; Normal 658 ; Surpoids 592 ; Obésité 287 |
| Surpoids ou obésité | 879 / 1 610 = 54,6 % |
| Légumes | ρ de Spearman ≈ −0,55 ; plus forte valeur absolue parmi 9 habitudes ordonnées/binaires |
| Légumes, parts observées | Rarement : 86,8 %, n = 400 ; Toujours : 20,3 %, n = 502 |
| Plan AFDM | 19,5 % de l’inertie sur les 2 axes affichés |
| Classification | 8 groupes sur 5 axes, 35,3 % de l’inertie ; parts de 4,2 % à 96,0 % |
| Multinomial | Exactitude moyenne CV : 74,7 % ; exactitude équilibrée : 68,3 % |
| Catégorie minoritaire | 73 personnes ; rappel hors pli : 52,1 % |
| Référence descriptive | Toujours “Normal” : 40,9 % de l’échantillon |
| Ordinal | Hypothèse des cotes proportionnelles rejetée pour 12 variables sur 12 testées au seuil de 5 %, tests non corrigés |

## Questions possibles du jury

**Pourquoi l’AFDM plutôt qu’une ACP ou une ACM ?**

L’ACP est adaptée aux variables quantitatives et l’ACM aux qualitatives. L’AFDM combine ici les deux types, en tenant compte de leurs codages. L’âge et la taille ne sont pas discrétisés pour construire les axes.

**Que signifie la proximité des points ?**

Elle traduit une proximité de caractéristiques dans la projection affichée. Avec 19,5 % de l’inertie, la projection ne conserve pas toutes les distances ; une superposition ne démontre pas des profils identiques.

**Les ellipses contiennent-elles exactement 80 % des personnes ?**

Non. Elles sont calculées à partir de la covariance de chaque catégorie et d’un quantile du khi-deux à deux degrés de liberté. Le repère à 80 % repose sur une approximation normale ; ce n’est pas une couverture empirique garantie ni un intervalle de confiance. La sélection d’une réponse ne les recalcule pas.

**Pourquoi ne pas utiliser les odds ratios ordinaux comme résultats principaux ?**

L’hypothèse d’un effet commun entre seuils est rejetée. Le coefficient ajusté n’est pas une moyenne garantie des effets par seuil, et les intervalles restent conditionnels à ce modèle. Les tests principaux utilisent donc le multinomial.

**Comment sont calculées les associations ajustées ?**

Rapport de vraisemblance entre le multinomial complet et un modèle sans la variable étudiée, sur les mêmes 1 610 observations. La différence des nombres de paramètres donne les degrés de liberté. Correction de Holm sur les 14 tests. Ces tests sont globaux : ils ne donnent pas un effet commun ou un sens unique à une variable.

**Pourquoi une corrélation faible peut-elle coexister avec un test ajusté significatif ?**

Spearman teste une association monotone brute avec les catégories ordonnées. Le test multinomial évalue globalement une variable, conditionnellement aux autres, sans imposer cette structure monotone. Les hypothèses testées diffèrent. Il ne faut pas attribuer automatiquement toute différence au seul ajustement.

**L’activité physique serait-elle associée à une prise de poids ?**

La corrélation brute positive décrit cet échantillon. Elle ne démontre aucun effet de l’activité physique sur une prise de poids. L’adaptation des habitudes après une prise de poids est une hypothèse possible ; la temporalité ne peut pas être vérifiée ici.

**Le simulateur peut-il diagnostiquer une personne ou prédire son risque futur ?**

Il estime la distribution des catégories pour un profil fictif selon le modèle ajusté sur l’enquête. Les données ne décrivent pas une évolution dans le temps. Les probabilités ne sont pas validées pour un usage individuel et leur calibration n’a pas été évaluée.

**Que signifie l’exactitude équilibrée ?**

C’est la moyenne des quatre rappels, donnant le même poids à chaque catégorie. Le rappel est la part des observations d’une catégorie correctement reconnues. Cela complète l’exactitude globale dans un jeu de données déséquilibré.

**Comment avez-vous validé le modèle ?**

Nous avons reproduit dix plis aléatoires de tailles proches, avec la graine 2024. Chaque observation est prédite par un modèle qui n’a pas utilisé cette observation pour l’ajustement. Le protocole actuel n’est pas stratifié et n’évalue pas la validité externe. L’exactitude est la moyenne des scores des plis ; les rappels et précisions sont calculés sur toutes les prédictions hors pli.

**Pourquoi huit groupes et cinq axes ?**

Les cinq premiers axes sont le choix du projet existant. HCPC propose automatiquement le nombre de groupes, puis consolide la partition. Ce choix doit être soumis à une analyse de sensibilité ; nous n’avons pas démontré que huit groupes soient une structure stable ou optimale hors de cet échantillon.

**Comment éviter de construire les groupes avec le résultat que l’on compare ?**

La catégorie de poids est supplémentaire dans l’AFDM ; seuls les axes des 14 caractéristiques servent à HCPC. La catégorie sert ensuite à comparer et ordonner les groupes. Les écarts restent décrits dans les mêmes données, sans validation indépendante.

**Quelles seraient les suites du projet ?**

Vérifier la construction des catégories, évaluer la représentativité, tester la stabilité de la classification, stratifier ou répéter la validation, évaluer la calibration, puis utiliser des données externes et longitudinales.

## Préparation pratique

1. Ouvrir l’application et actualiser la page avant la présentation.
2. Activer « Mode présentation » ; il agrandit les textes secondaires et masque les annexes fermées.
3. Suivre le menu : Cadrer → Observer → Ajuster → Regrouper → Conclure. Les boutons de fin de page suivent ce même ordre. Alt + flèche droite/gauche change d’étape hors des champs de saisie.
4. Vérifier que les graphiques, les pictogrammes et les menus apparaissent sur l’ordinateur de présentation. Le serveur R doit rester lancé. Les polices et la bibliothèque d’icônes utilisent des ressources en ligne ; les données et les pictogrammes de la carte sont locaux.
5. Répartir les cinq étapes entre les membres du groupe selon le temps accordé. Conserver une seule problématique et les mêmes trois messages clés.
6. Répéter en disant les transitions à voix haute. Ne pas parcourir tous les contrôles : une comparaison, une sélection sur la carte et une modification du simulateur suffisent.

## Vérifications réalisées et limites de la vérification

Le contrôle `checks/verify-parcours.R` vérifie les effectifs, la synthèse, les tests ajustés, les performances par catégorie, les 14 contrôles du simulateur et les sorties Shiny. `checks/verify-carte-hode.R` vérifie toutes les modalités, les pictogrammes, les axes et les effectifs de la carte. La logique JavaScript du menu, des étapes actives, du mode présentation et du raccourci clavier a également été exercée.

Le contrôle visuel dans un navigateur n’a pas pu être réalisé pendant cette intervention, l’outil d’accès au navigateur étant indisponible. Le rendu final reste à regarder sur l’ordinateur et le vidéoprojecteur utilisés pour l’examen.
