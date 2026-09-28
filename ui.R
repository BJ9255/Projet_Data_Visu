# ============================================================
# ui.R : interface utilisateur de l'application Shiny
# ============================================================

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Analyse Obésité - Shiny"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Accueil", tabName = "accueil", icon = icon("home")),
      menuItem("Statistiques Descriptives", tabName = "desc", icon = icon("bar-chart")),
      menuItem("IMC & Distribution", tabName = "imc", icon = icon("chart-line")),
      menuItem("Corrélations", tabName = "corr", icon = icon("link")),
      menuItem("ACP", tabName = "pca", icon = icon("project-diagram")),
      menuItem("ANOVA", tabName = "anova", icon = icon("flask")),
      menuItem("Tests Statistiques", tabName = "tests", icon = icon("vial")),
      menuItem("Visualisations Avancées", tabName = "viz", icon = icon("palette"))
    )
  ),
  dashboardBody(
    tabItems(
      # TAB 1: Accueil
      tabItem(tabName = "accueil",
        fluidRow(
          box(title = "Aperçu du Jeu de Données", width = 12, status = "primary",
            p("Nombre d'observations:", nrow(data)),
            p("Nombre de variables:", ncol(data)),
            hr(),
            h4("Variables clés:"),
            p("✓ IMC (calculé): Poids_kg / Height²"),
            p("✓ Variables numériques:", paste(numeric_vars, collapse = ", ")),
            p("✓ Variables catégoriques:", paste(categorical_vars, collapse = ", "))
          )
        ),
        fluidRow(
          box(title = "Premiers Enregistrements", width = 12,
            DTOutput("table_apercu")
          )
        )
      ),

      # TAB 2: Statistiques Descriptives
      tabItem(tabName = "desc",
        fluidRow(
          box(title = "Résumé Statistique", width = 12, solidHeader = TRUE, status = "info",
            DTOutput("summary_stats")
          )
        ),
        fluidRow(
          box(title = "Distributions des Variables Numériques", width = 12, solidHeader = TRUE, status = "info",
            plotOutput("dist_plots", height = "600px")
          )
        ),
        fluidRow(
          box(title = "Comptage par Catégorie", width = 12, solidHeader = TRUE, status = "info",
            selectInput("cat_var", "Choisir une variable catégorique:", categorical_vars),
            plotOutput("bar_plots", height = "500px")
          )
        )
      ),

      # TAB 3: IMC & Distribution
      tabItem(tabName = "imc",
        fluidRow(
          box(title = "Statistiques IMC", width = 6, solidHeader = TRUE, status = "success",
            verbatimTextOutput("imc_summary")
          ),
          box(title = "IMC par Catégorie d'Obésité", width = 6, solidHeader = TRUE, status = "success",
            DTOutput("imc_by_obesity")
          )
        ),
        fluidRow(
          box(title = "Distribution de l'IMC", width = 6, solidHeader = TRUE,
            plotOutput("imc_hist")
          ),
          box(title = "IMC vs Poids", width = 6, solidHeader = TRUE,
            plotlyOutput("imc_weight")
          )
        ),
        fluidRow(
          box(title = "IMC par Genre", width = 12, solidHeader = TRUE,
            plotOutput("imc_gender", height = "400px")
          )
        ),
        fluidRow(
          box(title = "IMC vs Obésité", width = 12, solidHeader = TRUE,
            plotOutput("imc_obesity", height = "400px")
          )
        )
      ),

      # TAB 4: Corrélations
      tabItem(tabName = "corr",
        fluidRow(
          box(title = "Matrice de Corrélation de Pearson", width = 12, solidHeader = TRUE, status = "warning",
            plotOutput("corr_matrix", height = "600px")
          )
        ),
        fluidRow(
          box(title = "Corrélations avec l'IMC", width = 12, solidHeader = TRUE, status = "warning",
            DTOutput("imc_correlations")
          )
        ),
        fluidRow(
          box(title = "Scatterplot Matrix (Variables Sélectionnées)", width = 12, solidHeader = TRUE,
            uiOutput("select_vars_corr"),
            plotOutput("scatter_matrix", height = "600px")
          )
        )
      ),

      # TAB 5: ACP
      tabItem(tabName = "pca",
        fluidRow(
          box(title = "ACP - Paramètres", width = 12, solidHeader = TRUE, status = "info",
            selectInput("pca_vars", "Variables pour ACP:", numeric_vars, multiple = TRUE,
                       selected = numeric_vars[1:6]),
            actionButton("run_pca", "Exécuter ACP", class = "btn-primary")
          )
        ),
        fluidRow(
          box(title = "Variance Expliquée", width = 6, solidHeader = TRUE,
            plotOutput("pca_variance")
          ),
          box(title = "Cumul de Variance", width = 6, solidHeader = TRUE,
            DTOutput("pca_variance_table")
          )
        ),
        fluidRow(
          box(title = "Biplot PC1 vs PC2", width = 6, solidHeader = TRUE,
            plotOutput("pca_biplot1", height = "500px")
          ),
          box(title = "Biplot PC1 vs PC3", width = 6, solidHeader = TRUE,
            plotOutput("pca_biplot2", height = "500px")
          )
        ),
        fluidRow(
          box(title = "Cercle de Corrélation", width = 6, solidHeader = TRUE,
            plotOutput("pca_circle")
          ),
          box(title = "Graph des Variables", width = 6, solidHeader = TRUE,
            plotOutput("pca_vars")
          )
        ),
        fluidRow(
          box(title = "Contributions aux Composantes", width = 12, solidHeader = TRUE,
            plotOutput("pca_contrib", height = "500px")
          )
        )
      ),

      # TAB 6: ANOVA
      tabItem(tabName = "anova",
        fluidRow(
          box(title = "ANOVA - Configuration", width = 12, solidHeader = TRUE, status = "danger",
            fluidRow(
              column(4, selectInput("anova_factor", "Variable Catégorique:", categorical_vars)),
              column(4, selectInput("anova_response", "Variable Réponse:", numeric_vars, selected = "IMC")),
              column(4, actionButton("run_anova", "Exécuter ANOVA", class = "btn-danger"))
            )
          )
        ),
        fluidRow(
          box(title = "Tableau ANOVA", width = 12, solidHeader = TRUE,
            verbatimTextOutput("anova_table")
          )
        ),
        fluidRow(
          box(title = "Boxplot par Groupe", width = 12, solidHeader = TRUE,
            plotOutput("anova_boxplot", height = "450px")
          )
        ),
        fluidRow(
          box(title = "Statistiques par Groupe", width = 12, solidHeader = TRUE,
            DTOutput("anova_group_stats")
          )
        ),
        fluidRow(
          box(title = "Résidus ANOVA", width = 12, solidHeader = TRUE,
            plotOutput("anova_diagnostics", height = "600px")
          )
        )
      ),

      # TAB 7: Tests Statistiques
      tabItem(tabName = "tests",
        fluidRow(
          box(title = "Tests T", width = 12, solidHeader = TRUE, status = "info",
            selectInput("ttest_var", "Variable à tester:", numeric_vars, selected = "IMC"),
            selectInput("ttest_group", "Variable de groupage:", categorical_vars[c(1,3,4,5)]),
            DTOutput("ttest_results")
          )
        ),
        fluidRow(
          box(title = "Test de Kruskal-Wallis", width = 12, solidHeader = TRUE,
            verbatimTextOutput("kw_test")
          )
        ),
        fluidRow(
          box(title = "Normalité (Shapiro-Wilk)", width = 12, solidHeader = TRUE,
            DTOutput("normality_test")
          )
        ),
        fluidRow(
          box(title = "Homogénéité des Variances (Levene)", width = 12, solidHeader = TRUE,
            verbatimTextOutput("levene_test")
          )
        )
      ),

      # TAB 8: Visualisations Avancées
      tabItem(tabName = "viz",
        fluidRow(
          box(title = "Heatmap des Corrélations", width = 12, solidHeader = TRUE,
            plotOutput("heatmap_plot", height = "600px")
          )
        ),
        fluidRow(
          box(title = "Pairplot Interactif", width = 12, solidHeader = TRUE,
            selectInput("pair_vars", "Sélectionner variables:", numeric_vars, multiple = TRUE,
                       selected = c("IMC", "Age", "Poids_kg", "Consommation_Eau_Litres")),
            plotOutput("pairplot", height = "700px")
          )
        ),
        fluidRow(
          box(title = "Distribution 3D (IMC vs Age vs Poids_kg)", width = 12, solidHeader = TRUE,
            plotlyOutput("plot_3d")
          )
        ),
        fluidRow(
          box(title = "Violin Plot - IMC par Obésité", width = 12, solidHeader = TRUE,
            plotOutput("violin_obesity", height = "500px")
          )
        )
      )
    )
  )
)
