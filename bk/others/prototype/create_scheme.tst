PL/SQL Developer Test script 3.0
143
-- Created on 11.07.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  i integer;
  s xxdoo.xxdoo_db_scheme;
  c xxdoo.xxdoo_db_column_tmp;
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
  s := xxdoo.xxdoo_db_scheme(p_name  => 'xxdoo_cntr', 
                             p_owner => 'xxdoo');
  c := s.c();
  --
  xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  --
  --
  s.ctable('site_use_roles', 
           xxdoo.xxdoo_db_list_varchar2(
             'Ship to', 
             'Bill to'
           )
  );
  --
  s.ctable('flagsYN/flagYN','Yes No');
  --
  s.ctable('currencies/currency','RUB EUR USD');
  
  --
  s.ctable('countries/country', 
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',              c.cvarchar(2).pk().notNull),
             s.c('name',            c.cvarchar(80).notNull),
             s.c('description',     c.cvarchar(240)),
             s.c('iso_code',        c.cvarchar(3).indexed)
           )
  );
  --
  s.ctable('categories/category',  --XXGLA_CATEGORY
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',       c.cvarchar(1).pk),
             s.c('name',     c.cvarchar(240))
           )
  );
  --
  s.ctable('types',  --XXBI_CUSTOMER_TYPE          
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',     c.cvarchar(3).pk),
             s.c('name',   c.cvarchar(240))
           )
  );
  --
  s.ctable('addresses/address',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',          c.cint().csequence().pk),
             s.c('country',     c.tables('countries').fk),
             s.c('postal_code', c.cvarchar(30)),
             s.c('city',        c.cvarchar(60)),
             s.c('addr_line',   c.cvarchar(150))
           )
  );
  --
  s.ctable('contractors',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',   c.cint().csequence().pk),
             s.c('contr_number', c.cvarchar(30).notNull().cunique),
             s.c('name', c.cvarchar(360).notNull),
             s.c('name_alt', c.cvarchar(320)),
             s.c('category', c.tables('categories')),
             s.c('type', c.tables('types')),
             s.c('resident', c.tables('flagsYN').fk),
             s.c('tax_reference', c.cvarchar(100)),
             s.c('tax_payer_id', c.cvarchar(100)),
             s.c('creation_date', c.ctimestamp().cdefault('current_timestamp'))
           )
  );
  --
  s.ctable('sites', 
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',            c.cint().csequence().pk),
             s.c('contractor_id', c.tables('contractors').referenced('sites').deleted('CASCADE').indexed),
             s.c('site_number',   c.cnumber().notNull),
             s.c('address_id'   , c.tables('addresses')),
             s.c('tax_reference', c.cvarchar(100)),
             s.c('tax_payer_id', c.cvarchar(100))
           )
  );
  --
  s.ctable('site_uses', 
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',            c.cint().csequence().pk),
             s.c('site_id',       c.tables('sites').referenced('site_uses').deleted('CASCADE').indexed),
             s.c('role',          c.tables('site_use_roles').fk),
             s.c('active',        c.tables('flagsYN').fk),
             s.c('primary',       c.tables('flagsYN').fk)
           )
  );
  --
  s.ctable('bank_branches/bank_branch',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',        c.cint().csequence().pk),
             s.c('name',      c.cvarchar(120))
           )
  );
  --
  s.ctable('bank_accounts',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',             c.cint().csequence().pk),
             s.c('bank_branch_id', c.tables('bank_branches').referenced('bank_accounts').deleted('CASCADE').indexed),
             s.c('name',           c.cvarchar(80)),
             s.c('acc_number',     c.cvarchar(240).notNull),
             s.c('currency',       c.tables('currencies').fk),
             s.c('currency_sec',   c.tables('currencies').fk)
           )
  );
  --
  s.ctable('bank_acc_uses',
           xxdoo.xxdoo_db_tab_columns(
             s.c('id',             c.cint().csequence().pk),
             s.c('bank_account',   c.tables('bank_accounts')),
             s.c('site_use_id',    c.tables('site_uses').referenced('accounts').indexed)
           )
  );
  --
  s.generate;
  --
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
l_dummy
