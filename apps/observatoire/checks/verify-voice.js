// Run with JavaScriptCore jsc from the repository root.
var listeners = {}, recognition, spoken;
var elements = {
  assistant_voice_status: {}, assistant_voice_consent: { checked: false },
  assistant_texte: { value: 'Texte initial.', dispatchEvent: function () { this.changed = true; } }
};
var button = { id: 'assistant_micro', textContent: 'Dicter mes habitudes', setAttribute: function (key, value) { this[key] = value; }, classList: { contains: function () { return false; } } };
var document = {
  getElementById: function (id) { return elements[id]; },
  addEventListener: function (name, fn) { listeners[name] = fn; },
  querySelector: function () { return { classList: { contains: function () { return true; } }, querySelectorAll: function () { return [{textContent:'Une comparaison descriptive.'}]; } }; }
};
function Event(name) { this.type = name; }
function SpeechSynthesisUtterance(text) { this.text = text; }
var window = {
  SpeechRecognition: function () { recognition = this; this.start = function () {}; this.stop = this.abort = function () { if(this.onend) this.onend(); }; },
  SpeechSynthesisUtterance: SpeechSynthesisUtterance,
  speechSynthesis: {cancel:function(){}, getVoices:function(){return[];}, speak:function(u){spoken=u;}},
  addEventListener: function () {}
};
function assert(x, message) { if (!x) throw new Error(message); }
function click(b) { listeners.click({target:{closest:function(){return b;}}}); }
load('apps/observatoire/www/voice.js');
click(button);
assert(!recognition, 'Consent required before recognition');
elements.assistant_voice_consent.checked = true;
click(button);
assert(recognition.lang === 'fr-FR' && button['aria-pressed'] === 'true', 'French dictation starts');
recognition.onresult({resultIndex:0,results:[{isFinal:true,0:{transcript:'Je marche.'}}]});
assert(elements.assistant_texte.value === 'Texte initial. Je marche.' && elements.assistant_texte.changed, 'Transcript appends and notifies Shiny');
recognition.onend();
assert(button['aria-pressed'] === 'false', 'Micro reset');
var read = {textContent:'Écouter',dataset:{readTarget:'.assistant-answer'},classList:{contains:function(c){return c==='assistant-read';}}};
click(read);
assert(spoken.text === 'Une comparaison descriptive.' && spoken.lang === 'fr-FR', 'Read displayed answer in French');
click(read);
assert(read.textContent === 'Écouter', 'Stop reading resets button');
print('PASS — Consentement, dictée française, transcription Shiny, arrêt du micro et lecture/arrêt');
