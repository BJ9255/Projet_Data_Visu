# Depuis la racine du dépôt : Rscript --vanilla -e 'source("checks/verify-carte-hode.R")'
source("global.R")
stopifnot("Age" %in% vars_actives, is.numeric(data$Age), "Age" %in% rownames(afdm$quanti.var$coord))
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
    reperes <- modalites_afdm[modalites_afdm$Variable==v | modalites_afdm$Variable=="Classe",]
    stopifnot(length(z$x$layout$images)==nrow(reperes))
    etiquettes <- z$x$layout$annotations
    stopifnot(length(etiquettes)==nrow(reperes))
    for (a in etiquettes) stopifnot(any(abs(reperes$Dimension_1-a$x)<1e-8 & abs(reperes$Dimension_2-a$y)<1e-8))
    for (cote in c("left", "right")) {
      ys <- vapply(Filter(function(a) identical(a$xanchor,cote), etiquettes), function(a) a$ay, numeric(1))
      stopifnot(length(unique(ys))==length(ys))
    }
    sources <- vapply(z$x$layout$images, function(x) x$source, character(1))
    stopifnot(sum(startsWith(sources,"data:image/svg+xml;base64,"))==4)
    ellipses <- Filter(function(t) identical(t$fill,"toself"),z$x$data)
    stopifnot(length(ellipses)==4, all(vapply(ellipses,function(t) grepl("0.1",t$fillcolor,fixed=TRUE),logical(1))))
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
  session$setInputs(variable="Classe",focus="",ellipses=TRUE)
  z <- jsonlite::fromJSON(output$carte,simplifyVector=FALSE)
  sources <- vapply(z$x$layout$images, function(x) x$source, character(1))
  stopifnot(length(unique(sources))==4, all(startsWith(sources,"data:image/svg+xml;base64,")))
})
cat("PASS — Carte intégrée : 1 610 personnes, toutes les modalités et icônes, axes fixes, effectifs et ellipses\n")
