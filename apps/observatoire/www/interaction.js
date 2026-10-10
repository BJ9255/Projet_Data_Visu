$(function () {
  $(document).on('shown.bs.tab', 'a[data-toggle="tab"]', function () {
    window.dispatchEvent(new Event('resize'));
    var slider = $('#age').data('ionRangeSlider');
    if (slider) slider.update({});
  });
  Shiny.addCustomMessageHandler('scroll-section', function (id) {
    var section = document.getElementById(id === 'onglets' ? 'navigation-sections' : id);
    if (section) {
      section.scrollIntoView({
        behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth',
        block: 'start'
      });
    }
  });
});
$(function () {
  Shiny.addCustomMessageHandler('assistant-busy', function (busy) {
    ['assistant_comprendre', 'assistant_comparer', 'assistant_expliquer'].forEach(function (id) {
      var button = document.getElementById(id);
      if (button) button.disabled = busy;
    });
  });
});
