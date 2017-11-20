h.html({ doctype: 'html' },
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
        h.input({ type: 'text', name: 'query', placeholder: t('Type to search...') }))),

    h('div.sidebar',
      h('ul#folders.filter', folders),
      h('ol#entries.list', {
        'tabindex': 0,
        'data-behavior': 'list',
        'data-asset': G('contentId')
      })
    ),

    h('div#content.content'),

    h.script({ src: 'noodoo.js?' + new Date().getTime() })
  )
)