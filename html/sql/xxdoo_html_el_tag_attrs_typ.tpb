create or replace type body xxdoo_html_el_tag_attrs_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_el_tag_attrs_typ return self as result is
  begin
    self.attrs := xxdoo_html_el_attrs_typ();
    return;
  end;
  --
  constructor function xxdoo_html_el_tag_attrs_typ(p_name varchar2,p_value varchar2) return self as result is
  begin
    self.attrs := xxdoo_html_el_attrs_typ();
    self.attr(p_name,p_value);
    return;
  end;
  --
  member procedure attr(p_name varchar2, p_value varchar2) is
    l_id number;
    l_dummy varchar2(1);
  begin
    l_id := get_id(p_name);
    if l_id > 0 then
      self.attrs(l_id).add_value(p_value);
    else
      self.attrs.extend;
      self.attrs(self.attrs.count) := xxdoo_html_el_attr_typ(p_name => p_name,p_value => p_value);
    end if;
  end;
  --
  member function attr(p_name varchar2, p_value varchar2) return xxdoo_html_el_tag_attrs_typ is
    l_new_obj xxdoo_html_el_tag_attrs_typ;
  begin
    l_new_obj := self;
    l_new_obj.attr(p_name,p_value);
    return l_new_obj;
  end;
  --
  member function get_id(p_name varchar2) return number is
  begin
    for id in 1..self.attrs.count loop
      if self.attrs(id).name = p_name then
        return id;
      end if;
    end loop;
    return 0;
  end;
  --
  member function as_string return varchar2 is
    l_result varchar2(2000);
  begin
    for i in 1..self.attrs.count loop
      l_result := l_result  || 
                    case
                      when l_result is not null then
                        ' '
                    end 
                  || self.attrs(i).as_string;
    end loop;
    --
    return case
             when l_result is not null then
              ' ' || l_result
           end;
  end;
  --
  member procedure prepare(self in out nocopy xxdoo_html_el_tag_attrs_typ, p_ctx in out nocopy xxdoo_html_el_context_typ) is
  begin
    for i in 1..self.attrs.count loop
      self.attrs(i).prepare(p_ctx);
    end loop;
  end;
  --
  member function get_attribute_value(p_name varchar2) return varchar2 is
    l_result varchar2(32000);
    --
    cursor l_attrs_cur is
      select a.value.value
      from   table(self.attrs) a
      where  upper(a.name) = upper(p_name);
    --
  begin
    open l_attrs_cur;
    fetch l_attrs_cur
      into l_result;
    close l_attrs_cur;
    --
    return l_result;
  end;
  --
end;
/
