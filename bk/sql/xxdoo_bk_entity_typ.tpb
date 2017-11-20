create or replace type body xxdoo_bk_entity_typ is
  --
  constructor function xxdoo_bk_entity_typ return self as result is
  begin
    return;
  end;
  -- Member procedures and functions
  constructor function xxdoo_bk_entity_typ(p_entity_id number) return self as result is
  begin
    select value(e)
    into   self
    from   xxdoo_bk_entities_v e
    where  e.entity_id = p_entity_id;
    --
    return;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Entity ID '||p_entity_id||' not found into scheme');
      raise;
  end;
  -- Member procedures and functions
  constructor function xxdoo_bk_entity_typ(p_scheme_id number, p_source_name varchar2) return self as result is
    cursor l_entity_cur is
      select value(e)
      from   xxdoo_bk_entities_v e
      where  1=1
      and    (e.entity_name = p_source_name
               or
              e.entry_name = p_source_name
             )
      and    e.scheme_id = p_scheme_id
      union all
      select value(e)
      from   xxdoo_bk_entities_v e
      where  1=1
      and    (e.entity_name = p_source_name
               or
              e.entry_name = p_source_name
             )
      and    e.scheme_id = -1;
  begin
    --
    open l_entity_cur;
    fetch l_entity_cur into self;
    if l_entity_cur%notfound = true then
      xxdoo_utl_pkg.fix_exception('Entity name '||p_source_name||' not found into scheme '||p_scheme_id);
      raise xxdoo_bk_core_pkg.g_exc_error;
    end if;
    close l_entity_cur;
    --
    return;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Entity name '||p_source_name||' not found into scheme '||p_scheme_id);
      raise;
  end;
  -- 
  constructor function xxdoo_bk_entity_typ(p_scheme_name varchar2, p_source_name varchar2) return self as result is
    cursor l_entity_cur is
      select value(e)
      from   xxdoo_bk_entities_v e
      where  1=1
      and    e.entity_name = p_source_name
      and    e.scheme_name = p_scheme_name
      union all
      select value(e)
      from   xxdoo_bk_entities_v e
      where  1=1
      and    e.entry_name = p_source_name
      and    e.scheme_name = p_scheme_name;
  begin
    --
    open l_entity_cur;
    fetch l_entity_cur into self;
    if l_entity_cur%notfound = true then
      xxdoo_utl_pkg.fix_exception('Entity name '||p_source_name||' not found into scheme ' || p_scheme_name);
      raise xxdoo_bk_core_pkg.g_exc_error;
    end if;
    close l_entity_cur;
    -- 
    return;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Entity name '||p_source_name||' not found into scheme ' || p_scheme_name);
      raise;
  end;
  --
end;
/
