# Reproduction du protocole de validation croisée du modèle multinomial.
# Les prédictions hors pli permettent de lire les performances par catégorie.
fichier_validation <- "resultats/validation-multinomiale.rds"
signature_validation <- c(version = "1", tools::md5sum(c("Obesity_Dataset.xlsx", fichier_precalcul)))
validation_modele <- if (file.exists(fichier_validation)) readRDS(fichier_validation) else NULL
if (is.null(validation_modele) || !identical(validation_modele$signature, signature_validation)) {
  set.seed(2024)
  plis <- sample(rep(1:10, length.out = nrow(data)))
  probabilites_cv <- matrix(NA_real_, nrow(data), length(niveaux), dimnames = list(NULL, niveaux))
  exactitude_plis <- numeric(10)
  for (k in 1:10) {
    apprentissage <- plis != k
    modele <- nnet::multinom(reformulate(explicatives, response = "Niveau_Obesite"),
      data = data[apprentissage, ], trace = FALSE, maxit = 1000)
    stopifnot(modele$convergence == 0, identical(modele$lev, niveaux))
    pr <- predict(modele, newdata = data[!apprentissage, explicatives], type = "probs")
    probabilites_cv[!apprentissage, ] <- pr[, niveaux]
    exactitude_plis[k] <- mean(max.col(pr) == as.integer(data$Niveau_Obesite[!apprentissage]))
  }
  predictions_cv <- factor(niveaux[max.col(probabilites_cv)], levels = niveaux)
  confusion <- table(Observe = data$Niveau_Obesite, Predit = predictions_cv)
  rappel <- diag(confusion) / rowSums(confusion)
  precision <- diag(confusion) / colSums(confusion)
  validation_modele <- list(signature = signature_validation, confusion = confusion,
    rappel = rappel, precision = precision, exactitude = mean(exactitude_plis),
    exactitude_equilibree = mean(rappel), plis = plis)
  saveRDS(validation_modele, fichier_validation)
}
# Une divergence signale un cache ancien : ne pas présenter deux chiffres incompatibles.
stopifnot(abs(validation_modele$exactitude - precalcul$exactitude_cv[["multinomial"]]) < 1e-6)
