# ===================================================================
# 📊 EXEMPLES D'ANALYSES - Obesity Dataset
# ===================================================================
# Ce fichier contient des exemples pour utiliser les données
# directement dans R, en dehors de Shiny
# ===================================================================

# ✓ Charger les packages
library(tidyverse)
library(ggplot2)
library(FactoMineR)
library(factoextra)
library(corrplot)

# ✓ Charger les données
data <- read.csv("C:/Users/I50832/Desktop/Spé Science des données/Projet libre jeu de donnée/estimation+of+obesity+levels+based+on+eating+habits+and+physical+condition/ObesityDataSet_raw_and_data_sinthetic.csv")

# ✓ Calculer l'IMC
data$IMC <- data$Weight / (data$Height ^ 2)

# ===================================================================
# 1. STATISTIQUES DESCRIPTIVES
# ===================================================================

# Résumé simple
summary(data[c("Age", "Height", "Weight", "IMC")])

# Résumé par genre
data %>%
  group_by(Gender) %>%
  summarise(
    N = n(),
    Age_moy = mean(Age, na.rm = TRUE),
    IMC_moy = mean(IMC, na.rm = TRUE),
    IMC_sd = sd(IMC, na.rm = TRUE),
    .groups = 'drop'
  )

# ===================================================================
# 2. CORRÉLATIONS
# ===================================================================

# Matrice de corrélation
numeric_vars <- c("Age", "Height", "Weight", "IMC", "FCVC", "NCP", "CH2O", "FAF", "TUE")
corr_matrix <- cor(data[, numeric_vars], use = "complete.obs")

# Visualiser
corrplot(corr_matrix, method = "circle", type = "upper")

# Corrélations avec l'IMC
corr_imc <- corr_matrix[, "IMC"]
print(sort(corr_imc, decreasing = TRUE))

# ===================================================================
# 3. VISUALISATIONS UNIVARIÉES
# ===================================================================

# Histogramme de l'IMC
ggplot(data, aes(x = IMC)) +
  geom_histogram(bins = 40, fill = "darkblue", alpha = 0.7) +
  geom_vline(aes(xintercept = mean(IMC)), color = "red", linetype = "dashed") +
  labs(title = "Distribution de l'IMC", x = "IMC", y = "Fréquence") +
  theme_minimal()

# Boxplot IMC par genre
ggplot(data, aes(x = Gender, y = IMC, fill = Gender)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.3) +
  labs(title = "IMC par Genre", x = "Genre", y = "IMC") +
  theme_minimal()
# ya des graphiques plus jolie avec des formes de poire 

# Boxplot IMC par catégorie d'obésité
ggplot(data, aes(x = reorder(NObeyesdad, IMC, FUN = median), y = IMC, fill = NObeyesdad)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Distribution de l'IMC par Catégorie d'Obésité",
       x = "Catégorie", y = "IMC") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")
# graphique bizarre, pourquoi les categories se recoupent 

#Explication des catégories de poids 
tapply(data$Weight / (data$Height^2), data$NObeyesdad, summary)
# Je sais pas si on peut redefinir les categories pour pas qu'elles se recoupent'

# ===================================================================
# 4. VISUALISATIONS BIVARIÉES
# ===================================================================

# Scatterplot IMC vs Poids
ggplot(data, aes(x = Weight, y = IMC, color = Gender)) +
  geom_point(alpha = 0.6, size = 3) +
  geom_smooth(method = "lm", se = TRUE) +
  facet_wrap(~Gender) +
  labs(title = "Relation IMC vs Poids par Genre", x = "Poids (kg)", y = "IMC") +
  theme_minimal()

# Scatterplot Age vs IMC
ggplot(data, aes(x = Age, y = IMC, color = NObeyesdad)) +
  geom_point(alpha = 0.6, size = 2) +
  labs(title = "Relation Age vs IMC par Catégorie d'Obésité",
       x = "Age", y = "IMC") +
  theme_minimal()

# Heatmap des corrélations
heatmap(corr_matrix, col = colorRampPalette(c("blue", "white", "red"))(100))

# ===================================================================
# 5. ANALYSE EN COMPOSANTES PRINCIPALES (ACP)
# ===================================================================

# Préparer les données pour l'ACP
data_acp <- na.omit(data[, numeric_vars])

# Exécuter l'ACP
acp <- PCA(data_acp, scale.unit = TRUE, ncp = 5, graph = FALSE)

# Variance expliquée
print(acp$eig)

# Scree plot
fviz_eig(acp, addlabels = TRUE)

# Biplot
fviz_pca_biplot(acp, axes = c(1, 2), repel = TRUE)

# Contributions
fviz_contrib(acp, choice = "var", axes = 1, top = 10)
fviz_contrib(acp, choice = "var", axes = 2, top = 10)

# Scores des individus
scores <- acp$ind$coord
head(scores)

# ===================================================================
# 6. TESTS STATISTIQUES - COMPARAISONS
# ===================================================================

# ANOVA : IMC vs Gender
aov_gender <- aov(IMC ~ Gender, data = data)
summary(aov_gender)

# ANOVA : IMC vs NObeyesdad
aov_obesity <- aov(IMC ~ NObeyesdad, data = data)
summary(aov_obesity)

# Post-hoc test (Tukey)
TukeyHSD(aov_obesity)

# Kruskal-Wallis (non-paramétrique)
kruskal.test(IMC ~ NObeyesdad, data = data)

# Test T entre genres
male_imc <- data$IMC[data$Gender == "Male"]
female_imc <- data$IMC[data$Gender == "Female"]
t.test(male_imc, female_imc)

# ===================================================================
# 7. TESTS DE NORMALITÉ
# ===================================================================

# Shapiro-Wilk pour l'IMC
shapiro.test(data$IMC)

# Pour toutes les variables
sapply(data[, numeric_vars], function(x) shapiro.test(x)$p.value)

# ===================================================================
# 8. TESTS D'HOMOGÉNÉITÉ (Levene)
# ===================================================================

library(car)

# Homogénéité IMC par Genre
leveneTest(data$IMC ~ data$Gender)

# Homogénéité IMC par Obésité
leveneTest(data$IMC ~ data$NObeyesdad)

# ===================================================================
# 9. RÉGRESSION LINÉAIRE
# ===================================================================

# IMC en fonction de plusieurs variables
model_full <- lm(IMC ~ Age + Weight + Height + Gender + CH2O + FAF, data = data)
summary(model_full)

# Diagnostic
par(mfrow = c(2, 2))
plot(model_full)
par(mfrow = c(1, 1))

# Modèle réduit
model_reduced <- lm(IMC ~ Weight + Height + Gender, data = data)
anova(model_reduced, model_full)

# ===================================================================
# 10. CROSSTABS & CHI-SQUARE
# ===================================================================

# Tableau de contingence
table_crosstab <- table(data$Gender, data$NObeyesdad)
print(table_crosstab)

# Proportions
prop.table(table_crosstab, margin = 1)

# Chi-square test
chisq.test(table_crosstab)

# ===================================================================
# 11. CLUSTERING (K-means)
# ===================================================================

# Préparer les données
data_cluster <- na.omit(data[, numeric_vars])
data_cluster_scaled <- scale(data_cluster)

# K-means avec 3 clusters
set.seed(42)
km <- kmeans(data_cluster_scaled, centers = 3, niter.max = 10)

# Ajouter les clusters aux données
data$cluster <- as.factor(km$cluster)

# Visualiser
ggplot(data, aes(x = Weight, y = IMC, color = cluster)) +
  geom_point(alpha = 0.6, size = 3) +
  labs(title = "K-means Clustering (K=3)", x = "Poids", y = "IMC") +
  theme_minimal()

# ===================================================================
# 12. ANALYSE DE LA VARIANCE (Plus Avancée)
# ===================================================================

# ANOVA à deux facteurs
aov_two_factors <- aov(IMC ~ Gender + NObeyesdad, data = data)
summary(aov_two_factors)

# Avec interactions
aov_interaction <- aov(IMC ~ Gender * NObeyesdad, data = data)
summary(aov_interaction)

# ===================================================================
# 13. VISUALISATIONS AVANCÉES
# ===================================================================

# Violin plot
ggplot(data, aes(x = NObeyesdad, y = IMC, fill = NObeyesdad)) +
  geom_violin(alpha = 0.7) +
  geom_boxplot(width = 0.2, alpha = 0.5) +
  labs(title = "Violin Plot de l'IMC par Catégorie", x = "Catégorie", y = "IMC") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")

# Pairplot
library(GGally)
ggpairs(data[, c("IMC", "Age", "Weight", "Height", "Gender")],
        lower = list(continuous = wrap("points", alpha = 0.3)),
        diag = list(continuous = "densityDiag"))

# Density plot superposé
ggplot(data, aes(x = IMC, fill = Gender)) +
  geom_density(alpha = 0.5) +
  labs(title = "Densité de l'IMC par Genre", x = "IMC") +
  theme_minimal()

# ===================================================================
# 14. SUMMARY STATISTIQUE PAR GROUPE
# ===================================================================

# IMC par catégorie d'obésité
data %>%
  group_by(NObeyesdad) %>%
  summarise(
    N = n(),
    Moyenne_IMC = mean(IMC, na.rm = TRUE),
    Mediane_IMC = median(IMC, na.rm = TRUE),
    SD_IMC = sd(IMC, na.rm = TRUE),
    Min = min(IMC, na.rm = TRUE),
    Max = max(IMC, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(Moyenne_IMC)

# ===================================================================
# 15. EXPORT DES RÉSULTATS
# ===================================================================

# Exporter un tableau en CSV
results <- data.frame(
  Variable = numeric_vars,
  Moyenne = colMeans(data[, numeric_vars], na.rm = TRUE),
  SD = sapply(data[, numeric_vars], sd, na.rm = TRUE)
)
write.csv(results, "resultats_stats.csv", row.names = FALSE)

# ===================================================================
# 🎉 C'est tout! Vous pouvez maintenant:
# - Modifier les analyses
# - Créer vos propres visualisations
# - Combiner les résultats
# - Exporter pour des rapports
# ===================================================================
