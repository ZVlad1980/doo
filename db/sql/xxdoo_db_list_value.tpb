create or replace type body xxdoo_db_list_value is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_db_list_value');
  end;
  --
  constructor function xxdoo_db_list_value(p_key varchar2, p_value anydata) return self as result is
  begin
    self.key := p_key;
    self.value := p_value;
    return;
  end;
  --
end;
/
