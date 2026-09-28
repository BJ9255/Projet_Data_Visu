# ============================================================
# ui.R : interface utilisateur de l'application Shiny
# ============================================================

ui <- dashboardPage(
  dashboardHeader(title = "Analyse Obésité"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Accueil", tabName = "accueil", icon = icon("home")),
      menuItem("Distributions", tabName = "distrib", icon = icon("chart-bar")),
      menuItem("Facteurs Non Modifiables", tabName = "fixes", icon = icon("user")),
      menuItem("Habitudes de Vie", tabName = "habitudes", icon = icon("utensils")),
      menuItem("Liens entre Variables", tabName = "liaisons", icon = icon("table-cells")),
      menuItem("Synthèse", tabName = "synthese", icon = icon("ranking-star"))
    )
  ),
  dashboardBody(
    tabItems(

      # TAB 1: Accueil
      tabItem(tabName = "accueil",
        fluidRow(
          box(title = "Origine du Jeu de Données", width = 12, status = "primary", solidHeader = TRUE,
            p("-> Ce jeu de données, « Obesity Dataset », provient de l'étude de Koklu et Sulak (2024),
               qui utilise des techniques d'intelligence artificielle pour analyser le niveau d'obésité
               des individus en fonction de leurs habitudes de vie : alimentation, activité physique,
               temps d'écran, moyen de transport."),
            p(em("Koklu, N., & Sulak, S.A. (2024). Using artificial intelligence techniques for the analysis
                  of obesity status according to the individuals' social and physical activities.
                  Sinop Üniversitesi Fen Bilimleri Dergisi, 9(1), 217-239."),
              a("doi.org/10.33484/sinopfbd.1445215",
                href = "https://doi.org/10.33484/sinopfbd.1445215", target = "_blank"))
          )
        ),
        fluidRow(
          valueBox(nrow(data), "nombre d'individus de l'étude", icon = icon("users"), color = "blue", width = 8),
          valueBox(ncol(data), "variables (âge, taille, habitudes de vie, niveau d'obésité)",
                   icon = icon("list"), color = "blue", width = 8)
        ),
        fluidRow(
          box(title = "Problématique", width = 12, status = "warning", solidHeader = TRUE,
            h4(strong("Au-delà de l'âge, du genre et des antécédents familiaux, quelles habitudes de vie
                       sont associées au niveau d'obésité ?")),
            p("La démarche suit les onglets : on décrit d'abord la population (Distributions), puis on
               examine les facteurs que l'on ne peut pas changer (Facteurs non modifiables), ensuite les
               comportements (Habitudes de vie), puis les liens entre toutes les variables (Liens entre
               variables), avant de comparer la force de chaque lien avec le niveau d'obésité (Synthèse).")
          )
        ),
        fluidRow(
          box(title = "Variable Réponse", width = 12, status = "success", solidHeader = TRUE,
            p("Notre variable réponse est le ", strong("niveau d'obésité"), " (Niveau_Obesite), en quatre classes :"),
            tags$ul(
              tags$li("Insuffisance pondérale"),
              tags$li("Normal"),
              tags$li("Surpoids"),
              tags$li("Obésité")
            ),
            p("C'est une variable ", strong("qualitative ordinale"), ".")
          )
        ),
        fluidRow(
          box(title = "Variables Quantitatives (2)", width = 4, solidHeader = TRUE, status = "info",
            tags$ul(lapply(vars_quanti, function(v) tags$li(libelles[[v]])))
          ),
          box(title = "Variables Qualitatives (13)", width = 8, solidHeader = TRUE, status = "info",
            fluidRow(
              column(6, strong("Nominales (sans ordre)"),
                     tags$ul(lapply(vars_nominales, function(v) tags$li(libelles[[v]])))),
              column(6, strong("Ordinales (modalités ordonnées)"),
                     tags$ul(lapply(vars_ordinales, function(v) tags$li(libelles[[v]]))))
            )
          )
        ),
        fluidRow(
          box(title = "Mesure du Lien entre Deux Variables", width = 12, solidHeader = TRUE, status = "info",
            tags$table(class = "table table-bordered",
              tags$thead(tags$tr(tags$th("Couple de variables"), tags$th("Méthode"), tags$th("Force du lien"))),
              tags$tbody(
                tags$tr(tags$td("Quantitative × quantitative"), tags$td("Corrélation de Pearson"),
                        tags$td("r, de -1 à 1")),
                tags$tr(tags$td("Qualitative × qualitative"), tags$td("Test du khi-deux"),
                        tags$td("V de Cramér, de 0 à 1")),
                tags$tr(tags$td("Qualitative × quantitative"), tags$td("ANOVA à un facteur"),
                        tags$td("η² (êta carré) : part de la variance expliquée, de 0 à 1"))
              )
            )
          )
        ),
        fluidRow(
          box(title = "Dictionnaire des Variables", width = 12, solidHeader = TRUE, status = "primary",
            tableOutput("dictionnaire")
          )
        )
      ),

      # TAB 2: Distributions
      tabItem(tabName = "distrib",
        fluidRow(
          box(title = "Paramètres", width = 12, solidHeader = TRUE, status = "info",
            fluidRow(
              column(6, selectInput("dist_var", "Variable à observer :", choix(toutes_vars))),
              column(6, selectInput("dist_split", "Découper par :", decoupages))
            )
          )
        ),
        fluidRow(
          box(title = "Distribution", width = 12, solidHeader = TRUE,
            uiOutput("dist_note"),
            plotOutput("dist_plot", height = "480px")
          )
        ),
        fluidRow(
          box(title = "Tableau Récapitulatif", width = 12, solidHeader = TRUE,
            DTOutput("dist_table")
          )
        ),
        fluidRow(
          box(title = "Consulter les Données", width = 12, solidHeader = TRUE, collapsible = TRUE,
              collapsed = TRUE,
            DTOutput("table_donnees")
          )
        )
      ),

      # TAB 3: Facteurs non modifiables
      tabItem(tabName = "fixes",
        fluidRow(
          box(title = "Âge selon le Niveau d'Obésité", width = 6, solidHeader = TRUE, status = "primary",
            plotOutput("fixe_age", height = "380px"),
            verbatimTextOutput("fixe_age_test")
          ),
          box(title = "Taille selon le Niveau d'Obésité (par genre)", width = 6, solidHeader = TRUE, status = "primary",
            plotOutput("fixe_taille", height = "380px"),
            verbatimTextOutput("fixe_taille_test")
          )
        ),
        fluidRow(
          box(title = "Niveau d'Obésité selon le Genre", width = 6, solidHeader = TRUE, status = "primary",
            plotOutput("fixe_genre", height = "380px"),
            uiOutput("fixe_genre_test")
          ),
          box(title = "Niveau d'Obésité selon les Antécédents Familiaux", width = 6, solidHeader = TRUE,
              status = "primary",
            plotOutput("fixe_antecedents", height = "380px"),
            uiOutput("fixe_antecedents_test")
          )
        ),
        fluidRow(
          box(title = "Lecture", width = 12, solidHeader = TRUE,
            p("Âge et taille sont quantitatives, le niveau d'obésité est qualitatif : on utilise l'ANOVA,
               qui compare les moyennes des quatre niveaux. La force du lien est donnée par η², la part de
               la variance expliquée par le niveau (repères : 0,01 faible, 0,06 modéré, 0,14 fort)."),
            p("Genre et antécédents sont qualitatifs : on utilise le test du khi-deux, et la force du lien
               est donnée par le V de Cramér, de 0 (aucun lien) à 1 (lien parfait).")
          )
        )
      ),

      # TAB 4: Habitudes de vie
      tabItem(tabName = "habitudes",
        fluidRow(
          box(title = "Paramètres", width = 12, solidHeader = TRUE, status = "info",
            selectInput("habitude_var", "Habitude de vie :", choix(habitudes_vie))
          )
        ),
        fluidRow(
          box(title = "Niveau d'Obésité selon l'Habitude", width = 8, solidHeader = TRUE,
            plotOutput("habitude_plot", height = "450px")
          ),
          box(title = "Test du Lien", width = 4, solidHeader = TRUE,
            uiOutput("habitude_test")
          )
        ),
        fluidRow(
          box(title = "Tableau Croisé (effectifs et % par ligne)", width = 12, solidHeader = TRUE,
            DTOutput("habitude_table")
          )
        )
      ),

      # TAB 5: Liens entre variables
      tabItem(tabName = "liaisons",
        fluidRow(
          box(title = "Matrice des Liaisons entre Toutes les Variables", width = 12, solidHeader = TRUE,
              status = "warning",
            plotOutput("liaison_plot", height = "720px"),
            p(em("Chaque case utilise la méthode adaptée au type des deux variables : r = corrélation de
                  Pearson (quanti × quanti), V = V de Cramér issu du khi-deux (quali × quali),
                  η² = êta carré issu de l'ANOVA (quali × quanti). La couleur indique la force du lien ;
                  les cases grises ne sont pas significatives (p ≥ 0,05)."))
          )
        ),
        fluidRow(
          box(title = "Explorer un Couple de Variables", width = 12, solidHeader = TRUE, status = "info",
            fluidRow(
              column(6, selectInput("couple_v1", "Variable 1 :", choix(toutes_vars), selected = "Age")),
              column(6, selectInput("couple_v2", "Variable 2 :", choix(toutes_vars), selected = "Taille_cm"))
            ),
            fluidRow(
              column(8, plotOutput("couple_plot", height = "450px")),
              column(4, uiOutput("couple_test"))
            )
          )
        )
      ),

      # TAB 6: Synthèse
      tabItem(tabName = "synthese",
        fluidRow(
          box(title = "Force du Lien avec le Niveau d'Obésité", width = 12,
              solidHeader = TRUE, status = "warning",
            plotOutput("synthese_plot", height = "520px"),
            p(em("Variables qualitatives : V de Cramér (khi-deux), repères 0,1 faible, 0,2 modéré, 0,3 fort.
                  Variables quantitatives : η² (ANOVA), repères 0,01 faible, 0,06 modéré, 0,14 fort.
                  Les deux indicateurs n'ont pas la même échelle : on compare les variables à l'intérieur
                  de chaque panneau."))
          )
        ),
        fluidRow(
          box(title = "Détail des Tests", width = 12, solidHeader = TRUE,
            DTOutput("synthese_table")
          )
        )
      )
    )
  )
)
