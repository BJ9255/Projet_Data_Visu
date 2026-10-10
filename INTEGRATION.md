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

Les dix contrôles R de l’observatoire passent depuis ce dépôt. Les tests de l’assistant et de navigation sont disponibles dans `apps/observatoire/checks`. La version racine contient maintenant le module `R/carte_hode.R`, affiché au début de la section « Habitudes et obésité ». Sa carte initiale, ses régressions et sa classification sont conservées. Le module de Hodé utilise sa propre AFDM : sexe et classe supplémentaires.

`checks/verify-carte-hode.R` couvre les images, les modalités, les axes et les effectifs. L’application racine a été lancée sur le port 3840. La vérification visuelle automatisée est indisponible à cause d’une erreur de démarrage de l’outil de navigateur.

La carte est intégrée dans l’interface de Baptiste. Les autres fonctionnalités de l’observatoire restent disponibles dans `apps/observatoire`. La branche d’intégration est publiée sur GitHub ; la branche principale n’est pas modifiée.
