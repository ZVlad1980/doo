PL/SQL Developer Test script 3.0
433
-- Created on 15.08.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  b xxdoo.xxdoo_bk_book_typ;
  --
  h xxdoo.xxdoo_html;
  t xxdoo.xxdoo_html;
  --
  tbl xxdoo.xxdoo_dsl_table;
  plc xxdoo.xxdoo_html;
  p xxdoo.xxdoo_dsl_page;
  --
  owner  xxdoo.xxdoo_bk_role_typ;
  --
begin
  --dbms_session.reset_package; return;
  --
  h := xxdoo.xxdoo_html();
  t := xxdoo.xxdoo_html();
  --
  b := xxdoo.xxdoo_bk_book_typ(p_name     => 'journals',
                               p_scheme   => 'xxdoo_edu',
                               p_table    => 'journal',
                               p_package  => 'xxdoo_edu_pkg',
                               p_path     => ':filter/:journal(\d+)?/:state?/st/:student(\d+)',--:journals(\d+)
                               p_title    => 'Journals'
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
  t := t.h('body',t.attrs(data_book => t.G('name')),
         t.h('div.wrapper',
           t.h('header.header',
             t.h('div#toolbar.buttons', t.G('get_toolbar')).
             h('div.search',
               t.h('input', t.attrs(type => 'text', name => 'query', value => t.G('search')))
             )
           ).
           h('div#sidebar.sidebar',t.G('get_sidebar')
           ).
           h('form#content.content',t.G('get_content'))
         ).
         h('script',t.attrs(src => t.G('get_js_link')))
  );
  --<ol tabindex="0" data-behavior="list" data-asset="305" class="list" id="entries">
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
  --  JournalView
  --
  tbl := xxdoo.xxdoo_dsl_table();
  plc := xxdoo.xxdoo_html();
  --
  h.init;
  --
  plc := h.h('div',h.h('p','Journal is empty'));
  h.init;
  tbl.ctable(
    p_caption     => 'Journal entries', 
    p_rows        => xxdoo.xxdoo_dsl_tbl_row('entries'),
    p_columns     => tbl.ccolumn(p_name => 'Name',       p_content => h.within('student',h.text(h.G('last_name')||' ' ||h.G('name')))).
                         ccolumn(p_name => 'Discipline', p_content => h.G('discipline.full_name')).
                         ccolumn(p_name => 'Grade',      p_content => h.G('grade')),
    p_placeholder => plc
  );
  --
  h.init;
  p := xxdoo.xxdoo_dsl_page();	
  p.page(
    p_name    => 'Test',
    p_header  => 
      xxdoo.xxdoo_dsl_header(
        p_message => 'Journal info',
        p_toolbar => 
          xxdoo.xxdoo_dsl_toolbar(
            xxdoo.xxdoo_dsl_buttons(
              xxdoo.xxdoo_dsl_button(
                p_label     => 'Overview',
                p_callback  => b.callback(b.fn('overview'))
              )
            )
          )
      ),
    p_summary => 
      xxdoo.xxdoo_dsl_summary(
        xxdoo.xxdoo_dsl_terms(
          xxdoo.xxdoo_dsl_term(
            p_term  => 'Journal: ',
            p_value => p.G('name')
          ),
          xxdoo.xxdoo_dsl_term(
            p_term  => '  Count of entry: ',
            p_value => p.G(b.handler(b.fn('get_entires_qty')))
          )
        )
      ),
    p_content => h.h('div.sheet',
                   h.h(tbl.h)
                  )
  );
  --
  b.page(
    p_name     => 'JournalView',
    p_html     => p.h
  );
  --
  --
  --  ContractorEdit
  --
  h.init;
  --b.page(p_page => xxdoo_dsl_page);
  b.page(
    p_name     => 'JournalEdit',
    p_html     => h.h('div.sheet',
                      h.h('header.title group',
                          h.h('div.buttons',
                            h.h('a.button primary', 
                                h.attrs(href => '#', data_sync => 'Y', data_meta => 'journal.entries.diapazon:1-50', 
                                        data_action => b.callback(b.fn('journal_save_cb'))),
                                'Save')/*.
                              h('a.button', 
                                h.attr('href','#').
                                  attr('data-sync','Y').
                                  attr('data-action',b.callback(b.fn('cb_contractor_discard'))),
                                'Discard changes')--*/
                          )  --*/
                      ).  
                      h('div.form grid',
                        h.h('div',
                              h.text('Journal: ').
                              h('input',  h.attrs(type => 'hidden', name => 'journal.id', value => h.G('id'))).
                              h('input',  h.attrs(type => 'text', name => 'journal.name', value => h.G('name'))) --hidden text
                                --h('span.info',h.G('name'))
                        ).
                          h('fieldset.cols-4', 
                            h.h('legend','Journal entries').
                              h('fieldset.tabular cols-4',
                                h.h('div.row group',
                                    h.h('div.field rows-2',
                                        h.when#(b.handler(b.fn('when_test')),
                                                h.h('label.label','Name').
                                                  h('div.frame')).
                                          when#(b.handler(b.fn('when_test2')),
                                                h.h('label.label','Èìÿ').
                                                  h('div.frame'))
                                    ).
                                    h('div.field rows-2',
                                      h.h('label.label','Discipline').
                                        h('div.frame')).
                                    h('div.field rows-2',
                                      h.h('label.label','Grade').
                                        h('div.frame')).
                                    h('div.field rows-2',
                                      h.h('label.label','Manage').
                                        h('div.frame'))
                                ).
                                h('div.collection',
                                  h.each('entries',
                                    h.h('input',  h.attrs(type => 'hidden', name => 'journal.entries.'||h.G('#position')||'.id', value => h.G('id'))).--hidden
                                      h('fieldset.cols-4',
                                        h.h('div.row group',
                                          h.h('div.field',
                                              h.h('div.frame',
                                                h.h('input', h.attrs(type => 'text', name => 'journal.entries.'||h.G('#position')||'.student.name', value => h.G('student.name'), placeholder => 'Zhuravov',data_behavior => 'suggest')).
                                                  h('input', h.attrs(type => 'hidden', name => 'journal.entries.'||h.G('#position')||'.student.id', value => h.G('student.id'))).
                                                  h('div.flyout',
                                                    h.h('ul.modal', h.attrs(data_behavior => 'list', data_source => b.callback(b.fn('list_students_cb'))))
                                                  )
                                              )
                                            ).
                                            h('div.field',
                                              h.h('div.frame', --h.condition(b.handler(b.fn('is_error_discpl'))
                                                h.h('input', h.attrs(type => 'text', name => 'journal.entries.'||h.G('#position')||'.discipline.name', value => h.G('discipline.name'), placeholder => 'Informatics',data_behavior => 'suggest')).
                                                  h('input', h.attrs(type => 'hidden', name => 'journal.entries.'||h.G('#position')||'.discipline.id', value => h.G('discipline.id'))).
                                                  h('div.flyout',
                                                    h.h('ul.modal', h.attrs(data_behavior => 'list', data_source => b.callback(b.fn('list_disciplines_cb'))))
                                                  )
                                              )
                                            ).
                                            h('div.field',
                                              h.h('div.frame',
                                                h.h('input', h.attrs(type => 'text', name => 'journal.entries.'||h.G('#position')||'.grade', value => h.G('grade'), placeholder => '5'))
                                              )
                                            ).
                                            h('div.field',
                                              h.h('div.buttons#toolbar', --
                                                h.h('a.button', h.attrs(data_action => b.callback(b.fn('journal_entry_new_cb')), data_sync => 'Y'),'+').
                                                  h('a.button', h.attrs(data_action => b.callback(b.fn('journal_entry_delete_cb')), data_sync => 'Y', data_meta => 'journal.entries.'||h.G('#position')),'-').
                                                  h('a.button', h.attrs(data_action => b.callback(b.fn('student_select')), data_sync => 'Y', data_meta => 'journal.entries.'||h.G('#position')),'Student')
                                              )
                                            )
                                        )
                                      )
                                  )
                                )
                              )
                          )
                        )
                 )
  );   
  --
  --
  --  Student edit
  --
  h.init;
  p := xxdoo.xxdoo_dsl_page();	
  p.page(
    p_name    => 'StudentEdit',
    p_header  => 
      xxdoo.xxdoo_dsl_header(
        p_message => 'Student edit',
        p_toolbar => 
          xxdoo.xxdoo_dsl_toolbar(
            xxdoo.xxdoo_dsl_buttons(
              xxdoo.xxdoo_dsl_button(
                p_label     => 'Overview',
                p_callback  => b.callback(b.fn('overview'))
              )
            )
          )
      ),
    p_summary => 
      xxdoo.xxdoo_dsl_summary(
        xxdoo.xxdoo_dsl_terms(
          xxdoo.xxdoo_dsl_term(
            p_term  => 'Student: ',
            p_value => h.G('name')
          )
        )
      ),
    p_content => h.h('div.form grid',
                        h.h('div',
                            h.h('input',  h.attrs(type => 'hidden', name => 'student.id', value => h.G('id')))
                        ).h('fieldset.cols-2', 
                          h.h('legend','General').
                            h('div.row group',
                            h.h('div.field',
                              h.h('label.label','Name: ').
                                h('div.frame',
                                 h.h('input',  h.attrs(type => 'text', name => 'student.name', value => h.G('name')))
                                )
                             ).
                              h('div.field',
                              h.h('label.label','Last Name: ').
                                h('div.frame',
                                 h.h('input',  h.attrs(type => 'text', name => 'student.last_name', value => h.G('last_name')))
                                )
                              )
                            ).
                            h('div.row group',
                            h.h('div.field',
                              h.h('label.label','Sex: ').
                                h('div.frame',
                                 h.h('input',  h.attrs(type => 'text', name => 'student.sex.code', value => h.G('sex.code')))
                                )
                             ).
                              h('div.field',
                              h.h('label.label','Birth Day: ').
                                h('div.frame',
                                 h.h('input',  h.attrs(type => 'text', name => 'student.birth_day', value => h.G('birth_day')))
                                )
                              )
                            )
                        )
                  )
  );
  --
  b.page(
    p_name        => 'StudentEdit',
    p_html        => p.h,
    p_entity_name => 'students'
  );
  --
  --ROLES
  --*/
            
  owner  := b.role('Owner', b.fn('prepare_owner'));
  owner := owner.page(b.page('Welcome')).
                   is_when(b.fn('when_welcome'))
                .page(b.page('JournalEdit')).
                   is_when(b.fn('when_journal_edit'))
                .page(b.page('JournalView')).
                   is_when(b.fn('when_journal_view'))
                .page(b.page('StudentEdit')).
                   is_when(b.fn('when_student_edit'))--*/
                   ;
  --
  owner.set_par('filter','ALL');
  --
  owner.is_when(
    b.fn('state_is_empty'),
    xxdoo.xxdoo_bk_pages_typ(
      b.page('Welcome')
    )
  );
  --
  b.role(owner);
  --
  -- TOOLBAR
  --
  /*b.create_toolbar(
    xxdoo.xxdoo_bk_buttons_typ(
      b.button('New')
    )
  );
  --
  h.init;
  b.toolbar.set_html(
    h.each('buttons', 
           h.h('a.button', 
             h.attrs(href => '#', data_action => b.callback(b.fn('journal_new_cb')), data_sync => 'Y'), 
             h.text('New journal')--G('name')
           )
    )
  ); --*/
  b.create_toolbar(
    xxdoo.xxdoo_dsl_toolbar(
      xxdoo.xxdoo_dsl_buttons(
        xxdoo.xxdoo_dsl_button(
          p_label     => 'New journal',
          p_callback  => b.callback(b.fn('journal_new_cb'))
        )
      )
    )
  );
  
  --
  -- Sidebar
  --
  h.init;
  --
  b.template(p_name        => 'sidebar',
             p_html        => h.h(
               'ol#entries.list',
               h.attrs(tabindex => '0', data_behavior => 'list', data_source => b.callback(b.fn('sidebar_scroll'))),
               h.each(
                                h.h('li.item', 
                                  h.attrs(data_id => h.G('id')),
                                  h.h('a',
                                    h.h('div.group title',
                                      h.h('span','Journal name: ').
                                        h('span.product',
                                          h.attrs(data_action => b.callback(b.fn('sidebar_select_cb')), data_sync => 'Y',
                                                  data_meta =>'journals.id.'||h.G('id')),
                                          h.G('name'))
                                    )
                                  )
                                )
                              )),
             p_source_name => 'journals');
  --
  --
  -- List of students
  --
  h.init;
  --
  b.template(p_name        => 'students',
             p_html        => h.each(
                                h.h('li', 
                                  h.attrs(data_id => h.G('id')),
                                  h.G('name') || ' ' || h.G('last_name')
                                )
                              ),
             p_source_name => 'students');
  --
  --
  -- List of disciplines
  --
  h.init;
  --
  b.template(p_name        => 'disciplines',
             p_html        => h.each(
                                h.h('li', 
                                  h.attrs(data_id => h.G('id'), data_value => h.G('name')),
                                  h.G('full_name')
                                )
                              ),
             p_source_name => 'disciplines');
  --
  /*
  <li data-id="62297" class="item">
               <a>
                  <div class="group by-side reference"><span>#D-622970/02.04.2015</span><span>Requested</span></div>
                  <div class="group by-side title"><span class="product">SETRASPED SPA</span><span class="quantity"></span></div>
                  <div class="group">Ravenna, Setrasped</div>
                  <div class="group by-side"><span>Truck Canvas, 1 x Consigments</span><span>02.04.2015</span></div>
               </a>
            </li>
  */
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
4
self.entity.name
l_attrs_string
l_name
p_source
