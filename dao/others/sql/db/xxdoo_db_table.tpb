create or replace type body xxdoo_db_table is
  --
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_TABLE');
  end get_type_name;
  -- Member procedures and functions
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
      select value(cl) obj
      from   table(l_table.column_list) cl
      where  upper(cl.name) = p_name;
    --
    cursor l_indx_cur(p_index xxdoo_db_index, p_column_list varchar2) is
      select value(il) obj
      from   table(l_table.index_list) il
      where  1=1
      and    p_index.uniqueness = il.uniqueness
      and    upper(xxdoo_db_utils_pkg.columns_as_string(il.column_list)) = p_column_list;
    --
    cursor l_cons_cur(p_cons xxdoo_db_constraint, p_column_list varchar2) is
      select value(il) obj
      from   table(l_table.constraints) il
      where  1=1
      and    upper(xxdoo_db_utils_pkg.columns_as_string(il.column_list)) = p_column_list
      and    p_cons.type = il.type;
  begin
    l_table := self;
    self := p_table;
    self.id := l_table.id;
    self.instance_version := l_table.instance_version;
    --
    for c in 1..self.column_list.count loop
      for cc in l_cols_cur(upper(self.column_list(c).name)) loop
        self.column_list(c).id := cc.obj.id;
        exit;
      end loop;
    end loop;
    --
    for c in 1..self.index_list.count loop
      for cc in l_indx_cur(self.index_list(c),upper(self.index_list(c).columns_string)) loop
        self.index_list(c).id := cc.obj.id;
        self.index_list(c).column_list := cc.obj.column_list;
        exit;
      end loop;
    end loop;
    --
    for c in 1..self.constraints.count loop
      for cc in l_cons_cur(self.constraints(c),upper(self.constraints(c).columns_string)) loop
        self.constraints(c).id := cc.obj.id;
        self.constraints(c).column_list := cc.obj.column_list;
        exit;
      end loop;
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
  member procedure set_attrbiute_pos is
  begin
    for a in 1..self.attribute_list.count loop
      if self.attribute_list(a).member_type = 'A' then
        self.attribute_list(a).position := get_column_pos(self.attribute_list(a).column_name);
      else
        self.attribute_list(a).position := a + 1000;
      end if;
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
  member procedure prepare_attributes is
    --
    pos number;
    --
  begin
    for c in 1..self.column_list.count loop
      pos := get_attribute_pos(self.column_list(c).name);
      if pos is null then
        add_attribute(
          xxdoo_db_attribute(
            self.column_list(c).name,
            self.column_list(c).type,
            self.column_list(c).length,
            self.column_list(c).scale
          )
        );
      elsif self.attribute_list(pos).type_code = 'FK' then
        self.attribute_list(pos).set_property(p_type   => self.column_list(c).type  ,
                                              p_length => self.column_list(c).length,
                                              p_scale  => self.column_list(c).scale );
      end if;
    end loop;
    --
    xxdoo_db_engine_pkg.add_default_methods(self);
    --
    if xxdoo_db_utils_pkg.is_object_exists(self.owner,self.db_type) = false then
      set_attrbiute_pos;
    end if;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end prepare_attributes;
  --
  --
  --
  member procedure final_prepare_attributes(p_scheme xxdoo_db_object) is
    l xxdoo_db_attributes := xxdoo_db_attributes();
    l_table xxdoo_db_table;
    cursor l_attrs_cur is
      select a.attr_name name,a.attr_type_name,a.attr_type_owner,a.length,a.scale,a.inherited
      from   all_type_attrs a
      where  1=1
      and    a.type_name = upper(self.db_type)
      and    a.owner = upper(self.owner)
      order by a.attr_no;
    cursor l_self_attrs_cur(p_name varchar2) is
      select value(a)
      from   table(self.attribute_list) a
      where  upper(a.name) = p_name;
    --
    cursor l_table_cur(p_name varchar2) is
      select value(t) t
      from   table(treat(p_scheme as xxdoo_db_scheme).table_list) t
      where  t.name = p_name;
  begin
    for a in l_attrs_cur loop
      l.extend;
      open l_self_attrs_cur(a.name);
      fetch l_self_attrs_cur into l(l.count);
      if l_self_attrs_cur%notfound = true then
        l(l.count) := xxdoo_db_attribute(p_name        => lower(a.name),
                                         p_type        => a.attr_type_name,
                                         p_length      => a.length,
                                         p_scale       => a.scale,
                                         p_owner       => a.attr_type_owner,
                                         p_member_type => 'U');
      end if;
      close l_self_attrs_cur;
    end loop;
    --
    for a in 1..self.attribute_list.count loop
      if self.attribute_list(a).type = 'M' then
        l.extend;
        l(l.count) := self.attribute_list(a);
      end if;
    end loop;
    --
    self.attribute_list := l;
    --
    for a in 1..self.attribute_list.count loop
      exit when self.attribute_list(a).type = 'M';
      --
      if self.attribute_list(a).type_code in ('OBJECT','COLLECTION','FK') then
        open l_table_cur(self.attribute_list(a).r_table_name);
        fetch l_table_cur into l_table;
        if l_table_cur%notfound then
          xxdoo_db_utils_pkg.fix_exception('Table '||self.attribute_list(a).r_table_name||' not found for attribute '||self.name||'.');
          raise apps.fnd_api.g_exc_error;
        end if;
        self.attribute_list(a).r_table := l_table;
        close l_table_cur;
      end if;
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('final_prepare_attributes '||self.name||' error.');
      raise;
  end final_prepare_attributes;
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
      if self.attribute_list(a).member_type <> 'A' then
        continue;
      end if;
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
  -- Create DAO methods
  --
  member procedure dao_xml_parsing(c in out nocopy xxdoo_db_text, p_path varchar2 default null) is
  begin
    --
    --c.inc;
    for a in 1..self.attribute_list.count loop
      exit when self.attribute_list(a).type = 'M';
      if a > 1 then
        c.append(',');
      end if;
      --
      self.attribute_list(a).xml_string(c, p_path);
      --
    end loop;
    --c.dec(4);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('dao_xml_parsing '||self.name||' error.');
      raise;  
  end dao_xml_parsing;
  --
  --
  --
  member procedure dao_load_object(s in out nocopy xxdoo_db_select,
                                   p_alias_vw varchar2 default null,
                                   p_alias_xml varchar2 default null) is
  begin
    if self.alias_xml is null then
      self.alias_xml := p_alias_xml;
    end if;
    if self.alias_vw is null then
      self.alias_vw := p_alias_vw;
    end if;
    --
    s.st.append(self.db_type||'(');
    s.st.inc(2);
    --
    for a in 1..self.attribute_list.count loop
      exit when self.attribute_list(a).type = 'M';
      --
      if a > 1 then
        s.st.append(',',true);
      end if;
      --
      self.attribute_list(a).load_string(s, self.alias_vw, self.alias_xml);
      --
    end loop;
    --
    s.st.append(null);
    s.st.dec(2);
    s.st.append(')',false);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('dao_load_object '||self.name||' error.');
      raise;
  end dao_load_object;
  --
  --
  --
  member procedure dao_load_select(s in out nocopy xxdoo_db_select, 
                                   p_xml_info varchar2,
                                   p_path     varchar2) is
    c xxdoo_db_text;
    cursor l_pk_attrib_cur is
      select cl.name column_name, a.xml_name attr_name, a.fn_formatting
      from   table(self.constraints) c,
             table(c.column_list)    cl,
             table(self.attribute_list) a
      where  1=1
      and    a.column_name = cl.name
      and    c.type = 'P'
      order by cl.position;
  begin
    self.alias_xml := 'x'||to_char(xxdoo_db_utils_pkg.seq_nextval());
    self.alias_vw  := 'v'||to_char(xxdoo_db_utils_pkg.seq_nextval());
    -- from xml
    c := xxdoo_db_text();
    c.append('xmltable('''||p_path||''' passing('||p_xml_info||')');
    c.inc;
    c.append('columns');
    c.inc;
    dao_xml_parsing(c);
    c.dec(4);
    c.append(')');
    s.f(c,self.alias_xml);
    s.f(self.db_view||' '||self.alias_vw);
    --
    for a in l_pk_attrib_cur loop
      s.w(self.alias_vw||'.'||a.column_name||'(+) = '||
        case
          when a.fn_formatting is null then
            self.alias_xml||'.'||a.attr_name
          else
            a.fn_formatting || '(' || a.attr_name || ',' || a.attr_name || '_f)'
        end);
    end loop;
    --
    s.st.append('select ',false);
    s.st.inc(7);
    self.dao_load_object(s);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('dao_load_select '||self.name||' error.');
      raise;
  end dao_load_select;
  --
  --
  --
  member procedure dao_load is
    s xxdoo_db_select; 
    l_xml_info varchar2(20) := 'p_xml';
    l_path     varchar2(20) := '/content';
    t          xxdoo_db_text;
    l_str      varchar2(4000);
    l_is_first boolean := true;
  begin
    --self.alias_xml := 'x'||to_char(xxdoo_db_utils_pkg.seq_nextval());
    --self.alias_vw  := 'v'||to_char(xxdoo_db_utils_pkg.seq_nextval());
    -- from xml
    xxdoo_db_utils_pkg.seq_init;
    s := xxdoo_db_select;
    self.dao_load_select(s, l_xml_info, l_path);
    --
    t := xxdoo_db_text();
    t.append('procedure load(p_object in out nocopy '||self.db_type||', p_xml xmltype) is');
    t.inc(2);
    t.append('cursor l_parsing_cur is');
    t.inc(2);
    s.first;
    while s.next(l_str) loop
      if not l_is_first then
        t.append(null);
      end if;
      l_is_first := false;
      t.append(l_str,false);
    end loop;
    t.append(';');
    t.dec(4);
    t.append('begin');
    t.inc;
    t.append('open l_parsing_cur;');
    t.append('fetch l_parsing_cur into p_object;');
    t.append('close l_parsing_cur;');
    t.dec;
    t.append('exception');
    t.append('  when others then');
    t.append('    xxdoo_utl_pkg.fix_exception;');
    t.append('    raise;');
    t.append('end load;');
    self.load_method := t.get_text;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('dao_load '||self.name||' error.');
      raise;
  end dao_load;
  --
  --
  --
  member procedure dao_put_object(t in out nocopy xxdoo_db_text,
                                  p_from_tables xxdoo_db_dao_tables) is
    --
    m             xxdoo_db_merge;
    l_obj_col_name varchar2(32);
    l_pk_keys     varchar2(1024);
    --
    cursor l_object_column_cur(p_attribute in out nocopy xxdoo_db_attribute) is
      select rc.name
      from   table(p_attribute.column_list)   c,
             table(p_attribute.r_column_list) rc
      where  1=1
      and    rc.position = c.position
      and    c.name = p_attribute.column_name; --*/
    --
  begin
    --
    m := xxdoo_db_merge(2);
    m.m(self.db_table,'t');
    l_pk_keys := ','||get_pk_as_string||',';
    --
    for a in 1..self.attribute_list.count loop
      exit when self.attribute_list(a).member_type = 'M';
      continue when ((self.attribute_list(a).type_code = 'COLLECTION') or (self.attribute_list(a).member_type <> 'A'));
      --
      if self.attribute_list(a).type_code = 'OBJECT' then
        --
        open l_object_column_cur(self.attribute_list(a));
        fetch l_object_column_cur into l_obj_col_name;
        if l_object_column_cur%notfound then
          close l_object_column_cur;
          xxdoo_db_utils_pkg.fix_exception('Column '||self.attribute_list(a).column_name||' for attribute '
            ||self.name||'.'||self.attribute_list(a).name||' not found into '||self.attribute_list(a).r_table_name);
          raise apps.fnd_api.g_exc_error;
        end if;
        close l_object_column_cur; --*/
        --
        m.us.s(self.alias_vw||'.'||self.attribute_list(a).name||'.'||l_obj_col_name||' '||self.attribute_list(a).column_name);
      else
        m.us.s(self.alias_vw||'.'||self.attribute_list(a).name||' '||self.attribute_list(a).column_name);
      end if;
      --
      if l_pk_keys like ('%,'||self.attribute_list(a).column_name||',%') then
        --on
        m.o(self.attribute_list(a).column_name);
      else
        --update
        m.u(self.attribute_list(a).column_name);
      end if;
      --insert
      m.i(self.attribute_list(a).column_name);
    end loop;
    --using select expression from
    for tt in 1..p_from_tables.count loop
      m.us.f(p_from_tables(tt).table_name||' ' ||p_from_tables(tt).table_alias);
    end loop;
    m.us.f(self.alias_xml||' ' ||self.alias_vw);
    --
    t.dec(2);
    t.append(m.get_text||';');
    t.inc(2);
    t.append('--');
    
    -- Добавить удаление!!!
    --if p_from_tables.count > 0 then
      
    --end if;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('dao_put_object '||self.name||' error.');
      raise;
  end dao_put_object;
  --
  -- Удаление строк из коллекций
  --
  member procedure dao_put_delete(t             in out nocopy xxdoo_db_text,
                                  p_from_tables               xxdoo_db_dao_tables,
                                  a                           number, 
                                  p_table       in out nocopy xxdoo_db_table) is
    s xxdoo_db_select;
    l_str varchar2(4000);
  begin
    s := xxdoo_db_select();
    s.s(self.attribute_list(a).get_fk_as_string('T',p_from_tables(p_from_tables.count).table_alias));
    for tt in 1..p_from_tables.count loop
      s.f(p_from_tables(tt).table_name||' ' ||p_from_tables(tt).table_alias);
    end loop;
    --
    t.append('delete from '||p_table.db_table||' t');
    t.append('where  1=1');
    t.append('and    ('||self.attribute_list(a).get_fk_as_string('R','t')||') in (');
    t.inc(7);
    s.first;
    while s.next(l_str) loop
      t.append(l_str);
    end loop;
    t.append(')');
    t.dec(7);
    --
    s := xxdoo_db_select();
    s.s(self.attribute_list(a).get_fk_as_string('T',p_table.alias_vw));
    for tt in 1..p_from_tables.count loop
      s.f(p_from_tables(tt).table_name||' ' ||p_from_tables(tt).table_alias);
    end loop;
    s.f(p_table.alias_xml||' ' ||p_table.alias_vw);
    --
    t.append('and    ('||self.get_pk_as_string||') not in (');
    t.inc(7);
    s.first;
    while s.next(l_str) loop
      t.append(l_str);
    end loop;
    t.append(');');
    t.dec(7);
    t.append('--');
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('dao_put_delete '||self.name||' error.');
      raise;
  end dao_put_delete;
  --
  --
  --
  member procedure dao_put_parse(t in out nocopy xxdoo_db_text,
                                 p_from_tables xxdoo_db_dao_tables) is
    l_from_tables xxdoo_db_dao_tables;
    l_table xxdoo_db_table;
    
  begin
    --
    l_from_tables := p_from_tables;
    l_from_tables.extend;
    l_from_tables(l_from_tables.count) := xxdoo_db_dao_table(self.alias_xml,self.alias_vw,self.dao_path);
    --
    for a in 1..self.attribute_list.count loop
      exit when self.attribute_list(a).member_type = 'M';
      continue when self.attribute_list(a).member_type <> 'A';
      --
      if self.attribute_list(a).type_code = 'COLLECTION' then
        l_table := treat(self.attribute_list(a).r_table as xxdoo_db_table);
        l_table.alias_xml := 'table('||nvl(self.dao_path,self.alias_vw)||'.'||self.attribute_list(a).name||')';
        l_table.alias_vw  := 'o'||xxdoo_db_utils_pkg.seq_nextval;
        --
        l_table.dao_put_object(t,l_from_tables);
        --
        dao_put_delete(t, l_from_tables, a, l_table);
        --
        l_table.dao_put_parse(t,l_from_tables);
        --
      end if;
      --
      if self.attribute_list(a).type_code in ('OBJECT') then
        l_table := treat(self.attribute_list(a).r_table as xxdoo_db_table);
        l_table.dao_path := nvl(self.dao_path,self.alias_vw) || '.' || self.attribute_list(a).name;
        l_table.dao_put_parse(t,l_from_tables);
      end if;
      --
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('dao_put_parse '||self.name||' error.');
      raise;
  end dao_put_parse;
  --
  --
  --
  member procedure dao_put is
    t xxdoo_db_text;
  begin
    xxdoo_db_utils_pkg.seq_init;
    --
    t := xxdoo_db_text();
    --
    t.append('procedure put(p_objects in out nocopy '||self.db_coll_type||') is');
    t.append('  pragma autonomous_transaction;');
    t.append('begin');
    t.inc;
    t.append('for o in 1..p_objects.count loop');
    t.append('  p_objects(o).set_id;');
    t.append('end loop;');
    t.append('--');
    --
    self.alias_xml := 'table(p_objects)';
    self.alias_vw  := 'o'||xxdoo_db_utils_pkg.seq_nextval;
    --
    self.dao_put_object(t,xxdoo_db_dao_tables());
    self.dao_put_parse(t,xxdoo_db_dao_tables());
    --
    --t.append('--');
    t.append('commit;');
    t.dec;
    t.append('exception');
    t.append('  when others then');
    t.append('    rollback;');
    t.append('    xxdoo_utl_pkg.fix_exception;');
    t.append('    raise;');
    t.append('end;');
    --
    self.put_method := t.get_text;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('dao_put_object '||self.name||' error.');
      raise;
  end dao_put;  
  --
end;
/
