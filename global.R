# ============================================================
# global.R : packages, chargement et preparation des donnees
# (execute automatiquement une seule fois avant ui.R et server.R)
# ============================================================

# Packages requis : installation automatique de ceux qui manquent, puis chargement
packages_requis <- c("shiny", "shinydashboard", "tidyverse", "ggplot2", "GGally",
                      "factoextra", "FactoMineR", "corrplot", "gridExtra", "DT",
                      "plotly", "car", "readxl")

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

# Charger les données (1re feuille du fichier Excel, toutes les colonnes en numérique)
# (lecture en texte puis conversion : certaines cellules Excel sont stockées en texte)
brut <- read_excel("Obesity_Dataset.xlsx", sheet = 1, col_types = "text")
brut[] <- lapply(brut, as.numeric)

# Le jeu ne contient pas le poids : pas d'IMC possible. La variable cible est
# la classe de corpulence (Class), gardée en facteur et en score ordinal 1-4.
# Les variables ordinales (échelles 1-3, 1-4, 1-5) restent numériques (scores),
# comme le prévoit le codage de la feuille "Explanation".
oui_non <- function(x) factor(x, levels = 1:2, labels = c("Oui", "Non"))

data <- data.frame(
  Genre                  = factor(brut$Sex, levels = 1:2, labels = c("Homme", "Femme")),
  Age                    = brut$Age,
  Taille_cm              = brut$Height,
  Antecedents_Familiaux  = oui_non(brut$Overweight_Obese_Family),
  Fast_Food              = oui_non(brut$Consumption_of_Fast_Food),
  Frequence_Legumes      = brut$Frequency_of_Consuming_Vegetables,  # 1 Rarement, 2 Parfois, 3 Toujours
  Repas_Principaux       = brut$Number_of_Main_Meals_Daily,         # 1 : 1-2, 2 : 3, 3 : plus de 3
  Grignotage             = brut$Food_Intake_Between_Meals,          # 1 Rarement ... 4 Toujours
  Fumeur                 = oui_non(brut$Smoking),
  Consommation_Liquide   = brut$Liquid_Intake_Daily,                # 1 < 1 L, 2 : 1-2 L, 3 > 2 L
  Suivi_Calories         = oui_non(brut$Calculation_of_Calorie_Intake),
  Activite_Physique      = brut$Physical_Excercise,                 # 1 aucune ... 5 plus de 6 j/semaine
  Temps_Ecrans           = brut$Schedule_Dedicated_to_Technology,   # 1 : 0-2 h, 2 : 3-5 h, 3 > 5 h
  Moyen_Transport        = factor(brut$Type_of_Transportation_Used, levels = 1:5,
                                  labels = c("Voiture", "Moto", "Vélo", "Transports en commun", "Marche")),
  Niveau_Obesite         = factor(brut$Class, levels = 1:4,
                                  labels = c("Insuffisance pondérale", "Normal", "Surpoids", "Obésité")),
  Score_Obesite          = brut$Class                               # 1 Insuffisance ... 4 Obésité
)

# Variables catégoriques (facteurs)
categorical_vars <- c("Genre", "Antecedents_Familiaux", "Fast_Food", "Fumeur", "Suivi_Calories", "Moyen_Transport", "Niveau_Obesite")

# Variables catégoriques à deux modalités (pour les tests t)
binary_vars <- c("Genre", "Antecedents_Familiaux", "Fast_Food", "Fumeur", "Suivi_Calories")

# Variables numériques (continues + scores ordinaux)
numeric_vars <- c("Age", "Taille_cm", "Frequence_Legumes", "Repas_Principaux", "Grignotage", "Consommation_Liquide", "Activite_Physique", "Temps_Ecrans", "Score_Obesite")
