PL/SQL Developer Test script 3.0
83
-- Created on 11.07.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  i integer;
  s xxdoo.xxdoo_db_scheme;
  c xxdoo.xxdoo_db_column_tmp;
  l_dao xxdoo.xxdoo_dao_builder;
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
  s := xxdoo.xxdoo_db_scheme(p_name  => 'xxdoo_edu', 
                             p_owner => 'xxdoo');
  c := s.c();
  --
  xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  --
  s.ctable('genders',
    xxdoo.xxdoo_db_tab_columns(
      s.c('id',      c.cint().csequence().pk),
      s.c('code',    c.cvarchar(10).notNull)
    )
  );
  --
  s.ctable(
    'journals',
    xxdoo.xxdoo_db_tab_columns(
      s.c('id',      c.cint().csequence().pk),
      s.c('name',    c.cvarchar(100).notNull)
    )
  );
  --
  s.ctable(
    'students',
    xxdoo.xxdoo_db_tab_columns(
      s.c('id',        c.cint().csequence().pk),
      s.c('name',      c.cvarchar(100).notNull),
      s.c('last_name', c.cvarchar(100)),
      s.c('birth_day', c.cdate),
      s.c('sex',       c.tables('genders'))
    )
  );
  --
  s.ctable(
    'disciplines/discipline',
    xxdoo.xxdoo_db_tab_columns(
      s.c('id',      c.cint().csequence().pk),
      s.c('name',    c.cvarchar(100).notNull),
      s.c('full_name', c.cvarchar(240))
    )
  );
  --
  s.ctable(
    'entries/entry',
    xxdoo.xxdoo_db_tab_columns(
      s.c('id',         c.cint().csequence().pk),
      s.c('journal',    c.tables('journals').referenced('entries').deleted('CASCADE').indexed),
      s.c('student',    c.tables('students').notNull),
      s.c('discipline', c.tables('disciplines').notNull),
      s.c('grade',      c.cint)
    )
  );
  --
  s.generate;
  l_dao := xxdoo.xxdoo_dao_builder(s.id);
  l_dao.generate;
  --
  xxdoo.xxdoo_db_utils_pkg.show_errors;
  --
exception 
  when others then
    xxdoo.xxdoo_db_utils_pkg.fix_exception;
    xxdoo.xxdoo_db_utils_pkg.show_errors;
end;
0
1
l_dummy
