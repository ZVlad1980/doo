create or replace type body xxdoo_db_attribute is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_ATTRIBUTE');
  end get_type_name;
  --
  --
  --
  constructor function xxdoo_db_attribute return self as result is
  begin
    return;
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
    procedure add_join(s in out nocopy xxdoo_db_select,
                       p_join_template varchar2,
                       p_tab_alias1 varchar2,
                       p_tab_alias2 varchar2) is
      a char := chr(38);
    begin
      /*for c in 1..self.column_list.count loop
        s.w(p_tab_alias||'.'||self.column_list(c).name||' = '||p_col_alias||'_v.' || self.r_column_list(c).name||'(+)');
      end loop;*/
      s.w(replace(replace(p_join_template,a||'_2_',p_tab_alias2),a||'_1_',p_tab_alias1));
    end;
  begin
    if self.member_type = 'U' then
      s.s('cast(null as '||self.type_as_string||')' || p_col_alias);
    elsif self.type_code = 'OBJECT' then
      s.s('value('||p_col_alias||'_v) '||p_col_alias);
      s.f(p_owner||'.'||
          case p_fast_view 
            when true then
              self.r_db_view_fast
            else
              self.r_db_view
            end ||' '||p_col_alias||'_v');
      add_join(s,self.join_template,p_tab_alias,p_col_alias||'_v');
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
          ss.s('value(v)');
          ss.f(p_owner||'.'||self.r_db_view||' v');
          add_join(ss, self.join_template, 'v', p_tab_alias);
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
          t.append(') as '||self.owner_type||'.'||self.type||')');
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
end;
/
