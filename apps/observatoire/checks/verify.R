# Run from the project root: Rscript --vanilla obesity-shiny/checks/verify.R
if (dir.exists("apps/observatoire")) setwd("apps/observatoire") else if (dir.exists("obesity-shiny")) setwd("obesity-shiny")
source("app.R")
pass <- function(n, text) cat(sprintf("PASS %02d — %s\n", n, text))
stopifnot(nrow(donnees) == 1610, ncol(donnees_brutes) == 15, !anyNA(donnees_afdm))
pass(1, "Données et libellés complets")
stopifnot(all(is.finite(resultat_afdm$ind$coord)), all(is.finite(modalites_afdm$Dimension_1)))
stopifnot(identical(colnames(donnees_afdm)[c(3,15)], c("Sexe", "Classe")))
pass(2, "AFDM et coordonnées valides")
carte <- creer_donnees_carte(donnees)
totaux <- carte |> group_by(Classe, Habitude) |> summarise(total=sum(Proportion), .groups="drop")
stopifnot(all(abs(totaux$total-1)<1e-10), all(carte$Proportion >= 0 & carte$Proportion <= 1))
pass(3, "Carte thermique : proportions cohérentes")
shiny::testServer(server, {
  session$setInputs(sexe="Tous", classe="Toutes", age=c(18,54), variable_modalites_public="Activite", modalite_focus_public="__toutes__", afficher_ellipses=TRUE, habitude="Activite")
  stopifnot(nrow(donnees_filtrees())==1610, output$n_obs=="1610")
  pass(4, "Indicateurs du jeu complet")
  session$setInputs(sexe="Femme", age=c(25,35))
  stopifnot(nrow(donnees_filtrees())>0, all(donnees_filtrees()$Sexe=="Femme"), all(donnees_filtrees()$Age>=25 & donnees_filtrees()$Age<=35))
  pass(5, "Filtres combinés")
  session$setInputs(classe="Insuffisance pondérale", age=c(54,54))
  stopifnot(nrow(donnees_filtrees())==0, output$age_moyen=="—", output$part_exces=="—")
  pass(6, "Sélection vide sans indicateur trompeur")
  session$setInputs(sexe="Tous", classe="Toutes", age=c(18,54))
  json <- jsonlite::fromJSON(output$carte_interactive, simplifyVector=FALSE)
  stopifnot(length(json$x$data)==9)
  base_axes <- json$x$layout[c("xaxis","yaxis")]
  pass(7, "Carte interactive rendue avec les quatre classes et les ellipses")
  for (v in unique(modalites_afdm$Variable)) {
    session$setInputs(variable_modalites_public=v, modalite_focus_public="__toutes__")
    z <- jsonlite::fromJSON(output$carte_interactive, simplifyVector=FALSE)
    stopifnot(identical(z$x$layout$xaxis$range, base_axes$xaxis$range), identical(z$x$layout$yaxis$range, base_axes$yaxis$range))
    modalites <- modalites_afdm[modalites_afdm$Variable==v,]
    stopifnot(length(z$x$layout$images)==nrow(modalites))
    for (i in seq_len(nrow(modalites))) {
      image <- z$x$layout$images[[i]]
      stopifnot(startsWith(image$source,"data:image/png;base64,"),
        !grepl("[\r\n]", image$source),
        abs(image$x-modalites$Dimension_1[i])<1e-10, abs(image$y-modalites$Dimension_2[i])<1e-10)
    }
    for (m in as.character(modalites_afdm$Modalite[modalites_afdm$Variable==v])) {
      session$setInputs(modalite_focus_public=m)
      z <- jsonlite::fromJSON(output$carte_interactive, simplifyVector=FALSE)
      stopifnot(length(z$x$data)>=9, identical(modalite_focus_public(),m))
      stopifnot(grepl("LA RÉPONSE EN CHIFFRES", output$interpretation_afdm_public$html))
    }
  }
  pass(8, "Toutes les variables et modalités explorables sur des axes fixes")
  session$setInputs(variable_modalites_public="Activite", modalite_focus_public="Aucune", afficher_ellipses=FALSE)
  z <- jsonlite::fromJSON(output$carte_interactive, simplifyVector=FALSE)
  stopifnot(length(z$x$data)==9)
  session$setInputs(variable_modalites_public="Transport")
  stopifnot(modalite_focus_public()=="")
  pass(9, "Contours désactivables et ancienne réponse ignorée lors du changement de variable")
  for (v in unname(variables_habitudes)) {
    session$setInputs(habitude=v)
    graphique <- output$graphique_habitudes
    stopifnot(nzchar(graphique$src))
  }
  stopifnot(nzchar(output$graphique_afdm_variance$src), nzchar(output$graphique_afdm_contributions$src))
  pass(10, "Graphiques comparatifs et méthode rendus")
})
