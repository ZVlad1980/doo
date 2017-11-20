create or replace type body xxdoo_bk_template_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_bk_template_typ return self as result is
  begin
    return;
  end;
  --
--procedure assignment sequence numbers
  member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_bk_templates_seq.nextval;
    end if;
    if self.method is not null then
      self.method.set_id;
    end if;
  end;
  --
  constructor function xxdoo_bk_template_typ(p_book_id number, p_name varchar2) return self as result is
    cursor l_template_cur is
      select value(t)
      from   xxdoo_bk_templates_v t
      where  1=1
      and    t.name = p_name
      and    t.book_id = p_book_id;
  begin
    open l_template_cur;
    fetch l_template_cur into self;
    if  l_template_cur%notfound then
      close l_template_cur;
      xxdoo_utl_pkg.fix_exception('Template '||p_name||' (book id '||p_book_id||') not found.');
      raise xxdoo_bk_core_pkg.g_exc_error;
    end if;
    close l_template_cur;
    --
    return;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Template '||p_name||' (book id '||p_book_id||') error');
      raise;
  end;
  --
  --
  --
  constructor function xxdoo_bk_template_typ(p_name varchar2, p_entity xxdoo_bk_entity_typ default null, p_source varchar2) return self as result is
  begin
    self.name := p_name;
    self.entity := p_entity;
    self.source_name := p_source;
    return;
  end;
  --
  member procedure build(p_html xxdoo_html, p_source_name varchar2) is
    l_html xxdoo_html;
  begin
    if self.entity is not null then
      l_html := xxdoo_html(p_html, 
                           self.entity.owner, 
                           case p_source_name
                             when self.entity.entity_name then
                               self.entity.collect_name
                             else
                               self.entity.object_name
                           end);
    else
      l_html := p_html;
    end if;
    --
    if self.method is null then
      self.method := xxdoo.xxdoo_bk_method_typ('content_'||lower(self.name));
    end if;
    --
    self.method.build(l_html);
    --
    return;
  end;
  --
  member function content(p_context in out nocopy xxdoo_html_context, p_object anydata) return clob is
  begin
    if self.entity.entity_id is null then
      return xxdoo_html_pkg.get_html(self.method.get_body,anydata.ConvertObject(p_context));
    else
      --добавить проверку наличия объекта! Если нет - не формировать контент!
      if p_object is not null then
        p_context.entries.add_value(self.source_name, p_object);
        return xxdoo_html_pkg.get_html(self.method.get_body, anydata.ConvertObject(p_context));
      end if;
    end if;
    return null;
  end;
  --
  member function check_version return boolean is
  begin
    return self.method.check_version;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Template '||self.name||' check version error.');
      raise;
  end;
  --
end;
/
