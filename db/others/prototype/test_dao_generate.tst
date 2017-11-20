PL/SQL Developer Test script 3.0
34
-- Created on 11.07.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  i integer;
  --t xxdoo.xxdoo_db_scheme_typ := xxdoo.xxdoo_db_scheme_typ(p_name => 'TEST', p_dev_code => 'test', p_owner => 'xxdoo');
  s xxdoo.xxdoo_db_scheme_typ := xxdoo.xxdoo_db_scheme_typ(p_name => 'Contractors', p_dev_code => null, p_owner => null);
  l_prg xxdoo.xxdoo_db_prgPackage_typ;
  --f xxdoo.xxdoo_db_field_typ := xxdoo.xxdoo_db_field_typ();
  --
  function get_xml(s xxdoo.xxdoo_db_prgPackage_typ) return xmltype is
    l_result xmltype;
  begin
    select xmlroot(xmltype.createxml(s), version 1.0)
    into l_result
    from dual;
    --
    return l_result;
  end;
begin
  --dbms_session.reset_package; return;
  xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  l_prg := xxdoo.xxdoo_db_dao_generator_pkg.dao_generate(p_scheme => s, p_main_entity_name => 'contractors');
  --dbms_output.put_line(get_xml(l_prg).getStringVal);
  --dbms_output.put_line(l_prg.methods(1).body);
  l_prg.create_ddl;
  dbms_output.put_line(l_prg.specification);
  dbms_output.put_line('/');
  dbms_output.put_line(l_prg.body);
  --
exception 
  when others then
    xxdoo.xxdoo_db_utils_pkg.fix_exception;
    xxdoo.xxdoo_db_utils_pkg.show_errors;
end;
0
1
instr(p_entity_name,'/')+1
