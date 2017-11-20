create or replace package body xxdoo_bk_engine_pkg is
  -----------------------------------------------------------------------------------------------------------
  -- Разработка xxdoo_bk. Управление органайзерами
  --   Публикация: 
  --
  --  
  --
  -- MODIFICATION HISTORY
  -- Person         Date         Comments
  -- ---------      ------       ------------------------------------------
  -- Журавов В.Б.   15.08.2014   Создание
  -----------------------------------------------------------------------------------------------------------
  --
  
  --
  --g_scheme xxdoo_db_scheme;
  g_methods g_methods_typ;
  g_service_owner   constant varchar2(32) := 'xxdoo_ee';
  --
  type g_page_list_typ is table of number index by varchar2(240);
  type g_role_page_typ is table of g_page_list_typ index by varchar2(240);
  type g_role_list_typ is table of number index by varchar2(240);
  --
  g_role_page g_role_page_typ;
  g_role_list g_role_list_typ;
  --
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------------------------------------
  function get_methods return g_methods_typ pipelined is
  begin
    for i in 1..g_methods.count loop
      pipe row (g_methods(i));
    end loop;
  end;
  --
  --
  --
  procedure init_role_pages(p_role_name varchar2) is
  begin
    g_role_page.delete(p_role_name);
    g_role_list(p_role_name) := 1;
    
  end;
  --
  --
  --
  function get_role_page_position(p_role_name varchar2, p_page_name varchar2) return number is
    l_result number;
  begin
    --
    if not g_role_page.exists(p_role_name) or not g_role_page(p_role_name).exists(p_page_name) then
      g_role_page(p_role_name)(p_page_name) := g_role_list(p_role_name);
      g_role_list(p_role_name) := g_role_list(p_role_name) + 1;
    end if;
    --
    return g_role_page(p_role_name)(p_page_name);
    --
  end;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- Процедура сохранения книги
  -----------------------------------------------------------------------------------------------------------
  procedure put(p_book in out nocopy xxdoo_bk_book_typ) is
    --pragma autonomous_transaction;
    p_objects xxdoo_bk_books_typ := xxdoo_bk_books_typ();
  begin
    --
    p_book.set_id;
    
    --
    
    --
    p_objects.extend;
    p_objects(1) := p_book;
    --
    --g_methods(1).id := 1;
    open g_methods_cur(p_book);
    fetch g_methods_cur 
      bulk collect into g_methods;
    close g_methods_cur;
    --
    merge into xxdoo_bk_methods_t m
    using (select m.id,
                  p_book.id book_id,
                  m.name,
                  m.spc,
                  m.body,
                  m.owner,
                  m.package
           from   table(xxdoo_bk_engine_pkg.get_methods) m
           where  m.id is not null
          ) u
    on    (m.id = u.id)
    when matched then
      update set 
        m.book_id = u.book_id,
        m.name = u.name,
        m.spc  = u.spc,
        m.body = u.body,
        m.owner = u.owner,
        m.package = u.package,
        m.version = m.version + 1
    when not matched then
      insert(id, book_id, version, name, spc, body, owner, package)
      values (u.id, u.book_id, 1, u.name,u.spc,u.body, u.owner, u.package);
    --
    merge into xxdoo_bk_services_t l
    using (select p_book.service.id id,
                  p_book.service.name name,
                  p_book.service.namespace namespace,
                  p_book.service.method.id method_id,
                  p_book.service.url url,
                  p_book.service.is_default is_default
           from   dual
           where  p_book.service.id is not null
          ) u
    on    (l.id = u.id)
    when matched then
      update set
        l.name = u.name,
        l.url = u.url,
        l.method_id = u.method_id,
        l.namespace = u.namespace,
        l.is_default = u.is_default
    when not matched then
      insert (id,name,namespace,url,method_id,is_default)
      values(u.id,u.name,u.namespace,u.url,u.method_id,u.is_default);
    --
    merge into xxdoo.xxdoo_bk_books_t m
    using (select t1.id id,
                  t1.name name,
                  t1.owner owner,
                  t1.dev_code dev_code,
                  t1.title title,
                  t1.search search, 
                  t1.service.id service,
                  t1.state state,
                  t1.entity.entity_id entity_id,
                  t1.package.id package_id,
                  t1.path
            from  table(p_objects) t1) u
    on    (m.id = u.id)
    when matched then
      update set
        m.name = u.name,
        m.owner = u.owner,
        m.dev_code = u.dev_code,
        m.title = u.title,
        m.search = u.search,
        m.service = u.service,
        m.state = u.state,
        m.entity_id = u.entity_id,
        m.package_id = u.package_id,
        m.path = u.path,
        m.version = nvl(m.version,0) + 1
    when not matched then
        insert(
          id,
          name,
          owner,
          dev_code,
          title,
          search,
          service,
          state,
          entity_id,
          package_id,
          path,
          version
        )
        values(
          u.id,
          u.name,
          u.owner,
          u.dev_code,
          u.title,
          u.search,
          u.service,
          u.state,
          u.entity_id,
          u.package_id,
          u.path,
          1
        );
    --
    merge into xxdoo.xxdoo_bk_roles_t m
    using (select t3.id id,
                  t1.id book_id,
                  t3.name name,
                  t3.method.id method_id
            from  table(p_objects) t1,
                  table(t1.roles) t3) u
    on    (m.id = u.id)
    when matched then
      update set
        m.book_id = u.book_id,
        m.name = u.name,
        m.method_id = u.method_id
    when not matched then
        insert(
          id,
          book_id,
          name,
          method_id
        )
        values(
          u.id,
          u.book_id,
          u.name,
          u.method_id
        );
    --
    delete from xxdoo.xxdoo_bk_roles_t t
    where  1=1
    and    t.book_id in (
          select t1.id
          from  table(p_objects) t1
          )
    and    t.id not in (
          select t3.id
          from  table(p_objects) t1,
                table(t1.roles) t3
          );
    --
    merge into xxdoo.xxdoo_bk_role_params_t rp
    using (select t3.id role_id,
                  l.key key,
                  l.value value
            from  table(p_objects) t1,
                  table(t1.roles)  t3,
                  table(t3.parameters.list) l) u
    on    (rp.role_id = u.role_id and rp.key = u.key)
    when matched then
      update set
        rp.value = u.value
    when not matched then
        insert(
          role_id,
          key,
          value
        )
        values(
          u.role_id,
          u.key,
          u.value
        );
    --
    delete from xxdoo.xxdoo_bk_role_params_t t
    where  1=1
    and    t.role_id in (
          select  t3.id role_id
            from  table(p_objects) t1,
                  table(t1.roles)  t3
          )
    and    t.key not in (
          select l.key key
            from  table(p_objects) t1,
                  table(t1.roles)  t3,
                  table(t3.parameters.list) l
          );
    
    --
    merge into xxdoo.xxdoo_bk_pages_t m
    using (select t4.id id,
                  t1.id book_id,
                  t4.name name,
                  t4.content_method.id content_method_id,
                  t4.entity.entity_id entity_id,
                  t4.prepare_method.id prepare_method_id
            from  table(p_objects) t1,
                  table(t1.pages) t4) u
    on    (m.id = u.id)
    when matched then
      update set
        m.book_id = u.book_id,
        m.name = u.name,
        m.content_method_id = u.content_method_id,
        m.entity_id = u.entity_id,
        m.prepare_method_id = u.prepare_method_id
    when not matched then
        insert(
          id,
          book_id,
          name,
          content_method_id,
          entity_id,
          prepare_method_id
        )
        values(
          u.id,
          u.book_id,
          u.name,
          u.content_method_id,
          u.entity_id,
          u.prepare_method_id
        );
    --
    delete from xxdoo.xxdoo_bk_pages_t t
    where  1=1
    and    t.book_id in (
          select t1.id
          from  table(p_objects) t1
          )
    and    t.id not in (
          select t4.id
          from  table(p_objects) t1,
                table(t1.pages) t4
          );
    --
    merge into xxdoo.xxdoo_bk_role_pages_t m
    using (select t7.id id,
                  t6.id role_id,
                  p.id  page_id,
                  t7.condition_method.id condition_method_id,
                  t7.order_num
            from  table(p_objects) t1,
                  table(t1.roles) t6,
                  table(t6.pages) t7,
                  table(p_objects) o,
                  table(o.pages)   p
            where 1=1
            and   p.name = t7.page.name) u
    on    (m.id = u.id)
    when matched then
      update set
        m.role_id = u.role_id,
        m.page_id = u.page_id,
        m.condition_method_id = u.condition_method_id,
        m.order_num = u.order_num
    when not matched then
        insert(
          id,
          role_id,
          page_id,
          condition_method_id,
          order_num
        )
        values(
          u.id,
          u.role_id,
          u.page_id,
          u.condition_method_id,
          u.order_num
        );
    --
    delete from xxdoo.xxdoo_bk_role_pages_t t
    where  1=1
    and    t.role_id in (
          select t6.id
          from  table(p_objects) t1,
                table(t1.roles) t6
          )
    and    t.id not in (
          select t7.id
          from  table(p_objects) t1,
                table(t1.roles) t6,
                table(t6.pages) t7
          );
    --
    merge into xxdoo.xxdoo_bk_callbacks_t m
    using (select t10.id           id,
                  t1.id            book_id,
                  t10.method.id    method_id
            from  table(p_objects) t1,
                  table(t1.callbacks) t10) u
    on    (m.id = u.id)
    when matched then
      update set
        m.book_id   = u.book_id,
        m.method_id = u.method_id
    when not matched then
        insert(
          id,
          book_id,
          method_id
        )
        values(
          u.id,
          u.book_id,
          u.method_id
        );
    --
    delete from xxdoo.xxdoo_bk_callbacks_t t
    where  1=1
    and    t.book_id in (
          select t1.id
          from  table(p_objects) t1
          )
    and    t.id not in (
          select t10.id
          from  table(p_objects) t1,
                table(t1.callbacks) t10
          );
    --
    merge into xxdoo.xxdoo_bk_resources_t m
    using (select r.id,
                  o.id book_id,
                  r.name,
                  r.value
            from  table(p_objects) o,
                  table(o.resources) r) u
    on    (m.id = u.id)
    when matched then
      update set
        m.book_id = u.book_id,
        m.name = u.name,
        m.value = u.value
    when not matched then
        insert(
          id,
          book_id,
          name,
          value
        )
        values(
          u.id,
          u.book_id,
          u.name,
          u.value
        );
    --
    delete from xxdoo.xxdoo_bk_resources_t t
    where  1=1
    and    t.book_id in (
          select o.id
          from  table(p_objects) o
          )
    and    t.id not in (
          select r.id
          from  table(p_objects) o,
                table(o.resources) r
          );
    --
    --REGIONS
    --
    merge into xxdoo.xxdoo_bk_regions_t m
    using (select r.id,
                  o.id book_id,
                  r.name,
                  r.build_method.id build_method_id,
                  r.html_method.id html_method_id
            from  table(p_objects) o,
                  table(o.regions) r) u
    on    (m.id = u.id)
    when matched then
      update set
        m.book_id = u.book_id,
        m.name = u.name,
        m.build_method_id = u.build_method_id,
        m.html_method_id = u.html_method_id
    when not matched then
        insert(
          id,
          book_id,
          name,
          build_method_id,
          html_method_id
        )
        values(
          u.id,
          u.book_id,
          u.name,
          u.build_method_id,
          u.html_method_id
        );
    --
    delete from xxdoo.xxdoo_bk_regions_t t
    where  1=1
    and    t.book_id in (
          select o.id
          from  table(p_objects) o
          )
    and    t.id not in (
          select r.id
          from  table(p_objects) o,
                table(o.regions) r
          );
    --
    --REGIONS
    --
    merge into xxdoo.xxdoo_bk_templates_t m
    using (select t.id               id,
                  p_book.id          book_id,
                  t.name             name,
                  t.entity.entity_id entity_id,
                  t.method.id        method_id,
                  t.source_name      source_name
            from  table(p_book.templates) t
          ) u
    on    (m.id = u.id)
    when matched then
      update set
        m.book_id = u.book_id,
        m.name = u.name,
        m.entity_id = u.entity_id,
        m.method_id = u.method_id,
        m.source    = u.source_name
    when not matched then
        insert(
          id,
          book_id,
          name,
          entity_id,
          method_id,
          source
        )
        values(
          u.id,
          u.book_id,
          u.name,
          u.entity_id,
          u.method_id,
          u.source_name
        );
    --
    delete from xxdoo.xxdoo_bk_templates_t t
    where  1=1
    and    t.book_id = p_book.id
    and    t.id not in (
          select t.id
          from  table(p_book.templates) t
          );
    --
    delete from xxdoo_bk_methods_t m
    where  1=1
    and    m.id not in (select mm.id
                        from   table(xxdoo_bk_engine_pkg.get_methods) mm
                        where  mm.id is not null)
    and    m.book_id = p_book.id;
    --
    --
    --commit;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      --rollback;
      raise;
  end put;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------------------------------------
  function get_entity_id(p_scheme varchar2, p_entry varchar2) return number is
    l_result number;
  begin
    select e.id
    into   l_result
    from   xxdoo_db_schemes_t s,
           xxdoo_db_tables_t e
    where  1=1
    and    e.entry_name = p_entry
    and    e.scheme_id = s.id
    and    s.name = p_scheme;
    --
    return l_result;
  exception
    when no_data_found then
      xxdoo_utl_pkg.fix_exception('Entry '||p_entry||' not found in scheme '||p_scheme);
      raise;
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end get_entity_id;
  --
  --
  --
  procedure default_regions(p_book in out nocopy xxdoo_bk_book_typ) is
    --
    procedure add_region(p_name varchar2) is
    begin
      if not p_book.region_exists(p_name) then
        p_book.region(p_name, xxdoo_bk_method_typ('xxdoo', 'xxdoo_bk_regions_pkg', 'get_'||p_name));
      end if;
    end;
    --
  begin
    --
    add_region('content');
    add_region('toolbar');
    add_region('sidebar');
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------------------------------------
  procedure default_layout(p_book in out nocopy xxdoo_bk_book_typ) is
    --
    h xxdoo.xxdoo_html := xxdoo.xxdoo_html();
    b xxdoo.xxdoo_html := xxdoo.xxdoo_html();
    --
  begin
    --
    h := h.h('head',
           h.h('meta',h.attr('apple-mobile-web-app-capable','yes')).
             h('meta',h.attr('apple-mobile-web-app-status-bar-style','black')).
             h('meta',h.attr('viewport','width=device-width, initial-scale=1.0, user-scalable=no')).
             h('meta',h.attrs(http_equiv => 'X-UA-Compatible', content => 'IE=edge,chrome=1', charset => 'utf-8')).
             h('title',h.G('title')).
             h('link',h.attrs(href => h.G('get_css_link'), rel => 'stylesheet'))
    );
    --
    b := b.h('body',b.attr('data-book',b.G('name')),
           b.h('div.wrapper',
             b.h('header.header',
               b.h('div#toolbar.buttons', b.G('get_toolbar')).
               h('div.search',
                 b.h('input', b.attrs(type => 'text', name => 'query', value => b.G('search')))
               )
             ).
             h('div.sidebar',b.G('get_sidebar')
             ).
             h('div#content.content',b.G('get_content'))
           ).
           h('script',b.attr('src',b.G('get_js_link')))
    );
    --
    p_book.create_layout(
      h.h('html',
          h.h(h).
            h(b)
         ));
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end default_layout;
  
  
  /*-----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- Обработка ролей
  -----------------------------------------------------------------------------------------------------------
  procedure process_roles(p_book in out nocopy xxdoo_bk_book_typ) is
    --
    cursor l_page_cur(p_page_name varchar2) is
      select value(p)
      from   table(p_book.pages) p
      where  p.name = p_page_name;
    --
    
    --
  begin
    --
    for r in 1..p_book.roles.count loop
      --
      for p in 1..p_book.roles(r).pages.count loop
        --
        null;
        --
      end loop;
      --
    end loop;
    --
    return;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end process_roles;*/
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- Сборка пакета 
  -----------------------------------------------------------------------------------------------------------
  procedure default_service(p_book in out nocopy xxdoo_bk_book_typ) is
    s xxdoo_db_text;
    b xxdoo_db_text;
    l_fn_spc varchar2(1024);
    l_fn_proxy varchar2(1024);
    l_pkg_name varchar2(1024);
    l_method   xxdoo_bk_method_typ;
    l_owner    varchar2(32) := g_service_owner;
    --
    procedure compile(p_text varchar2, p_object_type varchar2 default null) is
    begin
      execute immediate 'begin xxdoo_ee.xxdoo_bk_ee_gateway_pkg.create_db_object(:p_text); end;' using p_text;--execute immediate p_text;
      /*ZHURAVOV_15 объект XXDOO_EE не доступен! 
      if p_object_type is not null then
        if xxdoo_utl_pkg.get_status_obj(p_object_type,p_book.service.method.owner,p_book.service.method.package) <> 'VALID' then
          raise xxdoo_bk_core_pkg.g_exc_error;
        end if;
      end if;*/
    exception
      when others then
        xxdoo_utl_pkg.fix_exception('Error compile package '||chr(10)||p_text);
        raise;
    end;
  begin
    --
    l_fn_spc := 'function '||lower(p_book.name)||'("path" varchar2, "inputs" clob, "meta" clob) return xxapps.xxapps_service_raw_block';
    l_fn_proxy := 'function '||lower(p_book.name)||'_proxy(request_body clob, request_params sys.odciVarchar2List) return xxapps.xxapps_service_raw_block';
    l_pkg_name := lower(p_book.dev_code || '_gateway_pkg');
    --
    begin
      if p_book.service.method is not null 
         and xxdoo_utl_pkg.get_status_obj('PACKAGE',l_owner,l_pkg_name) = 'VALID' 
         and xxdoo_utl_pkg.get_status_obj('PACKAGE BODY',l_owner,l_pkg_name) = 'VALID' then
         --return;
         null;
      end if;
    exception
      when others then
        null;
    end;
    --
    s := xxdoo_db_text();
    b := xxdoo_db_text();
    --
    s.append('create or replace package '||l_owner || '.' || l_pkg_name||' is');
    s.inc;
    s.append(l_fn_spc||';');
    s.append(l_fn_proxy||';');
    s.dec;
    s.append('end '||p_book.package.name||';');
    --
    b.append('create or replace package body '||l_owner || '.' || l_pkg_name||' is');
    b.inc;
    b.append(l_fn_spc||' is');
    b.append('begin');
    b.inc;
    b.append('return xxdoo_ee.xxdoo_bk_ee_gateway_pkg."request"("book_name" => '''||p_book.name||''', "path" => "path", "inputs" => "inputs", "meta" => "meta");');
    b.dec;
    b.append('end '||lower(p_book.name)||';');
    b.append('--');
    b.append(l_fn_proxy||' is');
    b.append('begin');
    b.inc;
    b.append('return xxdoo_ee.xxdoo_bk_ee_gateway_pkg."request"("book_name" => '''||p_book.name||''', "request_body" => request_body, "request_params" => request_params);');
    b.dec;
    b.append('end '||lower(p_book.name)||'_proxy;');
    b.dec;
    b.append('end '||p_book.package.name||';');
    --
    l_method := xxdoo_bk_method_typ(p_owner   => l_owner,
                                    p_package => l_pkg_name, 
                                    p_method  => lower(p_book.name));
    l_method.set_text(p_spc => s.get_text, p_body => b.get_text);
    --
    p_book.service.set_method(l_method);
    --
    compile(p_book.service.method.spc,'PACKAGE');
    compile(p_book.service.method.body,'PACKAGE BODY');
    --
    compile('grant execute on '||l_owner||'.'||p_book.service.method.package||' to xxportal,xxapps');
    compile('grant execute,debug on '||l_owner||'.'||p_book.service.method.package||' to apps with grant option');
    --
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end default_service;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------------------------------------
  procedure generate_book(p_book in out nocopy xxdoo_bk_book_typ) is
  begin
    --
    if nvl(p_book.service.is_default,'Y') = 'Y' then
      default_service(p_book);
    end if;
    --
    p_book.service.export;
    --
    default_regions(p_book);
    --
    if nvl(p_book.layout,'N') <> 'Y' then
      default_layout(p_book);
    end if;
    --
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end generate_book;
  --
end xxdoo_bk_engine_pkg;
/
