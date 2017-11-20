create or replace type body xxdoo.xxdoo_bk_role_page_typ is
  --default constructor
  constructor function xxdoo_bk_role_page_typ return self as result is
  begin
    return;
  end;
  --
  --
  --
  constructor function xxdoo_bk_role_page_typ(p_page xxdoo_bk_page_typ) return self as result is
  begin
    self.page := p_page;
    self.filters := xxdoo_bk_methods_typ();
    return;
  end;
  --
  --
  --
  member procedure set_id is
  begin
    --
    if self.id is null then
      self.id := xxdoo_bk_role_pages_seq.nextval;
    end if;
    --
    if self.condition_method is not null then
      self.condition_method.set_id;
    end if;
    --
  end set_id;
  --
  --
  --
  member procedure set_page(p_page xxdoo_bk_page_typ) is
  begin
    self.page := p_page;
    if self.filters is null then
      self.filters := xxdoo_bk_methods_typ();
    end if;
    self.save := 'Y';
  end;
  --
  --
  --
  member function get_filter_num(p_method_name varchar2) return number is
    l_result number;
  begin
    if self.filters is not null then
      for f in 1..self.filters.count loop
        if self.filters(f).get_method_name = p_method_name then
          l_result := f;
          exit;
        end if;
      end loop;
    end if;
    --
    return l_result;
  end;
  --
  --
  --
  member procedure is_when(p_method  xxdoo_bk_method_typ) is
    --
    fn number;
    id number;
  begin
    fn := self.get_filter_num(p_method.get_method_name);
    --
    if fn is null then
      self.filters.extend;
      fn := self.filters.count;
    else
      id := self.filters(fn).id;
    end if;
    --
    self.filters(fn) := p_method;
    self.filters(fn).id := id;
    --
  exception 
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end is_when;
  --
  --
  --
  member procedure build_condition_method is
    t xxdoo_db_text;
    id number;
  begin
    if self.filters.count = 0 then
      self.condition_method := null;
      return;
    end if;
    t := xxdoo_db_text();
    t.append('begin');
    t.inc(2);
    t.append('if ',false);
    t.inc(3);
    for f in 1..self.filters.count loop
      if f > 1 then
        t.append(' and');
      end if;
      t.append(self.filters(f).get_method_name||'(:p_answer)',false);
    end loop;
    t.append(' then');
    t.dec(1);
    t.append(':l_result := ''Y'';');
    t.dec(2);
    t.append('else');
    t.inc(2);
    t.append(':l_result := ''N'';');
    t.dec;
    t.append('end if;');
    t.dec;
    t.append('end;');
    --
    if self.condition_method is null then
      self.condition_method := xxdoo_bk_method_typ('condition_method');
    else
      id := self.condition_method.id;
    end if;
    self.condition_method.set_text(t.get_clob);
    self.condition_method.id := id;
    --
  end build_condition_method; 
  --
end;
/
