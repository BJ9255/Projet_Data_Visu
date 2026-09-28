# ============================================================
# run.R : point d'entree unique pour lancer l'application
# Fonctionne que ce fichier soit "source" dans RStudio (Ctrl+Shift+Enter)
# ou execute en ligne de commande : Rscript run.R
# ============================================================

app_dir <- tryCatch({
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    dirname(rstudioapi::getSourceEditorContext()$path)
  } else {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- sub("--file=", "", args[grepl("--file=", args)])
    if (length(file_arg) == 1 && nzchar(file_arg)) dirname(normalizePath(file_arg)) else getwd()
  }
}, error = function(e) getwd())

if (!requireNamespace("shiny", quietly = TRUE)) install.packages("shiny")
shiny::runApp(app_dir, launch.browser = TRUE)

