PL/SQL Developer Test script 3.0
234
-- Created on 31.07.2014 by ZHURAVOV_VB 
declare
  -- Local variables here
  i  integer;
  cc  xxdoo.xxdoo_cntr_contractors_typ := xxdoo.xxdoo_cntr_contractors_typ();
  xx xmltype;
  l_cursor sys_refcursor;
  l_entity_id number;
  --l_object anydata;
  --FULL
  /*
    x xmltype := xmltype('<content>
    <id>1</id>
    <name>Lenovo</name>
    <type>Vendor</type>
    <sites>
      <site>
        <id>1</id>
        <contractor_id>1</contractor_id>
        <role>Ship to</role>
        <address>
          <id>1</id>
          <country>
            <id>RU</id>
            <name>Russian Federation</name>
            <localizedName>Russia</localizedName>
          </country>
          <postal_code>111111</postal_code>
          <addr_line>Moscow</addr_line>
        </address>
        <siteAccounts>
          <siteAccount>
            <id>1</id>
            <bankAccount>
              <id>1</id>
              <siteId>1</siteId>
              <accountNum>10101010101</accountNum>
            </bankAccount>
            <siteId>1</siteId>
          </siteAccount>
        </siteAccounts>
      </site>
      <site>
        <id>2</id>
        <contractor_id>1</contractor_id>
        <role>Bill to</role>
        <address>
          <id>1</id>
          <country>
            <id>RU</id>
            <name>Russian Federation</name>
            <localizedName>Russia</localizedName>
          </country>
          <postal_code>111111</postal_code>
          <addr_line>Moscow</addr_line>
        </address>
        <accounts/>
      </site>
    </sites>
  </content>
  ');
  --*/
  --Only ID
  /*
  x xmltype := xmltype('<content>
    <id>1</id>
    <sites>
      <site>
        <id>1</id>
        <address>
          <id>1</id>
        </address>
        <siteAccounts>
          <siteAccount>
            <id>1</id>
            <bankAccount>
              <id>1</id>
            </bankAccount>
          </siteAccount>
        </siteAccounts>
      </site>
      <site>
        <id>2</id>
        <accounts/>
      </site>
    </sites>
  </content>
  ');--*/
  --New site/*
  x xmltype := xmltype('<content>
  <id></id>
  <name>Lenovo2</name>
  <type>Vendor</type>
  <sites>
    <site>
      <id></id>
      <contractor_id>1</contractor_id>
      <role>Ship to</role>
      <address>
        <id>1</id>
        <country>
          <id>RU</id>
          <name>russian Federation</name>
          <localizedName>Russia</localizedName>
        </country>
        <postal_code>111111</postal_code>
        <addr_line>Moscow</addr_line>
      </address>
      <siteAccounts>
        <siteAccount>
          <id></id>
          <siteId>1</siteId>
        </siteAccount>
      </siteAccounts>
    </site>
    <site>
      <id></id>
      <contractor_id>1</contractor_id>
      <role>Bill to</role>
      <address>
        <id>2</id>
      </address>
      <accounts/>
    </site>
    <site>
      <id></id>
      <contractor_id></contractor_id>
      <role>Ship to</role>
      <address>
        <id>2</id>
        <country>
          <id>US</id>
        </country>
      </address>
      <siteAccounts>
        <siteAccount>
          <id>1</id>
          <bankAccount>
            <id>1</id>
          </bankAccount>
        </siteAccount>
      </siteAccounts>
    </site>
  </sites>
</content>
'); --*/
begin
  --dbms_session.reset_package; return;
  --
  --PREPARE
  --
  select e.id
  into   l_entity_id
  from   xxdoo.xxdoo_db_schemes_t s,
         xxdoo.xxdoo_db_entities_t e
  where  1=1
  and    e.name = 'contractors'
  and    e.scheme_id = s.id
  and    s.name = 'Contractors';
  --
  --Get
  --
  cc.extend;
  cc(1) := xxdoo.xxdoo_cntr_contractor_typ(xxdoo.xxdoo_db_dao_pkg.get(p_entity_id => l_entity_id, p_id => 1));-- := xxdoo.xxdoo_cntr_contractors_pkg.load(x);
  select xmlroot(xmltype.createxml(cc(1)),
                 version 1.0)
  into   xx
  from   dual;
  --
  dbms_output.put_line(xx.getstringval);
  --return;
  
  --
  --
  -- LOAD
  
  --l_object := xxdoo_db_dao_pkg.load(p_entity_id => l_entity_id, p_xmlinfo => xx);
  --
  --cc.extend;
  cc(1) := xxdoo.xxdoo_cntr_contractor_typ(xxdoo.xxdoo_db_dao_pkg.load(p_entity_id => l_entity_id, p_xmlinfo => x));-- := xxdoo.xxdoo_cntr_contractors_pkg.load(x);
  --
  select xmlroot(xmltype.createxml(cc(1)),
                 version 1.0)
  into   xx
  from   dual;
  --
  dbms_output.put_line(xx.getstringval);
  --
  --PUT
  --
  dbms_output.put_line('PUT');
  xxdoo.xxdoo_db_dao_pkg.put(p_entity_id => l_entity_id, p_object => anydata.ConvertObject(cc(1)));
  return;
  --
  /*
  xxdoo.xxdoo_cntr_contractors_pkg.put(p_object => cc(1));
  --
  dbms_output.put_line('------------------------------------------------');
  dbms_output.put_line('--  After put');
  dbms_output.put_line('------------------------------------------------');
  select xmlroot(xmltype.createxml(cc(1)),
                 version 1.0)
  into   xx
  from   dual;
  dbms_output.put_line(xx.getstringval);
  --
  open l_cursor for
    select id
    from   xxdoo.xxdoo_cntr_contractors_t;
  --
  cc.extend;
  cc := xxdoo.xxdoo_cntr_contractors_pkg.get();
  
  dbms_output.put_line('------------------------------------------------');
  dbms_output.put_line('--  After get');
  dbms_output.put_line('------------------------------------------------');
  --
  for i in 1..cc.count loop
    select xmlroot(xmltype.createxml(cc(i)),
                   version 1.0)
    into   xx
    from   dual;
    dbms_output.put_line(xx.getstringval);
  end loop;*/
  --
exception
  when others then
    xxdoo.xxdoo_db_utils_pkg.show_errors;
    /*select xmlroot(xmltype.createxml(cc(1)),
                   version 1.0)
    into   xx
    from   dual;
    dbms_output.put_line(xx.getstringval);*/
end;
0
0
