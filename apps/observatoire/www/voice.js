(function () {
  'use strict';
  var Recognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  var recognition = null, activeButton = null, readingButton = null;
  function status(text) {
    var node = document.getElementById('assistant_voice_status');
    if (node) node.textContent = text;
  }
  function resetMicro() {
    if (activeButton) {
      activeButton.textContent = activeButton.id === 'assistant_micro' ? 'Dicter mes habitudes' : 'Dicter ma question';
      activeButton.setAttribute('aria-pressed', 'false');
    }
    activeButton = null;
  }
  function stopVoice() {
    if (recognition) recognition.abort();
    resetMicro();
    if (window.speechSynthesis) window.speechSynthesis.cancel();
    if (readingButton) readingButton.textContent = readingButton.dataset.originalLabel;
    readingButton = null;
  }
  function dictate(button, targetId) {
    if (recognition && activeButton) { recognition.stop(); return; }
    if (!Recognition) { status('La dictée est indisponible dans ce navigateur. Vous pouvez saisir votre texte.'); return; }
    var consent = document.getElementById('assistant_voice_consent');
    if (!consent || !consent.checked) { status('Cochez l’accord pour la dictée vocale avant d’utiliser le micro.'); return; }
    var field = document.getElementById(targetId);
    if (!field) return;
    stopVoice();
    recognition = new Recognition();
    recognition.lang = 'fr-FR';
    recognition.continuous = false;
    recognition.interimResults = false;
    var base = field.value.trim();
    activeButton = button;
    button.textContent = 'Arrêter la dictée';
    button.setAttribute('aria-pressed', 'true');
    status('Micro en cours… Parlez, puis attendez la transcription.');
    recognition.onresult = function (event) {
      var words = [];
      for (var i = event.resultIndex; i < event.results.length; i++) {
        if (event.results[i].isFinal) words.push(event.results[i][0].transcript);
      }
      if (!words.length) return;
      field.value = (base ? base + ' ' : '') + words.join(' ');
      field.dispatchEvent(new Event('input', { bubbles: true }));
      field.dispatchEvent(new Event('change', { bubbles: true }));
      status('Transcription ajoutée. Relisez et corrigez le texte avant de l’envoyer.');
    };
    recognition.onerror = function (event) {
      var messages = {
        'not-allowed': 'Le micro n’est pas autorisé. Autorisez-le dans votre navigateur ou saisissez votre texte.',
        'service-not-allowed': 'Le service vocal est indisponible. Vous pouvez saisir votre texte.',
        'audio-capture': 'Aucun microphone disponible.',
        'no-speech': 'Aucune parole détectée. Réessayez ou saisissez votre texte.',
        'network': 'La transcription n’a pas abouti. Vérifiez la connexion ou saisissez votre texte.'
      };
      status(messages[event.error] || 'La dictée a été interrompue. Votre texte reste modifiable.');
    };
    recognition.onend = resetMicro;
    try { recognition.start(); } catch (error) { resetMicro(); status('Impossible de démarrer la dictée. Vous pouvez saisir votre texte.'); }
  }
  document.addEventListener('click', function (event) {
    var button = event.target.closest('button');
    if (!button) return;
    if (button.id === 'assistant_micro') dictate(button, 'assistant_texte');
    if (button.classList.contains('assistant-dictate-question')) dictate(button, 'assistant_question');
    if (['assistant_effacer', 'assistant_comprendre', 'assistant_comparer', 'assistant_expliquer', 'assistant_exemple'].indexOf(button.id) !== -1) stopVoice();
    if (!button.classList.contains('assistant-read')) return;
    if (!window.speechSynthesis || !window.SpeechSynthesisUtterance) { status('La lecture vocale est indisponible dans ce navigateur.'); return; }
    if (readingButton === button) { stopVoice(); return; }
    stopVoice();
    var target = document.querySelector(button.dataset.readTarget);
    if (!target) return;
    var paragraphs = target.querySelectorAll('.assistant-computed, .assistant-answer p, .assistant-criteria, .assistant-class-row');
    if (target.classList.contains('assistant-answer')) paragraphs = target.querySelectorAll('p');
    var text = Array.from(paragraphs).map(function (p) { return p.textContent.trim(); }).join('. ');
    if (!text) return;
    var utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'fr-FR';
    var voice = window.speechSynthesis.getVoices().find(function (v) { return v.lang.indexOf('fr') === 0 && v.localService; });
    if (voice) utterance.voice = voice;
    readingButton = button;
    button.dataset.originalLabel = button.textContent;
    button.textContent = 'Arrêter la lecture';
    utterance.onend = utterance.onerror = function () {
      if (readingButton === button) { button.textContent = button.dataset.originalLabel; readingButton = null; }
    };
    window.speechSynthesis.speak(utterance);
  });
  document.addEventListener('change', function (event) {
    if (event.target.id === 'assistant_voice_consent' && !event.target.checked) stopVoice();
    if (/^assistant_(Age|Sexe|Famille|Fast_food|Legumes|Activite|Technologie|Transport)$/.test(event.target.id)) stopVoice();
  });
  window.addEventListener('pagehide', stopVoice);
  if (window.jQuery) window.jQuery(document).on('shown.bs.tab', stopVoice);
  document.addEventListener('visibilitychange', function () { if (document.hidden) stopVoice(); });
  document.addEventListener('DOMContentLoaded', function () {
    if (!Recognition) {
      var button = document.getElementById('assistant_micro');
      if (button) button.disabled = true;
      status('La dictée est indisponible dans ce navigateur. La saisie au clavier reste disponible.');
    }
  });
})();
