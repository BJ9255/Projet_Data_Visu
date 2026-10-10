# État de l’intégration

Base : commit `58a0d0c` du dépôt commun. La branche d’intégration descend de cette base : elle peut être proposée dans une pull request sans créer un historique Git indépendant.

## Contributions disponibles

| Version | Fonctionnalités |
|---|---|
| Racine, Baptiste | Contexte, AFDM, associations, régressions, classification de profils |
| `apps/observatoire`, Hodé | Carte AFDM avec pictogrammes, proportions, assistant avec confirmation, dictée et lecture, navigation animée, texte de présentation |

Le fichier Excel est identique dans les deux versions (vérifié par comparaison binaire).

## Carte commune

La carte interactive remplace l’ancien affichage de Baptiste dans l’étape « Observer ». Elle reprend les pictogrammes, la sélection des modalités et les effectifs de Hodé, avec la police Nunito, les couleurs de catégories et les cadres du projet commun. Les points utilisent aussi quatre formes pour faciliter la distinction des catégories.

Les coordonnées proviennent désormais de l’AFDM de Baptiste : les 14 caractéristiques sont actives et la classe de poids est supplémentaire. La carte conserve cette même AFDM. La version autonome de Hodé reste inchangée dans `apps/observatoire`.

## Parcours compatible avec le cours

L’application commune utilise maintenant les proportions, le χ² d’indépendance (Fisher exact en repli) et l’AFDM. Le parcours comprend Cadrer, Observer, Tester, Explorer l’AFDM et Conclure. Les tests et les textes de synthèse sont calculés dans `R/parcours.R`.

La classification automatique et les régressions ne sont plus chargées dans le parcours courant. Les calculs et caches antérieurs restent dans l’historique et dans les fichiers non chargés. La version autonome de Hodé reste inchangée.

## Vérification

`checks/verify-parcours.R` reproduit les 12 χ², les effectifs attendus, le choix de Fisher et le rendu des sorties Shiny dans des environnements UI et serveur distincts.

`checks/verify-carte-hode.R` vérifie les coordonnées, toutes les modalités, les images, les axes fixes, les effectifs et les ellipses.

Le speech et les réponses aux questions du jury figurent dans `PRESENTATION_M2.md`. L’application est lancée sur le port 3840, sur la branche `integration/hode-observatoire`.
