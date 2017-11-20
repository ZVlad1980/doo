PL/SQL Developer Test script 3.0
25
-- Created on 21.04.2015 by ZHURAVOV_VB 
declare 
  -- Local variables here
  t xxdoo.xxdoo_dsl_table;
  h xxdoo.xxdoo_html;
  p xxdoo.xxdoo_html;
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  t := xxdoo.xxdoo_dsl_table();
  h := xxdoo.xxdoo_html();
  p := xxdoo.xxdoo_html();
  p := h.h('div',h.h('p','Collection is empty'));
  t.ctable(p_caption     => 'TEST', 
           p_rows        => xxdoo.xxdoo_dsl_tbl_row(xxdoo.xxdoo_html_source_typ(owner => 'xxdoo', name => 'xxdoo_edu_entries_typ')),
           p_columns     => t.ccolumn(p_name => 'Column1', p_content => h.h('div',h.h('p','test'))).
                              ccolumn(p_name => 'Column2', p_content => h.h('div',h.h('p','test2'))),
           p_placeholder => p
  );
  dbms_output.put_line(t.h.get_method);      
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
0
