create or replace type body xxdoo_html_el_attr_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_el_attr_typ return self as result is
  begin
    return;
  end;
  constructor function xxdoo_html_el_attr_typ(p_name varchar2,p_value varchar2) return self as result is
  begin
    self.name  := p_name;
    self.value := xxdoo_html_el_value_typ(p_value);
    return;
  end;
  constructor function xxdoo_html_el_attr_typ(p_name varchar2,p_value xxdoo_html_el_value_typ) return self as result is
  begin
    self.name  := p_name;
    self.value := p_value;
    return;
  end;
  --
  member procedure add_value(p_value varchar2) is
  begin
    self.value.add_value(p_value);
  end;
  --
  member function as_string return varchar2 is
  begin
    return self.name || '=' || self.value.as_string;
  end;
  --
  member procedure prepare(self in out nocopy xxdoo_html_el_attr_typ, p_ctx in out nocopy xxdoo_html_el_context_typ) is
  begin
    self.value.prepare(p_ctx);
  end;
  --
  --
end;
/
