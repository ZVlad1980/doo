create or replace type body xxdoo_dao_builder is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DAO_BUILDER');
  end get_type_name;
  -- 
  --
  --
  constructor function xxdoo_dao_builder return self as result is
  begin
    return;
  end;
  -- 
  --
  --
  constructor function xxdoo_dao_builder(p_scheme_name varchar2) return self as result is
  begin
    return;
  end;
  --
  --
  --
  member procedure build is
  begin
    null;
  end;
  --
end;
/
