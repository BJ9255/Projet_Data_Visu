var handlers={}, timers=[], node=null, selected=null, reduced=false;
function assert(ok, message){if(!ok)throw new Error(message);}
function $(arg){if(typeof arg==='function'){arg();return;}if(arg===document)return{on:function(event,selector,fn){if(typeof selector==='function')fn=selector;handlers[event]=fn;}};return{length:1,parent:function(){return{hasClass:function(){return false;}};},tab:function(){selected=arg;}};}
var caption={textContent:''}, bodyClasses=[];
var document={body:{classList:{add:function(c){bodyClasses.push(c);},remove:function(c){bodyClasses=bodyClasses.filter(function(x){return x!==c;});}},appendChild:function(n){node=n;}},getElementById:function(id){if(id==='navigation_section')return menu;return node;},createElement:function(){return{className:'',setAttribute:function(){},classList:{add:function(c){node.className+=' '+c;}},querySelector:function(){return caption;}};},addEventListener:function(){}};
var window={matchMedia:function(){return{matches:reduced};},Shiny:true};
var Shiny={setInputValue:function(id,value){assert(value===menu.value,'Synchronisation Shiny');}};
var menu={value:'carte'};
function setTimeout(fn,delay){timers.push({fn:fn,delay:delay});return timers.length;}
function clearTimeout(){}
load('apps/observatoire/www/mascot.js');
handlers.change.call({value:'assistant'});
assert(selected.indexOf('assistant')!==-1,'Menu ouvre la bonne section');
handlers['shown.bs.tab'].call({textContent:'04 / Explorer mon profil',getAttribute:function(){return 'assistant';}});
assert(menu.value==='assistant' && node.className==='oscar-scene-active','Transition et menu synchronisés');
assert(node.innerHTML.indexOf('giant-kebab')!==-1 && node.innerHTML.indexOf('giant-rope')!==-1,'Dessin corde et kebab présents');
timers.filter(function(t){return t.delay===1350;})[0].fn();
assert(node.className.indexOf('oscar-snack')!==-1,'Kebab après le tirage');
timers.filter(function(t){return t.delay===3400;})[0].fn();
assert(node.className==='' && bodyClasses.length===0,'Transition nettoyée');
reduced=true;
handlers['shown.bs.tab'].call({textContent:'03 / Comprendre la méthode',getAttribute:function(){return 'methode';}});
assert(menu.value==='methode' && node.className==='','Navigation sans animation avec réduction des mouvements');
print('PASS — Menu, synchronisation, tirage, kebab, fin de transition et réduction des mouvements');
