create or replace type body xxdoo_html_el_cont_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_el_cont_typ return self as result is
  begin
    self.set_id;
    return;
  end;
  --
  constructor function xxdoo_html_el_cont_typ(p_content varchar2) return self as result is
  begin
    self.set_id;
    self.value := xxdoo_html_el_value_typ(p_content,'C');
    return;
  end;
  --
  overriding member function as_string return varchar2 is
  begin
    return self.value.as_string;
  end;
  --
  overriding member function as_string_end return varchar2 is
  begin
    return null;
  end;
  --
  overriding member function prepare(self in out nocopy xxdoo_html_el_cont_typ, p_ctx xxdoo_html_el_context_typ) return xxdoo_html_el_context_typ is
    l_ctx xxdoo_html_el_context_typ := p_ctx;
  begin
    self.value.prepare(l_ctx);
    return l_ctx;
  end;
  --
  overriding member function get_attribute_value(p_name varchar2) return varchar2 is 
  begin
    return null;
  end;
  --
end;
/
