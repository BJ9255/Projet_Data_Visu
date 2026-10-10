# Méthodes du cours : tableaux de proportions, χ² / Fisher et AFDM.
problematique <- "Quelles habitudes sont associées aux catégories de poids dans cet échantillon, et comment s’organisent-elles en profils de vie ?"
cible_projet <- "Étudiants et acteurs de prévention souhaitant comprendre les associations entre habitudes de vie et catégories de poids."
but_projet <- "Rendre les associations observées compréhensibles, explorer les profils et expliciter les limites de leur interprétation."
source_article <- "https://doi.org/10.33484/sinopfbd.1445215"
pages <- c(contexte = "01 · Cadrer", explorer = "02 · Observer", compte = "03 · Tester",
           profils = "04 · Explorer l’AFDM", synthese = "05 · Conclure")
effectifs_niveaux <- table(data$Niveau_Obesite)
part_surpoids_obesite <- mean(data$Niveau_Obesite %in% c("Surpoids", "Obésité"))
information_plan <- sum(afdm$eig[1:2, 2])
habitude_principale <- "Frequence_Legumes"
variables_qualitatives <- explicatives[vapply(data[explicatives], is.factor, logical(1))]
fmt_p <- function(x) ifelse(x < 0.001, "< 0,001", fmt(x, 3))

# Conditions de Cochran sur les EFFECTIFS ATTENDUS : aucun < 1, au moins 80 % ≥ 5.
# Une observation par personne ; pas de données appariées dans le fichier.
test_independance <- function(tab) {
  tab <- as.matrix(tab)
  tab <- tab[rowSums(tab) > 0, colSums(tab) > 0, drop = FALSE]
  stopifnot(nrow(tab) >= 2, ncol(tab) >= 2)
  chi <- suppressWarnings(chisq.test(tab, correct = FALSE))
  conditions <- min(chi$expected) >= 1 && mean(chi$expected >= 5) >= .8
  if (conditions) {
    resultat <- chi
    methode <- "χ² d’indépendance"
  } else {
    resultat <- fisher.test(tab, workspace = 2e7)
    methode <- "Fisher exact"
  }
  list(observe = tab, attendu = chi$expected, methode = methode, conditions = conditions,
       p = resultat$p.value, chi2 = unname(chi$statistic), ddl = unname(chi$parameter),
       minimum_attendu = min(chi$expected), part_attendus_5 = mean(chi$expected >= 5))
}
tests_independance <- setNames(lapply(variables_qualitatives, function(v)
  test_independance(table(data[[v]], data$Niveau_Obesite))), variables_qualitatives)
table_tests <- bind_rows(lapply(variables_qualitatives, function(v) {
  t <- tests_independance[[v]]
  data.frame(var = v, Variable = unname(libelles[v]), methode = t$methode, p = t$p,
             chi2 = t$chi2, ddl = t$ddl, conditions = t$conditions,
             minimum_attendu = t$minimum_attendu, part_attendus_5 = t$part_attendus_5)
}))
# P-values brutes : les 12 comparaisons sont exploratoires, sans correction multiple.
# Ne pas présenter leur seuil comme une garantie sur l'ensemble des tests.
resultats_cles_ui <- function() {
  legumes <- part_risque("Frequence_Legumes")
  rare <- legumes[legumes$modalite == "Rarement", ]
  toujours <- legumes[legumes$modalite == "Toujours", ]
  t <- tests_independance[["Frequence_Legumes"]]
  tagList(
    div(class = "resultat-cle", span(class = "resultat-num", "01"),
        span(class = "resultat-kicker", "Observer"), h3("Des répartitions contrastées"),
        p("Pour les légumes, la part observée de surpoids ou d’obésité est de ", strong(pct(rare$risque, 1)),
          " chez « Rarement » et de ", strong(pct(toujours$risque, 1)), " chez « Toujours ».")),
    div(class = "resultat-cle", span(class = "resultat-num", "02"),
        span(class = "resultat-kicker", "Tester"), h3("Une association détectée par le χ²"),
        p("Pour les légumes et la catégorie de poids : ", strong(paste0("p ", fmt_p(t$p))),
          ". Les conditions sur les effectifs attendus sont satisfaites. Ce test ne démontre pas une causalité.")),
    div(class = "resultat-cle", span(class = "resultat-num", "03"),
        span(class = "resultat-kicker", "Explorer"), h3("Une vue d’ensemble avec l’AFDM"),
        p("La carte combine 14 caractéristiques. Ses deux premiers axes représentent ",
          strong(paste0(fmt(information_plan, 1), " % de l’inertie")),
          ". La catégorie de poids est supplémentaire : elle ne construit pas les axes."))
  )
}
