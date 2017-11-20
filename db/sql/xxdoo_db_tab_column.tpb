create or replace type body xxdoo_db_tab_column is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_TAB_COLUMN');
  end get_type_name;
  --
  --
  --
  constructor function xxdoo_db_tab_column(p_owner      varchar2, 
                                           p_table_name varchar2, 
                                           p_column     xxdoo_db_tab_column) return self as result is
  begin
    self.id := p_column.id;
    self.owner_id := p_column.owner_id;
    self.name := p_column.name;
    --self.position := p_columns.position;
    self.type := p_column.type;
    --self.owner_type := p_column.owner_type;
    self.length := p_column.length;
    self.scale := p_column.scale;
    self.nullable := nvl(p_column.nullable,'Y');
    self.default_value := p_column.default_value;
    self.is_sequence := p_column.is_sequence;
    --
    --self.check_column(p_owner, p_table_name);
    return;
  exception
   when others then
     xxdoo_db_utils_pkg.fix_exception('Constructor column '||p_table_name||'.'||p_column.name||' error.');
     raise;
  end;
  --
  --
  --
  overriding member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_db_seq.nextval();
    end if;
  end;
  --
  --
  --
  member procedure check_column(p_owner varchar2, p_table_name varchar2) is
    cursor l_column_cur is
      select c.position,c.type,c.length,c.scale,c.nullable
      from   xxdoo_db_tab_columns_db_v c
      where  1=1
      and    c.name = upper(self.name)
      and    c.table_name = p_table_name
      and    c.owner = p_owner;
    l_column l_column_cur%rowtype;
  begin
    open l_column_cur;
    fetch l_column_cur into l_column;
    --
    if l_column_cur%found = true then
      self.position := l_column.position;
      if self.type in ('VARCHAR2') then
        if self.length < l_column.length then
          xxdoo_db_utils_pkg.fix_exception('Size column '||p_table_name||'.'||self.name||'('||self.length||') less on DB.');
          raise apps.fnd_api.g_exc_error;
        end if;
      end if;
    end if;
    --
    close l_column_cur;
    --
  exception
   when others then
     xxdoo_db_utils_pkg.fix_exception('Error build column '||p_table_name||'.'||self.name||'.');
     raise;
  end check_column;
  --
  --
  --
  member procedure property(p_type   varchar2 default null, 
                            p_length number default null, 
                            p_scale  number default null) is
  begin
    self.type   := nvl(p_type  , self.type  );
    self.length := nvl(p_length, self.length);
    self.scale  := nvl(p_scale , self.scale );
    --
  end;
  --
  --
  --
  member function as_string(p_max_name_size number) return varchar2 is
    l_result varchar2(400);
  begin
    l_result := 
      case
        when p_max_name_size is null then
          self.name
        else
          rpad(self.name,p_max_name_size,' ' ) 
      end ||
      ' ' || self.type ||
      case
        when self.length is not null then
          '(' || self.length ||
          case
            when self.scale is not null then
              ','||self.scale
          end || ')'
      end  ||
      case
        when self.default_value is not null then
          ' default '||self.default_value
      end ||
      case
        when self.nullable = 'N' then
          ' not'
      end || ' null';
    --
    return l_result;
  end;
  --
  --
  --
  member procedure ddl(o in out nocopy xxdoo_db_objects_db_list, p_owner varchar2, p_table_name varchar2) is
    cursor l_column_cur is
      select c.position,c.type,c.length,c.scale,c.nullable
      from   xxdoo_db_tab_columns_db_v c
      where  1=1
      and    c.name = upper(self.name)
      and    c.table_name = upper(p_table_name)
      and    c.owner = upper(p_owner);
    l_column l_column_cur%rowtype;
  begin
    open l_column_cur;
    fetch l_column_cur into l_column;
    --
    if l_column_cur%found = true then
      if l_column.type = 'NUMBER' and self.type = 'INTEGER' and l_column.scale = 0 then
        l_column.type := 'INTEGER';
      end if;
      if l_column.type like 'TIMESTAMP%' then
        l_column.type := 'TIMESTAMP';
      end if;
      if l_column.type <> self.type then
        xxdoo_db_utils_pkg.fix_exception('Cannot change type of columns '||self.name||'. Current type: '||l_column.type||', new type '||self.type);
        raise apps.fnd_api.g_exc_error;
      end if;
      if nvl(l_column.length,0) < nvl(self.length,0) then
        xxdoo_db_utils_pkg.fix_exception('Cannot change length of columns '||self.name||'. Current type: '||l_column.length||', new type '||self.length);
        raise apps.fnd_api.g_exc_error;
      end if;
      --
      if l_column.nullable <> self.nullable or 
          (upper(self.type) like '%CHAR%' and nvl(l_column.length,0) > nvl(self.length,0)) then 
        o.new('column',p_table_name||'.'||self.name);
        o.append('alter table '||p_owner||'.'||p_table_name||' modify '||self.as_string(null),false);
      end if;
    else
      o.new('column',p_table_name||'.'||self.name);
      o.append('alter table '||p_owner||'.'||p_table_name||' add '||self.as_string(null),false);
    end if;
    --
    close l_column_cur;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Alter column '||p_owner||'.'||p_table_name||'.'||self.name||' error.');
      raise;
  end;
  --
end;
/
