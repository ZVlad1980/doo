create or replace type body xxdoo_dao is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DAO');
  end get_type_name;
  -- 
  --
  --
  constructor function xxdoo_dao return self as result is
  begin
    return;
  end;
  -- 
  --
  --
  constructor function xxdoo_dao(p_table xxdoo_db_tab) return self as result is
  begin
    return;
  end;
  --
  --
  --
  member function  load(p_xmlinfo xmltype) return anydata is
    l_result anydata;
  begin
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  -- 
  --
  --
  member procedure put(p_object anydata) is
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
  member function  get_all(p_fast_mode boolean default null) return anydata is
    l_result anydata;
  begin
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  -- 
  --
  --
  member function  get(p_fast_mode boolean default null) return anydata is
    l_result anydata;
  begin
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  -- 
  --
  --
  member procedure update_version is
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
