PL/SQL Developer Test script 3.0
14
select * from xxdoo.xxdoo_db_scripts_t /*
-- Created on 08.08.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  i integer;
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  xxdoo.xxdoo_db_engine_pkg.generate_scripts(p_scheme_name => 'Books');
exception 
  when others then
    xxdoo.xxdoo_db_utils_pkg.fix_exception;
    xxdoo.xxdoo_db_utils_pkg.show_errors;
end; --*/
0
0
