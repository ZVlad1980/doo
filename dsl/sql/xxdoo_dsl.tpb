create or replace type body xxdoo_dsl is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin 
    return upper('xxdoo_dsl');
  end;
  --
  member function unless(p_condition varchar2) return varchar2 is
  begin
    return xxdoo_utl_pkg.get_function_str(p_fn_name => xxdoo_utl_pkg.g_fn_unless, p_fn_args => xxdoo_utl_pkg.g_fn_args(p_condition));
  end;
  --
  --
  --
  member function when#(p_condition varchar2) return varchar2 is
  begin
    return xxdoo_utl_pkg.get_function_str(p_fn_name => xxdoo_utl_pkg.g_fn_when, p_fn_args => xxdoo_utl_pkg.g_fn_args(p_condition));
  end;
  --
  --
  --
  member function condition#(p_condition varchar2) return varchar2 is
  begin
    return xxdoo_utl_pkg.get_function_str(p_fn_name => xxdoo_utl_pkg.g_fn_condition, p_fn_args => xxdoo_utl_pkg.g_fn_args(p_condition));
  end;
  --
  --
  --
  member function g(p_value varchar2) return varchar2 is
  begin
    return xxdoo_utl_pkg.get_function_str(p_fn_name => xxdoo_utl_pkg.g_fn_getter, p_fn_args => xxdoo_utl_pkg.g_fn_args(p_value));
  end;
  --
  member function eql(p_value varchar2, p_value2 varchar2) return varchar2 is
  begin
    return xxdoo_utl_pkg.get_function_str(p_fn_name => xxdoo_utl_pkg.g_fn_eql, p_fn_args => xxdoo_utl_pkg.g_fn_args(p_value,p_value2));
  end;
  --
  --
  --
  member function all#(p_list xxdoo_db_list_varchar2) return varchar2 is
    l_fn_args xxdoo_utl_pkg.g_fn_args;
  begin
    select column_value
    bulk collect into l_fn_args
    from   table(p_list);
    --
    return xxdoo_utl_pkg.get_function_str(p_fn_name => xxdoo_utl_pkg.g_fn_all, p_fn_args => l_fn_args);
  end;
  --
  --
  --
  member function not#(p_condition varchar2) return varchar2 is
  begin
    return xxdoo_utl_pkg.get_function_str(p_fn_name => xxdoo_utl_pkg.g_fn_not, p_fn_args => xxdoo_utl_pkg.g_fn_args(p_condition));
  end;
  --
  --
  --
  member function firstOf(p_list xxdoo_db_list_varchar2) return varchar2 is
    l_fn_args xxdoo_utl_pkg.g_fn_args;
  begin
    select column_value
    bulk collect into l_fn_args
    from   table(p_list);
    --
    return xxdoo_utl_pkg.get_function_str(p_fn_name => xxdoo_utl_pkg.g_fn_firstOf, p_fn_args => l_fn_args);
  end;
  --
end;
/
