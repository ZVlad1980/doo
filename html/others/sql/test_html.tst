PL/SQL Developer Test script 3.0
16
-- Created on 10.09.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  h xxdoo.xxdoo_html := xxdoo.xxdoo_html('xxdoo','xxdoo_cntr_contractor_typ');
  m clob;
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  h := h.h('p',h.G('name')).each('sites',h.h('p',h.G('name')));
  m := h.get_method;
  dbms_output.put_line(m);
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
0
