PL/SQL Developer Test script 3.0
93
-- Created on 11.07.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  i integer;
  --t xxdoo.xxdoo_db_scheme_typ := xxdoo.xxdoo_db_scheme_typ(p_name => 'TEST', p_dev_code => 'test', p_owner => 'xxdoo');
  s xxdoo.xxdoo_db_scheme_typ := xxdoo.xxdoo_db_scheme_typ(p_name => 'Contractors', p_dev_code => 'xxdoo_cntr', p_owner => 'xxdoo');
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
  --dbms_session.reset_package; return;
  xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  --xxdoo.xxdoo_db_engine_pkg.drop_objects(s); return;
  
  --
  s.ctable('contractorTypes', 'Vendor Customer');
  --
  s.ctable('siteRoles', 
           xxdoo.xxdoo_db_list_typ(
             'Ship to', 
             'Bill to'
           )
  );
  --
  s.ctable('countries/country', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',              s.cvarchar(2).pk().notNull),
             s.f('name',            s.cvarchar(255).notNull),
             s.f('localizedName',   s.text),
             s.f('union_countries', s.cvarchar(15).indexed)
           )
  );
  --
  s.ctable('addresses/address',
           xxdoo.xxdoo_db_fields_typ(
             s.f('id', s.cint().csequence().pk),
             s.f('country', s.tables('countries')),
             s.f('postal_code', s.cvarchar(30)),
             s.f('addr_line', s.cvarchar(150))
           )
  );
  --
  s.ctable('contractors',
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',   s.cint().csequence().pk),
             s.f('name', s.cvarchar(150).notNull),
             s.f('type', s.tables('contractorTypes').fk)
           )
  );
  --
  s.ctable('sites', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',            s.cint().csequence().pk),
             s.f('contractor_id', s.tables('contractors').referenced('sites').deleted('CASCADE')),
             s.f('role'         , s.tables('siteRoles').fk),
             s.f('address_id'   , s.tables('addresses'))
           )
  );
  --
  s.ctable('bankAccounts',
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',     s.cint().csequence().pk),
             s.f('siteId', s.tables('sites').fk().deleted('CASCADE')),
             s.f('accountNum', s.cvarchar(40).notnull)
           )
  );
  --
  s.ctable('siteAccounts',
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',     s.cint().csequence().pk),
             s.f('accountId', s.tables('bankAccounts')),
             s.f('siteId', s.tables('sites').referenced('accounts').deleted('CASCADE'))
           )
  );
  --
  s.put;
  s.generate;
  xxdoo.xxdoo_db_utils_pkg.show_errors;
  --dbms_output.put_line(get_xml(s).getClobVal);
  --
exception 
  when others then
    xxdoo.xxdoo_db_utils_pkg.fix_exception;
    xxdoo.xxdoo_db_utils_pkg.show_errors;
end;
0
1
d
