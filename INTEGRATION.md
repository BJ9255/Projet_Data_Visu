# État de l’intégration

Base : commit `58a0d0c` du dépôt commun. La branche d’intégration descend de cette base : elle peut être proposée dans une pull request sans créer un historique Git indépendant.

## Contributions disponibles

| Version | Fonctionnalités |
|---|---|
| Racine, Baptiste | Contexte, AFDM, associations, régressions, classification de profils |
| `apps/observatoire`, Hodé | Carte AFDM avec pictogrammes, proportions, assistant avec confirmation, dictée et lecture, navigation animée, texte de présentation |

Le fichier Excel est identique dans les deux versions (vérifié par comparaison binaire).

## Décisions nécessaires avant une application unique

- Choisir l’interface de référence pour y porter les fonctionnalités de l’autre version.
- Harmoniser les noms des variables et les modalités.
- Choisir une seule AFDM : le sexe construit la carte de Baptiste, tandis qu’il est supplémentaire dans l’observatoire. Leurs coordonnées ne doivent pas être mélangées.
- Conserver la distinction entre proportions observées, sorties de régression et risque futur ; l’assistant actuel compare uniquement des observations.

## Vérification

Les dix contrôles R de l’observatoire passent depuis ce dépôt. Les tests de l’assistant et de navigation sont disponibles dans `apps/observatoire/checks`. La version racine n’a pas été modifiée ni exécutée lors de cette première étape.

La réunion des fonctionnalités dans une interface unique reste à faire après le choix de la base. Aucun changement n’a été poussé sur GitHub à cette étape.
