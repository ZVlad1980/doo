declare
  c varchar2(400);
  cursor l_obj_cur is
    select case o.object_type
             when 'TABLE' then
               'select,insert,update,delete'
             when 'TYPE' then
               'execute,debug'
             when 'PACKAGE' then
               'execute,debug'
             when 'SEQUENCE' then
               'select'
             when 'VIEW' then
               'select'
           end grant_type,
           o.OBJECT_NAME
    from   all_objects o
    where  o.OBJECT_TYPE in ('TABLE','TYPE','SEQUENCE','PACKAGE','VIEW')
    and    o.OBJECT_NAME like upper('xxdoo_json%')
    and    o.OWNER = 'XXDOO';
begin
  for o in l_obj_cur loop
    begin
      c := 'grant '||o.grant_type||' on '||o.OBJECT_NAME||' to apps with grant option';
      dbms_output.put(c||' ... ');
      execute immediate c;
      dbms_output.put_line('Ok');
    exception
      when others then
        dbms_output.put_line('Error: '||sqlerrm);
    end;
  end loop;
end;
/
grant execute on xxdoo_json_pkg to xxapps,xxportal
/
