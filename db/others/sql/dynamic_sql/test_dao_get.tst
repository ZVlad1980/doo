PL/SQL Developer Test script 3.0
71
declare
  a anydata;
  obj xxdoo.xxdoo_cntr_contractor_typ;
  coll xxdoo.xxdoo_cntr_contractors_typ;
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
begin
  --dbms_session.reset_package; return;
  --dbms_output.put_line(rpad('-',30,'-'));
  --dbms_output.put_line('Object');
  xxdoo_db_utils_pkg.init_exceptions;
  obj := xxdoo.xxdoo_cntr_contractor_typ();
  dao := xxdoo.xxdoo_db_dao(obj);
  dao.query.w('id','668720');
  dbms_output.put_line(dao.get_query(false));
  l_start_time := current_timestamp;
  a := dao.get(false);
  dbms_output.put_line('Selected time = ' || regexp_substr(to_char(current_timestamp - l_start_time),'[^ ]+',1,2));
  --dbms_output.put_line(get_xml(a).getStringVal);
  l_start_time := current_timestamp;
  l_dummy := a.getObject(obj);
  dbms_output.put_line('Convert time = ' || regexp_substr(to_char(current_timestamp - l_start_time),'[^ ]+',1,2));
  /*for i in 1..coll.count loop
    dbms_output.put_line(coll(i).name);
  end loop; 
  /*
  a := anydata.ConvertObject(obj);
  
  obj := xxdoo.xxdoo_cntr_contractor_typ(dao.get_object(1));
  dbms_output.put_line(xmltype.createxml(obj).getClobVal);
  --return;
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('Load');
  a := dao.load(x);
  obj := xxdoo.xxdoo_cntr_contractor_typ(a);
  dbms_output.put_line(xmltype.createxml(obj).getClobVal);
  obj.name := case
                when obj.name = 'XEROX' then
                  'Lenovo'
                else
                  'XEROX'
              end;
  dao.put(obj.get_anydata);
  --
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('Collection');
  dao.query.w('rownum',3,'<');
  dao.query.o('name');
  a := dao.get;
  l_dummy := a.getCollection(coll);
  for i in 1..coll.count loop
    dbms_output.put_line(xmltype.createxml(coll(i)).getClobVal);
  end loop;  --*/
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
1
l_sql
