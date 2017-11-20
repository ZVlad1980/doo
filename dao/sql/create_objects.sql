declare
  --
  g_owner    varchar2(30) := 'xxdoo';
  g_dev_code varchar2(10) := 'xxdoo_db';
  l_table    varchar2(15);
  g_drop varchar2(32000);
  --
  procedure plog(p_msg in varchar2, p_eof in boolean default true) is
  begin
    if p_eof = true then
      dbms_output.put_line(p_msg);
    else
      dbms_output.put(p_msg);
    end if;
  end;
  --
  function get_name(p_name    varchar2,
                    p_type    in varchar2 default 'table',
                    p_postfix in varchar2 default null) return varchar2 is
  begin
    return replace(g_dev_code || '_' || p_name || '_' || nvl(p_postfix,
                                                             substr(p_type,
                                                                    1,
                                                                    1)),
                   '__',
                   '_');
  end;
  --
  procedure ei(p_type      in varchar2 default 'table',
               p_name      in varchar2,
               p_body      in varchar2,
               p_owner     in varchar2 default g_owner,
               p_operation in varchar2 default 'create',
               p_postfix   in varchar2 default null,
               p_add_type  in varchar2 default null) is
    l_object_exists_exc exception;
    pragma exception_init(l_object_exists_exc,
                          -955);
    l_element_exists_exc exception;
    pragma exception_init(l_element_exists_exc,
                          -1430);
    --
    l_name varchar2(30) := get_name(p_name    => p_name,
                                    p_type    => p_type,
                                    p_postfix => p_postfix);
    --
    l_add_type varchar2(100) := case
                                  when p_add_type is not null then
                                    p_add_type || ' '
                                end;
    --
    l_grants varchar2(200) := case
                                when p_type = 'table' then
                                  'select, update, insert, delete'
                                else
                                  'select'
                              end;
  begin
    if p_type = 'table' then
      g_drop := 'drop ' || p_type || ' ' || p_owner || '.' || l_name || ';' || chr(10) || g_drop;
    end if;
    --
    plog(p_operation || ' ' || l_add_type || p_type || ' ' || l_name || ' ... ',false);
    execute immediate p_operation || ' ' || l_add_type || p_type || ' ' || p_owner || '.' || l_name || ' ' || p_body;
    if p_operation = 'create' and p_type in ('table') then
      execute immediate 'grant '||l_grants||' on '||p_owner || '.' || l_name||' to apps with grant option';
    end if;
    plog('Ok');
  exception
    when l_object_exists_exc then
      if p_operation = 'create' and p_type in ('table') then
        execute immediate 'grant '||l_grants||' on '||p_owner || '.' || l_name||' to apps with grant option';
      end if;
      plog('exist');
    when l_element_exists_exc then
      plog('exist');
    when others then
      plog('error: ' || sqlerrm);
      plog(p_operation || ' ' || p_type || ' ' || p_owner || '.' || l_name || ' ' || p_body);
      raise;
  end;
  --
begin
  dbms_output.enable(100000);
  ei(p_type    => 'sequence',
     p_name    => '',
     p_postfix => 'seq',
     p_body    => ' start with 1 nocache');
  --
  --таблица схем
  --
  l_table := 'schemes';
  ei(p_name => l_table,
     p_body => '(
id               integer not null,
version          integer,
name             varchar2(12) not null,
full_name        varchar2(100),
owner            varchar2(10),
creation_date    date,
last_update_date date,
constraint '||get_name(l_table,null,null)||'pk
  primary key (id),
constraint '||get_name(l_table,null,null)||'uc
  unique(name)
)');
  --
  --таблица сущностей
  --xxdoo_db_table
  l_table := 'tables';
  ei(p_name => l_table,
     p_body => '(
id                integer not null,
scheme_id         integer not null,
version           integer,
owner	            varchar2(30),
entry_name	      varchar2(15),
name	            varchar2(32),
db_table          varchar2(32),
db_view           varchar2(32),
db_view_fast      varchar2(32),
db_type           varchar2(32),
db_coll_type      varchar2(32),
db_sequence       varchar2(32),
db_trigger        varchar2(32),
put_method        clob,
load_method       clob,
creation_date	    date,
last_update_date	date,
constraint '||get_name(l_table,null,null)||'pk
  primary key(id),
constraint '||get_name(l_table,null,null)||'fk
 foreign key(scheme_id)
 references '||get_name('schemes')||'(id)
 on delete cascade)');
  --
  ei(p_type    => 'unique index',
     p_name    => l_table,
     p_postfix => 'u1',
     p_body    => ' on ' || get_name(l_table) || '(name, scheme_id)');
  --
  ei(p_type    => 'unique index',
     p_name    => l_table,
     p_postfix => 'u2',
     p_body    => ' on ' || get_name(l_table) || '(entry_name, scheme_id)');
  --
  ei(p_type    => 'unique index',
     p_name    => l_table,
     p_postfix => 'u3',
     p_body    => ' on ' || get_name(l_table) || '(db_type, owner)');
  --
  --таблица для архива генерации объектов
  --
  l_table := 'tab_joins';
  ei(p_name => l_table,
     p_body => '(
  id            number,
  table_id      number,
  table_name    varchar2(32),
  column_name   varchar2(32),
  r_table_name  varchar2(32),
  condition_template varchar2(200),
constraint '||get_name(l_table,null,null)||'pk
 primary key (id),
constraint '||get_name(l_table,null,null)||'fk
 foreign key(table_id)
 references '||get_name('tables')||'(id)
 on delete cascade
)');
  --
  --таблица для архива генерации объектов
  --
  l_table := 'archive';
  ei(p_name => l_table,
     p_body => '(
id	          integer,
scheme_name   varchar2(12) not null,
creation_date timestamp default current_timestamp,
constraint '||get_name(l_table,null,null)||'pk
 primary key (id))');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(scheme_name)');
  --
  --таблица объектов БД (xxdoo_db_object_base)
  --
  l_table := 'archive_lines';
  ei(p_name => l_table,
     p_body => '(
id	        integer,
archive_id  integer,
position      integer,
type          varchar2(30),
owner         varchar2(30),
name          varchar2(120),
body          clob,
constraint '||get_name(l_table,null,null)||'pk
 primary key (id),
constraint '||get_name(l_table,null,null)||'fk
 foreign key(archive_id)
 references '||get_name('archive')||'(id)
 on delete cascade)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(archive_id)');
  --
  --
  --таблица колонок таблиц и типов (xxdoo_db_tab_column)
  --
  l_table := 'tab_columns';
  ei(p_name => l_table,
     p_body => '(
id	          integer,
table_id      integer,
name	        varchar2(30),
position      number,
type	        varchar2(120),
owner_type	  varchar2(32),
length	      number,
scale	        number,
nullable	    varchar2(1),
default_value	varchar2(100),
is_sequence   varchar2(1),
constraint '||get_name(l_table,null,null)||'pk
 primary key (id),
constraint '||get_name(l_table,null,null)||'fk
  foreign key(table_id)
  references '||get_name('tables')||'(id)
  on delete cascade
)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(table_id)');
  --
  -- ограничения таблиц(xxdoo_db_constraint)
  --
  l_table := 'constraints';
  ei(p_name => l_table,
     p_body => '(
id	              integer,
table_id          integer,
name	            varchar2(32),
type	            varchar2(1),
table_name        varchar2(32),
db_table_name     varchar2(32),
r_table_name	    varchar2(15),
r_constraint_name	varchar2(32),
r_type	          varchar2(20),
r_collection_name	varchar2(32),
update_rule       varchar2(50),
delete_rule       varchar2(50),
constraint '||get_name(l_table,null,null)||'pk
 primary key (id),
constraint '||get_name(l_table,null,null)||'fk
  foreign key(table_id)
  references '||get_name('tables')||'(id)
  on delete cascade
)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(table_id)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n2',
     p_body    => ' on ' || get_name(l_table) || '(name)');
  --
  -- колонки ограничений (xxdoo_db_column)
  --
  l_table := 'cons_columns';
  ei(p_name => l_table,
     p_body => '(
id	              integer,
constraint_id     integer,
name	            varchar2(32),
position          integer,
constraint '||get_name(l_table,null,null)||'pk
 primary key (id),
constraint '||get_name(l_table,null,null)||'fk
  foreign key(constraint_id)
  references '||get_name('constraints')||'(id)
  on delete cascade
)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(constraint_id)');
  --
  -- индексы таблиц(xxdoo_db_index)
  --
  l_table := 'indexes';
  ei(p_name => l_table,
     p_body => '(
id	              integer,
table_id          integer,
name	            varchar2(32),
uniqueness        varchar2(9),
constraint '||get_name(l_table,null,null)||'pk
 primary key (id),
constraint '||get_name(l_table,null,null)||'fk
  foreign key(table_id)
  references '||get_name('tables')||'(id)
  on delete cascade
)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(table_id)');
  --
  -- колонки индексов (xxdoo_db_column)
  --
  l_table := 'ind_columns';
  ei(p_name => l_table,
     p_body => '(
id	              integer,
index_id          integer,
name	            varchar2(32),
position          integer,
constraint '||get_name(l_table,null,null)||'pk
 primary key (id),
constraint '||get_name(l_table,null,null)||'fk
  foreign key(index_id)
  references '||get_name('indexes')||'(id)
  on delete cascade
)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(index_id)');
  --
  /*--
  -- индексы таблиц(xxdoo_db_index)
  --
  l_table := 'indexes';
  ei(p_name => l_table,
     p_body => '(
id	              number,
table_id          number,
name	            varchar2(32),
type	            varchar2(1),
--column_list	      xxdoo_db_columns
r_entity_name	    varchar2(15),
r_constraint_name	varchar2(32),
r_type	          varchar2(20),
r_collection_name	varchar2(32),
constraint '||get_name(l_table,null,null)||'pk
 primary key (id),
constraint '||get_name(l_table,null,null)||'fk
  foreign key(table_id)
  references '||get_name('tables')||'(id)
  on delete cascade
)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(table_id)');
  --
  --
  /*return;
  --
  --таблица индексов
  --
  l_table := 'indexes';
  ei(p_name => l_table,
     p_body => '(id number,
                 entity_id number,
                 idx       number,
                 version number,
                 name varchar2(30),
                 type varchar2(100),
                 fields varchar2(2000),
                 is_deleted  varchar2(1),
                 constraint '||get_name(l_table,null,null)||'fk
                  foreign key(entity_id)
                  references '||get_name('entities')||'(id)
                  on delete cascade
                )');
  --
  ei(p_type    => 'unique index',
     p_name    => l_table,
     p_postfix => 'u1',
     p_body    => ' on ' || get_name(l_table) || '(id)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(entity_id)');
  
  --
  --таблица полей объектных  типов БД
  --
  l_table := 'obj_columns';
  ei(p_name => l_table,
     p_body => '(id               number,
                 object_id        number,
                 idx              number,
                 name             varchar2(30),
                 type_owner       varchar2(30),
                 type             varchar2(106),
                 length           number,
                 accuracy         number, 
                 source_field     varchar2(30),
                 view_name        varchar2(30),
                 collect_name     varchar2(30),
                 target_entity_id number,
                 constraint '||get_name(l_table,null,null)||'pk
                  primary key (id),
                 constraint '||get_name(l_table,null,null)||'fk
                  foreign key(object_id)
                  references '||get_name('objects')||'(id)
                  on delete cascade
                )');
  --
  --
  --таблица полей
  --
  l_table := 'fields';
  ei(p_name => l_table,
     p_body => '(id	number,
                 entity_id	number,
                 idx        number,
                 version	  number,
                 name	      varchar2(30),
                 type	      varchar2(106),
                 length	    number,
                 accuracy	  number,
                 is_sequence	varchar2(1),
                 is_unique	varchar2(1),
                 is_null	varchar2(1),
                 is_pk	varchar2(1),
                 is_fk	varchar2(1),
                 is_bool	varchar2(1),
                 is_indexed	varchar2(1),
                 default_value	varchar2(200),
                 is_deleted  varchar2(1),
                 constraint '||get_name(l_table,null,null)||'_e_fk
                  foreign key(entity_id)
                  references '||get_name('entities')||'(id)
                  on delete cascade
                )');
  --
  ei(p_type    => 'unique index',
     p_name    => l_table,
     p_postfix => 'u1',
     p_body    => ' on ' || get_name(l_table) || '(id)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(entity_id)');
  --
  -- таблица связей
  --
  l_table := 'relationships';
  ei(p_name => l_table,
     p_body => '(id	              number not null,
                 entity_id        number not null,
                 idx              number,
                 type             varchar2(20) not null,
                 source_field_id  number not null,
                 target_entity_id number not null,
                 target_field_id  number not null,
                 collect_name     varchar2(30),
                 updated          varchar2(100),
                 deleted          varchar2(100),
                 is_deleted       varchar2(1),
                 constraint '||get_name(l_table,null,null)||'fk
                  foreign key(entity_id)
                  references '||get_name('entities')||'(id)
                  on delete cascade
                )');
  --
  ei(p_type    => 'unique index',
     p_name    => l_table,
     p_postfix => 'u1',
     p_body    => ' on ' || get_name(l_table) || '(id)');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(entity_id)');
  --
  --список значений (для простых справочников
  --
  l_table := 'entity_content';
  ei(p_name => l_table,
     p_body => '(entity_id number,
                 value     varchar2(4000),
                 constraint '||get_name(l_table,null,null)||'fk
                  foreign key(entity_id)
                  references '||get_name('entities')||'(id)
                  on delete cascade
                )');
  --
  ei(p_type    => 'index',
     p_name    => l_table,
     p_postfix => 'n1',
     p_body    => ' on ' || get_name(l_table) || '(entity_id)');
  --
  l_table := 'scripts';
  ei(p_name => l_table,
     p_body => '(id number,
                 name varchar2(100),
                 body clob
                ) on commit preserve rows',
     p_add_type => 'global temporary');
  --
  l_table := 'template_scr';
  ei(p_name => l_table,
     p_body => '(name varchar2(100),
                 script clob
                )');
  --*/
  plog('');
  plog(lpad('-',30,'-'));
  plog('DROP COMMANDS:');
  plog(g_drop,false);
  plog(lpad('-',30,'-'));
end;
/
--xxdoo_db_entities_t
--xxdoo_db_seq
