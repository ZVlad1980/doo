declare
  cursor l_obj(p_name_template varchar2) is
    select o.OBJECT_TYPE,o.OBJECT_NAME
    from   all_objects o
    where  1=1
    and    o.OBJECT_TYPE in ('PACKAGE','TABLE','TYPE','VIEW','SEQUENCE')
    and    o.OBJECT_NAME like upper(p_name_template||'%');
  type t_list is table of varchar2(100);
  l_list t_list := t_list('xxdoo_cntr'
                          --'xxdoo_bk'--,
                          --'xxdoo_db'
                          --'xxdoo_html',
                          --'xxdoo_utl'
                         );
  l_err boolean;
begin
  for l in 1..l_list.count loop
    for i in 1..20 loop
      l_err := false;
      for o in l_obj(l_list(l)) loop
        begin
          execute immediate 'drop '||o.object_type||' '||o.object_name;
        exception
          when others then
            dbms_output.put_line('drop '||o.object_type||' '||o.object_name||chr(10)||sqlerrm);
            l_err := true;
        end;
      end loop;
      exit when not l_err;
    end loop;
    if l_err then
      return;
    end if;
  end loop; 
  dbms_output.put_line('All objects dropped.'); 
end;
