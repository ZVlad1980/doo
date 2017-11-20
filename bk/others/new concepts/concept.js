Request (url, querystring, body)  <= /tasks/#all/12/edit?q='Zhuravov'
  url = '/tasks/#all/12/edit'
  body = null
  querystring = { q: 'Zhuravov' }

  for each book
      book.path = '/tasks'
      book.routes = {
        path: ':filter/:tasks?/:state?',
        keys: ['filter', 'tasks', 'state']
        re: /()/
      }

      /callbacks/:callback/
      /:filter([a-z]+)?/:entry(\d+)?/:state([a-z]+)?/

      // Check if book is mounted at requested path
      if (url.indexOf(book.path) !== 0) continue;

      // Trim book name from url
      // now url = '/all/12/edit'

      var a = new Answer(book, this); => { book: book }

      book.middlewares.authenticate => { book: book, user: { name: 'Vladimir', role: 'Owner' } }
      book.middlewares.role => { ... , role: {...}  }
      book.middlewares.params => { ..., params: { filter: 'all', task: 12, state: 'edit' }}
         - calls route regexps with url until first match found
      book.middlewares.entries => { ..., entries: { task: { ... }} }}
         - for each key in params check if key is name of DB object
           - when true get it


      if (params.callback)
          var value = callbacks[params.callback].call(a);
          if (value) return respond(value);

          for region in book.regions
            region.render

          {
            path: a.path,
            regions: {
              sidebar: '<ul>',
              content: '<div>'
            }
          }

          layout = h.div
          layout(regions)


Role
  - name
  - pages
  - contextFn
  - variables: { filters, somethingElse }
