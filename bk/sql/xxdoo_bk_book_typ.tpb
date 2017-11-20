create or replace type body xxdoo.xxdoo_bk_book_typ is
  --default constructor
  constructor function xxdoo_bk_book_typ return self as result is
  begin                                        
    --self.service := xxdoo.xxdoo_bk_service_typ();
    self.pages := xxdoo.xxdoo_bk_pages_typ();
    self.roles := xxdoo.xxdoo_bk_roles_typ();
    self.resources := xxdoo.xxdoo_bk_resources_typ();
    self.callbacks := xxdoo.xxdoo_bk_callbacks_typ();
    self.regions := xxdoo.xxdoo_bk_regions_typ();
    self.templates := xxdoo.xxdoo_bk_templates_typ();
    return;
  end;
  --
  constructor function xxdoo_bk_book_typ(p_name varchar2) return self as result is
  begin
    xxdoo.xxdoo_utl_pkg.init_exceptions;
    --
    select value(b)
    into   self
    from   xxdoo_bk_books_v b
    where  b.name = p_name;
    
    --
    if self.resources is null then
      self.resources := xxdoo.xxdoo_bk_resources_typ();
    end if;
    --
    if self.callbacks is null then
      self.callbacks := xxdoo.xxdoo_bk_callbacks_typ();
    end if; 
    --
    return;
  exception
    when no_data_found then
      xxdoo_utl_pkg.fix_exception('Constructor book error. Book "'||p_name||'" not found.');
      raise;
    when others then
      xxdoo_utl_pkg.fix_exception('Constructor book error. Book "'||p_name||'". ');
      raise;
  end;
  --
  constructor function xxdoo_bk_book_typ(p_name     varchar2,
                                         p_scheme   varchar2,
                                         p_table    varchar2,
                                         p_package  varchar2 default null,
                                         p_path     varchar2 default null,
                                         p_dev_code varchar2 default null,
                                         p_owner    varchar2 default null,
                                         p_title    varchar2 default null) return self as result is
  begin
    begin
      self := xxdoo_bk_book_typ(p_name);
      --
      self.path := p_path;
      self.title := nvl(p_title,self.title);
      --
      return;
    exception 
      when others then
        xxdoo_utl_pkg.init_exceptions;
    end;
    --
    self := xxdoo_bk_book_typ();
    self.name     := p_name;
    self.entity   := xxdoo_bk_entity_typ(p_scheme, p_table);
    self.dev_code := nvl(p_dev_code, self.entity.dev_code);
    self.owner    := nvl(p_owner, regexp_substr(self.dev_code, '[^_]+',1,1));
    self.path     := p_path;
    self.title    := nvl(p_title,self.title);
    self.service  := xxdoo_bk_service_typ(p_service_name => self.name,
                                          p_namespace    => xxdoo_utl_pkg.get_service_namespace);
    --
    if p_package is not null then
      self.package  := self.fn(self.owner, p_package, null); 
    end if;
    --
    return;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Create book "'||p_name||'" error.');
      raise;
  end;
  --procedure assignment sequence numbers
  member procedure set_id is
  begin
    --
    if self.id is null then
      self.id := xxdoo_bk_books_seq.nextval;
    end if;
    for i in 1..self.pages.count loop
      self.pages(i).set_id;
    end loop;
    for i in 1..self.roles.count loop
      self.roles(i).set_id;
    end loop;
    for i in 1..self.resources.count loop
      self.resources(i).set_id;
    end loop;
    for i in 1..self.callbacks.count loop
      self.callbacks(i).set_id;
    end loop;
    --
    for i in 1..self.regions.count loop
      self.regions(i).set_id;
    end loop;
    --
    for i in 1..self.templates.count loop
      self.templates(i).set_id;
    end loop; 
    --
    if self.service is not null then
      self.service.set_id;
    end if;
    --
    if self.package.package is not null then
      self.package.set_id;
    end if;
    --
  end set_id;
  --
  member procedure put is
    pragma autonomous_transaction;
  begin
    --
    self.set_id;
    --
    xxdoo_bk_engine_pkg.put(self);
    --
    commit;
    --
  exception
    when others then
      rollback;
      xxdoo_utl_pkg.fix_exception;
      raise;
  end put;
  --
  member function get_role_num(p_name varchar2) return number is
    l_result number := null;
  begin
    --
    for r in 1..self.roles.count loop
      if self.roles(r).name = p_name then
        l_result := r;
        exit;
      end if;
    end loop;
    --
    return l_result;
    --
  end get_role_num;
  --
  member function get_page_num(p_name varchar2) return number is
    l_result number := null;
  begin
    --
    for r in 1..self.pages.count loop
      if self.pages(r).name = p_name then
        l_result := r;
        exit;
      end if;
    end loop;
    --
    return l_result;
    --
  end get_page_num;
  --
  member function get_template_num(p_template_name varchar2) return number is
    l_result number := null;
  begin
    --
    for r in 1..self.templates.count loop
      if self.templates(r).name = p_template_name then
        l_result := r;
        exit;
      end if;
    end loop;
    --
    return l_result;
    --
  end;
  --
  member procedure region(p_name varchar2, p_build_method xxdoo_bk_method_typ, p_html_method xxdoo_bk_method_typ default null) is
    rn number;
  begin
    rn := self.get_region_num(p_name);
    --
    if rn is null then
      self.regions.extend;
      rn := self.regions.count;
      self.regions(rn) := xxdoo_bk_region_typ(p_name);
    end if;
    --
    self.regions(rn).build(p_build_method, p_html_method);
    --
  end;
  --
  --
  --
  member procedure role(p_role xxdoo_bk_role_typ) is
    rn number;
    id number;
  begin
    rn := get_role_num(p_role.name);
    if rn is null then
      self.roles.extend;
      rn := self.roles.count;
    else
      id := self.roles(rn).id;
    end if;
    --
    self.roles(rn) := p_role;
    self.roles(rn).id := id;
    self.roles(rn).prepare_role;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member function role(self in out nocopy xxdoo_bk_book_typ, 
                       p_name             varchar2, 
                       p_method           xxdoo_bk_method_typ default null) return xxdoo_bk_role_typ is
    rn number := get_role_num(p_name);
  begin
    if rn is null then
      self.roles.extend;
      rn := self.roles.count;
      self.roles(rn) := xxdoo_bk_role_typ(p_name);
    end if;
    --
    self.roles(rn).set_method(p_method);
    --
    xxdoo.xxdoo_bk_engine_pkg.init_role_pages(p_name);
    --
    return self.roles(rn);
  end;
  --
  -- CALLBACKS
  --
  member function callback(self     in out nocopy xxdoo_bk_book_typ, 
                           p_callback_name varchar2,
                           p_method xxdoo_bk_method_typ) return varchar2 is
    l_callback_code varchar2(120);
    cn number;
  begin
    l_callback_code := upper(p_method.get_method_name);
    cn := self.get_callback_num(l_callback_code);
    --
    if cn is null then
      self.callbacks.extend;
      cn := self.callbacks.count;
      self.callbacks(cn) := xxdoo_bk_callback_typ(l_callback_code, p_callback_name);
    end if;
    --
    self.callbacks(cn).set_name(p_callback_name);
    self.callbacks(cn).set_method(p_method);
    --
    return self.callbacks(cn).id;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --  
  --
  member function callback(self     in out nocopy xxdoo_bk_book_typ, 
                           p_method xxdoo_bk_method_typ) return varchar2 is
  begin
    return self.callback(p_callback_name => null, p_method => p_method);
  end;
  --
  --
  --
  member function callback(self in out nocopy xxdoo_bk_book_typ, 
                           p_callback_name varchar2) return varchar2 is --, p_name varchar2 default null, p_package varchar2 default null, p_owner varchar2 default null) is
    cursor l_callback_cur(p_name varchar2) is
      select c.id
      from   table(self.callbacks) c
      where  c.id = p_name;
    l_result varchar2(32);
  begin
    --сначал ищем callback по имени
    open l_callback_cur(p_callback_name);
    fetch l_callback_cur into l_result;
    if l_callback_cur%notfound then
      close l_callback_cur;
      xxdoo_utl_pkg.fix_exception('callback '||p_callback_name||' not found');
      raise xxdoo_bk_core_pkg.g_exc_error;
    end if;
    close l_callback_cur;
    --
    return l_result;
  end;
  --
  --Функция ищет страницу по имени, если нет - создает ее
  --
  member function page(p_name varchar2) return xxdoo_bk_page_typ is
    pnum number;
  begin
    pnum := get_page_num(p_name);
    if pnum is null then
      xxdoo_utl_pkg.fix_exception('Page '||p_name||' not found.');
      raise no_data_found;
    end if;
    --
    return self.pages(pnum);
  exception
    when no_data_found then
      raise no_data_found;
    when others then
      xxdoo_utl_pkg.fix_exception('Page '||p_name||' error.');
      raise;
  end;
  --
  member procedure page(p_name        varchar2, 
                        p_html        xxdoo_html, 
                        p_entity_name varchar2 default null,
                        p_prepare     xxdoo_bk_method_typ default null) is
    pnum number;
  begin
    pnum := get_page_num(p_name);
    if pnum is null then
      self.pages.extend;
      pnum := self.pages.count;
      self.pages(pnum) := xxdoo_bk_page_typ(
                            p_name, 
                            case
                              when p_entity_name is null then
                                self.entity
                              else
                                xxdoo_bk_entity_typ(self.entity.scheme_id,p_entity_name)
                            end
                          );
    end if;
    --
    self.pages(pnum).build_html_method(p_html);
    if p_prepare is not null then
      self.pages(pnum).set_prepare_method(p_prepare);
    end if;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Book add page '||p_name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure home(p_name varchar2, p_html xxdoo_html, p_entity_name varchar2 default null) is
  begin
    self.page(p_name, p_html, p_entity_name);
  end;
  --
  --
  --
  member function role_page(p_page_name varchar2) return xxdoo_bk_role_page_typ is 
  begin
    return xxdoo_bk_role_page_typ(self.page(p_page_name));
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Book add page '||p_page_name||' error.');
      raise;
  end;          
  --
  member function get_service_url return varchar2 is
  begin
    return self.service.get_url;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member procedure cresource(p_name varchar2, p_value varchar2) is
    rnum number;
  begin
    if self.get_resource(p_name) is null then
      self.resources.extend;
      rnum := self.resources.count;
      self.resources(rnum) :=  xxdoo.xxdoo_bk_resource_typ(p_name);
    else
      for r in 1..self.resources.count loop
        if self.resources(r).name = p_name then
          rnum := r;
          exit;
        end if;
      end loop;
    end if;
    --
    self.resources(rnum).value := p_value;
  end;
  --
  member procedure create_layout(p_html xxdoo_html) is
    l_html xxdoo_html;
  begin
    --
    self.layout := 'Y';
    self.template('layout', p_html, 'book');
    --
  end create_layout;
  --
  --
  --
  member procedure create_toolbar(p_toolbar xxdoo_dsl_toolbar) is
    l_toolbar xxdoo_dsl_toolbar := p_toolbar;
  begin
    self.template('toolbar', l_toolbar.get_html);
  end;
  --
  --
  --
  member procedure template(p_name varchar2, p_html xxdoo_html, p_source_name varchar2 default null) is
    pnum number;
  begin
    pnum := get_template_num(p_name);
    if pnum is null then
      self.templates.extend;
      pnum := self.templates.count;
      self.templates(pnum) := xxdoo_bk_template_typ(
                            p_name, 
                            case
                              when p_source_name is null then
                                null
                              else
                                xxdoo_bk_entity_typ(self.entity.scheme_id,p_source_name)
                            end,
                            p_source_name
                          );
    end if;
    --
    self.templates(pnum).build(p_html, p_source_name);
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Book add template '||p_name||' error.');
      raise;
  end;
  --
  member procedure generate is
  begin
    xxdoo_bk_engine_pkg.generate_book(self);
  end;
  --
  member function fn(p_owner   varchar2,
                     p_package varchar2,
                     p_method  varchar2) return xxdoo_bk_method_typ is
  begin
    return xxdoo_bk_method_typ(
      p_owner   => p_owner,
      p_package => p_package,
      p_method  => p_method
    );
  end;
  --
  member function fn(p_method  varchar2) return xxdoo_bk_method_typ is
  begin
    return fn(p_owner   => self.package.owner,
              p_package => self.package.package,
              p_method  => p_method);
  end;
  --
  member function handler(self     in out nocopy xxdoo_bk_book_typ, 
                          p_method xxdoo_bk_method_typ) return varchar2 is
  begin
    return chr(0) || '#E#' || p_method.get_method_name;
  end handler;
  --
end;
/
