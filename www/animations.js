// ============================================================
// animations.js : navigation flottante, apparitions, compteurs, effets de survol
// Toutes les animations passent par transform et opacity (fluides, sans recalcul de mise en page)
// ============================================================
(function () {
  var reduit = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  // ---------- Apparitions : chaque élément .reveal monte et se net quand il entre dans l'écran ----------
  var observateur = ("IntersectionObserver" in window) ? new IntersectionObserver(function (entrees) {
    entrees.forEach(function (e) {
      if (e.isIntersecting) { e.target.classList.add("vu"); observateur.unobserve(e.target); }
    });
  }, { threshold: 0.08, rootMargin: "0px 0px -40px 0px" }) : null;

  function preparerReveals(racine) {
    var els = (racine || document).querySelectorAll(".reveal");
    els.forEach(function (el, i) {
      el.classList.remove("vu");
      el.style.setProperty("--i", Math.min(i, 8));
      if (reduit || !observateur) { el.classList.add("vu"); return; }
      observateur.observe(el);
    });
  }

  // ---------- Compteurs : défilement du nombre jusqu'à sa valeur ----------
  function format(n) { return Math.round(n).toLocaleString("fr-FR").replace(/ | /g, " "); }
  function compter(el, cible, duree, depart) {
    if (reduit) { el.textContent = format(cible); return; }
    var t0 = null, d = (depart === undefined) ? 0 : depart;
    function pas(t) {
      if (t0 === null) t0 = t;
      var u = Math.min(1, (t - t0) / duree), e = 1 - Math.pow(1 - u, 4);
      el.textContent = format(d + (cible - d) * e);
      if (u < 1) requestAnimationFrame(pas);
    }
    requestAnimationFrame(pas);
  }
  function lancerCompteurs(racine) {
    (racine || document).querySelectorAll("[data-compteur]").forEach(function (el) {
      compter(el, parseFloat(el.dataset.compteur), 1600);
    });
  }

  // ---------- Navigation : onglet actif, indicateur glissant, changement de page ----------
  function placerIndicateur() {
    var actif = document.querySelector(".lien-nav.actif"), ind = document.querySelector(".ile-nav .indicateur");
    if (!actif || !ind) return;
    ind.style.width = actif.offsetWidth + "px";
    ind.style.transform = "translateX(" + actif.offsetLeft + "px)";
  }
  function marquerActif(page) {
    document.querySelectorAll(".lien-nav").forEach(function (b) { b.classList.toggle("actif", b.dataset.page === page); });
    placerIndicateur();
  }
  function aller(page, evt) {
    marquerActif(page);
    if (window.Effets && Effets.aller) { Effets.aller(page, null, evt); return; }   // rideau (effets.js)
    if (window.Shiny && Shiny.setInputValue) Shiny.setInputValue("nav", page, { priority: "event" });
    window.scrollTo(0, 0);
  }

  // ---------- Lueur qui suit le curseur sur les cartes ----------
  function lueur(e) {
    var noyau = e.target.closest && e.target.closest(".noyau");
    if (!noyau) return;
    var r = noyau.getBoundingClientRect();
    noyau.style.setProperty("--mx", (e.clientX - r.left) + "px");
    noyau.style.setProperty("--my", (e.clientY - r.top) + "px");
  }

  // ---------- Graphiques : révélation en balayage à chaque nouveau rendu ----------
  function balayer(id) {
    var el = document.getElementById(id);
    if (!el || reduit) return;
    el.classList.remove("balaye"); void el.offsetWidth; el.classList.add("balaye");
  }

  // ---------- Silhouette d'accueil : nom du niveau qui suit sa corpulence ----------
  function suivreNiveau() {
    var svg = document.getElementById("sil_accueil"), lab = document.getElementById("niveau_accueil");
    if (!svg || !lab) return;
    var noms = ["Insuffisance pondérale", "Normal", "Surpoids", "Obésité"], dernier = "";
    setInterval(function () {
      var k = parseFloat(svg.dataset.k || "0"), n = noms[Math.min(3, Math.round(k * 3))];
      if (n !== dernier) {
        lab.classList.remove("change"); void lab.offsetWidth; lab.classList.add("change");
        lab.textContent = n; dernier = n;
        lab.parentElement.dataset.niveau = noms.indexOf(n);
      }
    }, 120);
  }

  document.addEventListener("DOMContentLoaded", function () {
    preparerReveals(document.querySelector(".tab-pane.active") || document);
    lancerCompteurs();
    suivreNiveau();
    setTimeout(placerIndicateur, 60);
    window.addEventListener("resize", placerIndicateur);
    document.addEventListener("pointermove", lueur, { passive: true });

    document.addEventListener("click", function (e) {
      var b = e.target.closest("[data-page], [data-aller]");
      if (b) aller(b.dataset.page || b.dataset.aller, e);
    });

    // Barre de navigation plus compacte quand on fait défiler la page
    var nav = document.querySelector(".ile-nav");
    var sentinelle = document.createElement("div"); sentinelle.className = "sentinelle"; document.body.prepend(sentinelle);
    if ("IntersectionObserver" in window) {
      new IntersectionObserver(function (e) { nav.classList.toggle("compacte", !e[0].isIntersecting); }).observe(sentinelle);
    }
  });

  // Changement de page (navigation ou bouton « Voir la réponse ») : nouvelles apparitions
  $(document).on("shown.bs.tab", function (e) {
    var page = $(e.target).attr("data-value");
    marquerActif(page);
    var pane = document.querySelector('.tab-pane[data-value="' + page + '"]');
    preparerReveals(pane);
    setTimeout(function () { window.dispatchEvent(new Event("resize")); }, 60);   // les graphiques prennent leur taille
  });

  // Chaque graphique plotly qui reçoit de nouvelles données est révélé par un balayage
  $(document).on("shiny:value", function (e) {
    var el = document.getElementById(e.name);
    if (el && el.classList.contains("plotly")) setTimeout(function () { balayer(e.name); }, 30);
  });

  // Messages du serveur : nombre du simulateur qui défile et change de couleur
  function enregistrer() {
    Shiny.addCustomMessageHandler("nombre", function (m) {
      var el = document.getElementById(m.id);
      if (!el) return;
      var depart = parseFloat(el.textContent.replace(/\s/g, "")) || 0;
      compter(el, m.valeur, 900, depart);
      // aiguille de la balance : de -90° (0 %) à +90° (100 %)
      var aig = document.getElementById("aiguille");
      if (aig) aig.style.transform = "rotate(" + (-90 + 1.8 * m.valeur) + "deg)";
      el.parentElement.style.color = m.couleur;
      el.parentElement.classList.remove("pulse"); void el.parentElement.offsetWidth; el.parentElement.classList.add("pulse");
    });
  }
  if (window.Shiny && Shiny.addCustomMessageHandler) enregistrer();
  else $(document).on("shiny:connected", enregistrer);
})();
