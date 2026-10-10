# Habitudes de vie et catégories de poids — Projet de visualisation M2

Application R / Shiny construite à partir de 1 610 réponses à une enquête en ligne en Turquie, présentée par [Koklu et Sulak (2024)](https://doi.org/10.33484/sinopfbd.1445215).

**Problématique :** quelles habitudes sont associées aux catégories de poids dans cet échantillon, et comment s’organisent-elles en profils de vie ?

**Cible :** étudiants et acteurs de prévention qui souhaitent comprendre les associations observées et leurs limites.

| Étape | Question | Support |
|---|---|---|
| Cadrer | Pour qui, dans quel but et avec quelles données ? | Problématique, échantillon, trois messages clés |
| Observer | Comment les répartitions varient-elles selon les réponses ? | Proportions avec effectifs, Spearman, carte AFDM |
| Ajuster | Quelles associations sont détectées en prenant les autres caractéristiques en compte ? | Tests multinomiaux ajustés, simulateur fictif, validation |
| Regrouper | Quels profils proches présentent des répartitions différentes ? | HCPC sur la même AFDM, descriptions des groupes |
| Conclure | Que retenir et que reste-t-il à vérifier ? | Réponse, résultats, limites et prolongements |

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
- Carte sur deux axes : 19,5 % de l’inertie. La HCPC utilise les cinq premiers axes : 35,3 %, méthode de Ward puis consolidation, graine 2024.
- Associations brutes : Spearman sur les variables ordonnées/binaires ; V de Cramér pour le transport nominal. Les p-values de Spearman sont corrigées par Holm sur les 13 tests.
- Associations ajustées : tests globaux du rapport de vraisemblance dans le multinomial complet ; correction de Holm sur 14 tests.
- Simulateur : estimation de catégories pour un profil fictif dans ce modèle, sans prédiction de risque futur.
- Validation multinomiale : reproduction des 10 plis aléatoires, non stratifiés, graine 2024 ; exactitude moyenne 74,7 %, exactitude équilibrée 68,3 %, performances par catégorie et matrice hors pli.
- L’ordinal est conservé en annexe exploratoire, car l’hypothèse des cotes proportionnelles est rejetée. Il ne fonde pas les messages principaux.

Les caches des nouveaux tests et de la validation sont invalidés lorsque les données ou le modèle précalculé changent. L’exactitude reproduite est comparée au cache initial pour détecter une divergence.

Il s’agit d’associations dans un échantillon : représentativité, causalité, stabilité des groupes, calibration et validité externe ne sont pas établies. Sans poids ni IMC dans le fichier, les catégories fournies ne peuvent pas être recalculées.

## Préparer l’oral

[Speech, chiffres à connaître et questions du jury](PRESENTATION_M2.md).

## Vérifier

```sh
Rscript --vanilla -e 'source("checks/verify-parcours.R")'
Rscript --vanilla -e 'source("checks/verify-carte-hode.R")'
```

Le premier contrôle vérifie les chiffres, les tests ajustés, les métriques et le rendu des sorties Shiny. Le second exerce toutes les modalités de la carte, les pictogrammes, les effectifs et la stabilité des axes. Ces contrôles ne remplacent pas une inspection du rendu dans le navigateur et sur le vidéoprojecteur.

## Contributions

La branche `integration/hode-observatoire` réunit les analyses du projet de Baptiste et la carte interactive de Hodé. La version autonome de Hodé reste disponible dans `apps/observatoire` :

```r
shiny::runApp("apps/observatoire")
```

Le premier commit d’import conserve le travail déjà réalisé ; il ne reconstitue pas un historique antérieur. [Détails de l’intégration](INTEGRATION.md).
