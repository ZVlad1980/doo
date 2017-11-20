create or replace type body xxdoo_dsl_frm_content is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_frm_content');
  end;
  --
  constructor function xxdoo_dsl_frm_content return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_dsl_frm_content(p_name varchar2, p_type varchar2, p_hidden boolean default false) return self as result is
  begin
    self.name   := p_name;
    self.type   := p_type;
    self.hidden := case when p_hidden then 'Y' else 'N' end;
    return;
  end;
  --
  overriding member procedure generate is 
  begin
    self.h := xxdoo_html();
  end;
  --
  overriding member function get_html(self in out nocopy xxdoo_dsl_frm_content) return xxdoo_html is
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
