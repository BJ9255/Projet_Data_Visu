# ============================================================
# server.R (version courte) : graphiques et calculs réactifs
# ============================================================

# Couleurs des graphiques : encre noire sur papier.
encre <- "#1B1A17"; encre_2 <- "#3A3833"; encre_3 <- "#6E6A60"; gris_doux <- "#1B1A1733"; grille <- "#1B1A1714"
fond_sombre <- "#1B1A17"
police <- "Nunito"

theme_app <- theme_minimal(base_size = 13, base_family = police) +
  theme(text = element_text(colour = encre_2), axis.text = element_text(colour = encre_3),
        axis.title = element_text(colour = encre_2, size = 12.5),
        panel.grid.major = element_line(colour = grille, linewidth = 0.5), panel.grid.minor = element_blank(),
        legend.position = "bottom")

# ggplot -> plotly : typographie de l'application, infobulles sobres, fond transparent
interactif <- function(p, tooltip = "text", legende = "haut", source = "A") {
  g <- ggplotly(p, tooltip = tooltip, source = source) %>%
    layout(font = list(family = police, color = encre_2),
           paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)",
           hoverlabel = list(bgcolor = "#FFFFFF", bordercolor = encre, font = list(family = police, color = encre, size = 13)),
           legend = list(font = list(size = 12.5, color = encre_2))) %>%
    config(displaylogo = FALSE, locale = "fr", displayModeBar = FALSE)
  
  switch(legende,
         haut = layout(g, legend = list(orientation = "h", x = 0, xanchor = "left", y = 1.02, yanchor = "bottom",
                                        title = list(text = "")), margin = list(t = 40)),
         aucune = layout(g, showlegend = FALSE))
}

# Texte lisible sur une barre colorée
texte_sur <- function(niveau) ifelse(niveau %in% c("Insuffisance pondérale", "Obésité"), "#FFFFFF", encre)

# Barres empilées à 100 % : niveau d'obésité dans chaque modalité d'un groupe
barres_empilees <- function(groupe, titre, effectifs = TRUE) {
  d <- data.frame(modalite = groupe, Niveau = data$Niveau_Obesite) %>%
    count(modalite, Niveau) %>% group_by(modalite) %>%
    mutate(total = sum(n), part = n / total, centre = 1 - cumsum(part) + part / 2) %>% ungroup()
  etiquettes <- with(distinct(d, modalite, total),
                     setNames(if (effectifs) paste0(modalite, "<br>n = ", total) else as.character(modalite), modalite))
  p <- ggplot(d, aes(x = modalite, y = part, fill = Niveau,
                     text = paste0(titre, " : ", modalite, "<br>", Niveau, " : ", n, " sur ", total, " (", pct(part), ")"))) +
    geom_col(width = 0.68, colour = encre, linewidth = 0.9) +
    geom_text(aes(y = centre, label = ifelse(part >= 0.08, pct(part), ""), colour = texte_sur(Niveau)),
              hjust = 0.5, vjust = 0.5, size = 3.7, family = police) +
    scale_colour_identity() +
    scale_fill_manual(values = couleurs_niveau, name = NULL) +
    scale_x_discrete(labels = etiquettes, limits = rev(levels(factor(groupe)))) +
    scale_y_continuous(labels = scales::percent, breaks = seq(0, 1, 0.25)) +
    coord_flip() +
    labs(x = NULL, y = NULL) +
    theme_app + theme(panel.grid.major.y = element_blank())
  interactif(p) %>% layout(yaxis = list(automargin = TRUE))
}

# Tableau lisible des effectifs observés ou attendus.
tableau_effectifs_ui <- function(m, attendus = FALSE) {
  div(class = "table-responsive", tags$table(class = "table table-associations",
                                             tags$caption(if (attendus) "Effectifs attendus sous l’hypothèse d’indépendance" else "Effectifs observés dans l’échantillon"),
                                             tags$thead(tags$tr(tags$th(scope = "col", "Réponse"), lapply(colnames(m), function(n) tags$th(scope = "col", n)), tags$th(scope = "col", "Total"))),
                                             tags$tbody(lapply(seq_len(nrow(m)), function(i) tags$tr(tags$th(scope = "row", rownames(m)[i]),
                                                                                                     lapply(m[i, ], function(n) tags$td(if (attendus) fmt(n, 1) else as.integer(n))), tags$td(fmt(sum(m[i, ]), 0))))),
                                             tags$tfoot(tags$tr(tags$th(scope = "row", "Total"), lapply(colSums(m), function(n) tags$td(fmt(n, 0))), tags$td(fmt(sum(m), 0))))))
}

server <- function(input, output, session) {
  carte_hode_server("hode")
  observeEvent(input$nav, {
    if (input$nav %in% names(pages)) updateTabsetPanel(session, "pages", input$nav)
  })
  
  # --- PRÉDICTEUR PROBABILISTE ---
  probas_prediction <- reactive({
    req(input$sim_genre, input$sim_age, input$sim_antecedents, input$sim_repas,
        input$sim_legumes, input$sim_fastfood, input$sim_grignotage, input$sim_liquide,
        input$sim_activite, input$sim_ecrans, input$sim_fumeur, input$sim_transport)
    
    nouveau_profil <- data.frame(
      Genre = factor(input$sim_genre, levels = levels(data_classes$Genre)),
      Age = factor(input$sim_age, levels = levels(data_classes$Age)),
      Antecedents_Familiaux = factor(input$sim_antecedents, levels = levels(data_classes$Antecedents_Familiaux)),
      Repas_Principaux = factor(input$sim_repas, levels = levels(data_classes$Repas_Principaux)),
      Frequence_Legumes = factor(input$sim_legumes, levels = levels(data_classes$Frequence_Legumes)),
      Fast_Food = factor(input$sim_fastfood, levels = levels(data_classes$Fast_Food)),
      Grignotage = factor(input$sim_grignotage, levels = levels(data_classes$Grignotage)),
      Consommation_Liquide = factor(input$sim_liquide, levels = levels(data_classes$Consommation_Liquide)),
      Activite_Physique = factor(input$sim_activite, levels = levels(data_classes$Activite_Physique)),
      Temps_Ecrans = factor(input$sim_ecrans, levels = levels(data_classes$Temps_Ecrans)),
      Fumeur = factor(input$sim_fumeur, levels = levels(data_classes$Fumeur)),
      Moyen_Transport = factor(input$sim_transport, levels = levels(data_classes$Moyen_Transport))
    )
    
    res <- predict(modele_optimal, newdata = nouveau_profil, type = "prob")
    probs <- as.numeric(res[1, ])
    names(probs) <- colnames(res)
    return(probs)
  })
  
  output$sim_resultat <- renderUI({
    probs <- probas_prediction()
    if (is.null(names(probs))) names(probs) <- levels(data$Niveau_Obesite)
    
    tagList(
      div(class = "tuiles", 
          tuile("Simulateur de tendances", "Régression multinomiale (Validée par CV 10 blocs)")),
      p(style = "margin: 15px 0 10px 0;", "Probabilités estimées par le modèle pour ce profil complet :"),
      div(class = "distribution-hero", style = "margin-bottom: 15px;",
          lapply(names(probs), function(niv) {
            p_val <- probs[[niv]]
            div(style = paste0("width:", 100 * p_val, "%;background:", couleurs_niveau[[niv]]))
          })
      ),
      div(class = "repartition-hero", 
          lapply(names(probs), function(niv) {
            p_val <- probs[[niv]]
            div(
              span(class = "pastille", style = paste0("background:", couleurs_niveau[[niv]])),
              span(niv), 
              strong(pct(p_val, 1))
            )
          })
      )
    )
  })
  
  # Calcul dynamique de la meilleure accuracy (en pourcentage arrondi à 1 décimale)
  output$texte_accuracy <- renderText({
    acc <- max(modele_optimal$results$Accuracy) * 100
    paste0("Le modèle sous-jacent a été validé par validation croisée à 10 blocs (exactitude / accuracy globale de ", round(acc, 1), "% sur l'échantillon).")
  })
  
  output$explorer_barres <- renderPlotly({
    v <- req(input$explorer_var)
    barres_empilees(data_classes[[v]], libelles[[v]])
  })
  output$explorer_message <- renderUI({
    v <- req(input$explorer_var)
    r <- part_risque(v) %>% arrange(desc(risque))
    a_retenir(HTML(paste0("Parts observées de surpoids ou d’obésité : <strong>", pct(r$risque[1]), "</strong> pour « ",
                          r$modalite[1], " » (n = ", r$n[1], ") et <strong>", pct(r$risque[nrow(r)]), "</strong> pour « ",
                          r$modalite[nrow(r)], " » (n = ", r$n[nrow(r)], "). Ces écarts ne démontrent pas un effet causal.")))
  })
  output$observer_suite <- renderUI({
    v <- req(input$explorer_var)
    if (v %in% variables_qualitatives) actionButton("tester_selection", "Tester cette association", class = "pilule")
    else p(class = "note", "L’âge et la taille sont regroupés ici pour décrire les répartitions. Ils restent quantitatifs dans l’AFDM ; les tests de la page suivante portent sur les variables qualitatives d’origine.")
  })
  observeEvent(input$tester_selection, {
    req(input$explorer_var %in% variables_qualitatives)
    updateSelectInput(session, "test_var", selected = input$explorer_var)
    updateTabsetPanel(session, "pages", "compte")
  })
  test_selection <- reactive({
    v <- req(input$test_var)
    req(v %in% variables_qualitatives)
    tests_independance[[v]]
  })
  output$test_resultat <- renderUI({
    t <- test_selection()
    tagList(
      div(class = "tuiles", tuile(paste0("p ", fmt_p(t$p)), t$methode)),
      if (t$conditions) p(class = "note", paste0("χ² = ", fmt(t$chi2), " · degrés de liberté = ", t$ddl)),
      div(class = "encadre", strong(if (t$p < .05) "H₀ rejetée au seuil de 5 %. " else "H₀ non rejetée au seuil de 5 %. "),
          if (t$p < .05) "Une association est détectée entre cette caractéristique et la catégorie de poids. Ce test ne donne pas le sens d’une cause ni son importance."
          else "Ce test ne met pas en évidence une association au seuil choisi ; cela ne démontre pas l’indépendance."),
      p(class = "note", "La p-value n’est pas la probabilité que H₀ soit vraie. Ces résultats concernent une association non ajustée sur les autres caractéristiques.")
    )
  })
  output$test_conditions <- renderUI({
    t <- test_selection()
    div(class = "message", div(strong("Conditions sur les effectifs attendus"),
                               span(paste0("Minimum : ", fmt(t$minimum_attendu, 1), " ; ", pct(t$part_attendus_5),
                                           " des cellules ont un effectif attendu ≥ 5. ",
                                           if (t$conditions) "Conditions retenues satisfaites : χ² utilisé." else "Conditions non satisfaites : Fisher utilisé."))))
  })
  output$test_tableau <- renderUI({
    t <- test_selection()
    tableau_effectifs_ui(if (isTRUE(input$test_attendus)) t$attendu else t$observe, isTRUE(input$test_attendus))
  })
  output$tests_resume <- renderUI({
    div(class = "table-responsive", tags$table(class = "table table-associations",
                                               tags$caption("Variables qualitatives croisées avec les quatre catégories de poids · p-values brutes, non classées par importance"),
                                               tags$thead(tags$tr(tags$th(scope = "col", "Caractéristique"), tags$th(scope = "col", "Test"), tags$th(scope = "col", "p-value"))),
                                               tags$tbody(lapply(seq_len(nrow(table_tests)), function(i) tags$tr(tags$th(scope = "row", table_tests$Variable[i]),
                                                                                                                 tags$td(table_tests$methode[i]), tags$td(fmt_p(table_tests$p[i])))))))
  })
}