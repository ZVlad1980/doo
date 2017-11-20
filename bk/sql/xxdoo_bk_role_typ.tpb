create or replace type body xxdoo.xxdoo_bk_role_typ is
  --default constructor
  constructor function xxdoo_bk_role_typ return self as result is
  begin
    --self.method := xxdoo.xxdoo_bk_method_typ();
    self.pages := xxdoo.xxdoo_bk_role_pages_typ();
    self.parameters := xxdoo_db_list();
    return;
  end;
  --procedure assignment sequence numbers
  member procedure set_id is
  begin
    --
    if self.id is null then
      self.id := xxdoo_bk_roles_seq.nextval;
    end if;
    --
    for i in 1..self.pages.count loop
      self.pages(i).set_id;
    end loop;
    --
    if self.method is not null then
      self.method.set_id;
    end if;
    --
  end set_id;
  --
  constructor function xxdoo_bk_role_typ(p_name varchar2) return self as result is
  begin
    self := xxdoo_bk_role_typ;
    self.name := p_name;
    return;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  constructor function xxdoo_bk_role_typ(p_book_name varchar2, p_role_name varchar2) return self as result is
    cursor l_roles_cur is
      select value(r)
      from   xxdoo_bk_roles_v r,
             xxdoo_bk_books_t b
      where  1=1
      and    r.name = p_role_name
      and    r.book_id = b.id
      and    b.name = p_book_name;
  begin
    open l_roles_cur;
    fetch l_roles_cur into self;
    if l_roles_cur%notfound = true then
      close l_roles_cur;
      xxdoo_utl_pkg.fix_exception('Role '||p_role_name||' not found into book '||p_book_name);
      raise xxdoo_bk_core_pkg.g_exc_error;
    end if;
    close l_roles_cur;
    --
    if self.parameters is null then
      self.parameters := xxdoo_db_list();
    end if;
    --
    return;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Constructor role error. Role name '||p_role_name||', book name '||p_book_name);
      raise;
  end;
  --
  --
  --
  member procedure set_method(p_method xxdoo_bk_method_typ) is
    id number;
  begin
    if p_method is null then
      self.method := null;
    else
      if self.method is not null then
        id := self.method.id;
      end if;
      --
      self.method := p_method;
      self.method.id := id;
    end if;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end set_method;
  --
  --
  --
  member function get_role_page_num(p_page_name varchar2) return number is
    l_result number;
  begin
    for rp in 1..self.pages.count loop
      if self.pages(rp).page.name = p_page_name then
        l_result := rp;
        exit;
      end if;
    end loop;
    --
    return l_result;
  end;
  --
  --
  --
  member procedure page(p_page xxdoo_bk_page_typ) is
  begin
    self.current_role_page := self.get_role_page_num(p_page.name);
    --
    if self.current_role_page is null then
      self.pages.extend;
      self.current_role_page := self.pages.count;
      self.pages(self.current_role_page) := xxdoo_bk_role_page_typ;
    end if;
    --
    self.pages(self.current_role_page).set_page(p_page);
    self.pages(self.current_role_page).order_num := xxdoo.xxdoo_bk_engine_pkg.get_role_page_position(self.name,p_page.name);
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end page;
  --
  --
  --
  member function page(p_page xxdoo_bk_page_typ) return xxdoo_bk_role_typ is
    l_result xxdoo_bk_role_typ;
  begin
    l_result := self;
    l_result.page(p_page);
    --
    return l_result;
  exception 
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end page;
  --
  --
  --
  member procedure is_when(p_method xxdoo_bk_method_typ) is
  begin
    self.pages(self.current_role_page).is_when(p_method);
  exception 
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end is_when;
  --
  --
  --
  member function is_when(p_method xxdoo_bk_method_typ) return xxdoo_bk_role_typ is
    l_result xxdoo_bk_role_typ;
  begin
    l_result := self;
    l_result.is_when(p_method);
    --
    return l_result;
  exception 
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end is_when;
  --
  --
  --
  member procedure is_when(p_method xxdoo_bk_method_typ, p_pages xxdoo_bk_pages_typ) is
  begin
    for p in 1..p_pages.count loop
      self.page(p_pages(p));
      self.is_when(p_method);
    end loop;
    --
  exception 
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end is_when;
  --
  --
  --
  member procedure prepare_role is
    l_role_pages xxdoo_bk_role_pages_typ;
  begin
    l_role_pages := xxdoo_bk_role_pages_typ();
    --
    for p in 1..self.pages.count loop
      if self.pages(p).save = 'Y' then
        self.pages(p).build_condition_method;
        l_role_pages.extend;
        l_role_pages(l_role_pages.count) := self.pages(p);
      end if;
    end loop;
    --
    self.pages := l_role_pages;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Prepare role '||self.name||' error.');
      raise;
  end prepare_role;
  --
  --
  --
  member procedure set_par(p_key varchar2, p_value varchar2) is
  begin
    self.parameters.add_value(p_key, p_value);
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Set parameter '||p_key||'='||p_value||' into role '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure set_par(p_key varchar2, p_value number) is
  begin
    self.parameters.add_value(p_key, anydata.ConvertNumber(p_value));
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Set parameter '||p_key||'='||p_value||' into role '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure set_par(p_key varchar2, p_value date) is
  begin
    self.parameters.add_value(p_key, anydata.ConvertDate(p_value));
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Set parameter '||p_key||'='||p_value||' into role '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure set_par(p_key varchar2, p_value anydata) is
  begin
    self.parameters.add_value(p_key, p_value);
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Set parameter '||p_key||'=anydata('||p_value.GetTypeName||') into role '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member function get(p_key varchar2) return varchar2 is
    l_result varchar2(4000);
    a        anydata;
    l_dummy  integer;
  begin
    a := self.parameters.get_value(p_key);
    if a is not null then
      l_dummy := a.GetVarchar2(l_result);
    end if;
    --
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Get parameter '||p_key||' from role '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member function get_number(p_key varchar2) return number is
    l_result number;
    a        anydata;
    l_dummy  integer;
  begin
    a := self.parameters.get_value(p_key);
    if a is not null then
      l_dummy := a.GetNumber(l_result);
    end if;
    --
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Get parameter '||p_key||' from role '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member function get_date(p_key varchar2) return date is
    l_result date;
    a        anydata;
    l_dummy  integer;
  begin
    a := self.parameters.get_value(p_key);
    if a is not null then
      l_dummy := a.GetDate(l_result);
    end if;
    --
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Get parameter '||p_key||' from role '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member function get_anydata(p_key varchar2) return anydata is
  begin
    return self.parameters.get_value(p_key);
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Get parameter '||p_key||' from role '||self.name||' error.');
      raise;
  end;
  --
end;
/
