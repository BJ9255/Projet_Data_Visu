# ============================================================
# server.R : logique serveur (calculs, graphiques, tests stat.)
# ============================================================

theme_app <- theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold"), legend.position = "bottom")

# Barres empilées à 100 % : répartition des niveaux d'obésité dans chaque modalité de `var`
plot_empile <- function(var) {
  comptes <- data_groupes %>%
    count(modalite = .data[[var]], Niveau_Obesite) %>%
    group_by(modalite) %>%
    mutate(pct = n / sum(n)) %>%
    ungroup()
  effectifs <- comptes %>% group_by(modalite) %>% summarise(n = sum(n))

  ggplot(comptes, aes(x = modalite, y = pct, fill = Niveau_Obesite)) +
    geom_col(width = 0.7) +
    geom_text(aes(label = ifelse(pct >= 0.05, scales::percent(pct, accuracy = 1), "")),
              position = position_stack(vjust = 0.5), size = 4) +
    geom_text(data = effectifs, aes(x = modalite, y = 1.03, label = paste0("n = ", n)),
              inherit.aes = FALSE, size = 3.8, vjust = 0) +
    scale_fill_manual(values = couleurs_niveau, name = NULL) +
    scale_y_continuous(labels = scales::percent, expand = expansion(mult = c(0, 0.08))) +
    labs(x = libelles[[var]], y = "Part des individus") +
    theme_app
}

# Résultat du test adapté au type des deux variables, mis en forme pour l'interface
ui_mesure <- function(v1, v2) {
  res <- mesure_lien(v1, v2)
  tagList(
    p(strong("Méthode : "), res$methode),
    p(res$detail),
    p(strong("p-value : "), format_p(res$p),
      if (res$p < 0.05) " → lien significatif" else " → pas de lien significatif"),
    p(strong("Force du lien : "), tolower(res$force)),
    if (isTRUE(res$effectifs_faibles))
      p(em("Attention : certains effectifs attendus sont inférieurs à 5, le test est à interpréter avec prudence."),
        style = "color: #b35900;")
  )
}

# Graphique adapté au type des deux variables
plot_couple <- function(v1, v2) {
  q1 <- v1 %in% vars_quanti
  q2 <- v2 %in% vars_quanti
  if (q1 && q2) {
    # Quanti x quanti : nuage de points + droite de régression
    ggplot(data, aes(x = .data[[v1]], y = .data[[v2]])) +
      geom_jitter(width = 0.3, height = 0.3, alpha = 0.35, colour = "steelblue") +
      geom_smooth(method = "lm", formula = y ~ x, colour = "red", se = TRUE) +
      labs(x = libelles[[v1]], y = libelles[[v2]]) +
      theme_app
  } else if (!q1 && !q2) {
    # Quali x quali : répartition de v2 dans chaque modalité de v1
    if (v2 == "Niveau_Obesite") return(plot_empile(v1))
    comptes <- data %>% count(mod1 = .data[[v1]], mod2 = .data[[v2]]) %>%
      group_by(mod1) %>% mutate(pct = n / sum(n)) %>% ungroup()
    ggplot(comptes, aes(x = mod1, y = pct, fill = mod2)) +
      geom_col(width = 0.7) +
      geom_text(aes(label = ifelse(pct >= 0.05, scales::percent(pct, accuracy = 1), "")),
                position = position_stack(vjust = 0.5), size = 4) +
      { if (v2 == "Niveau_Obesite") scale_fill_manual(values = couleurs_niveau, name = libelles[[v2]])
        else scale_fill_brewer(palette = "Set2", name = libelles[[v2]]) } +
      scale_y_continuous(labels = scales::percent) +
      labs(x = libelles[[v1]], y = "Part des individus") +
      theme_app
  } else {
    # Quali x quanti : boîtes à moustaches de la variable quantitative par groupe
    quanti <- if (q1) v1 else v2
    quali  <- if (q1) v2 else v1
    ggplot(data, aes(x = .data[[quali]], y = .data[[quanti]], fill = .data[[quali]])) +
      geom_boxplot(alpha = 0.8) +
      stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white") +
      { if (quali == "Niveau_Obesite") scale_fill_manual(values = couleurs_niveau)
        else scale_fill_brewer(palette = "Set2") } +
      labs(x = libelles[[quali]], y = libelles[[quanti]], caption = "Losange blanc : moyenne du groupe") +
      theme_app + theme(legend.position = "none")
  }
}

texte_anova <- function(var) {
  res <- mesure_lien(var, "Niveau_Obesite")
  paste0("ANOVA : ", res$detail, ", p-value ", format_p(res$p))
}

server <- function(input, output, session) {

  # TAB 1: Accueil - dictionnaire des variables
  output$dictionnaire <- renderTable({
    data.frame(
      Variable = names(data),
      Description = unname(libelles[names(data)]),
      Type = ifelse(names(data) %in% vars_quanti, "Quantitative",
                    ifelse(names(data) %in% vars_ordinales, "Qualitative ordinale", "Qualitative nominale")),
      Modalités = sapply(data, function(x) {
        if (is.factor(x)) paste(levels(x), collapse = " / ") else paste("de", min(x), "à", max(x))
      })
    )
  }, striped = TRUE, width = "100%")

  # TAB 2: Distributions
  # Le découpage est ignoré s'il n'apporte rien (même variable, ou âge par tranche d'âge)
  decoupage <- reactive({
    split <- input$dist_split
    var <- input$dist_var
    if (split == "aucun" || split == var || (var == "Age" && split == "Tranche_Age")) NULL else split
  })

  output$dist_note <- renderUI({
    if (input$dist_split != "aucun" && is.null(decoupage()))
      p(em("Découpage ignoré : il porte sur la variable observée elle-même."), style = "color: #777;")
  })

  output$dist_plot <- renderPlot({
    var <- input$dist_var
    split <- decoupage()

    if (var %in% vars_quanti) {
      if (is.null(split)) {
        ggplot(data_groupes, aes(x = .data[[var]])) +
          geom_histogram(binwidth = if (var == "Age") 2 else 3, fill = "steelblue", colour = "white", alpha = 0.85) +
          geom_vline(xintercept = mean(data_groupes[[var]]), colour = "red", linetype = "dashed", linewidth = 1) +
          labs(x = libelles[[var]], y = "Nombre d'individus",
               caption = "Trait rouge : moyenne") +
          theme_app
      } else {
        ggplot(data_groupes, aes(x = .data[[split]], y = .data[[var]], fill = .data[[split]])) +
          geom_violin(alpha = 0.6, colour = NA) +
          geom_boxplot(width = 0.2, alpha = 0.9, outlier.shape = NA) +
          { if (split == "Niveau_Obesite") scale_fill_manual(values = couleurs_niveau) } +
          labs(x = libelles[[split]], y = libelles[[var]]) +
          theme_app + theme(legend.position = "none")
      }
    } else {
      if (is.null(split)) {
        comptes <- data_groupes %>% count(modalite = .data[[var]]) %>% mutate(pct = n / sum(n))
        ggplot(comptes, aes(x = modalite, y = n, fill = modalite)) +
          geom_col(width = 0.7) +
          geom_text(aes(label = paste0(n, " (", scales::percent(pct, accuracy = 0.1), ")")), vjust = -0.4, size = 4.5) +
          { if (var == "Niveau_Obesite") scale_fill_manual(values = couleurs_niveau)
            else scale_fill_manual(values = rep("steelblue", nlevels(comptes$modalite))) } +
          scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
          labs(x = libelles[[var]], y = "Nombre d'individus") +
          theme_app + theme(legend.position = "none")
      } else {
        # Pourcentages calculés à l'intérieur de chaque groupe, pour comparer des groupes de tailles différentes
        comptes <- data_groupes %>%
          count(groupe = .data[[split]], modalite = .data[[var]]) %>%
          group_by(groupe) %>% mutate(pct = n / sum(n)) %>% ungroup()
        ggplot(comptes, aes(x = modalite, y = pct, fill = groupe)) +
          geom_col(position = position_dodge(width = 0.8), width = 0.75) +
          geom_text(aes(label = scales::percent(pct, accuracy = 1)),
                    position = position_dodge(width = 0.8), vjust = -0.4, size = 3.6) +
          { if (split == "Niveau_Obesite") scale_fill_manual(values = couleurs_niveau, name = NULL)
            else scale_fill_brewer(palette = "Set2", name = NULL) } +
          scale_y_continuous(labels = scales::percent, expand = expansion(mult = c(0, 0.1))) +
          labs(x = libelles[[var]], y = paste("Part au sein de chaque groupe :", tolower(libelles[[split]]))) +
          theme_app
      }
    }
  })

  output$dist_table <- renderDT({
    var <- input$dist_var
    split <- decoupage()
    d <- if (is.null(split)) mutate(data_groupes, groupe = "Ensemble") else mutate(data_groupes, groupe = .data[[split]])

    if (var %in% vars_quanti) {
      tab <- d %>%
        group_by(Groupe = groupe) %>%
        summarise(N = n(),
                  Moyenne = round(mean(.data[[var]]), 1),
                  Médiane = median(.data[[var]]),
                  Écart_type = round(sd(.data[[var]]), 1),
                  Min = min(.data[[var]]),
                  Max = max(.data[[var]]),
                  .groups = "drop")
    } else {
      # Une colonne par groupe : "effectif (% du groupe)"
      tab <- d %>%
        count(groupe, Modalité = .data[[var]]) %>%
        group_by(groupe) %>%
        mutate(valeur = paste0(n, " (", round(100 * n / sum(n), 1), " %)")) %>%
        ungroup() %>%
        select(-n) %>%
        pivot_wider(names_from = groupe, values_from = valeur, values_fill = "0 (0 %)")
    }
    datatable(tab, rownames = FALSE, options = list(dom = "t", paging = FALSE, ordering = FALSE))
  })

  output$table_donnees <- renderDT({
    datatable(data, class = "display nowrap",
              options = list(pageLength = 10, lengthMenu = c(10, 25, 50, 100), scrollX = TRUE))
  })

  # TAB 3: Facteurs non modifiables
  output$fixe_age <- renderPlot({
    ggplot(data, aes(x = Niveau_Obesite, y = Age, fill = Niveau_Obesite)) +
      geom_violin(alpha = 0.6, colour = NA) +
      geom_boxplot(width = 0.2, outlier.shape = NA) +
      scale_fill_manual(values = couleurs_niveau) +
      labs(x = NULL, y = "Âge") +
      theme_app + theme(legend.position = "none")
  })
  output$fixe_age_test <- renderText(texte_anova("Age"))

  # La taille dépend fortement du genre : on l'affiche séparément pour hommes et femmes
  output$fixe_taille <- renderPlot({
    ggplot(data, aes(x = Niveau_Obesite, y = Taille_cm, fill = Niveau_Obesite)) +
      geom_boxplot(outlier.alpha = 0.4) +
      facet_wrap(~ Genre) +
      scale_fill_manual(values = couleurs_niveau, name = NULL) +
      labs(x = NULL, y = "Taille (cm)") +
      theme_app +
      theme(axis.text.x = element_blank(), panel.grid.major.x = element_blank())
  })
  output$fixe_taille_test <- renderText(texte_anova("Taille_cm"))

  output$fixe_genre <- renderPlot(plot_empile("Genre"))
  output$fixe_genre_test <- renderUI(ui_mesure("Genre", "Niveau_Obesite"))
  output$fixe_antecedents <- renderPlot(plot_empile("Antecedents_Familiaux"))
  output$fixe_antecedents_test <- renderUI(ui_mesure("Antecedents_Familiaux", "Niveau_Obesite"))

  # TAB 4: Habitudes de vie
  output$habitude_plot <- renderPlot(plot_empile(input$habitude_var))
  output$habitude_test <- renderUI(ui_mesure(input$habitude_var, "Niveau_Obesite"))

  output$habitude_table <- renderDT({
    var <- input$habitude_var
    tab <- data %>%
      count(Modalité = .data[[var]], Niveau_Obesite) %>%
      group_by(Modalité) %>%
      mutate(Total = sum(n), valeur = paste0(n, " (", round(100 * n / Total, 1), " %)")) %>%
      ungroup() %>%
      select(Modalité, Niveau_Obesite, valeur, Total) %>%
      pivot_wider(names_from = Niveau_Obesite, values_from = valeur, values_fill = "0 (0 %)") %>%
      relocate(Total, .after = last_col())
    datatable(tab, rownames = FALSE, options = list(dom = "t", paging = FALSE, ordering = FALSE))
  })

  # TAB 5: Liens entre variables
  # Chaque couple est mesuré selon le type des variables : Pearson, khi-deux ou ANOVA
  ordre_vars <- c(vars_quanti, setdiff(vars_quali, "Niveau_Obesite"), "Niveau_Obesite")

  liaisons <- reactive({
    paires <- t(combn(ordre_vars, 2))
    bind_rows(lapply(seq_len(nrow(paires)), function(i) {
      res <- mesure_lien(paires[i, 1], paires[i, 2])
      data.frame(v1 = paires[i, 1], v2 = paires[i, 2], symbole = res$symbole,
                 valeur = res$valeur, p = res$p, force = res$force)
    }))
  })

  output$liaison_plot <- renderPlot({
    ordre <- unname(libelles_courts[ordre_vars])
    m <- liaisons() %>%
      mutate(x = factor(libelles_courts[v1], levels = ordre),
             y = factor(libelles_courts[v2], levels = rev(ordre)),
             classe = ifelse(p < 0.05, force, "Non significatif"),
             classe = factor(classe, levels = c("Non significatif", "Négligeable", "Faible", "Modéré", "Fort")),
             label = paste(symbole, fmt(valeur, 2)))
    ggplot(m, aes(x = x, y = y, fill = classe)) +
      geom_tile(colour = "white", linewidth = 1) +
      geom_text(aes(label = label, colour = classe == "Fort"), size = 3.7) +
      scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "black"), guide = "none") +
      scale_fill_manual(values = c("Non significatif" = "grey90", "Négligeable" = "#FEE5D9",
                                   "Faible" = "#FCAE91", "Modéré" = "#FB6A4A", "Fort" = "#CB181D"),
                        name = "Force du lien", drop = FALSE) +
      labs(x = NULL, y = NULL) +
      theme_app +
      theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 40, hjust = 1),
            legend.position = "right")
  })

  output$couple_plot <- renderPlot({
    req(input$couple_v1 != input$couple_v2)
    plot_couple(input$couple_v1, input$couple_v2)
  })

  output$couple_test <- renderUI({
    if (input$couple_v1 == input$couple_v2) return(p(em("Choisissez deux variables différentes.")))
    ui_mesure(input$couple_v1, input$couple_v2)
  })

  # TAB 6: Synthèse
  synthese <- reactive({
    bind_rows(lapply(c(facteurs_fixes, habitudes_vie), function(v) {
      res <- mesure_lien(v, "Niveau_Obesite")
      data.frame(
        Variable = libelles[[v]],
        Type = if (v %in% habitudes_vie) "Habitude de vie" else "Facteur non modifiable",
        Méthode = res$methode,
        Indicateur = res$symbole,
        Valeur = round(res$valeur, 3),
        Détail = res$detail,
        p_value = format_p(res$p),
        Force = res$force
      )
    })) %>% arrange(Indicateur, desc(Valeur))
  })

  output$synthese_plot <- renderPlot({
    s <- synthese() %>%
      mutate(Panneau = ifelse(Indicateur == "V", "Variables qualitatives : V de Cramér (khi-deux)",
                              "Variables quantitatives : η² (ANOVA)"))
    ggplot(s, aes(x = Valeur, y = reorder(Variable, Valeur), fill = Type)) +
      geom_col(width = 0.7) +
      geom_text(aes(label = format(Valeur, decimal.mark = ",")), hjust = -0.15, size = 4) +
      facet_grid(Panneau ~ ., scales = "free_y", space = "free_y") +
      scale_fill_manual(values = c("Facteur non modifiable" = "#9E9AC8", "Habitude de vie" = "#E6550D"), name = NULL) +
      scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
      labs(x = "Force du lien avec le niveau d'obésité", y = NULL) +
      theme_app +
      theme(strip.text.y = element_text(angle = 0, hjust = 0, face = "bold"))
  })

  output$synthese_table <- renderDT({
    datatable(synthese(), rownames = FALSE, options = list(dom = "t", paging = FALSE))
  })
}
