# Contrôle de bout en bout des données → résultats → sorties Shiny.
# Rscript --vanilla -e 'source("checks/verify-parcours.R")'
source("global.R")
source("ui.R")
source("server.R")

stopifnot(nrow(data) == 1610, ncol(data) == 15, !anyNA(data),
  identical(as.integer(effectifs_niveaux), c(73L, 658L, 592L, 287L)),
  abs(part_surpoids_obesite - 879 / 1610) < 1e-12,
  habitude_principale == "Frequence_Legumes",
  abs(information_plan - sum(afdm$eig[1:2, 2])) < 1e-12,
  length(unique(groupes_profils)) == length(part_par_groupe),
  all(diff(part_par_groupe) >= 0), sum(table(groupes_profils)) == nrow(data))
stopifnot(identical(precalcul$multinomial$lev, niveaux),
  sum(validation_modele$confusion) == nrow(data),
  identical(as.integer(rowSums(validation_modele$confusion)), as.integer(effectifs_niveaux)),
  isTRUE(all.equal(validation_modele$rappel, diag(validation_modele$confusion) / rowSums(validation_modele$confusion))),
  abs(validation_modele$exactitude_equilibree - mean(validation_modele$rappel)) < 1e-12,
  abs(validation_modele$exactitude - precalcul$exactitude_cv[["multinomial"]]) < 1e-6)

# Vérification indépendante des tests qui fondent les messages principaux.
for (v in c("Frequence_Legumes", "Repas_Principaux", "Fumeur")) {
  reduit <- nnet::multinom(reformulate(setdiff(explicatives, v), response = "Niveau_Obesite"),
                          data = data, trace = FALSE, maxit = 1000)
  chi2 <- 2 * as.numeric(logLik(precalcul$multinomial) - logLik(reduit))
  stopifnot(reduit$convergence == 0,
            abs(chi2 - associations_ajustees$chi2[match(v, associations_ajustees$var)]) < 1e-7)
}
stopifnot(nrow(associations_ajustees) == 14,
  isTRUE(all.equal(associations_ajustees$p_holm, p.adjust(associations_ajustees$p, "holm"))),
  p_ajustee("Frequence_Legumes") < .001, p_ajustee("Repas_Principaux") < .001,
  p_ajustee("Fumeur") < .05,
  table_or$p[table_or$var == "Fumeur"] > .05)

html <- as.character(ui)
stopifnot(length(pages) == 5, grepl('id="navigation_page"', html, fixed = TRUE),
          grepl('data-value="synthese"', html, fixed = TRUE),
          grepl(problematique, html, fixed = TRUE),
          !grepl("Profil sain|Profil à risque|L'association du tabac disparaît", html),
          !grepl('src="effets.js"', html, fixed = TRUE))
for (v in explicatives) stopifnot(grepl(paste0('id="sim_', v, '"'), html, fixed = TRUE))

shiny::testServer(server, {
  reglages <- setNames(profil_type, paste0("sim_", names(profil_type)))
  do.call(session$setInputs, c(reglages, list(explorer_var = habitude_principale,
    `hode-variable` = "Legumes", `hode-focus` = "", `hode-ellipses` = FALSE)))
  stopifnot(abs(sum(probas()) - 1) < 1e-10, all(probas() >= 0), all(probas() <= 1))
  for (page in names(pages)) session$setInputs(nav = page)

  # Chaque caractéristique a des proportions et un message, y compris le transport nominal.
  for (v in explicatives) {
    session$setInputs(explorer_var = v)
    z <- jsonlite::fromJSON(output$explorer_barres, simplifyVector = FALSE)
    stopifnot(length(z$x$data) > 0, nzchar(output$explorer_message$html))
    taux <- data.frame(groupe = data_classes[[v]], poids = data$Niveau_Obesite) %>%
      count(groupe, poids) %>% group_by(groupe) %>% summarise(somme = sum(n / sum(n)), .groups = "drop")
    stopifnot(all(abs(taux$somme - 1) < 1e-12))
  }

  # Tous les graphiques et messages du parcours se rendent sans erreur.
  for (nom in c("classement", "sim_barres", "sim_effets", "odds_ratios", "profils_obesite", "hode-carte")) {
    z <- jsonlite::fromJSON(output[[nom]], simplifyVector = FALSE)
    stopifnot(length(z$x$data) > 0)
  }
  for (nom in c("ajustement_messages", "associations_table", "modele_qualite", "profils_message", "profils_portraits", "sim_resultat", "sim_levier")) {
    stopifnot(nzchar(output[[nom]]$html))
  }
  stopifnot(!grepl("disparaît|explication probable", output$ajustement_messages$html),
            !grepl("Catégorie de poids :", output$profils_portraits$html, fixed = TRUE))

  # Les nouveaux réglages de taille et d'antécédents sont réellement utilisés.
  session$setInputs(sim_Taille_cm = min(data$Taille_cm), sim_Antecedents_Familiaux = "Oui")
  stopifnot(profil()$Taille_cm == min(data$Taille_cm), profil()$Antecedents_Familiaux == "Oui")
  session$setInputs(sim_Age = max(data$Age), sim_Frequence_Legumes = "Rarement", sim_Repas_Principaux = "Plus de 3")
  stopifnot(abs(sum(probas()) - 1) < 1e-10,
    isTRUE(all.equal(probas(), probas_profil(profil()))), nzchar(output$sim_resultat$html))
})
cat("PASS — 5 étapes ; chiffres cohérents ; tests ajustés reproduits ; 14 comparaisons ; 14 réglages ; graphiques et messages Shiny\n")
