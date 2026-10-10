# Dix questions de revue finale

Navigation actuelle : les sections sont accessibles par un menu déroulant. La transition grand format comprend un personnage moustachu qui tire un rideau puis mange un kebab. Les tests JavaScript couvrent les destinations, la synchronisation, les deux phases, le nettoyage et la réduction des mouvements. Les destinations comparaison, méthode et assistant ont été ouvertes dans Safari ; le personnage a été inspecté pendant son arrivée. Les dix contrôles R passent.

Mise à jour des repères : les anciens losanges sont remplacés par les pictogrammes existants avec libellés. Leur affichage a été vérifié dans Safari. Les contrôles couvrent les images de toutes les modalités, leurs coordonnées et l’encodage sans saut de ligne ; les dix contrôles passent.

1. **La problématique est-elle immédiatement identifiable ?** Oui : elle figure dans l’accueil et structure les trois étapes.
2. **La cible peut-elle commencer sans connaître l’AFDM ?** Trois repères expliquent les personnes, les distances et les modalités avant l’exploration.
3. **La carte est-elle le support central ?** Elle ouvre le premier onglet et dispose de la plus grande surface, avec un panneau de commande distinct.
4. **L’interaction apporte-t-elle une information utile ?** Une réponse met en évidence ses personnes et affiche leurs effectifs et classes. Sélection « Aucune » vérifiée dans Safari : 206 personnes.
5. **Les changements permettent-ils une comparaison honnête ?** Coordonnées, axes et échelle des distances restent communs. Toutes les variables et modalités sont couvertes par les contrôles serveur.
6. **Les pourcentages répondent-ils à la question posée ?** La comparaison décrit les réponses au sein d’une classe. L’encadré de la carte décrit les classes au sein d’une réponse ; le discours précise cette différence.
7. **La page évite-t-elle les conclusions trompeuses ?** Les rapprochements automatiques avec un centre de classe ont été retirés. Inertie partielle, causalité, représentativité et ellipses sont expliquées.
8. **Les commandes fonctionnent-elles dans le navigateur ?** Navigation, sélection d’une réponse, filtre Femme (898 personnes) et réinitialisation (1 610) vérifiés dans Safari. Le curseur d’âge est redimensionné à l’ouverture de l’onglet.
9. **La présentation est-elle lisible et organisée ?** Les trois onglets ont été inspectés visuellement sur ordinateur. Les styles prévoient une disposition étroite et la réduction des animations. Le rendu sur un téléphone réel n’a pas été vérifié.
10. **Le site et l’oral racontent-ils la même histoire ?** Le discours a été réécrit autour de la cible, de la carte, d’un exemple calculé, de la comparaison et des limites. Prévoir une répétition chronométrée sur l’écran de projection.

Les dix contrôles de `verify.R` passent après les dernières modifications du code R. L’aperçu local tourne sur le port 3839 ; aucune publication distante n’a été effectuée.

## Assistant de profils

Les contrôles de `verify-assistant.R` couvrent la confirmation, l’intersection exacte des critères (36 personnes pour l’exemple), les limites des petits groupes, l’effacement et le lien vers l’AFDM. L’adaptateur OpenAI est testé avec une réponse simulée ; aucun appel réel à OpenAI n’est vérifié sans clé serveur. Le test local optionnel utilise uniquement un exemple fictif avec Ollama. Le texte oral inclut une courte démonstration de l’assistant, qui décrit les données sans prédire un risque médical individuel.

Le test réel Ollama passe pour l’extraction ; une explication ne respectant pas les contraintes est remplacée par le texte calculé. Dans Safari, l’exemple a rempli « 1-2 jours » et « Marche », puis affiché 36 personnes et leur répartition après confirmation. Le bouton de carte ouvre l’onglet AFDM.

## Voix

La dictée en français alimente la description ou la question sans lancer l’analyse automatiquement. La lecture porte sur les résultats affichés. Les contrôles JavaScript avec des API vocales simulées passent (accord, transcription, notification Shiny, arrêt et lecture). Dans Safari, le bouton et le message demandant l’accord ont été vérifiés. La capture et l’écoute audio réelles restent à essayer par l’utilisateur avec son microphone ; aucune permission micro n’a été accordée pendant la vérification.
