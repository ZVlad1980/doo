PL/SQL Developer Test script 3.0
81
-- Created on 19.08.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  b xxdoo.xxdoo_bk_book_typ := xxdoo.xxdoo_bk_book_typ('Contractors');
  o xxdoo.xxdoo_cntr_contractor_typ;
  l_dummy pls_integer;
  a xxapps.xxapps_service_raw_block;
  l_xml xmltype := xmltype('<Request><Parameters><State>NEW</State></Parameters><content>
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
  </content></Request>');
  l_clob clob;
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  l_clob := l_xml.getClobVal;
  a := xxdoo.xxdoo_bk_core_pkg.request(
    p_book_name => 'Contractors',
    p_mode => null, 
    p_ctx => null);--l_clob); 
  dbms_output.put_line(a.clob_value);
  a := xxdoo.xxdoo_bk_core_pkg.request(
    p_book_name => 'Contractors',
    p_mode => 'CALLBACK', 
    p_ctx => l_clob);--l_clob); 
  
  --
  --l_dummy := b.context.entry.getObject(o);
  dbms_output.put_line(a.clob_value);
--  dbms_output.put_line(xmltype.createxml(o).getStringVal);
  --
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
1
l_xml
