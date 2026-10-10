# Résultats partagés par le cadrage, les graphiques et la conclusion.
# Les nombres du récit sont calculés sur les mêmes données que les figures.
problematique <- "Quelles habitudes sont associées aux catégories de poids dans cet échantillon, et comment s’organisent-elles en profils de vie ?"
cible_projet <- "Étudiants et acteurs de prévention souhaitant comprendre les associations entre habitudes de vie et catégories de poids."
but_projet <- "Rendre les associations observées compréhensibles, explorer les profils et expliciter les limites de leur interprétation."
source_article <- "https://doi.org/10.33484/sinopfbd.1445215"
pages <- c(contexte = "01 · Cadrer", explorer = "02 · Observer", compte = "03 · Ajuster",
           profils = "04 · Regrouper", synthese = "05 · Conclure")

effectifs_niveaux <- table(data$Niveau_Obesite)
part_surpoids_obesite <- mean(data$Niveau_Obesite %in% c("Surpoids", "Obésité"))
habitudes_classees <- correlations[correlations$var %in% habitudes_vie, ]
habitude_principale <- habitudes_classees$var[1]
part_obesite_tabac <- tapply(data$Niveau_Obesite == "Obésité", data$Fumeur, mean)
information_plan <- sum(afdm$eig[1:2, 2])
information_classification <- sum(afdm$eig[1:5, 2])

# Les groupes sont construits SANS la catégorie de poids, puis ordonnés pour la lecture.
part_classe_origine <- tapply(data$Niveau_Obesite %in% c("Surpoids", "Obésité"), cah$data.clust$clust, mean)
rang_groupes <- rank(part_classe_origine, ties.method = "first")
groupes_profils <- factor(paste("Groupe", rang_groupes[as.character(cah$data.clust$clust)]),
                         levels = paste("Groupe", seq_along(rang_groupes)))
part_par_groupe <- tapply(data$Niveau_Obesite %in% c("Surpoids", "Obésité"), groupes_profils, mean)
origine_groupes <- setNames(as.integer(names(rang_groupes)), as.character(rang_groupes))

# Tests globaux ajustés dans le multinomial, qui n'impose PAS les cotes proportionnelles.
# Pour chaque variable : comparaison du modèle complet avec celui qui l'omet.
# Le cache est invalidé si les données, le modèle complet ou la version du calcul changent.
signature_associations <- c(version = "2", libelles = paste(libelles, collapse = "|"),
                           tools::md5sum(c("Obesity_Dataset.xlsx", fichier_precalcul)))
fichier_associations <- "resultats/associations-multinomiales.rds"
cache_associations <- if (file.exists(fichier_associations)) readRDS(fichier_associations) else NULL
if (is.null(cache_associations) || !identical(cache_associations$signature, signature_associations)) {
  stopifnot(precalcul$multinomial$convergence == 0)
  complet_ll <- logLik(precalcul$multinomial)
  tests <- bind_rows(lapply(explicatives, function(v) {
    formule <- reformulate(setdiff(explicatives, v), response = "Niveau_Obesite")
    reduit <- nnet::multinom(formule, data = data, trace = FALSE, maxit = 1000)
    stopifnot(reduit$convergence == 0)
    reduit_ll <- logLik(reduit)
    statistique <- 2 * as.numeric(complet_ll - reduit_ll)
    stopifnot(statistique > -0.01)
    ddl <- attr(complet_ll, "df") - attr(reduit_ll, "df")
    data.frame(var = v, Variable = unname(libelles[v]), chi2 = max(0, statistique), ddl = ddl,
               p = pchisq(max(0, statistique), df = ddl, lower.tail = FALSE))
  })) %>% mutate(p_holm = p.adjust(p, method = "holm")) %>% arrange(p_holm, desc(chi2))
  cache_associations <- list(signature = signature_associations, tests = tests)
  dir.create("resultats", showWarnings = FALSE)
  saveRDS(cache_associations, fichier_associations)
}
associations_ajustees <- cache_associations$tests
p_ajustee <- function(v) associations_ajustees$p_holm[match(v, associations_ajustees$var)]
fmt_p <- function(x) ifelse(x < 0.001, "< 0,001", fmt(x, 3))

# Synthèse réutilisable, toujours alimentée par les résultats courants.
resultats_cles_ui <- function() {
  tagList(
    div(class = "resultat-cle", span(class = "resultat-num", "01"),
        span(class = "resultat-kicker", "Observer"),
        h3(paste0(libelles[[habitude_principale]], " : une association marquée")),
        p("Parmi les 9 habitudes ordonnées ou binaires, c’est la plus forte corrélation de Spearman en valeur absolue : ",
          strong(fmt(habitudes_classees$rho[1])), ". Le transport, sans ordre naturel, est étudié séparément.")),
    div(class = "resultat-cle", span(class = "resultat-num", "02"),
        span(class = "resultat-kicker", "Ajuster"), h3("Des associations alimentaires persistent"),
        p("Les légumes et le nombre de repas restent associés aux catégories de poids dans le modèle multinomial ajusté : ",
          strong("p corrigées < 0,001"),
          ". Ces tests globaux ne mesurent pas un effet causal.")),
    div(class = "resultat-cle", span(class = "resultat-num", "03"),
        span(class = "resultat-kicker", "Regrouper"), h3("Des profils contrastés"),
        p("Dans les ", length(part_par_groupe), " groupes exploratoires, la part observée de surpoids ou d’obésité va de ",
          strong(pct(min(part_par_groupe), 1)), " à ", strong(pct(max(part_par_groupe), 1)),
          ". La catégorie de poids n’a pas servi à construire ces groupes."))
  )
}
