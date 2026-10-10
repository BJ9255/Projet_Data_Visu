library(shiny)
library(readxl)
library(dplyr)
library(ggplot2)

# Lecture du fichier Excel -------------------------------------------------
chemin_fichier <- file.path("data", "Obesity_Dataset.xlsx")

donnees_brutes <- read_excel(chemin_fichier, sheet = 1, col_types = "text")

donnees <- donnees_brutes |>
  mutate(
    across(everything(), as.integer),
    Sexe = factor(Sex, levels = c(1, 2), labels = c("Homme", "Femme")),
    Classe = factor(
      Class,
      levels = 1:4,
      labels = c("Insuffisance pondérale", "Poids normal", "Surpoids", "Obésité")
    ),
    Famille = factor(
      Overweight_Obese_Family,
      levels = c(1, 2),
      labels = c("Oui", "Non")
    ),
    Fast_food = factor(
      Consumption_of_Fast_Food,
      levels = c(1, 2),
      labels = c("Oui", "Non")
    ),
    Legumes = factor(
      Frequency_of_Consuming_Vegetables,
      levels = 1:3,
      labels = c("Rarement", "Parfois", "Toujours")
    ),
    Activite = factor(
      Physical_Excercise,
      levels = 1:5,
      labels = c("Aucune", "1-2 jours", "3-4 jours", "5-6 jours", "Plus de 6 jours")
    ),
    Technologie = factor(
      Schedule_Dedicated_to_Technology,
      levels = 1:3,
      labels = c("0-2 heures", "3-5 heures", "Plus de 5 heures")
    ),
    Transport = factor(
      Type_of_Transportation_Used,
      levels = 1:5,
      labels = c("Automobile", "Moto", "Vélo", "Transport public", "Marche")
    )
  )

variables_habitudes <- c(
  "Antécédents familiaux" = "Famille",
  "Consommation de fast-food" = "Fast_food",
  "Consommation de légumes" = "Legumes",
  "Activité physique" = "Activite",
  "Temps consacré à la technologie" = "Technologie",
  "Mode de transport" = "Transport"
)
couleurs_classes <- c(
  "Insuffisance pondérale" = "#3B82B4",
  "Poids normal"           = "#38A169",
  "Surpoids"               = "#F2B134",
  "Obésité"                = "#D95F59"
)

dictionnaire_variables <- data.frame(
  Thème = c(
    rep("Profil", 3),
    rep("Alimentation", 7),
    rep("Mode de vie", 4),
    "Résultat"
  ),
  Variable = c(
    "Sexe", "Âge", "Taille",
    "Antécédents familiaux", "Consommation de fast-food",
    "Consommation de légumes", "Nombre de repas principaux",
    "Alimentation entre les repas", "Tabagisme", "Consommation de liquides",
    "Suivi de l'apport calorique", "Activité physique",
    "Temps consacré à la technologie", "Mode de transport",
    "Classe de poids"
  ),
  Description = c(
    "Homme ou femme",
    "Âge en années",
    "Taille en centimètres",
    "Oui ou non",
    "Oui ou non",
    "Rarement, parfois ou toujours",
    "1-2 repas, 3 repas ou plus de 3 repas",
    "Rarement, parfois, habituellement ou toujours",
    "Oui ou non",
    "Moins de 1 L, 1-2 L ou plus de 2 L par jour",
    "Oui ou non",
    "Aucune, 1-2, 3-4, 5-6 ou plus de 6 journées par semaine",
    "0-2 h, 3-5 h ou plus de 5 h par jour",
    "Automobile, moto, vélo, transport public ou marche",
    "Insuffisance pondérale, poids normal, surpoids ou obésité"
  ),
  Codage = c(
    "1 = Homme ; 2 = Femme",
    "Valeur entière",
    "Valeur entière",
    "1 = Oui ; 2 = Non",
    "1 = Oui ; 2 = Non",
    "1 = Rarement ; 2 = Parfois ; 3 = Toujours",
    "1 = 1-2 repas ; 2 = 3 repas ; 3 = Plus de 3 repas",
    "1 = Rarement ; 2 = Parfois ; 3 = Habituellement ; 4 = Toujours",
    "1 = Oui ; 2 = Non",
    "1 = Moins de 1 L ; 2 = 1-2 L ; 3 = Plus de 2 L",
    "1 = Oui ; 2 = Non",
    "1 = Aucune ; 2 = 1-2 jours ; 3 = 3-4 jours ; 4 = 5-6 jours ; 5 = Plus de 6 jours",
    "1 = 0-2 h ; 2 = 3-5 h ; 3 = Plus de 5 h",
    "1 = Automobile ; 2 = Moto ; 3 = Vélo ; 4 = Transport public ; 5 = Marche",
    "1 = Insuffisance pondérale ; 2 = Poids normal ; 3 = Surpoids ; 4 = Obésité"
  ),
  check.names = FALSE
)

repartition_classes <- donnees |>
  count(Classe, name = "Effectif") |>
  mutate(Part = paste0(round(100 * Effectif / sum(Effectif), 1), " %"))

# Analyse factorielle des données mixtes ---------------------------------
donnees_afdm <- donnees |>
  transmute(
    Age,
    Taille = Height,
    Sexe,
    Famille,
    Fast_food,
    Legumes,
    Repas = factor(
      Number_of_Main_Meals_Daily,
      levels = 1:3,
      labels = c("1-2 repas", "3 repas", "Plus de 3 repas")
    ),
    Entre_repas = factor(
      Food_Intake_Between_Meals,
      levels = 1:4,
      labels = c("Rarement", "Parfois", "Habituellement", "Toujours")
    ),
    Tabagisme = factor(Smoking, levels = 1:2, labels = c("Oui", "Non")),
    Hydratation = factor(
      Liquid_Intake_Daily,
      levels = 1:3,
      labels = c("Moins de 1 L", "1-2 L", "Plus de 2 L")
    ),
    Suivi_calories = factor(
      Calculation_of_Calorie_Intake,
      levels = 1:2,
      labels = c("Oui", "Non")
    ),
    Activite,
    Technologie,
    Transport,
    Classe
  )

# Le sexe et la classe de poids sont supplémentaires :
# ils servent à interpréter les axes sans participer à leur construction.
resultat_afdm <- FactoMineR::FAMD(
  donnees_afdm,
  sup.var = which(names(donnees_afdm) %in% c("Sexe", "Classe")),
  ncp = 5,
  graph = FALSE
)

variance_afdm <- data.frame(
  Dimension = factor(paste0("Dim. ", 1:5), levels = paste0("Dim. ", 1:5)),
  Variance = resultat_afdm$eig[1:5, 2]
)

individus_afdm <- data.frame(
  Dimension_1 = resultat_afdm$ind$coord[, 1],
  Dimension_2 = resultat_afdm$ind$coord[, 2],
  Classe = donnees_afdm$Classe
)

# Position des libellés au bord supérieur des ellipses à 80 %.
rayon_ellipse <- sqrt(qchisq(0.80, df = 2))
libelles_ellipses_afdm <- bind_rows(lapply(
  levels(individus_afdm$Classe),
  function(classe) {
    coordonnees <- individus_afdm[
      individus_afdm$Classe == classe,
      c("Dimension_1", "Dimension_2")
    ]
    centre <- colMeans(coordonnees)
    covariance <- cov(coordonnees)

    data.frame(
      Classe = factor(classe, levels = levels(individus_afdm$Classe)),
      Dimension_1 = centre[1] +
        rayon_ellipse * covariance[1, 2] / sqrt(covariance[2, 2]),
      Dimension_2 = centre[2] + rayon_ellipse * sqrt(covariance[2, 2])
    )
  }
))

noms_variables_afdm <- c(
  "Age" = "Âge",
  "Taille" = "Taille",
  "Sexe" = "Sexe",
  "Famille" = "Antécédents familiaux",
  "Fast_food" = "Consommation de fast-food",
  "Legumes" = "Consommation de légumes",
  "Repas" = "Nombre de repas",
  "Entre_repas" = "Alimentation entre les repas",
  "Tabagisme" = "Tabagisme",
  "Hydratation" = "Consommation de liquides",
  "Suivi_calories" = "Suivi de l'apport calorique",
  "Activite" = "Activité physique",
  "Technologie" = "Temps consacré à la technologie",
  "Transport" = "Mode de transport",
  "Classe" = "Classe de poids"
)

contributions_base <- data.frame(
  Variable = rownames(resultat_afdm$var$contrib),
  Dimension_1 = resultat_afdm$var$contrib[, 1],
  Dimension_2 = resultat_afdm$var$contrib[, 2]
)

ordre_contributions <- order(
  pmax(contributions_base$Dimension_1, contributions_base$Dimension_2),
  decreasing = TRUE
)
variables_principales <- contributions_base$Variable[ordre_contributions[1:8]]

contributions_afdm <- bind_rows(
  contributions_base |>
    transmute(Variable, Dimension = "Dimension 1", Contribution = Dimension_1),
  contributions_base |>
    transmute(Variable, Dimension = "Dimension 2", Contribution = Dimension_2)
) |>
  filter(Variable %in% variables_principales) |>
  mutate(
    Libelle = unname(noms_variables_afdm[Variable]),
    Libelle = factor(
      Libelle,
      levels = rev(unname(noms_variables_afdm[variables_principales]))
    )
  )

variables_actives_afdm <- names(donnees_afdm)[
  vapply(donnees_afdm, is.factor, logical(1))
]
variables_actives_afdm <- setdiff(variables_actives_afdm, c("Sexe", "Classe"))

modalites_actives_afdm <- bind_rows(lapply(variables_actives_afdm, function(variable) {
  data.frame(
    Variable = variable,
    Modalite = levels(donnees_afdm[[variable]]),
    Type = "Active"
  )
}))
modalites_actives_afdm$Dimension_1 <- resultat_afdm$quali.var$coord[, 1]
modalites_actives_afdm$Dimension_2 <- resultat_afdm$quali.var$coord[, 2]

variables_supplementaires_afdm <- c("Sexe", "Classe")
modalites_supplementaires_afdm <- bind_rows(lapply(
  variables_supplementaires_afdm,
  function(variable) {
    data.frame(
      Variable = variable,
      Modalite = levels(donnees_afdm[[variable]]),
      Type = "Supplémentaire"
    )
  }
))
modalites_supplementaires_afdm$Dimension_1 <- resultat_afdm$quali.sup$coord[, 1]
modalites_supplementaires_afdm$Dimension_2 <- resultat_afdm$quali.sup$coord[, 2]

modalites_afdm <- bind_rows(
  modalites_actives_afdm,
  modalites_supplementaires_afdm
)

# Pictogrammes existants : repères placés aux coordonnées exactes des modalités.
pictogrammes_modalites <- list(
  Sexe=c("mars", "venus"), Famille=c("users", "user"),
  Fast_food=c("burger", "leaf"), Legumes=c("seedling", "carrot", "leaf"),
  Repas=c("utensils", "bowl-food", "plus"),
  Entre_repas=c("apple-whole", "cookie-bite", "cookie-bite", "cookie-bite"),
  Tabagisme=c("smoking", "ban-smoking"),
  Hydratation=c("glass-water", "bottle-water", "droplet"),
  Suivi_calories=c("calculator", "minus"),
  Activite=c("couch", "person-walking", "person-running", "dumbbell", "medal"),
  Technologie=c("clock", "laptop", "mobile-screen-button"),
  Transport=c("car", "motorcycle", "bicycle", "bus", "person-walking"),
  Classe=rep("user", 4)
)
modalites_afdm$Icone <- vapply(seq_len(nrow(modalites_afdm)), function(i) {
  v <- modalites_afdm$Variable[i]
  position <- match(modalites_afdm$Modalite[i], levels(donnees_afdm[[v]]))
  pictogrammes_modalites[[v]][position]
}, character(1))
sources_pictogrammes <- setNames(lapply(unique(modalites_afdm$Icone), function(nom) {
  contenu <- jsonlite::base64_enc(readBin(file.path("www", "pictogrammes", paste0(nom, ".png")), "raw", n=1e6))
  paste0("data:image/png;base64,", gsub("[\r\n]", "", contenu))
}), unique(modalites_afdm$Icone))

choix_modalites_afdm <- c(
  setNames(
    variables_actives_afdm,
    unname(noms_variables_afdm[variables_actives_afdm])
  ),
  setNames(
    variables_supplementaires_afdm,
    paste0(
      unname(noms_variables_afdm[variables_supplementaires_afdm]),
      " (supplémentaire)"
    )
  )
)

# Préparation des données de la carte thermique -------------------------
creer_donnees_carte <- function(d) {
  tableaux <- list()

  for (nom_habitude in names(variables_habitudes)) {
    nom_variable <- variables_habitudes[[nom_habitude]]

    effectifs <- d |>
      transmute(
        Classe = as.character(Classe),
        Modalite = as.character(.data[[nom_variable]])
      ) |>
      count(Classe, Modalite, name = "Effectif")

    grille_complete <- expand.grid(
      Classe = levels(droplevels(d$Classe)),
      Modalite = levels(d[[nom_variable]]),
      stringsAsFactors = FALSE
    )

    tableaux[[nom_habitude]] <- grille_complete |>
      left_join(effectifs, by = c("Classe", "Modalite")) |>
      mutate(Effectif = coalesce(Effectif, 0L)) |>
      group_by(Classe) |>
      mutate(Proportion = Effectif / sum(Effectif)) |>
      ungroup() |>
      mutate(
        Classe = factor(Classe, levels = levels(d$Classe)),
        Modalite = factor(Modalite, levels = levels(d[[nom_variable]])),
        Habitude = nom_habitude
      )
  }

  bind_rows(tableaux) |>
    mutate(Habitude = factor(Habitude, levels = names(variables_habitudes)))
}

creer_graphique_carte <- function(tableau_carte) {
  seuil_texte <- 0.65

  tableau_carte <- tableau_carte |>
    mutate(Texte_clair = Proportion >= seuil_texte)

  ggplot(
    tableau_carte,
    aes(x = Classe, y = Modalite, fill = Proportion)
  ) +
    geom_tile(colour = "white", linewidth = 0.7) +
    geom_text(
      aes(
        label = paste0(round(100 * Proportion), " %"),
        colour = Texte_clair
      ),
      size = 3.5
    ) +
    scale_fill_gradient(
      low = "#EDF6F5",
      high = "#1F6F78",
      labels = function(x) paste0(round(100 * x), " %"),
      limits = c(0, 1)
    ) +
    scale_y_discrete(limits = rev) +
    scale_colour_manual(
      values = c("FALSE" = "#1F2937", "TRUE" = "white"),
      guide = "none"
    ) +
    labs(
      x = NULL,
      y = NULL
    ) +
    facet_grid(
      Habitude ~ .,
      scales = "free_y",
      space = "free_y",
      switch = "y"
    ) +
    guides(fill = "none") +
    theme_minimal(base_size = 13) +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_text(face = "bold"),
      strip.background = element_blank(),
      strip.placement = "outside",
      strip.text.y.left = element_text(angle = 0, face = "bold", hjust = 1),
      panel.spacing.y = grid::unit(0.5, "lines")
    )
}

if (file.exists(".Renviron")) readRenviron(".Renviron")
source(file.path("R", "assistant.R"), local = TRUE)
configuration_assistant <- assistant_config()

# Interface ---------------------------------------------------------------
carte_etape <- function(numero, titre, texte) {
  tags$div(class = "reading-card", tags$span(class = "step-number", numero),
    h4(titre), p(texte))
}
ui <- fluidPage(
  title = "Observatoire des profils · Habitudes de vie",
  tags$head(tags$link(rel = "stylesheet", href = "style.css"),
    tags$script(src = "interaction.js"),
    tags$script(src = "mascot.js", defer=NA),
    tags$script(src = "voice.js", defer=NA),
    tags$meta(name = "description", content = "Un observatoire interactif pour comprendre les profils et habitudes de vie grâce à l'AFDM.")),
  tags$nav(class = "brandbar", tags$div(class = "brand", tags$span(class = "brand-mark", "O"), "OBSERVATOIRE", tags$span("DES PROFILS", class = "brand-sub")),
    tags$span(class = "nav-caption", "Une exploration des habitudes de vie")),
  tags$header(class = "hero",
    tags$div(class = "hero-copy", tags$span(class = "eyebrow", "COMPRENDRE · EXPLORER · COMPARER"),
      h1("Des habitudes de vie.", tags$br(), tags$span("Des profils à explorer.")),
      p(class = "hero-description", "Quels profils se ressemblent et comment les classes de poids se répartissent-elles parmi ces profils ?"),
      tags$div(class = "hero-actions", actionButton("commencer", "Explorer la carte", class = "btn-primary"),
        tags$span("Une lecture guidée, même sans formation en statistiques."))),
    tags$div(class = "hero-aside", tags$span(class = "eyebrow", "LE JEU DE DONNÉES"),
      tags$div(class = "hero-stat", format(nrow(donnees), big.mark = " "), tags$span("personnes observées")),
      tags$div(class = "hero-mini", tags$div(strong("15"), tags$span("variables")), tags$div(strong("18–54"), tags$span("ans"))),
      tags$div(class = "hero-foot", "Des associations à explorer. Une population à contextualiser."))),
  tags$div(id="navigation-sections", class="section-menu",
    tags$div(tags$span(class="eyebrow", "OÙ ALLONS-NOUS ?"), tags$p("Choisissez votre prochaine exploration.")),
    selectInput("navigation_section", "Explorer le site", choices=c(
      "01 / Explorer les profils"="carte", "02 / Comparer les habitudes"="comparer",
      "03 / Comprendre la méthode"="methode", "04 / Explorer mon profil"="assistant"),
      selected="carte", selectize=FALSE, width="100%")),
  tabsetPanel(id = "onglets", selected = "carte",
    tabPanel("01 / Explorer les profils", value = "carte",
      tags$div(class = "section-heading", tags$div(tags$span(class = "eyebrow", "LA CARTE COMME POINT DE DÉPART"), h2("Ce qui nous rapproche.")),
        tags$span(class = "scope-badge", "Jeu complet · 1 610 observations")),
      tags$div(class = "reading-grid",
        carte_etape("01", "Un point, une personne", "Survolez un point pour découvrir son profil. Sa couleur indique sa classe de poids."),
        carte_etape("02", "Une proximité à explorer", "Des points proches ont des profils semblables sur ces deux axes. La carte ne résume pas toutes leurs différences."),
        carte_etape("03", "Une réponse comme repère", "Les icônes situent les modalités. Choisissez une réponse pour mettre ses personnes en évidence.")),
      tags$div(class = "exploration-grid",
        tags$aside(class = "control-card", tags$span(class = "eyebrow", "À VOUS D’EXPLORER"), h3("Une habitude à la fois"),
          selectInput("variable_modalites_public", "Caractéristique à explorer", choix_modalites_afdm, selected = "Activite"),
          uiOutput("choix_modalite_focus_public"),
          checkboxInput("afficher_ellipses", "Afficher les zones des classes", TRUE),
          tags$div(class = "control-tip", icon("computer-mouse"), " Survolez pour lire un profil. Tracez un rectangle pour zoomer ; double-cliquez pour revenir."),
          tags$hr(), tags$strong("Un repère commun"), p("Les axes restent fixes quand vous changez d’habitude. Vous comparez toujours la même carte.")),
        tags$div(class = "chart-card", tags$div(class = "chart-topline", h3("Carte des profils"), tags$span(class = "live-badge", "EXPLORATION INTERACTIVE")),
          uiOutput("assistant_carte_notice"),
          plotly::plotlyOutput("carte_interactive", height = "570px"),
          tags$div(class = "chart-caption", "Icônes : modalités, avec leurs libellés · Contours : ellipses normales à 80 %, sans frontières de classification."))),
      uiOutput("interpretation_afdm_public"),
      tags$div(class = "honesty-card", tags$div(tags$span(class = "inertia-number", paste0(format(round(sum(resultat_afdm$eig[1:2, 2]), 1), decimal.mark = ","), " %")), tags$span("de l’inertie sur les deux axes")),
        p("Une fenêtre sur les profils, pas une représentation complète. Le sexe et la classe de poids servent à lire la carte ; ils ne construisent pas les axes.")),
      tags$div(class = "next-step", p("Une proximité vous intrigue ? Comparez les proportions pour approfondir votre lecture."), actionButton("vers_comparaison", "Comparer les habitudes →", class = "btn-primary"))
    ),
    tabPanel("02 / Comparer les habitudes", value = "comparer",
      tags$div(class = "section-heading", tags$div(tags$span(class = "eyebrow", "DE LA CARTE AUX PROPORTIONS"), h2("Observer. Puis comparer."))),
      p(class = "section-intro", "Comment les réponses à une habitude se répartissent-elles au sein de chaque classe de poids ? Chaque barre représente 100 % d’une classe."),
      tags$div(class = "comparison-controls",
        selectInput("habitude", "Habitude à comparer", choices = variables_habitudes, selected = "Activite"),
        selectInput("sexe", "Sexe", c("Tous", levels(donnees$Sexe))),
        selectInput("classe", "Classe de poids", c("Toutes", levels(donnees$Classe))),
        sliderInput("age", "Âge", min = min(donnees$Age), max = max(donnees$Age), value = range(donnees$Age), step = 1),
        actionButton("reinitialiser", "Réinitialiser", icon = icon("rotate-left"))),
      tags$div(class = "selection-strip", textOutput("resume_filtres"), tags$span("Ces filtres s’appliquent uniquement aux comparaisons et aux données de cet onglet.")),
      tags$div(class = "chart-card", plotOutput("graphique_habitudes", height = "470px")),
      tags$details(tags$summary("Voir toutes les habitudes : carte thermique"),
        p("Chaque case indique le pourcentage d’une classe correspondant à une réponse. Les pourcentages se lisent au sein de chaque classe, pour chaque habitude."), plotOutput("carte_profils", height = "850px")),
      tags$details(tags$summary("Décrire le groupe sélectionné"),
        fluidRow(column(4, wellPanel(h4("Observations"), h2(textOutput("n_obs")))), column(4, wellPanel(h4("Âge moyen"), h2(textOutput("age_moyen")))), column(4, wellPanel(h4("Surpoids ou obésité"), h2(textOutput("part_exces"))))),
        plotOutput("graphique_classes", height = "400px"), plotOutput("graphique_profils", height = "480px")),
      tags$details(tags$summary("Consulter les observations sélectionnées"), p("Aperçu des 100 premières lignes."), tableOutput("tableau"))
    ),
    tabPanel("03 / Comprendre la méthode", value = "methode",
      tags$div(class = "section-heading", tags$div(tags$span(class = "eyebrow", "LE CONTEXTE COMPTE"), h2("Comprendre avant de conclure."))),
      tags$div(class = "method-grid",
        carte_etape("POUR QUI", "Découvrir l’analyse de données", "Cet observatoire s’adresse à des étudiants qui souhaitent comprendre une analyse multivariée sans connaissances statistiques avancées."),
        carte_etape("POURQUOI", "Rendre les profils lisibles", "Explorer ensemble les caractéristiques individuelles et les habitudes de vie, puis observer la répartition des classes de poids."),
        carte_etape("COMMENT", "Une AFDM, deux types de données", "L’analyse factorielle des données mixtes combine l’âge et la taille avec les réponses qualitatives sur les habitudes.")),
      tags$div(class = "chart-card", h3("Ce qui construit la carte"), p("Les habitudes, l’âge et la taille construisent les axes. Le sexe et la classe de poids sont des variables supplémentaires, utilisées pour l’interprétation."),
        fluidRow(column(5, plotOutput("graphique_afdm_variance", height = "360px")), column(7, plotOutput("graphique_afdm_contributions", height = "430px")))),
      tags$div(class = "limits-card", h3("Trois limites à garder en tête"), tags$ul(
        tags$li(strong("Association ≠ causalité. "), "Une différence observée ne démontre pas qu’une habitude provoque une classe de poids."),
        tags$li(strong("L’échantillon ≠ la population. "), "Les résultats décrivent ce fichier. La représentativité doit être vérifiée à partir des conditions de collecte."),
        tags$li(strong("La carte ≠ un diagnostic. "), "Les distances sont partielles, les modalités sont des repères et les ellipses ne classent pas les personnes."))),
      tags$details(tags$summary("Découvrir les données et leur codage"),
        fluidRow(column(4, wellPanel(h4("Observations"), h3(textOutput("total_observations")))), column(4, wellPanel(h4("Variables"), h3(textOutput("total_variables")))), column(4, wellPanel(h4("Valeurs manquantes"), h3(textOutput("total_manquantes"))))),
        tableOutput("dictionnaire_variables"), h3("Répartition des classes"), tableOutput("repartition_classes")),
      tags$div(class = "source-card", tags$span(class = "eyebrow", "SOURCE SCIENTIFIQUE"), p("Koklu, N. et Sulak, S.A. (2024), Sinop Üniversitesi Fen Bilimleri Dergisi, 9(1), 217–239."),
        tags$a(href = "https://doi.org/10.33484/sinopfbd.1445215", target = "_blank", rel = "noopener noreferrer", "Consulter l’article ↗"))
    ),
    assistant_ui(configuration_assistant)
  ),
  tags$footer(class = "site-footer", tags$span("OBSERVATOIRE DES PROFILS"), tags$span("Explorer les données. Comprendre leurs limites."))
)

# Serveur -----------------------------------------------------------------
server <- function(input, output, session) {

  assistant <- assistant_server(input, output, session, donnees_afdm, configuration_assistant)

  observeEvent(input$commencer, {
    updateTabsetPanel(session, "onglets", selected = "carte")
    session$sendCustomMessage("scroll-section", "onglets")
  })
  observeEvent(input$vers_comparaison, {
    if (input$variable_modalites_public %in% unname(variables_habitudes)) {
      updateSelectInput(session, "habitude", selected = input$variable_modalites_public)
    }
    updateTabsetPanel(session, "onglets", selected = "comparer")
    session$sendCustomMessage("scroll-section", "onglets")
  })

  output$carte_interactive <- plotly::renderPlotly({
    variable <- input$variable_modalites_public
    req(variable)
    focus <- modalite_focus_public()
    selection_assistant <- assistant$selection_carte()
    mise_en_avant <- !is.null(selection_assistant) || nzchar(focus)
    actif <- if (!is.null(selection_assistant)) seq_len(nrow(donnees)) %in% selection_assistant else if (nzchar(focus)) as.character(donnees_afdm[[variable]]) == focus else rep(TRUE, nrow(donnees))
    profil <- paste0("Observation ", seq_len(nrow(donnees)),
      "<br>Classe : ", donnees$Classe, "<br>Âge : ", donnees$Age,
      " ans<br>Taille : ", donnees$Height, " cm<br>",
      unname(noms_variables_afdm[variable]), " : ", donnees_afdm[[variable]])
    carte <- plotly::plot_ly(source = "profils")
    for (classe in levels(donnees$Classe)) {
      idx <- which(individus_afdm$Classe == classe)
      if (mise_en_avant) {
        fond <- idx[!actif[idx]]
        carte <- plotly::add_trace(carte, x = individus_afdm$Dimension_1[fond], y = individus_afdm$Dimension_2[fond],
          type = "scatter", mode = "markers", name = classe, legendgroup = classe, showlegend = FALSE,
          text = profil[fond], hoverinfo = "text", marker = list(color = couleurs_classes[[classe]], size = 5, opacity = 0.10))
      }
      points <- idx[actif[idx]]
      carte <- plotly::add_trace(carte, x = individus_afdm$Dimension_1[points], y = individus_afdm$Dimension_2[points],
        type = "scatter", mode = "markers", name = classe, legendgroup = classe,
        text = profil[points], hoverinfo = "text", marker = list(color = couleurs_classes[[classe]], size = if (mise_en_avant) 7 else 5, opacity = if (mise_en_avant) 0.8 else 0.45))
      if (isTRUE(input$afficher_ellipses)) {
        coords <- as.matrix(individus_afdm[idx, c("Dimension_1", "Dimension_2")])
        decomposition <- eigen(cov(coords), symmetric = TRUE)
        angles <- seq(0, 2 * pi, length.out = 100)
        ellipse <- t(decomposition$vectors %*% diag(sqrt(pmax(decomposition$values, 0))) %*% rbind(cos(angles), sin(angles))) * rayon_ellipse
        ellipse <- sweep(ellipse, 2, colMeans(coords), "+")
        carte <- plotly::add_trace(carte, x = ellipse[, 1], y = ellipse[, 2], type = "scatter", mode = "lines",
          name = classe, legendgroup = classe, showlegend = FALSE, hoverinfo = "skip",
          line = list(color = couleurs_classes[[classe]], width = 1.5))
      }
    }
    modalites <- modalites_afdm |> filter(Variable == variable)
    carte <- plotly::add_trace(carte, x = modalites$Dimension_1, y = modalites$Dimension_2,
      type = "scatter", mode = "markers+text", name = "Modalités", showlegend = FALSE,
      text = modalites$Modalite,
      textposition = rep(c("top center", "bottom left", "top right", "bottom right", "top left"), length.out = nrow(modalites)),
      textfont = list(size = 12, color = "#203e49"),
      hovertext = paste0(modalites$Modalite, "<br>Repère de modalité · ", modalites$Type), hoverinfo = "text",
      marker = list(symbol = "circle", size = ifelse(nzchar(focus) & modalites$Modalite == focus, 46, 35),
        color = "white", line = list(color = "#173f4b", width = ifelse(nzchar(focus) & modalites$Modalite == focus, 3, 1))))
    images_modalites <- lapply(seq_len(nrow(modalites)), function(i) {
      taille <- if (nzchar(focus) && modalites$Modalite[i] == focus) 0.52 else 0.40
      list(source=sources_pictogrammes[[modalites$Icone[i]]], xref="x", yref="y",
        x=modalites$Dimension_1[i], y=modalites$Dimension_2[i],
        sizex=taille, sizey=taille, xanchor="center", yanchor="middle", sizing="contain", layer="above")
    })
    carte <- plotly::layout(carte,
      images = images_modalites,
      xaxis = list(title = paste0("Dimension 1 · ", round(resultat_afdm$eig[1, 2], 1), " %"), range = range(c(individus_afdm$Dimension_1, modalites_afdm$Dimension_1)) * 1.15, zerolinecolor = "#c9d6dc", gridcolor = "#edf2f5"),
      yaxis = list(title = paste0("Dimension 2 · ", round(resultat_afdm$eig[2, 2], 1), " %"), range = range(c(individus_afdm$Dimension_2, modalites_afdm$Dimension_2)) * 1.2, zerolinecolor = "#c9d6dc", gridcolor = "#edf2f5", scaleanchor = "x", scaleratio = 1),
      font = list(family = "Arial, sans-serif", color = "#203e49", size = 12),
      paper_bgcolor = "transparent", plot_bgcolor = "transparent", hovermode = "closest",
      legend = list(orientation = "h", x = 0, y = -0.17, font = list(size = 16), itemsizing = "constant"),
      margin = list(l = 65, r = 20, t = 35, b = 115), dragmode = "zoom")
    plotly::config(carte, displaylogo = FALSE, scrollZoom = FALSE,
      modeBarButtonsToRemove = c("select2d", "lasso2d", "autoScale2d"),
      toImageButtonOptions = list(format = "png", filename = "carte-des-profils", width = 1400, height = 900, scale = 2))
  })

  observeEvent(input$reinitialiser, {
    updateSelectInput(session, "sexe", selected = "Tous")
    updateSelectInput(session, "classe", selected = "Toutes")
    updateSliderInput(session, "age", value = range(donnees$Age))
  })

  output$resume_filtres <- renderText({
    paste(nrow(donnees_filtrees()), "observations sélectionnées sur", nrow(donnees))
  })

  output$total_observations <- renderText({
    nrow(donnees_brutes)
  })

  output$total_variables <- renderText({
    ncol(donnees_brutes)
  })

  output$tranche_age <- renderText({
    paste0(min(donnees$Age), " à ", max(donnees$Age), " ans")
  })

  output$total_manquantes <- renderText({
    sum(is.na(donnees_brutes))
  })

  output$dictionnaire_variables <- renderTable({
    dictionnaire_variables
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$repartition_classes <- renderTable({
    repartition_classes
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  donnees_filtrees <- reactive({
    resultat <- donnees |>
      filter(Age >= input$age[1], Age <= input$age[2])

    if (input$sexe != "Tous") {
      resultat <- resultat |> filter(Sexe == input$sexe)
    }

    if (input$classe != "Toutes") {
      resultat <- resultat |> filter(Classe == input$classe)
    }

    resultat
  })

  output$n_obs <- renderText({
    nrow(donnees_filtrees())
  })

  output$age_moyen <- renderText({
    if (nrow(donnees_filtrees()) == 0) return("—")
    paste0(round(mean(donnees_filtrees()$Age), 1), " ans")
  })

  output$part_exces <- renderText({
    d <- donnees_filtrees()
    if (nrow(d) == 0) return("—")
    part <- mean(d$Classe %in% c("Surpoids", "Obésité"))
    paste0(round(100 * part, 1), " %")
  })

  output$graphique_classes <- renderPlot({
    d <- donnees_filtrees()
    validate(need(nrow(d) > 0, "Aucune observation avec ces filtres."))

    ggplot(d, aes(x = Classe, fill = Classe)) +
      geom_bar(show.legend = FALSE) +
      geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.4) +
      scale_fill_manual(values = couleurs_classes) +
      labs(
        title = "Répartition des classes de poids",
        x = NULL,
        y = "Nombre d'observations"
      ) +
      theme_minimal(base_size = 14) +
      theme(axis.text.x = element_text(angle = 15, hjust = 1))
  })

  output$graphique_profils <- renderPlot({
    d <- donnees_filtrees()
    validate(need(nrow(d) > 0, "Aucune observation avec ces filtres."))

    ggplot(d, aes(x = Age, y = Height, colour = Classe)) +
      geom_point(alpha = 0.55, position = position_jitter(width = 0.25, height = 0.25, seed = 123)) +
      facet_wrap(~ Sexe) +
      scale_colour_manual(values = couleurs_classes) +
      labs(
        title = "Âge et taille selon la classe de poids",
        x = "Âge (ans)",
        y = "Taille (cm)",
        colour = "Classe"
      ) +
      theme_minimal(base_size = 14) +
      theme(legend.position = "bottom")
  })

  output$graphique_habitudes <- renderPlot({
    d <- donnees_filtrees()
    validate(need(nrow(d) > 0, "Aucune observation avec ces filtres."))

    nom_variable <- input$habitude
    titre_variable <- names(variables_habitudes)[variables_habitudes == nom_variable]

    tableau_graphique <- d |>
      count(.data[[nom_variable]], Classe, name = "Effectif") |>
      group_by(Classe) |>
      mutate(Proportion = Effectif / sum(Effectif)) |>
      ungroup()

    ggplot(
      tableau_graphique,
      aes(x = Classe, y = Proportion, fill = .data[[nom_variable]])
    ) +
      geom_col(width = 0.65) +
      geom_text(aes(label = ifelse(Proportion >= 0.08, paste0(round(100 * Proportion), " %"), "")),
        position = position_stack(vjust = 0.5), colour = "#173f49", size = 4) +
      scale_y_continuous(labels = function(x) paste0(round(100 * x), " %")) +
      scale_fill_brewer(palette = "Set2", drop = FALSE) +
      labs(
        title = paste("Habitude par classe de poids :", titre_variable),
        x = NULL,
        y = "Part au sein de la classe",
        fill = titre_variable
      ) +
      theme_minimal(base_size = 14) +
      theme(
        axis.text.x = element_text(angle = 20, hjust = 1),
        legend.position = "bottom"
      )
  })

  output$carte_profils <- renderPlot({
    d <- donnees_filtrees()
    validate(need(nrow(d) > 0, "Aucune observation avec ces filtres."))

    creer_graphique_carte(creer_donnees_carte(d))
  })

  output$choix_modalite_focus_public <- renderUI({
    modalites <- modalites_afdm |>
      filter(Variable == input$variable_modalites_public) |>
      pull(Modalite) |>
      as.character()

    selectInput(
      "modalite_focus_public",
      "Mettre une réponse en avant",
      choices = c(
        "Toutes les réponses" = "__toutes__",
        setNames(modalites, modalites)
      ),
      selected = "__toutes__"
    )
  })

  modalite_focus_public <- reactive({
    valeur <- input$modalite_focus_public

    if (is.null(valeur) || valeur == "__toutes__" ||
        !valeur %in% modalites_afdm$Modalite[modalites_afdm$Variable == input$variable_modalites_public]) {
      return("")
    }

    valeur
  })

  output$interpretation_afdm_public <- renderUI({
    variable <- input$variable_modalites_public
    req(variable)
    focus <- modalite_focus_public()
    if (nzchar(focus)) {
      groupe <- donnees_afdm |> filter(as.character(.data[[variable]]) == focus)
      repartition <- groupe |> count(Classe, .drop = FALSE) |>
        mutate(part = if (nrow(groupe) > 0) 100 * n / nrow(groupe) else 0)
      tags$div(class = "insight-card",
        tags$div(tags$span(class = "eyebrow", "LA RÉPONSE EN CHIFFRES"), h3(paste(unname(noms_variables_afdm[variable]), "·", focus)),
          p(paste(nrow(groupe), "personnes correspondent à cette réponse. Les autres points restent visibles en arrière-plan."))),
        tags$div(class = "class-breakdown", lapply(seq_len(nrow(repartition)), function(i) {
          tags$div(class = "breakdown-item", tags$span(class = "class-dot", style = paste0("background:", couleurs_classes[as.character(repartition$Classe[i])])),
            tags$span(as.character(repartition$Classe[i])), strong(paste0(format(round(repartition$part[i], 1), decimal.mark = ","), " %")),
            tags$small(paste(repartition$n[i], "personnes")))
        })))
    } else {
      tags$div(class = "insight-card", tags$div(tags$span(class = "eyebrow", "VOTRE PREMIÈRE EXPLORATION"),
        h3("Une carte, plusieurs lectures."), p("Choisissez une réponse dans le panneau pour voir les personnes concernées et leur répartition entre les classes de poids.")),
        tags$div(class = "insight-note", "Comparez les groupes et leur dispersion. Une proximité entre une icône et une classe ne suffit pas à conclure à une association."))
    }
  })

  output$graphique_afdm_variance <- renderPlot({
    ggplot(variance_afdm, aes(x = Dimension, y = Variance)) +
      geom_col(fill = "#3B82B4", width = 0.7) +
      geom_text(
        aes(label = paste0(round(Variance, 1), " %")),
        vjust = -0.4,
        size = 3.8
      ) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
      labs(
        title = "Information expliquée par les axes",
        x = NULL,
        y = "Variance expliquée (%)"
      ) +
      theme_minimal(base_size = 13) +
      theme(panel.grid.major.x = element_blank())
  })

  output$graphique_afdm_contributions <- renderPlot({
    ggplot(
      contributions_afdm,
      aes(x = Contribution, y = Libelle, fill = Dimension)
    ) +
      geom_col(position = "dodge") +
      scale_fill_manual(
        values = c("Dimension 1" = "#3B82B4", "Dimension 2" = "#F2B134")
      ) +
      labs(
        title = "Variables les plus contributives",
        x = "Contribution (%)",
        y = NULL,
        fill = NULL
      ) +
      theme_minimal(base_size = 13) +
      theme(
        panel.grid.major.y = element_blank(),
        legend.position = "bottom"
      )
  })

  output$tableau <- renderTable({
    donnees_filtrees() |>
      select(Sexe, Age, Height, Classe, Famille, Fast_food, Legumes, Activite, Technologie, Transport) |>
      rename(
        Âge = Age,
        `Taille (cm)` = Height,
        `Antécédents familiaux` = Famille,
        `Fast-food` = Fast_food,
        Légumes = Legumes,
        `Activité physique` = Activite,
        Technologie = Technologie
      ) |>
      head(100)
  }, striped = TRUE, bordered = TRUE, spacing = "s")
}

shinyApp(ui = ui, server = server)
