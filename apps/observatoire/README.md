# Observatoire des profils — application Shiny

Une exploration destinée aux étudiants découvrant l’analyse de données.

**Problématique :** quels profils se ressemblent et comment les classes de poids se répartissent-elles parmi ces profils ?

## Lancer le site

Depuis le dossier `apps/observatoire`, ouvrir `app.R` dans RStudio et cliquer sur **Run App**, ou lancer :

```r
shiny::runApp()
```

Depuis la racine du projet :

```r
shiny::runApp("apps/observatoire")
```

Bibliothèques nécessaires :

```r
install.packages(c("shiny", "readxl", "dplyr", "ggplot2", "FactoMineR", "plotly", "curl", "jsonlite", "promises", "later"))
```

Le fichier `data/Obesity_Dataset.xlsx` doit rester dans le dossier fourni. Le style et les interactions sont dans `www`. Le site utilise les ressources de ses bibliothèques locales, sans police externe.

## Un parcours en trois étapes

1. **Explorer les profils.** Carte d’AFDM interactive avec survol des personnes, zoom, contours optionnels, réponses mises en évidence et répartition chiffrée de chaque groupe. Les axes restent communs aux différentes habitudes ; leur échelle graphique est identique pour préserver la lecture des distances.
2. **Comparer les habitudes.** Proportions des réponses au sein de chaque classe de poids, filtres combinables, carte thermique et données descriptives en approfondissement.
3. **Comprendre la méthode.** Public cible, objectif, contributions, inertie, dictionnaire et limites d’interprétation.

L’AFDM porte toujours sur le jeu complet. Le sexe et la classe de poids sont supplémentaires. Les filtres de la comparaison ne modifient pas la carte. Les deux premiers axes expliquent environ 19,8 % de l’inertie : la projection est partielle. Aucune interprétation causale ou prédiction individuelle n’est proposée.

## Présentation et vérification

- `presentation-lundi.md` : discours de cinq minutes et parcours de démonstration.
- `checks/verify.R` : dix contrôles, dont le rendu de toutes les modalités et des graphiques. Depuis la racine : `Rscript --vanilla apps/observatoire/checks/verify.R`.

## Assistant de profil et connexion OpenAI

L’onglet **Explorer mon profil** comprend une description libre, une confirmation modifiable, une comparaison calculée en R et des explications du LLM. Le résultat permet de mettre les personnes correspondantes en évidence sur l’AFDM. Aucun point ne prétend représenter l’utilisateur lui-même.

### Activer OpenAI

1. Copier `.Renviron.example` en `.Renviron` **dans `apps/observatoire`**.
2. Renseigner `OPENAI_API_KEY` dans ce fichier local, sans partager la clé dans une conversation ou la publier. Le fichier est ignoré par Git.
3. Conserver `OBESITY_LLM_PROVIDER=openai` et `OBESITY_LLM_MODEL=gpt-5.4-mini`, puis relancer l’application.
4. L’interface affiche le fournisseur actif et demande l’accord de l’utilisateur avant d’envoyer sa description ou sa question à OpenAI. La clé reste côté serveur.

Le modèle est configurable. [GPT-5.4 mini](https://developers.openai.com/api/docs/models/gpt-5.4-mini) et les [sorties structurées de l’API Responses](https://developers.openai.com/api/docs/guides/structured-outputs?api-mode=responses) sont documentés dans la documentation officielle OpenAI. Les requêtes utilisent `store=false`, sans historique API ni enregistrement de conversation par cette application. Cela ne constitue pas une garantie d’absence de conservation par le fournisseur.

Sans clé et sans fournisseur explicitement configuré, l’application recherche un modèle génératif déjà installé sur l’Ollama local (`127.0.0.1:11434`). Sur cet ordinateur, le modèle détecté est `llama3.2:3b`. Les modèles d’embedding sont exclus. Si le modèle est absent ou indisponible, le formulaire manuel reste utilisable. Aucun téléchargement de modèle n’est lancé par le site.

Bibliothèques supplémentaires : `curl`, `jsonlite`, `promises` et `later`. Les requêtes sont asynchrones pour laisser les autres onglets disponibles pendant la génération. L’extraction est structurée, validée puis confirmée par l’utilisateur ; les déclarations numériques explicites de jours d’activité font aussi l’objet d’une vérification déterministe.

### Ce que le résultat mesure

Les catégories confirmées doivent toutes correspondre exactement. L’âge facultatif utilise une fenêtre de ± 3 ans, sans extrapolation au-delà des âges observés. La répartition des classes n’est affichée qu’à partir de 30 personnes : ce seuil de présentation ne remplace pas une validation statistique. Aucune probabilité individuelle, maladie future ou classe prédite n’est calculée.

Une modification des critères invalide le résultat précédent. Les questions demandant un risque médical reçoivent une explication des limites. Les chiffres restent calculés par R, et les explications du modèle ne sont pas autorisées à ajouter leurs propres pourcentages. Ce prototype est un outil pédagogique : la validation des sorties et la confirmation humaine limitent les erreurs sans garantir qu’un LLM n’en fera jamais.

Contrôles de l’assistant : `Rscript --vanilla apps/observatoire/checks/verify-assistant.R` depuis la racine.

### Parler et écouter

« Dicter mes habitudes » et « Dicter ma question » utilisent la reconnaissance vocale du navigateur en français. Cochez l’accord de dictée, autorisez le microphone puis relisez la transcription avant d’envoyer. Selon le navigateur, l’audio peut être transmis à son service de reconnaissance ; l’application ne conserve aucun enregistrement audio. La compatibilité varie et la saisie reste disponible. Utilisez HTTPS pour une publication distante.

Les boutons « Écouter » lisent uniquement le résultat affiché et permettent d’arrêter la lecture. Une voix française locale est privilégiée lorsqu’elle est disponible. La lecture démarre sur clic, jamais automatiquement. Voir la [documentation Web Speech API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Speech_API).
