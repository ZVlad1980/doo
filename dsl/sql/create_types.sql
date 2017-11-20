declare
  g_owner    varchar2(15) := 'xxdoo';
  g_dev_code varchar2(15) := 'xxdoo_dsl';
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
  -- Базовый тип
  --
  create_type(p_name     => null, 
              p_name_tbl => null,
              p_body     => ' under xxdoo_db_object (
  h  xxdoo_html,
  --
  overriding member function get_type_name return varchar2,
  member function unless(p_condition varchar2) return varchar2,
  member function when#(p_condition varchar2) return varchar2,
  member function condition#(p_condition varchar2) return varchar2,
  member function eql(p_value varchar2, p_value2 varchar2) return varchar2,
  member function g(p_value varchar2) return varchar2,
  member function all#(p_list xxdoo_db_list_varchar2) return varchar2,
  member function not#(p_condition varchar2) return varchar2,
  member function firstOf(p_list xxdoo_db_list_varchar2) return varchar2
) not final
  not instantiable');
  --
  --Ячейки
  --
  create_type(p_name     => 'tbl_cell', 
              p_name_tbl => 'tbl_cells',
              p_body     => ' under xxdoo_db_object (
  h        xxdoo_html,
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name('tbl_cell') || '(p_h xxdoo_html) return self as result
) not final');
  --
  -- Строки
  --
  create_type(p_name     => 'tbl_row', 
              p_name_tbl => null,
              p_body     => ' under xxdoo_db_object (
  h      xxdoo_html,
  source varchar2(1024),
  collection xxdoo_html_source_typ,
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name('tbl_row') || '(p_collection xxdoo_html_source_typ, p_css varchar2 default null) return self as result,
  constructor function ' || get_name('tbl_row') || '(p_source varchar2, p_css varchar2 default null) return self as result
) not final');
  --
  -- таблица
  --
  create_type(p_name     => 'table', 
              p_name_tbl => null,
              p_body     => ' under '||get_name||' (
  caption     varchar2(1024),
  head        '||get_name('tbl_cell')||',
  cells       '||get_name('tbl_cell')||',
  placeholder xxdoo_html,
  condition   varchar2(4000),
  crows        '||get_name('tbl_row')||',
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name('table') || ' return self as result,
  member function ccolumn(p_name varchar2, p_content xxdoo_html, p_tag varchar2 default null, p_css varchar2 default null) return '||get_name('table')||',
  member function ccolumn(p_name      varchar2, 
                          p_content   varchar2, 
                          p_tag       varchar2 default null, 
                          p_css       varchar2 default null) return xxdoo_dsl_table,
  member procedure ctable(
    p_caption     varchar2                    default null, 
    p_when        varchar2                    default null, 
    p_placeholder xxdoo_html                  default null, 
    p_rows        '||get_name('tbl_row') || ' default null, 
    p_columns     '||get_name('table')   || ' default null,
    p_css         varchar2                    default null)
) not final');
  --
  -- Кнопка панели инструментов
  --
  create_type(p_name     => 'button', 
              p_name_tbl => 'buttons',
              p_body     => ' under '||get_name||' (
  label       varchar2(100),
  callback    varchar2(100), --xxdoo_utl_method,
  condition   varchar2(4000),
  html        xxdoo_html,
  css         varchar2(100),
  confirmed   varchar2(100),
  link        varchar2(1024),
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name('button') || '(p_label       varchar2,
                                                    p_callback    varchar2 default null,
                                                    p_when        varchar2 default null,
                                                    p_html        xxdoo_html default null,
                                                    p_css         varchar2 default null,
                                                    p_confirmed   varchar2 default null,
                                                    p_link        varchar2 default null) return self as result,
  member procedure generate,
  member function get_html(self in out nocopy '||get_name('button')||') return xxdoo_html
) not final');
  --
  -- Панель инструментов
  --
  create_type(p_name     => 'toolbar', 
              p_name_tbl => null,
              p_body     => ' under '||get_name||' (
  buttons     '||get_name('buttons')||',
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name('toolbar') || ' return self as result,
  constructor function ' || get_name('toolbar') || '(p_buttons '||get_name('buttons')||') return self as result,
  member procedure generate,
  member function get_html(self in out nocopy '||get_name('toolbar')||') return xxdoo_html
) not final');
  --
  -- Заголовок (страницы)
  --
  create_type(p_name     => 'header', 
              p_name_tbl => null,
              p_body     => ' under '||get_name||' (
  heading     varchar2(150),
  message_h   xxdoo_html,
  message_s   varchar2(1024),
  toolbar     '||get_name('toolbar')||',
  --
  overriding member function get_type_name return varchar2,
  constructor function xxdoo_dsl_header return self as result,
  constructor function ' || get_name('header') || '(
    p_heading varchar2 default null,
    p_message xxdoo_html default null,
    p_toolbar '||get_name('toolbar')||' default '||get_name('toolbar')||'()) return self as result,
  constructor function ' || get_name('header') || '(
    p_heading varchar2 default null,
    p_message varchar2 default null,
    p_toolbar '||get_name('toolbar')||' default '||get_name('toolbar')||'()) return self as result,
  member procedure initialize(
    p_heading   varchar2,
    p_message_h xxdoo_html,
    p_message_s varchar2,
    p_toolbar '||get_name('toolbar')||'),
  member procedure generate,
  member function get_html(self in out nocopy '||get_name('header')||') return xxdoo_html
) not final');
  --
  -- Инфа по параметру (термин - описание)
  --
  create_type(p_name     => 'term', 
              p_name_tbl => 'terms',
              p_body     => ' under '||get_name||' (
  term        varchar2(250),
  describe_h  xxdoo_html,
  describe_s  varchar2(1024),
  condition   varchar2(4000),
  css         varchar2(150),
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name('term') || ' return self as result,
  constructor function ' || get_name('term') || '(
    p_term  varchar2, 
    p_value xxdoo_html, 
    p_when  varchar2 default null,
    p_css   varchar2 default null) return self as result,
  constructor function ' || get_name('term') || '(
    p_term  varchar2, 
    p_value varchar2, 
    p_when  varchar2 default null,
    p_css   varchar2 default null) return self as result,
  member procedure initialize(
    p_term    varchar2,
    p_value_h xxdoo_html,
    p_value_s varchar2,
    p_when    varchar2,
    p_css     varchar2),
  member procedure generate,
  member function get_html(self in out nocopy '||get_name('term')||') return xxdoo_html
) not final');
  --
  -- Суммарная инфа по параметрам (термин - описание)
  --
  create_type(p_name     => 'summary', 
              p_name_tbl => null,
              p_body     => ' under '||get_name||' (
  terms       '||get_name('terms')||',
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name('summary') || '(p_terms '||get_name('terms')||') return self as result,
  member procedure generate,
  member function get_html(self in out nocopy '||get_name('summary')||') return xxdoo_html
) not final');
  --
  -- Страница
  --
  create_type(p_name     => 'page', 
              p_name_tbl => null,
              p_body     => ' under '||get_name||' (
  name        varchar2(1024),
  header      '||get_name('header')||',
  summary     '||get_name('summary')||',
  content     xxdoo_html,
  tag         varchar2(50),
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name('page') || ' return self as result,
  member procedure page(p_name    varchar2, 
                        p_header  '||get_name('header')||' default null,
                        p_summary '||get_name('summary')||' default null,
                        p_content xxdoo_html default null),
  member procedure generate
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
