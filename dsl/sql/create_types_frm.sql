declare
  g_owner     varchar2(15) := 'xxdoo';
  g_dev_code  varchar2(15) := 'xxdoo_dsl_frm';
  l_name      varchar2(15);
  l_list_name varchar2(15);
  g_drop      varchar2(32000);
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
    return g_dev_code || case when p_name is not null then '_' || p_name end;
  end;
  --
  procedure create_obj(p_name  in varchar2,
                       p_body  in varchar2,
                       p_owner in varchar2 default g_owner,
                       p_type  in varchar2 default 'type') is
    l_table_exist_exc exception;
    pragma exception_init(l_table_exist_exc, -955);
    l_name varchar2(30) := p_name;
  begin
    g_drop := 'drop ' || p_type || ' ' || l_name || ';' || chr(10) || g_drop;
    --
    plog('Create ' || p_type || ' ' || l_name || '...', false);
    execute immediate 'create ' || p_type || ' ' || p_owner || '.' || l_name || ' ' || p_body;
    execute immediate 'grant execute, debug on ' || p_owner || '.' || l_name || ' to apps with grant option';
    plog('Ok');
  exception
    when l_table_exist_exc then
      plog('exist');
      --plog('create ' || p_type || ' ' || p_owner || '.' || l_name || ' ' || p_body);
      execute immediate 'grant execute, debug on ' || p_owner || '.' || l_name || ' to apps with grant option';
    when others then
      plog('error: ' || sqlerrm);
      plog('create ' || p_type || ' ' || p_owner || '.' || l_name || ' ' || p_body);
      raise;
  end;
  --
  procedure create_type(p_name     varchar2,
                        p_name_tbl varchar2,
                        p_body     varchar2) is
  begin
    create_obj(p_name => get_name(p_name), p_body => p_body);
    if p_name_tbl is not null then
      create_obj(p_name => get_name(p_name_tbl), p_body => ' as table of ' || get_name(p_name));
    end if;
  end;
  --
begin
  dbms_output.enable(100000);
  g_drop := null;
  --
  -- Базовый тип элемента формы
  --
  create_type(p_name     => '', 
              p_name_tbl => 'list',
              p_body     => ' under xxdoo_dsl (
  --id           number, --identify
  --pid          number, --parent id
  aid          number, --array id (in memory)
  name         varchar2(150),
  element_type varchar2(20),
  --
  overriding member function get_type_name return varchar2,
  --
  not instantiable member procedure generate,
  not instantiable member function get_html(self in out nocopy '||get_name||') return xxdoo_html,
  not instantiable member function get_element_type return varchar2
  --
) not final
  not instantiable');
  --
  -- Форма (базовая логика)
  --
  l_name      := 'core';
  l_list_name := '';
  create_type(p_name     => l_name, 
              p_name_tbl => l_list_name,
              p_body     => ' under '||get_name||' (
  elements    '||get_name('list')||',
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  overriding member procedure generate,
  overriding member function get_html(self in out nocopy '||get_name(l_name)||') return xxdoo_html,
  overriding member function get_element_type return varchar2,
  --
  --member procedure merge(p_parent_id number, p_elements '||get_name('list')||'),
  member procedure element(p_element '||get_name||')
) not final');
  --
  -- Форма
  --
  l_name      := 'form';
  l_list_name := l_name || 's';
  create_type(p_name     => l_name, 
              p_name_tbl => l_list_name,
              p_body     => ' under '||get_name('core')||' (
  legend      varchar2(1024),
  entry_name  varchar2(15),
  css         varchar2(100),
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  overriding member procedure generate,
  overriding member function get_html(self in out nocopy '||get_name(l_name)||') return xxdoo_html,
  overriding member function get_element_type return varchar2,
  --
  member function form(p_entry varchar2, p_legend varchar2, p_form xxdoo_dsl_frm_form) return xxdoo_dsl_frm_form,
  member function form(p_entry varchar2, p_form xxdoo_dsl_frm_form) return xxdoo_dsl_frm_form,
  member function collection(p_entry varchar2, p_object '||get_name(l_name)||') return '||get_name(l_name)||',
  member function fieldset(p_name varchar2, p_cols number, p_object '||get_name(l_name)||') return '||get_name(l_name)||',
  member function fieldset(p_cols number, p_object '||get_name(l_name)||') return '||get_name(l_name)||',
  member function field(p_name varchar2, p_object '||get_name(l_name)||') return '||get_name(l_name)||',
  member function field(p_name varchar2) return '||get_name(l_name)||',
  member function field(p_object '||get_name(l_name)||') return '||get_name(l_name)||',
  member function suggest(p_name varchar2) return '||get_name(l_name)||',
  member function text(p_name varchar2, hidden boolean default false) return '||get_name(l_name)||',
  member function number#(p_name varchar2, hidden boolean default false) return '||get_name(l_name)||',
  member function date#(p_name varchar2, hidden boolean default false) return '||get_name(l_name)||'
) not final');
  --
  -- Начинка поля
  --
  l_name      := 'content';
  l_list_name := l_name || 's';
  create_type(p_name     => l_name, 
              p_name_tbl => l_list_name,
              p_body     => ' under '||get_name||' (
  type       varchar2(20),
  hidden     varchar2(1),
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_name varchar2, p_type varchar2, p_hidden boolean default false) return self as result,
  overriding member procedure generate,
  overriding member function get_html(self in out nocopy '||get_name(l_name)||') return xxdoo_html,
  overriding member function get_element_type return varchar2
) not final');
  --
  -- Список
  --
  l_name      := 'suggest';
  l_list_name := '';
  create_type(p_name     => l_name, 
              p_name_tbl => l_list_name,
              p_body     => ' under '||get_name('content')||' (
  fld_id_name varchar2(32),
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_name varchar2) return self as result,
  overriding member procedure generate,
  overriding member function get_html(self in out nocopy '||get_name(l_name)||') return xxdoo_html,
  overriding member function get_element_type return varchar2
) not final');
  --
  -- Поле
  --
  l_name      := 'field';
  l_list_name := l_name || 's';
  create_type(p_name     => l_name, 
              p_name_tbl => l_list_name,
              p_body     => ' under '||get_name||' (
  contents   '||get_name('contents')||',
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_name varchar2, p_elements '||get_name('list')||') return self as result,
  overriding member procedure generate,
  overriding member function get_html(self in out nocopy '||get_name(l_name)||') return xxdoo_html,
  overriding member function get_element_type return varchar2
) not final');
  --
  -- Набор полей
  --
  l_name      := 'fieldset';
  l_list_name := '';
  create_type(p_name     => l_name, 
              p_name_tbl => l_list_name,
              p_body     => ' under '||get_name||' (
  contents   '||get_name('list')||',
  column_cnt number,
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_name varchar2, p_cols number, p_elements '||get_name('list')||') return self as result,
  overriding member procedure generate,
  overriding member function get_html(self in out nocopy '||get_name(l_name)||') return xxdoo_html,
  overriding member function get_element_type return varchar2
) not final');
  --
  -- Коллекция
  --
  l_name      := 'collection';
  l_list_name := '';
  create_type(p_name     => l_name, 
              p_name_tbl => l_list_name,
              p_body     => ' under '||get_name||' (
  entry_name varchar2(15),
  contents   '||get_name('list')||',
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_entry varchar2, p_elements '||get_name('list')||') return self as result,
  overriding member procedure generate,
  overriding member function get_html(self in out nocopy '||get_name(l_name)||') return xxdoo_html,
  overriding member function get_element_type return varchar2
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
    plog('Crashed creation objects');
end;
/
