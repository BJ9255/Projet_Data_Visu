# Optional integration test with the already-installed local model; fictitious text only.
# From project root: Rscript --vanilla obesity-shiny/checks/verify-local-llm.R
if (dir.exists("apps/observatoire")) setwd("apps/observatoire") else if (dir.exists("obesity-shiny")) setwd("obesity-shiny")
source("app.R")
stopifnot(configuration_assistant$provider=="ollama",isTRUE(configuration_assistant$ready))
await_local <- function(p) {
  done <- FALSE; value <- NULL; failure <- NULL
  promises::then(p,onFulfilled=function(x){value<<-x;done<<-TRUE},onRejected=function(e){failure<<-conditionMessage(e);done<<-TRUE})
  deadline <- Sys.time()+50
  while(!done && Sys.time()<deadline) later::run_now(timeoutSecs=0.1)
  if(!is.null(failure)) stop(failure)
  stopifnot(done)
  value
}
texte <- "Je fais du sport 2 jours par semaine et je me déplace à pied."
x <- await_local(assistant_llm(configuration_assistant,"Extrais seulement les informations explicites dans le JSON du schéma. Les champs absents valent null. Ne prédis aucun risque ni aucune classe de poids.",texte,assistant_schema(donnees_afdm)))
p <- assistant_completer_explicite(assistant_normaliser(jsonlite::fromJSON(x,simplifyVector=FALSE),donnees_afdm),texte,donnees_afdm)
stopifnot(identical(p$Activite,"1-2 jours"),identical(p$Transport,"Marche"),is.null(p$Age))
cat("PASS — Extraction réelle par le LLM local, validée et complétée sur les déclarations explicites\n")
x <- await_local(assistant_llm(configuration_assistant,"Explique en français comment lire une comparaison de groupes d’un fichier. Trois phrases. Aucun chiffre, aucune prescription, aucun risque individuel. Rappelle que les autres caractéristiques peuvent différer et qu’association ne signifie pas causalité.","Comment lire une répartition des classes parmi les personnes partageant des habitudes ?"))
stopifnot(nzchar(x))
cat("PASS — Explication réellement générée, ",if (assistant_explication_valide(x)) "admissible" else "remplacée par le texte calculé", "\n",sep="")
