PL/SQL Developer Test script 3.0
42
-- Created on 19.09.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  s xxdoo.xxdoo_db_select := xxdoo.xxdoo_db_select();
  s2 xxdoo.xxdoo_db_select := xxdoo.xxdoo_db_select();
  t xxdoo_db_text := xxdoo_db_text();
  str varchar(1000);
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  s.s('t.column1 c');
  s.f('table1 t');
  s.s('t.column2 c2');
  s.w('t.column3 = ''A''');
  s.w('t.column3 = ''b''');
  s.f('table2 t2');
  s.s('t2.column1');
  s2.s('t3.col1');
  s2.f('table t3');
  t.append('cast(');
  t.inc;
  t.append('multiset(');
  t.inc;
  s2.first;
  while s2.next(str) loop t.append(str); end loop;
  t.dec;
  t.append(')');
  t.dec;
  t.append('as type)');
  s.s(t,'field');
  --s.s(s2,'field');
  --s.f(s2,'table');
  dbms_output.put_line(s.build);
  return;
  --dbms_output.put_line(s2.build);
  s2.first;
  while s2.next(str) loop
    dbms_output.put_line(str);
  end loop;
  --
  --dbms_output.put_line(xmltype.createxml(s2.wt).getStringVal);
end;
0
2
l_str
