PL/SQL Developer Test script 3.0
20
-- Created on 23.09.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  m xxdoo.xxdoo_db_merge;
begin
  -- Test statements here
  m := xxdoo.xxdoo_db_merge();
  --
  m.m('table','t');
  m.us.s('field1');
  m.us.s('field2');
  m.us.f('table(t) o');
  m.i('field1');
  m.i('field2');
  m.u('field2');
  m.o('field1');
  --
  dbms_output.put_line(m.get_text);
  --
end;
0
0
