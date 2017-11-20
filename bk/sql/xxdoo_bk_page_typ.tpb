create or replace type body xxdoo.xxdoo_bk_page_typ is
  --default constructor
  constructor function xxdoo_bk_page_typ return self as result is
  begin                                                 
    return;
  end;
  --procedure assignment sequence numbers
  member procedure set_id is
  begin
    --
    if self.id is null then
      self.id := xxdoo_bk_pages_seq.nextval;
    end if;
    --
    if self.content_method is not null then
      self.content_method.set_id;
    end if;
    if self.prepare_method is not null then
      self.prepare_method.set_id;
    end if;
    --
  end set_id;
  --
  constructor function xxdoo_bk_page_typ(p_name varchar2, p_entity xxdoo_bk_entity_typ default null) return self as result is
  begin
     self := xxdoo_bk_page_typ;
     self.name := p_name;
     self.entity := p_entity;
     return;
   exception
     when others then
       xxdoo_utl_pkg.fix_exception;
  end;
  --
  --
  --
  member procedure build_html_method(p_html xxdoo_html) is
    l_html xxdoo_html;
  begin
    --
    if self.entity.object_name is not null then
      l_html := xxdoo_html(p_html, self.entity.owner, self.entity.object_name);
    else
      l_html := p_html;
    end if;
    --
    if self.content_method is null then
      self.content_method := xxdoo.xxdoo_bk_method_typ('get_'||lower(self.name)||'_page');
    end if;
    self.content_method.build(l_html);
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Build page '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure set_prepare_method(p_method xxdoo_bk_method_typ) is
    l_id number;
  begin
    --
    l_id := self.prepare_method.id;
    self.prepare_method := p_method;
    self.prepare_method.id := l_id;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Build page '||lower(self.name)||' error.');
      raise;
  end;
  --
end;
/
