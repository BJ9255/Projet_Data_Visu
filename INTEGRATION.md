# État de l’intégration

Base : commit `58a0d0c` du dépôt commun. La branche d’intégration descend de cette base : elle peut être proposée dans une pull request sans créer un historique Git indépendant.

## Contributions disponibles

| Version | Fonctionnalités |
|---|---|
| Racine, Baptiste | Contexte, AFDM, associations, régressions, classification de profils |
| `apps/observatoire`, Hodé | Carte AFDM avec pictogrammes, proportions, assistant avec confirmation, dictée et lecture, navigation animée, texte de présentation |

Le fichier Excel est identique dans les deux versions (vérifié par comparaison binaire).

## Carte commune

La carte interactive remplace l’ancien affichage de Baptiste dans « Habitudes et obésité ». Elle reprend les pictogrammes, la sélection des modalités et les effectifs de Hodé, avec la police Nunito, les couleurs de niveaux et les cadres du projet commun.

Les coordonnées proviennent désormais de l’AFDM de Baptiste : les 14 caractéristiques sont actives et la classe de poids est supplémentaire. La classification utilise cette même AFDM. La version autonome de Hodé reste inchangée dans `apps/observatoire`.

## Vérification

`checks/verify-carte-hode.R` vérifie l’égalité numérique des coordonnées avec l’AFDM commune, toutes les modalités, les images, les axes fixes, les effectifs et les ellipses. La page ne contient plus l’ancien graphique.

L’application commune est lancée sur le port 3840. Les changements sont portés uniquement par la branche `integration/hode-observatoire`.
