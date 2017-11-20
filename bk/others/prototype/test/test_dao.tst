PL/SQL Developer Test script 3.0
95
declare
  a anydata;
  obj xxdoo.xxdoo_cntr_contractor_typ;
  coll xxdoo.xxdoo_cntr_contractors_typ;
  l_dummy pls_integer;
  dao xxdoo.xxdoo_db_dao;
  x xmltype := xmltype('<content>
    <id></id>
    <name>IBM</name>
    <type>Vendor</type>
    <sites>
      <site>
        <id>1</id>
        <contractor_id>1</contractor_id>
        <role>Ship to</role>
        <address_id>
          <id>1</id>
          <country>
            <id>RU</id>
            <name>Russian Federation</name>
            <localizedName>Russia</localizedName>
          </country>
          <postal_code>111111</postal_code>
          <addr_line>Moscow</addr_line>
        </address_id>
        <siteAccounts>
          <siteAccount>
            <id>1</id>
            <accountId>
              <id>1</id>
              <siteId>1</siteId>
              <accountNum>10101010101</accountNum>
            </accountId>
            <siteId>1</siteId>
          </siteAccount>
        </siteAccounts>
      </site>
      <site>
        <id>2</id>
        <contractor_id>1</contractor_id>
        <role>Bill to</role>
        <address_id>
          <id>1</id>
          <country>
            <id>RU</id>
            <name>Russian Federation</name>
            <localizedName>Russia</localizedName>
          </country>
          <postal_code>111111</postal_code>
          <addr_line>Moscow</addr_line>
        </address_id>
        <accounts/>
      </site>
    </sites>
  </content>
  ');

begin
  xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('Object');
  obj := xxdoo.xxdoo_cntr_contractor_typ();
  dao := xxdoo.xxdoo_db_dao(obj);
  --obj := xxdoo.xxdoo_cntr_contractor_typ(dao.get_object(1));
  --dbms_output.put_line(xmltype.createxml(obj).getClobVal);
  --return;
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('Load');
  obj := xxdoo_cntr_contractor_typ(dao.load(x));
  dbms_output.put_line(xmltype.createxml(obj).getClobVal);
  --return;
  obj.name := case
                when obj.name = 'XEROX' then
                  'Lenovo'
                else
                  'XEROX'
              end;
  dao.put(obj.get_anydata);
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('Put name '||obj.name);
  --
  dbms_output.put_line(rpad('-',30,'-'));
  dbms_output.put_line('Collection');
  dao.query.w('rownum',3,'<');
  dao.query.o('name');
  a := dao.get;
  l_dummy := a.getCollection(coll);
  for i in 1..coll.count loop
    dbms_output.put_line(xmltype.createxml(coll(i)).getClobVal);
  end loop;
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception('O-oops');
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
0
