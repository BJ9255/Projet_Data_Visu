# ============================================================
# global.R (version courte) : packages, données, fonctions et résultats précalculés
# Exécuté une seule fois avant ui.R et server.R
# ============================================================

# ------------------------------------------------------------
# Packages : installation automatique de ceux qui manquent
# Les packages de modélisation sont appelés avec "package::fonction" pour ne pas masquer le tidyverse
# ------------------------------------------------------------
packages_charges <- c("shiny", "tidyverse", "readxl", "plotly", "FactoMineR")
packages_requis  <- c(packages_charges, "ordinal", "nnet")

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

# Mascotte BD (dessinée et animée par www/mascotte.js) ; k = corpulence de 0 (mince) à 1 (forte)
silhouette_svg <- function(id = NULL, k = 0.3, boucle = FALSE, hauteur = 220, pose = "repos") {
  HTML(sprintf('<svg %s class="mascotte%s" data-k="%s" data-pose="%s" viewBox="0 0 200 300" height="%d" role="img"
    aria-label="Mascotte dont la corpulence suit le niveau d\'obésité"></svg>',
    if (is.null(id)) "" else sprintf('id="%s"', id), if (boucle) " en-boucle" else "", k, pose, hauteur))
}
# Corpulence moyenne attendue d'après les probabilités des 4 niveaux (0 = insuffisance, 1 = obésité)
corpulence <- function(probas) sum(probas * (0:3)) / 3

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
# Lien de chaque variable avec le niveau d'obésité
# Khi-deux et V de Cramér sur les variables en classes (même indicateur pour toutes) ;
# tau-b de Kendall pour le sens quand la variable est ordonnée ou binaire
# ------------------------------------------------------------
lien <- function(v) {
  x <- data_classes[[v]]
  tab <- table(x, data$Niveau_Obesite)
  test <- suppressWarnings(chisq.test(tab))
  ordonnee <- v != "Moyen_Transport"
  list(V = sqrt(unname(test$statistic) / (sum(tab) * (min(dim(tab)) - 1))), p = test$p.value,
       tau = if (ordonnee) cor(as.numeric(x), as.numeric(data$Niveau_Obesite), method = "kendall") else NA)
}
force <- function(v) as.character(cut(v, c(-Inf, 0.1, 0.2, 0.3, Inf), c("négligeable", "faible", "modéré", "fort")))

classement <- bind_rows(lapply(explicatives, function(v) {
  l <- lien(v)
  data.frame(var = v, Variable = libelles[[v]], V = l$V, p = l$p, tau = l$tau,
             Groupe = if (v %in% habitudes_vie) "Habitude de vie" else "Facteur non modifiable")
})) %>%
  mutate(p_holm = p.adjust(p, "holm"), Force = force(V)) %>%
  arrange(desc(V))

# Corrélation de rang (Spearman) entre chaque variable et le niveau d'obésité, de -1 à +1.
# Les variables sont orientées pour que le signe se lise directement :
# positif = « plus de X » va avec un niveau d'obésité plus élevé.
# Le moyen de transport n'a pas d'ordre : pas de corrélation possible, seule la force du lien est donnée.
sens_lecture <- c(
  Age = "être plus âgé", Taille_cm = "être plus grand", Genre = "être une femme",
  Antecedents_Familiaux = "avoir des antécédents", Repas_Principaux = "prendre plus de repas",
  Frequence_Legumes = "manger plus souvent des légumes", Fast_Food = "consommer du fast-food",
  Grignotage = "grignoter plus souvent", Consommation_Liquide = "boire davantage",
  Suivi_Calories = "suivre ses calories", Activite_Physique = "faire plus de sport",
  Temps_Ecrans = "passer plus de temps sur les écrans", Fumeur = "fumer"
)
vars_ordonnees <- names(sens_lecture)
score_oriente <- function(v) {
  x <- data[[v]]
  if (!is.factor(x)) return(x)
  if (v == "Genre") return(as.numeric(x == "Femme"))
  if (identical(levels(x), c("Oui", "Non"))) return(as.numeric(x == "Oui"))
  as.numeric(x)
}
correlations <- bind_rows(lapply(vars_ordonnees, function(v) {
  t <- suppressWarnings(cor.test(score_oriente(v), as.numeric(data$Niveau_Obesite), method = "spearman", exact = FALSE))
  data.frame(var = v, Variable = libelles[[v]], rho = unname(t$estimate), p = t$p.value,
             Groupe = if (v %in% habitudes_vie) "Habitude de vie" else "Facteur non modifiable")
})) %>%
  mutate(p_holm = p.adjust(p, "holm"), Force = force(abs(rho))) %>%
  arrange(desc(abs(rho)))

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
# Classification ascendante hiérarchique (Ward) sur les 5 premiers axes de cette même AFDM : groupes de profils (étape 4)
# La consolidation utilise des départs aléatoires : graine fixe pour la soutenance.
set.seed(2024)
cah <- HCPC(afdm, nb.clust = -1, graph = FALSE, consol = TRUE)

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

# ------------------------------------------------------------
# Résultats précalculés (modèles de régression, AFDM + classification)
# Recalculés au premier lancement si resultats/precalcul.rds est absent
# ------------------------------------------------------------
fichier_precalcul <- file.path("resultats", "precalcul.rds")

calculer <- function() {
  message("Premier lancement : calcul des modèles (une vingtaine de secondes)...")
  formule <- as.formula(paste("Niveau_Obesite ~", paste(explicatives, collapse = " + ")))

  # 1. Régression logistique ordinale (modèle complet) : un odds ratio par modalité, lisible.
  #    L'hypothèse des cotes proportionnelles est testée variable par variable (test du rapport de vraisemblance).
  # (formule insérée telle quelle dans l'appel, pour que nominal_test() puisse réajuster le modèle)
  complet <- eval(bquote(ordinal::clm(.(formule), data = data)))
  test_cotes <- suppressWarnings(ordinal::nominal_test(complet))
  # 2. Régression logistique multinomiale (modèle complet) : sans hypothèse de cotes proportionnelles,
  #    elle sert à toutes les probabilités affichées (simulateur).
  multinomial <- nnet::multinom(formule, data = data, trace = FALSE, maxit = 1000)
  # 3. Sélection par AIC : seulement une information (quelles variables pèsent peu) ; aucune inférence n'est faite
  #    sur le modèle sélectionné, car ses intervalles de confiance seraient trop optimistes.
  retirees_aic <- setdiff(explicatives, attr(terms(step(complet, trace = 0)), "term.labels"))
  # 4. Exactitude des deux modèles en validation croisée à 10 plis (part des personnes bien classées)
  set.seed(2024)
  pli <- sample(rep(1:10, length.out = nrow(data)))
  bien_classes <- sapply(1:10, function(k) {
    a <- pli != k; y <- as.integer(data$Niveau_Obesite[!a])
    po <- ordinal::clm(formule, data = data[a, ])
    mn <- nnet::multinom(formule, data = data[a, ], trace = FALSE, maxit = 1000)
    c(ordinal = mean(max.col(predict(po, newdata = data[!a, explicatives], type = "prob")$fit) == y),
      multinomial = mean(max.col(predict(mn, newdata = data[!a, ], type = "probs")) == y))
  })

  list(complet = complet, multinomial = multinomial, retirees_aic = retirees_aic,
       cotes_rejetees = sum(test_cotes[-1, "Pr(>Chi)"] < 0.05, na.rm = TRUE),
       cotes_testees = sum(!is.na(test_cotes[-1, "Pr(>Chi)"])),
       aic = c(ordinal = AIC(complet), multinomial = AIC(multinomial)),
       exactitude_cv = rowMeans(bien_classes))
}

if (file.exists(fichier_precalcul)) {
  precalcul <- readRDS(fichier_precalcul)
} else {
  precalcul <- calculer()
  dir.create("resultats", showWarnings = FALSE)
  saveRDS(precalcul, fichier_precalcul)
}

# ------------------------------------------------------------
# Odds ratios (modèle ordinal complet), profil de référence, probabilités prédites (modèle multinomial)
# ------------------------------------------------------------
habitudes_sim <- habitudes_vie   # habitudes réglables dans le simulateur

table_or <- local({
  co <- coef(summary(precalcul$complet))
  co <- co[names(precalcul$complet$beta), , drop = FALSE]
  var <- sapply(rownames(co), function(n) explicatives[startsWith(n, explicatives)][1])
  echelle <- ifelse(var %in% c("Age", "Taille_cm"), 10, 1)   # effet de 10 ans ou 10 cm
  data.frame(var = var, Variable = unname(libelles[var]),
             Modalite = ifelse(var == "Age", "+10 ans", ifelse(var == "Taille_cm", "+10 cm", substring(rownames(co), nchar(var) + 1))),
             Reference = sapply(var, function(v) if (v %in% c("Age", "Taille_cm")) "" else levels(data[[v]])[1]),
             beta = echelle * co[, 1], se = echelle * co[, 2], p = co[, 4], row.names = NULL) %>%
    mutate(OR = exp(beta), bas = exp(beta - 1.96 * se), haut = exp(beta + 1.96 * se))
})

# Profil le plus courant : modalité la plus fréquente, âge et taille médians
profil_type <- lapply(data[explicatives], function(x) if (is.factor(x)) names(which.max(table(x))) else median(x))

probas_profil <- function(profil) {
  nd <- as.data.frame(lapply(explicatives, function(v) {
    if (is.factor(data[[v]])) factor(profil[[v]], levels = levels(data[[v]])) else as.numeric(profil[[v]])
  }), col.names = explicatives)
  p <- predict(precalcul$multinomial, newdata = nd, type = "probs")
  setNames(as.vector(p), niveaux)
}

# Contribution de Hodé : carte autonome dans un module.
source("R/carte_hode.R", local=TRUE)
source("R/parcours.R", local=TRUE)
source("R/validation.R", local=TRUE)
