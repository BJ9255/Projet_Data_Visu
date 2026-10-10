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
    count(modalite, Niveau) %>% group_by(modalite) %>% mutate(total = sum(n), part = n / total) %>% ungroup()
  etiquettes <- with(distinct(d, modalite, total),
                     setNames(if (effectifs) paste0(modalite, "<br>n = ", total) else as.character(modalite), modalite))
  p <- ggplot(d, aes(x = modalite, y = part, fill = Niveau,
                     text = paste0(titre, " : ", modalite, "<br>", Niveau, " : ", n, " sur ", total, " (", pct(part), ")"))) +
    geom_col(width = 0.68, colour = encre, linewidth = 0.9) +
    geom_text(aes(label = ifelse(part >= 0.08, pct(part), ""), colour = texte_sur(Niveau)),
              position = position_stack(vjust = 0.5), size = 3.7, family = police) +
    scale_colour_identity() +
    scale_fill_manual(values = couleurs_niveau, name = NULL) +
    scale_x_discrete(labels = etiquettes) +
    scale_y_continuous(labels = scales::percent, breaks = seq(0, 1, 0.25)) +
    labs(x = NULL, y = NULL) +
    theme_app + theme(panel.grid.major.x = element_blank())
  interactif(p)
}

server <- function(input, output, session) {
  carte_hode_server("hode")

  # ============================================================
  # 1. CONTEXTE
  # ============================================================
  output$contexte_niveaux <- renderPlotly({
    d <- data %>% count(Niveau = Niveau_Obesite) %>% mutate(part = n / sum(n))
    p <- ggplot(d, aes(x = n, y = fct_rev(Niveau), fill = Niveau,
                       text = paste0(Niveau, " : ", n, " personnes (", pct(part, 1), ")"))) +
      geom_col(width = 0.62, colour = encre, linewidth = 0.9) +
      scale_y_discrete(labels = function(x) paste0(x, "  ·  ", table(data$Niveau_Obesite)[x], "  ·  ",
                                                    pct(prop.table(table(data$Niveau_Obesite))[x], 1))) +
      scale_fill_manual(values = couleurs_niveau) +
      scale_x_continuous(limits = c(0, 680)) +
      labs(x = NULL, y = NULL) +
      theme_app + theme(panel.grid.major.y = element_blank(), axis.text.x = element_blank(), panel.grid.major.x = element_blank())
    interactif(p, legende = "aucune")
  })

  # Navigation bornée aux cinq étapes du parcours.
  observeEvent(input$nav, {
    if (input$nav %in% names(pages)) updateTabsetPanel(session, "pages", input$nav)
  })

  # ============================================================
  # 2. EXPLORER LES LIENS
  # ============================================================
  # Corrélation signée de chaque variable avec le niveau d'obésité (barres divergentes autour de 0)
  output$classement <- renderPlotly({
    d <- correlations %>%
      mutate(Variable = factor(Variable, levels = rev(Variable)),
             Sens = ifelse(rho > 0, "Va avec plus d'obésité", "Va avec moins d'obésité"),
             texte = paste0(Variable, "<br>ρ de Spearman : ", ifelse(rho > 0, "+", ""), fmt(rho), "<br>p corrigée : ", fmt_p(p_holm),
                            "<br>", ifelse(rho > 0, "Plus d'obésité", "Moins d'obésité"), " quand on a tendance à ",
                            sens_lecture[var], ifelse(Groupe == "Facteur non modifiable", "<br>Facteur non modifiable", "")))
    choisie <- filter(d, var == input$explorer_var)
    p <- ggplot(d, aes(x = rho, y = Variable, fill = Sens, text = texte, customdata = var)) +
      geom_col(width = 0.68, colour = encre, linewidth = 0.7) +
      geom_col(data = choisie, fill = "#F7D23E66", colour = encre, linewidth = 1.6, width = 0.68) +
      geom_vline(xintercept = 0, colour = encre_3) +
      scale_fill_manual(values = c("Va avec plus d'obésité" = couleur_accent, "Va avec moins d'obésité" = "#6E6A60"),
                        name = NULL) +
      scale_x_continuous(limits = c(-0.65, 0.65), breaks = c(-0.5, 0, 0.5), labels = c("−0,5", "0", "+0,5")) +
      labs(x = NULL, y = NULL) +
      theme_app + theme(panel.grid.major.y = element_blank())
    interactif(p, source = "classement", legende = "aucune") %>% event_register("plotly_click")
  })

  output$classement_transport <- renderUI({
    v <- classement$V[classement$var == "Moyen_Transport"]
    p(class = "note", style = "margin: 6px 0 0;",
      actionLink("voir_transport", "Moyen de transport"),
      paste0(" : pas d'ordre entre voiture, vélo, marche…, donc pas de corrélation. Sa force du lien, de 0 à 1, vaut ",
             fmt(v), " (", force(v), ")."))
  })
  observeEvent(input$voir_transport, updateSelectInput(session, "explorer_var", selected = "Moyen_Transport"))

  # Clic sur une barre du classement : on explore cette variable
  observeEvent(input[["plotly_click-classement"]], {
    v <- event_data("plotly_click", source = "classement")$customdata
    if (!is.null(v) && v %in% explicatives) updateSelectInput(session, "explorer_var", selected = v)
  })

  output$explorer_barres <- renderPlotly({
    v <- req(input$explorer_var)
    barres_empilees(data_classes[[v]], libelles[[v]])
  })

  output$explorer_message <- renderUI({
    v <- req(input$explorer_var)
    r <- part_risque(v) %>% arrange(desc(risque))
    ecart <- HTML(paste0(" Parts observées de surpoids ou d’obésité : <strong>", pct(r$risque[1]), "</strong> pour « ", r$modalite[1],
                         " » (n = ", r$n[1], ") et <strong>", pct(r$risque[nrow(r)]), "</strong> pour « ", r$modalite[nrow(r)], " » (n = ", r$n[nrow(r)], ")."))
    if (v %in% vars_ordonnees) {
      l <- correlations[correlations$var == v, ]
      a_retenir(HTML(paste0("ρ de Spearman : <strong>", ifelse(l$rho > 0, "+", ""), fmt(l$rho), "</strong> ; p corrigée ", fmt_p(l$p_holm), ". ",
        if (l$p_holm >= .05) "Aucune association monotone détectée au seuil de 5 %." else
          paste0("Association brute ", if (l$rho > 0) "positive" else "négative", " avec la catégorie de poids quand on a tendance à ", sens_lecture[[v]], "."))), ecart)
    } else {
      a_retenir(HTML(paste0("Pas de corrélation possible (modalités sans ordre). Force du lien : <strong>",
                            fmt(classement$V[classement$var == v]), "</strong>.")), ecart)
    }
  })

  # ============================================================
  # 3. CE QUI COMPTE VRAIMENT
  # ============================================================
  # Profils prêts à l'emploi : on recopie leurs valeurs dans les réglages
  appliquer_profil <- function(profil) {
    updateSliderInput(session, "sim_Age", value = profil$Age)
    updateSliderInput(session, "sim_Taille_cm", value = profil$Taille_cm)
    for (v in setdiff(explicatives, c("Age", "Taille_cm"))) updateSelectInput(session, paste0("sim_", v), selected = profil[[v]])
  }
  observeEvent(input$profil_type, appliquer_profil(profil_type))
  observeEvent(input$profil_sain, updateSelectInput(session, "sim_Frequence_Legumes", selected = "Toujours"))
  observeEvent(input$profil_risque, updateSelectInput(session, "sim_Repas_Principaux", selected = "Plus de 3"))

  # Profil fictif : les 14 caractéristiques sont réglables.
  profil <- reactive({
    req(input$sim_Age, input$sim_Taille_cm,
        all(sapply(setdiff(explicatives, c("Age", "Taille_cm")), function(v) !is.null(input[[paste0("sim_", v)]]))))
    p <- profil_type
    p$Age <- input$sim_Age
    p$Taille_cm <- input$sim_Taille_cm
    for (v in setdiff(explicatives, c("Age", "Taille_cm"))) p[[v]] <- input[[paste0("sim_", v)]]
    p
  })
  probas <- reactive(probas_profil(profil()))
  observe({
    pr <- probas()
    r <- sum(pr[c("Surpoids", "Obésité")])
    rampe <- colorRampPalette(c(couleurs_niveau[["Normal"]], couleurs_niveau[["Surpoids"]], couleurs_niveau[["Obésité"]]))(101)
    session$sendCustomMessage("nombre", list(id = "sim_pct", valeur = round(100 * r), couleur = rampe[round(100 * r) + 1]))
  })
  risque <- function(pr) sum(pr[c("Surpoids", "Obésité")])

  output$sim_resultat <- renderUI({
    r <- risque(probas())
    r_type <- risque(probas_profil(profil_type))
    p(class = "comparaison", "Profil de référence fictif : ", pct(r_type),
      if (abs(r - r_type) >= 0.005) paste0(" · ", if (r > r_type) "+" else "−", fmt(100 * abs(r - r_type), 0), " points") else "")
  })

  output$sim_barres <- renderPlotly({
    pr <- probas()
    d <- data.frame(Niveau = factor(names(pr), levels = niveaux), proba = pr, y = "Profil")
    p <- ggplot(d, aes(x = proba, y = y, fill = Niveau, text = paste0(Niveau, " : ", pct(proba, 1)))) +
      geom_col(width = 0.7, colour = encre, linewidth = 0.9, position = position_stack(reverse = TRUE)) +
      geom_text(aes(label = ifelse(proba >= 0.07, pct(proba), ""), colour = texte_sur(Niveau)),
                position = position_stack(vjust = 0.5, reverse = TRUE), size = 3.8, family = police) +
      scale_colour_identity() +
      scale_fill_manual(values = couleurs_niveau, name = NULL) +
      scale_x_continuous(labels = scales::percent, expand = c(0, 0)) +
      labs(x = NULL, y = NULL) +
      theme_app + theme(axis.text.y = element_blank(), panel.grid.major.y = element_blank())
    interactif(p)
  })

  # Pour chaque habitude : probabilité de surpoids ou d'obésité selon sa modalité, les autres réglages fixés.
  # Le trait va de la modalité la plus favorable à la plus défavorable ; le point marque la modalité choisie.
  output$sim_effets <- renderPlotly({
    base <- profil()
    d <- bind_rows(lapply(habitudes_sim, function(v) {
      r <- sapply(levels(data[[v]]), function(m) risque(probas_profil(modifyList(base, setNames(list(m), v)))))
      data.frame(Habitude = libelles[[v]], min = min(r), max = max(r), actuel = r[[base[[v]]]],
                 favorable = names(r)[which.min(r)], defavorable = names(r)[which.max(r)], choisie = base[[v]])
    })) %>% mutate(Habitude = reorder(Habitude, max - min))
    d$texte <- paste0(d$Habitude, "<br>De ", pct(d$min), " (", d$favorable, ") à ", pct(d$max), " (", d$defavorable, ")",
                      "<br>Choix actuel : ", d$choisie, " → ", pct(d$actuel))
    p <- ggplot(d, aes(y = Habitude, text = texte)) +
      geom_segment(aes(x = min, xend = max, yend = Habitude), colour = gris_doux, linewidth = 3.2, lineend = "round") +
      geom_point(aes(x = actuel), colour = couleur_accent, size = 3.6) +
      scale_x_continuous(labels = scales::percent, limits = c(0, 1)) +
      labs(x = "Probabilité de surpoids ou d'obésité", y = NULL) +
      theme_app + theme(panel.grid.major.y = element_blank())
    interactif(p, legende = "aucune")
  })

  # Habitude dont le changement ferait le plus varier la probabilité, pour le profil réglé
  output$sim_levier <- renderUI({
    base <- profil()
    ecarts <- sapply(habitudes_sim, function(v) {
      r <- sapply(levels(data[[v]]), function(m) risque(probas_profil(modifyList(base, setNames(list(m), v)))))
      c(ecart = max(r) - min(r), min = min(r), max = max(r))
    })
    v <- colnames(ecarts)[which.max(ecarts["ecart", ])]
    a_retenir(HTML(paste0("Pour ce profil, l'habitude qui fait le plus varier la probabilité estimée est <strong>",
              tolower(libelles[[v]]), "</strong> : de <strong>", pct(ecarts["min", v]), "</strong> à <strong>",
              pct(ecarts["max", v]), "</strong> selon la réponse.")))
  })

  output$odds_ratios <- renderPlotly({
    d <- table_or %>% filter(var %in% c(habitudes_vie, "Age", "Genre")) %>%
      mutate(etiquette = paste0(Variable, " : ", Modalite, ifelse(Reference == "", "", paste0(" (", Reference, ")"))),
             etiquette = factor(etiquette, levels = rev(etiquette)),
             Effet = case_when(bas > 1 ~ "Associé à un niveau plus élevé", haut < 1 ~ "Associé à un niveau plus faible",
                               TRUE ~ "IC contenant 1"),
             texte = paste0(etiquette, "<br>OR = ", fmt(OR), " [", fmt(bas), " ; ", fmt(haut), "]"))
    p <- ggplot(d, aes(y = etiquette, colour = Effet, text = texte)) +
      geom_vline(xintercept = 1, linetype = "dashed", colour = encre_3) +
      geom_segment(aes(x = bas, xend = haut, yend = etiquette), linewidth = 1) +
      geom_point(aes(x = OR), size = 3) +
      scale_colour_manual(values = c("Associé à un niveau plus élevé" = couleurs_niveau[["Obésité"]],
                                     "Associé à un niveau plus faible" = "#3E8E57",
                                     "IC contenant 1" = "#77736A"), name = NULL) +
      scale_x_log10(breaks = c(0.1, 0.3, 1, 3, 10, 30), labels = function(x) format(x, decimal.mark = ",")) +
      labs(x = "Odds ratio (échelle logarithmique)", y = NULL) +
      theme_app
    interactif(p)
  })

  output$ajustement_messages <- renderUI({
    div(class = "messages",
      div(class = "message", span(class = "num", "01"),
          div(strong("Légumes et repas : une association après ajustement"),
              span("Dans le modèle multinomial, ces deux variables restent associées aux catégories de poids, les 13 autres caractéristiques prises en compte (tests globaux, p corrigées < 0,001). Cela ne prouve pas qu’un changement de réponse modifierait le poids."))),
      div(class = "message", span(class = "num", "02"),
          div(strong("Le tabac illustre l’importance du choix du modèle"),
              span(paste0("Dans les données, ", pct(part_obesite_tabac[["Oui"]]), " des fumeurs sont classés en obésité, contre ",
                pct(part_obesite_tabac[["Non"]]), " des non-fumeurs. L’association ajustée est détectée par le multinomial (p corrigée ",
                fmt_p(p_ajustee("Fumeur")), "). Le modèle ordinal ne la détecte pas, mais son hypothèse de cotes proportionnelles est rejetée : nous ne concluons donc pas à une disparition du lien.")))),
      div(class = "message", span(class = "num", "03"),
          div(strong("Activité physique : un résultat à questionner"),
              span("La corrélation brute est positive dans cet échantillon. Une adaptation des habitudes après une prise de poids est une explication possible, parmi d’autres ; cette enquête ne permet pas de vérifier la chronologie. Ce résultat ne démontre pas que l’activité physique ferait prendre du poids.")))
    )
  })

  output$associations_table <- renderUI({
    d <- associations_ajustees[associations_ajustees$var %in% habitudes_vie, ]
    # Ordre du questionnaire : la p-value ne sert pas à classer l’importance des habitudes.
    d <- d[match(habitudes_vie, d$var), ]
    div(class = "table-responsive", tags$table(class = "table table-associations",
      tags$caption("Associations avec la catégorie de poids, ajustées sur les autres caractéristiques"),
      tags$thead(tags$tr(tags$th(scope = "col", "Habitude"), tags$th(scope = "col", "p corrigée"))),
      tags$tbody(lapply(seq_len(nrow(d)), function(i)
        tags$tr(tags$th(scope = "row", d$Variable[i]), tags$td(fmt_p(d$p_holm[i])))))))
  })

  output$modele_qualite <- renderUI({
    base <- max(prop.table(table(data$Niveau_Obesite)))
    tagList(
      div(class = "tuiles",
        tuile(pct(precalcul$exactitude_cv[["multinomial"]], 1), "exactitude du multinomial · validation croisée à 10 plis"),
        tuile(pct(validation_modele$exactitude_equilibree, 1), "exactitude équilibrée · moyenne des rappels des quatre catégories"),
        tuile(pct(base, 1), "référence descriptive · toujours prédire la catégorie majoritaire « Normal »"),
        tuile(pct(min(validation_modele$rappel), 1), "rappel le plus faible · insuffisance pondérale")
      ),
      div(class = "grille-deux", style = "margin-top: 16px;",
        p(strong("Le multinomial pour les analyses principales. "),
          "Il estime séparément les quatre catégories sans imposer les cotes proportionnelles. Il sert aux tests ajustés et au simulateur. Les 14 caractéristiques sont incluses, sans sélection préalable. AIC : ",
          fmt(precalcul$aic[["multinomial"]], 0), " contre ", fmt(precalcul$aic[["ordinal"]], 0), " pour l’ordinal."),
        p(strong("Une validation interne, avec des limites. "),
          "L’exactitude est une moyenne sur 10 plis : à chaque tour, le modèle est réajusté sur 9 plis et évalué sur le pli restant. Le tableau ci-dessous utilise ces prédictions hors pli. La classe minoritaire est moins bien reconnue. La calibration des probabilités et la validité externe restent à évaluer.")),
      div(class = "table-responsive", tags$table(class = "table table-associations",
        tags$caption("Performances par catégorie sur les prédictions hors pli · rappel = part de la catégorie observée correctement reconnue ; précision = part des prédictions de cette catégorie qui sont correctes"),
        tags$thead(tags$tr(tags$th(scope = "col", "Catégorie observée"), tags$th(scope = "col", "n"), tags$th(scope = "col", "Rappel"), tags$th(scope = "col", "Précision"))),
        tags$tbody(lapply(niveaux, function(n) tags$tr(tags$th(scope = "row", n), tags$td(effectifs_niveaux[[n]]),
          tags$td(pct(validation_modele$rappel[[n]], 1)), tags$td(pct(validation_modele$precision[[n]], 1))))))),
      tags$details(class = "details-methode", tags$summary("Matrice de confusion : catégories observées et prédites"),
        div(class = "table-responsive", tags$table(class = "table table-associations",
          tags$caption("Lignes : catégories observées · colonnes : catégories prédites · prédictions hors pli"),
          tags$thead(tags$tr(tags$th(scope = "col", "Observée / prédite"), lapply(niveaux, function(n) tags$th(scope = "col", n)))),
          tags$tbody(lapply(niveaux, function(n) tags$tr(tags$th(scope = "row", n),
            lapply(as.integer(validation_modele$confusion[n, ]), tags$td))))))),
      tags$details(class = "details-methode", tags$summary("Détails des tests et limites de l’ordinal"),
        p("Tests ajustés : rapports de vraisemblance entre le multinomial complet et 14 modèles omettant chacun une caractéristique. Correction de Holm sur les 14 p-values. Une p-value faible n’indique ni un effet important ni une causalité."),
        p("L’ordinal suppose un effet commun entre les trois seuils des catégories. Cette hypothèse est rejetée pour ", precalcul$cotes_rejetees, " variables sur ", precalcul$cotes_testees,
          " testées au seuil de 5 % (tests non corrigés). Ses coefficients ne sont pas des moyennes garanties des effets par seuil. Ses odds ratios sont conservés en annexe à titre exploratoire ; son exactitude interne est de ",
          pct(precalcul$exactitude_cv[["ordinal"]], 1), "."),
        p("Protocole reproduit : graine 2024, 10 plis aléatoires de tailles proches, non stratifiés. Les rappels et précisions sont calculés sur l’ensemble des prédictions hors pli ; l’exactitude est la moyenne des exactitudes des plis."))
    )
  })

  # ============================================================
  # 4. PROFILS DE VIE
  # ============================================================
  # Les groupes de la CAH sont renumérotés du moins au plus touché par le surpoids et l'obésité
  k_groupes <- nlevels(groupes_profils)
  groupes <- groupes_profils
  couleurs_groupes <- setNames(rep(couleur_accent, k_groupes), levels(groupes))
  risque_groupe <- part_par_groupe
  classe_d_origine <- origine_groupes

  output$profils_obesite <- renderPlotly(barres_empilees(factor(sub("Groupe ", "", groupes), levels = sub("Groupe ", "", levels(groupes))),
                                                         "Groupe", effectifs = TRUE))

  output$profils_message <- renderUI({
    a_retenir(HTML(paste0("Selon le groupe, la part de surpoids ou d'obésité va de <strong>", pct(min(risque_groupe)),
               "</strong> à <strong>", pct(max(risque_groupe)), "</strong>. Ces écarts décrivent les groupes dans cet échantillon, sans validation de leur stabilité.")))
  })

  output$profils_portraits <- renderUI({
    div(class = "portraits", lapply(seq_len(k_groupes), function(k) {
      desc <- cah$desc.var$category[[classe_d_origine[[as.character(k)]]]]
      traits <- rownames(desc)[desc[, "v.test"] > 0 & !startsWith(rownames(desc), "Niveau_Obesite=")]
      traits <- sub("^[^=]*=", "", traits)
      traits <- head(traits, 3)
      r <- risque_groupe[[k]]
      couleur <- colorRampPalette(c(couleurs_niveau[["Normal"]], couleurs_niveau[["Surpoids"]], couleurs_niveau[["Obésité"]]))(101)[round(100 * r) + 1]
      div(class = "portrait",
        div(class = "portrait-tete",
            span(class = "portrait-nom", span(class = "pastille", style = paste0("background:", couleurs_groupes[[k]])),
                 levels(groupes)[k], span(class = "note", paste0("(", sum(groupes == levels(groupes)[k]), ")"))),
            span(class = "portrait-risque", pct(r))),
        p(class = "note", "Part observée de surpoids ou d’obésité"),
        div(class = "jauge", span(style = paste0("width:", round(100 * r), "%; background:", couleur))),
        tags$ul(lapply(traits, tags$li))
      )
    }))
  })
}
