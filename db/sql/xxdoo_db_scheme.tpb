create or replace type body xxdoo_db_scheme is

  -- Member procedures and functions
  --
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_SCHEME');
  end get_type_name;
  --
  constructor function xxdoo_db_scheme return self as result is
  begin
    self.table_list := xxdoo_db_tables();
    --
    return;
  end;
  --
  constructor function xxdoo_db_scheme(p_name      varchar2) return self as result is
  begin
    select value(s)
    into   self
    from   xxdoo_db_schemes_v s
    where  s.name = p_name;
    --
    self.objects_list := xxdoo_db_objects_db_list(self.owner);
    --
    return;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  constructor function xxdoo_db_scheme(p_name      varchar2,
                                       p_owner     varchar2,
                                       p_full_name varchar2 default null) return self as result is
  begin
    begin
      self := xxdoo_db_scheme(p_name);
    exception
      when no_data_found then
        xxdoo_db_utils_pkg.init_exceptions;
        self.build(p_owner, p_name, p_full_name);
    end;
    --
    return;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  member procedure build(p_owner varchar2, p_name varchar2, p_full_name varchar2) is
  begin
    self := xxdoo_db_scheme;
    self.owner := p_owner;
    self.name  := p_name;
    self.full_name := p_full_name;
    self.objects_list := xxdoo_db_objects_db_list(self.owner);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end build;
  --
  --
  --
  member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_db_seq.nextval();
    end if;
    --
    for c in 1..self.table_list.count loop
      self.table_list(c).set_id;
    end loop;
  end;
  --
  --Создание таблицы
  --
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     xxdoo_db_tab_columns,
                          p_indexes     xxdoo_db_indexes,
                          p_constraints xxdoo_db_constraints,
                          p_contents    xxdoo_db_list_varchar2) is
             
  begin
    --
    self.add_table(xxdoo_db_table(self.owner,
                                  self.name,
                                  p_table_name ,
                                  p_columns    ,
                                  p_indexes    ,
                                  p_constraints,
                                  p_contents));
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ctable(p_table_name varchar2, p_contents xxdoo_db_list_varchar2) is
    cursor l_content_max_length is
      select max(length(column_value))
      from   table(p_contents);
    l_length number;
  begin
    --
    open l_content_max_length;
    fetch l_content_max_length into l_length;
    close l_content_max_length;
    --
    self.ctable(p_table_name  => p_table_name,
                p_columns     => xxdoo_db_tab_columns(
                                   self.c('id', self.c().cvarchar(l_length).pk)
                                 ),
                p_indexes     => null,
                p_constraints => null,
                p_contents    => p_contents);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ctable(p_table_name varchar2, p_contents varchar2) is
    --
    l_contents xxdoo_db_list_varchar2;
    --
    cursor l_contents_cur is
      select regexp_substr(p_contents,'[^/ ]+',1,level)
      from   dual
      connect by regexp_substr(p_contents,'[^/ ]+',1,level)  is not null
      order by level desc;
    --
  begin
    --
    open l_contents_cur;
    fetch l_contents_cur bulk collect into l_contents;
    close l_contents_cur;
    --
    self.ctable(p_table_name => p_table_name, p_contents => l_contents);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     xxdoo_db_tab_columns,
                          p_indexes     xxdoo_db_indexes,
                          p_constraints xxdoo_db_constraints) is
  begin
    --
    self.ctable(p_table_name  => p_table_name,
                p_columns     => p_columns,
                p_indexes     => p_indexes,
                p_constraints => p_constraints,
                p_contents    => null);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     xxdoo_db_tab_columns,
                          p_indexes     xxdoo_db_indexes) is
  begin
    --
    self.ctable(p_table_name  => p_table_name,
                p_columns     => p_columns,
                p_indexes     => p_indexes,
                p_constraints => null,
                p_contents    => null);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     xxdoo_db_tab_columns,
                          p_constraints xxdoo_db_constraints) is
  begin
    --
    self.ctable(p_table_name  => p_table_name,
                p_columns     => p_columns,
                p_indexes     => null,
                p_constraints => p_constraints,
                p_contents    => null);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ctable(p_table_name  varchar2, 
                          p_columns     xxdoo_db_tab_columns) is
  begin
    --
    self.ctable(p_table_name  => p_table_name,
                p_columns     => p_columns,
                p_indexes     => null,
                p_constraints => null,
                p_contents    => null);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member function get_table_pos(p_table_name varchar2) return number is
    l_result number;
  begin
    for t in 1..self.table_list.count loop
      if self.table_list(t).name = p_table_name then
        l_result := t;
        exit;
      end if;
    end loop;
    --
    return l_result;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  /*
  member procedure prepare_constraints(pos number) is
    --
    type l_num_list_typ is table of number index by varchar2(1);
    l_num_list l_num_list_typ;
    --
    cursor l_constraint_cur(p_rel_table_name varchar2) is
      select c.name,
             t.db_table,
             c.column_list, 
             value(tc) pk_column
      from   table(self.table_list) t,
             table(t.constraints)   c,
             table(c.column_list)   cc,
             table(t.column_list)   tc
      where  1=1
      and    tc.name = cc.name
      and    cc.position = 1
      and    c.type = 'P'
      and    t.name = p_rel_table_name;
    --
    l_rel_pos number;
    --
    l_pk_column xxdoo_db_tab_column;
  begin
    for c in 1..self.table_list(pos).constraints.count loop
      --
      if l_num_list.exists(self.table_list(pos).constraints(c).type) then
        l_num_list(self.table_list(pos).constraints(c).type) := nvl(l_num_list(self.table_list(pos).constraints(c).type),0) + 1;
      else
        l_num_list(self.table_list(pos).constraints(c).type) := 1;
      end if;
      --
      if self.table_list(pos).constraints(c).type = 'R' then
        --self.table_list(pos).constraints(c).db_table := self.table_list(pos).db_table;
        if self.table_list(pos).constraints(c).r_constraint_name is null then
          open l_constraint_cur(self.table_list(pos).constraints(c).r_table_name);
          fetch l_constraint_cur 
            into self.table_list(pos).constraints(c).r_constraint_name,
                 self.table_list(pos).constraints(c).r_db_table,
                 self.table_list(pos).constraints(c).r_column_list,
                 l_pk_column;
          --
--          self.table_list(pos).constraints(c).db_table := self.table_list(pos).db_table;
          --
          if l_constraint_cur%notfound = true then
            close l_constraint_cur;
            xxdoo_db_utils_pkg.fix_exception('Relationship constraint not found: table '||self.table_list(pos).name||
              ', relation_table ' || self.table_list(pos).constraints(c).r_table_name);
            raise apps.fnd_api.g_exc_error;
          end if;
          --
          self.table_list(pos).set_column_property(p_column_name => self.table_list(pos).constraints(c).column_list(1).name,
                                                   p_rel_column  => l_pk_column);
          --
          close l_constraint_cur;
        end if;
        --
        l_rel_pos := get_table_pos(self.table_list(pos).constraints(c).r_table_name);
        --
        if self.table_list(pos).constraints(c).r_type = 'COLLECTION' then
          --l_rel_pos := get_table_pos(self.table_list(pos).constraints(c).r_table_name);
          self.table_list(l_rel_pos).add_attribute(
            xxdoo_db_attribute(p_name              => self.table_list(pos).constraints(c).r_collection_name,
                               p_column_name       => null,
                               p_owner_type        => self.owner,
                               p_type              => self.table_list(pos).db_coll_type,
                               p_type_code         => 'COLLECTION',
                               p_column_list       => self.table_list(pos).constraints(c).r_column_list,
                               p_r_table_name      => self.table_list(pos).name,
                               p_r_constraint_name => self.table_list(pos).constraints(c).name,
                               p_r_db_table        => self.table_list(pos).db_table    ,
                               p_r_db_type         => self.table_list(pos).db_type     ,
                               p_r_db_coll_type    => self.table_list(pos).db_coll_type,
                               p_r_db_view         => self.table_list(pos).db_view,
                               p_r_db_view_fast    => self.table_list(pos).db_view_fast,
                               p_r_column_list     => self.table_list(pos).constraints(c).column_list
            )
          );
        elsif self.table_list(pos).constraints(c).r_type in ('OBJECT','FK') then
          self.table_list(pos).add_attribute(
            xxdoo_db_attribute(p_name              => self.table_list(pos).constraints(c).column_list(1).name,
                               p_column_name       => self.table_list(pos).constraints(c).column_list(1).name,
                               p_owner_type        => self.owner,
                               p_type              => self.table_list(l_rel_pos).db_type,
                               p_type_code         => self.table_list(pos).constraints(c).r_type,
                               p_column_list       => self.table_list(pos).constraints(c).column_list,
                               p_r_table_name      => self.table_list(l_rel_pos).name,
                               p_r_constraint_name => self.table_list(pos).constraints(c).name,
                               p_r_db_table        => self.table_list(l_rel_pos).db_table    ,
                               p_r_db_type         => self.table_list(l_rel_pos).db_type     ,
                               p_r_db_coll_type    => self.table_list(l_rel_pos).db_coll_type,
                               p_r_db_view         => self.table_list(l_rel_pos).db_view,
                               p_r_db_view_fast    => self.table_list(l_rel_pos).db_view_fast,
                               p_r_column_list     => self.table_list(pos).constraints(c).r_column_list
             )
          );
        end if;
        --
      end if;
      --
      self.table_list(pos).constraints(c).set_name(p_owner      => self.owner, 
                                                   p_table_name => self.table_list(pos).db_table,
                                                   p_cons_name  => self.name ||'_'|| self.table_list(pos).name,
                                                   p_cons_num   => l_num_list(self.table_list(pos).constraints(c).type));
      --
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end prepare_constraints;
  
  --*/
  --
  --
  member procedure add_table(p_table xxdoo_db_table) is
    pos number;
  begin
    pos := get_table_pos(p_table.name);
    if pos is null then
      self.table_list.extend;
      pos := self.table_list.count;
      self.table_list(pos) := p_table;
    else
      self.table_list(pos).merge(p_table);
    end if;
    --
    if p_table.name = 'contractors' then
      null;
    end if;
    self.table_list(pos).prepare(self);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member function c(p_name varchar2, p_column xxdoo_db_column_tmp) return xxdoo_db_column_tmp is
  begin
    return xxdoo_db_column_tmp(p_name, p_column);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end c;
  --
  ---
  --
  member function c return xxdoo_db_column_tmp is
  begin
    return xxdoo_db_column_tmp();
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end c;
  --
  --
  --
  member procedure prepare_tables(p_tab_pos number) is
    l_tab_pos number;
  begin
    if self.table_list(p_tab_pos).status = 'TABLE' then
      return;
    end if;
    --
    self.table_list(p_tab_pos).status := 'PREPARE_TABLE';
    --
    for c in 1..self.table_list(p_tab_pos).constraints.count loop
      if self.table_list(p_tab_pos).constraints(c).type = 'R' then
        if self.table_list(p_tab_pos).constraints(c).r_table_name <> '#self' then
          l_tab_pos := get_table_pos(self.table_list(p_tab_pos).constraints(c).r_table_name);
          --
          if self.table_list(l_tab_pos).status = 'PREPARE_TABLE' then
            xxdoo_db_utils_pkg.fix_exception('prepare table '||self.table_list(l_tab_pos).name||' circle error.');
            raise apps.fnd_api.g_exc_error;
          else
            self.prepare_tables(l_tab_pos);
          end if;
        end if;
      end if;
    end loop;
    --
    self.table_list(p_tab_pos).ddl_table(self.objects_list,self.iterator);
    self.iterator := self.iterator + 1;
    self.table_list(p_tab_pos).status := 'TABLE';
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('prepare tables '||self.table_list(p_tab_pos).name||' error.');
      raise;
  end prepare_tables;
  --
  --
  --
  member procedure prepare_types(p_tab_pos number) is
    l_tab_pos number;
    --
    cursor l_attr_obj_cur is
      select a.r_table_name table_name
      from   table(self.table_list(p_tab_pos).attribute_list) a
      where  1=1
      and    upper(a.type) <> upper(self.table_list(p_tab_pos).db_coll_type)
      and    upper(a.type) <> upper(self.table_list(p_tab_pos).db_type)
      and    a.type_code in ('OBJECT','COLLECTION')
      and    a.member_type = 'A';
  begin
    if self.table_list(p_tab_pos).status = 'TYPE' then
      return;
    end if;
    --
    self.table_list(p_tab_pos).status := 'PREPARE_TYPE';
    --
    self.table_list(p_tab_pos).prepare_attributes(self);
    --
    for a in l_attr_obj_cur loop
      l_tab_pos :=  get_table_pos(a.table_name);
      if self.table_list(l_tab_pos).status = 'PREPARE_TYPE' then
        xxdoo_db_utils_pkg.fix_exception('prepare type '||self.table_list(l_tab_pos).name||' circle error.');
        raise apps.fnd_api.g_exc_error;
      else
        self.prepare_types(l_tab_pos);
      end if;
      --
    end loop;
    --
    
    self.table_list(p_tab_pos).ddl_type(self.objects_list, self.iterator);
    self.iterator := self.iterator + 1;
    self.table_list(p_tab_pos).status := 'TYPE';
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('prepare_types table '||self.table_list(p_tab_pos).name||' error.');
      raise;
  end prepare_types;
  --
  --
  --
  member procedure prepare_views(p_tab_pos number) is
    l_tab_pos number;
    --
    cursor l_attr_obj_cur is
      select a.r_table_name table_name
      from   table(self.table_list(p_tab_pos).attribute_list) a
      where  1=1
      and    upper(a.type) <> upper(self.table_list(p_tab_pos).db_coll_type)
      and    upper(a.type) <> upper(self.table_list(p_tab_pos).db_type)
      and    a.type_code in ('OBJECT','COLLECTION')
      and    a.member_type = 'A';
  begin
    if self.table_list(p_tab_pos).status = 'VIEW' then
      return;
    end if;
    --
    self.table_list(p_tab_pos).status := 'PREPARE_VIEW';
    --
    for a in l_attr_obj_cur loop
      l_tab_pos :=  get_table_pos(a.table_name);
      if self.table_list(l_tab_pos).status = 'PREPARE_VIEW' then
        xxdoo_db_utils_pkg.fix_exception('prepare view '||self.table_list(l_tab_pos).name||' circle error.');
        raise apps.fnd_api.g_exc_error;
      else
        self.prepare_views(l_tab_pos);
      end if;
      --
    end loop;
    --
    self.table_list(p_tab_pos).prepare_view_attrs;
    self.table_list(p_tab_pos).ddl_view(self.objects_list);
    self.table_list(p_tab_pos).status := 'VIEW';
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('prepare_views table '||self.table_list(p_tab_pos).name||' error.');
      raise;
  end prepare_views;
  --
  --
  --
  member procedure prepare is
  begin
    self.iterator := 1;
    for t in 1..self.table_list.count loop
      self.prepare_tables(t);
    end loop;
    --
    self.iterator := 1;
    for t in 1..self.table_list.count loop
      self.prepare_types(t);
    end loop;
    --
    for t in 1..self.table_list.count loop
      self.table_list(t).ddl_type_body(self.objects_list);
    end loop;
    --
    self.objects_list.put(self.name);
    --
  exception
    when others then
      self.objects_list.put(self.name);
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end prepare;
  --
  --
  --
  member procedure prepare_views is
  begin
    for t in 1..self.table_list.count loop
      if xxdoo_db_utils_pkg.is_object_exists(p_owner => self.owner,
                                             p_name  => self.table_list(t).db_table) = true and
         xxdoo_db_utils_pkg.is_object_exists(p_owner        => self.owner,
                                             p_name         => self.table_list(t).db_type,
                                             p_object_type  => 'TYPE') = true  then                                  
        self.prepare_views(t);
      end if;
    end loop;
    self.objects_list.put(self.name);
  exception
    when others then
      self.objects_list.put(self.name);
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure show_drop_commands is
    cursor l_drop_tables_cur is
      select t.db_table, t.db_sequence, t.db_trigger
      from   table(self.table_list) t
      order by t.position_tab desc;
    cursor l_drop_types_cur is
      select t.db_coll_type, t.db_type, t.db_view
      from   table(self.table_list) t
      order by t.position_typ desc;
  begin
    --self.objects_list.invoke;
    --show drop
    for t in l_drop_types_cur loop
      dbms_output.put_line('drop view '||self.owner||'.'||t.db_view||';');
    end loop;
    for t in l_drop_tables_cur loop
      dbms_output.put_line('drop table '||self.owner||'.'||t.db_table||';');
      if t.db_sequence is not null then
        dbms_output.put_line('drop sequence '||self.owner||'.'||t.db_sequence||';');
      end if;
    end loop;
    for t in l_drop_types_cur loop
      dbms_output.put_line('drop type '||self.owner||'.'||t.db_coll_type||';');
      dbms_output.put_line('drop type '||self.owner||'.'||t.db_type||';');
    end loop;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end show_drop_commands;
  --
  --
  --
  member procedure generate is
  begin
    self.prepare;
    self.objects_list.invoke;
    xxdoo_db_utils_pkg.seq_init;
    xxdoo_db_utils_pkg.change_type_init;
    self.prepare_views;
    self.objects_list.invoke;
    --
    for t in 1..self.table_list.count loop
      self.table_list(t).create_joins(self);
    end loop;
    --
    self.show_drop_commands;
    --
    self.put;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end generate;
  --
  --
  --
  member procedure put is
    pragma autonomous_transaction;
  begin
    self.set_id;
    merge into xxdoo_db_schemes_t s
    using (select self.id        id,
                  self.name      name,
                  self.full_name full_name,
                  self.owner     owner,
                  sysdate        event_date
           from   dual
          ) u
    on    (s.id = u.id)
    when matched then
      update set    
        s.version = nvl(s.version,0) + 1,
        s.last_update_date = u.event_date
    when not matched then
      insert(s.id,s.version,s.name,s.full_name,s.owner,s.creation_date,s.last_update_date)
      values(u.id,1,u.name,u.full_name,u.owner,u.event_date,u.event_date);
    --
    merge into xxdoo_db_tables_t s
    using (select t.id           id,
                  self.id        scheme_id,
                  t.owner        owner,
                  t.entry_name   entry_name,
                  t.name         name,
                  t.db_table     db_table    ,
                  t.db_view      db_view     ,
                  t.db_view_fast db_view_fast,
                  t.db_type      db_type     ,
                  t.db_coll_type db_coll_type,
                  t.db_sequence  db_sequence ,
                  t.pk_template  pk_template,
                  t.pk_joins_template pk_joins_template,
                  sysdate        event_date
           from   table(self.table_list) t
          ) u
    on    (s.id = u.id)
    when matched then
      update set    
        s.version = nvl(s.version,0) + 1,
        s.db_sequence = db_sequence,
        s.last_update_date = u.event_date,
        s.pk_template       = u.pk_template ,     
        s.pk_joins_template = u.pk_joins_template
    when not matched then
      insert(s.id,
             s.scheme_id,
             s.version,
             s.owner,
             s.name,
             s.entry_name,
             s.db_table,
             s.db_view,
             s.db_view_fast,
             s.db_type,
             s.db_coll_type,
             s.db_sequence,
             s.pk_template   ,   
             s.pk_joins_template,
             s.creation_date,
             s.last_update_date)
      values(u.id,
             u.scheme_id,
             1,
             u.owner,
             u.name,
             u.entry_name,
             u.db_table,
             u.db_view,
             u.db_view_fast,
             u.db_type,
             u.db_coll_type,
             u.db_sequence,
             u.pk_template      ,
             u.pk_joins_template,
             u.event_date,
             u.event_date);
    --
    delete from xxdoo_db_tables_t t
    where 1=1
    and   t.scheme_id = self.id
    and   t.id not in (
            select t.id
            from   table(self.table_list) t
          );
    --
    merge into xxdoo_db_tab_joins_t s
    using (select j.id                 id,
                  t.id                 table_id,
                  j.table_name         table_name,
                  j.column_name        column_name,
                  j.r_table_name       r_table_name,
                  j.condition_template condition_template,
                  j.r_type
           from   table(self.table_list) t,
                  table(t.joins)         j
          ) u
    on    (s.id = u.id)
    when matched then
      update set    
        s.r_table_name       = u.r_table_name,
        s.condition_template = u.condition_template,
        s.r_type             = u.r_type
    when not matched then
      insert(s.id,
             s.table_id,
             s.table_name,
             s.column_name,
             s.r_table_name,
             s.condition_template,
             s.r_type
             )
      values(u.id,
             u.table_id,
             u.table_name,
             u.column_name,
             u.r_table_name,
             u.condition_template,
             u.r_type);
    --
    delete from xxdoo_db_tab_joins_t t
    where 1=1
    and   t.table_id in (select tt.id
                         from   table(self.table_list) tt)
    and   t.id not in (
            select j.id
            from   table(self.table_list) t,
                   table(t.joins)         j
          );
    --
    merge into xxdoo_db_tab_columns_t s
    using (select tc.id            id,
                  t.id             table_id,
                  tc.name          name         ,
                  tc.nullable      nullable     ,
                  tc.default_value default_value,
                  tc.length        length       ,
                  tc.scale         scale        ,
                  tc.type          type         ,
                  tc.is_sequence   is_sequence  
           from   table(self.table_list) t,
                  table(t.column_list)   tc
          ) u
    on    (s.id = u.id)
    when matched then
      update set    
        s.nullable = u.nullable,
        S.default_value = u.default_value,
        s.is_sequence = u.is_sequence
    when not matched then
      insert(s.id,
             s.table_id,
             s.name,
             s.nullable,
             s.default_value,
             s.length,
             s.scale,
             s.type,
             s.is_sequence)
      values(u.id,
             u.table_id,
             u.name,
             u.nullable,
             u.default_value,
             u.length,
             u.scale,
             u.type,
             u.is_sequence);
    --
    delete from xxdoo_db_tab_columns_t c
    where  1=1
    and    c.table_id in (
             select t.id
             from   table(self.table_list) t
           )
    and    c.id not in (
             select c.id
             from   table(self.table_list) t,
                    table(t.column_list)   c
           );
    --
    merge into xxdoo_db_constraints_t s
    using (select c.id                id,
                  t.id                table_id,
                  c.name              name             ,
                  c.type              type             ,
                  c.table_name        table_name       ,
                  c.db_table_name     db_table_name    ,
                  c.r_table_name      r_table_name     ,
                  c.r_constraint_name r_constraint_name,
                  c.r_type            r_type           ,
                  c.r_collection_name r_collection_name,
                  c.delete_rule       delete_rule      ,
                  c.update_rule       update_rule      ,
                  c.join_template     join_template
           from   table(self.table_list) t,
                  table(t.constraints)   c
          ) u
    on    (s.id = u.id)
    when matched then
      update set   
        s.type          = u.type, 
        s.delete_rule   = u.delete_rule,
        S.update_rule   = u.update_rule,
        s.join_template = u.join_template
    when not matched then
      insert(s.id,
             s.table_id,
             s.name,
             s.type,
             s.table_name,
             s.db_table_name,
             s.r_table_name,
             s.r_constraint_name,
             s.r_type,
             s.r_collection_name,
             s.delete_rule,
             s.update_rule,
             s.join_template)
      values(u.id,
             u.table_id,
             u.name,
             u.type,
             u.table_name,
             u.db_table_name,
             u.r_table_name,
             u.r_constraint_name,
             u.r_type,
             u.r_collection_name,
             u.delete_rule,
             u.update_rule,
             u.join_template);
    --
    delete from xxdoo_db_constraints_t c
    where  1=1
    and    c.table_id in (
             select t.id
             from   table(self.table_list) t
           )
    and    c.id not in (
             select c.id
             from   table(self.table_list) t,
                    table(t.constraints)   c
           );
    --
    merge into xxdoo_db_cons_columns_t s
    using (select c.id       id,
                  tc.id      constraint_id,
                  c.name     name,
                  c.position position
           from   table(self.table_list) t,
                  table(t.constraints)   tc,
                  table(tc.column_list)  c
          ) u
    on    (s.id = u.id)
    when not matched then
      insert(s.id,
             s.constraint_id,
             s.name,
             s.position)
      values(u.id,
             u.constraint_id,
             u.name,
             u.position);
    --
    merge into xxdoo_db_indexes_t s
    using (select c.id         id,
                  t.id         table_id,
                  c.name       name,
                  c.uniqueness uniqueness
           from   table(self.table_list) t,
                  table(t.index_list)   c
          ) u
    on    (s.id = u.id)
    when not matched then
      insert(s.id,
             s.table_id,
             s.name,
             s.uniqueness)
      values(u.id,
             u.table_id,
             u.name,
             u.uniqueness);
    --
    delete from xxdoo_db_indexes_t c
    where  1=1
    and    c.table_id in (
             select t.id
             from   table(self.table_list) t
           )
    and    c.id not in (
             select c.id
             from   table(self.table_list) t,
                    table(t.index_list)   c
           );
    --
    merge into xxdoo_db_ind_columns_t s
    using (select c.id       id,
                  tc.id      index_id,
                  c.name     name,
                  c.position position
           from   table(self.table_list) t,
                  table(t.index_list)   tc,
                  table(tc.column_list)  c
          ) u
    on    (s.id = u.id)
    when not matched then
      insert(s.id,
             s.index_id,
             s.name,
             s.position)
      values(u.id,
             u.index_id,
             u.name,
             u.position);
    --
    commit;
    --
  exception
    when others then
      rollback;
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  /*--
  --
  --
  member function set_property(p_type          varchar2,
                               p_length        number,
                               p_scale         number,
                               p_sequence      varchar2,
                               p_unique        varchar2,
                               p_nullable      varchar2,
                               p_pk            varchar2,
                               p_fk            varchar2,
                               p_indexed       varchar2,
                               p_default_value varchar2) return xxdoo_db_scheme is
    l_self xxdoo_db_scheme := self;
  begin
    --
    l_self.field_tmp.type          := nvl(p_type         , l_self.field_tmp.type         );
    l_self.field_tmp.length        := nvl(p_length       , l_self.field_tmp.length       );
    l_self.field_tmp.accuracy      := nvl(p_accuracy     , l_self.field_tmp.accuracy     );
    l_self.field_tmp.is_sequence   := nvl(p_is_sequence  , l_self.field_tmp.is_sequence  );
    l_self.field_tmp.is_unique     := nvl(p_is_unique    , l_self.field_tmp.is_unique    );
    l_self.field_tmp.is_null       := nvl(p_is_null      , l_self.field_tmp.is_null      );
    l_self.field_tmp.is_pk         := nvl(p_is_pk        , l_self.field_tmp.is_pk        );
    l_self.field_tmp.is_fk         := nvl(p_is_fk        , l_self.field_tmp.is_fk        );
    l_self.field_tmp.is_bool       := nvl(p_is_bool      , l_self.field_tmp.is_bool      );
    l_self.field_tmp.is_indexed    := nvl(p_is_indexed   , l_self.field_tmp.is_indexed   );
    l_self.field_tmp.default_value := nvl(p_default_value, l_self.field_tmp.default_value);
    --
    return l_self;
  end;
/*constructor function xxdoo_db_scheme(p_name     varchar2,
                                       p_dev_code varchar2,
                                       p_owner    varchar2) return self as result is
  begin
    --self := xxdoo_db_scheme_typ.get_from_name(p_name);
    --
    
    if self.id is null then
      self := xxdoo_db_scheme;
      self.name     := p_name;
      self.dev_code := substr(nvl(p_dev_code,p_name),1,12);
      self.owner    := nvl(p_owner,'xxdoo');
      self.db_objects := xxdoo_db_objects_base();
    else
      --
      if self.table_list is null then
        self.table_list := xxdoo_db_tables();
      end if;
      --
      self.column_list := xxdoo_db_columns_tmp();
    end if;
    --
    return;
  end;
  --
  member procedure set_id is
    --
  begin
    if self.id is null then
      self.id := xxdoo_db_seq.nextval();
    end if;
    --
    for e in 1..self.table_list.count loop
      --
      self.table_list(e).set_id;
      --
    end loop;
    --
    for o in 1..self.db_objects.count loop
      if self.db_objects(o).id is null then 
        self.db_objects(o).id := xxdoo_db_seq.nextval();
      end if;
    end loop;
    --
  end;
  --
  member procedure get(p_scheme_id number) is
  begin 
    select value(s)
    into   self
    from   xxdoo_db_schemes_v s
    where  s.id = p_scheme_id;
    --
  end;
  --
  member procedure put is
    --
  begin 
    if self.name is null then
      dbms_output.put_line('The name of the scheme can''t be empty');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    self.set_id;
    --
    xxdoo_db_engine_pkg.put(self);
    --
  end;
  --
  static function get_from_name(p_name varchar2) return xxdoo_db_scheme is
    l_result xxdoo_db_scheme;
  begin 
    select value(s)
    into   l_result
    from   xxdoo.xxdoo_db_schemes_v s
    where  s.name = p_name;
    --
    return l_result;
    --
  exception
    when no_data_found then
      return null;
  end;
  
  --
  member function get_entity_num(p_name varchar2) return number is
  begin
    for e in 1..self.entities.count loop
      if self.entities(e).name = p_name then
        return e;
      end if;
    end loop;
    --
    return null;
  end;
  --
  
  --
  member function get_object_num(p_name varchar2, p_type varchar2) return number is
    l_name varchar2(200);
  begin
    for o in 1..self.db_objects.count loop
      l_name := self.db_objects(o).name;
      if self.db_objects(o).name = p_name and self.db_objects(o).type = p_type then
        return o;
      end if;
    end loop;
    --
    return null;
  end;
  --
  --
  --
  member procedure add_object(p_object in out nocopy xxdoo_db_object) is
    l_obj_num number := get_object_num(p_object.name,p_object.type);
  begin
    if l_obj_num is null then
      self.db_objects.extend;
      l_obj_num := self.db_objects.count;
    else
      p_object.id := self.db_objects(l_obj_num).id;
    end if;
    --
    p_object.scheme_id := self.id;
    self.seq_nextval;
    p_object.idx := self.seq_num;
    self.db_objects(l_obj_num) := p_object;
  end;
  --
  
  --
  member procedure ctable(p_table_name varchar2, 
                          p_fields     xxdoo_db_fields,
                          p_indexes    xxdoo_db_indexes) is
    --
    l_entity xxdoo_db_entity;
  begin
    --
    l_entity := xxdoo_db_entity(p_table_name, p_fields, p_indexes, null);
    self.add_entity(l_entity);
    self.indexes_tmp := null;
    --
  end;
  --
  member function cvarchar(p_length number)  return xxdoo_db_scheme is
  begin
    return f(p_type => 'varchar2', p_length => p_length);
  end;
  --
  member function  text return xxdoo_db_scheme is
  begin
    return f(p_type => 'varchar2', p_length => 240);
  end;
  --
  member function cint return xxdoo_db_scheme is
  begin
    return f(p_type => 'number');
  end;
  --
  member function cdecimal(p_length number, p_accuracy number) return xxdoo_db_scheme is
  begin
    return f(p_type => 'number',p_length => p_length, p_accuracy => p_accuracy);
  end;
  --
  member function  cnumber(p_length number, p_accuracy number) return xxdoo_db_scheme is
  begin
    return f(p_type => 'number',p_length => p_length, p_accuracy => p_accuracy);
  end;
  --
  member function  cdate return xxdoo_db_scheme is
  begin
    return f(p_type => 'date');
  end;
  --
  member function  cbool return xxdoo_db_scheme is
  begin
    return f(p_is_bool => 'Y');
  end;
  --
  member function  ctimestamp return xxdoo_db_scheme is
  begin
    return f(p_type => 'timestamp');
  end;
  --
  member function  cdatetime return xxdoo_db_scheme is
  begin
    return f(p_type => 'date');
  end;
  --
  member function cclob return xxdoo_db_scheme is
  begin
    return f(p_type => 'clob');
  end;
  --
  member function  csequence   return xxdoo_db_scheme is
  begin
    return f(p_is_sequence => 'Y');
  end;
  --
  member function  pk  return xxdoo_db_scheme is
  begin
    return f(p_is_pk => 'Y');
  end;
  --
  member function  notNull  return xxdoo_db_scheme is
  begin
    return f(p_is_null => 'N');
  end;
  --
  member function  cunique  return xxdoo_db_scheme is
  begin
    return f(p_is_unique => 'Y', p_is_indexed => 'Y');
  end;
  --
  member function  cdefault(p_value varchar2) return xxdoo_db_scheme is
  begin
    return f(p_default_value => p_value);
  end;
  --
  member function  tables(p_name varchar2) return xxdoo_db_scheme is
    l_self xxdoo_db_scheme := f(p_is_fk => 'Y');
  begin
    return l_self.r(p_type => 'OBJECT', p_target_entity => p_name);
  end;
  --
  member function  referenced(p_value varchar2) return xxdoo_db_scheme is
  begin
    return r(p_type => 'COLLECTION', p_collect_name => p_value);
  end;
  --
  member function fk return xxdoo_db_scheme is
    l_self xxdoo_db_scheme := self;--f(p_is_fk => 'Y');
  begin
    return l_self.r(p_type => 'FK');
  end;
  --
  member function  changed(p_value varchar2) return xxdoo_db_scheme is
  begin
    return r(p_updated => p_value,
             p_deleted => p_value);
  end;
  --
  member function  updated(p_value varchar2) return xxdoo_db_scheme is
  begin
    return r(p_updated => p_value);
  end;
  --
  member function  deleted(p_value varchar2) return xxdoo_db_scheme is
  begin
    return r(p_deleted => p_value);
  end;
  --
  member function  self return xxdoo_db_scheme is
    l_self xxdoo_db_scheme := f(p_is_fk => 'Y');
  begin
    return l_self.r(p_type => 'OBJECT', p_target_entity => '#self');
  end;
  --
  member function indexed return xxdoo_db_scheme is
  begin
    return f(p_is_indexed => 'Y');
  end;
  --
  
  --
  member function i(p_name   varchar2,
                    p_type   varchar2,
                    p_fields varchar2) return xxdoo_db_index_typ is
  begin
    return xxdoo_db_index_typ(p_name   => p_name  , 
                              p_type   => p_type  , 
                              p_fields => p_fields);
  end;
  --
  --
  --
  member function r(p_type          varchar2 default null,
                    p_target_entity varchar2 default null,
                    p_collect_name  varchar2 default null,
                    p_updated       varchar2 default null,
                    p_deleted       varchar2 default null) return xxdoo_db_scheme is
    l_self xxdoo_db_scheme := self;
    --
    cursor l_pk_field_cur(p_entity_name varchar2) is
      select e.entry_name,f.name,f.type,f.length,f.accuracy
      from   table(self.entities) e,
             table(e.fields)      f
      where  1=1
      and    f.is_pk = 'Y'
      and    e.name = p_entity_name;
  begin
    l_self.field_tmp.relationship_tmp.type           := nvl(p_type         , l_self.field_tmp.relationship_tmp.type         );
    l_self.field_tmp.relationship_tmp.target_entity  := nvl(p_target_entity, l_self.field_tmp.relationship_tmp.target_entity);
    l_self.field_tmp.relationship_tmp.collect_name   := nvl(p_collect_name , l_self.field_tmp.relationship_tmp.collect_name );
    l_self.field_tmp.relationship_tmp.updated        := nvl(p_updated      , l_self.field_tmp.relationship_tmp.updated      );
    l_self.field_tmp.relationship_tmp.deleted        := nvl(p_deleted      , l_self.field_tmp.relationship_tmp.deleted      );
    --
    if l_self.field_tmp.relationship_tmp.target_field is null then
      open l_pk_field_cur(l_self.field_tmp.relationship_tmp.target_entity);
      fetch l_pk_field_cur 
        into l_self.field_tmp.relationship_tmp.collect_name,
             l_self.field_tmp.relationship_tmp.target_field,
             l_self.field_tmp.type,
             l_self.field_tmp.length,
             l_self.field_tmp.accuracy;
      if l_pk_field_cur%notfound = true then
        xxdoo_db_utils_pkg.fix_exception('Relationship: target field not found. Source entity: '||l_self.field_tmp.relationship_tmp.source_entity||', target: '||l_self.field_tmp.relationship_tmp.target_entity);
        raise apps.fnd_api.g_exc_error;
      end if;
      --
      close l_pk_field_cur;
    end if;
    --
    if l_self.field_tmp.relationship_tmp.type = 'FK' then
      l_self.field_tmp.relationship_tmp.collect_name := null;
    end if;
    --
    return l_self;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
  end;
  --
  --
  --
  member procedure generate is
  begin
    --self.generate_scripts;
    xxdoo.xxdoo_db_engine_pkg.generate_objects(self);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  member procedure prepare_ddl is
  begin
    xxdoo.xxdoo_db_engine_pkg.generate_objects(self,true);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  member procedure generate_scripts(p_directory varchar2 default null) is
  begin
    self.prepare_ddl;
    xxdoo.xxdoo_db_engine_pkg.generate_scripts(self, p_directory);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  member procedure seq_nextval is
  begin
    self.seq_num := nvl(self.seq_num,0) + 1;
  end;
  --
  member function seq_curval return number is
  begin
    return self.seq_num;
  end;
  member procedure seq_init is
  begin
    self.seq_num := 0;
  end;--*/
--
end;
/
