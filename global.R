# ============================================================
# global.R (version courte) : packages, données, fonctions et résultats précalculés
# Exécuté une seule fois avant ui.R et server.R
# ============================================================

# ------------------------------------------------------------
# Packages : installation automatique de ceux qui manquent
# Les packages de modélisation sont appelés avec "package::fonction" pour ne pas masquer le tidyverse
# ------------------------------------------------------------
packages_charges <- c("shiny", "tidyverse", "readxl", "plotly", "FactoMineR")
packages_requis  <- packages_charges

packages_manquants <- setdiff(packages_requis, rownames(installed.packages()))
if (length(packages_manquants) > 0) install.packages(packages_manquants)
invisible(lapply(packages_charges, library, character.only = TRUE))
invisible(lapply(setdiff(packages_requis, packages_charges), loadNamespace))

# ------------------------------------------------------------
# Données : le fichier Excel est dans le dossier parent
# ------------------------------------------------------------
brut <- read_excel(file.path("Obesity_Dataset.xlsx"), sheet = 1, col_types = "text")
brut[] <- lapply(brut, as.numeric)

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
rm(brut, code, oui_non)

# Âge en tranches et taille en quartiles : pour comparer toutes les variables avec le même indicateur
tranches_age <- c("18-24 ans", "25-34 ans", "35-44 ans", "45-54 ans")
bornes_taille <- quantile(data$Taille_cm, 0:4 / 4)
data_classes <- data %>%
  mutate(Age = cut(Age, breaks = c(17, 24, 34, 44, 54), labels = tranches_age),
         Taille_cm = cut(Taille_cm, breaks = bornes_taille, include.lowest = TRUE,
                         labels = paste0(c(bornes_taille[1], bornes_taille[2:4] + 1), "-", bornes_taille[2:5], " cm")))

# ------------------------------------------------------------
# Variables, libellés et couleurs
# ------------------------------------------------------------
libelles <- c(
  Genre = "Sexe déclaré", Age = "Âge", Taille_cm = "Taille",
  Antecedents_Familiaux = "Antécédents familiaux de surpoids", Fast_Food = "Fast-food",
  Frequence_Legumes = "Légumes", Repas_Principaux = "Repas principaux par jour",
  Grignotage = "Grignotage entre les repas", Fumeur = "Tabac", Consommation_Liquide = "Boisson par jour",
  Suivi_Calories = "Suivi des calories", Activite_Physique = "Activité physique",
  Temps_Ecrans = "Temps d'écran par jour", Moyen_Transport = "Moyen de transport",
  Niveau_Obesite = "Catégorie de poids"
)
facteurs_fixes <- c("Age", "Taille_cm", "Genre", "Antecedents_Familiaux")
habitudes_vie  <- c("Repas_Principaux", "Frequence_Legumes", "Fast_Food", "Grignotage", "Consommation_Liquide",
                    "Suivi_Calories", "Activite_Physique", "Temps_Ecrans", "Fumeur", "Moyen_Transport")
explicatives   <- c(facteurs_fixes, habitudes_vie)
choix <- function(vars) setNames(vars, libelles[vars])

# Questionnaire regroupé par thème pour l'accueil (icônes Font Awesome)
themes_questionnaire <- list(
  list(titre = "Alimentation", icone = "fork-knife",
       vars = c("Repas_Principaux", "Frequence_Legumes", "Fast_Food", "Grignotage", "Consommation_Liquide", "Suivi_Calories")),
  list(titre = "Activité et déplacements", icone = "person-simple-run", vars = c("Activite_Physique", "Moyen_Transport")),
  list(titre = "Mode de vie", icone = "device-mobile", vars = c("Temps_Ecrans", "Fumeur")),
  list(titre = "Caractéristiques individuelles", icone = "user", vars = c("Age", "Taille_cm", "Genre", "Antecedents_Familiaux"))
)
# Réponses possibles d'une question : modalités, ou plage de valeurs pour l'âge et la taille
levels_ou_plage <- function(v) {
  x <- data[[v]]
  if (is.factor(x)) levels(x) else paste("de", min(x), "à", max(x), if (v == "Age") "ans" else "cm")
}

# Quatre teintes distinctes, constantes sur toutes les pages.
niveaux <- levels(data$Niveau_Obesite)
couleurs_niveau <- setNames(c("#0072B2", "#E69F00", "#009E73", "#8B4B9E"), niveaux)
couleur_accent  <- "#3D6FB6"
palette_classes <- c("#2A78D6", "#EB6834", "#1BAF7A", "#EDA100", "#E87BA4", "#008300", "#4A3AA7", "#E34948")

fmt <- function(x, d = 2) format(round(x, d), nsmall = d, decimal.mark = ",", big.mark = " ")
pct <- function(x, d = 0) paste0(fmt(100 * x, d), " %")

# Briques d'interface partagées par ui.R et server.R
ico <- function(nom) tags$i(class = paste0("ph-bold ph-", nom))   # icônes Phosphor (trait épais, style BD)
bouton_ile <- function(id, texte, icone = "arrow-up-right") {
  actionButton(id, label = tagList(span(texte), span(class = "bulle", ico(icone))), class = "btn-ile")
}
tuile <- function(valeur, libelle) div(class = "tuile", div(class = "tuile-valeur", valeur), div(class = "tuile-libelle", libelle))
# Message de lecture immédiate, sans animation ni modification du graphique.
a_retenir <- function(..., k = 0.35) {
  div(class = "bulle-bd",
      div(class = "bulle-texte", span(class = "a-retenir-titre", "À retenir"), p(...)))
}

# ------------------------------------------------------------
# AFDM : analyse factorielle des données mixtes.
# Les 14 variables explicatives sont actives (12 qualitatives, âge et taille quantitatifs) : elles construisent la carte.
# Le niveau d'obésité est illustratif : il est projeté sur la carte sans participer à sa construction.
# ------------------------------------------------------------
vars_actives <- explicatives
vars_quanti  <- c("Age", "Taille_cm")
afdm <- local({
  df <- data[, c(vars_actives, "Niveau_Obesite")]
  for (v in names(df)) if (is.factor(df[[v]])) levels(df[[v]]) <- paste0(libelles[[v]], " : ", levels(df[[v]]))
  FAMD(df, ncp = 5, sup.var = length(vars_actives) + 1, graph = FALSE)
})
# Coordonnées des modalités qualitatives (actives et niveau d'obésité) avec leur variable d'origine
afdm_modalites <- bind_rows(lapply(c(setdiff(vars_actives, vars_quanti), "Niveau_Obesite"), function(v) {
  noms <- paste0(libelles[[v]], " : ", levels(data[[v]]))
  m <- if (v == "Niveau_Obesite") afdm$quali.sup$coord else afdm$quali.var$coord
  data.frame(var = v, modalite = levels(data[[v]]), x = m[noms, 1], y = m[noms, 2])
}))
# Variables qui construisent le plus chaque axe (r² ou rapport de corrélation), pour nommer les axes
nom_axe <- function(k) {
  top <- names(sort(afdm$var$coord[, k], decreasing = TRUE))[1:3]
  paste0("Axe ", k, " (", fmt(afdm$eig[k, 2], 1), " %) : ", paste(tolower(libelles[top]), collapse = ", "))
}

# Part de surpoids ou d'obésité dans chaque modalité d'une variable
part_risque <- function(v) {
  data_classes %>%
    group_by(modalite = .data[[v]]) %>%
    summarise(n = n(), risque = mean(Niveau_Obesite %in% c("Surpoids", "Obésité")), .groups = "drop")
}

# Carte interactive et parcours fondé sur les méthodes vues en cours.
source("R/carte_hode.R", local=TRUE)
source("R/parcours.R", local=TRUE)
