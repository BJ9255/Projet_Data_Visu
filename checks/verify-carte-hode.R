# Depuis la racine du dépôt : Rscript --vanilla -e 'source("checks/verify-carte-hode.R")'
source("global.R")
stopifnot(nrow(carte_hode_donnees$donnees)==1610,
  identical(carte_hode_donnees$individus_afdm$Dimension_1, unname(afdm$ind$coord[,1])),
  identical(carte_hode_donnees$individus_afdm$Dimension_2, unname(afdm$ind$coord[,2])))
shiny::testServer(carte_hode_server,args=list(id="hode"), {
  session$setInputs(variable="Activite",focus="",ellipses=TRUE)
  z <- jsonlite::fromJSON(output$carte,simplifyVector=FALSE)
  axes <- z$x$layout[c("xaxis","yaxis")]
  for (v in unique(modalites_afdm$Variable)) {
    session$setInputs(variable=v,focus="")
    z <- jsonlite::fromJSON(output$carte,simplifyVector=FALSE)
    stopifnot(identical(z$x$layout$xaxis$range,axes$xaxis$range),identical(z$x$layout$yaxis$range,axes$yaxis$range))
    m <- modalites_afdm[modalites_afdm$Variable==v,]
    stopifnot(length(z$x$layout$images)==nrow(m))
    for (f in m$Modalite) {
      session$setInputs(focus=f)
      z <- jsonlite::fromJSON(output$carte,simplifyVector=FALSE)
      stopifnot(length(z$x$data)==13,nzchar(output$resume$html))
    }
  }
  session$setInputs(variable="Activite",focus="Aucune",ellipses=FALSE)
  stopifnot(grepl("206 personnes",output$resume$html))
  z <- jsonlite::fromJSON(output$carte,simplifyVector=FALSE)
  stopifnot(length(z$x$data)==9)
})
cat("PASS — Carte intégrée : 1 610 personnes, toutes les modalités et icônes, axes fixes, effectifs et ellipses\n")
