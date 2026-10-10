# Habitudes de vie et catégories de poids — Projet de visualisation M2

Application R / Shiny construite à partir de 1 610 réponses à une enquête en ligne en Turquie, présentée par [Koklu et Sulak (2024)](https://doi.org/10.33484/sinopfbd.1445215).

**Problématique :** quelles habitudes sont associées aux catégories de poids dans cet échantillon, et comment s’organisent-elles en profils de vie ?

**Cible :** étudiants et acteurs de prévention qui souhaitent comprendre les associations observées et leurs limites.

| Étape | Question | Support |
|---|---|---|
| Cadrer | Pour qui, dans quel but et avec quelles données ? | Problématique, échantillon, trois messages clés |
| Observer | Comment les répartitions varient-elles selon les réponses ? | Proportions avec effectifs |
| Tester | Deux variables qualitatives sont-elles indépendantes ? | Tableaux de contingence, χ², attendus et conditions ; Fisher en repli |
| Explorer l’AFDM | Comment les caractéristiques s’organisent-elles ensemble ? | Carte interactive d’une AFDM sur données mixtes |
| Conclure | Que retenir et que reste-t-il à vérifier ? | Réponse, résultats, limites |

## Lancer le projet

Depuis la racine du dépôt, dans R :

```r
shiny::runApp(".")
```

Ou en ligne de commande pour la prévisualisation locale :

```sh
Rscript --vanilla -e 'shiny::runApp(".", host="127.0.0.1", port=3840, launch.browser=FALSE)'
```

Ouvrir ensuite `http://127.0.0.1:3840`. Le serveur R doit rester actif. Les packages manquants sont installés au lancement ; une connexion est alors nécessaire. Les polices et les icônes générales proviennent de ressources web ; les données et pictogrammes de la carte sont locaux.

Le menu propose les cinq étapes. Le mode présentation agrandit les textes secondaires et masque les annexes fermées. Alt + flèche droite/gauche passe à l’étape suivante/précédente hors des champs de saisie.

## Méthodes et périmètre

- 14 caractéristiques actives dans l’AFDM : 12 qualitatives, âge et taille quantitatifs. La catégorie de poids est supplémentaire.
- Carte sur deux axes : 19,5 % de l’inertie ; sélection des modalités, pictogrammes, effectifs et répartition observée.
- Comparaisons descriptives : proportions dans chaque réponse. Âge en tranches et taille en quartiles pour ces seuls graphiques.
- Tests d’indépendance : les 12 caractéristiques qualitatives d’origine sont croisées avec les quatre catégories de poids.
- Conditions du χ² retenues : aucun attendu < 1 et au moins 80 % des cellules avec un attendu ≥ 5. Tous les tableaux actuels satisfont ces conditions ; Fisher exact est prévu en repli.
- P-values brutes : comparaisons exploratoires, sans correction multiple. Le seuil de 5 % concerne chaque test individuellement.

Le site présente des associations observées, sans ajustement sur d’autres caractéristiques. Il ne prédit pas un risque individuel et ne comporte plus de simulateur de régression ni de classification automatique. Les versions antérieures sont conservées dans l’historique Git.

La représentativité et la causalité ne sont pas établies. Sans poids ni IMC dans le fichier, les catégories fournies ne peuvent pas être recalculées.

## Préparer l’oral

[Speech, chiffres à connaître et questions du jury](PRESENTATION_M2.md).

## Vérifier

```sh
Rscript --vanilla -e 'source("checks/verify-parcours.R")'
Rscript --vanilla -e 'source("checks/verify-carte-hode.R")'
```

Le premier contrôle vérifie les effectifs, les χ², le choix de Fisher, les attendus et le rendu des sorties Shiny. Le second exerce toutes les modalités de la carte, les pictogrammes, les effectifs et la stabilité des axes. Ces contrôles ne remplacent pas une inspection du rendu dans le navigateur et sur le vidéoprojecteur.

## Contributions

La branche `integration/hode-observatoire` réunit les analyses du projet de Baptiste et la carte interactive de Hodé. La version autonome de Hodé reste disponible dans `apps/observatoire` :

```r
shiny::runApp("apps/observatoire")
```

Le premier commit d’import conserve le travail déjà réalisé ; il ne reconstitue pas un historique antérieur. [Détails de l’intégration](INTEGRATION.md).
