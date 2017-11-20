create or replace type body xxdoo_dsl_tbl_cell is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin 
    return upper('xxdoo_dsl_tbl_cell');
  end;
  --
  --
  --
  constructor function xxdoo_dsl_tbl_cell(p_h xxdoo_html) return self as result is
  begin
    self.h := p_h;
    return;
  end;
  
end;
/
