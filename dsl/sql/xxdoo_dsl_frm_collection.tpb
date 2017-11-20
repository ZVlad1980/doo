create or replace type body xxdoo_dsl_frm_collection is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_frm_collection');
  end;
  --
  constructor function xxdoo_dsl_frm_collection return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_dsl_frm_collection(p_entry varchar2, p_elements xxdoo_dsl_frm_list) return self as result is
  begin
    self.name       := p_entry;
    self.entry_name := p_entry;
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
  overriding member function get_html(self in out nocopy xxdoo_dsl_frm_collection) return xxdoo_html is
  begin
    self.generate;
    return self.h;
  end;
  --
  overriding member function get_element_type return varchar2 is
  begin
    return xxdoo_dsl_utils_pkg.g_el_collection;
  end;
  --
end;
/
