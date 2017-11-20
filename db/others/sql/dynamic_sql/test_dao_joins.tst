PL/SQL Developer Test script 3.0
45
declare
  a anydata;
  obj  xxdoo.xxdoo_cntr_bank_account_typ;
  coll xxdoo.xxdoo_cntr_bank_accounts_typ;
  l_dummy pls_integer;
  dao xxdoo.xxdoo_db_dao;
  l_start_time timestamp;
  --
  function get_xml(s in out nocopy xxdoo.xxdoo_db_dao) return xmltype is
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
  --dbms_output.put_line(rpad('-',30,'-'));
  --dbms_output.put_line('Object');
  xxdoo.xxdoo_utl_pkg.init_exceptions;
  --
  obj := xxdoo.xxdoo_cntr_bank_account_typ();
  dao := xxdoo.xxdoo_db_dao(obj);
  --dbms_output.put_line(get_xml(dao).getStringVal);
  --dao.query.o('site_number');
  --dao.query.o('address_id.postal_code');
  dao.query.init;
  dao.query.w('currency.id','LTL');
  dao.query.w('currency_sec','LTL');
  dao.query.o('currency_sec.id');
  dbms_output.put_line(dao.get_query(true));
  --return;
  a := dao.get_all(true);
  l_dummy := a.GetCollection(coll);
  for i in 1..coll.count loop
    dbms_output.put_line(coll(i).name);
  end loop;
  return;
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
1
l_sql
