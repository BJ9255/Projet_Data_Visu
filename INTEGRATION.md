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

Les coordonnées proviennent désormais de l’AFDM de Baptiste : les 14 caractéristiques sont actives et la classe de poids est supplémentaire. La classification utilise cette même AFDM. La version autonome de Hodé reste inchangée dans `apps/observatoire`.

## Vérification

Le parcours commun comprend maintenant cinq étapes, de la problématique à la conclusion. Les analyses ajustées principales utilisent des tests globaux multinomiaux ; l’ordinal, dont l’hypothèse est rejetée, est conservé en annexe. La validation croisée multinomiale a été reproduite et complétée par les performances par catégorie. Les chiffres de synthèse sont calculés dans `R/parcours.R`, les performances dans `R/validation.R`.

`checks/verify-parcours.R` contrôle les effectifs, les conclusions, les tests ajustés, les métriques et les sorties Shiny du parcours. Le speech et les réponses aux questions du jury figurent dans `PRESENTATION_M2.md`.

`checks/verify-carte-hode.R` vérifie l’égalité numérique des coordonnées avec l’AFDM commune, toutes les modalités, les images, les axes fixes, les effectifs et les ellipses. La page ne contient plus l’ancien graphique.

L’application commune est lancée sur le port 3840. Les changements sont portés uniquement par la branche `integration/hode-observatoire`.
