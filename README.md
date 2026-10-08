# Version courte de l'application (5 pages)

Version pensée pour une soutenance de 10 minutes : une question et un graphique principal par page.
L'application complète (11 pages) reste dans le dossier parent.

| Page | Question | Méthode |
|---|---|---|
| 1. Contexte | D'où viennent les données, quelles limites ? | Description |
| 2. Explorer les liens | Chaque variable est-elle liée au niveau d'obésité ? | Khi-deux, V de Cramér, tau-b de Kendall, correction de Holm |
| 3. Ce qui compte vraiment | Quel effet reste-t-il à âge et genre égaux ? | Régression logistique ordinale (sélection AIC), simulateur de profil |
| 4. Profils de vie | Quels groupes de personnes se dégagent ? | AFDM puis classification ascendante hiérarchique |
| 5. Et l'article ? | Leur meilleur modèle tient-il ses promesses ? | Forêt aléatoire, validation croisée stratifiée à 10 plis |

Lancement : ouvrir `run.R` dans RStudio et cliquer sur **Source**. Les données sont lues dans `../Obesity_Dataset.xlsx`.
Les modèles sont calculés au premier lancement (une vingtaine de secondes) puis relus depuis `resultats/precalcul.rds`.
