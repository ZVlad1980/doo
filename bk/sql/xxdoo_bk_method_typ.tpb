create or replace type body xxdoo.xxdoo_bk_method_typ is
  --default constructor
  --
  constructor function xxdoo_bk_method_typ(p_name varchar2) return self as result is
  begin
    self.name := p_name;
    return;
  end;
  --
  constructor function xxdoo_bk_method_typ(p_owner varchar2, p_package varchar2, p_method varchar2) return self as result is
  begin
    self.name := p_method;
    self.set_package(p_owner,p_package);
    return;
  end;
  --
  member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_bk_methods_seq.nextval;
    end if;
  end set_id;
  --
  member function check_version return boolean is
    l_result boolean := true;
    l_version number;
    --
    cursor l_version_cur is
      select version
      from   xxdoo_bk_methods_t m
      where  m.id = self.id;
  begin
    open l_version_cur;
    fetch l_version_cur into l_version;
    close l_version_cur;
    --
    if l_version <> self.version then
      l_result := false;
    end if;
    return l_result;
  end;
  --
  member procedure set_package(p_owner varchar2, p_package varchar2) is
  begin
    --
    self.owner := p_owner;
    self.package := p_package;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end set_package;
  --
  member procedure set_text(p_spc varchar2, p_body clob) is
  begin
    --
    self.spc  := nvl(p_spc,self.spc);
    self.body := p_body;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end set_text;
  --
  member procedure set_text(p_body clob) is
  begin
    self.set_text(null,p_body);
  end set_text;
  --
  member procedure build(p_html xxdoo_html) is
    l_html xxdoo_html := p_html;
  begin
    self.body := l_html.get_method('get_html');
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end build;
  --
  member function get_body return clob is
  begin
    return self.body;
  end get_body;
  --
  member function get_method_name return varchar2 is
  begin
    return self.owner || '.' || self.package || '.' || self.name;
  end;
  --
end;
/
