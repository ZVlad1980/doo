PL/SQL Developer Test script 3.0
161
--select lower(name), body  from xxdoo.xxdoo_db_scripts_t order by id
/*declare
  l_result clob;
  cursor l_scripts_cur is
    select lower(name) name  from xxdoo.xxdoo_db_scripts_t order by id;
begin
  dbms_lob.createtemporary(l_result, true);
  --
  for s in l_scripts_cur loop
    dbms_lob.append(l_result,
      'prompt *********************************************************************************************' || chr(10) ||
       'prompt * Create '|| lower(s.name) || chr(10) ||
       'prompt *********************************************************************************************' || chr(10) ||
       '@@'|| lower(s.name) || chr(10) ||
       'show errors' || chr(10)||chr(10)
    );
  end loop;
  --
  dbms_output.put_line(l_result);
  dbms_lob.freetemporary(l_result);
end;*/
-- Created on 11.07.2014 by ZHURAVOV_VB 
declare 
  b xxdoo.xxdoo_db_scheme_typ := xxdoo.xxdoo_db_scheme_typ(p_name => 'Books', p_dev_code => 'xxdoo_bk', p_owner => 'xxdoo');
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
  --
begin
  --dbms_session.reset_package; return;
  xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  --
  --xxdoo.xxdoo_db_engine_pkg.drop_objects(b); return;
  --b.generate; return;
  --b.generate_scripts('ZHURAVOV_VB'); xxdoo.xxdoo_db_utils_pkg.show_errors; commit; return;
  --
  b.ctable('statesBook/stateBook', 'Create Complete Error Cancel');
  b.ctable('statesObject/stateObject', 'DDL Compile Error');
  --
  b.ctable('methods',
    xxdoo.xxdoo_db_fields_typ(
      b.f('id', b.cint().pk().csequence().notNull),
      b.f('name', b.cvarchar(30).notNull().indexed),
      b.f('spc', b.cclob),
      b.f('body',  b.cclob)
    )
  );
  --
  b.ctable('services',
    xxdoo.xxdoo_db_fields_typ(
      b.f('id', b.cint().pk().csequence().notNull),
      b.f('name', b.cvarchar(20).notNull().indexed),
      b.f('package_name', b.cvarchar(30)),
      b.f('method_id',       b.tables('methods'))
    )
  );
  --
  b.ctable('layouts',
    xxdoo.xxdoo_db_fields_typ(
      b.f('id', b.cint().pk().csequence().notNull),
      b.f('name', b.cvarchar(20).notNull().indexed),
      b.f('package_name', b.cvarchar(30)),
      b.f('method_id',       b.tables('methods'))
    )
  );
  --
  b.ctable('books', 
    xxdoo.xxdoo_db_fields_typ(
      b.f('id',              b.cint().pk().csequence().notNull),
      b.f('name',            b.cvarchar(15).notNull().indexed),
      b.f('owner',           b.cvarchar(15)),
      b.f('dev_code',        b.cvarchar(10)),
      b.f('dao',             b.cvarchar(100)),
      b.f('title',           b.cvarchar(200)),
      b.f('search',          b.cvarchar(200)),
      b.f('content_id',      b.cnumber),
      b.f('layout',          b.tables('layouts')),
      b.f('service',         b.tables('services')),
      b.f('state',           b.tables('statesBook').fk),
      b.f('created_date',    b.cdate().notNull().cdefault('SYSDATE')),
      b.f('package',         b.tables('methods')),
      b.f('entity_id',       b.cnumber)
    )
  );
  --
  b.ctable('objects',
    xxdoo.xxdoo_db_fields_typ(
      b.f('id',           b.cint().pk().csequence().notNull),
      b.f('book_id',      b.tables('books').referenced('objects')),
      b.f('owner',        b.cvarchar(15).notNull),
      b.f('name',         b.cvarchar(32).notNull),
      b.f('type',         b.cvarchar(106).notNull),
      b.f('state',        b.tables('statesObject').fk),
      b.f('script',       b.cclob)
    )
  );
  --
  b.ctable('roles', 
    xxdoo.xxdoo_db_fields_typ(
      b.f('id',              b.cint().pk().csequence().notNull),
      b.f('book_id',         b.tables('books').referenced('roles').deleted('CASCADE')),
      b.f('name',            b.cvarchar(45).notNull),
      b.f('method_id',          b.tables('methods'))
    )
  );
  --
  b.ctable('pages', 
    xxdoo.xxdoo_db_fields_typ(
      b.f('id',              b.cint().pk().csequence().notNull),
      b.f('book_id',         b.tables('books').referenced('pages').deleted('CASCADE')),
      b.f('name',            b.cvarchar(45).notNull),
      b.f('context',         b.cvarchar(32)),
      b.f('content',         b.tables('methods'))
    )
  );  
  --
  
  --
  b.ctable('role_pages', 
    xxdoo.xxdoo_db_fields_typ(
      b.f('id',              b.cint().pk().csequence().notNull),
      b.f('role_id',         b.tables('roles').referenced('pages').deleted('CASCADE')),
      b.f('page_id',         b.tables('pages')),
      b.f('filter',          b.tables('methods'))
    )
  );  
  --
  b.ctable('callbacks', 
    xxdoo.xxdoo_db_fields_typ(
      b.f('id',              b.cint().pk().csequence().notNull),
      b.f('book_id',         b.tables('books').fk().deleted('CASCADE').deleted('CASCADE')),
      b.f('page_id',         b.tables('pages').referenced('callbacks').deleted('CASCADE')),
      b.f('name',            b.cvarchar(45).notNull),
      b.f('package_name',         b.cvarchar(32)),
      b.f('method_id',       b.tables('methods'))
    )
  );
  --
  b.put;
  --
  b.generate_scripts('ZHURAVOV_VB'); 
  b.generate;
  return;
  
  xxdoo.xxdoo_db_utils_pkg.show_errors; 
  commit; 
  return;
  --
exception 
  when others then
    --
    xxdoo.xxdoo_db_utils_pkg.fix_exception;
    xxdoo.xxdoo_db_utils_pkg.show_errors;
end; --*/
0
1
e
