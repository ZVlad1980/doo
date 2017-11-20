PL/SQL Developer Test script 3.0
80
declare
  a anydata;
  obj  xxdoo.xxdoo_cntr_site_typ;
  coll xxdoo.xxdoo_cntr_sites_typ;
  l_dummy pls_integer;
  dao xxdoo.xxdoo_db_dao;
  l_start_time timestamp;
  --
  function get_xml(a anydata) return xmltype is
    l_result xmltype;
  begin
    l_dummy := a.getObject(obj);
    select xmlroot(xmltype.createxml(obj), version 1.0)
    into l_result
    from dual;
    --
    return l_result;
  end;
  --
  procedure show_coll(a anydata) is
  begin
    l_dummy := a.getCollection(coll);
    for i in 1..coll.count loop
      dbms_output.put_line(coll(i).site_number || ' - ' || coll(i).address_id.postal_code);
    end loop;
  end;
begin
  --dbms_session.reset_package; return;
  --
  --dbms_output.put_line('Object');
  xxdoo.xxdoo_utl_pkg.init_exceptions;
  --
  obj := xxdoo.xxdoo_cntr_site_typ();
  dao := xxdoo.xxdoo_db_dao(obj);
  --dbms_output.put_line(get_xml(dao).getStringVal);
  --dao.query.o('site_number');
  --dao.query.o('address_id.postal_code');
  dao.query.init;
  dao.query.w('address_id.country.iso_code','LTU');
  dao.query.w('address_id.city','Vilnius','=');
  dao.query.o('address_id.postal_code');
  dao.query.o('site_number');
  --dao.query.from_row(1);
  --dao.query.to_row(10);
  --dbms_output.put_line(dao.get_query(false));
  --return;
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('  order by postal_code, site_number');
  dbms_output.put_line(rpad('-',30,'-'));
  show_coll(dao.get_all(true));
  --
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('  get object ');
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line(get_xml(dao.get).getStringVal);
  --
  --
  --
  dao.query.init;
  dao.query.w('address_id.country.iso_code','LTU');
  dao.query.w('address_id.city','Vilnius','=');
  dao.query.o('site_number');
  dao.query.o('address_id.postal_code');
  --
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('  order by site_number, postal_code');
  dbms_output.put_line(rpad('-',30,'-'));
  show_coll(dao.get_all(true));
  --
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('  get object ');
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line(get_xml(dao.get).getStringVal);
  
  return;
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
1
l_sql
