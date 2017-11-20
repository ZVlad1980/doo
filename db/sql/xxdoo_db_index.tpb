create or replace type body xxdoo_db_index is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_INDEX');
  end get_type_name;
  --
  constructor function xxdoo_db_index return self as result is
  begin
    self.column_list := xxdoo_db_columns();
    return;
  end;
  --
  --  p_uniqueness: Uniqueness status of the index: "UNIQUE",  "NONUNIQUE", or "BITMAP"
  --
  constructor function xxdoo_db_index(p_columns    varchar2, 
                                      p_uniqueness varchar2 default 'NONUNIQUE') return self as result is
  begin
    self.column_list := xxdoo_db_utils_pkg.parse_column_list(p_columns);
    self.uniqueness := p_uniqueness;
    --self.set_name(p_owner, p_table_name);
    return;
  exception
   when others then
     xxdoo_db_utils_pkg.fix_exception('Error constructor index ('||p_columns||').');
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
    for c in 1..self.column_list.count loop
      self.column_list(c).set_id;
    end loop;
  end;
  --
  --
  --
  member procedure set_name(p_owner varchar2, p_table_name varchar2, p_index_name varchar2, p_ind_num number) is
    cursor l_index_cur(p_column_list varchar2) is
      select i.name
      from   xxdoo_db_indexes_db_v i
      where  1=1
      and    upper(i.column_list) = upper(p_column_list)
      and    i.uniqueness = self.uniqueness
      and    i.table_name = upper(p_table_name)
      and    i.owner = upper(p_owner);
    --
    cursor l_index_num_cur(p_index_name varchar2) is
      select max(regexp_substr(i.name,
                               '[[:digit:]$]+')) + 1
      from   xxdoo_db_indexes_db_v i
      where  1=1
      and    i.name like upper(p_index_name)
      and    i.uniqueness = self.uniqueness
      and    i.table_name = upper(p_table_name)
      and    i.owner = upper(p_owner);
    --
    l_max_number   number;
  begin
    open l_index_cur(self.columns_string);
    fetch l_index_cur into self.name;
    close l_index_cur;
    --
    if self.name is null then
      open l_index_num_cur(upper(p_index_name || '%'));
      fetch l_index_num_cur into l_max_number;
      close l_index_num_cur;
      --
      if nvl(l_max_number,1) = 1 then
        l_max_number := p_ind_num;
      end if;
      --
      self.name := p_index_name || '_' ||
        case self.uniqueness
          when 'UNIQUE' then
            'u'
          else
            'n'
        end || l_max_number;
      --
    end if;
    --
  exception
   when others then
     xxdoo_db_utils_pkg.fix_exception('Error set name index '||p_table_name||'.'||self.name||'.');
     raise;
  end set_name;
  --
  --
  --
  member function columns_string return varchar2 is
  begin
    return xxdoo_db_utils_pkg.columns_as_string(self.column_list);
  end;
  --
  --
  --
  member procedure ddl(o in out nocopy xxdoo_db_objects_db_list, p_owner varchar2, p_table_name varchar2) is
  begin
    --
    if xxdoo_db_utils_pkg.is_object_exists(p_owner, self.name) = false then
      --
      o.new('index',self.name);
      o.append('create index '||o.full_name||' on '||p_owner||'.'||p_table_name||'('||self.columns_string||')',false);--||chr(10));
      --
    end if;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Index DDL '||self.name||' for '||p_owner||'.'||p_table_name||' : error.');
      raise;
  end;
  --
end;
/
