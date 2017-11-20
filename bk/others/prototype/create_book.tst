PL/SQL Developer Test script 3.0
252
-- Created on 15.08.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  b xxdoo.xxdoo_bk_book_typ;
  --
  h xxdoo.xxdoo_html;
  t xxdoo.xxdoo_html;
  --
  owner  xxdoo.xxdoo_bk_role_typ;
begin
  --dbms_session.reset_package; return;
  --
  h := xxdoo.xxdoo_html();
  t := xxdoo.xxdoo_html();
  --
  b := xxdoo.xxdoo_bk_book_typ(p_name     => 'contractors',
                               p_scheme   => 'xxdoo_cntr',
                               p_table    => 'contractor',
                               p_package  => 'xxdoo_cntr_bk_pkg',
                               p_path     => ':filter/:contractors?/:state?'
                               --p_dev_code => ,
                               --p_owner    =>    
                              );
  --
  -- REGIONS
  --
  b.region('content', b.fn('xxdoo', 'xxdoo_bk_regions_pkg', 'get_content'));
  b.region('toolbar', b.fn('xxdoo', 'xxdoo_bk_regions_pkg', 'get_toolbar'));
  b.region('sidebar', b.fn('xxdoo', 'xxdoo_bk_regions_pkg', 'get_sidebar'));
  --
  --LAYOUT
  --
  h.init;
  h := h.h('head',
         h.h('meta',h.attr('apple-mobile-web-app-capable','yes')).
           h('meta',h.attr('apple-mobile-web-app-status-bar-style','black')).
           h('meta',h.attr('viewport','width=device-width, initial-scale=1.0, user-scalable=no')).
           h('meta',h.attrs(http_equiv => 'X-UA-Compatible', content => 'IE=edge,chrome=1', charset => 'utf-8')).
           h('meta',h.attr('book_version',h.G('version'))).
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
           h('form#content.content',t.G('get_content'))
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
  --  Welcome
  h.init;
  b.page('Welcome',
    h.h('div.sheet',
        h.h('h1','Welcome Page').
        h('p','Please select entry...')
      )
  );           
  --
  --  ContractorInfo
  --
  h.init;
  b.page(
    p_name     => 'ContractorInfo',
    p_html     => h.h('div.sheet',
                   h.h('header.title group',
                       h.h('h2',
                           h.text('Contractor Info:').
                             h('span.info','description for test')
                       ).
                       h('div.buttons',
                         h.h('a.button primary', h.attrs(data_action => '49'),'Mark').
                           h('a.button', h.attrs(data_action => '50'),'Edit')
                       )
                   ).  
                   h('div.terms',h.text('Contractor: ').text(h.G('name')).text(', category ').text(h.G('category.name')))--.
                   --h('p',h.text('Callback_id = ').text(b.callback(b.fn('callback'))))
                 ),
    p_prepare => b.fn('prep_contractor_info')
  );   
  --
  --  ContractorEdit
  --
  h.init;
  b.page(
    p_name     => 'ContractorEdit',
    p_html     => h.h('div.sheet',
                      h.h('header.title group',
                          h.h('h2',
                              h.text('New Contractor Creation:').
                                h('span.info','description for test')
                          ).
                          h('div.buttons',
                            h.h('a.button primary', 
                                h.attr('href','#').
                                  attr('data-callback',b.callback(b.fn('cb_contractor_save'))).
                                  attr('data-sync','Y').
                                  attr('data-action',b.get_service_url),
                                'Save').
                              h('a.button', 
                                h.attr('href','#').
                                  attr('data-callback',b.callback(b.fn('cb_contractor_discard'))).
                                  attr('data-action',b.get_service_url),
                                'Discard changes')
                          )
                      ).  
                      h('div.form grid',
                        h.h('input', h.attrs(type => 'hidden', name => 'contractor.id', value => h.G('id'))).
                          h('fieldset.cols-4', 
                            h.h('legend','Contractors base info').
                              h('div.row group',
                                h.h('div.field cols-2',
                                    h.h('label.label','Contractor name').
                                      h('div.frame single group',
                                        h.h('input', h.attrs(name => 'contractor.name', value => h.G('name')))
                                      )
                                ).h('div.field cols-2',
                                    h.h('label.label','Alternative name').
                                      h('div.frame single group',
                                        h.h('input', h.attrs(name => 'contractor.name_alt', value => h.G('name_alt')))
                                      )
                                )
                              ).
                              h('div.row group',
                                h.h('div.field',
                                    h.h('label.label','Category').
                                      h('div.frame group',
                                        h.h('input', h.attrs(name => 'contractor.category.name', value => h.G('category.name')))
                                      )
                                ).h('div.field',
                                    h.h('label.label','Type').
                                      h('div.frame group',
                                        h.h('input', h.attrs(name => 'contractor.type.name', value => h.G('type.name')))
                                      )
                                ).h('div.field',
                                    h.h('label.label','Tax Reference').
                                      h('div.frame group',
                                        h.h('input', h.attrs(name => 'contractor.tax_reference', value => h.G('tax_reference')))
                                      )
                                ).h('div.field',
                                    h.h('label.label','Tax Payer').
                                      h('div.frame group',
                                        h.h('input', h.attrs(name => 'contractor.tax_payer_id', value => h.G('tax_payer_id')))
                                      )
                                )
                              ).
                              h('div.row group',
                                h.h('div.field',
                                    h.h('label.label','Resident').
                                      h('div.frame group',
                                        h.h('input', h.attrs(name => 'contractor.resident', value => h.G('resident')))
                                      )
                                )
                              )
                          )
                      )
                  )
  );   
  --
  --ROLES
  --
            
  owner  := b.role('Owner', b.fn('prepare_owner'));
  owner := owner.page(b.page('Welcome')).
                   is_when(b.fn('when_welcome'))
                .page(b.page('ContractorInfo')).
                   is_when(b.fn('when_contractor_info'))
                .page(b.page('ContractorEdit')).
                   is_when(b.fn('when_contractor_edit'));
  --
  owner.set_par('filter','ALL');
  --
  owner.is_when(
    b.fn('state_is_empty'),
    xxdoo.xxdoo_bk_pages_typ(
      b.page('Welcome'),
      b.page('ContractorInfo')
    )
  );
  --
  b.role(owner);
  --
  /*b.role('Owner',
         xxdoo.xxdoo_bk_role_pages_typ(
           b.role_page('Welcome')
            -- Maybe rename condition_method to when
            .condition_method(b.fn('welcome_condition')),
           b.role_page('Contractors')
            .condition_method(b.fn('contractors_condition'))
         )
        );--*/
  --
  -- TOOLBAR
  --
  b.create_toolbar(
    xxdoo.xxdoo_bk_buttons_typ(
      b.button('New')
    )
  );
  --
  h.init;
  b.toolbar.set_html(
    h.each('buttons', 
           h.h('a.button', 
             h.attr('href','#').
               attr('data-callback',b.callback(b.fn('cb_contractor_new'))).
               attr('data-action',b.get_service_url), 
             h.G('name')
           )
    )
  );
  --
  -- Sidebar
  --
  h.init;
  --
  b.template(p_name        => 'sidebar',
             p_html        => h.each(h.h('li.item', 
                                     h.attr('data-id',h.G('id')).
                                       attr('data-callback',
                                            b.callback(b.fn('sidebar_element'))).
                                       attr('data-action',b.get_service_url).
                                       attr('data-sync','Y').
                                       attr('data-meta','callback'), 
                                     h.G('name'))),-- h.text('NAME: ').text(h.G('name')))),
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
1
self.entity.name
