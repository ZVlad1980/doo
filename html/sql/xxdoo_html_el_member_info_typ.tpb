create or replace type body xxdoo_html_el_member_info_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_el_member_info_typ return self as result is
  begin
    return;
  end;
  constructor function xxdoo_html_el_member_info_typ(p_owner       varchar2, 
                                                    p_object_name varchar2, 
                                                    p_member_name varchar2
                                                    ) return self as result is
  begin
    self.data_type_owner := p_owner;
    self.data_type       := p_object_name;
    self.name            := p_member_name;
    self.data_type_code  := xxdoo_html_utils_pkg.get_object_type(p_object_owner => p_owner, p_object_name => p_object_name);
    return;
  end;
  
end;
/
