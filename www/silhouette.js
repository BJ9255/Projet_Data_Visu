// ============================================================
// silhouette.js : silhouette dont la corpulence varie de 0 (mince) à 1 (forte)
// Le tracé est recalculé à chaque image à partir d'un seul paramètre, ce qui donne
// une transformation fluide sans bibliothèque externe.
// ============================================================

(function () {
  // Couleurs des niveaux d'obésité (mêmes valeurs que dans global.R)
  var COULEURS = [[91, 155, 224], [111, 211, 154], [243, 162, 75], [239, 91, 76]];

  function melange(a, b, t) { return a + (b - a) * t; }

  // Couleur continue le long de l'échelle insuffisance → normal → surpoids → obésité
  function couleur(k) {
    var x = Math.max(0, Math.min(1, k)) * 3, i = Math.min(2, Math.floor(x)), t = x - i;
    var c = COULEURS[i].map(function (v, j) { return Math.round(melange(v, COULEURS[i + 1][j], t)); });
    return "rgb(" + c.join(",") + ")";
  }

  // Tracé du corps (vue de face, centré en x = 100) pour une corpulence k
  function traces(k) {
    var epaule = 30 + 10 * k, taille = 19 + 34 * k, hanche = 25 + 26 * k;
    var bras = 7 + 6 * k, cuisse = 11 + 11 * k, cheville = 7 + 3 * k, cou = 7 + 3 * k;
    var tronc = [
      "M", 100 - cou, 66, "C", 100 - cou, 74, 100 - epaule + 6, 74, 100 - epaule, 82,
      "C", 100 - epaule - 3, 108, 100 - taille - 2, 122, 100 - taille, 140,
      "C", 100 - taille + 1, 158, 100 - hanche - 2, 166, 100 - hanche, 178,
      "L", 100 + hanche, 178,
      "C", 100 + hanche + 2, 166, 100 + taille - 1, 158, 100 + taille, 140,
      "C", 100 + taille + 2, 122, 100 + epaule + 3, 108, 100 + epaule, 82,
      "C", 100 + epaule - 6, 74, 100 + cou, 74, 100 + cou, 66, "Z"
    ].join(" ");
    function brasPath(s) {   // s = -1 à gauche, +1 à droite
      var x0 = 100 + s * (epaule - 2), x1 = 100 + s * (epaule + 8 + 8 * k);
      return ["M", x0, 84, "Q", x0 + s * (bras + 6), 88, x1, 150,
              "Q", x1 - s * (bras * 0.6), 158, x1 - s * bras, 150,
              "Q", x0 - s * 2, 112, x0 - s * 6, 96, "Z"].join(" ");
    }
    function jambe(s) {
      var xh = 100 + s * (hanche - cuisse), xc = 100 + s * (8 + 8 * k);
      return ["M", 100 + s * 2, 176, "L", 100 + s * hanche, 176,
              "Q", xh + s * cuisse * 0.9, 236, xc + s * cheville, 290,
              "L", xc - s * cheville * 0.4, 290,
              "Q", 100 + s * 6, 236, 100 + s * 2, 176, "Z"].join(" ");
    }
    return { tronc: tronc, brasG: brasPath(-1), brasD: brasPath(1), jambeG: jambe(-1), jambeD: jambe(1),
             tete: 17 + 3 * k };
  }

  function dessiner(svg, k) {
    var t = traces(k), c = couleur(k);
    svg.querySelector(".s-tronc").setAttribute("d", t.tronc);
    svg.querySelector(".s-bras-g").setAttribute("d", t.brasG);
    svg.querySelector(".s-bras-d").setAttribute("d", t.brasD);
    svg.querySelector(".s-jambe-g").setAttribute("d", t.jambeG);
    svg.querySelector(".s-jambe-d").setAttribute("d", t.jambeD);
    svg.querySelector(".s-tete").setAttribute("r", t.tete);
    svg.querySelectorAll(".s-corps").forEach(function (e) { e.setAttribute("fill", c); });
    svg.dataset.k = k;
  }

  // Interpolation douce (easeInOutCubic) de la corpulence actuelle vers la cible
  function animer(svg, cible, duree) {
    var depart = parseFloat(svg.dataset.k || "0.3"), t0 = null;
    if (svg._anim) cancelAnimationFrame(svg._anim);
    function pas(t) {
      if (t0 === null) t0 = t;
      var u = Math.min(1, (t - t0) / duree);
      var e = u < 0.5 ? 4 * u * u * u : 1 - Math.pow(-2 * u + 2, 3) / 2;
      dessiner(svg, melange(depart, cible, e));
      if (u < 1) svg._anim = requestAnimationFrame(pas);
    }
    svg._anim = requestAnimationFrame(pas);
  }

  // Accueil : la silhouette oscille entre mince et forte
  // La boucle peut être mise en pause (quand le défilement pilote la silhouette)
  function boucle(svg) {
    var reduit = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduit) { dessiner(svg, 0.55); return; }
    var cibles = [0.05, 0.4, 0.75, 1, 0.4], i = 0;
    function suivant() {
      if (!svg._pause) { animer(svg, cibles[i], 1800); i = (i + 1) % cibles.length; }
      setTimeout(suivant, 2600);
    }
    suivant();
  }
  // Accès depuis animations.js
  window.Silhouette = {
    dessiner: dessiner, animer: animer,
    pause: function (svg, oui) { svg._pause = oui; if (oui && svg._anim) cancelAnimationFrame(svg._anim); }
  };

  function initialiser() {
    document.querySelectorAll("svg.silhouette").forEach(function (svg) {
      dessiner(svg, parseFloat(svg.dataset.k || "0.3"));
      if (svg.classList.contains("en-boucle")) boucle(svg);
    });
  }
  document.addEventListener("DOMContentLoaded", initialiser);

  // Simulateur : le serveur envoie la corpulence correspondant au profil
  if (window.Shiny) {
    Shiny.addCustomMessageHandler("corpulence", function (msg) {
      var svg = document.getElementById(msg.id);
      if (svg) animer(svg, msg.k, 900);
    });
  } else {
    document.addEventListener("shiny:connected", function () {
      Shiny.addCustomMessageHandler("corpulence", function (msg) {
        var svg = document.getElementById(msg.id);
        if (svg) animer(svg, msg.k, 900);
      });
    });
  }
})();
