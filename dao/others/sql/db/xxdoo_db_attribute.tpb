create or replace type body xxdoo_db_attribute is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_ATTRIBUTE');
  end get_type_name;
  --
  -- конструктор для вложенных объектов (коллекций)
  --
  constructor function xxdoo_db_attribute(p_name              varchar2, 
                                          p_column_name       varchar2,
                                          p_owner_type        varchar2, 
                                          p_type              varchar2, 
                                          p_type_code         varchar2,
                                          p_column_list       xxdoo_db_columns,
                                          p_r_table_name      varchar2,
                                          p_r_constraint_name varchar2,
                                          p_r_db_table        varchar2,
                                          p_r_db_type         varchar2,
                                          p_r_db_coll_type    varchar2,
                                          p_r_db_view         varchar2,
                                          p_r_db_view_fast    varchar2,
                                          p_r_column_list     xxdoo_db_columns)
    return self as result is
  begin
    self.name              := p_name;
    self.type_code         := p_type_code       ;
    if self.type_code <> 'FK' then
      self.type              := upper(p_type); --тип д.б. переопредел в xxdoo_db_table.prepare_attributes
      self.owner_type        := upper(p_owner_type);
    end if;
    self.column_name       := p_column_name;
    self.member_type       := 'A';
    self.column_list       := p_column_list     ;
    self.r_table_name      := p_r_table_name    ;
    self.r_constraint_name := p_r_constraint_name;
    self.r_db_table        := p_r_db_table      ;
    self.r_db_type         := p_r_db_type       ;
    self.r_db_coll_type    := p_r_db_coll_type  ;
    self.r_db_view         := p_r_db_view       ;
    self.r_column_list     := p_r_column_list   ;
    self.r_db_view_fast    := p_r_db_view_fast  ;
    --
    return;
  end;
  --
  --
  --
  constructor function xxdoo_db_attribute(p_name       varchar2, 
                                          p_type       varchar2,
                                          p_length     number,
                                          p_scale      number,
                                          p_owner      varchar2 default null,
                                          p_member_type varchar2 default 'A')
    return self as result is
  begin
    self.name := p_name;
    self.set_property(p_type       ,
                      p_length     ,
                      p_scale      ,
                      p_owner      ,
                      p_member_type);
    return;
  end;
  --
  --
  --
  member procedure set_property(p_type        varchar2,
                                p_length      number,
                                p_scale       number,
                                p_owner       varchar2 default null,
                                p_member_type varchar2 default 'A') is
  begin
    self.type := upper(p_type);
    self.owner_type := p_owner;
    self.length := p_length;
    self.scale := p_scale;
    self.member_type := p_member_type;
    if p_member_type = 'A' then
      self.column_name := self.name;
    end if;
  end;
  --
  --
  --
  constructor function xxdoo_db_attribute(p_name        varchar2,
                                          p_method_spc  varchar2,
                                          p_method_body varchar2)
    return self as result is
  begin
    self.name        := p_name;
    self.method_spc  := p_method_spc;
    self.method_body := p_method_body;
    self.member_type := 'M';
    return;
  end;
  --
  --
  --
  member procedure set_position(p_owner varchar2, p_type_name varchar2, p_default_position number) is
    cursor l_attrib_pos_cur is
      select a.attr_no position
      from   all_type_attrs a
      where  1=1
      and    a.attr_name = upper(self.name)
      and    a.type_name = upper(p_type_name)
      and    a.owner = upper(p_owner);
  begin
    open l_attrib_pos_cur;
    fetch l_attrib_pos_cur into self.position;
    if l_attrib_pos_cur%notfound = true then
      self.position := p_default_position;
    end if;
    close l_attrib_pos_cur; 
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Set position for attribute '||p_owner||'.'||p_type_name||'.'||self.name||' error.');
      raise;
  end set_position;
  --
  --
  --
  member function get_fk_as_string(p_type varchar2 default 'T', p_table_alias varchar2) return varchar2 is
    l_result varchar2(400);
    l_table_alias varchar2(40) := case
                                    when p_table_alias is not null then
                                      p_table_alias || '.' 
                                  end;
  begin
    for c in 1..self.column_list.count loop
      l_result := l_result || 
        case
          when c > 1 then
            ', '
        end || l_table_alias || 
        case
          when p_type = 'T' then
            self.column_list(c).name
          else 
            self.r_column_list(c).name
        end;
    end loop;
    --
    return l_result;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Attribute '||self.name||' as string error.');
      raise;
  end get_fk_as_string;
  --
  --
  --
  member function type_as_string return varchar2 is
    l_result varchar2(400);
  begin
    if self.member_type in ('A','U') then
      l_result := case
                    when self.owner_type is not null then
                      self.owner_type || '.'
                  end || self.type ||
                  case
                    when self.length is not null then
                      '(' || self.length ||
                      case
                        when self.scale is not null then
                          ','||self.scale
                      end || ')'
                  end;
    else
      xxdoo_db_utils_pkg.fix_exception('Attribute '||self.name||' as string: unknown member type "'||self.member_type||'"');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    return l_result;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Attribute '||self.name||' as string error.');
      raise;
  end;
  --
  --
  --
  overriding member function as_string(p_max_name_size number default null) return varchar2 is
    l_result varchar2(400);
  begin
    if self.member_type in ('A','U') then
      l_result := case
                    when p_max_name_size is null then
                      self.name
                    else
                      rpad(self.name,p_max_name_size,' ') 
                  end || ' ' || self.type_as_string;
    elsif self.member_type = 'M' then
      l_result := self.method_spc;
    else
      xxdoo_db_utils_pkg.fix_exception('Attribute '||self.name||' as string: unknown member type "'||self.member_type||'"');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    return l_result;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Attribute '||self.name||' as string error.');
      raise;
  end;
  --
  --
  --
  member procedure push_view(s           in out nocopy xxdoo_db_select, 
                             p_owner     varchar2, 
                             p_tab_alias varchar2, 
                             p_col_alias varchar2,
                             p_fast_view boolean default false) is
    --
    procedure conditions(s in out nocopy  xxdoo_db_select) is
    begin
      for c in 1..self.column_list.count loop
        s.w(p_tab_alias||'.'||self.column_list(c).name||' = '||p_col_alias||'_v.' || self.r_column_list(c).name||'(+)');
      end loop;
    end;
  begin
    if self.member_type = 'U' then
      s.s('cast(null as '||self.type_as_string||')' || p_col_alias);
    elsif self.type_code = 'OBJECT' then
      s.f(p_owner||'.'||
          case p_fast_view 
            when true then
              self.r_db_view_fast
            else
              self.r_db_view
            end ||' '||p_col_alias||'_v');
      conditions(s);
      s.s('value('||p_col_alias||'_v) '||p_col_alias);
    elsif self.type_code = 'COLLECTION' then
      --если быстрая вьюха - коллекции не грузим
      if p_fast_view then 
        s.s('null ' || p_col_alias);
      else
        declare
          t     xxdoo_db_text := xxdoo_db_text;
          ss    xxdoo_db_select := xxdoo_db_select;
          l_str varchar2(1024);
        begin
          ss.s('value('||p_col_alias||'_v)');
          ss.f(p_owner||'.'||self.r_db_view||' '||p_col_alias||'_v');
          conditions(ss);
          --
          t.append('cast(');
          t.inc;
          t.append('multiset(');
          t.inc;
          ss.first;
          while ss.next(l_str) loop
            t.append(l_str);
          end loop;
          t.dec;
          t.append(') as '||self.owner_type||'.'||self.r_db_coll_type||')');
          --
          s.s(t,p_col_alias);
          --
        end;
      end if;
    else
      s.s(p_tab_alias||'.'||self.name || ' ' || p_col_alias);
    end if;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Attribute '||self.name||' push view error.');
      raise;
  end push_view;
  --
  --
  --
  member procedure xml_string(c in out nocopy xxdoo_db_text, p_path varchar2) is
    l_table xxdoo_db_table;
  begin
    self.xml_name := self.name || to_char(xxdoo_db_utils_pkg.seq_nextval);
    --
    if self.type_code = 'OBJECT' then
      c.append(self.xml_name || ' xmltype path '''||p_path||self.name||''',');
      l_table := treat(self.r_table as xxdoo_db_table);
      l_table.dao_xml_parsing(c, p_path||self.name||'/');
      self.r_table := l_table;
    elsif self.type_code = 'COLLECTION' then
      c.append(self.xml_name || ' xmltype path '''||p_path||self.name||'''', false);
    else
      self.type_for_xml := xxdoo_db_utils_pkg.get_type_xml(self.type, self.length, self.scale);
      self.fn_formatting := xxdoo_db_utils_pkg.get_fn_format_xml(self.type);
      if self.fn_formatting is not null then
        c.append(self.xml_name || '_f varchar2(100) path '''||p_path||self.name||'/./@format'',');
      end if;
      c.append(self.xml_name || ' ' || lower(self.type_for_xml) || ' path '''||p_path||self.name||''''||
                 case
                   when upper(self.type_for_xml) like 'VARCHAR%' then
                     ' default chr(0)'
                 end, 
               false);
    end if;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Attribute '||self.name||' get xml string error.');
      raise;
  end;
  --
  --
  --
  member procedure load_string(s in out nocopy xxdoo_db_select, 
                               p_alias_vw  varchar2,
                               p_alias_xml varchar2) is
    l_table    xxdoo_db_table;
    ss         xxdoo_db_select;
    l_str      varchar2(4000);
    --
    cursor l_xml_pk_name_cur(p_column_name varchar2) is
        select a.xml_name,a.fn_formatting
        from   table(l_table.constraints) c,
               table(l_table.attribute_list) a
        where  1=1
        and    a.column_name = p_column_name;
    --
    function pk_is_null return varchar2 is
      l_result varchar2(1024);
      l_xml_name varchar2(32);
      l_dummy    varchar2(200);
    begin
      for c in 1..self.column_list.count loop
        if c > 1 then
          l_result := l_result || ' or ';
        end if;
        --
        open l_xml_pk_name_cur(self.r_column_list(c).name);
        fetch l_xml_pk_name_cur into l_xml_name, l_dummy;
        if l_xml_pk_name_cur%notfound then
          xxdoo_db_utils_pkg.fix_exception('load_string.pk_is_null: '||self.name||' not found xml name pk for '||self.r_column_list(c).name);
          close l_xml_pk_name_cur;
          raise apps.fnd_api.g_exc_error;
        end if;
        close l_xml_pk_name_cur;
        --
        l_result := p_alias_xml || '.' || l_xml_name || ' is null ';
      end loop;
      return l_result;
    end;
    --
    procedure fk_object(p_alias_vw varchar2) is
      --
      l_xml_name varchar2(32);
      l_fn_formatiing varchar2(200);
    begin
      for c in 1..self.column_list.count loop
        open l_xml_pk_name_cur(self.r_column_list(c).name);
        fetch l_xml_pk_name_cur into l_xml_name, l_fn_formatiing;
        if l_xml_pk_name_cur%notfound then
          xxdoo_db_utils_pkg.fix_exception('load_string.fk_object: '||self.name||' not found xml name pk for '||self.r_column_list(c).name);
          close l_xml_pk_name_cur;
          raise apps.fnd_api.g_exc_error;
        end if;
        close l_xml_pk_name_cur;
        s.w(p_alias_vw||'.'||self.r_column_list(c).name||'(+) = '||
          case
            when l_fn_formatiing is null then
              p_alias_xml || '.' ||l_xml_name
            else
              l_fn_formatiing||'('||p_alias_xml || '.' ||l_xml_name||
                ', ' ||p_alias_xml || '.' ||l_xml_name||'_f)'
          end);
      end loop;
    end;
  begin
    --
    if self.type_code = 'OBJECT' then
      --
      l_table := treat(self.r_table as xxdoo_db_table);
      l_table.alias_vw := 'v' || to_char(xxdoo_db_utils_pkg.seq_nextval());
      s.f(l_table.db_view || ' ' || l_table.alias_vw);
      fk_object(l_table.alias_vw);
      --
      s.st.append('case ');
      s.st.inc(2);
      s.st.append('when '||p_alias_xml||'.'||self.xml_name||' is null or ('||pk_is_null||') then');
      s.st.append('  '||p_alias_vw||'.'||self.name);
      s.st.append('else');
      s.st.inc(2);
      
      l_table.dao_load_object(s,l_table.alias_vw,p_alias_xml);
      --
      s.st.dec(4);
      s.st.append(null);
      s.st.append('end',false);
    elsif self.type_code = 'COLLECTION' then
      l_table := treat(self.r_table as xxdoo_db_table);
      s.st.append('case ');
      s.st.inc(2);
      s.st.append('when '||p_alias_xml||'.'||self.xml_name||' is null then');
      s.st.append('  '||p_alias_vw||'.'||self.name);
      s.st.append('else');
      s.st.inc(2);
      s.st.append('cast(multiset(');
      s.st.inc(2);
      ss := xxdoo_db_select();
      l_table.dao_load_select(ss, p_alias_xml||'.'||self.xml_name, '/'||l_table.name||'/'||l_table.entry_name);
      ss.first;
      while ss.next(l_str) loop
        s.st.append(l_str);
      end loop;
      --
      s.st.dec(2);
      s.st.append(null);
      s.st.append(') as '||self.r_db_coll_type||')');
      s.st.dec(4);
      s.st.append('end',false);
    else
      if upper(self.type_for_xml) like 'VARCHAR2%' then
        s.st.append('case '||p_alias_xml||'.'||self.xml_name);
        s.st.append('  when chr(0) then');
        s.st.append('    '||p_alias_vw||'.'||self.name);
        s.st.append('  else');
        if self.fn_formatting is null then
          s.st.append('    '||p_alias_xml||'.'||self.xml_name);
        else
          s.st.append('    '||self.fn_formatting||'('||p_alias_xml||'.'||self.xml_name||', '||p_alias_xml||'.'||self.xml_name||'_f)');
        end if;
        s.st.append('end',false);
      else
        s.st.append('nvl('||p_alias_xml||'.'||self.xml_name||', '||p_alias_vw||'.'||self.name||')',false);
      end if;
    end if;
    --
    
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Attribute '||self.name||' load string error.');
      raise;
  end;
  /*member procedure ddl(o in out nocopy xxdoo_db_objects_list, p_owner varchar2, p_type_name varchar2) is
    cursor l_column_cur is
      select c.position,c.type,c.length,c.scale,c.nullable
      from   xxdoo_db_tab_columns_db_v c
      where  1=1
      and    c.name = upper(self.name)
      and    c.table_name = upper(p_type_name)
      and    c.owner = upper(p_owner);
    l_column l_column_cur%rowtype;
  begin
    open l_column_cur;
    fetch l_column_cur into l_column;
    --
    if l_column_cur%found = true then
      null; --добавить проверки!!!
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
  end;  --*/
  --
end;
/
