# ============================================================
# global.R : packages, chargement et preparation des donnees
# (execute automatiquement une seule fois avant ui.R et server.R)
# ============================================================

# Packages requis : installation automatique de ceux qui manquent, puis chargement
packages_requis <- c("shiny", "shinydashboard", "tidyverse", "DT", "readxl")

packages_manquants <- setdiff(packages_requis, rownames(installed.packages()))
if (length(packages_manquants) > 0) {
  message("Installation des packages manquants : ", paste(packages_manquants, collapse = ", "))
  install.packages(packages_manquants)
}

invisible(lapply(packages_requis, library, character.only = TRUE))

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

# ------------------------------------------------------------
# Chargement (1re feuille du fichier Excel)
# Lecture en texte puis conversion : certaines cellules Excel sont stockées en texte
# ------------------------------------------------------------
brut <- read_excel("Obesity_Dataset.xlsx", sheet = 1, col_types = "text")
brut[] <- lapply(brut, as.numeric)

# Recodage des codes numériques en modalités lisibles, d'après la feuille
# "Explanation" du fichier. Les échelles ordinales restent ordonnées.
code <- function(x, libelles) factor(x, levels = seq_along(libelles), labels = libelles)
oui_non <- c("Oui", "Non")

data <- data.frame(
  Genre                 = code(brut$Sex, c("Homme", "Femme")),
  Age                   = brut$Age,
  Taille_cm             = brut$Height,
  Antecedents_Familiaux = code(brut$Overweight_Obese_Family, oui_non),
  Fast_Food             = code(brut$Consumption_of_Fast_Food, oui_non),
  Frequence_Legumes     = code(brut$Frequency_of_Consuming_Vegetables, c("Rarement", "Parfois", "Toujours")),
  Repas_Principaux      = code(brut$Number_of_Main_Meals_Daily, c("1 à 2", "3", "Plus de 3")),
  Grignotage            = code(brut$Food_Intake_Between_Meals, c("Rarement", "Parfois", "Souvent", "Toujours")),
  Fumeur                = code(brut$Smoking, oui_non),
  Consommation_Liquide  = code(brut$Liquid_Intake_Daily, c("Moins de 1 L", "1 à 2 L", "Plus de 2 L")),
  Suivi_Calories        = code(brut$Calculation_of_Calorie_Intake, oui_non),
  Activite_Physique     = code(brut$Physical_Excercise, c("Aucune", "1-2 j/sem", "3-4 j/sem", "5-6 j/sem", "Plus de 6 j/sem")),
  Temps_Ecrans          = code(brut$Schedule_Dedicated_to_Technology, c("0-2 h", "3-5 h", "Plus de 5 h")),
  Moyen_Transport       = code(brut$Type_of_Transportation_Used, c("Voiture", "Moto", "Vélo", "Transports en commun", "Marche")),
  Niveau_Obesite        = code(brut$Class, c("Insuffisance pondérale", "Normal", "Surpoids", "Obésité"))
)

# Tranches d'âge : uniquement pour découper les graphiques de l'onglet Distributions
# (les tests utilisent l'âge en quantitatif)
data_groupes <- data %>%
  mutate(Tranche_Age = cut(Age, breaks = c(17, 24, 34, 44, 54),
                           labels = c("18-24 ans", "25-34 ans", "35-44 ans", "45-54 ans")))

# ------------------------------------------------------------
# Listes de variables et libellés
# ------------------------------------------------------------
libelles <- c(
  Genre = "Genre", Age = "Âge", Taille_cm = "Taille (cm)",
  Antecedents_Familiaux = "Antécédents familiaux de surpoids",
  Fast_Food = "Consommation de fast-food", Frequence_Legumes = "Fréquence de consommation de légumes",
  Repas_Principaux = "Nombre de repas principaux par jour", Grignotage = "Grignotage entre les repas",
  Fumeur = "Fumeur", Consommation_Liquide = "Consommation de liquide par jour",
  Suivi_Calories = "Suivi des calories", Activite_Physique = "Activité physique",
  Temps_Ecrans = "Temps d'écran par jour", Moyen_Transport = "Moyen de transport",
  Niveau_Obesite = "Niveau d'obésité",
  Tranche_Age = "Tranche d'âge"
)

# Choix de listes déroulantes : libellé affiché -> nom de colonne
choix <- function(vars) setNames(vars, libelles[vars])

# Types de variables : 2 quantitatives, toutes les autres qualitatives (nominales ou ordinales)
vars_quanti      <- c("Age", "Taille_cm")
vars_quali       <- setdiff(names(data), vars_quanti)
vars_ordinales   <- c("Frequence_Legumes", "Repas_Principaux", "Grignotage", "Consommation_Liquide",
                      "Activite_Physique", "Temps_Ecrans", "Niveau_Obesite")
vars_nominales   <- setdiff(vars_quali, vars_ordinales)
facteurs_fixes   <- c("Age", "Taille_cm", "Genre", "Antecedents_Familiaux")
habitudes_vie    <- c("Fast_Food", "Frequence_Legumes", "Repas_Principaux", "Grignotage", "Fumeur",
                      "Consommation_Liquide", "Suivi_Calories", "Activite_Physique", "Temps_Ecrans",
                      "Moyen_Transport")
toutes_vars      <- c(facteurs_fixes, habitudes_vie, "Niveau_Obesite")

# Libellés courts pour les axes de la matrice des liaisons
libelles_courts  <- c(Genre = "Genre", Age = "Âge", Taille_cm = "Taille",
                      Antecedents_Familiaux = "Antécédents", Fast_Food = "Fast-food",
                      Frequence_Legumes = "Légumes", Repas_Principaux = "Repas principaux",
                      Grignotage = "Grignotage", Fumeur = "Fumeur", Consommation_Liquide = "Liquide",
                      Suivi_Calories = "Suivi calories", Activite_Physique = "Activité physique",
                      Temps_Ecrans = "Temps d'écran", Moyen_Transport = "Transport",
                      Niveau_Obesite = "Niveau d'obésité")
decoupages       <- c("Aucun" = "aucun", choix(c("Genre", "Tranche_Age", "Niveau_Obesite", "Antecedents_Familiaux")))

# Couleurs fixes des niveaux d'obésité, identiques dans tous les graphiques
couleurs_niveau <- c("Insuffisance pondérale" = "#6BAED6", "Normal" = "#74C476",
                     "Surpoids" = "#FDAE6B", "Obésité" = "#E6550D")

# ------------------------------------------------------------
# Fonctions utilitaires
# ------------------------------------------------------------

# Repères usuels pour le V de Cramér et |r| de Pearson
force_lien <- function(v) {
  cut(v, breaks = c(-Inf, 0.1, 0.2, 0.3, Inf), labels = c("Négligeable", "Faible", "Modéré", "Fort"))
}

# Repères usuels (Cohen) pour l'êta carré : part de variance expliquée
force_eta2 <- function(e) {
  cut(e, breaks = c(-Inf, 0.01, 0.06, 0.14, Inf), labels = c("Négligeable", "Faible", "Modéré", "Fort"))
}

# Mesure du lien entre deux variables, choisie selon leur type :
#   quanti x quanti -> corrélation de Pearson (r)
#   quali  x quali  -> khi-deux, force mesurée par le V de Cramér
#   quali  x quanti -> ANOVA, force mesurée par l'êta carré (part de variance expliquée)
fmt <- function(x, d = 3) format(round(x, d), nsmall = d, decimal.mark = ",")

mesure_lien <- function(v1, v2) {
  q1 <- v1 %in% vars_quanti
  q2 <- v2 %in% vars_quanti

  if (q1 && q2) {
    t <- cor.test(data[[v1]], data[[v2]], method = "pearson")
    r <- unname(t$estimate)
    list(methode = "Corrélation de Pearson", symbole = "r", valeur = r, p = t$p.value,
         force = as.character(force_lien(abs(r))),
         detail = paste0("r = ", fmt(r), " (t = ", fmt(unname(t$statistic), 2),
                         ", ddl = ", unname(t$parameter), ")"))
  } else if (!q1 && !q2) {
    tableau <- table(data[[v1]], data[[v2]])
    test <- suppressWarnings(chisq.test(tableau))
    v <- sqrt(unname(test$statistic) / (sum(tableau) * (min(dim(tableau)) - 1)))
    list(methode = "Test du khi-deux", symbole = "V", valeur = v, p = test$p.value,
         force = as.character(force_lien(v)),
         detail = paste0("Khi-deux = ", fmt(unname(test$statistic), 1), " (ddl = ",
                         unname(test$parameter), "), V de Cramér = ", fmt(v)),
         effectifs_faibles = any(test$expected < 5))
  } else {
    quanti <- if (q1) v1 else v2
    quali  <- if (q1) v2 else v1
    s <- summary(aov(data[[quanti]] ~ data[[quali]]))[[1]]
    eta2 <- s[["Sum Sq"]][1] / sum(s[["Sum Sq"]])
    list(methode = "ANOVA à un facteur", symbole = "η²", valeur = eta2, p = s[["Pr(>F)"]][1],
         force = as.character(force_eta2(eta2)),
         detail = paste0("F = ", fmt(s[["F value"]][1], 2), " (ddl = ", s[["Df"]][1], " ; ",
                         s[["Df"]][2], "), η² = ", fmt(eta2)))
  }
}

format_p <- function(p) if (p < 0.001) "< 0,001" else format(round(p, 3), decimal.mark = ",")
