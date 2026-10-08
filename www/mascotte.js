// ============================================================
// mascotte.js : la mascotte de l'application, dessinée en SVG « ligne claire »
// Un seul paramètre de corpulence k (0 = mince, 1 = forte) et une pose :
//   "repos", "suspendu" (accrochée au plafond), "marche", "balance".
// La mascotte reste bienveillante à toutes les corpulences : toujours souriante.
// ============================================================
(function () {
  var NS = "http://www.w3.org/2000/svg";
  var ENCRE = "#1B1A17", PEAU = "#F4C7A1", JOUE = "#F29A8A", CHEVEUX = "#5B3A29";
  var TSHIRT = "#F7D23E", PANTALON = "#3D6FB6", CHAUSSURE = "#E2553F";

  function el(nom, attrs, parent) {
    var e = document.createElementNS(NS, nom);
    for (var a in attrs) e.setAttribute(a, attrs[a]);
    if (parent) parent.appendChild(e);
    return e;
  }
  function trait(c) { return { fill: c, stroke: ENCRE, "stroke-width": 2.6, "stroke-linejoin": "round", "stroke-linecap": "round" }; }

  // ---------- Construction (une seule fois par SVG) ----------
  function construire(svg) {
    svg.setAttribute("viewBox", "0 0 200 300");
    svg.innerHTML = "";
    var r = {};
    r.ombre = el("ellipse", { cx: 100, cy: 288, rx: 46, ry: 6, fill: "rgba(27,26,23,.15)" }, svg);
    r.corps = el("g", { "class": "m-corps" }, svg);
    // jambes (pantalon + chaussure), pivotent autour de la hanche
    r.jambeG = el("g", {}, r.corps); r.pantG = el("path", trait(PANTALON), r.jambeG); r.chausG = el("path", trait(CHAUSSURE), r.jambeG);
    r.jambeD = el("g", {}, r.corps); r.pantD = el("path", trait(PANTALON), r.jambeD); r.chausD = el("path", trait(CHAUSSURE), r.jambeD);
    // bras arrière, tronc (t-shirt), bras avant
    r.brasG = el("g", {}, r.corps); r.mancheG = el("path", trait(PEAU), r.brasG); r.mainG = el("circle", trait(PEAU), r.brasG);
    r.tronc = el("path", trait(TSHIRT), r.corps);
    r.col = el("path", { fill: "none", stroke: ENCRE, "stroke-width": 2.2, "stroke-linecap": "round" }, r.corps);
    r.motif = el("path", { fill: "none", stroke: "#E0A92A", "stroke-width": 3, "stroke-linecap": "round" }, r.corps);
    r.brasD = el("g", {}, r.corps); r.mancheD = el("path", trait(PEAU), r.brasD); r.mainD = el("circle", trait(PEAU), r.brasD);
    r.mancheCourteG = el("path", trait(TSHIRT), r.brasG);
    r.mancheCourteD = el("path", trait(TSHIRT), r.brasD);
    // tête
    r.tete = el("g", { "class": "m-tete" }, r.corps);
    r.oreilleG = el("ellipse", trait(PEAU), r.tete); r.oreilleD = el("ellipse", trait(PEAU), r.tete);
    r.visage = el("path", trait(PEAU), r.tete);
    r.cheveux = el("path", trait(CHEVEUX), r.tete);
    r.joueG = el("ellipse", { fill: JOUE, opacity: .55 }, r.tete); r.joueD = el("ellipse", { fill: JOUE, opacity: .55 }, r.tete);
    r.yeux = el("g", { "class": "m-yeux" }, r.tete);
    r.oeilG = el("ellipse", { fill: ENCRE }, r.yeux); r.oeilD = el("ellipse", { fill: ENCRE }, r.yeux);
    r.refletG = el("circle", { fill: "#fff", r: 1.4 }, r.yeux); r.refletD = el("circle", { fill: "#fff", r: 1.4 }, r.yeux);
    r.sourcilG = el("path", { fill: "none", stroke: ENCRE, "stroke-width": 2.4, "stroke-linecap": "round" }, r.tete);
    r.sourcilD = el("path", { fill: "none", stroke: ENCRE, "stroke-width": 2.4, "stroke-linecap": "round" }, r.tete);
    r.bouche = el("path", { fill: "#B33A2C", stroke: ENCRE, "stroke-width": 2.2, "stroke-linejoin": "round" }, r.tete);
    r.nez = el("path", { fill: "none", stroke: ENCRE, "stroke-width": 2, "stroke-linecap": "round" }, r.tete);
    svg._m = r;
    return r;
  }

  // ---------- Dessin pour une corpulence k et une pose ----------
  function dessiner(svg, k, pose, t) {
    var r = svg._m || construire(svg);
    k = Math.max(0, Math.min(1, k)); pose = pose || svg.dataset.pose || "repos"; t = t || 0;
    var cx = 100;
    // proportions
    var teteR = 31 + 4 * k, teteY = 60;
    var epaule = 26 + 10 * k, ventre = 22 + 32 * k, hanche = 24 + 22 * k;
    var haut = 98, bas = 186;
    var brasL = 50, brasE = 8 + 6 * k;
    var jambeE = 12 + 10 * k, jambeL = 74;

    // tronc : t-shirt arrondi, le ventre s'élargit avec k
    r.tronc.setAttribute("d", [
      "M", cx - epaule, haut + 4,
      "C", cx - epaule - 4, haut + 24, cx - ventre - 2, haut + 34, cx - ventre, haut + 52,
      "C", cx - ventre + 2, bas - 14, cx - hanche - 2, bas - 4, cx - hanche, bas,
      "L", cx + hanche, bas,
      "C", cx + hanche + 2, bas - 4, cx + ventre - 2, bas - 14, cx + ventre, haut + 52,
      "C", cx + ventre + 2, haut + 34, cx + epaule + 4, haut + 24, cx + epaule, haut + 4,
      "Q", cx, haut - 6, cx - epaule, haut + 4, "Z"].join(" "));
    r.col.setAttribute("d", ["M", cx - 9, haut + 1, "Q", cx, haut + 9, cx + 9, haut + 1].join(" "));
    r.motif.setAttribute("d", ["M", cx - ventre * .5, haut + 50, "Q", cx, haut + 58, cx + ventre * .5, haut + 50].join(" "));

    // jambes
    function jambe(s, p, c) {
      var x0 = cx + s * (hanche * .45), x1 = x0 + s * 2;
      p.setAttribute("d", ["M", x0 - jambeE, bas - 6, "L", x0 + jambeE, bas - 6, "L", x1 + jambeE * .8, bas + jambeL,
                           "L", x1 - jambeE * .8, bas + jambeL, "Z"].join(" "));
      c.setAttribute("d", ["M", x1 - jambeE * .9 - (s < 0 ? 6 : 0), bas + jambeL + 8,
                           "Q", x1 - jambeE, bas + jambeL - 6, x1, bas + jambeL - 4,
                           "Q", x1 + jambeE + 8, bas + jambeL - 2, x1 + jambeE + (s > 0 ? 8 : 2), bas + jambeL + 8, "Z"].join(" "));
      return [x0, bas - 4];
    }
    var hG = jambe(-1, r.pantG, r.chausG), hD = jambe(1, r.pantD, r.chausD);

    // bras : tracés vers le bas, puis tournés autour de l'épaule selon la pose
    function bras(s, manche, main, courte) {
      var ex = cx + s * (epaule - 2), ey = haut + 10;
      manche.setAttribute("d", ["M", ex - brasE, ey, "L", ex + brasE, ey, "L", ex + s * 4 + brasE * .8, ey + brasL,
                                "L", ex + s * 4 - brasE * .8, ey + brasL, "Z"].join(" "));
      main.setAttribute("cx", ex + s * 4); main.setAttribute("cy", ey + brasL + 5); main.setAttribute("r", 8 + 2 * k);
      courte.setAttribute("d", ["M", ex - brasE - 4, ey - 2, "Q", ex, ey - 12, ex + brasE + 4, ey - 2,
                                "L", ex + s * 1 + brasE + 3, ey + 17, "Q", ex + s, ey + 21, ex + s * 1 - brasE - 3, ey + 17, "Z"].join(" "));
      return [ex, ey];
    }
    var eG = bras(-1, r.mancheG, r.mainG, r.mancheCourteG), eD = bras(1, r.mancheD, r.mainD, r.mancheCourteD);

    // pose : angles des bras et des jambes
    var ecart = 10 + 22 * k;   // les bras s'écartent pour contourner le ventre
    var aG = ecart, aD = -ecart, jG = 0, jD = 0, corpsY = 0, inclin = 0;
    if (pose === "suspendu") { aG = 168 + 4 * Math.sin(t * 2); aD = -168 + 4 * Math.sin(t * 2); jG = 8 * Math.sin(t * 3); jD = -8 * Math.sin(t * 3 + 1); }
    else if (pose === "marche") { var o = Math.sin(t * 7); aG = ecart + 20 * o; aD = -ecart + 20 * o; jG = -18 * o; jD = 18 * o; corpsY = -2 * Math.abs(Math.cos(t * 7)); }
    else if (pose === "balance") { aG = ecart + 22 + 4 * Math.sin(t * 2); aD = -ecart - 22 - 4 * Math.sin(t * 2); }
    else { aG = ecart + 2 * Math.sin(t * 1.6); aD = -ecart - 2 * Math.sin(t * 1.6); corpsY = 1.2 * Math.sin(t * 1.6); }
    r.brasG.setAttribute("transform", "rotate(" + aG + " " + eG[0] + " " + eG[1] + ")");
    r.brasD.setAttribute("transform", "rotate(" + aD + " " + eD[0] + " " + eD[1] + ")");
    r.jambeG.setAttribute("transform", "rotate(" + jG + " " + hG[0] + " " + hG[1] + ")");
    r.jambeD.setAttribute("transform", "rotate(" + jD + " " + hD[0] + " " + hD[1] + ")");

    // tête : visage rond, cheveux en mèche, joues, yeux, sourire
    var tx = cx, ty = teteY;
    r.oreilleG.setAttribute("cx", tx - teteR + 1); r.oreilleG.setAttribute("cy", ty + 4); r.oreilleG.setAttribute("rx", 6); r.oreilleG.setAttribute("ry", 8);
    r.oreilleD.setAttribute("cx", tx + teteR - 1); r.oreilleD.setAttribute("cy", ty + 4); r.oreilleD.setAttribute("rx", 6); r.oreilleD.setAttribute("ry", 8);
    var lj = teteR * (1 + .18 * k);   // joues plus pleines avec k
    r.visage.setAttribute("d", ["M", tx - teteR, ty - 4,
      "C", tx - teteR, ty - teteR - 6, tx + teteR, ty - teteR - 6, tx + teteR, ty - 4,
      "C", tx + lj, ty + teteR * .7, tx + teteR * .5, ty + teteR + 4, tx, ty + teteR + 4,
      "C", tx - teteR * .5, ty + teteR + 4, tx - lj, ty + teteR * .7, tx - teteR, ty - 4, "Z"].join(" "));
    r.cheveux.setAttribute("d", ["M", tx - teteR - 1, ty - 2,
      "C", tx - teteR - 3, ty - teteR - 14, tx + teteR + 6, ty - teteR - 16, tx + teteR + 1, ty - 4,
      "C", tx + teteR - 6, ty - 14, tx + 4, ty - 18, tx - 2, ty - 10,
      "C", tx - 6, ty - 18, tx - teteR + 8, ty - 16, tx - teteR - 1, ty - 2, "Z"].join(" "));
    r.joueG.setAttribute("cx", tx - teteR * .55); r.joueG.setAttribute("cy", ty + 12); r.joueG.setAttribute("rx", 6 + 2 * k); r.joueG.setAttribute("ry", 4 + k);
    r.joueD.setAttribute("cx", tx + teteR * .55); r.joueD.setAttribute("cy", ty + 12); r.joueD.setAttribute("rx", 6 + 2 * k); r.joueD.setAttribute("ry", 4 + k);
    var yy = ty + 1;
    r.oeilG.setAttribute("cx", tx - 11); r.oeilG.setAttribute("cy", yy); r.oeilG.setAttribute("rx", 4.2); r.oeilG.setAttribute("ry", 5.6);
    r.oeilD.setAttribute("cx", tx + 11); r.oeilD.setAttribute("cy", yy); r.oeilD.setAttribute("rx", 4.2); r.oeilD.setAttribute("ry", 5.6);
    r.refletG.setAttribute("cx", tx - 9.6); r.refletG.setAttribute("cy", yy - 2);
    r.refletD.setAttribute("cx", tx + 12.4); r.refletD.setAttribute("cy", yy - 2);
    var sourcil = pose === "suspendu" ? -3 : 0;
    r.sourcilG.setAttribute("d", ["M", tx - 15, yy - 10 + sourcil, "Q", tx - 10, yy - 13 + sourcil, tx - 5, yy - 10 + sourcil].join(" "));
    r.sourcilD.setAttribute("d", ["M", tx + 5, yy - 10 + sourcil, "Q", tx + 10, yy - 13 + sourcil, tx + 15, yy - 10 + sourcil].join(" "));
    r.nez.setAttribute("d", ["M", tx - 1, yy + 6, "Q", tx + 3, yy + 9, tx, yy + 11].join(" "));
    var bl = pose === "suspendu" ? 6 : 8;   // la bouche s'arrondit (« oh ! ») quand elle est suspendue
    if (pose === "suspendu") r.bouche.setAttribute("d", ["M", tx - 4, yy + 18, "Q", tx, yy + 13, tx + 4, yy + 18, "Q", tx, yy + 24, tx - 4, yy + 18, "Z"].join(" "));
    else r.bouche.setAttribute("d", ["M", tx - bl, yy + 15, "Q", tx, yy + 25, tx + bl, yy + 15, "Q", tx, yy + 19, tx - bl, yy + 15, "Z"].join(" "));

    // clignement des yeux toutes les ~4 s
    var cligne = ((t + 0.3) % 4) < 0.12 ? 0.12 : 1;
    r.yeux.setAttribute("transform", "translate(0," + yy + ") scale(1," + cligne + ") translate(0," + (-yy) + ")");
    r.corps.setAttribute("transform", "translate(0," + corpsY + ")");
    svg.dataset.k = k;
  }

  // ---------- Animation de la corpulence (interpolation douce) ----------
  function animerK(svg, cible, duree) {
    var depart = parseFloat(svg.dataset.k || "0.3"), t0 = null;
    svg._cible = cible;
    if (svg._animK) cancelAnimationFrame(svg._animK);
    function pas(t) {
      if (t0 === null) t0 = t;
      var u = Math.min(1, (t - t0) / duree), e = u < .5 ? 4 * u * u * u : 1 - Math.pow(-2 * u + 2, 3) / 2;
      svg._k = depart + (cible - depart) * e;
      if (u < 1) svg._animK = requestAnimationFrame(pas);
    }
    svg._animK = requestAnimationFrame(pas);
  }

  // ---------- Boucle de vie : respiration, balancement, marche, et accueil en boucle ----------
  var toutes = [];
  function vivre(t) {
    var s = t / 1000;
    toutes.forEach(function (svg) {
      if (!document.body.contains(svg)) return;
      if (svg._k === undefined) svg._k = parseFloat(svg.dataset.k || "0.3");
      dessiner(svg, svg._k, svg.dataset.pose, s + (svg._decalage || 0));
    });
    requestAnimationFrame(vivre);
  }
  function enregistrer(svg) {
    if (toutes.indexOf(svg) >= 0) return;
    construire(svg);
    svg._decalage = Math.random() * 10;
    svg._k = parseFloat(svg.dataset.k || "0.3");
    toutes.push(svg);
    if (svg.classList.contains("en-boucle")) boucle(svg);
  }
  function boucle(svg) {
    if (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    var cibles = [0.05, 0.4, 0.75, 1, 0.4], i = 0;
    (function suivant() { if (!svg._pause) { animerK(svg, cibles[i], 1800); i = (i + 1) % cibles.length; } setTimeout(suivant, 2800); })();
  }
  function scanner(racine) { (racine || document).querySelectorAll("svg.mascotte").forEach(enregistrer); }

  window.Mascotte = {
    dessiner: dessiner, animerK: animerK, scanner: scanner,
    fixerK: function (svg, k) { svg._k = k; svg.dataset.k = k; },
    pause: function (svg, oui) { svg._pause = oui; }
  };
  window.Silhouette = {   // compatibilité avec le reste du code
    dessiner: function (svg, k) { Mascotte.fixerK(svg, k); }, animer: function (svg, k, d) { animerK(svg, k, d); },
    pause: function (svg, oui) { svg._pause = oui; }
  };

  document.addEventListener("DOMContentLoaded", function () { scanner(); requestAnimationFrame(vivre); });
  // Les mascottes ajoutées plus tard par le serveur (portraits, bulles) sont prises en charge
  $(document).on("shiny:value", function () { setTimeout(scanner, 30); });

  function enregistrerMessages() {
    Shiny.addCustomMessageHandler("corpulence", function (m) { var s = document.getElementById(m.id); if (s) animerK(s, m.k, 900); });
  }
  if (window.Shiny && Shiny.addCustomMessageHandler) enregistrerMessages(); else $(document).on("shiny:connected", enregistrerMessages);
})();
