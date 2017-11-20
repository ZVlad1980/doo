PL/SQL Developer Test script 3.0
56
-- Created on 11.07.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  i integer;
  t xxdoo.xxdoo_db_scheme_typ := xxdoo.xxdoo_db_scheme_typ(p_name => 'TEST', p_dev_code => 'xxtst_a001', p_owner => 'xxdoo');
  --f xxdoo.xxdoo_db_field_typ := xxdoo.xxdoo_db_field_typ();
  --
  function get_xml(s xxdoo.xxdoo_db_scheme_typ) return xmltype is
    l_result xmltype;
  begin
    select xmlroot(xmltype.createxml(s), version 1.0)
    into l_result
    from dual;
    --
    return l_result;
  end;
begin
 --dbms_session.reset_package;
  xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  --dbms_output.put_line(get_xml(s).getStringVal);
-- /*
  t.ctable('testRefs', 'a b c');
  
  t.ctable('items', 
           xxdoo.xxdoo_db_fields_typ(
             t.f('id',            t.cint().csequence().pk),
             t.f('ref_id',        t.indexed().tables('testRefs').updated('CASCADE')),
             t.f('parent_id',     t.self().referenced('items')),
             t.f('state',         t.cvarchar(10).cdefault('NEW')),
             t.f('name',          t.cvarchar(20).cunique),
             t.f('quantity',      t.cnumber(10,2).cdefault(1)),
             t.f('creation_date', t.ctimestamp().cdefault('timestamp'))
           )
  );
  --
  t.ctable('ItemsWhs', 
          xxdoo.xxdoo_db_fields_typ(
             t.f('id',      t.cint().csequence().pk),
             t.f('item_id', t.tables('items').referenced('Warehouses').updated('CASCADE'))
          )
  );
  --
  t.put; 
  t.get(t.id);
  --return; --*/
  xxdoo.xxdoo_db_engine_pkg.drop_objects(t);
  xxdoo.xxdoo_db_engine_pkg.generate_objects(t);
  --dbms_output.put_line(get_xml(t).getStringVal);
  --
exception 
  when others then
    xxdoo.xxdoo_db_utils_pkg.fix_exception;
    xxdoo.xxdoo_db_utils_pkg.show_errors;
    --
  -- dbms_output.put_line(get_xml(t).getStringVal);
end;
0
1
p_entity.name
