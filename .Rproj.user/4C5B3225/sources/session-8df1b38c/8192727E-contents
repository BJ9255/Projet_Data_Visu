# ============================================================
# ui.R : interface (thème sombre « verre », navigation flottante, cartes en double cadre)
# Mise en forme : www/style.css · animations : www/animations.js et www/silhouette.js
# ============================================================

# ------------------------------------------------------------
# Briques de mise en page
# ------------------------------------------------------------
pastille <- function(texte) span(class = "pastille-sur", texte)

entete <- function(etape, titre, question) {
  div(class = "entete reveal", pastille(etape), h1(HTML(titre)), p(class = "question", question))
}

# Carte en double cadre : coque extérieure + noyau intérieur
bloc_carte <- function(titre = NULL, ..., sous_titre = NULL, classe = "") {
  div(class = paste("coque reveal", classe),
    div(class = "noyau",
      if (!is.null(titre)) div(class = "carte-tete", h3(titre), if (!is.null(sous_titre)) p(class = "sous-titre", sous_titre)),
      div(class = "carte-corps", ...)
    )
  )
}
carte <- function(titre = NULL, ..., largeur = 12, sous_titre = NULL, classe = "") {
  column(largeur, bloc_carte(titre, ..., sous_titre = sous_titre, classe = classe))
}
rangee <- function(...) div(class = "row rangee", ...)


# Liste déroulante du simulateur, initialisée au profil le plus courant
choix_sim <- function(v) selectInput(paste0("sim_", v), libelles[[v]], levels(data[[v]]), selected = profil_type[[v]])

pages <- c(contexte = "Accueil", explorer = "Habitudes et obésité", compte = "À caractéristiques égales", profils = "Profils de vie")

ui <- fluidPage(
  title = "Obésité et habitudes de vie",
  tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$meta(name = "description", content = "Analyse statistique de l'Obesity Dataset (Koklu et Sulak, 2024)"),
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=Bangers&family=Nunito:wght@400;600;700;800&display=swap"),
    tags$link(rel = "stylesheet", href = "https://unpkg.com/@phosphor-icons/web@2.1.1/src/bold/style.css"),
    tags$link(rel = "stylesheet", href = "style.css"),
    tags$link(rel = "icon", type = "image/svg+xml",
              href = paste0("data:image/svg+xml,", URLencode(
                "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'><rect x='1.5' y='1.5' width='29' height='29' rx='7' fill='#F7D23E' stroke='#1B1A17' stroke-width='3'/><circle cx='16' cy='12' r='5' fill='#F4C7A1' stroke='#1B1A17' stroke-width='2'/><path d='M8 27c0-6 3-9 8-9s8 3 8 9z' fill='#D9452F' stroke='#1B1A17' stroke-width='2'/></svg>",
                reserved = TRUE))),
    tags$script(src = "mascotte.js"),
    tags$script(src = "animations.js"),
    tags$script(src = "effets.js")
  ),

  # Fond : halos lumineux qui dérivent lentement, et grain très léger
  div(class = "fond", div(class = "halo h1"), div(class = "halo h2"), div(class = "halo h3")),
  div(class = "grain"),

  # Navigation flottante en pilule, avec indicateur qui glisse sous l'onglet actif
  tags$nav(class = "ile-nav",
    span(class = "marque", span(class = "marque-point"), "Obésité & habitudes"),
    div(class = "ile-liens",
      span(class = "indicateur"),
      lapply(seq_along(pages), function(i)
        tags$button(class = paste("lien-nav", if (i == 1) "actif"), `data-page` = names(pages)[i],
                    span(class = "num-nav", sprintf("%02d", i)), pages[[i]]))
    )
  ),

  tabsetPanel(id = "pages", type = "hidden",

    # ============================================================
    # 1. ACCUEIL
    # ============================================================
    tabPanel("contexte", value = "contexte",
      div(class = "hero",
        div(class = "hero-texte",
          div(class = "reveal", pastille("Projet de visualisation de données · M2")),
          h1(class = "hero-titre reveal", HTML("Quelles habitudes de vie accompagnent <em>l'obésité</em>&nbsp;?")),
          p(class = "hero-chapeau reveal", "1 610 adultes vivant en Turquie ont décrit en ligne leur alimentation, leur activité
            et leurs écrans. Koklu et Sulak (2024) s'en servent pour entraîner des modèles d'intelligence artificielle, sans
            jamais dire quelles habitudes comptent. C'est la question de cette application."),
          div(class = "hero-actions reveal",
            tags$button(class = "btn-ile", `data-aller` = "explorer", span("Commencer l'exploration"), span(class = "bulle", ico("arrow-up-right"))),
            a(class = "lien-doux", href = "https://doi.org/10.33484/sinopfbd.1445215", target = "_blank", "Lire l'article source ", ico("arrow-square-out"))
          ),
          div(class = "compteurs reveal",
            div(class = "compteur", span(class = "compteur-valeur", `data-compteur` = 1610, "0"), span("personnes interrogées")),
            div(class = "compteur", span(class = "compteur-valeur", `data-compteur` = 10, "0"), span("habitudes de vie")),
            div(class = "compteur", span(class = "compteur-valeur", `data-compteur` = 4, "0"), span("niveaux d'obésité"))
          )
        ),
        div(class = "hero-visuel reveal",
          silhouette_svg("sil_accueil", 0.3, boucle = TRUE, hauteur = 400),
          div(class = "anneau-defilement", span("Faites défiler"), ico("arrow-down")),
          div(class = "etiquette-niveau", span(class = "point-niveau"), span(id = "niveau_accueil", "Normal"))
        )
      ),

      div(class = "section",
        rangee(
          carte("Le questionnaire", largeur = 7, sous_titre = "14 questions posées à chaque personne. Survolez une question pour voir les réponses possibles",
            div(class = "questionnaire",
              lapply(themes_questionnaire, function(t)
                div(class = "theme",
                  div(class = "theme-tete", span(class = "theme-icone", ico(t$icone)), span(t$titre)),
                  div(class = "puces", lapply(t$vars, function(v)
                    span(class = "puce", title = paste(levels_ou_plage(v), collapse = " · "), libelles[[v]])))
                ))
            )
          ),
          carte("La variable étudiée", largeur = 5, sous_titre = "Niveau d'obésité : nombre de personnes dans chaque niveau",
            plotlyOutput("contexte_niveaux", height = "240px"),
            div(class = "encadre", strong("Deux limites. "), "Ni poids ni IMC dans le fichier : on ne sait pas comment les niveaux
                ont été attribués. Et l'enquête est faite à un seul moment : on observe des associations, pas des causes.")
          )
        ),
        rangee(
          carte(NULL, classe = "carte-pari",
            div(class = "pari-tete", pastille("Avant de commencer"), h2(HTML("Selon vous, quelle habitude est <em>la plus liée</em> au niveau d'obésité ?"))),
            div(class = "paris", radioButtons("pari", NULL, choix(habitudes_vie), selected = character(0), inline = TRUE)),
            uiOutput("pari_suite")
          )
        )
      )
    ),

    # ============================================================
    # 2. HABITUDES ET OBÉSITÉ
    # ============================================================
    tabPanel("explorer", value = "explorer",
      div(class = "section",
        entete("Étape 02", "Habitudes de vie et <em>niveau d'obésité</em>", "Quels profils se dessinent, et où se place le niveau d'obésité ?"),
        uiOutput("pari_resultat"),
        rangee(
          carte("Carte des profils", sous_titre = "Analyse factorielle des données mixtes (AFDM) · deux personnes proches ont des caractéristiques semblables",
            fluidRow(
              column(9, div(class = "carte-afdm-boite", plotlyOutput("afdm_carte", height = "620px"),
                            tags$button(class = "pilule rejouer-marche", ico("person-simple-walk"), " Rejouer la marche"))),
              column(3,
                div(class = "legende-carte",
                  p(class = "legende-titre", "Niveau d'obésité"),
                  lapply(niveaux, function(n) div(class = "legende-ligne",
                    span(span(class = "pastille-couleur", style = paste0("background:", couleurs_niveau[[n]])), n))),
                  p(class = "note", "Losange : point moyen du niveau. Ellipse : zone qui contient la moitié des personnes de ce niveau."),
                  uiOutput("afdm_message")
                )
              )
            ),
            div(class = "variables-afdm",
              div(span(class = "etiquette-afdm", "Variables actives"), span(class = "note", "les 14 variables : elles construisent la carte"),
                  div(class = "puces", lapply(vars_actives, function(v) span(class = "puce puce-active", libelles[[v]])))),
              div(span(class = "etiquette-afdm", "Variable illustrative"), span(class = "note", "projetée sur la carte, sans la construire"),
                  div(class = "puces", span(class = "puce", libelles[["Niveau_Obesite"]])),
                  p(class = "note", "Si les niveaux d'obésité se séparent sur la carte, c'est que les caractéristiques des personnes
                    suffisent à les distinguer."))
            )
          )
        ),
        rangee(
          carte("Lien brut avec le niveau d'obésité", largeur = 5,
                sous_titre = "Corrélation de −1 à +1 · rouge : va avec plus d'obésité · vert : avec moins · cliquez sur une barre",
            selectInput("explorer_var", NULL, choix(c(correlations$var, "Moyen_Transport")),
                        selected = correlations$var[correlations$Groupe == "Habitude de vie"][1]),
            plotlyOutput("classement", height = "400px"),
            uiOutput("classement_transport")
          ),
          carte("Détail de la variable choisie", largeur = 7, sous_titre = "Part de chaque niveau d'obésité dans chaque réponse",
            plotlyOutput("explorer_barres", height = "340px"),
            uiOutput("explorer_message")
          )
        )
      )
    ),

    # ============================================================
    # 3. À CARACTÉRISTIQUES ÉGALES
    # ============================================================
    tabPanel("compte", value = "compte",
      div(class = "section",
        entete("Étape 03", "À caractéristiques <em>égales</em>",
               "Une fois l'âge, le genre et les autres habitudes pris en compte, quelles associations restent ?"),
        rangee(
          carte("Simulateur de profil", largeur = 5, sous_titre = "Changez une réponse, toutes les autres restent fixes",
            div(class = "profils",
              tags$button(class = "pilule action-button", id = "profil_type", "Profil courant"),
              tags$button(class = "pilule action-button", id = "profil_sain", "Profil sain"),
              tags$button(class = "pilule action-button", id = "profil_risque", "Profil à risque")
            ),
            div(class = "grille-reglages",
              sliderInput("sim_Age", "Âge", min = 18, max = 54, value = profil_type$Age, step = 1),
              choix_sim("Genre"),
              lapply(habitudes_sim, choix_sim)
            ),
            div(class = "bas-carte", uiOutput("sim_levier"))
          ),
          carte("Probabilité estimée pour ce profil", largeur = 7, sous_titre = "Régression logistique multinomiale, ajustée sur les 14 variables",
            div(class = "sim-tete",
              div(class = "sim-silhouette", silhouette_svg("sil_sim", 0.4, hauteur = 200, pose = "balance"),
                  HTML('<svg class="balance" viewBox="0 0 170 74" aria-hidden="true">
                    <rect x="6" y="20" width="158" height="48" rx="14" fill="#FFFFFF" stroke="#1B1A17" stroke-width="3"/>
                    <rect x="20" y="62" width="22" height="10" rx="3" fill="#1B1A17"/><rect x="128" y="62" width="22" height="10" rx="3" fill="#1B1A17"/>
                    <path d="M45 46 A40 40 0 0 1 125 46" fill="#F3EBDA" stroke="#1B1A17" stroke-width="2.5"/>
                    <path d="M45 46 A40 40 0 0 1 72 9" fill="none" stroke="#74C488" stroke-width="7"/>
                    <path d="M72 9 A40 40 0 0 1 98 9" fill="none" stroke="#E8933A" stroke-width="7"/>
                    <path d="M98 9 A40 40 0 0 1 125 46" fill="none" stroke="#B43B2E" stroke-width="7"/>
                    <g id="aiguille" style="transform: rotate(-90deg)"><line x1="85" y1="46" x2="85" y2="12" stroke="#1B1A17" stroke-width="4" stroke-linecap="round"/></g>
                    <circle cx="85" cy="46" r="6" fill="#D9452F" stroke="#1B1A17" stroke-width="2.5"/>
                  </svg>')),
              div(class = "sim-chiffre",
                div(class = "grand", span(id = "sim_pct", "0"), span(class = "unite", "%")),
                p(class = "sim-libelle", "de probabilité d'être en surpoids ou obèse"),
                uiOutput("sim_resultat")
              )
            ),
            plotlyOutput("sim_barres", height = "130px"),
            plotlyOutput("sim_effets", height = "290px"),
            p(class = "note", "Pour chaque habitude, le trait va de sa réponse associée à la probabilité la plus faible à celle associée
              à la plus forte, les autres réglages restant fixes ; le point marque le choix actuel."),
            div(class = "encadre", "Probabilité estimée dans cet échantillon pour un profil fictif : ce n'est ni un risque individuel,
                ni un diagnostic, et elle ne dit pas qu'un changement d'habitude changerait le poids.")
          )
        ),
        rangee(
          carte("Associations ajustées : odds ratios", largeur = 7,
                sous_titre = "Modèle ordinal complet · rouge : niveau plus élevé · vert : plus faible · gris : intervalle contenant 1",
            plotlyOutput("odds_ratios", height = "540px"),
            p(class = "note", "Un odds ratio de 2 double la cote d'être dans un niveau d'obésité plus élevé, par rapport à la réponse
              de référence (entre parenthèses), les 13 autres variables étant égales.")
          ),
          carte("Ce que l'ajustement change", largeur = 5,
            uiOutput("ajustement_messages"),
            div(class = "bas-carte", a_retenir("Ce sont des associations observées à un seul moment, pas des causes."))
          )
        ),
        rangee(
          carte("Choix du modèle", sous_titre = "Pourquoi deux modèles, et que valent-ils ?",
            uiOutput("modele_qualite")
          )
        )
      )
    ),

    # ============================================================
    # 4. PROFILS DE VIE
    # ============================================================
    tabPanel("profils", value = "profils",
      div(class = "section",
        entete("Étape 04", "Profils <em>de vie</em>",
               "Peut-on regrouper les personnes en profils types, et ces profils ont-ils des niveaux d'obésité différents ?"),
        rangee(
          carte("Niveau d'obésité dans chaque groupe", largeur = 7, sous_titre = "Groupes numérotés du moins au plus touché par le surpoids et l'obésité",
            plotlyOutput("profils_obesite", height = "380px"),
            uiOutput("profils_message")
          ),
          carte("Comment les groupes sont formés", largeur = 5,
            tags$ol(class = "etapes",
              tags$li(strong("Point de départ : la carte de l'étape 02"), "Les personnes y sont placées selon leurs 14 caractéristiques."),
              tags$li(strong("Regroupement"), "Une classification ascendante hiérarchique (méthode de Ward) réunit les personnes proches
                      sur les 5 premiers axes ; on coupe l'arbre là où ajouter un groupe apporte peu."),
              tags$li(strong("Sans le niveau d'obésité"), "Il n'a pas servi à former les groupes : s'ils diffèrent nettement, c'est que
                      les profils de vie suffisent à les distinguer.")
            )
          )
        ),
        rangee(
          carte("Portrait de chaque groupe", sous_titre = "Part de surpoids ou d'obésité, et ce qui distingue le groupe du reste de l'échantillon",
            uiOutput("profils_portraits")
          )
        )
      )
    )
  ),

  # Silhouette compagne : sur l'accueil, elle grossit à mesure qu'on descend la page
  div(class = "compagnon",
    silhouette_svg("sil_compagnon", 0.05, hauteur = 92),
    div(class = "compagnon-texte", span(class = "compagnon-titre", "En descendant"), span(class = "compagnon-niveau", "Normal"),
        div(class = "compagnon-barre", span()))
  ),

  tags$footer(class = "pied", "Données : Koklu & Sulak (2024), Obesity Dataset · Analyse : AFDM, CAH, régressions ordinale et multinomiale · R / Shiny")
)
