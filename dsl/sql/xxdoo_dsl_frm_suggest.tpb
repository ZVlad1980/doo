create or replace type body xxdoo_dsl_frm_suggest is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_frm_suggest');
  end;
  --
  constructor function xxdoo_dsl_frm_suggest return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_dsl_frm_suggest(p_name varchar2) return self as result is
  begin
    self.name        := p_name;
    self.type        := xxdoo_dsl_utils_pkg.g_fld_suggest;
    self.fld_id_name := 'id';
    return;
  end;
  --
  overriding member procedure generate is 
  begin
    self.h := xxdoo_html();
  end;
  --
  overriding member function get_html(self in out nocopy xxdoo_dsl_frm_suggest) return xxdoo_html is
  begin
    self.generate;
    return self.h;
  end;
  --
  overriding member function get_element_type return varchar2 is
  begin
    return xxdoo_dsl_utils_pkg.g_el_content;
  end;
  --
end;
/
