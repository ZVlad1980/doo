create or replace type body xxdoo_db_list is
  --
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_LIST');
  end get_type_name;
  -- Member procedures and functions
  constructor function xxdoo_db_list return self as result is
  begin
    self.iterator := 0;
    self.list := xxdoo_db_list_values();
    return;
  end;
  --
  constructor function xxdoo_db_list(p_xmlinfo xmltype) return self as result is
  begin
    self := xxdoo_db_list;
    self.parse_xml(p_xmlinfo);
    return;
  end;
  --
  constructor function xxdoo_db_list(p_list xxdoo_db_list_values) return self as result is
  begin
    self.iterator := 0;
    self.list := p_list;
    return;
  end;
  --
  member procedure parse_xml(p_xmlinfo xmltype) is
    cursor l_parse_cur is
      select t.key, t.value
      from   xmltable('/content/param' passing(p_xmlinfo)
               columns
                 key varchar2(1024) path 'key',
                 value varchar2(1024) path 'value'
             ) t;
  begin
    for v in l_parse_cur loop
      self.add_value(v.key,v.value);
    end loop;
  end parse_xml;
  --
  member procedure first is
  begin
    self.iterator := 0;
    return;
  end first;
  --
  member procedure next(p_key in out nocopy varchar2, p_value out nocopy anydata) is
  begin
    if self.iterator >= self.list.count then
      p_key := null;
    else 
      self.iterator := self.iterator + 1;
      p_key := self.list(self.iterator).key;
      p_value := self.list(self.iterator).value;
    end if;
    --
  end next;
  --
  member function next(self in out nocopy xxdoo_db_list, p_key in out nocopy varchar2, p_value out nocopy varchar2) return boolean is
    a anydata;
    l_dummy pls_integer;
  begin
    --
    self.next(p_key, a);
    if p_key is null then
      return  false;
    end if;
    --
    l_dummy := a.GetVarchar2(p_value);
    return true;
    --
  end next;
  --
  member function next(self in out nocopy xxdoo_db_list, p_key in out nocopy varchar2, p_value out nocopy anydata) return boolean is
  begin
    --
    self.next(p_key, p_value);
    if p_key is null then
      return  false;
    end if;
    --
    return true;
    --
  end next;
  --
  member function next(self in out nocopy xxdoo_db_list, p_key in out nocopy varchar2) return boolean is
    l_dummy anydata;
  begin
    --
    self.next(p_key, l_dummy);
    if p_key is null then
      return  false;
    end if;
    --
    return true;
    --
  end next;
  --
  member procedure add_value(p_key varchar2, p_value anydata) is
    l_num number;
  begin
    l_num := get_value_num(p_key);
    if l_num is null then
      self.list.extend;
      self.list(self.list.count) := xxdoo_db_list_value(p_key, p_value);
    else
      self.list(l_num).value := p_value;
    end if;
  end add_value;
  --
  member procedure add_value(p_key varchar2, p_value varchar2) is
  begin
    self.add_value(p_key, anydata.ConvertVarchar2(p_value));
  end add_value;
  --
  member procedure add_value(p_key varchar2) is
    a anydata;
  begin
    self.add_value(p_key, a);
  end add_value;
  --
  member function get_value_num(p_key varchar2) return number is
    l_result number;
  begin
    for k in 1..self.list.count loop
      if self.list(k).key = p_key then
        l_result := k;
        exit;
      end if;
    end loop;
    --
    return l_result;
  end get_value_num;
  --
  member function get_value(p_key varchar2) return anydata is
    l_num number;
  begin
    --
    l_num := get_value_num(p_key);
    if l_num is not null then
      return self.list(l_num).value;
    end if;
    --
    return null;
  end;
  --
  member function is_exists(p_key varchar2) return boolean is
  begin
    return case
             when get_value_num(p_key) is null then
               false
             else
               true
           end;
  end;
  --
  
end;
/
