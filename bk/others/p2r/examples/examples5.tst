PL/SQL Developer Test script 3.0
13
-- Created on 09.09.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  p xxdoo_p2r_parser := xxdoo_p2r_parser(':bookname/:callback(\d+)?/:id(\d+)?','book//1');
  l_key varchar2(1024);
  l_value varchar2(1024);
begin
  -- Test statements here
  p.first;
  while p.next(l_key, l_value) loop
    dbms_output.put_line(l_key || ' = ' || l_value);
  end loop;
end;
0
0
