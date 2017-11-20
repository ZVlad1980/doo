create or replace type body xxdoo_dao_attribute is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DAO_ATTRIBUTE');
  end get_type_name;
  -- 
  --
  --
  constructor function xxdoo_dao_attribute return self as result is
  begin
    return;
  end;
  --
  --
  --
  member procedure xml_string(c in out nocopy xxdoo_db_text, p_path varchar2) is
  begin
    null;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  -- 
  --
  --
  member procedure load_string(s in out nocopy xxdoo_db_select, 
                               p_alias_vw  varchar2,
                               p_alias_xml varchar2) is
  begin
    null;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
end;
/
