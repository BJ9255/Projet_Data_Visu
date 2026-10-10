# ============================================================
# server.R (version courte) : graphiques et calculs réactifs
# ============================================================

# Couleurs des graphiques sur le fond sombre de l'application
# Couleurs des graphiques, style BD : encre noire sur papier
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

  # Question d'ouverture : le pari est révélé à l'étape 2
  output$pari_suite <- renderUI({
    req(input$pari)
    bonne <- correlations$var[correlations$Groupe == "Habitude de vie"][1]
    tagList(
      div(class = "pari-suite",
          span("Pari enregistré : ", strong(libelles[[input$pari]]), ". Tirons la réponse."),
          tags$button(id = "voir_reponse", class = "btn-ile", `data-bonne` = bonne, `data-choisi` = input$pari,
                      span("Révéler la réponse"), span(class = "bulle", ico("sparkle")))),
      div(class = "verdict")
    )
  })
  # Navigation : la pilule flottante envoie la page demandée
  observeEvent(input$nav, updateTabsetPanel(session, "pages", input$nav))

  output$pari_resultat <- renderUI({
    req(input$pari)
    hab <- correlations %>% filter(Groupe == "Habitude de vie") %>% mutate(rang = row_number())
    if (input$pari == "Moyen_Transport") {
      return(div(class = "pari-resultat", ico("lightbulb"),
        span(strong("Votre pari : moyen de transport. "), "Ses modalités n'ont pas d'ordre : on ne peut pas le classer par
             corrélation. L'habitude la plus liée est : ", tolower(hab$Variable[1]), " (corrélation ",
             paste0(ifelse(hab$rho[1] > 0, "+", ""), fmt(hab$rho[1])), ").")))
    }
    r <- hab[hab$var == input$pari, ]
    gagne <- r$rang == 1
    signe <- function(x) paste0(ifelse(x > 0, "+", ""), fmt(x))
    div(class = paste("pari-resultat", if (gagne) "gagne" else ""),
        ico(if (gagne) "check-circle" else "lightbulb"),
        span(strong("Votre pari : ", libelles[[input$pari]], ". "),
             if (gagne) paste0("C'est bien l'habitude la plus liée au niveau d'obésité (corrélation ", signe(r$rho), ").")
             else paste0("Elle arrive ", r$rang, "e sur ", nrow(hab), " habitudes (corrélation ", signe(r$rho),
                         "). La plus liée est : ", tolower(hab$Variable[1]), " (", signe(hab$rho[1]), ").")))
  })

  # ============================================================
  # 2. EXPLORER LES LIENS
  # ============================================================
  # Corrélation signée de chaque variable avec le niveau d'obésité (barres divergentes autour de 0)
  output$classement <- renderPlotly({
    d <- correlations %>%
      mutate(Variable = factor(Variable, levels = rev(Variable)),
             Sens = ifelse(rho > 0, "Va avec plus d'obésité", "Va avec moins d'obésité"),
             texte = paste0(Variable, "<br>Corrélation : ", ifelse(rho > 0, "+", ""), fmt(rho), " (lien ", Force, ")",
                            "<br>", ifelse(rho > 0, "Plus d'obésité", "Moins d'obésité"), " quand on a tendance à ",
                            sens_lecture[var], ifelse(Groupe == "Facteur non modifiable", "<br>Facteur non modifiable", "")))
    choisie <- filter(d, var == input$explorer_var)
    p <- ggplot(d, aes(x = rho, y = Variable, fill = Sens, text = texte, customdata = var)) +
      geom_col(width = 0.68, colour = encre, linewidth = 0.7) +
      geom_col(data = choisie, fill = "#F7D23E66", colour = encre, linewidth = 1.6, width = 0.68) +
      geom_vline(xintercept = 0, colour = encre_3) +
      scale_fill_manual(values = c("Va avec plus d'obésité" = couleurs_niveau[["Obésité"]], "Va avec moins d'obésité" = "#3E8E57"),
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

  # Carte de l'ACM : personnes en fond, ellipses par niveau d'obésité, modalités de la variable choisie
  output$afdm_carte <- renderPlotly({
    ind <- data.frame(x = afdm$ind$coord[, 1], y = afdm$ind$coord[, 2], Niveau = data$Niveau_Obesite)
    niv <- filter(afdm_modalites, var == "Niveau_Obesite") %>% mutate(Niveau = factor(modalite, levels = niveaux))
    virgule <- function(x) format(x, decimal.mark = ",")
    p <- ggplot(ind, aes(x = x, y = y)) +
      geom_hline(yintercept = 0, colour = gris_doux) + geom_vline(xintercept = 0, colour = gris_doux) +
      geom_point(aes(colour = Niveau), alpha = 0.22, size = 0.8) +
      stat_ellipse(aes(fill = Niveau), level = 0.5, geom = "polygon", alpha = 0.07, colour = NA) +
      stat_ellipse(aes(colour = Niveau), level = 0.5, linewidth = 1.2) +
      geom_path(data = niv, colour = encre_2, linewidth = 0.7, linetype = "dashed") +
      geom_point(data = niv, aes(fill = Niveau, text = paste("Point moyen :", modalite)), shape = 23, size = 5.5,
                 colour = encre, stroke = 1.2) +
      scale_colour_manual(values = couleurs_niveau, guide = "none") +
      scale_fill_manual(values = couleurs_niveau, guide = "none")
    p <- p + scale_x_continuous(labels = virgule) + scale_y_continuous(labels = virgule) +
      labs(x = nom_axe(1), y = nom_axe(2)) +
      theme_app
    # Même échelle sur les deux axes : les distances de la carte sont fidèles
    interactif(p, legende = "aucune") %>% layout(yaxis = list(scaleanchor = "x", scaleratio = 1))
  })

  output$afdm_message <- renderUI({
    a_retenir(HTML(paste0("Les quatre niveaux d'obésité s'alignent dans l'ordre le long de l'axe 1, construit par l'âge et l'alimentation,
      alors qu'ils n'ont pas servi à le construire. L'âge est la variable la plus liée à cet axe (corrélation ",
      fmt(afdm$quanti.var$coord["Age", 1]), ").")))
  })

  # Clic sur une barre du classement : on explore cette variable
  observeEvent(event_data("plotly_click", source = "classement"), {
    v <- event_data("plotly_click", source = "classement")$customdata
    if (!is.null(v) && v %in% explicatives) updateSelectInput(session, "explorer_var", selected = v)
  })

  output$explorer_barres <- renderPlotly({
    v <- input$explorer_var
    barres_empilees(data_classes[[v]], libelles[[v]])
  })

  output$explorer_message <- renderUI({
    v <- input$explorer_var
    r <- part_risque(v) %>% arrange(desc(risque))
    ecart <- HTML(paste0(" Surpoids ou obésité : <strong>", pct(r$risque[1]), "</strong> chez « ", r$modalite[1],
                         " » contre <strong>", pct(r$risque[nrow(r)]), "</strong> chez « ", r$modalite[nrow(r)], " »."))
    if (v %in% vars_ordonnees) {
      l <- correlations[correlations$var == v, ]
      a_retenir(HTML(paste0("Corrélation <strong>", ifelse(l$rho > 0, "+", ""), fmt(l$rho), "</strong> (lien ", l$Force, ") : ",
                            if (l$rho > 0) "le niveau d'obésité est plus élevé" else "le niveau d'obésité est plus faible",
                            " quand on a tendance à ", sens_lecture[[v]], ".")), ecart)
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
    for (v in c("Genre", habitudes_sim)) updateSelectInput(session, paste0("sim_", v), selected = profil[[v]])
  }
  observeEvent(input$profil_type, appliquer_profil(profils_demo$type))
  observeEvent(input$profil_sain, appliquer_profil(profils_demo$sain))
  observeEvent(input$profil_risque, appliquer_profil(profils_demo$risque))

  # Profil réglé par l'utilisateur ; les variables absentes des réglages restent au profil le plus courant
  profil <- reactive({
    req(input$sim_Age, input$sim_Genre, all(sapply(habitudes_sim, function(v) !is.null(input[[paste0("sim_", v)]]))))
    p <- profil_type
    p$Age <- input$sim_Age
    for (v in c("Genre", habitudes_sim)) p[[v]] <- input[[paste0("sim_", v)]]
    p
  })
  probas <- reactive(probas_profil(profil()))
  observe({
    pr <- probas()
    r <- sum(pr[c("Surpoids", "Obésité")])
    rampe <- colorRampPalette(c(couleurs_niveau[["Normal"]], couleurs_niveau[["Surpoids"]], couleurs_niveau[["Obésité"]]))(101)
    session$sendCustomMessage("corpulence", list(id = "sil_sim", k = corpulence(pr)))
    session$sendCustomMessage("nombre", list(id = "sim_pct", valeur = round(100 * r), couleur = rampe[round(100 * r) + 1]))
  })
  risque <- function(pr) sum(pr[c("Surpoids", "Obésité")])

  output$sim_resultat <- renderUI({
    r <- risque(probas())
    r_type <- risque(probas_profil(profil_type))
    p(class = "comparaison", "Profil le plus courant : ", pct(r_type),
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
    p <- ggplot(d, aes(y = Habitude)) +
      geom_segment(aes(x = min, xend = max, yend = Habitude), colour = gris_doux, linewidth = 3.2, lineend = "round") +
      geom_point(aes(x = actuel, text = texte), colour = couleur_accent, size = 3.6) +
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
                               TRUE ~ "Non significatif"),
             texte = paste0(etiquette, "<br>OR = ", fmt(OR), " [", fmt(bas), " ; ", fmt(haut), "]"))
    p <- ggplot(d, aes(y = etiquette, colour = Effet)) +
      geom_vline(xintercept = 1, linetype = "dashed", colour = encre_3) +
      geom_segment(aes(x = bas, xend = haut, yend = etiquette), linewidth = 1) +
      geom_point(aes(x = OR, text = texte), size = 3) +
      scale_colour_manual(values = c("Associé à un niveau plus élevé" = couleurs_niveau[["Obésité"]],
                                     "Associé à un niveau plus faible" = "#3E8E57",
                                     "Non significatif" = "#A9A6A0"), name = NULL) +
      scale_x_log10(breaks = c(0.1, 0.3, 1, 3, 10, 30), labels = function(x) format(x, decimal.mark = ",")) +
      labs(x = "Odds ratio (échelle logarithmique)", y = NULL) +
      theme_app
    interactif(p)
  })

  or_de <- function(v, m) table_or[table_or$var == v & table_or$Modalite == m, ]

  output$ajustement_messages <- renderUI({
    repas <- or_de("Repas_Principaux", "Plus de 3"); legumes <- or_de("Frequence_Legumes", "Toujours")
    tabac <- or_de("Fumeur", "Non")
    ic <- function(o) paste0("IC 95 % : ", fmt(o$bas), " à ", fmt(o$haut))
    div(class = "messages",
      div(class = "message", span(class = "num", "↗"),
          div(strong("Les repas et les légumes restent très associés"),
              span(paste0("Plus de 3 repas par jour multiplie la cote d'un niveau supérieur par ", fmt(repas$OR, 1), " (", ic(repas),
                          ") ; manger toujours des légumes la divise par ", fmt(1 / legumes$OR, 0), ".")))),
      div(class = "message", span(class = "num", "∅"),
          div(strong("L'association du tabac disparaît"),
              span(paste0("Prise seule, elle existe : 35 % des fumeurs sont obèses, contre 11 % des non-fumeurs. À caractéristiques
                          égales, elle n'est plus significative (OR des non-fumeurs ", fmt(tabac$OR), ", ", ic(tabac), ")."),
                   if (length(precalcul$retirees_aic) > 0)
                     paste0(" La sélection par AIC retirerait d'ailleurs : ", paste(tolower(libelles[precalcul$retirees_aic]), collapse = " et "), ".")))),
      div(class = "message", span(class = "num", "↺"),
          div(strong("Le sport et le suivi des calories vont dans le sens inverse de l'intuition"),
              span("Ils sont associés à un niveau plus élevé. L'enquête étant faite à un seul moment, une explication probable
                    est inverse : on se met au sport ou on compte ses calories à cause de son poids.")))
    )
  })

  output$modele_qualite <- renderUI({
    base <- max(prop.table(table(data$Niveau_Obesite)))
    tagList(
      div(class = "tuiles",
        tuile(pct(precalcul$exactitude_cv[["multinomial"]], 1), "bien classés par le modèle multinomial (validation croisée à 10 plis)"),
        tuile(pct(precalcul$exactitude_cv[["ordinal"]], 1), "bien classés par le modèle ordinal"),
        tuile(pct(base, 1), "en prédisant toujours « Normal » (référence sans modèle)"),
        tuile(paste(precalcul$cotes_rejetees, "/", precalcul$cotes_testees), "variables qui rejettent l'hypothèse des cotes proportionnelles")
      ),
      div(class = "grille-deux", style = "margin-top: 16px;",
        p(strong("Modèle ordinal, pour lire les associations. "), "Il donne un seul odds ratio par réponse, facile à lire. Mais il
          suppose qu'une variable a le même effet entre chaque niveau (normal → surpoids, surpoids → obésité…). Le test rejette
          cette hypothèse : ses odds ratios sont donc des moyennes sur les trois seuils, valables pour le sens et l'ordre de
          grandeur des associations."),
        p(strong("Modèle multinomial, pour les probabilités. "), "Il ne fait pas cette hypothèse. Il s'ajuste beaucoup mieux (AIC ",
          fmt(precalcul$aic[["multinomial"]], 0), " contre ", fmt(precalcul$aic[["ordinal"]], 0), ") et prédit mieux. C'est lui qui
          calcule toutes les probabilités du simulateur. Les deux modèles sont ajustés sur les 14 variables : aucune sélection
          préalable, pour que les intervalles de confiance restent valides.")
      )
    )
  })

  # ============================================================
  # 4. PROFILS DE VIE
  # ============================================================
  # Les groupes de la CAH sont renumérotés du moins au plus touché par le surpoids et l'obésité
  risque_brut <- tapply(data$Niveau_Obesite %in% c("Surpoids", "Obésité"), cah$data.clust$clust, mean)
  rang <- rank(risque_brut, ties.method = "first")
  k_groupes <- length(rang)
  groupes <- factor(paste("Groupe", rang[as.character(cah$data.clust$clust)]), levels = paste("Groupe", seq_len(k_groupes)))
  couleurs_groupes <- setNames(palette_classes[seq_len(k_groupes)], levels(groupes))
  risque_groupe <- tapply(data$Niveau_Obesite %in% c("Surpoids", "Obésité"), groupes, mean)
  classe_d_origine <- setNames(as.integer(names(rang)), rang)   # numéro de groupe -> classe de la CAH

  output$profils_obesite <- renderPlotly(barres_empilees(factor(sub("Groupe ", "", groupes), levels = sub("Groupe ", "", levels(groupes))),
                                                         "Groupe", effectifs = FALSE))

  output$profils_message <- renderUI({
    a_retenir(HTML(paste0("Selon le groupe, la part de surpoids ou d'obésité va de <strong>", pct(min(risque_groupe)),
               "</strong> à <strong>", pct(max(risque_groupe)), "</strong> : les profils de vie séparent nettement les niveaux d'obésité.")))
  })

  output$profils_portraits <- renderUI({
    div(class = "portraits", lapply(seq_len(k_groupes), function(k) {
      desc <- cah$desc.var$category[[classe_d_origine[[as.character(k)]]]]
      traits <- rownames(desc)[desc[, "v.test"] > 0]
      traits <- sub("^[^=]*=", "", traits)
      traits <- head(traits[!startsWith(traits, "Niveau d'obésité")], 3)
      r <- risque_groupe[[k]]
      couleur <- colorRampPalette(c(couleurs_niveau[["Normal"]], couleurs_niveau[["Surpoids"]], couleurs_niveau[["Obésité"]]))(101)[round(100 * r) + 1]
      # corpulence moyenne attendue du groupe, pour la mascotte
      k_mascotte <- corpulence(prop.table(table(factor(data$Niveau_Obesite[groupes == levels(groupes)[k]], levels = niveaux))))
      div(class = "portrait",
        silhouette_svg(k = round(k_mascotte, 2), hauteur = 111),
        div(class = "portrait-tete",
            span(class = "portrait-nom", span(class = "pastille", style = paste0("background:", couleurs_groupes[[k]])),
                 levels(groupes)[k], span(class = "note", paste0("(", sum(groupes == levels(groupes)[k]), ")"))),
            span(class = "portrait-risque", style = paste0("color:", couleur), pct(r))),
        div(class = "jauge", span(style = paste0("width:", round(100 * r), "%; background:", couleur))),
        tags$ul(lapply(traits, tags$li))
      )
    }))
  })
}
