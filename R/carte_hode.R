# Affichage interactif de Hodé, sur l’AFDM commune de Baptiste.
# La carte projette les individus et modalités sur une même AFDM.
carte_hode_donnees <- local({
  correspondance <- c(Sexe="Genre", Famille="Antecedents_Familiaux", Fast_food="Fast_Food",
    Legumes="Frequence_Legumes", Repas="Repas_Principaux", Entre_repas="Grignotage",
    Tabagisme="Fumeur", Hydratation="Consommation_Liquide", Suivi_calories="Suivi_Calories",
    Activite="Activite_Physique", Technologie="Temps_Ecrans", Transport="Moyen_Transport", Classe="Niveau_Obesite")
  donnees_afdm <- data[, unname(correspondance)]
  names(donnees_afdm) <- names(correspondance)
  donnees <- data.frame(Age=data$Age, Height=data$Taille_cm, Classe=data$Niveau_Obesite)
  individus_afdm <- data.frame(Dimension_1=afdm$ind$coord[,1], Dimension_2=afdm$ind$coord[,2], Classe=data$Niveau_Obesite)
  modalites_afdm <- afdm_modalites
  modalites_afdm$Variable <- names(correspondance)[match(modalites_afdm$var, correspondance)]
  modalites_afdm$Modalite <- modalites_afdm$modalite
  modalites_afdm$Dimension_1 <- modalites_afdm$x
  modalites_afdm$Dimension_2 <- modalites_afdm$y
  modalites_afdm$Type <- ifelse(modalites_afdm$Variable=="Classe", "Supplémentaire", "Active")
  noms_variables_afdm <- setNames(unname(libelles[correspondance]),names(correspondance))
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
  Classe=paste0("poids-", 1:4)
)
modalites_afdm$Icone <- vapply(seq_len(nrow(modalites_afdm)), function(i) {
  v <- modalites_afdm$Variable[i]
  position <- match(modalites_afdm$Modalite[i], levels(donnees_afdm[[v]]))
  pictogrammes_modalites[[v]][position]
}, character(1))
sources_pictogrammes <- setNames(lapply(unique(modalites_afdm$Icone), function(nom) {
  poids <- startsWith(nom, "poids-")
  chemin <- if (poids) file.path("www", "pictogrammes-poids", paste0(nom, ".svg")) else
    file.path("apps", "observatoire", "www", "pictogrammes", paste0(nom, ".png"))
  contenu <- jsonlite::base64_enc(readBin(chemin, "raw", n=1e6))
  paste0(if (poids) "data:image/svg+xml;base64," else "data:image/png;base64,", gsub("[\r\n]", "", contenu))
}), unique(modalites_afdm$Icone))


  choix_modalites_afdm <- setNames(names(correspondance), unname(noms_variables_afdm))
  list(donnees=donnees, donnees_afdm=donnees_afdm, individus_afdm=individus_afdm,
    modalites_afdm=modalites_afdm, resultat_afdm=afdm,
    choix_modalites_afdm=choix_modalites_afdm, noms_variables_afdm=noms_variables_afdm,
    couleurs_classes=couleurs_niveau, rayon_ellipse=sqrt(qchisq(.80,2)),
    sources_pictogrammes=sources_pictogrammes)
})

carte_hode_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::div(class="hode-map",
    shiny::div(class="hode-map-controls", shiny::fluidRow(
      shiny::column(4, shiny::selectInput(ns("variable"), "Caractéristique à explorer", carte_hode_donnees$choix_modalites_afdm, selected="Activite")),
      shiny::column(4, shiny::uiOutput(ns("choix_focus"))),
      shiny::column(4, shiny::checkboxInput(ns("ellipses"), "Ellipses de dispersion (repère 80 %)", FALSE))
    )),
    shiny::div(class="carte-afdm-boite", plotly::plotlyOutput(ns("carte"), height="620px")),
    shiny::uiOutput(ns("resume")),
    shiny::p(class="note", "Survolez les points ; tracez un rectangle pour zoomer ; double-cliquez pour réinitialiser la vue. Couleurs et formes distinguent les catégories. Les axes restent fixes lors des sélections, avec la même unité sur les deux dimensions. Les ellipses sont calculées sur les catégories entières, même lorsqu’une réponse est sélectionnée : repères de dispersion sous approximation normale, pas des intervalles de confiance ni des frontières de classification.")
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
          text = profil[fond], hoverinfo = "text", marker = list(color = couleurs_classes[[classe]], symbol = c("circle", "diamond", "square", "triangle-up")[match(classe, niveaux)], size = 5, opacity = 0.10))
      }
      points <- idx[actif[idx]]
      carte <- plotly::add_trace(carte, x = individus_afdm$Dimension_1[points], y = individus_afdm$Dimension_2[points],
        type = "scatter", mode = "markers", name = classe, legendgroup = classe,
        text = profil[points], hoverinfo = "text", marker = list(color = couleurs_classes[[classe]], symbol = c("circle", "diamond", "square", "triangle-up")[match(classe, niveaux)], size = if (mise_en_avant) 7 else 5, opacity = if (mise_en_avant) 0.9 else 0.65))
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
      textfont = list(size = 14, color = "#3A3833"),
      hovertext = paste0(modalites$Modalite, "<br>Repère de modalité · ", modalites$Type), hoverinfo = "text",
      marker = list(symbol = "circle", size = ifelse(nzchar(focus) & modalites$Modalite == focus, 46, 35),
        color = "white", line = list(color = "#1B1A17", width = ifelse(nzchar(focus) & modalites$Modalite == focus, 3, 1))))
    images_modalites <- lapply(seq_len(nrow(modalites)), function(i) {
      taille <- if (nzchar(focus) && modalites$Modalite[i] == focus) 0.52 else 0.40
      list(source=sources_pictogrammes[[modalites$Icone[i]]], xref="x", yref="y",
        x=modalites$Dimension_1[i], y=modalites$Dimension_2[i],
        sizex=taille, sizey=taille, xanchor="center", yanchor="middle", sizing="contain", layer="above")
    })
    carte <- plotly::layout(carte,
      images = images_modalites,
      xaxis = list(title = paste0("Dimension 1 · ", round(resultat_afdm$eig[1, 2], 1), " %"), range = range(c(individus_afdm$Dimension_1, modalites_afdm$Dimension_1)) * 1.15, zerolinecolor = "#1B1A1733", gridcolor = "#1B1A1714"),
      yaxis = list(title = paste0("Dimension 2 · ", round(resultat_afdm$eig[2, 2], 1), " %"), range = range(c(individus_afdm$Dimension_2, modalites_afdm$Dimension_2)) * 1.2, zerolinecolor = "#1B1A1733", gridcolor = "#1B1A1714", scaleanchor = "x", scaleratio = 1),
      font = list(family = "Nunito, sans-serif", color = "#3A3833", size = 12),
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
