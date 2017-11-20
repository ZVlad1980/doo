declare
  l_table    varchar2(150);
  l_type     varchar2(15);
  g_owner    varchar2(15) := 'xxdoo';
  g_dev_code varchar2(15) := 'xxdoo_db';
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
  function get_name(p_name varchar2,
                    p_type in varchar2 default 'type') return varchar2 is
  begin
    return replace(g_dev_code || '_' || p_name /*|| '_' || substr(p_type,
                                                                1,
                                                                3)*/,
                   '__',
                   '_');
  end get_name;
  --
  procedure create_obj(p_name  in varchar2,
                       p_body  in varchar2,
                       p_owner in varchar2 default g_owner,
                       p_type  in varchar2 default 'type') is
    l_table_exist_exc exception;
    pragma exception_init(l_table_exist_exc,
                          -955);
    l_name varchar2(30) := get_name(p_name);
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
  procedure alter_obj(p_name  in varchar2,
                      p_body  in varchar2,
                      p_owner in varchar2 default g_owner,
                      p_type  in varchar2 default 'type') is
    l_element_exists_exc exception;
    pragma exception_init(l_element_exists_exc,
                          -1442);
    l_element_exists2_exc exception; --дубирование элементов в типе
    pragma exception_init(l_element_exists2_exc,
                          -22324);
    l_name varchar2(30) := get_name(p_name);
  begin
    plog('Alter ' || p_type || ' ' || l_name || '...',false);
    execute immediate 'alter ' || p_type || ' ' || p_owner || '.' || l_name || ' ' || p_body;
    plog('Ok');
  exception
    when l_element_exists_exc
         or l_element_exists2_exc then
      plog('exist');
    when others then
      plog('error' || sqlerrm); --plog('error: '||sqlerrm, true);
      raise;
  end;
  --
begin
  dbms_output.enable(100000);
  g_drop := null;
  --
  -- Интерфейс базового типа
  --
  l_name  := 'object';
  l_cname := 'objects_list';
  create_obj(p_name => l_name,
             p_body => 'as object (
  instance_version integer,
  not instantiable member function get_type_name return varchar2
) not final
not instantiable');
  --
  --Коллекция 
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  -- Типы для списков
  --
  -- varchar2
  create_obj(p_name => 'list_varchar2',
             p_body => ' as table of varchar2(32767)');
  -- number
  create_obj(p_name => 'list_number',
             p_body => ' as table of number');
  -- date
  create_obj(p_name => 'list_date',
             p_body => ' as table of date');
  --
  -- Универсальный хэш-список
  --
  l_name  := 'list_value';
  l_cname := 'list_values';
  create_obj(p_name => l_name,
             p_body => 'under '||get_name('object')||' (
  key       varchar2(200),
  value     anydata,
  overriding member function get_type_name return varchar2,
  constructor function '||get_name(l_name)||'(p_key varchar2, p_value anydata) return self as result
) not final');
  --
  --Коллекция 
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  
  --
  -- Универсальный хэш-список
  --
  l_name  := 'list';
  l_cname := null;
  create_obj(p_name => l_name,
             p_body => 'under '||get_name('object')||' (
  iterator number,
  list     '||get_name('list_values')||',
  max_length number,
  constructor function '||get_name(l_name)||' return self as result,
  constructor function '||get_name(l_name)||'(p_xmlinfo xmltype) return self as result,
  constructor function '||get_name(l_name)||'(p_list '||get_name('list_values')||') return self as result,
  overriding member function get_type_name return varchar2,
  member procedure parse_xml(p_xmlinfo xmltype),
  member procedure first,
  member procedure next(p_key in out nocopy varchar2, p_value out nocopy anydata),
  member function next(self in out nocopy '||get_name(l_name)||', p_key in out nocopy varchar2, p_value out nocopy varchar2) return boolean,
  member function next(self in out nocopy '||get_name(l_name)||', p_key in out nocopy varchar2, p_value out nocopy anydata) return boolean,
  member function next(self in out nocopy '||get_name(l_name)||', p_key in out nocopy varchar2) return boolean,
  member procedure add_value(p_key varchar2, p_value varchar2),
  member procedure add_value(p_key varchar2, p_value anydata),
  member procedure add_value(p_key varchar2),
  member function get_value_num(p_key varchar2) return number,
  member function get_value(p_key varchar2) return anydata,
  member function is_exists(p_key varchar2) return boolean
) not final');
  --
  --  тип для объектов базы
  --
  l_name  := 'text_line';
  l_cname := 'text_lines';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  position      integer,
  text          varchar2(4000),
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_position integer,
                                                  p_text     varchar2) return self as result
) not final');
  --Коллекция строк
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  --  text
  --
  l_name  := 'text';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  lines      '||get_name('text_lines')||',
  --
  indent integer,
  nl     varchar2(1),
  iterator integer,
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || '(p_indent number default 0) return self as result,
  member procedure append(p_str varchar2, p_eof boolean default true),
  member procedure inc(p_value number default 2),
  member procedure dec(p_value number default 2),
  member function get_text return varchar2,
  member function get_clob return clob,
  member procedure first,
  member function next(self in out nocopy ' || get_name(l_name) || ', p_str in out nocopy varchar2) return boolean
) not final');
  --
  --  тип для объектов базы
  --
  l_name  := 'object_db';
  l_cname := 'objects_db';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  position      integer,
  type          varchar2(30),
  owner         varchar2(30),
  name          varchar2(120),
  body          varchar2(32767),
  spc           varchar2(1000),
  --
  id            integer,
  indent        number,
  new_line      varchar2(1),
  spc_indent    number,
  spc_nl        varchar2(1),
  status        varchar2(1),
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_position integer,
                                                  p_type     varchar2,
                                                  p_owner    varchar2,
                                                  p_name     varchar2) return self as result,
  member procedure append(p_str varchar2, p_eof boolean default true),
  member procedure appends(p_str varchar2, p_eof boolean default true),
  member procedure inc(p_value number default 2),
  member procedure dec(p_value number default 2),
  member procedure incs(p_value number default 2),
  member procedure decs(p_value number default 2),
  member function full_name return varchar2,
  member procedure invoke,
  member procedure set_id
) not final');
  --Коллекция объектов базы
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  --  тип для работы с коллекцией объектов БД
  --
  l_name  := 'objects_db_list';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  owner         varchar2(32),
  objects_db   '||get_name('objects_db')||',
  --
  archive_id    integer,
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || '(p_owner varchar2) return self as result,
  member procedure init,
  member function object_pos(p_owner varchar2, p_name varchar2, p_type varchar2) return number,
  member procedure new(p_type varchar2, p_name varchar2),
  member procedure append(p_str varchar2, p_eof boolean default true),
  member procedure appends(p_str varchar2, p_eof boolean default true),
  member procedure inc(p_value number default 2),
  member procedure dec(p_value number default 2),
  member procedure incs(p_value number default 2),
  member procedure decs(p_value number default 2),
  member function full_name return varchar2,
  member procedure invoke,
  member function get_spc return varchar2,
  member procedure put(p_scheme_name varchar2)
) not final');
  --
  --
  --
  l_name  := 'select';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  st '||get_name('text')||',
  wt '||get_name('text')||',
  ft '||get_name('text')||',
  ob '||get_name('text')||',
  gb '||get_name('text')||',
  --
  current_block varchar2(20),
  current_line  number,
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || '(p_indent number default 0) return self as result,
  member procedure new_line(p_obj in out nocopy xxdoo_db_text, p_command varchar2),
  member procedure s(p_str varchar2),
  member procedure s(p_select  in out nocopy '||get_name(l_name)||', p_alias varchar2),
  member procedure s(p_text  in out nocopy '||get_name('text')||', p_alias varchar2),
  member procedure f(p_str varchar2),
  member procedure f(p_select  in out nocopy '||get_name(l_name)||', p_alias varchar2),
  member procedure f(p_text  in out nocopy '||get_name('text')||', p_alias varchar2),
  member procedure w(p_value varchar2),
  member procedure w(p_cond varchar2, p_value varchar2),
  member procedure o(p_value varchar2),
  member procedure g(p_value varchar2),
  member function build return varchar2,
  member procedure first,
  member function next(self in out nocopy ' || get_name(l_name) || ', p_str in out nocopy varchar2) return boolean
) not final');
  --
  --
  --
  l_name  := 'merge';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  table_name varchar2(64),
  table_alias varchar2(32),
  using_alias varchar2(3),
  --
  mt  '||get_name('text')||',
  us  '||get_name('select')||',
  ut  '||get_name('text')||',
  ot  '||get_name('text')||',
  upt '||get_name('text')||',
  ict '||get_name('text')||',
  ivt '||get_name('text')||',
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || '(p_indent number default 0) return self as result,
  member procedure m(p_table_name varchar2, p_table_alias varchar2),
  member procedure i(p_column_name varchar2),
  member procedure u(p_column_name varchar2),
  member procedure o(p_column_name varchar2),
  member procedure build,
  member function get_text(self in out nocopy xxdoo_db_merge) return varchar2
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
exception
  when others then
    plog('Crashed creation objects');
end;
/
