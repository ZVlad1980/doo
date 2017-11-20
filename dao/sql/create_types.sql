declare
  l_table    varchar2(150);
  l_type     varchar2(15);
  g_owner    varchar2(15) := 'xxdoo';
  g_dev_code varchar2(15) := 'xxdoo_dao';
  l_name     varchar2(15);
  l_cname    varchar2(15);
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
  function get_name(p_name varchar2 default null) return varchar2 is
  begin
    return g_dev_code || 
             case 
               when p_name is not null then
                 '_' || p_name
             end;
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
  --
  --
  create_obj(p_name => get_name,
             p_body => ' under xxdoo_db_object (
  table_name        varchar2(32),
  put_method        clob,
  load_method       clob,
  --
  overriding member function get_type_name return varchar2,
  constructor function '||get_name||' return self as result,
  constructor function '||get_name||'(p_table xxdoo_db_tab) return self as result,
  member function  load(p_xmlinfo xmltype) return anydata,
  member procedure put(p_object anydata),
  member function  get_all(p_fast_mode boolean default null) return anydata,
  member function  get(p_fast_mode boolean default null) return anydata,
  member procedure update_version
) not final');
  --Коллекция 
  create_obj(p_name => 'xxdoo_daos',
             p_body => ' as table of ' || get_name(l_name));
  --
  -- атрибуты
  --
  l_name  := 'attribute';
  l_cname := 'attributes';
  create_obj(p_name => get_name(l_name),
             p_body => ' under xxdoo_db_object (
  position        number,
  name            varchar2(32),
  data_type_owner varchar2(32),
  data_type       varchar2(32),
  data_typecode   varchar2(1), --(O)bject/(C)ollection(F)K
  data_length     number,
  data_scale      number,
  tab_col_name    varchar2(32),
  xml_alias       varchar2(32),
  overriding member function get_type_name return varchar2,
  constructor function '||get_name(l_name)||' return self as result,
  member procedure xml_string(c in out nocopy xxdoo_db_text, p_path varchar2),
  member procedure load_string(s in out nocopy xxdoo_db_select, 
                               p_alias_vw  varchar2,
                               p_alias_xml varchar2)
) not final');
  --Коллекция 
  create_obj(p_name => get_name(l_cname),
             p_body => ' as table of ' || get_name(l_name));
  --
  -- таблицы
  --
  l_name  := 'table';
  l_cname := 'tables';
  create_obj(p_name => get_name(l_name),
             p_body => ' under xxdoo_db_object (
  table_name       varchar2(32),
  table_alias      varchar2(32),
  table_info       xxdoo_db_tab,
  attribute_list   '||get_name('attributes')||',
  --
  put_method       clob,
  load_method      clob,
  --
  alias_xml        varchar2(32),
  alias_vw         varchar2(32),
  dao_path         varchar2(1024),
  --
  overriding member function get_type_name return varchar2,
  constructor function '||get_name(l_name)||' return self as result,
  member procedure add_attribute(p_attr '||get_name('attribute')||'),
  member function get_attribute_pos(p_attr_name varchar2) return number,
  member procedure dao_xml_parsing(c in out nocopy xxdoo_db_text, p_path varchar2 default null),
  member procedure dao_load_object(s in out nocopy xxdoo_db_select,
                                   p_alias_vw varchar2 default null,
                                   p_alias_xml varchar2 default null),
  member procedure dao_load_select(s in out nocopy xxdoo_db_select, 
                                   p_xml_info varchar2,
                                   p_path     varchar2),
  member procedure dao_load,
  member procedure dao_put_object(t in out nocopy xxdoo_db_text,
                                  p_from_tables xxdoo_db_objects_list),
  member procedure dao_put_delete(t             in out nocopy xxdoo_db_text,
                                  p_from_tables               xxdoo_db_objects_list,
                                  a                           number, 
                                  p_table       in out nocopy xxdoo_db_object),
  member procedure dao_put_parse(t in out nocopy xxdoo_db_text,
                                 p_from_tables xxdoo_db_objects_list),
  member procedure dao_put
) not final');
  --Коллекция 
  create_obj(p_name => get_name(l_cname),
             p_body => ' as table of ' || get_name(l_name));
  --
  -- builder
  --
  l_name  := 'builder';
  create_obj(p_name => get_name(l_name),
             p_body => ' under xxdoo_db_object (
  dummy number,
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_scheme_name varchar2) return self as result,
  member procedure build
)');
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
    plog('Crashed creation objects');
end;
/
