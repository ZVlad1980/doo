callbacks.register = (function() {
  var callbacks = {},
      id = 0;

  return function(callback, name) {
    if (name && callbacks[name]) throw new Error('Callback already registred');
    if (!name) name = ++id;

    callbacks[name] = callback;
    return name;
  }
})();


h.a('Click Me', { 'data-callback': callbacks.register(logMe) });


function logMe() {
  console.log('Button Clicked');
}



GET erouter/app-x/?callback=
