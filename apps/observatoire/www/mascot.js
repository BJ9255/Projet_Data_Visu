(function () {
  'use strict';
  var timers = [], sequence = 0;
  function later(fn, delay) { timers.push(setTimeout(fn, delay)); }
  function clear() {
    sequence++;
    timers.forEach(clearTimeout); timers = [];
    var overlay = document.getElementById('oscar-transition');
    if (overlay) overlay.className = '';
    document.body.classList.remove('oscar-page-pulled');
  }
  function scene() {
    var node = document.getElementById('oscar-transition');
    if (node) return node;
    node = document.createElement('div');
    node.id = 'oscar-transition';
    node.setAttribute('role', 'presentation');
    node.innerHTML = '<div class="oscar-curtain" aria-hidden="true"></div><div class="oscar-chapter" aria-hidden="true"><span>PROCHAINE ESCALE</span><strong></strong></div><button type="button" class="oscar-skip">Passer l’animation <span>Échap</span></button><div class="oscar-giant" aria-hidden="true"><svg viewBox="0 0 420 490" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="oscar-shirt" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#31a5a0"/><stop offset=".55" stop-color="#147d80"/><stop offset="1" stop-color="#10505f"/></linearGradient><radialGradient id="oscar-skin"><stop stop-color="#e4b387"/><stop offset="1" stop-color="#bc865b"/></radialGradient><linearGradient id="oscar-bread" x2="1" y2="1"><stop stop-color="#f6dca1"/><stop offset="1" stop-color="#cb9045"/></linearGradient></defs><ellipse cx="205" cy="464" rx="150" ry="16" fill="#193d4725"/><g class="giant-leg giant-leg-left"><path d="M152 380 L137 448" stroke="#193d47" stroke-width="40" stroke-linecap="round"/><path d="M137 448 L96 455" stroke="#112c34" stroke-width="32" stroke-linecap="round"/></g><g class="giant-leg giant-leg-right"><path d="M246 380 L271 448" stroke="#193d47" stroke-width="40" stroke-linecap="round"/><path d="M271 448 L313 455" stroke="#112c34" stroke-width="32" stroke-linecap="round"/></g><g class="giant-body"><path d="M90 211 Q44 247 52 293" fill="none" stroke="#bc865b" stroke-width="32" stroke-linecap="round"/><ellipse cx="201" cy="275" rx="139" ry="127" fill="url(#oscar-shirt)"/><ellipse cx="191" cy="290" rx="110" ry="93" fill="#42b2a0" opacity=".17"/><path d="M115 332 Q201 367 280 329" fill="none" stroke="#b7d9cd" stroke-width="10" stroke-linecap="round"/><path d="M103 204 Q202 168 296 207" fill="none" stroke="#d3e8d5" stroke-width="8"/><g class="giant-pull-arm"><path d="M297 215 Q342 239 375 202" fill="none" stroke="#bc865b" stroke-width="34" stroke-linecap="round"/><path class="giant-rope" d="M372 202 L820 202" stroke="#dfad53" stroke-width="7" fill="none"/><circle cx="375" cy="202" r="18" fill="#c99266"/></g><g class="giant-head"><ellipse cx="202" cy="105" rx="65" ry="73" fill="url(#oscar-skin)"/><ellipse cx="138" cy="107" rx="12" ry="19" fill="#bc865b"/><ellipse cx="266" cy="107" rx="12" ry="19" fill="#bc865b"/><path d="M140 85 Q119 26 172 19 Q191 4 226 20 Q281 25 264 85 L250 66 Q201 49 154 68 Z" fill="#222d30"/><path d="M159 92 Q175 83 188 91 M215 91 Q232 83 245 92" stroke="#222d30" stroke-width="6" fill="none" stroke-linecap="round"/><g class="giant-eyes"><ellipse cx="175" cy="101" rx="9" ry="10" fill="#fff9f0"/><circle cx="178" cy="102" r="5" fill="#193d47"/><ellipse cx="232" cy="101" rx="9" ry="10" fill="#fff9f0"/><circle cx="235" cy="102" r="5" fill="#193d47"/></g><ellipse cx="158" cy="122" rx="11" ry="7" fill="#d89272" opacity=".5"/><ellipse cx="247" cy="122" rx="11" ry="7" fill="#d89272" opacity=".5"/><path d="M197 101 L190 123 Q201 130 211 123" stroke="#ad744f" stroke-width="4" fill="none" stroke-linecap="round"/><path d="M202 130 Q183 114 165 138 Q184 150 202 139 Q222 150 241 138 Q220 114 202 130Z" fill="#222d30"/><path class="giant-mouth" d="M189 153 Q202 163 216 153" stroke="#763d31" stroke-width="4" fill="none" stroke-linecap="round"/></g><g class="giant-kebab"><path d="M310 229 Q294 235 277 232" stroke="#bc865b" stroke-width="25" fill="none" stroke-linecap="round"/><g transform="translate(270 161) rotate(12)"><path d="M0 16 Q24 -2 49 16 L38 85 L15 85Z" fill="url(#oscar-bread)" stroke="#b57d3a" stroke-width="3"/><path d="M5 13 L12 3 L24 9 L36 0 L46 13" fill="#70a365"/><path d="M8 19 L40 19 M12 29 L38 29" stroke="#8c4f32" stroke-width="8"/><path d="M5 22 L41 22" stroke="#d95f59" stroke-width="4"/><path d="M11 51 L40 51 L36 91 L15 91Z" fill="#fff8ee"/><path d="M18 64 L33 67" stroke="#d3e8d5" stroke-width="4"/></g></g><g class="giant-crumbs" fill="#e7bd78"><circle cx="214" cy="163" r="3"/><circle cx="222" cy="170" r="2"/><circle cx="201" cy="176" r="3"/></g></g></svg><span class="giant-caption">Je vous ouvre la page…</span></div>';
    document.body.appendChild(node);
    return node;
  }
  function animate(title) {
    clear();
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    var node = scene();
    node.querySelector('.oscar-chapter strong').textContent = title || 'Votre prochaine exploration';
    // Restart CSS animation even after rapid consecutive selections.
    void node.offsetWidth;
    node.className = 'oscar-scene-active';
    document.body.classList.add('oscar-page-pulled');
    var current = sequence;
    later(function () {
      if (current !== sequence) return;
      node.classList.add('oscar-snack');
      node.querySelector('.giant-caption').textContent = 'Voilà ! Petite pause kebab.';
    }, 1350);
    later(clear, 3400);
    node.querySelector('.giant-caption').textContent = 'Je vous ouvre la page…';
  }
  $(function () {
    $(document).on('change', '#navigation_section', function () {
      var target = this.value;
      var link = $('#onglets a[data-value="' + target + '"]');
      if (link.length && !link.parent().hasClass('active')) link.tab('show');
    });
    $(document).on('shown.bs.tab', '#onglets a[data-toggle="tab"]', function () {
      var select = document.getElementById('navigation_section');
      if (select) {
        select.value = this.getAttribute('data-value');
        // Keep Shiny's input state aligned with programmatic navigation.
        if (window.Shiny) Shiny.setInputValue('navigation_section', select.value, {priority:'event'});
      }
      animate(this.textContent.replace(/^\s*\d+\s*\/\s*/, '').trim());
    });
    $(document).on('click', '.oscar-skip', clear);
    $(document).on('shiny:disconnected', clear);
  });
  document.addEventListener('keydown', function (event) { if (event.key === 'Escape') clear(); });
  document.addEventListener('visibilitychange', function () { if (document.hidden) clear(); });
})();
