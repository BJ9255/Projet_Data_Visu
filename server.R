# ============================================================
# server.R : logique serveur (calculs, graphiques, tests stat.)
# ============================================================

# SERVER
server <- function(input, output, session) {

  # TAB 1: Aperçu
  output$table_apercu <- renderDT({
    datatable(head(data, 10), options = list(pageLength = 10))
  })

  # TAB 2: Statistiques Descriptives
  output$summary_stats <- renderDT({
    stats_df <- data.frame(
      Variable = numeric_vars,
      Moyenne = sapply(data[numeric_vars], mean, na.rm = TRUE),
      Médiane = sapply(data[numeric_vars], median, na.rm = TRUE),
      SD = sapply(data[numeric_vars], sd, na.rm = TRUE),
      Min = sapply(data[numeric_vars], min, na.rm = TRUE),
      Max = sapply(data[numeric_vars], max, na.rm = TRUE)
    )
    datatable(stats_df, options = list(pageLength = 15))
  })

  output$dist_plots <- renderPlot({
    plots <- lapply(numeric_vars, function(var) {
      # Scores ordinaux (peu de valeurs) : diagramme en barres ; sinon histogramme
      geom_dist <- if (n_distinct(data[[var]]) <= 6) {
        geom_bar(fill = "steelblue", alpha = 0.7)
      } else {
        geom_histogram(fill = "steelblue", bins = 30, alpha = 0.7)
      }
      ggplot(data, aes(x = !!sym(var))) +
        geom_dist +
        labs(title = var, x = var, y = "Fréquence") +
        theme_minimal() +
        theme(plot.title = element_text(hjust = 0.5, size = 10, face = "bold"))
    })
    gridExtra::grid.arrange(grobs = plots, ncol = 3)
  })

  output$bar_plots <- renderPlot({
    var <- input$cat_var
    data_counts <- data %>% group_by(!!sym(var)) %>% summarise(count = n())
    ggplot(data_counts, aes(x = !!sym(var), y = count, fill = !!sym(var))) +
      geom_bar(stat = "identity", alpha = 0.7) +
      geom_text(aes(label = count), vjust = -0.3) +
      labs(title = paste("Distribution de", var), x = var, y = "Nombre") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "none")
  })

  # TAB 3: Niveau d'obésité (le jeu n'a pas de poids : pas d'IMC)
  output$obesity_summary <- renderPrint({
    cat("Répartition des niveaux d'obésité\n")
    cat("=================================\n\n")
    effectifs <- table(data$Niveau_Obesite)
    print(data.frame(Niveau = names(effectifs),
                     Effectif = as.integer(effectifs),
                     Pourcentage = round(100 * as.numeric(prop.table(effectifs)), 1)),
          row.names = FALSE)
  })

  output$profile_by_obesity <- renderDT({
    profil <- data %>%
      group_by(Niveau_Obesite) %>%
      summarise(
        N = n(),
        Age_moyen = round(mean(Age, na.rm = TRUE), 1),
        Taille_moyenne = round(mean(Taille_cm, na.rm = TRUE), 1),
        Activite_moyenne = round(mean(Activite_Physique, na.rm = TRUE), 2),
        Ecrans_moyen = round(mean(Temps_Ecrans, na.rm = TRUE), 2),
        Pct_Fast_Food = round(100 * mean(Fast_Food == "Oui"), 1),
        Pct_Antecedents = round(100 * mean(Antecedents_Familiaux == "Oui"), 1),
        .groups = 'drop'
      )
    datatable(profil, options = list(dom = 't'))
  })

  output$obesity_bar <- renderPlot({
    ggplot(data, aes(x = Niveau_Obesite, fill = Niveau_Obesite)) +
      geom_bar(alpha = 0.7) +
      geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.3) +
      labs(title = "Effectifs par niveau d'obésité", x = "Niveau d'obésité", y = "Nombre") +
      theme_minimal() +
      theme(legend.position = "none")
  })

  output$age_height_scatter <- renderPlotly({
    plot_ly(data, x = ~jitter(Age), y = ~jitter(Taille_cm), color = ~Niveau_Obesite,
            type = "scatter", mode = "markers",
            marker = list(size = 5, opacity = 0.7)) %>%
      layout(title = "Taille vs Âge par niveau d'obésité", xaxis = list(title = "Âge"),
             yaxis = list(title = "Taille (cm)"))
  })

  output$obesity_gender <- renderPlot({
    ggplot(data, aes(x = Genre, fill = Niveau_Obesite)) +
      geom_bar(position = "fill", alpha = 0.8) +
      scale_y_continuous(labels = scales::percent) +
      labs(title = "Niveau d'obésité par genre", x = "Genre", y = "Proportion", fill = "Niveau") +
      theme_minimal()
  })

  output$obesity_factor <- renderPlot({
    var <- input$obesity_cross_var
    ggplot(data, aes(x = factor(!!sym(var)), fill = Niveau_Obesite)) +
      geom_bar(position = "fill", alpha = 0.8) +
      scale_y_continuous(labels = scales::percent) +
      labs(title = paste("Niveau d'obésité selon", var), x = var, y = "Proportion", fill = "Niveau") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })

  # TAB 4: Corrélations (Spearman : la plupart des variables sont des scores ordinaux)
  output$corr_matrix <- renderPlot({
    data_numeric <- data[, numeric_vars]
    corr_matrix <- cor(data_numeric, use = "complete.obs", method = "spearman")
    corrplot(corr_matrix, method = "circle", type = "upper", tl.cex = 0.8,
             addCoef.col = "black", number.cex = 0.7)
  })

  output$obesity_correlations <- renderDT({
    data_numeric <- data[, numeric_vars]
    corr_with_score <- cor(data_numeric, use = "complete.obs", method = "spearman")[, "Score_Obesite"]
    corr_df <- data.frame(
      Variable = names(corr_with_score),
      Corrélation = round(as.numeric(corr_with_score), 3)
    ) %>%
      filter(Variable != "Score_Obesite") %>%
      arrange(desc(abs(Corrélation)))
    datatable(corr_df)
  })

  output$select_vars_corr <- renderUI({
    selectInput("corr_selected_vars", "Choisir 4-6 variables:", numeric_vars,
                multiple = TRUE, selected = numeric_vars[1:4])
  })

  output$scatter_matrix <- renderPlot({
    if (is.null(input$corr_selected_vars)) {
      plot.new()
    } else {
      data_subset <- data[, input$corr_selected_vars]
      ggpairs(data_subset, alpha = 0.5)
    }
  })

  # TAB 5: ACP
  pca_result <- eventReactive(input$run_pca, {
    req(input$pca_vars)
    data_pca <- na.omit(data[, input$pca_vars])
    PCA(data_pca, scale.unit = TRUE, ncp = 5, graph = FALSE)
  })

  output$pca_variance <- renderPlot({
    pca <- pca_result()
    fviz_eig(pca, addlabels = TRUE, barfill = "steelblue")
  })

  output$pca_variance_table <- renderDT({
    pca <- pca_result()
    var_table <- data.frame(
      PC = paste("PC", 1:5, sep = ""),
      Variance = pca$eig[1:5, 1],
      Cumulative = pca$eig[1:5, 3]
    )
    datatable(var_table)
  })

  output$pca_biplot1 <- renderPlot({
    pca <- pca_result()
    fviz_pca_biplot(pca, axes = c(1, 2), repel = TRUE, alpha = 0.7)
  })

  output$pca_biplot2 <- renderPlot({
    pca <- pca_result()
    fviz_pca_biplot(pca, axes = c(1, 3), repel = TRUE, alpha = 0.7)
  })

  output$pca_circle <- renderPlot({
    pca <- pca_result()
    fviz_pca_var(pca, col.var = "contrib", gradient.cols = c("blue", "red"), repel = TRUE)
  })

  output$pca_vars <- renderPlot({
    pca <- pca_result()
    fviz_pca_var(pca, axes = c(1, 2))
  })

  output$pca_contrib <- renderPlot({
    pca <- pca_result()
    p1 <- fviz_contrib(pca, choice = "var", axes = 1, top = 10)
    p2 <- fviz_contrib(pca, choice = "var", axes = 2, top = 10)
    gridExtra::grid.arrange(p1, p2, ncol = 2)
  })

  # TAB 6: ANOVA
  anova_result <- eventReactive(input$run_anova, {
    factor_var <- input$anova_factor
    response_var <- input$anova_response

    formula_str <- paste(response_var, "~", factor_var)
    aov_model <- aov(as.formula(formula_str), data = data)
    list(model = aov_model, formula = formula_str)
  })

  output$anova_table <- renderPrint({
    result <- anova_result()
    summary(result$model)
  })

  output$anova_boxplot <- renderPlot({
    result <- anova_result()
    factor_var <- input$anova_factor
    response_var <- input$anova_response

    ggplot(data, aes(x = !!sym(factor_var), y = !!sym(response_var), fill = !!sym(factor_var))) +
      geom_boxplot(alpha = 0.7) +
      geom_jitter(width = 0.2, alpha = 0.3) +
      labs(title = paste(response_var, "par", factor_var), x = factor_var, y = response_var) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")
  })

  output$anova_group_stats <- renderDT({
    factor_var <- input$anova_factor
    response_var <- input$anova_response

    group_stats <- data %>%
      group_by(!!sym(factor_var)) %>%
      summarise(
        Moyenne = mean(!!sym(response_var), na.rm = TRUE),
        Médiane = median(!!sym(response_var), na.rm = TRUE),
        SD = sd(!!sym(response_var), na.rm = TRUE),
        N = n(),
        .groups = 'drop'
      )
    datatable(group_stats)
  })

  output$anova_diagnostics <- renderPlot({
    result <- anova_result()
    par(mfrow = c(2, 2))
    plot(result$model)
    par(mfrow = c(1, 1))
  })

  # TAB 7: Tests Statistiques
  output$ttest_results <- renderDT({
    var <- input$ttest_var
    group_var <- input$ttest_group

    groups <- unique(data[[group_var]])
    if (length(groups) != 2) {
      return(NULL)
    }

    group1 <- data[data[[group_var]] == groups[1], var]
    group2 <- data[data[[group_var]] == groups[2], var]

    t_result <- t.test(group1, group2)

    result_df <- data.frame(
      Groupe1 = groups[1],
      Groupe2 = groups[2],
      Moyenne1 = mean(group1, na.rm = TRUE),
      Moyenne2 = mean(group2, na.rm = TRUE),
      t_statistic = t_result$statistic,
      p_value = t_result$p.value
    )
    datatable(result_df)
  })

  output$kw_test <- renderPrint({
    var <- input$ttest_var
    group_var <- input$ttest_group
    kw_result <- kruskal.test(as.formula(paste(var, "~", group_var)), data = data)
    print(kw_result)
  })

  output$normality_test <- renderDT({
    normality_results <- data.frame(
      Variable = numeric_vars,
      Shapiro_Statistic = NA,
      p_value = NA
    )

    for (i in seq_along(numeric_vars)) {
      sw_test <- shapiro.test(data[[numeric_vars[i]]])
      normality_results$Shapiro_Statistic[i] <- sw_test$statistic
      normality_results$p_value[i] <- sw_test$p.value
    }
    datatable(normality_results)
  })

  output$levene_test <- renderPrint({
    if (require("car")) {
      levene_result <- leveneTest(data$Age ~ data$Niveau_Obesite)
      print(levene_result)
    } else {
      print("Package 'car' non installé")
    }
  })

  output$chi2_test <- renderPrint({
    var <- input$chi2_var
    tableau <- table(data[[var]], data$Niveau_Obesite)
    print(tableau)
    cat("\n")
    print(chisq.test(tableau))
  })

  # TAB 8: Visualisations Avancées
  output$heatmap_plot <- renderPlot({
    data_numeric <- data[, numeric_vars]
    corr_matrix <- cor(data_numeric, use = "complete.obs", method = "spearman")
    heatmap(corr_matrix, scale = "none", col = colorRampPalette(c("blue", "white", "red"))(100))
  })

  output$pairplot <- renderPlot({
    if (is.null(input$pair_vars)) {
      plot.new()
    } else {
      data_subset <- data[, input$pair_vars]
      ggpairs(data_subset, lower = list(continuous = wrap("points", alpha = 0.3)),
              diag = list(continuous = "densityDiag"))
    }
  })

  output$plot_3d <- renderPlotly({
    plot_ly(data, x = ~Age, y = ~Taille_cm, z = ~jitter(Activite_Physique), color = ~Niveau_Obesite,
            type = "scatter3d", mode = "markers",
            marker = list(size = 4, opacity = 0.7)) %>%
      layout(title = "Âge vs Taille vs Activité physique par niveau d'obésité",
             scene = list(xaxis = list(title = "Âge"), yaxis = list(title = "Taille (cm)"),
                          zaxis = list(title = "Activité physique (1-5)")))
  })

  output$violin_obesity <- renderPlot({
    ggplot(data, aes(x = Niveau_Obesite, y = Age, fill = Niveau_Obesite)) +
      geom_violin(alpha = 0.7) +
      geom_boxplot(width = 0.2, alpha = 0.5) +
      labs(title = "Distribution de l'âge par niveau d'obésité (Violin Plot)",
           x = "Niveau d'obésité", y = "Âge") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")
  })
}

