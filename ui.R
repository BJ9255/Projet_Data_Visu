# Une question, cinq étapes : cadrer → observer → tester → explorer l’AFDM → conclure.
pastille <- function(texte) span(class = "pastille-sur", texte)
entete <- function(etape, titre, question) {
  div(class = "entete reveal", pastille(etape), h1(HTML(titre)), p(class = "question", question))
}
bloc_carte <- function(titre = NULL, ..., sous_titre = NULL, classe = "") {
  div(class = paste("coque reveal", classe), div(class = "noyau",
    if (!is.null(titre)) div(class = "carte-tete", h3(titre),
                           if (!is.null(sous_titre)) p(class = "sous-titre", sous_titre)),
    div(class = "carte-corps", ...)))
}
carte <- function(titre = NULL, ..., largeur = 12, sous_titre = NULL, classe = "") {
  column(largeur, bloc_carte(titre, ..., sous_titre = sous_titre, classe = classe))
}
rangee <- function(...) div(class = "row rangee", ...)
suite <- function(page, texte) div(class = "suite-parcours",
  tags$button(class = "btn-ile", `data-aller` = page, span(texte), span(class = "bulle", ico("arrow-right"))))

ui <- fluidPage(
  title = "Habitudes & catégories de poids · Une enquête, cinq étapes",
  tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$meta(name = "description", content = "Comprendre les associations entre habitudes de vie et catégories de poids dans un échantillon de 1 610 adultes."),
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Bangers&family=Nunito:wght@400;600;700;800&display=swap"),
    tags$link(rel = "stylesheet", href = "https://unpkg.com/@phosphor-icons/web@2.1.1/src/bold/style.css"),
    tags$link(rel = "stylesheet", href = "style.css"),
    tags$script(src = "animations.js")
  ),
  tags$nav(class = "ile-nav", `aria-label` = "Parcours de l’enquête",
    span(class = "marque", span(class = "marque-point"), "Habitudes & poids"),
    div(class = "navigation-choix",
        tags$label(`for` = "navigation_page", class = "sr-only", "Choisir une étape"),
        tags$select(id = "navigation_page", class = "navigation-select",
          lapply(seq_along(pages), function(i) tags$option(value = names(pages)[i], pages[[i]])))),
    tags$button(id = "mode_presentation", class = "pilule", type = "button", `aria-pressed` = "false", "Mode présentation")
  ),
  div(class = "progression-parcours", `aria-label` = "Étapes de l’enquête",
    lapply(seq_along(pages), function(i) tags$button(class = paste("etape-nav", if (i == 1) "actif"),
      `data-aller` = names(pages)[i], `aria-current` = if (i == 1) "step" else "false",
      span(sprintf("%02d", i)), sub("^[^·]*· ", "", pages[[i]])))),
  tabsetPanel(id = "pages", type = "hidden",
    tabPanel("Cadrer", value = "contexte",
      div(class = "hero hero-enquete",
        div(class = "hero-texte",
          div(class = "reveal", pastille("Visualisation de données · Master 2")),
          h1(class = "hero-titre reveal", HTML("Des habitudes.<br>Des profils.<br><em>Quels liens ?</em>")),
          p(class = "hero-chapeau reveal", problematique),
          p(class = "hero-perimetre reveal", "Une exploration de 1 610 réponses à une enquête en ligne en Turquie. Les résultats décrivent cet échantillon."),
          div(class = "hero-actions reveal",
            tags$button(class = "btn-ile", `data-aller` = "explorer", span("Explorer les résultats"), span(class = "bulle", ico("arrow-up-right"))),
            a(class = "lien-doux", href = source_article, target = "_blank", rel = "noopener", "Article source", ico("arrow-square-out"))),
          div(class = "repere-turquie reveal",
            tags$img(src = "drapeau-turquie.svg", alt = "", `aria-hidden` = "true"),
            span("Enquête en Turquie")),
          div(class = "compteurs reveal",
            div(class = "compteur", span(class = "compteur-valeur", fmt(nrow(data), 0)), span("personnes · 18 à 54 ans")),
            div(class = "compteur", span(class = "compteur-valeur", "14"), span("caractéristiques étudiées")),
            div(class = "compteur", span(class = "compteur-valeur", "4"), span("catégories de poids")))
        ),
        div(class = "hero-donnees reveal",
          tags$img(class = "turquie-filigrane", src = "turquie.svg", alt = "", `aria-hidden` = "true"),
          span(class = "resultat-kicker", "Le point de départ"),
          div(class = "hero-stat", pct(part_surpoids_obesite, 1)),
          h2("des répondants sont classés en surpoids ou en obésité"),
          div(class = "distribution-hero", `role` = "img", `aria-label` = "Répartition des quatre catégories de poids dans l’échantillon",
            lapply(niveaux, function(n) div(style = paste0("width:", 100 * effectifs_niveaux[[n]] / nrow(data), "%;background:", couleurs_niveau[[n]])))),
          div(class = "repartition-hero", lapply(niveaux, function(n)
            div(span(class = "pastille", style = paste0("background:", couleurs_niveau[[n]])),
                span(n), strong(pct(effectifs_niveaux[[n]] / nrow(data), 1)),
                span(class = "note", paste0("n = ", effectifs_niveaux[[n]]))))),
          p(class = "note", "Une proportion observée dans l’enquête, pas une estimation pour la population turque.")
        )
      ),
      div(class = "section",
        div(class = "intro-resultats reveal", pastille("Trois fils conducteurs"), h2("Ce que l’enquête nous permet d’explorer")),
        div(class = "resultats-grille reveal", resultats_cles_ui()),
        rangee(
          carte("Ce que contient le fichier", largeur = 7, sous_titre = "10 habitudes de vie et 4 caractéristiques individuelles",
            div(class = "questionnaire", lapply(themes_questionnaire, function(t)
              div(class = "theme", div(class = "theme-tete", span(class = "theme-icone", ico(t$icone)), span(t$titre)),
                div(class = "puces", lapply(t$vars, function(v)
                  span(class = "puce", title = paste(levels_ou_plage(v), collapse = " · "), libelles[[v]]))))))),
          carte("Ce que ces données permettent", largeur = 5,
            div(class = "messages",
              div(class = "message", div(strong("Décrire et comparer"), span("Des réponses recueillies à un seul moment ; les liens observés sont des associations."))),
              div(class = "message", div(strong("Explorer, avec un périmètre précis"), span("Une enquête en ligne : la représentativité de l’échantillon n’est pas établie."))),
              div(class = "message", div(strong("Lire les catégories fournies"), span("Le fichier ne contient ni poids ni IMC : nous ne pouvons pas recalculer ni vérifier l’attribution des catégories."))))
          )
        ),
        tags$details(class = "details-methode", tags$summary("Source et préparation des données"),
          p("Koklu et Sulak (2024) présentent une enquête en ligne auprès de 1 610 personnes en Turquie. Nous réutilisons les catégories du fichier, avec des libellés français."),
          p("Âge et taille restent quantitatifs dans l’AFDM. Pour les seules comparaisons en barres, ils sont regroupés en tranches d’âge et quartiles de taille. Aucune valeur manquante dans les 15 colonnes utilisées."),
          a(href = source_article, target = "_blank", rel = "noopener", "Consulter l’article et son tableau de codage")),
        suite("explorer", "Observer les associations")
      )
    ),
    tabPanel("Observer", value = "explorer",
      div(class = "section",
        entete("Étape 02 · Observer", "Une habitude, <em>plusieurs catégories</em>",
               "Comment la répartition des catégories de poids varie-t-elle selon les réponses ?"),
        div(class = "repere-etape", strong("Commencez par les proportions. "), "Puis utilisez la carte pour explorer plusieurs caractéristiques ensemble."),
        rangee(
          carte("Comparer les réponses", largeur = 7, sous_titre = "Chaque barre représente 100 % des personnes ayant donné cette réponse ; les effectifs sont affichés",
            selectInput("explorer_var", "Caractéristique à comparer", choix(explicatives), selected = habitude_principale),
            plotlyOutput("explorer_barres", height = "360px"), uiOutput("explorer_message")),
          carte("Lire une comparaison", largeur = 5,
            div(class = "messages",
              div(class = "message", div(strong("Une barre = une réponse"), span("Chaque barre totalise 100 %. Les effectifs sont différents : regardez toujours le nombre de personnes."))),
              div(class = "message", div(strong("Un écart est une observation"), span("Le graphique montre comment les catégories se répartissent. Il ne démontre pas qu’une habitude cause un changement de poids."))),
              div(class = "message", div(strong("Le test vient ensuite"), span("Le χ² examine l’indépendance entre deux variables qualitatives à partir des effectifs, sur l’ensemble du tableau.")))),
            uiOutput("observer_suite"))
        ),
        suite("compte", "Tester l’indépendance")
      )
    ),
    tabPanel("Tester", value = "compte",
      div(class = "section",
        entete("Étape 03 · Tester", "Une association <em>statistique ?</em>",
               "Les réponses et les catégories de poids sont-elles indépendantes dans le tableau observé ?"),
        div(class = "repere-etape", strong("H₀ : les deux variables sont indépendantes. "),
            "Le test compare les effectifs observés aux effectifs attendus sous cette hypothèse."),
        rangee(
          carte("Choisir une comparaison", largeur = 5,
            selectInput("test_var", "Variable qualitative", choix(variables_qualitatives), selected = habitude_principale),
            uiOutput("test_resultat"), uiOutput("test_conditions")),
          carte("Le tableau de contingence", largeur = 7, sous_titre = "Lignes : réponses · colonnes : catégories de poids",
            checkboxInput("test_attendus", "Afficher les effectifs attendus sous H₀", FALSE),
            uiOutput("test_tableau"),
            p(class = "note", "Effectif attendu = total de la ligne × total de la colonne / effectif total. Les effectifs attendus peuvent être décimaux ; les observations sont des personnes."))
        ),
        rangee(carte("Vue d’ensemble des tests", uiOutput("tests_resume"),
          div(class = "encadre", "Ces 12 comparaisons sont exploratoires. Les p-values sont présentées sans correction pour les comparaisons multiples ; le seuil de 5 % s’applique à chaque test, pas à l’ensemble. Une p-value ne mesure pas la force du lien."))),
        tags$details(class = "details-methode", tags$summary("Pourquoi χ² ou Fisher ?"),
          p("Le χ² d’indépendance convient au croisement de deux variables qualitatives. Nous vérifions les effectifs attendus : aucun inférieur à 1 et au moins 80 % supérieurs ou égaux à 5. Si ces conditions ne sont pas satisfaites, nous utilisons le test exact de Fisher."),
          p("Dans les 12 tableaux de cet échantillon, les conditions retenues pour le χ² sont satisfaites. L’enquête est analysée comme une réponse par personne ; la représentativité de l’échantillon n’est pas établie."),
          p("Le test de Student compare des moyennes d’une variable quantitative entre deux groupes. Il ne répond pas directement à notre question sur la répartition des quatre catégories de poids.")),
        suite("profils", "Explorer les profils avec l’AFDM")
      )
    ),
    tabPanel("Explorer l’AFDM", value = "profils",
      div(class = "section",
        entete("Étape 04 · Explorer", "Les profils dans <em>leur ensemble</em>",
               "Comment les habitudes et les caractéristiques individuelles s’organisent-elles sur une même carte ?"),
        rangee(carte("La carte des profils", sous_titre = "Analyse factorielle des données mixtes (AFDM) · une vue d’ensemble exploratoire",
          div(class = "lecture-carte",
            div(strong("Un point = une personne"), p("Deux points proches ont des caractéristiques proches sur les dimensions affichées.")),
            div(strong("Une icône = une modalité"), p("Un repère de réponse. Sa proximité avec un point ne constitue pas une prédiction de catégorie.")),
            div(strong(paste0(fmt(information_plan, 1), " % de l’information")),
                p("Les deux axes ne résument qu’une partie des données : des profils peuvent se superposer sur ce plan."))),
          carte_hode_ui("hode"),
          tags$details(class = "details-methode", tags$summary("Pourquoi cette carte ? Comment lire les axes ?"),
            p("L’AFDM combine 12 variables qualitatives et 2 quantitatives : l’âge et la taille. Les 14 caractéristiques construisent les axes ; la catégorie de poids est supplémentaire et sert à la lecture."),
            p(nom_axe(1)), p(nom_axe(2)),
            p("Les noms des axes décrivent leurs variables les plus associées. Les pourcentages indiquent l’inertie représentée. Les axes ne constituent pas une échelle de risque."))
        )),
        suite("synthese", "Répondre à la problématique")
      )
    ),
    tabPanel("Conclure", value = "synthese",
      div(class = "section",
        entete("Étape 05 · Conclure", "Ce que nous <em>retenons</em>", problematique),
        div(class = "reponse-problematique reveal", span(class = "resultat-kicker", "Notre réponse"),
          h2("Des associations existent, mais leur lecture dépend du contexte."),
          p("Les répartitions des catégories de poids varient selon les réponses, notamment pour la consommation de légumes. Le χ² détecte une association dans ce tableau. L’AFDM permet d’explorer les caractéristiques conjointement, sur une projection partielle. Ces résultats décrivent l’échantillon et ne permettent pas d’établir des causes.")),
        div(class = "resultats-grille reveal", resultats_cles_ui()),
        rangee(
          carte("Trois réflexes de lecture", largeur = 6,
            tags$ol(class = "etapes",
              tags$li(strong("Regarder les effectifs"), "Comparer des proportions avec leur dénominateur."),
              tags$li(strong("Distinguer observation et test"), "Le graphique décrit un écart ; le χ² teste l’indépendance, sans démontrer une cause."),
              tags$li(strong("Questionner le sens du lien"), "Sans chronologie, on ne peut pas distinguer cause et conséquence."))),
          carte("Ce qui reste à vérifier", largeur = 6,
            tags$ul(class = "limites-liste",
              tags$li("Représentativité de l’enquête en ligne et qualité des réponses déclarées."),
              tags$li("Attribution des catégories de poids, non recalculable sans poids ni IMC."),
              tags$li("Robustesse de la lecture de l’AFDM au choix des axes et généralisation à d’autres données."),
              tags$li("Temporalité des liens, à étudier avec des données longitudinales.")))
        ),
        div(class = "phrase-finale reveal", p("Une visualisation utile rend les liens visibles ", strong("et leurs limites compréhensibles."))),
        div(class = "sources-fin", strong("Source des données : "), a(href = source_article, target = "_blank", rel = "noopener", "Koklu & Sulak (2024)"),
            p(class = "note", "Les analyses et chiffres présentés sont ceux de notre application, distincts des modèles d’intelligence artificielle de l’article.")),
        suite("explorer", "Revenir aux données")
      )
    )
  ),
  tags$footer(class = "pied", "1 610 réponses · Associations observées · Proportions / χ² / AFDM · Projet M2 · R / Shiny")
)
