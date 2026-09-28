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
      menuItem("Niveau d'Obésité", tabName = "obesite", icon = icon("chart-line")),
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
            p("✓ Variable cible : Niveau_Obesite (Insuffisance pondérale, Normal, Surpoids, Obésité), aussi codée en Score_Obesite (1 à 4)"),
            p("✓ Pas de poids dans le jeu de données, donc pas d'IMC calculable"),
            p("✓ Scores ordinaux : Frequence_Legumes (1-3), Repas_Principaux (1-3), Grignotage (1-4), Consommation_Liquide (1-3), Activite_Physique (1-5), Temps_Ecrans (1-3)"),
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

      # TAB 3: Niveau d'Obésité
      tabItem(tabName = "obesite",
        fluidRow(
          box(title = "Répartition des Niveaux", width = 5, solidHeader = TRUE, status = "success",
            verbatimTextOutput("obesity_summary")
          ),
          box(title = "Profil Moyen par Niveau", width = 7, solidHeader = TRUE, status = "success",
            DTOutput("profile_by_obesity")
          )
        ),
        fluidRow(
          box(title = "Effectifs par Niveau", width = 6, solidHeader = TRUE,
            plotOutput("obesity_bar")
          ),
          box(title = "Taille vs Âge", width = 6, solidHeader = TRUE,
            plotlyOutput("age_height_scatter")
          )
        ),
        fluidRow(
          box(title = "Niveau d'Obésité par Genre", width = 12, solidHeader = TRUE,
            plotOutput("obesity_gender", height = "400px")
          )
        ),
        fluidRow(
          box(title = "Niveau d'Obésité selon une Variable", width = 12, solidHeader = TRUE,
            selectInput("obesity_cross_var", "Choisir une variable:",
                        setdiff(names(data), c("Niveau_Obesite", "Score_Obesite", "Age", "Taille_cm")),
                        selected = "Activite_Physique"),
            plotOutput("obesity_factor", height = "400px")
          )
        )
      ),

      # TAB 4: Corrélations
      tabItem(tabName = "corr",
        fluidRow(
          box(title = "Matrice de Corrélation de Spearman", width = 12, solidHeader = TRUE, status = "warning",
            plotOutput("corr_matrix", height = "600px")
          )
        ),
        fluidRow(
          box(title = "Corrélations avec le Score d'Obésité", width = 12, solidHeader = TRUE, status = "warning",
            DTOutput("obesity_correlations")
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
              column(4, selectInput("anova_response", "Variable Réponse:", numeric_vars, selected = "Age")),
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
            selectInput("ttest_var", "Variable à tester:", numeric_vars, selected = "Score_Obesite"),
            selectInput("ttest_group", "Variable de groupage:", binary_vars),
            DTOutput("ttest_results")
          )
        ),
        fluidRow(
          box(title = "Test du Khi-deux (Indépendance avec le Niveau d'Obésité)", width = 12, solidHeader = TRUE,
            selectInput("chi2_var", "Variable catégorique:", setdiff(categorical_vars, "Niveau_Obesite")),
            verbatimTextOutput("chi2_test")
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
          box(title = "Homogénéité des Variances (Levene) : Âge selon le Niveau d'Obésité", width = 12, solidHeader = TRUE,
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
                       selected = c("Score_Obesite", "Age", "Taille_cm", "Activite_Physique")),
            plotOutput("pairplot", height = "700px")
          )
        ),
        fluidRow(
          box(title = "Distribution 3D (Âge vs Taille vs Activité physique)", width = 12, solidHeader = TRUE,
            plotlyOutput("plot_3d")
          )
        ),
        fluidRow(
          box(title = "Violin Plot - Âge par Niveau d'Obésité", width = 12, solidHeader = TRUE,
            plotOutput("violin_obesity", height = "500px")
          )
        )
      )
    )
  )
)
