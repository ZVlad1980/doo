PL/SQL Developer Test script 3.0
179
-- Created on 15.08.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  b xxdoo.xxdoo_bk_book_typ := xxdoo.xxdoo_bk_book_typ(p_name     => 'contractors',
                                                       p_owner    => 'xxdoo',
                                                       p_dev_code => 'xxdoo_cntr',
                                                       p_scheme   => 'Contractors',
                                                       p_entry    => 'contractor',
                                                       p_path     => ':filter/:contractors?/:state?');
  --
  h xxdoo.xxdoo_html := xxdoo.xxdoo_html();
  t xxdoo.xxdoo_html := xxdoo.xxdoo_html();
  h1 xxdoo.xxdoo_html := xxdoo.xxdoo_html();
  --
  l_owner   varchar2(60) := 'xxdoo';
  l_package varchar2(60) := 'xxdoo_cntr_bk_pkg';
  --
  procedure add_region(p_name varchar2) is
  begin
    if not b.exists_region(p_name) then
      b.create_region(p_name, xxdoo.xxdoo_bk_method_typ('get_'||p_name, 'xxdoo', 'xxdoo_bk_regions_pkg', 'get_'||p_name));
    end if;
  end;
  --
begin
  --dbms_session.reset_package; return;
  --
  --
  -- b.param('contractors', b.fn(fetchContractor)); param convertor
  
  xxdoo.xxdoo_utl_pkg.init_exceptions;
  --
  -- REGIONS
  --
  add_region('content');
  add_region('toolbar');
  add_region('sidebar');
  --
  --LAYOUT
  --
  h.init;
  h := h.h('head',
         h.h('meta',h.attr('apple-mobile-web-app-capable','yes')).
           h('meta',h.attr('apple-mobile-web-app-status-bar-style','black')).
           h('meta',h.attr('viewport','width=device-width, initial-scale=1.0, user-scalable=no')).
           h('meta',h.attrs(http_equiv => 'X-UA-Compatible', content => 'IE=edge,chrome=1', charset => 'utf-8')).
           h('title',h.G('title')).
           h('link',h.attrs(href => h.G('get_css_link'), rel => 'stylesheet'))
  );
  --
  t := t.h('body',t.attr('data-book',t.G('name')),
         t.h('div.wrapper',
           t.h('header.header',
             t.h('div#toolbar.buttons', t.G('get_toolbar')).
             h('div.search',
               t.h('input', t.attrs(type => 'text', name => 'query', value => t.G('search')))
             )
           ).
           h('div.sidebar',t.h('ol#entries.list',t.attr('tabindex','0'),t.G('get_sidebar'))).
           h('div#content.content',t.G('get_content'))
         ).
         h('script',t.attr('src',t.G('get_js_link')))
  );
  --
  b.create_layout(h.h('html',
           h.h(h).
             h(t)
          ));
  --
  -- PAGES
  --
  h.init;
  
  b.page('Welcome',
    h.h('div.page',
        h.h('h1','Welcome Page').
        h('p','Please select entry...')
      )
  );           
  --
  h.init;
  b.page('Contractors',
    h.h('div.page',
        h.h('h1','CONTRACTORS').
        h('br').
        h('p',h.text('Contractor: ').text(h.G('name')).text(', type ').text(h.G('type'))).
        h('p',h.text('Callback_id = ').text(b.callback(p_owner   => l_owner,
                                                       p_package => l_package,
                                                       p_method  => 'callback')))
      )
  );
  
  --
  --ROLES
  --
  
  -- declare
  -- owner xxdoo_bk_role
  -- begin
  -- owner := new xxdoo_bk_role('Owner')
  
  -- owner.context() -- prepare context shared with all role pages
  -- owner.page()
  -- owner.when()
  -- owner.set(key, value) -- put value under key in internal key-value storage
  -- owner.get(key) -- get value under given key
  
  -- owner.page(b.page('Welcome')).when(b.fn('something'))
  
  -- owner.when(b.fn('state_is_empty'))
  --    .page('A')
  --    .page('B')
  --    .page('C')
  --
  -- b.role(owner);
  --
  -- b.fn('name') or b.fn(p_owner => ..., p_method => ...)
  
  
  -- region.filters
  -- function context(a : Answer(role, book, params))
  -- {
  --   var selectedFilterId = params.filter;
  --     var allFilters = role.get('filters');
  --    
  --     var selectedFilter = allFiters[selectedFilterId || 0];
  --    
  --     return { filters: allFitlers, selected: selectedFilter }
  -- }
  -- h.h('ul.filters', h.each(G('filters'), h.h('li', G()))
                                 
  
  b.role('Owner',
         xxdoo.xxdoo_bk_role_pages_typ(
           b.role_page('Welcome')
            -- Maybe rename condition_method to when
            .condition_method(p_owner   => l_owner,
                              p_package => l_package,
                              p_method  => 'welcome_condition'),
           b.role_page('Contractors')
            .condition_method(p_owner   => l_owner,
                              p_package => 'xxdoo_cntr_bk_pkg',
                              p_method  => 'contractors_condition')
            .prepare_method(p_owner   => l_owner,
                            p_package => l_package,
                            p_method  => 'contractors_prepare')--*/
         )
        );
  --
  -- TOOLBAR
  --
  b.create_toolbar(
    xxdoo.xxdoo_bk_buttons_typ(
      b.button('New'),
      b.button('Update')
    )
  );
  h.init;
  b.toolbar.set_html(h.each('buttons', h.h('a.button', h.attr('href','#'), h.G('name'))));
  --
  -- Sidebar
  --
  h.init;
  --
  b.template(p_name        => 'sidebar',
             p_html        => h.each(h.h('li.item', h.attr('data-id',h.G('id')), h.G('name'))); h.text('NAME: ').text(h.G('name')))),
             p_source_name => 'contractors');
  --
  --
  -- GENERATION&SAVE
  --
  b.generate;
  b.put;
  --
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
3
self.id
p_name
self.name
