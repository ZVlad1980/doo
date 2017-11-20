create or replace type body xxdoo_db_table is
  --
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_TABLE');
  end get_type_name;
  --
  -- Member procedures and functions
  --
  constructor function xxdoo_db_table return self as result is
  begin
    self.column_list := xxdoo_db_tab_columns();
    self.constraints := xxdoo_db_constraints();
    return;
  end;
  --
  --
  --
  constructor function xxdoo_db_table(p_table_name varchar2) return self as result is
    l_entry_name varchar2(18);
    l_table_name varchar2(18);
  begin
    self := xxdoo_db_table;
    if p_table_name like '%/%' then
      l_entry_name := substr(p_table_name,instr(p_table_name,'/')+1);
      l_table_name       := substr(p_table_name,1,instr(p_table_name,'/')-1);
    else
      l_table_name       := p_table_name;
      l_entry_name := substr(l_table_name,1,length(l_table_name)-1);
    end if;
    --
    --
    if l_table_name = l_entry_name then
      xxdoo_db_utils_pkg.fix_exception('Entity: name ('||l_table_name||') and entry name ('||l_entry_name||') must be different.');
      raise apps.fnd_api.g_exc_error;
    elsif l_table_name is null or l_entry_name is null then
      xxdoo_db_utils_pkg.fix_exception('Entity: name ('||l_table_name||') and entry name ('||l_entry_name||') shouldn''t be empty.');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    self.name := l_table_name;
    self.entry_name := l_entry_name;
    --
    return;
  exception 
    when others then
      xxdoo_db_utils_pkg.fix_exception('xxdoo_db_entity_typ(p_entity_name => '||p_table_name||') error.');
      raise;
  end;
  --
  --
  --основной конструтор
  --
  constructor function xxdoo_db_table(p_owner       varchar2,
                                      p_dev_code    varchar2,
                                      p_table_name  varchar2,
                                      p_columns     xxdoo_db_tab_columns,
                                      p_indexes     xxdoo_db_indexes,
                                      p_constraints xxdoo_db_constraints,
                                      p_content     xxdoo_db_list_varchar2)  return self as result is
    --
  begin
    self := xxdoo_db_table(p_table_name);
    --
    self.owner        := p_owner;
    self.dev_code     := p_dev_code;
    --
    self.db_table     := xxdoo_db_utils_pkg.object_name(p_dev_code => self.dev_code, p_name => self.name, p_type => 'table');
    self.db_view      := xxdoo_db_utils_pkg.object_name(p_dev_code => self.dev_code, p_name => self.name, p_type => 'view');
    --код fast view переопределяется в ddl_view
    self.db_view_fast := self.db_view;
    self.db_type      := xxdoo_db_utils_pkg.object_name(p_dev_code => self.dev_code, p_name => self.entry_name, p_type => 'type');
    self.db_coll_type := xxdoo_db_utils_pkg.object_name(p_dev_code => self.dev_code, p_name => self.name, p_type => 'type');
    --
    self.index_list   := nvl(p_indexes, xxdoo_db_indexes());
    self.constraints  := nvl(p_constraints, xxdoo_db_constraints());
    self.content      := nvl(p_content,xxdoo_db_list_varchar2());
    --
    self.joins        := xxdoo_db_tab_joins();
    --
    self.parse_columns_tmp(p_columns);
    --
    for c in 1..self.constraints.count loop
      if self.constraints(c).type = 'P' then
        self.constraints(c).create_pk_templates(self.pk_template,self.pk_joins_template);
        exit;
      end if;
    end loop;
    --
    return;
  exception
   when others then
     xxdoo_db_utils_pkg.fix_exception;
     raise;
  end;
  --
  --
  --
  member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_db_seq.nextval();
    end if;
    --
    for i in 1..self.column_list.count loop
      self.column_list(i).set_id;
    end loop;
    --
    for i in 1..self.index_list.count loop
      self.index_list(i).set_id;
    end loop;
    --
    for i in 1..self.constraints.count loop
      self.constraints(i).set_id;
    end loop;
    --
    for i in 1..self.joins.count loop
      self.joins(i).set_id;
    end loop;
    --
  end;
  --
  -- Процедура формирует список колонок таблицы, строя его по tmp-списку
  --   параллельно дополняя списки индексов и констрэйнов
  member procedure parse_columns_tmp(p_columns     xxdoo_db_tab_columns) is
  begin
    --
    --self.column_list.extend(p_columns.count);
    --
    for c in 1..p_columns.count loop
      add_column(p_columns(c));
      if treat(p_columns(c) as xxdoo_db_column_tmp).is_indexed = 'Y' and
           nvl(treat(p_columns(c) as xxdoo_db_column_tmp).is_unique,'N') <> 'Y' then
        --
        self.add_index(xxdoo_db_index(p_columns(c).name));
        --
      end if;
      --
      self.add_constraints(p_columns(c).name, treat(p_columns(c) as xxdoo_db_column_tmp).constraints_tmp);
      --
    end loop;
    --
  exception
   when others then
     xxdoo_db_utils_pkg.fix_exception;
     raise;
  end parse_columns_tmp;
  --
  --
  --
  member procedure add_column(p_column     xxdoo_db_tab_column) is
  begin
    --
    self.column_list.extend;
    if self.get_column_pos(p_column.name) is not null then
      xxdoo_db_utils_pkg.fix_exception('Multiple description of a column '||self.name||'.'||p_column.name);
      raise apps.fnd_api.g_exc_error;
    end if;
    self.column_list(self.column_list.count) := xxdoo_db_tab_column(self.owner,self.db_table,p_column);
    --
  exception
   when others then
     xxdoo_db_utils_pkg.fix_exception('Add column '||self.name||'.'||p_column.name||' error.');
     raise;
  end add_column;
  --
  --
  --
  member procedure add_index(p_index xxdoo_db_index) is
  begin
    self.index_list.extend;
    self.index_list(self.index_list.count) := p_index;
  exception
   when others then
     xxdoo_db_utils_pkg.fix_exception;
     raise;
  end;
  --
  --
  --
  member procedure add_constraints(p_column_name varchar2, 
                                   p_constraints xxdoo_db_constraints) is
    pos number;
    --l_cons_name varchar2(32);
  begin
    pos := self.constraints.count;
    self.constraints.extend(p_constraints.count);
    for c in 1..p_constraints.count loop
      self.constraints(pos + c) := p_constraints(c);
      self.constraints(pos + c).property(p_column_list => xxdoo_db_utils_pkg.parse_column_list(p_column_name));
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure merge(p_table xxdoo_db_table) is
    l_table xxdoo_db_table;
    --
    cursor l_cols_cur(p_name varchar2) is
      select cl.id
      from   table(l_table.column_list) cl
      where  upper(cl.name) = p_name;
    --
    cursor l_indx_cur(p_uniqueness varchar2, p_columns varchar2) is
      select il.id
      from   table(l_table.index_list) il
      where  1=1
      and    il.uniqueness = p_uniqueness
      and    upper(xxdoo_db_utils_pkg.columns_as_string(il.column_list)) = p_columns;
    --
    cursor l_cons_cur(p_type varchar2, p_columns varchar2) is
      select il.id
      from   table(l_table.constraints) il
      where  1=1
      and    upper(xxdoo_db_utils_pkg.columns_as_string(il.column_list)) = p_columns
      and    il.type = p_type;
    --
  begin
    l_table := self;
    self := p_table;
    self.id := l_table.id;
    self.instance_version := l_table.instance_version;
    --
    for c in 1..self.column_list.count loop
      open l_cols_cur(upper(self.column_list(c).name));
      fetch l_cols_cur into self.column_list(c).id;
      close l_cols_cur;
    end loop;
    --
    for c in 1..self.index_list.count loop
      open l_indx_cur(self.index_list(c).uniqueness, upper(self.index_list(c).columns_string));
      fetch l_indx_cur into self.index_list(c).id;
      close l_indx_cur;
    end loop;
    --
    for c in 1..self.constraints.count loop
      open l_cons_cur(self.constraints(c).type, upper(self.constraints(c).columns_string));
      fetch l_cons_cur into self.constraints(c).id;
      close l_cons_cur;
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member function get_attribute_pos(p_name varchar2) return number is
  begin
    if self.attribute_list is null then
      return null;
    end if;
    --
    for a in 1..self.attribute_list.count loop
      if upper(self.attribute_list(a).name) = upper(p_name) and self.attribute_list(a).member_type = 'A' then
        return a;
      end if;
    end loop;
    --
    return null;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member function get_column_pos(p_name varchar2) return number is
    l_result number;
  begin
    for c in 1..self.column_list.count loop
      if upper(self.column_list(c).name) = upper(p_name) then
        l_result := c;
        exit;
      end if;
    end loop;
    --
    return l_result;
  end;
  --
  --
  --
  member procedure set_column_property(p_column_name varchar2, 
                                       p_rel_column  xxdoo_db_tab_column) is
  begin
    self.column_list(get_column_pos(p_column_name)).property(
      p_type   => p_rel_column.type  ,
      p_length => p_rel_column.length,
      p_scale  => p_rel_column.scale 
    );
  end set_column_property;
  --
  --
  --
  member procedure add_attribute(p_attribute xxdoo_db_attribute) is
  begin
    if upper(substr(p_attribute.name,1,2)) = 'U_' then
      xxdoo_db_utils_pkg.fix_exception('Attribute name ('||self.name||'.'||p_attribute.name||') not be start with "U_".');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    if self.attribute_list is null then
      self.attribute_list := xxdoo_db_attributes();
    end if;
    --
    if get_attribute_pos(p_attribute.name) is not null then
      xxdoo_db_utils_pkg.fix_exception('Multiple description of a attribute '||self.name||'.'||p_attribute.name);
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    self.attribute_list.extend;
    self.attribute_list(self.attribute_list.count) := p_attribute;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end add_attribute;
  --
  --
  --/*
  member procedure prepare_index is
    --
    type l_num_list_typ is table of number index by varchar2(20);
    l_num_list l_num_list_typ;
  begin
    for c in 1..self.index_list.count loop
      --
      if l_num_list.exists(self.index_list(c).uniqueness) then
        l_num_list(self.index_list(c).uniqueness) := l_num_list(self.index_list(c).uniqueness) + 1;
      else
        l_num_list(self.index_list(c).uniqueness) := 1;
      end if;
      --
      self.index_list(c).set_name(self.owner,
                                  self.db_table, 
                                  self.dev_code || '_' || self.name, 
                                  l_num_list(self.index_list(c).uniqueness));
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end prepare_index;
  --
  --
  --
  member procedure prepare_constraints(p_scheme in out nocopy xxdoo_db_object) is
    --
    type l_cons_list_typ is table of number index by varchar2(1);
    l_cons_list l_cons_list_typ;
    --
    cursor l_constraint_cur(p_rel_table_name varchar2) is
      select c.name,
             t.db_table,
             c.column_list, 
             value(tc) pk_column
      from   table(treat(p_scheme as xxdoo_db_scheme).table_list) t,
             table(t.constraints)   c,
             table(c.column_list)   cc,
             table(t.column_list)   tc
      where  1=1
      and    tc.name = cc.name
      and    cc.position = 1
      and    c.type in 'P'
      and    t.name = p_rel_table_name;
    --
    l_pk_column xxdoo_db_tab_column;
    --
  begin
    for c in 1..self.constraints.count loop
      --обновим счетчики констрэйнов по типам (для генерации уникальных имен при первом создании)
      if l_cons_list.exists(self.constraints(c).type) then
        l_cons_list(self.constraints(c).type) := nvl(l_cons_list(self.constraints(c).type),0) + 1;
      else
        l_cons_list(self.constraints(c).type) := 1;
      end if;
      --для foreign key's нужны данные по встречному констрэйну и целевому полю
      if self.constraints(c).type = 'R' then
        --в целевой таблице ищем констрэйн в типом P (primary key)
        open l_constraint_cur(self.constraints(c).r_table_name);
        fetch l_constraint_cur 
          into self.constraints(c).r_constraint_name,
               self.constraints(c).r_db_table,
               self.constraints(c).r_column_list,
               l_pk_column;
        --
        if l_constraint_cur%notfound = true then
          close l_constraint_cur;
          xxdoo_db_utils_pkg.fix_exception('Relationship constraint not found: table '||self.name||
            ', relation_table ' || self.constraints(c).r_table_name);
          raise apps.fnd_api.g_exc_error;
        end if;
        --установим свойства (тип и т.д.) текущей колонке по типу целевой колонки
        self.set_column_property(p_column_name => self.constraints(c).column_list(1).name,
                                 p_rel_column  => l_pk_column);
        --
        close l_constraint_cur;
        --
        self.constraints(c).create_join_template;
        --
      end if;
      --
      self.constraints(c).set_name(
        p_owner      => self.owner, 
        p_table_name => self.db_table,
        p_cons_name  => self.dev_code ||'_'|| self.name,
        p_cons_num   => l_cons_list(self.constraints(c).type)
      );
      --
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end prepare_constraints;
  --
  --
  --
  member procedure prepare(p_scheme in out nocopy xxdoo_db_object) is
  begin
    --
    prepare_index;
    prepare_constraints(p_scheme);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure prepare_attributes(p_scheme in out nocopy xxdoo_db_object) is
    --
    l_attr xxdoo_db_attribute;
    --вложенные объекты
    cursor l_object_cur(p_col_name varchar2) is
      select rt.name r_table_name, rt.owner, rt.db_type, rt.db_view, rt.db_view_fast, c.join_template
      from   table(self.constraints) c,
             table(c.column_list)    cc,
             table(treat(p_scheme as xxdoo_db_scheme).table_list) rt
      where  1=1
      and    rt.name = c.r_table_name
      and    cc.position = 1
      and    cc.name = p_col_name
      and    c.r_type in ('OBJECT')
      and    c.type = 'R';
    --коллекции
    cursor l_collections_cur is
      select rt.name r_table_name, rownum rnum, c.r_collection_name name, rt.owner, rt.db_coll_type type, rt.db_view, rt.db_view_fast,
             c.join_template
      from   table(treat(p_scheme as xxdoo_db_scheme).table_list) rt,
             table(rt.constraints)                                c
      where  1=1
      and    c.r_table_name = self.name
      and    c.r_type in ('COLLECTION')
      and    c.type = 'R';
    --
  begin
    --добавим поля таблицы в тип
    for c in 1..self.column_list.count loop
      l_attr             := xxdoo_db_attribute();
      --
      l_attr.name        := self.column_list(c).name;
      l_attr.column_name := self.column_list(c).name;
      --
      open l_object_cur(self.column_list(c).name);
      fetch l_object_cur
        into  l_attr.r_table_name,
              l_attr.owner_type,
              l_attr.type,
              l_attr.r_db_view,
              l_attr.r_db_view_fast,
              l_attr.join_template;
      if l_object_cur%notfound = true then
        l_attr.type   := self.column_list(c).type;
        l_attr.length := self.column_list(c).length;
        l_attr.scale  := self.column_list(c).scale;
      else
        l_attr.type_code := 'OBJECT';
      end if;
      close l_object_cur;
      --
      l_attr.member_type := 'A';
      l_attr.position    := c;
      --
      add_attribute(l_attr);
    end loop;
    --Добавим коллекции
    l_attr := xxdoo_db_attribute();
    for c in l_collections_cur loop
      l_attr.r_table_name := c.r_table_name;
      l_attr.name := c.name;
      l_attr.owner_type := c.owner;
      l_attr.type := c.type;
      l_attr.r_db_view := c.db_view;
      l_attr.r_db_view_fast := c.db_view_fast;
      l_attr.type_code := 'COLLECTION';
      l_attr.join_template := c.join_template;
      --
      l_attr.member_type := 'A';
      l_attr.position    := self.column_list.count + c.rnum;
      add_attribute(l_attr);
    end loop;
    --
    xxdoo_db_engine_pkg.add_default_methods(self);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end prepare_attributes;
  --
  --
  --
  member procedure prepare_view_attrs is
    l xxdoo_db_attributes;
    --
    cursor l_attrs_cur is
      select a.attr_name name, 
             a.attr_type_owner,
             a.attr_type_name,
             a.length,
             a.scale,
             a.inherited,
             a.attr_no position
      from   all_type_attrs a
      where  1=1
      and    a.type_name = upper(self.db_type)
      and    a.owner = upper(self.owner)
      order by a.attr_no;
    --
    cursor l_self_attrs_cur(p_name varchar2) is
      select value(a)
      from   table(self.attribute_list) a
      where  upper(a.name) = p_name;
    --
  begin
    l := xxdoo_db_attributes();
    --
    for a in l_attrs_cur loop
      l.extend;
      open l_self_attrs_cur(a.name);
      fetch l_self_attrs_cur into l(l.count);
      if l_self_attrs_cur%notfound = true then
        l(l.count) := xxdoo_db_attribute(p_name        => lower(a.name),
                                         p_type        => lower(a.attr_type_name),
                                         p_length      => a.length,
                                         p_scale       => a.scale,
                                         p_owner       => lower(a.attr_type_owner),
                                         p_member_type => 'U');
      end if;
      l(l.count).position := a.position;
      close l_self_attrs_cur;
    end loop;
    --
    self.attribute_list := l;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Prepare view attributes '||self.name||' error.');
      raise;
  end prepare_view_attrs;
  --
  --
  --
  member procedure ddl_table(o in out nocopy xxdoo_db_objects_db_list, p_position integer) is
  begin
    self.position_tab := p_position; --порядковый номер обработки таблицы
    if xxdoo_db_utils_pkg.is_object_exists(self.owner,self.db_table) = false then
      ddl_table_create(o);
    else
      ddl_table_alter(o);
    end if;
    --
    ddl_constraints(o);
    --
    ddl_index(o);
    --
    ddl_sequence(o);
    --
--    self.generated := 'Y';
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ddl_table_create(o in out nocopy xxdoo_db_objects_db_list) is
    --
    l_name_max_length number;
    --
    procedure set_name_max_length is
      --
      cursor l_name_max_length_cur is
        select max(length(c.name))
        from   table(self.column_list) c;
      --
    begin
      open l_name_max_length_cur;
      fetch l_name_max_length_cur into l_name_max_length;
      close l_name_max_length_cur;
      l_name_max_length := l_name_max_length + 2;
    end;
    --
  begin
    set_name_max_length;
    o.new('table', self.db_table);
    o.append('create table '||o.full_name||'(');
    o.inc;
    for c in 1..self.column_list.count loop
      o.append(self.column_list(c).as_string(l_name_max_length) ||
                        case
                          when c <> self.column_list.count then
                            ','
                        end
                     );
    end loop;
    --
    o.append(')',false);
    --
    if self.content is not null then
      if self.content.count > 0 then
        o.new('insert', self.db_table);
        --
        o.append('insert into '||o.full_name||'('||self.column_list(1).name||')');
        o.inc;
        for c in 1..self.content.count loop
          if c > 1 then
            o.append('  union all');
          end if;
          o.append('select '''||self.content(c)||''' from dual');
        end loop;
      end if;
    end if;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ddl_table_alter(o in out nocopy xxdoo_db_objects_db_list) is
  begin
    for c in 1..self.column_list.count loop
      self.column_list(c).ddl(o,self.owner,self.db_table);
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Alter table '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure ddl_constraints(o in out nocopy xxdoo_db_objects_db_list) is
  begin
    for c in 1..self.constraints.count loop
      self.constraints(c).ddl(o, self.owner, self.db_table);
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ddl_index(o in out nocopy xxdoo_db_objects_db_list) is
  begin
    for c in 1..self.index_list.count loop
      self.index_list(c).ddl(o, self.owner, self.db_table);
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ddl_sequence(o in out nocopy xxdoo_db_objects_db_list) is
    l_is_sequence boolean := false;
    t xxdoo_db_text;
    l_str varchar2(4000);
  begin
    if self.name = 'addresses' then
      null;
    end if;
    t := xxdoo_db_text;
    self.db_trigger   := xxdoo_db_utils_pkg.object_name(p_dev_code => self.dev_code, p_name => self.name, p_type => 'trigger');
    self.db_sequence  := xxdoo_db_utils_pkg.object_name(p_dev_code => self.dev_code, p_name => self.name, p_type => 'sequence');
    --
    for c in 1..self.column_list.count loop
      if self.column_list(c).is_sequence = 'Y' then
        if xxdoo_db_utils_pkg.is_object_exists(self.owner,self.db_sequence) = false then
          o.new('sequence',self.db_sequence);
          o.append('create sequence '||o.full_name||' start with 1 nocache',false);
        end if;
        --тригер
        t.append('--');
        t.append('if :new.'||self.column_list(c).name||' is null then');
        t.append('  :new.'||self.column_list(c).name||' := '||self.db_sequence||'.nextval;');
        t.append('end if;');
        l_is_sequence := true;
      end if;
    end loop;
    --
    if not l_is_sequence then 
      --если sequence не определен - удалим не актуальные объекты
      if xxdoo_db_utils_pkg.is_object_exists(self.owner,self.db_sequence) = true then
        o.new('sequence',self.db_sequence);
        o.append('drop sequence '||o.full_name);
      end if;
      self.db_sequence := null;
      --
      if xxdoo_db_utils_pkg.is_object_exists(self.owner,self.db_trigger) = true then
        o.new('trigger',self.db_trigger);
        o.append('drop trigger '||o.full_name);
      end if;
      self.db_trigger := null;
    else
      o.new('trigger',self.db_trigger);
      o.append('create or replace trigger '||o.full_name);
      o.append('  before insert on '||self.owner||'.'||self.db_table);
      o.append('  for each row');
      o.append('begin');
      o.inc;
      t.first;
      while t.next(l_str) loop
        o.append(l_str);
      end loop;
      o.dec;
      o.append('end '||self.db_trigger||';');
    end if;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure ddl_type(o in out nocopy xxdoo_db_objects_db_list, p_position integer) is
  begin
    self.position_typ := p_position; --порядковый номер обработки типа
    --
    if xxdoo_db_utils_pkg.is_object_exists(self.owner,self.db_type) = false then
      ddl_type_create(o);
    else
      ddl_type_alter(o);
    end if;
    --
    if xxdoo_db_utils_pkg.is_object_exists(self.owner,self.db_coll_type) = false then
      ddl_collection(o);
    end if;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end ddl_type;
  --
  --
  --
  member procedure ddl_type_create(o in out nocopy xxdoo_db_objects_db_list) is
    l_name_max_length number;
    l_first_attr      boolean := true;
    --
    cursor l_attributes_cur is
      select value(a) o
      from   table(self.attribute_list) a
      order by a.member_type, a.position;
    --
    procedure set_name_max_length is
      --
      cursor l_name_max_length_cur is
        select max(length(c.name))
        from   table(self.attribute_list) c
        where  c.member_type = 'A';
      --
    begin
      open l_name_max_length_cur;
      fetch l_name_max_length_cur into l_name_max_length;
      close l_name_max_length_cur;
      l_name_max_length := l_name_max_length + 2;
    end;
    --
  begin
    set_name_max_length;
    o.new('type',self.db_type);
    o.append('create type '||o.full_name||' under xxdoo_db_object(');
    o.inc;
    --
    for a in l_attributes_cur loop
      if not l_first_attr then
        o.append(',');
      else
        l_first_attr := false;
      end if;
      o.append(a.o.as_string(l_name_max_length),false);
    end loop;
    --
    o.append(')',false);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Generate DDL for type '||self.db_type||' error.');
      raise;
  end ddl_type_create;
  --
  --
  --
  member procedure ddl_type_alter(o in out nocopy xxdoo_db_objects_db_list) is
    type l_attr_drop_list_typ is table of boolean index by varchar2(106);
    l_attr_drop_list l_attr_drop_list_typ;
    --
    cursor l_drop_attrs_cur is
      select a.attr_name name, a.attr_no position
      from   all_type_attrs a
      where  1=1
      and    not exists (
               select 1
               from   table(self.attribute_list) al
               where  1=1
               and    al.member_type = 'A'
               and    upper(al.type) = a.attr_type_name  
               and    upper(al.name) = a.attr_name
             )
      and    substr(a.attr_name,1,2) <> 'U_'
      and    a.inherited = 'NO'
      and    a.type_name = upper(self.db_type)
      and    a.owner = upper(self.owner);
    --
      cursor l_attr_cur(p_name varchar2) is
        select 1
        from   all_type_attrs a
        where  1=1
        and    a.attr_name = upper(p_name) 
        and    substr(a.attr_name,1,2) <> 'U_'
        and    a.inherited = 'NO'
        and    a.type_name = upper(self.db_type)
        and    a.owner = upper(self.owner);
    l_attr l_attr_cur%rowtype;
  begin
    --удаление атрибутов
    for a in l_drop_attrs_cur loop
      o.new('attribute',self.db_type||'.'||a.name);
      o.append('alter type '||self.owner||'.'||self.db_type||
        ' drop attribute '||a.name || ' cascade',false);
      l_attr_drop_list(upper(a.name)) := true;
    end loop;
    --добавление атрибутов/модификация
    for a in 1..self.attribute_list.count loop
      continue when self.attribute_list(a).member_type <> 'A';
      --
      open l_attr_cur(self.attribute_list(a).name);
      fetch l_attr_cur into l_attr;
      if l_attr_cur%notfound = true or l_attr_drop_list.exists(upper(self.attribute_list(a).name)) then
        o.new('attribute',self.db_type||'.'||self.attribute_list(a).name);
        o.append('alter type '||self.owner||'.'||self.db_type||
          ' add attribute ' || self.attribute_list(a).as_string || ' cascade',false);
      end if;
      close l_attr_cur;
    end loop;
    --Модификация атрибутов
    
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end ddl_type_alter;
  
  --
  --
  --
  member procedure ddl_type_body(o in out nocopy xxdoo_db_objects_db_list) is
    l_body_empty boolean := true;
    --
    cursor l_body_cur is
      with source as (
        select s.line, s.text
        from   all_source s
        where  1=1
        and    s.TYPE = 'TYPE BODY'
        and    s.name = upper(self.db_type)
        and    s.owner = upper(self.owner)
      )
      select s.text --listagg(s.text,chr(10)) within group (order by s.line) text
      from   source s
      where  s.line > (select max(ss.line) from source ss where ss.text like '%XXDOO_DB_END%') + 1;
    --
  begin
    --
    ddl_type_body_create(o);
    --
    for t in l_body_cur loop
      o.append(t.text,false);
      l_body_empty := false;
    end loop;
    --
    if l_body_empty then
      o.append('end;',false);
    end if;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end ddl_type_body;
  --
  --
  --
  member procedure ddl_type_body_create(o in out nocopy xxdoo_db_objects_db_list) is
    --
    cursor l_attributes_cur is
      select value(a) o
      from   table(self.attribute_list) a
      where  a.member_type = 'M'
      order by a.member_type, a.position;
    --
  begin
    --
    o.new('type body',self.db_type);
    --
    o.append('create or replace type body '||o.full_name||' is ');
    o.inc;
    o.append(rpad('-',60,'-'));
    o.append('--  XXDOO_DB_START');
    o.append(rpad('-',60,'-'));
    --
    for a in l_attributes_cur loop
      o.append(a.o.method_body);
    end loop;
    o.append(rpad('-',60,'-'));
    o.append('--  XXDOO_DB_END');
    o.append(rpad('-',60,'-'));
    --
    o.dec;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Generate DDL for type '||self.db_type||' error.');
      raise;
  end ddl_type_body_create;
  --
  --
  --
  member procedure ddl_collection(o in out nocopy xxdoo_db_objects_db_list) is
  begin
    o.new('type',self.db_coll_type);
    o.append('create type '||o.full_name||' as table of '||self.owner||'.'||self.db_type,false);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end ddl_collection;
  --
  --
  --
  member procedure ddl_view(o in out nocopy xxdoo_db_objects_db_list) is
    --
    --full view (with collection)
    s xxdoo_db_select := xxdoo_db_select;

    --fast view (without collection)
    sf xxdoo_db_select := xxdoo_db_select; 
    l_create_fast_view boolean;
    --
    function collections_exists return boolean is
      l_dummy number;
    begin
      select 1
      into   l_dummy
      from   table(self.attribute_list) a
      where  1=1
      and    rownum = 1
      and    a.type_code = 'COLLECTION';
      return true;
    exception
      when no_data_found then
        return false;
      when others then
        xxdoo_db_utils_pkg.fix_exception('collections_exists for '||self.name||' error.');
        raise;
    end;
  begin
    l_create_fast_view := collections_exists;
    --
    s.f(self.owner||'.'||self.db_table||' t');
    sf.f(self.owner||'.'||self.db_table||' t');
    for a in 1..self.attribute_list.count loop
      exit when self.attribute_list(a).type = 'M';
      --full object view (with collection)
      self.attribute_list(a).push_view(
        s           => s,
        p_owner     => self.owner,
        p_tab_alias => 't',
        p_col_alias => self.attribute_list(a).name);
      if l_create_fast_view then
        --fast object view (without collection)
        self.attribute_list(a).push_view(
          s           => sf,
          p_owner     => self.owner,
          p_tab_alias => 't',
          p_col_alias => self.attribute_list(a).name,
          p_fast_view => true);
      end if;
    end loop;
    --
    o.new('view',self.db_view);
    o.append('create or replace view '||o.full_name||' of '||
             self.db_type||' with object oid('||self.get_pk_as_string||') as');
    o.append(s.build);
    --
    if l_create_fast_view then
      self.db_view_fast := xxdoo_db_utils_pkg.object_name(p_dev_code => self.dev_code, p_name => self.name||'f', p_type => 'view');
      o.new('view',self.db_view_fast);
      o.append('create or replace view '||o.full_name||' of '||
               self.db_type||' with object oid('||self.get_pk_as_string||') as');
      o.append(sf.build);
    end if;
    --
null;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end ddl_view;
  --
  --
  --
  member function get_pk_as_string return varchar2 is
    l_result varchar2(1024);
  begin
    for c in 1..self.constraints.count loop
      if self.constraints(c).type = 'P' then
        l_result := self.constraints(c).columns_string;
        exit;
      end if;
    end loop;
    --
    if l_result is null then
      xxdoo_db_utils_pkg.fix_exception('get_pk_as_string: '||self.name||' primary key not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    return l_result;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('get_pk_as_string '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure create_list_joins(p_scheme in out nocopy xxdoo_db_object, p_joins in out nocopy xxdoo_db_tab_joins) is
    l_table xxdoo_db_table;
    --
    l_tab_pos number;
    --
    cursor l_collections_cur is
      select rt.name table_name, rt.db_table, c.r_collection_name, c.join_template
      from   table(treat(p_scheme as xxdoo_db_scheme).table_list) rt,
             table(rt.constraints)                                c
      where  1=1
      and    c.r_table_name = self.name
      and    c.r_type in ('COLLECTION')
      and    c.type = 'R';
    --
  begin
    --
    for c in 1..self.constraints.count loop
      continue when self.constraints(c).type <> 'R';
      continue when self.constraints(c).r_type = 'COLLECTION';
      --
      l_tab_pos := treat(p_scheme as xxdoo_db_scheme).get_table_pos(self.constraints(c).r_table_name);
      if l_tab_pos is null then
        xxdoo_db_utils_pkg.fix_exception('Table '||self.constraints(c).r_table_name||' not found in attributes '||self.name);
        raise apps.fnd_api.g_exc_error;
      end if;
      --
      l_table := treat(p_scheme as xxdoo_db_scheme).table_list(l_tab_pos);
      --
      p_joins.extend;
      p_joins(p_joins.count) := xxdoo_db_tab_join(self.db_table,
                                                  self.constraints(c).column_list(1).name,
                                                  l_table.db_table,
                                                  self.constraints(c).join_template,--conditions(self.constraints(c)),
                                                  substr(self.constraints(c).r_type,1,1));
      l_table.create_list_joins(p_scheme, p_joins);
    end loop;
    --
    for c in l_collections_cur loop
      l_tab_pos := treat(p_scheme as xxdoo_db_scheme).get_table_pos(c.table_name);
      if l_tab_pos is null then
        xxdoo_db_utils_pkg.fix_exception('Table '||c.table_name||' not found in attributes '||self.name);
        raise apps.fnd_api.g_exc_error;
      end if;
      --
      l_table := treat(p_scheme as xxdoo_db_scheme).table_list(l_tab_pos);
      --
      p_joins.extend;
      p_joins(p_joins.count) := xxdoo_db_tab_join(self.db_table,
                                                  c.r_collection_name,
                                                  l_table.db_table,
                                                  c.join_template,
                                                  'C');
      --для коллекций не надо вложенности, т.к. в query не используется, в dao все равно грузятся все таблицы. l_table.create_list_joins(p_scheme, p_joins);
    end loop;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Create joins for table '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure create_joins(p_scheme in out nocopy xxdoo_db_object) is
    l_joins xxdoo_db_tab_joins;
    --
    cursor l_join_cur(p_table_name varchar2, p_column_name varchar2) is
      select j.id
      from   table(self.joins) j
      where  1=1
      and    j.column_name = p_column_name
      and    j.table_name = p_table_name;
  begin
    l_joins := xxdoo_db_tab_joins();
    self.create_list_joins(p_scheme, l_joins);
    --
    if self.joins is not null then
      for j in 1..l_joins.count loop
        open l_join_cur(l_joins(j).table_name, l_joins(j).column_name);
        fetch l_join_cur into l_joins(j).id;
        close l_join_cur;
      end loop;
    end if;
    --
    self.joins := l_joins;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Create joins for table '||self.name||' error.');
      raise;
  end;
  --
end;
/
