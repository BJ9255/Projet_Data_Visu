# Une question, cinq étapes : cadrer → observer → ajuster → regrouper → conclure.
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
choix_sim <- function(v) selectInput(paste0("sim_", v), libelles[[v]], levels(data[[v]]), selected = profil_type[[v]])
suite <- function(page, texte) div(class = "suite-parcours",
  tags$button(class = "btn-ile", `data-aller` = page, span(texte), span(class = "bulle", ico("arrow-right"))))
pages <- c(contexte = "01 · Cadrer", explorer = "02 · Observer", compte = "03 · Ajuster",
           profils = "04 · Regrouper", synthese = "05 · Conclure")

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
          div(class = "compteurs reveal",
            div(class = "compteur", span(class = "compteur-valeur", fmt(nrow(data), 0)), span("personnes · 18 à 54 ans")),
            div(class = "compteur", span(class = "compteur-valeur", "14"), span("caractéristiques étudiées")),
            div(class = "compteur", span(class = "compteur-valeur", "4"), span("catégories de poids")))
        ),
        div(class = "hero-donnees reveal",
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
        div(class = "cadrage-projet reveal",
          div(span(class = "resultat-kicker", "Pour qui ?"), h2("Comprendre pour mieux questionner"), p(cible_projet)),
          div(span(class = "resultat-kicker", "Dans quel but ?"), h2("Lire les liens avec recul"), p(but_projet))),
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
          p("Âge et taille restent quantitatifs dans l’AFDM et les modèles. Pour les seules comparaisons en barres, ils sont regroupés en tranches d’âge et quartiles de taille. Aucune valeur manquante dans les 15 colonnes utilisées."),
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
          carte("Situer l’association brute", largeur = 5, sous_titre = "Corrélation de Spearman · les caractéristiques binaires sont orientées comme indiqué au survol",
            plotlyOutput("classement", height = "440px"), uiOutput("classement_transport"),
            p(class = "note", "La longueur indique |ρ| ; le signe donne le sens. Une corrélation brute ne tient pas compte des autres caractéristiques. Cliquez sur une barre pour la détailler."))
        ),
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
        suite("compte", "Prendre les autres caractéristiques en compte")
      )
    ),
    tabPanel("Ajuster", value = "compte",
      div(class = "section",
        entete("Étape 03 · Ajuster", "Le lien brut <em>ne suffit pas</em>",
               "Quelles associations restent détectables quand les 13 autres caractéristiques sont prises en compte ?"),
        rangee(
          carte("Ce que l’ajustement apporte", largeur = 7, uiOutput("ajustement_messages")),
          carte("Associations ajustées", largeur = 5, sous_titre = "Tests globaux dans le modèle multinomial complet",
            uiOutput("associations_table"),
            p(class = "note", "Chaque test compare le modèle complet au modèle sans la variable étudiée. Les p-values sont corrigées par Holm sur 14 tests. Ce tableau indique une évidence statistique, pas une taille d’effet ni un classement des causes."))
        ),
        div(class = "intro-resultats reveal", pastille("Expérience interactive"), h2("Explorer un profil fictif"),
            p("Le modèle estime les catégories associées à une combinaison de réponses. Changer une réponse ici modifie un calcul, sans démontrer l’effet réel d’un changement d’habitude.")),
        rangee(
          carte("Construire une comparaison", largeur = 5, sous_titre = "Les 14 caractéristiques sont accessibles ; les valeurs initiales forment un profil de référence fictif",
            div(class = "profils",
              tags$button(class = "pilule action-button", id = "profil_type", "Réinitialiser"),
              tags$button(class = "pilule action-button", id = "profil_sain", "Légumes : toujours"),
              tags$button(class = "pilule action-button", id = "profil_risque", "Repas : plus de 3")),
            div(class = "grille-reglages",
              sliderInput("sim_Age", "Âge", min = min(data$Age), max = max(data$Age), value = profil_type$Age, step = 1),
              sliderInput("sim_Taille_cm", "Taille (cm)", min = min(data$Taille_cm), max = max(data$Taille_cm), value = profil_type$Taille_cm, step = 1),
              choix_sim("Genre"), choix_sim("Antecedents_Familiaux"), lapply(habitudes_sim, choix_sim)),
            div(class = "bas-carte", uiOutput("sim_levier"))),
          carte("Répartition estimée par le modèle", largeur = 7, sous_titre = "Régression logistique multinomiale · proportions estimées pour le profil fictif",
            div(class = "sim-tete", div(class = "sim-chiffre",
              div(class = "grand", span(id = "sim_pct", "—"), span(class = "unite", "%")),
              p(class = "sim-libelle", "estimés en surpoids ou en obésité pour ce profil"), uiOutput("sim_resultat"))),
            plotlyOutput("sim_barres", height = "160px"), plotlyOutput("sim_effets", height = "320px"),
            p(class = "note", "Pour chaque habitude, le segment relie la plus petite à la plus grande estimation parmi ses réponses possibles, toutes les autres caractéristiques fixées. Le point représente votre choix."),
            div(class = "encadre", strong("Portée du simulateur. "), "Ce calcul décrit le modèle ajusté sur cet échantillon. Il n’est ni un diagnostic ni une prédiction du risque futur. Certaines combinaisons peuvent être peu représentées ; la calibration des probabilités n’a pas été évaluée."))
        ),
        rangee(carte("Validation et choix des modèles", uiOutput("modele_qualite"))),
        tags$details(class = "details-methode", tags$summary("Annexe exploratoire : les odds ratios du modèle ordinal"),
          div(class = "encadre", paste0("Attention : l’hypothèse des cotes proportionnelles est rejetée pour ", precalcul$cotes_rejetees,
            " variables sur ", precalcul$cotes_testees, " testées. Les odds ratios et leurs intervalles sont conditionnels à ce modèle inadéquat ; ils ne fondent pas les conclusions principales.")),
          plotlyOutput("odds_ratios", height = "620px"),
          p(class = "note", "OR > 1 : cote plus élevée dans ce modèle ; OR < 1 : cote plus faible, par rapport à la modalité de référence. La cote n’est pas une probabilité. L’âge et la taille sont exprimés par 10 ans et 10 cm.")),
        suite("profils", "Regrouper les profils de vie")
      )
    ),
    tabPanel("Regrouper", value = "profils",
      div(class = "section",
        entete("Étape 04 · Regrouper", "Des profils de vie <em>contrastés</em>",
               "Des groupes construits à partir des caractéristiques présentent-ils des répartitions de poids différentes ?"),
        rangee(
          carte("Comparer les groupes", largeur = 7, sous_titre = "Groupes ordonnés après construction par part croissante de surpoids ou d’obésité · effectifs affichés",
            plotlyOutput("profils_obesite", height = "420px"), uiOutput("profils_message")),
          carte("Comment sont-ils construits ?", largeur = 5,
            tags$ol(class = "etapes",
              tags$li(strong("La même AFDM que la carte"), "Les 14 caractéristiques sont actives ; la catégorie de poids est supplémentaire."),
              tags$li(strong("Cinq dimensions pour regrouper"), paste0("Ward, puis consolidation HCPC, sur les 5 premiers axes (", fmt(information_classification, 1), " % de l’inertie). Le nombre de groupes est choisi automatiquement par HCPC.")),
              tags$li(strong("La catégorie de poids intervient ensuite"), "Elle sert à comparer et ordonner les groupes après leur construction.")),
            div(class = "encadre", "Une partition exploratoire : la stabilité des groupes et la sensibilité au nombre d’axes ou de groupes n’ont pas été évaluées. Les écarts sont descriptifs dans cet échantillon."))
        ),
        rangee(carte("Ce qui caractérise chaque groupe", sous_titre = "Trois modalités surreprésentées dans le groupe ; elles ne concernent pas nécessairement tous ses membres",
          uiOutput("profils_portraits"))),
        suite("synthese", "Répondre à la problématique")
      )
    ),
    tabPanel("Conclure", value = "synthese",
      div(class = "section",
        entete("Étape 05 · Conclure", "Ce que nous <em>retenons</em>", problematique),
        div(class = "reponse-problematique reveal", span(class = "resultat-kicker", "Notre réponse"),
          h2("Des associations existent, mais leur lecture dépend du contexte."),
          p("Les habitudes alimentaires présentent des associations brutes marquées avec les catégories de poids, également détectées dans le modèle ajusté. Les caractéristiques dessinent des groupes aux répartitions contrastées. La lecture dépend de la méthode et de ses hypothèses ; ces résultats ne permettent pas d’établir des causes.")),
        div(class = "resultats-grille reveal", resultats_cles_ui()),
        rangee(
          carte("Pour notre public", largeur = 6,
            h3("Trois réflexes de lecture"), tags$ol(class = "etapes",
              tags$li(strong("Regarder les effectifs"), "Comparer des proportions avec leur dénominateur."),
              tags$li(strong("Distinguer association brute et ajustée"), "Une relation peut dépendre d’autres caractéristiques."),
              tags$li(strong("Questionner le sens du lien"), "Sans chronologie, on ne peut pas distinguer cause et conséquence."))),
          carte("Ce qui reste à vérifier", largeur = 6,
            tags$ul(class = "limites-liste",
              tags$li("Représentativité de l’enquête en ligne et qualité des réponses déclarées."),
              tags$li("Attribution des catégories de poids, non recalculable sans poids ni IMC."),
              tags$li("Stabilité des groupes, calibration et validation externe du modèle."),
              tags$li("Temporalité des liens, à étudier avec des données longitudinales.")))
        ),
        div(class = "phrase-finale reveal", p("Une visualisation utile rend les liens visibles ", strong("et leurs limites compréhensibles."))),
        div(class = "sources-fin", strong("Source des données : "), a(href = source_article, target = "_blank", rel = "noopener", "Koklu & Sulak (2024)"),
            p(class = "note", "Les analyses et chiffres présentés sont ceux de notre application, distincts des modèles d’intelligence artificielle de l’article.")),
        suite("explorer", "Revenir aux données")
      )
    )
  ),
  tags$footer(class = "pied", "1 610 réponses · Associations observées · AFDM / HCPC / modèle multinomial · Projet M2 · R / Shiny")
)
