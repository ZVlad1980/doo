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
  -- базовый тип для колонки
  --
  l_name  := 'column';
  l_cname := 'columns';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  id            integer,
  owner_id      integer,
  name          varchar2(32),
  position      integer,
  overriding member function get_type_name return varchar2,
  constructor function '||get_name('column')||' return self as result,
  constructor function '||get_name('column')||'(p_name varchar2) return self as result,
  constructor function '||get_name('column')||'(p_name varchar2, p_position integer) return self as result,
  member procedure set_id
) not final');
  --
  -- Коллекция колонок
  --
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  --индексы
  --
  l_name  := 'index';
  l_cname := l_name || 'es';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  id         integer,
  table_id   integer,
  name       varchar2(32),
  uniqueness varchar2(9), --Uniqueness status of the index: "UNIQUE",  "NONUNIQUE", or "BITMAP"
  column_list  '||get_name('columns')||',
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_columns    varchar2, 
                                                  p_uniqueness varchar2 default ''NONUNIQUE'') return self as result,
  member procedure set_id,
  member procedure set_name(p_owner varchar2, p_table_name varchar2, p_index_name varchar2, p_ind_num number),
  member function columns_string return varchar2,
  member procedure ddl(o in out nocopy xxdoo_db_objects_db_list, p_owner varchar2, p_table_name varchar2)
)');
  --Коллекция 
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  --constraint with PK, FK, NotNull, etc
  --
  l_name  := 'constraint';
  l_cname := l_name || 's';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  id	              integer,
  table_id          integer,
  name              varchar2(32),
  type              varchar2(1), --
  table_name        varchar2(32),
  db_table_name     varchar2(32),
  column_list       '||get_name('columns')||',
  r_table_name      varchar2(15),
  r_db_table        varchar2(32),
  r_constraint_name varchar2(32),
  r_type            varchar2(20), --type relationships object/collection/fk
  r_collection_name varchar2(32),
  r_column_list     '||get_name('columns')||',
  delete_rule       varchar2(50),
  update_rule       varchar2(50),
  join_template     varchar2(400),
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_type           varchar2, 
                                                  p_rel_table_name varchar2 default null,
                                                  p_rel_type            varchar2 default null) return self as result,
  member procedure set_id,
  member procedure property(p_name                varchar2 default null,
                            p_column_list         '||get_name('columns')||' default null,
                            p_rel_table_name      varchar2 default null,
                            p_rel_constraint_name varchar2 default null,
                            p_rel_type            varchar2 default null,
                            p_rel_collect_name    varchar2 default null,
                            p_delete_rule         varchar2 default null,
                            p_update_rule         varchar2 default null,
                            p_rel_db_table        varchar2 default null),
  member procedure set_name(p_owner varchar2, 
                            p_table_name varchar2,
                            p_cons_name  varchar2,
                            p_cons_num   number),
  member procedure create_join_template,
  member procedure create_pk_templates(p_pk_template       in out nocopy varchar2,

                                       p_pk_joins_template in out nocopy varchar2),
  member function columns_string return varchar2,
  member procedure ddl(o in out nocopy xxdoo_db_objects_db_list, p_owner varchar2, p_table_name varchar2)
)');
  --Collection constraints
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  -- колонки таблицы
  --
  l_name  := 'tab_column';
  l_cname := 'tab_columns';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('column')||' (
  nullable       varchar2(1),
  default_value  varchar2(100),
  length        number,
  scale         number,
  type          varchar2(120),
  is_sequence   varchar2(1),
  overriding member function get_type_name return varchar2,
  constructor function '||get_name(l_name)||'(p_owner      varchar2, 
                                              p_table_name varchar2, 
                                              p_column     '||get_name('tab_column') || ') return self as result,
  overriding member procedure set_id,
  member procedure check_column(p_owner varchar2, p_table_name varchar2),
  member procedure property(p_type   varchar2 default null, 
                            p_length number default null, 
                            p_scale  number default null),
  member function as_string(p_max_name_size number default null) return varchar2,
  member procedure ddl(o in out nocopy xxdoo_db_objects_db_list, p_owner varchar2, p_table_name varchar2)
) not final');
  --Коллекция аттрибутов типа
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  -- аттрибут типа
  --
  l_name  := 'attribute';
  l_cname := l_name || 's';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('tab_column')||' (
  owner_type        varchar2(32),
  column_name       varchar2(32),
  member_type       varchar2(1), --(A)ttribute/(M)ethod/(U)ser defined
  type_code         varchar2(20), -- OBJECT/COLLECTION
  r_table_name      varchar2(32),
  r_db_type         varchar2(32),
  r_db_view         varchar2(32),
  r_db_view_fast    varchar2(32),
  method_spc        varchar2(400),
  method_body       varchar2(32767),
  join_template  varchar2(400),
  --
  overriding member function get_type_name return varchar2,
  constructor function xxdoo_db_attribute return self as result,
  constructor function ' || get_name(l_name) || '(p_name       varchar2, 
                                                  p_type       varchar2,
                                                  p_length     number,
                                                  p_scale      number,
                                                  p_owner      varchar2 default null,
                                                  p_member_type varchar2 default ''A'')
    return self as result,
  member procedure set_property(p_type        varchar2,
                                p_length      number,
                                p_scale       number,
                                p_owner       varchar2 default null,
                                p_member_type varchar2 default ''A''),
  constructor function ' || get_name(l_name) || '(p_name        varchar2,
                                                  p_method_spc  varchar2,
                                                  p_method_body varchar2)
    return self as result,
  member procedure set_position(p_owner varchar2, p_type_name varchar2, p_default_position number),
  member function type_as_string return varchar2,
  overriding member function as_string(p_max_name_size number default null) return varchar2,
  member procedure push_view(s           in out nocopy xxdoo_db_select, 
                             p_owner     varchar2, 
                             p_tab_alias varchar2, 
                             p_col_alias varchar2,
                             p_fast_view boolean default false)
) not final');
  --Коллекция аттрибутов типа
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  -- Тип для временного описания колонки, используется при создании таблицы
  --
  l_name  := 'column_tmp';
  l_cname := 'columns_tmp';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('tab_column')||' (
  is_indexed      varchar2(1),
  is_unique       varchar2(1),
  constraints_tmp '||get_name('constraints')||',
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_name varchar2, p_column ' || get_name(l_name) || ') return self as result,
  member function property(p_type          varchar2 default null,
                           p_length        number   default null,
                           p_scale         number   default null,
                           p_nullable      varchar2 default null,
                           p_default_value varchar2 default null,
                           p_indexed       varchar2 default null,
                           p_is_unique     varchar2 default null,
                           p_sequence      varchar2 default null) return ' || get_name(l_name) || ',
  member function add_constraint(p_type           varchar2 default null,
                                 p_rel_table_name varchar2 default null,
                                 p_rel_type       varchar2 default null) return ' || get_name(l_name) || ',
  member function constraint_property(p_rel_type       varchar2 default null,
                                      p_collect_name   varchar2 default null,
                                      p_update_rule    varchar2 default null,
                                      p_delete_rule    varchar2 default null) return ' || get_name(l_name) || ',
  member function cvarchar(p_length number)  return ' || get_name(l_name) || ',
  member function cint return ' || get_name(l_name) || ',
  member function cnumber(p_length number default null, 
                          p_scale  number default null) return ' || get_name(l_name) || ',
  member function cdate return ' || get_name(l_name) || ',
  member function ctimestamp return ' || get_name(l_name) || ',
  member function cclob return ' || get_name(l_name) || ',
  member function csequence return ' || get_name(l_name) || ',
  member function cdefault(p_value varchar2) return ' || get_name(l_name) || ',
  member function notnull return ' || get_name(l_name) || ',
  member function cunique return ' || get_name(l_name) || ',
  member function indexed return ' || get_name(l_name) || ',
  member function pk return ' || get_name(l_name) || ',
  member function tables(p_name varchar2) return ' || get_name(l_name) || ',
  member function self return ' || get_name(l_name) || ',
  member function referenced(p_value varchar2) return ' || get_name(l_name) || ',
  member function fk return ' || get_name(l_name) || ',
  member function changed(p_value varchar2) return ' || get_name(l_name) || ',
  member function updated(p_value varchar2) return ' || get_name(l_name) || ',
  member function deleted(p_value varchar2) return ' || get_name(l_name) || '
)');
  --
  -- тип для описания связей между таблицами (используется в методе get для построения динамического запроса)
  --
  l_name  := 'tab_join';
  l_cname := 'tab_joins';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  id                 number,
  table_id           number,
  table_name         varchar2(32),
  column_name        varchar2(32),
  r_table_name       varchar2(32),
  r_type             char, --(O)bject/(F)K/(C)ollection
  condition_template varchar2(200),
  overriding member function get_type_name return varchar2,
  constructor function '||get_name(l_name)||'(p_table_name         varchar2, 
                                              p_column_name        varchar2, 
                                              p_r_table_name       varchar2, 
                                              p_condition_template varchar2,
                                              p_rel_type           char) return self as result,
  member procedure set_id
) not final');
  --
  -- Коллекция связей
  --
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  --
  --
  l_name  := 'tab';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('object')||' (
  id                number,
  scheme_id         number,
  owner             varchar2(32),
  entry_name	      varchar2(15),
  name	            varchar2(32),
  db_table          varchar2(32),
  db_view           varchar2(32),
  db_view_fast      varchar2(32),
  db_type           varchar2(32),
  db_coll_type      varchar2(32),
  db_sequence       varchar2(32),
  db_trigger        varchar2(32),
  joins             '||get_name('tab_joins')||',
  pk_template       varchar2(200),
  pk_joins_template varchar2(200),
  --
  overriding member function get_type_name return varchar2,
  constructor function '||get_name(l_name)||' return self as result,
  constructor function '||get_name(l_name)||'(p_scheme_name varchar2, p_table_name varchar2) return self as result,
  constructor function '||get_name(l_name)||'(p_object xxdoo_db_object) return self as result,
  constructor function '||get_name(l_name)||'(p_object anydata) return self as result,
  constructor function '||get_name(l_name)||'(p_table_id number) return self as result
) not final');
  --
  -- таблицы
  --
  l_name  := 'table';
  l_cname := 'tables';
  create_obj(p_name => l_name,
             p_body => ' under '||get_name('tab')||' (
  dev_code          varchar2(12),
  column_list      ' || get_name('tab_columns')||',
  attribute_list   ' || get_name('attributes')||',
  index_list       ' || get_name('indexes') || ',
  constraints      ' || get_name('constraints') || ',
  content          ' || get_name('list_varchar2') || ',
  creation_date    date,
  last_update_date date,
  status           varchar2(20),
  position_tab     integer,
  position_typ     integer,
  --
  constructor function ' || get_name(l_name) || ' return self as result,
  constructor function ' || get_name(l_name) || '(p_table_name  varchar2) return self as result,
  constructor function ' || get_name(l_name) || '(p_owner       varchar2,
                                                  p_dev_code    varchar2,
                                                  p_table_name  varchar2, 
                                                  p_columns     ' || get_name('tab_columns') || ',
                                                  p_indexes     ' || get_name('indexes') || ',
                                                  p_constraints ' || get_name('constraints') || ',
                                                  p_content     ' || get_name('list_varchar2') || ')  return self as result,
  overriding member function get_type_name return varchar2,
  member procedure parse_columns_tmp(p_columns     ' || get_name('tab_columns') || '),
  member procedure add_column(p_column     ' || get_name('tab_column') || '),
  member procedure add_index(p_index ' || get_name('index') || '),
  member procedure add_constraints(p_column_name varchar2, p_constraints xxdoo_db_constraints),
  member procedure merge(p_table ' || get_name(l_name) || '),
  member procedure set_id,
  --member procedure add_attribute(p_name varchar2, p_type_owner varchar2, p_type_name varchar2),
  member procedure add_attribute(p_attribute xxdoo_db_attribute),
  member function get_attribute_pos(p_name varchar2) return number,
  member procedure prepare_index,
  member procedure prepare_constraints(p_scheme in out nocopy xxdoo_db_object),
  member procedure prepare(p_scheme in out nocopy xxdoo_db_object),
  member procedure prepare_attributes(p_scheme in out nocopy xxdoo_db_object),
  member procedure prepare_view_attrs,
  member function get_column_pos(p_name varchar2) return number ,
  member procedure set_column_property(p_column_name varchar2, 
                                       p_rel_column  xxdoo_db_tab_column),
  member function get_pk_as_string return varchar2,
  member procedure ddl_table(o in out nocopy xxdoo_db_objects_db_list, p_position integer),
  member procedure ddl_table_create(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_table_alter(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_constraints(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_index(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_sequence(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_type(o in out nocopy xxdoo_db_objects_db_list, p_position integer),
  member procedure ddl_type_create(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_type_alter(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_collection(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_type_body(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_type_body_create(o in out nocopy xxdoo_db_objects_db_list),
  member procedure ddl_view(o in out nocopy xxdoo_db_objects_db_list),
  member procedure create_list_joins(p_scheme in out nocopy xxdoo_db_object, p_joins in out nocopy xxdoo_db_tab_joins),
  member procedure create_joins(p_scheme in out nocopy xxdoo_db_object)
)');
  --Коллекция 
  create_obj(p_name => l_cname,
             p_body => ' as table of ' || get_name(l_name));
  --
  --схема
  --authid current_user
  l_name  := 'scheme';
  create_obj(p_name => l_name,
             p_body => '  under '||get_name('object')||' (
  id               integer,
  name             varchar2(30),
  full_name        varchar2(12),
  owner            varchar2(10),
  table_list       ' || get_name('tables') || ',
  objects_list     ' || get_name('objects_db_list') || ',
  creation_date    date,
  last_update_date date,
  tmp_indexes      ' || get_name('indexes') || ',
  tmp_constraints  ' || get_name('constraints') || ',
  iterator         integer,
  --
  overriding member function get_type_name return varchar2,
  constructor function ' || get_name(l_name) || 
    ' return self as result,
  constructor function ' || get_name(l_name) || 
    '(p_name      varchar2) return self as result,
  constructor function ' || get_name(l_name) || 
    '(p_name      varchar2,
      p_owner     varchar2,
      p_full_name varchar2 default null) return self as result,
  member procedure build(p_owner varchar2, p_name varchar2, p_full_name varchar2),
  member procedure set_id,
  -- Add table
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     ' || get_name('tab_columns') || ',
                          p_indexes     ' || get_name('indexes') || ',
                          p_constraints ' || get_name('constraints') || ',
                          p_contents    ' || get_name('list_varchar2') || '),
  member procedure ctable(p_table_name  varchar2, 
                          p_contents    ' || get_name('list_varchar2') || '),
  member procedure ctable(p_table_name  varchar2, 
                          p_contents    varchar2),
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     ' || get_name('tab_columns') || ',
                          p_indexes     ' || get_name('indexes') || ',
                          p_constraints ' || get_name('constraints') || '),
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     ' || get_name('tab_columns') || ',
                          p_indexes     ' || get_name('indexes') || '),
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     ' || get_name('tab_columns') || ',
                          p_constraints ' || get_name('constraints') || '),
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     ' || get_name('tab_columns') || '),                        
  member procedure add_table(p_table xxdoo_db_table),
  member function c(p_name varchar2, 
                    p_column '||get_name('column_tmp')||') return '||get_name('column_tmp')||',
  member function c return '||get_name('column_tmp')||',
  member function get_table_pos(p_table_name varchar2) return number,
  member procedure prepare_tables(p_tab_pos number),
  member procedure prepare_types(p_tab_pos number),
  member procedure prepare_views(p_tab_pos number),
  member procedure prepare,
  member procedure prepare_views,
  member procedure show_drop_commands,
  member procedure generate,
  member procedure put
)');
  
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
