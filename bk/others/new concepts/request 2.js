book.layout = h('div.wrapper',
  h('header',
    h('div#toolbar', G('toolbar'))),

  h('div#content', G('content'))
);

book.templates = {
  toolbar: h.each(G('buttons'), h('a.button', { href: '#' }, G('name'))),

  somePage: h('div.page', h('h1', 'Page Title'), h('p', 'Hello World'))
};

book.regions = {
  toolbar: function(ref a : Answer) {
    console.log('Rendering Toolbar');

    // We will prepare buttons here (check visibility for example)

    buttons = [
      { name: 'Click Me' },
      { name: 'And me also' }
    ];

    return templates.toolbar({ buttons: buttons })
  }

  content: function(ref a : Answer) {
    console.log('Rendering Content');

    // We will prepare pages here (authorize againist state and role)

    return templates.somePage({});
  }
}

function processRequest(url : String, qs : XML, body : XML)
{
  if (url.indexOf(book.name) !== 0) return 404;
  if (url.indexOf('callback') !== -1) return 404;

  // If it is not callback, it is direct user request
  // and we have to render layout

  // var ctx = new Answer();
  // var params = processURL(url);
  // for (var key in params)
  //   var o;
  //   var f = body.forms[key];
  //   if (f) o = db[key].load(params[key], f); // If form was given
  //   else o = db[key].get(params[key]);
  //   ctx.entries[key] = o;

  // if it was callback
  // get callback, authorize it and call it within context

  var regions = {};

  for (var name in book.regions) {
    regions[name] = book.regions[name].call() // Later we will call them with context
  }

  return layout(regions);
}
