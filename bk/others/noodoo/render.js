var h = require('nd-html'),
    utils = require('nd-utils');

var slice = Array.prototype.slice;

var t = h.translate;

var G = utils.getter,
    firstOf = utils.firstOf,
    compose = utils.compose;


exports.each = function(array, item) {
  var result = [];

  for (var i=0, len=array.length; i<len; i++) {
    result.push(item(array[i]));
  }

  return result.join('');
};

var folders = exports.folders = h.each(G('folders'),
  h.within('entry', h('li.option', {
    'data-name': G('name'),
    'data-action': G('action'),
    'title': G('count')
  }, h.translate(G('name'))))
);

exports.entry = function(schema, fn) {
  var pk = schema.pk,
      label = schema.fields[1] || schema.fields[0],
      entry = fn || G(label);

  return h('li.item', { 'data-id': G(pk) }, h.a(entry));
};

var toolbar = exports.toolbar = h('div#toolbar.buttons', G('buttons'));

exports.content = h('form#content.content',
  h.when(G('context.entry'), [
    h.input({
      'type': 'hidden',
      'value': function(ctx) { return ctx.context.entry[ctx.schema.pk]; },
      'name': function(ctx) { return ctx.schema.entry + '.' + ctx.schema.pk; }
    }),
    h.input({
      'type': 'hidden',
      'value': G('context.entry.state'),
      'name': function(ctx) { return ctx.schema.entry + '.state'; }
    })
  ]),
  function(ctx) { return h.within('context', ctx.content); }
);

var stylesheet = function(name) { return name + '/css/' + name + '.css'; };

exports.layout = h.html({ doctype: 'html' },
  h.head(
    h.meta({ charset: 'utf-8'}),
    h.meta({ name: 'apple-mobile-web-app-capable', content: 'yes'}),
    h.meta({ name: 'apple-mobile-web-app-status-bar-style', content: 'black'}),
    h.meta({ name: 'viewport', content: 'width=device-width, initial-scale=1.0, user-scalable=no'}),
    h.meta({ 'http-equiv': 'X-UA-Compatible', 'content': 'IE=edge,chrome=1' }),
    h.title(G('title')),
    h.link({ href: 'css/noodoo-ui.css?' + new Date().getTime(), rel: 'stylesheet' }),
    h.link({ href: compose(G('book.name'), stylesheet), rel: 'stylesheet' })),
    h.link({ rel: 'apple-touch-icon', href: 'images/ipad_icon.png' }),

  h.body({ 'data-book': G('book.name') },
    h('header.header',
      toolbar,
      h('div.search',
        h.input({ type: 'text', name: 'query', placeholder: t('Type to search...') })),
      h('ul#folders.filter', folders)
    ),
    h('div.sidebar',
      h('ol#entries.list', {
        'tabindex': 0,
        'data-behavior': 'list',
        'data-asset': G('contentId')
      })
    ),

    h('div#content.content'),

    h.script({ src: 'noodoo.js?' + new Date().getTime() })
  )
);

exports.confirm = h('div.confirm', h.within(G('confirm'), [
  h.h3(firstOf(G('message'), 'Are you sure?')),
  h('div.buttons',
    h('a.button.primary', firstOf(G('yes'), 'Yes'), {
      'data-action': G('action'),
      'data-meta': 'Yes'
    }),
    h('a.button', firstOf(G('no'), 'No'), {
      'data-action': G('action'),
      'data-meta': 'No'
    })
  )
]));

exports.errors = function() {
  var entries = slice(arguments),
      template;

  if (typeof(entries[0]) === 'function') template = entries[0];

  return h.when(hasErrors, template || errors(entries));
};

var errors = function(entries) {
  return h('div.errors',
    h.h2(t('Please correct the following errors before continuing')),
    h.ul(function(ctx) {
      var errors = ctx.errors,
          template = [],
          entry, key, messages;

      for (entry in errors) {
        if (entries.length && entries.indexOf(entry) === -1) continue;
        messages = errors[entry];

        for (key in messages) {
          if (typeof(messages[key]) !== 'object')
            template.push(h.li(t(key), ' ', t(messages[key])));
        }
      }

      return template;
    })
  );
};

var hasErrors = function(ctx) {
  return !!Object.keys(ctx.errors).length;
};