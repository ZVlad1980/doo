create or replace type body xxdoo_dsl_frm_fieldset is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_frm_fieldset');
  end;
  --
  constructor function xxdoo_dsl_frm_fieldset return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_dsl_frm_fieldset(p_name varchar2, p_cols number, p_elements xxdoo_dsl_frm_list) return self as result is
  begin
    self.name       := p_name;
    self.column_cnt := p_cols;
    --
    select value(c)
    bulk collect into self.contents
    from   table(p_elements) c;
    --
    return;
  end;
  --
  overriding member procedure generate is 
  begin
    self.h := xxdoo_html();
  end;
  --
  overriding member function get_html(self in out nocopy xxdoo_dsl_frm_fieldset) return xxdoo_html is
  begin
    self.generate;
    return self.h;
  end;
  --
  overriding member function get_element_type return varchar2 is
  begin
    return xxdoo_dsl_utils_pkg.g_el_fieldset;
  end;
  --
end;
/
