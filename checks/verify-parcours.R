# Données → proportions → χ² / Fisher → AFDM → sorties Shiny.
source("global.R")
# Shiny charge aussi automatiquement les scripts du dossier R/.
for (fichier in list.files("R", pattern = "[.]R$", full.names = TRUE)) {
  sys.source(fichier, envir = globalenv())
}
stopifnot(exists("pages", envir = globalenv(), inherits = FALSE))
environnement_ui <- new.env(parent = globalenv())
environnement_server <- new.env(parent = globalenv())
sys.source("ui.R", envir = environnement_ui)
sys.source("server.R", envir = environnement_server)
ui <- environnement_ui$ui
server <- environnement_server$server

stopifnot(nrow(data) == 1610, ncol(data) == 15, !anyNA(data),
  identical(as.integer(effectifs_niveaux), c(73L, 658L, 592L, 287L)),
  abs(part_surpoids_obesite - 879 / 1610) < 1e-12,
  abs(information_plan - sum(afdm$eig[1:2, 2])) < 1e-12,
  length(tests_independance) == 12, all(table_tests$conditions))

# Reproduire chaque χ² et ses attendus indépendamment des sorties UI.
for (v in variables_qualitatives) {
  t <- tests_independance[[v]]
  tab <- table(data[[v]], data$Niveau_Obesite)
  attendu <- outer(rowSums(tab), colSums(tab)) / sum(tab)
  statistique <- sum((tab - attendu)^2 / attendu)
  ddl <- (nrow(tab) - 1) * (ncol(tab) - 1)
  stopifnot(sum(tab) == 1610,
    max(abs(t$attendu - attendu)) < 1e-10,
    abs(t$chi2 - statistique) < 1e-10,
    abs(t$p - pchisq(statistique, ddl, lower.tail = FALSE)) < 1e-12,
    t$ddl == ddl)
}
# Le choix de Fisher porte sur les attendus, pas sur les zéros observés.
petit <- matrix(c(0, 2, 2, 0), nrow = 2)
f <- test_independance(petit)
stopifnot(!f$conditions, f$methode == "Fisher exact",
          abs(f$p - fisher.test(petit)$p.value) < 1e-12)
transport <- tests_independance$Moyen_Transport
stopifnot(transport$minimum_attendu < 5, transport$minimum_attendu >= 1,
          transport$part_attendus_5 == .95, transport$conditions)

html <- as.character(ui)
stopifnot(length(pages) == 5, grepl('id="navigation_page"', html, fixed = TRUE),
          grepl('data-value="synthese"', html, fixed = TRUE),
          grepl(problematique, html, fixed = TRUE),
          !grepl("Spearman|Kendall|multinomial|odds ratio|cotes proportionnelles|HCPC|Ward|Holm|sim_Age", html, ignore.case = TRUE))

shiny::testServer(server, {
  session$setInputs(explorer_var = habitude_principale, test_var = habitude_principale,
    test_attendus = FALSE, `hode-variable` = "Legumes", `hode-focus` = "", `hode-ellipses` = FALSE)
  for (page in names(pages)) session$setInputs(nav = page)
  for (v in explicatives) {
    session$setInputs(explorer_var = v)
    z <- jsonlite::fromJSON(output$explorer_barres, simplifyVector = FALSE)
    stopifnot(length(z$x$data) > 0, nzchar(output$explorer_message$html), nzchar(output$observer_suite$html))
  }
  for (v in variables_qualitatives) {
    session$setInputs(test_var = v, test_attendus = FALSE)
    stopifnot(identical(test_selection(), tests_independance[[v]]),
              nzchar(output$test_resultat$html), nzchar(output$test_conditions$html),
              grepl("Effectifs observés", output$test_tableau$html))
    session$setInputs(test_attendus = TRUE)
    stopifnot(grepl("Effectifs attendus", output$test_tableau$html))
  }
  stopifnot(nzchar(output$tests_resume$html))
  z <- jsonlite::fromJSON(output[["hode-carte"]], simplifyVector = FALSE)
  stopifnot(length(z$x$data) > 0)
})
cat("PASS — 5 étapes, 14 comparaisons descriptives, 12 χ² reproduits, Fisher exact, tableaux observés/attendus, AFDM et sorties Shiny\n")
