# Carte de Hodé isolée : coordonnées et modalités issues de sa propre AFDM.
# Le sexe et la classe sont supplémentaires ; aucun objet de Baptiste n’est remplacé.
carte_hode_donnees <- local({
library(shiny)
library(readxl)
library(dplyr)
library(ggplot2)

# Lecture du fichier Excel -------------------------------------------------
chemin_fichier <- "Obesity_Dataset.xlsx"

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
  contenu <- jsonlite::base64_enc(readBin(file.path("apps", "observatoire", "www", "pictogrammes", paste0(nom, ".png")), "raw", n=1e6))
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


  list(donnees=donnees, donnees_afdm=donnees_afdm, individus_afdm=individus_afdm,
    modalites_afdm=modalites_afdm, resultat_afdm=resultat_afdm,
    choix_modalites_afdm=choix_modalites_afdm, noms_variables_afdm=noms_variables_afdm,
    couleurs_classes=couleurs_classes, rayon_ellipse=rayon_ellipse,
    sources_pictogrammes=sources_pictogrammes)
})

carte_hode_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(4, shiny::selectInput(ns("variable"), "Caractéristique à explorer", carte_hode_donnees$choix_modalites_afdm, selected="Activite")),
      shiny::column(4, shiny::uiOutput(ns("choix_focus"))),
      shiny::column(4, shiny::checkboxInput(ns("ellipses"), "Afficher les ellipses à 80 %", TRUE))
    ),
    plotly::plotlyOutput(ns("carte"), height="620px"),
    shiny::uiOutput(ns("resume")),
    shiny::p(class="note", "Icônes : modalités. Survolez les points pour lire les observations ; tracez un rectangle pour zoomer. Axes fixes et distances à la même échelle. Le sexe et la classe de poids sont supplémentaires dans cette carte. Les ellipses ne sont pas des frontières de classification.")
  )
}

carte_hode_server <- function(id) {
  with(carte_hode_donnees, shiny::moduleServer(id, function(input, output, session) {
    output$choix_focus <- shiny::renderUI({
      shiny::req(input$variable)
      modalites <- modalites_afdm$Modalite[modalites_afdm$Variable==input$variable]
      shiny::selectInput(session$ns("focus"), "Mettre une réponse en avant", c("Toutes les réponses"="",setNames(modalites,modalites)))
    })
    focus <- shiny::reactive({
      f <- input$focus
      if (is.null(f) || !f %in% modalites_afdm$Modalite[modalites_afdm$Variable==input$variable]) "" else f
    })
    output$carte <- plotly::renderPlotly({
    variable <- input$variable
    req(variable)
    focus <- focus()
    selection_assistant <- NULL
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
      if (isTRUE(input$ellipses)) {
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
    output$resume <- shiny::renderUI({
      shiny::req(input$variable)
      f <- focus()
      if (!nzchar(f)) return(shiny::p(class="note", "Choisissez une réponse pour mettre les personnes concernées en évidence."))
      d <- donnees[as.character(donnees_afdm[[input$variable]])==f,]
      n <- nrow(d)
      repartition <- table(d$Classe)
      shiny::div(class="hode-focus", shiny::strong(paste(f, "·", n, "personnes")),
        shiny::p(paste(paste(names(repartition), as.integer(repartition), sep=" : "),collapse=" · ")),
        shiny::p(class="note", "Répartition observée parmi les personnes ayant donné cette réponse ; aucune prédiction individuelle."))
    })
  }))
}
