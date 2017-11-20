create or replace type body xxdoo_json is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_JSON');
  end get_type_name;
  --
  --
  --
  constructor function xxdoo_json return self as result is
  begin
    self.elements := xxdoo_json_elements();
    return;
  end xxdoo_json;
  --
  --
  --
  constructor function xxdoo_json(p_json clob) return self as result is
  begin
    self := xxdoo_json;
    self.build(to_char(p_json));
    return;
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception('JSON error.');
      raise;
  end xxdoo_json;
  --
  --
  --
  member procedure build(p_json varchar2) is
    -- 
  begin
    select value(e)--e.name, e.type, e.value
    bulk collect into self.elements
    from   table(xxdoo_json_pkg.parse_json(p_json)) e;
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception('Build JSON error.');
      raise;
  end build;
  --
  --
  --
  member function get_parent return number is
    l_result number;
  begin
    if self.levels is null then
      return null;
    end if;
    --
    if self.levels.count > 0 then
      l_result := self.levels(self.levels.count);
    end if;
    --
    return l_result;
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception('JSON get_parent error.');
      raise;
  end get_parent;
  --
  --
  --
  member procedure first is
  begin
    levels := xxdoo_db_list_number();
    position := 0;
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception('First JSON error.');
      raise;
  end;
  --
  --
  --
  member function next(self in out nocopy xxdoo_json, p_element in out nocopy xxdoo_json_element) return boolean is
    l_result boolean := true;
    --
    cursor l_element_cur(p_pos number, p_parent_id number) is
      select value(e)
      from   table(self.elements) e
      where  e.id > p_pos
      and    ((p_parent_id is not null and e.parent_id = p_parent_id) or (p_parent_id is null and e.parent_id is null));
  begin
    open l_element_cur(self.position, self.get_parent);
    fetch l_element_cur into p_element;
    if l_element_cur%notfound = true then
      l_result := false;
    else
      self.position := p_element.id;
    end if;
    close l_element_cur;
    return l_result;
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception('Next JSON error (element='||p_element.name||').');
      raise;
  end next;
  --
  --
  --
  member procedure set_parent(p_name varchar2) is
    l_element xxdoo_json_element;
  begin
    l_element:=element(p_name);
    if l_element.id is null then
      xxdoo.xxdoo_utl_pkg.fix_exception('JSON: Set parent element '||p_name||' not found.');
      raise apps.fnd_api.g_exc_error;
    else
      self.position := l_element.id;
      self.inside;
    end if;
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception('JSON: Set parent element '||p_name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure inside is
  begin
    if self.elements(self.position).type in ('O','A') then
        levels.extend;
        levels(levels.count) := self.elements(self.position).id;
        self.position := 0;
    else
        xxdoo.xxdoo_utl_pkg.fix_exception('JSON: Set parent element '||self.elements(self.position).name||' must be Object or Array.');
        raise apps.fnd_api.g_exc_error;
    end if;
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception('Inside JSON error.');
      raise;
  end inside;
  --
  --
  --
  member procedure outside is
    l_parent number;
  begin
    l_parent := self.get_parent;
    if l_parent is not null then
      self.position := self.elements(l_parent).id;
      levels.trim;
    else
      xxdoo.xxdoo_utl_pkg.fix_exception('Outside JSON error: current level is null.');
      raise apps.fnd_api.g_exc_error;
    end if;
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception('Outside JSON error.');
      raise;
  end outside;
  --
  --
  --
  member function element(p_name varchar2) return xxdoo_json_element is
    l_result xxdoo_json_element;
    --
    cursor l_element_cur(p_parent_id number) is
      select value(e)
      from   table(self.elements) e
      where  1 = 1
      and    e.name = p_name
      and    ((p_parent_id is not null and e.parent_id = p_parent_id) or (p_parent_id is null and e.parent_id is null));
  begin
    open l_element_cur(self.get_parent);
    fetch l_element_cur into l_result;
    close l_element_cur;
    --
    return l_result;
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception('Element JSON error (element='||p_name||').');
      raise;
  end element;
  --
end;
/
