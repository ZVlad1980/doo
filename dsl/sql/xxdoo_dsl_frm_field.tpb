create or replace type body xxdoo_dsl_frm_field is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_frm_field');
  end;
  --
  constructor function xxdoo_dsl_frm_field return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_dsl_frm_field(p_name varchar2, p_elements xxdoo_dsl_frm_list) return self as result is
  begin
    self.name := p_name;
    --
    select treat(value(c) as xxdoo_dsl_frm_content)
    bulk collect into self.contents
    from   table(p_elements) c
    where  c.element_type = xxdoo_dsl_utils_pkg.g_el_content
    order by aid;
    --
    return;
  end;
  --
  overriding member procedure generate is 
  begin
    self.h := xxdoo_html();
  end;
  --
  overriding member function get_html(self in out nocopy xxdoo_dsl_frm_field) return xxdoo_html is
  begin
    self.generate;
    return self.h;
  end;
  --
  overriding member function get_element_type return varchar2 is
  begin
    return xxdoo_dsl_utils_pkg.g_el_field;
  end;
  --
end;
/
