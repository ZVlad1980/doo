create or replace type body xxdoo_bk_book_base_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_bk_book_base_typ return self as result is
  begin
    return;
    --
  end;
  --
  constructor function xxdoo_bk_book_base_typ(p_name varchar2) return self as result is
  begin
    select value(bb) 
    into   self
    from   xxdoo_bk_books_base_v bb
    where  bb.name = p_name;
    --
    self.path_parser := xxdoo_p2r_parser(self.path);
    --
    return;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Constructor book_base failed.');
      raise;
  end;
  --
  --
  --
  member function check_version return boolean is
    cursor l_version_cur(p_book_id number) is
      select b.version
      from   xxdoo_bk_books_t b
      where  b.id = p_book_id;
    --
    l_version xxdoo_bk_books_t.version%type;
    --
    l_result boolean := true;
  begin
    open l_version_cur(self.id);
    fetch l_version_cur into l_version;
    if l_version_cur%notfound then
      close l_version_cur;
      return false; 
    end if;
    close l_version_cur;
    --
    if l_version <> self.version then
      l_result := false;--self := xxdoo_bk_book_typ(self.name);
    end if;
    --
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Book '||self.name||' check version error.');
      raise;  
  end;
  --
  member function get_region_num(p_region_name varchar2) return number is
    l_result number := null;
  begin
    --
    for r in 1..self.regions.count loop
      if self.regions(r).name = p_region_name then
        l_result := r;
        exit;
      end if;
    end loop;
    --
    return l_result;
    --
  end;
  --
  --
  --
  member function get_region_html(p_region_name varchar2) return clob is
    rn number;
  begin
    rn := self.get_region_num(p_region_name);
    if rn is not null then
      return self.regions(rn).html;
    end if;
    return null;
  end;
  --
  member function get_callback_num(p_callback_code varchar2) return number is
    l_result number := null;
  begin
    --
    for r in 1..self.callbacks.count loop
      if self.callbacks(r).code = p_callback_code then
        l_result := r;
        exit;
      end if;
    end loop;
    --
    return l_result;
    --
  end;
  --
  --
  --
  member function get_callback_num_from_id(p_callback_id varchar2) return number is
    l_result number := null;
  begin
    --
    for r in 1..self.callbacks.count loop
      if self.callbacks(r).id = p_callback_id then
        l_result := r;
        exit;
      end if;
    end loop;
    --
    return l_result;
    --
  end;
  --
  --
  --
  member function region_exists(p_region_name varchar2) return boolean is
    l_result boolean := true;
  begin
    if get_region_num(p_region_name) is null then
      l_result := false;
    end if;
    --
    return l_result;
  exception 
    when others then
      xxdoo_utl_pkg.fix_exception('Check exists region '||p_region_name||' error.');
      raise;
  end region_exists;
  --
  --
  --
  member function get_js_link return varchar2 is
  begin
    return xxdoo_utl_pkg.get_url_resource || nvl(self.get_resource('JS'),'oracle-client_3.js');
  end get_js_link;
  --
  --
  --
  member function get_css_link return varchar2 is
  begin
    return xxdoo_utl_pkg.get_url_resource || nvl(self.get_resource('CSS'),'noodoo-ui_7.css');
  end get_css_link;
  --
  --ЗАГЛУШКА! С картинками надо решить...
  --
  member function get_image_link return varchar2 is
  begin
    return null;
  end get_image_link;
  --
  --
  --
  member function get_resource(p_name varchar2) return varchar2 is
    --
    l_result xxdoo.xxdoo_bk_resources_t.value%type;
    --
    cursor l_resource_cur is
      select r.value
      from   table(self.resources) r
      where  r.name = p_name;
  begin
    --
    open l_resource_cur;
    fetch l_resource_cur into l_result;
    close l_resource_cur;
    --
    return l_result;
    --
  end get_resource;
  --
  --
  --
  member function get_content return clob is
  begin
    return self.get_region_html('content');
  end;
  --
  member function get_sidebar return clob is
  begin
    return self.get_region_html('sidebar');
  end;
  --
  member function get_toolbar return clob is
  begin
    return self.get_region_html('toolbar');
  end;
  --
end;
/
