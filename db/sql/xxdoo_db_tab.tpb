create or replace type body xxdoo_db_tab is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_TAB');
  end get_type_name;
  --
  constructor function xxdoo_db_tab return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_db_tab(p_scheme_name varchar2, p_table_name varchar2) return self as result is
    --
    cursor l_tab_cur is
      select value(d)
      from   xxdoo_db_schemes_t s,
             xxdoo_db_tabs_v    d
      where  1=1
      and    d.name = p_table_name
      and    d.scheme_id = s.id
      and    s.name = p_scheme_name;
  begin
    open l_tab_cur;
    fetch l_tab_cur into self;
    if l_tab_cur%notfound = true then
      close l_tab_cur;
      xxdoo_db_utils_pkg.fix_exception('Table '||p_table_name||' into scheme '||p_scheme_name||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    close l_tab_cur;
    --
    return;
  end;
  --
  constructor function xxdoo_db_tab(p_object xxdoo_db_object) return self as result is
    l_type_name  varchar2(120);
    --
    cursor l_tab_cur(p_owner varchar2, p_type_name varchar2) is
      select value(d)
      from   xxdoo_db_tabs_v d
      where  1=1
      and    upper(d.owner) = p_owner
      and    upper(d.db_type) = p_type_name;
  begin
    l_type_name := p_object.get_type_name;
    open l_tab_cur(regexp_substr(l_type_name,'[^.]+',1,1), regexp_substr(l_type_name,'[^.]+',1,2));
    fetch l_tab_cur into self;
    if l_tab_cur%notfound = true then
      close l_tab_cur;
      xxdoo_db_utils_pkg.fix_exception('Table '||l_type_name||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    close l_tab_cur;
    --
    return;
  end;
  --
  constructor function xxdoo_db_tab(p_object anydata) return self as result is
    l_type_name  varchar2(120);
    --
    cursor l_tab_cur(p_owner varchar2, p_type_name varchar2) is
      select value(d)
      from   xxdoo_db_tabs_v d
      where  1=1
      and    upper(d.owner) = p_owner
      and    upper(d.db_type) = p_type_name;
  begin
    l_type_name := p_object.GetTypeName;
    open l_tab_cur(regexp_substr(l_type_name,'[^.]+',1,1), regexp_substr(l_type_name,'[^.]+',1,2));
    fetch l_tab_cur into self;
    if l_tab_cur%notfound = true then
      close l_tab_cur;
      xxdoo_db_utils_pkg.fix_exception('Table '||l_type_name||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    close l_tab_cur;
    --
    return;
  end;
  --
  constructor function xxdoo_db_tab(p_table_id number) return self as result is
    cursor l_tab_cur is
      select value(d)
      from   xxdoo_db_tabs_v d
      where  1=1
      and    d.id = p_table_id;
  begin
    open l_tab_cur;
    fetch l_tab_cur into self;
    if l_tab_cur%notfound = true then
      close l_tab_cur;
      xxdoo_db_utils_pkg.fix_exception('Table '||p_table_id||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    close l_tab_cur;
    --
    return;
  end;
  --
end;
/
