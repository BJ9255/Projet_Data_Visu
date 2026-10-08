// ============================================================
// effets.js : effets d'animation avancés
//   1. transition de page en rideau circulaire
//   3. silhouette pilotée par le défilement (accueil)
//   5. carte AFDM qui se construit
//   6. barres qui poussent
//   7. curseur magnétique
//   8. cartes inclinées en 3D
//   9. révélation du pari en « loterie », avec confettis
// ============================================================
(function () {
  var reduit = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var tactile = window.matchMedia && window.matchMedia("(pointer: coarse)").matches;
  var Effets = window.Effets = {};

  // ------------------------------------------------------------
  // 1. Rideau : un cercle s'agrandit depuis le point cliqué et couvre l'écran,
  //    la page change dessous, puis le cercle se retire.
  // ------------------------------------------------------------
  var rideau = null, couvert = null;
  function creerRideau() {
    rideau = document.createElement("div");
    rideau.className = "rideau";
    document.body.appendChild(rideau);
  }
  Effets.couvrir = function (x, y) {
    if (reduit) return Promise.resolve();
    if (!rideau) creerRideau();
    x = (x === undefined) ? window.innerWidth / 2 : x;
    y = (y === undefined) ? window.innerHeight / 2 : y;
    rideau.style.setProperty("--x", x + "px");
    rideau.style.setProperty("--y", y + "px");
    rideau.classList.remove("retrait");
    void rideau.offsetWidth;
    rideau.classList.add("ouvert");
    couvert = new Promise(function (ok) { setTimeout(ok, 620); });
    // Sécurité : le rideau est retiré au plus tard 2,5 s après, même si la page n'a pas changé
    clearTimeout(rideau._secours);
    rideau._secours = setTimeout(function () { Effets.decouvrir(); }, 2500);
    return couvert;
  };
  Effets.decouvrir = function () {
    if (!rideau || !rideau.classList.contains("ouvert")) return;
    (couvert || Promise.resolve()).then(function () {
      setTimeout(function () { rideau.classList.add("retrait"); rideau.classList.remove("ouvert"); }, 120);
    });
  };
  $(document).on("shown.bs.tab", function () { Effets.decouvrir(); });

  // ------------------------------------------------------------
  // 3. Silhouette pilotée par le défilement : sur l'accueil, une petite silhouette
  //    compagne grossit à mesure qu'on descend la page.
  // ------------------------------------------------------------
  function silhouetteDefilement() {
    var heros = document.getElementById("sil_accueil");
    var comp = document.getElementById("sil_compagnon"), boite = document.querySelector(".compagnon");
    var noms = ["Insuffisance pondérale", "Normal", "Surpoids", "Obésité"];
    if (!heros || !comp || !window.Silhouette) return;
    var enAttente = false;
    function maj() {
      enAttente = false;
      var surAccueil = document.querySelector('.tab-pane.active[data-value="contexte"]') !== null;
      var y = window.scrollY, max = Math.max(1, document.documentElement.scrollHeight - window.innerHeight);
      var k = 0.05 + 0.95 * Math.min(1, y / max);
      var actif = surAccueil && y > 80;
      Silhouette.pause(heros, actif);
      if (actif) Silhouette.dessiner(heros, k);
      // visible en milieu de page, cachée près du bas pour ne pas couvrir la carte du pari
      boite.classList.toggle("visible", surAccueil && y > window.innerHeight * 0.55 && max - y > 320);
      Silhouette.dessiner(comp, k);
      boite.querySelector(".compagnon-niveau").textContent = noms[Math.min(3, Math.round(k * 3))];
      boite.querySelector(".compagnon-barre span").style.transform = "scaleX(" + k + ")";
    }
    window.addEventListener("scroll", function () { if (!enAttente) { enAttente = true; requestAnimationFrame(maj); } }, { passive: true });
    $(document).on("shown.bs.tab", maj);
    maj();
  }

  // ------------------------------------------------------------
  // 5 et 6. Graphiques plotly : construction animée au premier rendu de chaque graphique
  // ------------------------------------------------------------
  var dejaAnimes = {};
  var GRAPHIQUES_BARRES = ["contexte_niveaux", "classement", "explorer_barres", "profils_obesite"];

  function zeros(n) { var z = []; for (var i = 0; i < n; i++) z.push(0); return z; }

  // Montre (ou cache) des groupes de tracés plotly par une transition CSS d'opacité
  function opacite(elts, valeur, duree, delai) {
    elts.forEach(function (el, k) {
      if (!el) return;
      el.style.transition = duree ? "opacity " + duree + "ms cubic-bezier(.32,.72,0,1) " + ((delai || 0) * k) + "ms" : "none";
      el.style.opacity = valeur;
    });
  }

  // 6. Les barres montent depuis zéro, les étiquettes apparaissent ensuite
  function pousserBarres(gd) {
    var barres = [];
    gd.data.forEach(function (t, i) { if (t.type === "bar") barres.push(i); });
    if (!barres.length) return;
    var textes = Array.prototype.slice.call(gd.querySelectorAll(".scatterlayer .trace"));
    var cibles = barres.map(function (i) {
      var t = gd.data[i], horiz = t.orientation === "h";
      return { i: i, horiz: horiz, valeurs: (horiz ? t.x : t.y).slice() };
    });
    cibles.forEach(function (c) {
      var u = {}; u[c.horiz ? "x" : "y"] = [zeros(c.valeurs.length)];
      Plotly.restyle(gd, u, [c.i]);
    });
    opacite(textes, 0);
    var data = cibles.map(function (c) { var d = {}; d[c.horiz ? "x" : "y"] = c.valeurs; return d; });
    Plotly.animate(gd, { data: data, traces: cibles.map(function (c) { return c.i; }) },
      { transition: { duration: 1100, easing: "elastic-out" }, frame: { duration: 1100, redraw: false } })
      .then(function () { opacite(Array.prototype.slice.call(gd.querySelectorAll(".scatterlayer .trace")), 1, 500, 40); });
  }

  // 5. Carte AFDM : les points s'envolent du centre, puis les ellipses se dessinent,
  //    puis les points moyens tombent et le trajet se trace.
  function construireCarte(gd) {
    var nuage = [], lignes = [], points = [];
    gd.data.forEach(function (t, i) {
      var mode = t.mode || "";
      if (mode === "markers" && t.x && t.x.length > 50) nuage.push(i);
      else if (mode.indexOf("markers") >= 0) points.push(i);
      else lignes.push(i);
    });
    if (!nuage.length) return;
    var dom = function () { return gd.querySelectorAll(".scatterlayer .trace"); };
    var choisir = function (idx) { var d = dom(); return idx.map(function (i) { return d[i]; }); };
    var vrais = nuage.map(function (i) { return { x: gd.data[i].x.slice(), y: gd.data[i].y.slice() }; });
    nuage.forEach(function (i) { Plotly.restyle(gd, { x: [zeros(gd.data[i].x.length)], y: [zeros(gd.data[i].y.length)] }, [i]); });
    opacite(choisir(lignes.concat(points)), 0);
    Plotly.animate(gd, { data: vrais, traces: nuage },
      { transition: { duration: 1400, easing: "cubic-out" }, frame: { duration: 1400, redraw: false } })
      .then(function () {
        // Les ellipses et le trajet se dessinent comme au crayon
        var traces = choisir(lignes);
        opacite(traces, 1, 300, 0);
        traces.forEach(function (tr, k) {
          var chemin = tr && tr.querySelector("path.js-line");
          if (!chemin || !chemin.getTotalLength) return;
          var pointille = chemin.style.strokeDasharray;
          if (pointille && pointille !== "none") return;   // le trajet en pointillé apparaît en fondu, sans tracé
          var L = chemin.getTotalLength();
          chemin.style.strokeDasharray = L; chemin.style.strokeDashoffset = L;
          chemin.getBoundingClientRect();
          chemin.style.transition = "stroke-dashoffset 1.3s cubic-bezier(.32,.72,0,1) " + (k * 90) + "ms";
          chemin.style.strokeDashoffset = 0;
          setTimeout(function () { chemin.style.strokeDasharray = ""; chemin.style.transition = ""; }, 1500 + k * 90);
        });
        // Puis les points moyens apparaissent, l'un après l'autre
        setTimeout(function () { opacite(choisir(points), 1, 600, 120); }, 1000);
      });
  }

  function animerGraphique(id) {
    var gd = document.getElementById(id);
    if (!gd || !gd.data || reduit || dejaAnimes[id]) return;
    dejaAnimes[id] = true;
    if (id === "afdm_carte") construireCarte(gd);
    else if (GRAPHIQUES_BARRES.indexOf(id) >= 0) pousserBarres(gd);
  }
  $(document).on("shiny:value", function (e) {
    if (["afdm_carte"].concat(GRAPHIQUES_BARRES).indexOf(e.name) < 0) return;
    var gd = document.getElementById(e.name);
    // Le graphique n'est animé que lorsqu'il est visible (sa page est affichée)
    var essayer = function () {
      if (gd && gd.offsetParent !== null && gd.data) animerGraphique(e.name);
      else setTimeout(essayer, 250);
    };
    setTimeout(essayer, 120);
  });

  // ------------------------------------------------------------
  // 7. Curseur magnétique : un anneau suit la souris avec inertie,
  //    grossit sur ce qui est cliquable ; les boutons sont légèrement attirés.
  // ------------------------------------------------------------
  function curseur() {
    if (tactile || reduit) return;
    var anneau = document.createElement("div"), point = document.createElement("div");
    anneau.className = "curseur-anneau"; point.className = "curseur-point";
    document.body.appendChild(anneau); document.body.appendChild(point);
    var mx = innerWidth / 2, my = innerHeight / 2, ax = mx, ay = my;
    var CLIQUABLE = "a, button, .puce, .paris .radio-inline span, .selectize-input, .lien-nav, .irs-handle, .pilule";
    var AIMANT = ".btn-ile, .pilule, .lien-nav, .paris .radio-inline span";
    document.addEventListener("pointermove", function (e) {
      mx = e.clientX; my = e.clientY;
      point.style.transform = "translate(" + mx + "px," + my + "px)";
      var cible = e.target.closest && e.target.closest(CLIQUABLE);
      anneau.classList.toggle("survol", !!cible);
      var aimant = e.target.closest && e.target.closest(AIMANT);
      document.querySelectorAll(".aimante").forEach(function (b) { if (b !== aimant) { b.classList.remove("aimante"); b.style.transform = ""; } });
      if (aimant) {
        var r = aimant.getBoundingClientRect();
        var dx = (mx - (r.left + r.width / 2)) * 0.22, dy = (my - (r.top + r.height / 2)) * 0.3;
        aimant.classList.add("aimante");
        aimant.style.transform = "translate(" + dx + "px," + dy + "px)";
      }
    }, { passive: true });
    document.addEventListener("pointerdown", function () { anneau.classList.add("presse"); });
    document.addEventListener("pointerup", function () { anneau.classList.remove("presse"); });
    document.addEventListener("mouseleave", function () { anneau.style.opacity = 0; point.style.opacity = 0; });
    document.addEventListener("mouseenter", function () { anneau.style.opacity = ""; point.style.opacity = ""; });
    (function suivre() {
      ax += (mx - ax) * 0.16; ay += (my - ay) * 0.16;
      anneau.style.transform = "translate(" + ax + "px," + ay + "px)";
      requestAnimationFrame(suivre);
    })();
    document.body.classList.add("avec-curseur");
  }

  // ------------------------------------------------------------
  // 8. Inclinaison 3D des cartes sans graphique (la rotation fausserait le survol des graphiques plotly)
  // ------------------------------------------------------------
  function inclinaison() {
    if (tactile || reduit) return;
    var SELECTEUR = ".message, .portrait, .tuile, .theme-carte, .coque.sans-graphique";
    document.addEventListener("pointermove", function (e) {
      var el = e.target.closest && e.target.closest(SELECTEUR);
      document.querySelectorAll(".incline").forEach(function (x) { if (x !== el) { x.classList.remove("incline"); x.style.transform = ""; } });
      if (!el) return;
      var r = el.getBoundingClientRect(), px = (e.clientX - r.left) / r.width - 0.5, py = (e.clientY - r.top) / r.height - 0.5;
      var force = el.classList.contains("coque") ? 3 : 7;
      el.classList.add("incline");
      el.style.transform = "perspective(900px) rotateX(" + (-py * force) + "deg) rotateY(" + (px * force) + "deg) translateZ(0)";
      el.style.setProperty("--rx", (px + 0.5) * 100 + "%");
      el.style.setProperty("--ry", (py + 0.5) * 100 + "%");
    }, { passive: true });
  }
  // Marque les cartes qui ne contiennent pas de graphique
  function marquerCartes(racine) {
    (racine || document).querySelectorAll(".coque").forEach(function (c) {
      c.classList.toggle("sans-graphique", !c.querySelector(".plotly, .html-widget-output"));
    });
  }

  // ------------------------------------------------------------
  // 9. Pari « loterie » : les réponses défilent, ralentissent et s'arrêtent sur la bonne
  // ------------------------------------------------------------
  function confettis(x, y) {
    var c = document.createElement("canvas"), ctx = c.getContext("2d");
    c.className = "confettis"; c.width = innerWidth; c.height = innerHeight; document.body.appendChild(c);
    var couleurs = ["#6FD39A", "#8AB8FF", "#F3A24B", "#EF5B4C", "#F2F1EE"], ps = [];
    for (var i = 0; i < 160; i++) {
      var a = Math.random() * Math.PI * 2, v = 6 + Math.random() * 9;
      ps.push({ x: x, y: y, vx: Math.cos(a) * v, vy: Math.sin(a) * v - 6, r: 3 + Math.random() * 4,
                c: couleurs[i % couleurs.length], rot: Math.random() * 6, vr: (Math.random() - .5) * .3, vie: 1 });
    }
    (function pas() {
      ctx.clearRect(0, 0, c.width, c.height);
      var vivants = 0;
      ps.forEach(function (p) {
        if (p.vie <= 0) return; vivants++;
        p.vy += 0.32; p.vx *= 0.985; p.x += p.vx; p.y += p.vy; p.rot += p.vr; p.vie -= 0.009;
        ctx.save(); ctx.globalAlpha = Math.max(0, p.vie); ctx.translate(p.x, p.y); ctx.rotate(p.rot);
        ctx.fillStyle = p.c; ctx.fillRect(-p.r, -p.r / 2, p.r * 2, p.r); ctx.restore();
      });
      if (vivants) requestAnimationFrame(pas); else c.remove();
    })();
  }

  function loterie(bouton) {
    var boite = bouton.closest(".carte-corps");
    var pastilles = Array.prototype.slice.call(boite.querySelectorAll(".paris .radio-inline"));
    var bonne = bouton.dataset.bonne, choisi = bouton.dataset.choisi;
    var iBonne = pastilles.findIndex(function (l) { return l.querySelector("input").value === bonne; });
    if (iBonne < 0 || reduit) { allerVers("explorer"); return; }
    boite.classList.add("en-tirage");
    bouton.disabled = true;
    var n = pastilles.length, tours = 2 * n + ((iBonne - 0 + n) % n), i = 0, delai = 55;
    function etape() {
      pastilles.forEach(function (l) { l.classList.remove("tire"); });
      pastilles[i % n].classList.add("tire");
      if (i >= tours) { fin(); return; }
      i++;
      delai = delai * (i > tours - 8 ? 1.32 : 1.03);
      setTimeout(etape, delai);
    }
    function fin() {
      var gagnant = pastilles[iBonne];
      gagnant.classList.add("gagnant");
      var verdict = boite.querySelector(".verdict");
      var juste = choisi === bonne;
      verdict.innerHTML = juste ? "<strong>Bien vu.</strong> C'est l'habitude la plus liée au niveau d'obésité."
        : "<strong>Raté.</strong> L'habitude la plus liée est « " + gagnant.querySelector("span").textContent + " ».";
      verdict.classList.add("visible", juste ? "juste" : "faux");
      if (juste) { var r = gagnant.getBoundingClientRect(); confettis(r.left + r.width / 2, r.top + r.height / 2); }
      setTimeout(function () { allerVers("explorer", bouton); }, juste ? 2400 : 2000);
    }
    etape();
  }

  // ------------------------------------------------------------
  // Navigation : rideau puis changement de page (utilisée aussi par animations.js)
  // ------------------------------------------------------------
  function allerVers(page, source, evt) {
    // Page déjà affichée : pas de rideau (il ne serait jamais retiré), simple retour en haut
    var actuelle = document.querySelector(".tab-pane.active");
    if (actuelle && actuelle.dataset.value === page) { window.scrollTo({ top: 0, behavior: "smooth" }); return; }
    var x, y;
    if (evt) { x = evt.clientX; y = evt.clientY; }
    else if (source) { var r = source.getBoundingClientRect(); x = r.left + r.width / 2; y = r.top + r.height / 2; }
    Effets.couvrir(x, y).then(function () {
      window.scrollTo(0, 0);
      if (window.Shiny && Shiny.setInputValue) Shiny.setInputValue("nav", page, { priority: "event" });
    });
  }
  Effets.aller = allerVers;

  document.addEventListener("click", function (e) {
    var b = e.target.closest && e.target.closest("#voir_reponse");
    if (b) { e.preventDefault(); loterie(b); }
  });

  document.addEventListener("DOMContentLoaded", function () {
    curseur();
    inclinaison();
    marquerCartes();
    silhouetteDefilement();
  });
  $(document).on("shown.bs.tab", function () { marquerCartes(); });
})();
