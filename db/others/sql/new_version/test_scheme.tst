PL/SQL Developer Test script 3.0
183
-- Created on 11.07.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  i integer;
  --t xxdoo.xxdoo_db_scheme_typ := xxdoo.xxdoo_db_scheme_typ(p_name => 'TEST', p_dev_code => 'test', p_owner => 'xxdoo');
  s xxdoo.xxdoo_db_scheme;
  c xxdoo.xxdoo_db_column_tmp;
  --f xxdoo.xxdoo_db_field_typ := xxdoo.xxdoo_db_field_typ();
  --
  function get_xml(s xxdoo.xxdoo_db_scheme) return xmltype is
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
  --
  xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  s := xxdoo.xxdoo_db_scheme(p_name  => 'xxdoo_cntr', 
                             p_owner => 'xxdoo');
  --
  /*s.generate;
  s.table_list(1).dao_load;
  s.put;
  return; --*/
  --
  --c := s.c().cvarchar(10);
  --dbms_output.put_line(xmltype.createxml(c).getStringVal);
  --/*
  
  c := s.c();
  /*s.ctable('addresses/address',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',          c.cint().csequence().pk)
           )
  );*/
  --
  /*
  s.ctable('contractorTypes', 'Vendor Customer');
  --
  s.ctable('siteRoles', 
           xxdoo_db_list_varchar2(
             'Ship to', 
             'Bill to'
           )
           
  );
  --
  s.ctable('union_countries/union_country', 
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',              c.cvarchar(2).pk),
             s.c('name',            c.cvarchar(240).notNull().cunique),
             s.c('creation_date',   c.cdate().cdefault('sysdate'))
           )
  );
  --/*
  s.ctable('countries/country', 
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',              c.cvarchar(2).pk),
             s.c('name',            c.cvarchar(240).notNull().cunique),
             s.c('localizedName',   c.cvarchar(240)),
             s.c('union_countries', c.cvarchar(15).indexed),
             s.c('union_country',   c.tables('union_countries')),
             s.c('creation_date',   c.cdate().cdefault('sysdate'))
           )
  );
  --
  s.ctable('sites',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',          c.cint().csequence().pk),
             s.c('name',        c.cvarchar(100).notNull),
             s.c('site_type',   c.cvarchar(10).indexed)
           )
  );
  --
  s.ctable('addresses/address',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',          c.cint().csequence().pk),
             s.c('country',     c.tables('countries').indexed),
             s.c('country2',    c.tables('countries').indexed),
             s.c('country3',    c.tables('countries').fk),
             s.c('postal_code', c.cvarchar(30)),
             s.c('addr_line',   c.cvarchar(150).cunique),
             s.c('new_column',  c.cvarchar(10).indexed().notNull),
             s.c('site_id',     c.tables('sites').referenced('addresses'))
           )
  );
  --
  --
  --s.prepare;
  --s.prepare_views;
  s.generate;
  --
  --s.table_list(1).dao_load;
  --s.table_list(2).dao_load;
  --s.table_list(3).dao_load;
  s.put;
  
  --dbms_output.put_line(get_xml(s).getClobVal);
  
  return;--*/
  
  --dbms_session.reset_package; return;
  --xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  --xxdoo.xxdoo_db_engine_pkg.drop_objects(s); return;
  
  --
  s.ctable('contractorTypes', 'Vendor Customer');
  --
  s.ctable('siteRoles', 
           xxdoo_db_list_varchar2(
             'Ship to', 
             'Bill to'
           )
           
  );
  
  --
  s.ctable('countries/country', 
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',              c.cvarchar(2).pk().notNull),
             s.c('name',            c.cvarchar(255).notNull),
             s.c('localizedName',   c.cvarchar(240)),
             s.c('union_countries', c.cvarchar(15).indexed)
           )
  );
  --
  s.ctable('addresses/address',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',          c.cint().csequence().pk),
             s.c('country',     c.tables('countries')),
             s.c('postal_code', c.cvarchar(30)),
             s.c('addr_line',   c.cvarchar(150))
           )
  );
  --
  s.ctable('contractors',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',   c.cint().csequence().pk),
             s.c('name', c.cvarchar(150).notNull),
             s.c('type', c.tables('contractorTypes').fk)
           )
  );
  --
  s.ctable('sites', 
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',            c.cint().csequence().pk),
             s.c('contractor_id', c.tables('contractors').referenced('sites').deleted('CASCADE')),
             s.c('role'         , c.tables('siteRoles').fk),
             s.c('address_id'   , c.tables('addresses'))
           )
  );
  --
  s.ctable('bankAccounts',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',     c.cint().csequence().pk),
             s.c('siteId', c.tables('sites').fk().deleted('CASCADE')),
             s.c('accountNum', c.cvarchar(40).notnull)
           )
  );
  --
  s.ctable('siteAccounts',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',     c.cint().csequence().pk),
             s.c('accountId', c.tables('bankAccounts')),
             s.c('siteId', c.tables('sites').referenced('accounts').deleted('CASCADE'))
           )
  );
  --
  s.generate;
  --xxdoo.xxdoo_db_utils_pkg.show_errors;
  --dbms_output.put_line(get_xml(s).getClobVal);
  --*/
exception 
  when others then
    xxdoo.xxdoo_db_utils_pkg.fix_exception;
    xxdoo.xxdoo_db_utils_pkg.show_errors;
    --dbms_output.put_line(sqlerrm);
end;
0
2
self.name
self.attribute_list(a).type_code
