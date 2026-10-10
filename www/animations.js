// Navigation, apparition discrète et lecture de présentation.
// Les animations ne modifient jamais les coordonnées ou les valeurs des graphiques.
(function () {
  "use strict";
  var pages = ["contexte", "explorer", "compte", "profils", "synthese"];
  var reduit = window.matchMedia("(prefers-reduced-motion: reduce)");
  var actuelle = "contexte";
  var enregistrerMessages = false;

  function marquer(page) {
    actuelle = page;
    var menu = document.getElementById("navigation_page");
    if (menu) menu.value = page;
    document.querySelectorAll(".etape-nav").forEach(function (b) {
      b.classList.toggle("actif", b.dataset.aller === page);
      b.setAttribute("aria-current", b.dataset.aller === page ? "step" : "false");
    });
  }
  function aller(page) {
    if (pages.indexOf(page) < 0) return;
    if (window.Shiny && Shiny.setInputValue) Shiny.setInputValue("nav", page, { priority: "event" });
    window.scrollTo({ top: 0, behavior: "auto" });
  }
  function compter(el, valeur, couleur) {
    if (el._animation) cancelAnimationFrame(el._animation);
    if (couleur) el.parentElement.style.color = couleur;
    var depart = Number(el.textContent.replace(/\s/g, ""));
    if (!Number.isFinite(depart) || reduit.matches || document.body.classList.contains("presentation")) {
      el.textContent = Math.round(valeur); return;
    }
    var debut;
    function pas(t) {
      if (debut === undefined) debut = t;
      var u = Math.min(1, (t - debut) / 220);
      el.textContent = Math.round(depart + (valeur - depart) * u);
      if (u < 1) el._animation = requestAnimationFrame(pas);
    }
    el._animation = requestAnimationFrame(pas);
  }
  function messages() {
    if (enregistrerMessages || !window.Shiny || !Shiny.addCustomMessageHandler) return;
    enregistrerMessages = true;
    Shiny.addCustomMessageHandler("nombre", function (m) {
      var el = document.getElementById(m.id);
      if (el) compter(el, m.valeur, m.couleur);
    });
  }
  document.addEventListener("DOMContentLoaded", function () {
    var menu = document.getElementById("navigation_page");
    if (menu) menu.addEventListener("change", function () { aller(menu.value); });
    document.addEventListener("click", function (e) {
      var b = e.target.closest("[data-aller]");
      if (b) aller(b.dataset.aller);
    });
    var presentation = document.getElementById("mode_presentation");
    presentation.addEventListener("click", function () {
      var actif = document.body.classList.toggle("presentation");
      presentation.setAttribute("aria-pressed", String(actif));
      presentation.textContent = actif ? "Quitter la présentation" : "Mode présentation";
      window.dispatchEvent(new Event("resize"));
    });
    document.addEventListener("keydown", function (e) {
      if (!e.altKey || (e.key !== "ArrowRight" && e.key !== "ArrowLeft")) return;
      if (e.target.closest("input, select, textarea, [contenteditable]")) return;
      var i = pages.indexOf(actuelle) + (e.key === "ArrowRight" ? 1 : -1);
      if (i >= 0 && i < pages.length) { e.preventDefault(); aller(pages[i]); }
    });
    if ("IntersectionObserver" in window && !reduit.matches) {
      document.body.classList.add("animations-pretes");
      var observateur = new IntersectionObserver(function (entrees) {
        entrees.forEach(function (e) {
          if (e.isIntersecting) { e.target.classList.add("vu"); observateur.unobserve(e.target); }
        });
      }, { threshold: 0.04 });
      document.querySelectorAll(".reveal").forEach(function (el) { observateur.observe(el); });
    } else document.querySelectorAll(".reveal").forEach(function (el) { el.classList.add("vu"); });
    messages();
  });
  $(document).on("shiny:connected", messages);
  $(document).on("shown.bs.tab", function (e) {
    var page = $(e.target).attr("data-value");
    if (pages.indexOf(page) >= 0) marquer(page);
    setTimeout(function () { window.dispatchEvent(new Event("resize")); }, 60);
  });
})();
