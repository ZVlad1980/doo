create or replace type body xxdoo_dao_table is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DAO_TABLE');
  end get_type_name;
  -- 
  --
  --
  constructor function xxdoo_dao_table return self as result is
  begin
    return;
  end;
  --
  --
  --
  member procedure add_attribute(p_attr xxdoo_dao_attribute) is
  begin
    null;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member function get_attribute_pos(p_attr_name varchar2) return number is
    l_result number;
  begin
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure dao_xml_parsing(c in out nocopy xxdoo_db_text, p_path varchar2 default null) is
  begin
    null;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
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
  end;
  --
  --
  --
  member procedure dao_load_select(s in out nocopy xxdoo_db_select, 
                                   p_xml_info varchar2,
                                   p_path     varchar2) is
    c xxdoo_db_text;
    cursor l_pk_attrib_cur is
      select a.column_name, a.xml_name attr_name, a.fn_formatting
      from   table(self.attribute_list) a
      where  1=1
      and    a.is_pk = 'Y'
      order by a.position;
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
    s.f(self.table_info.db_view||' '||self.alias_vw);
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
      xxdoo_db_utils_pkg.fix_exception('dao_load_select '||self.table_info.name||' error.');
      raise;
  end;
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
    --
    xxdoo_dao_pkg.seq_init;
    s := xxdoo_db_select;
    self.dao_load_select(s, l_xml_info, l_path);
    --
    t := xxdoo_db_text();
    t.append('procedure load(p_object in out nocopy '||self.table_info.db_type||', p_xml xmltype) is');
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
      xxdoo_utl_pkg.fix_exception('dao_load '||self.table_info.name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure dao_put_object(t in out nocopy xxdoo_db_text,
                                  p_from_tables xxdoo_db_objects_list) is
  begin
    null;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure dao_put_delete(t             in out nocopy xxdoo_db_text,
                                  p_from_tables               xxdoo_db_objects_list,
                                  a                           number, 
                                  p_table       in out nocopy xxdoo_db_object) is
  begin
    null;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure dao_put_parse(t in out nocopy xxdoo_db_text,
                                 p_from_tables xxdoo_db_objects_list) is
  begin
    null;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure dao_put is
  begin
    null;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  --
end;
/
