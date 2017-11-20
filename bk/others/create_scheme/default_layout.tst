PL/SQL Developer Test script 3.0
186
declare
  --
  --service_name varchar2(30) := 'test';
  o xxdoo.xxdoo_html := xxdoo.xxdoo_html(p_appl_name  => 'others',
                                        p_src_owner  => 'xxdoo',
                                        p_src_object => 'xxdoo_bk_book_typ',
                                        p_appl_code  => 'xxdoo_bk');
  --
  h xxdoo.xxdoo_html := xxdoo.xxdoo_html();
  b xxdoo.xxdoo_html := xxdoo.xxdoo_html();
  t xxdoo.xxdoo_html := xxdoo.xxdoo_html();
  --
  l_result   varchar2(400);
begin
  --
  h := h.h('head',
         h.h('meta',h.attr('apple-mobile-web-app-capable','yes')).
           h('meta',h.attr('apple-mobile-web-app-status-bar-style','black')).
           h('meta',h.attr('viewport','width=device-width, initial-scale=1.0, user-scalable=no')).
           h('meta',h.attrs(http_equiv => 'X-UA-Compatible', content => 'IE=edge,chrome=1', charset => 'utf-8')).
           h('title',h.G('title')).
           h('link',h.attrs(href => 'css/noodoo-ui.css?', rel => 'stylesheet')).
           h('link',h.attrs(href => h.G('name'), rel => 'stylesheet')).
           h('link',h.attrs(href => 'images/ipad_icon.png', rel => 'apple-touch-icon'))
  );
  --h('div#toolbar.buttons', G('buttons'))
  t := t.h('div#toolbar.buttons', t.G('buttons'));
  --
  b := b.h('body',b.attr('data-book',b.G('name')),
         b.h('header.header',
           b.h(t).
           h('div.search',
             b.h('input', b.attrs(type => 'text', name => 'query', value => b.G('search')))
           )--.
           --h('ul#folders.filter', folders)
         ).
         h('div.sidebar',
            b.h('ol#entries.list', 
              b.attr('tabindex','0').
              attr('data-behavior', 'list').
              attr('data-asset', b.G('contentId'))
            )
         ).
         h('div#content.content').
         h('script',b.attr('src',b.G('get_js_link')))
  );
  --
  o := o.h('html',
           o.h(h).
             h(b)
          );
  --
  o.prepare;
  o.application.package.method_html := 'layout';
  o.create_fn_html;
  --
  --l_result := o.create_pkg;
  dbms_output.put_line(o.application.package.methods(1).get_method_spc);
  dbms_output.put_line(o.application.package.methods(1).get_method);
  return;
  
  
  /*
  
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
  
  
  */
  o := o.h('form#content',
           o.h('div.form'));
  o.prepare;
    o.application.package.method_html := xxdoo_html_utils_pkg.g_fn_html;
    o.create_fn_html;
  l_result := o.create_pkg;
  --dbms_output.put_line();
  --o.prepare;
  --o.application.save;
  return;
  --
  /*
 -- xxdoo.XXSL_DC_PKG
  h := h.h('head',
               h.h('meta',h.attrs(http_equiv => 'Content-Type', content => 'text/html', charset => 'ISO-8859-1')).
                 h('title',h.G('title')).
                 h('style',h.attrs(type => 'text/css'), h.G('style')).
                 h('script',h.attrs(type => 'text/javascript'), h.G('script')) --
             );
  --
  f := f.h('form#content',
           f.h('div.form',
               f.h('table.params',
                    f.h('tr.pst',
                        f.h('td',
                            f.text('Deal number:').
                              h('input', h.attrs(type => 'text', name => 'deal', value => h.G('deal')))
                           ).
                          h('td',
                            f.text('Shipment number:').
                              h('input', h.attrs(type => 'text', name => 'shipment', value => h.G('shipment')))
                           ).
                          h('td',
                            f.text('Operation id:').
                              h('input', h.attrs(type => 'text', name => 'operation_id',    value => h.G('operation_id')))
                           ).
                          h('td',
                            f.h('button', h.attrs(data_action => f.callbacks('find')),'SUBMIT')
                             )
                       )
                   )
              )
          );
  --
  t := t.h('table.deals',
           t.h('tr',
               t.h('th','Deals').
                 h('th','Shipments').
                 h('th','Operations').
                 h('th','Company').
                 h('th','Event').
                 h('th','Created At').
                 h('th','Status').
                 h('th','Messages').
                 h('th','Controls')
              ).
             each('lines',
                  t.h('tr',
                      t.h('td',t.attrs(class => h.G('class_deal'),rowspan => h.G('deal_cnt')),h.G('deal_number')).
                        h('td',t.attrs(class => h.G('class_shipment'),rowspan => h.G('shipment_cnt')),h.G('shipment_num')).
                        h('td',t.attrs(class => h.G('class_operation'), rowspan => h.G('operation_cnt')),h.G('operation_id')).
                        h('td',h.G('company_code')).
                        h('td',h.G('event_name')).
                        h('td',h.G('creation_date')).
                        h('td',t.attrs(class => 'status_class'),h.G('status_as_string')).
                        h('td',t.text(chr(38)||'nbsp;').
                                 h('a',t.attrs(onclick => h.G('onclick_in_xml'),href => '""'),'In XML').
                                 text(chr(38)||'nbsp;').
                                 h('a',t.attrs(onclick => h.G('onclick_out_xml'),href => '""'),'Out XML')
                         ).
                        h('td',
                          t.h('button',t.attrs(class => h.G('redo_class'), onclick => h.G('onclick_invoke')),'Redo') --is_hide_redo
                         )
                     )
                 )
          );
  --
  b := b.h('body',o.attrs(data_book => service_name),
           b.h('div.body',
               b.h('h1#banner', b.G('title')).
               h('div.bd',
                 b.h(f).
                   h(t)
                )
              )
          ); --
  --
  o := o.h('html',
           o.h(h).
             h(b)
          );
  --
  
  l_result := o.create_appl;
  --l_result := o.create_pkg;
  --o.compile;
  --l_result := o.create_appl;
  dbms_output.put_line(l_result);
  o.application.save;
  --o.application.save; --*/
end;
0
3
m
m
l_member.data_type
