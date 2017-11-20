PL/SQL Developer Test script 3.0
116
declare
  --
  service_name varchar2(30) := 'test';
  o xxweb.xxweb_api := xxweb.xxweb_api(p_appl_name  => service_name,
                                         p_src_owner  => 'xxsl',
                                         p_src_object => 'xxsl_dc_db_hdr_type',
                                         p_appl_code  => 'xxsl_dc');
  --
  h xxweb.xxweb_api := xxweb.xxweb_api();
  f xxweb.xxweb_api := xxweb.xxweb_api();
  b xxweb.xxweb_api := xxweb.xxweb_api();
  t xxweb.xxweb_api := xxweb.xxweb_api();
  --
  l_result   varchar2(400);
begin
  --
  /*o := o.h('form#content',
           o.h('div.form'));
  l_result := o.create_pkg;
  --o.prepare;
  o.application.save;
  return;
  --*/
 -- XXWEB.XXSL_DC_PKG
  h := h.h('head',
               h.h('meta',h.attrs(http_equiv => 'Content-Type', content => 'text/html', charset => 'ISO-8859-1')).
                 h('title',h.G('title')).
                 h('style',h.attrs(type => 'text/css'), h.G('style')).
                 h('script',h.attrs(type => 'text/javascript'), h.G('script')) --*/
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
  /*for e in 1..o.elements.count loop
    dbms_output.put_line(o.elements(e).array_id || ' - ' || o.elements(e).id || ' - ' || o.elements(e).parent_id || ' / '||o.elements(e).as_string);
  end loop; --*/
  --o.prepare;
  
  l_result := o.create_appl;
  --l_result := o.create_pkg;
  --o.compile;
  --l_result := o.create_appl;
  dbms_output.put_line(l_result);
  o.application.save;
  --o.application.save;
end;
0
3
m
m
l_member.data_type
