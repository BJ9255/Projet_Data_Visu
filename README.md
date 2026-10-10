# Version courte de l'application (5 pages)

Voici une application qui illustre des données récoltés en Turquie sur une population de 1600 individus

| Page | Question | Méthode |
|---|---|---|
| 1. Contexte | D'où viennent les données, quelles limites ? | Description |
| 2. Explorer les liens | Chaque variable est-elle liée au niveau d'obésité ? | AFMD |


## Intégration des contributions

La branche `integration/hode-observatoire` conserve l’application de Baptiste à la racine et ajoute la version locale de Hodé dans `apps/observatoire`. Le premier commit importe le travail déjà réalisé ; il ne reconstitue pas un historique antérieur.

Depuis la racine du dépôt :

```r
# Application initiale de l’équipe
shiny::runApp(".")

# Observatoire de Hodé : AFDM, comparaison et assistant
shiny::runApp("apps/observatoire")
```

[Points à décider pour réunir les fonctionnalités](INTEGRATION.md).

### Carte de Hodé dans l’application commune

Lancez l’application racine puis ouvrez « Habitudes et obésité ». La carte de Hodé apparaît en premier, avec ses icônes, le choix de la caractéristique, la mise en évidence d’une réponse et les effectifs correspondants. Elle est indépendante de la carte utilisée pour la classification de Baptiste.

Validation : `Rscript --vanilla -e 'source("checks/verify-carte-hode.R")'`.
