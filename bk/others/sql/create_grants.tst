PL/SQL Developer Test script 3.0
17
-- Created on 15.08.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  cursor l_obj_cur is
    select distinct o.name
    from   xxdoo_db_schemes_t s,
           xxdoo_db_objects_t o
    where  1=1
    and    o.type in ('TYPE')
    and    o.scheme_id = s.id
    and    s.name = 'Books';
begin
  -- Test statements here
  for o in l_obj_cur loop
    dbms_output.put_line('grant execute,debug on '||lower(o.name)||' to apps with grant option;');
  end loop;
end;
0
0
