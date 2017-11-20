declare
  g_owner    varchar2(15) := 'xxdoo';
  l_name     varchar2(32);
  l_cname    varchar2(32);
  g_drop     varchar2(32000);
  --
  procedure plog(p_msg in varchar2,
                 p_eof in boolean default true) is
  begin
    if p_eof = true then
      dbms_output.put_line(p_msg);
    else
      dbms_output.put(p_msg);
    end if;
  end;
  --
  procedure create_obj(p_name  in varchar2,
                       p_body  in varchar2,
                       p_owner in varchar2 default g_owner,
                       p_type  in varchar2 default 'type') is
    l_table_exist_exc exception;
    pragma exception_init(l_table_exist_exc,
                          -955);
    l_name varchar2(30) := p_name;
  begin
    g_drop := 'drop ' || p_type || ' ' || l_name || ';' || chr(10) || g_drop;
    --
    plog('Create ' || p_type || ' ' || l_name || '...',
         false);
    execute immediate 'create ' || p_type || ' ' || p_owner || '.' || l_name || ' ' || p_body;
    execute immediate 'grant execute, debug on '|| p_owner || '.' || l_name||' to apps with grant option';
    plog('Ok');
  exception
    when l_table_exist_exc then
      plog('exist');
      execute immediate 'grant execute, debug on '|| p_owner || '.' || l_name||' to apps with grant option';
    when others then
      plog('error: ' || sqlerrm);
      plog('create ' || p_type || ' ' || p_owner || '.' || l_name || ' ' || p_body);
      raise;
  end;
  --
begin
  dbms_output.enable(100000);
  g_drop := null;
  --
  l_name  := 'xxdoo_json_element';
  l_cname := l_name||'s';
  create_obj(p_name => l_name,
             p_body => ' as object (
  id            number,
  parent_id     number,
  name          varchar2(4000),
  type          varchar2(1), --(V)alue/(O)bject/(A)rray
  value         varchar2(4000),
  --
  constructor function '||l_name||' return self as result
) not final');
  --
  -- Коллекция элементов
  --
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || l_name);
  --
  -- 
  --
  l_name  := 'xxdoo_json';
  l_cname := l_name||'s';
  create_obj(p_name => l_name,
             p_body => ' under xxdoo_db_object (
  elements   xxdoo_json_elements,
  levels     xxdoo_db_list_number,
  position   number,
  --
  overriding member function get_type_name return varchar2,
  constructor function '||l_name||' return self as result,
  constructor function '||l_name||'(p_json clob) return self as result,
  member procedure build(p_json varchar2),
  member function get_parent return number,
  member procedure first,
  member function next(self in out nocopy '||l_name||', p_element in out nocopy xxdoo_json_element) return boolean,
  member procedure set_parent(p_name varchar2),
  member procedure inside,
  member procedure outside,
  member function element(p_name varchar2) return xxdoo_json_element
) not final');
  --
  --
  --
  plog('');
  plog(lpad('-',
            30,
            '-'));
  plog('DROP COMMANDS:');
  plog(g_drop,
       false);
  plog(lpad('-',
            30,
            '-'));
  --
exception
  when others then
    plog('Crashed creation objects '||sqlerrm);
end;
/
