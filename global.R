# ============================================================
# global.R : packages, chargement et preparation des donnees
# (execute automatiquement une seule fois avant ui.R et server.R)
# ============================================================

# Packages requis : installation automatique de ceux qui manquent, puis chargement
packages_requis <- c("shiny", "shinydashboard", "tidyverse", "ggplot2", "GGally",
                      "factoextra", "FactoMineR", "corrplot", "gridExtra", "DT",
                      "plotly", "car")

packages_manquants <- setdiff(packages_requis, rownames(installed.packages()))
if (length(packages_manquants) > 0) {
  message("Installation des packages manquants : ", paste(packages_manquants, collapse = ", "))
  install.packages(packages_manquants)
}

invisible(lapply(setdiff(packages_requis, "car"), library, character.only = TRUE))

# Se placer automatiquement dans le dossier du script, quel que soit l'endroit
# depuis lequel R a été lancé (pas besoin de fichier .Rproj ni de setwd manuel)
try({
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    script_dir <- dirname(rstudioapi::getSourceEditorContext()$path)
    if (nzchar(script_dir)) setwd(script_dir)
  } else {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- sub("--file=", "", args[grepl("--file=", args)])
    if (length(file_arg) == 1 && nzchar(file_arg)) setwd(dirname(normalizePath(file_arg)))
  }
}, silent = TRUE)

# Charger et préparer les données
data <- read.csv("ObesityDataSet_variables_explicites.csv")

# Calcul de l'IMC
data$IMC <- data$Poids_kg / (data$Taille_m ^ 2)

# Convertir les variables catégoriques en facteurs
categorical_vars <- c("Genre", "Antecedents_Familiaux_Surpoids", "Aliments_Hypercaloriques_Frequents", "Fumeur", "Suivi_Calories_Ingerees", "Consommation_Alcool", "Moyen_Transport", "Niveau_Obesite")
data[categorical_vars] <- lapply(data[categorical_vars], factor)

# Variables numériques
numeric_vars <- c("Age", "Taille_m", "Poids_kg", "IMC", "Frequence_Consommation_Legumes", "Nombre_Repas_Principaux", "Consommation_Eau_Litres", "Frequence_Activite_Physique", "Temps_Ecrans_Heures")
