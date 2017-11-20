create or replace package body xxdoo_bk_core_pkg is
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
  type g_books_typ is table of xxdoo_bk_book_base_typ index by varchar2(60);
  g_books g_books_typ;
  type g_dao_list_typ is table of xxdoo_dao index by binary_integer;
  g_dao_list g_dao_list_typ;
  type g_templates_typ is table of xxdoo_bk_template_typ index by varchar2(220);
  g_templates g_templates_typ;
  type g_medium_uri_list_typ is table of varchar2(1024) index by varchar2(60);
  g_medium_uri_list g_medium_uri_list_typ;
  --
  g_package varchar2(60) := 'xxdoo_bk_core_pkg';
  --
  g_respond xxdoo_bk_service_raw_typ;
  --
  g_answer xxdoo_bk_answer_typ;
  --
  g_json clob;
  --
  -----------------------------------------------------------------------------------------------------------
  --Обвертки
  procedure fix_exception(p_description varchar2 default null) is
  begin
    xxdoo_utl_pkg.fix_exception(p_description => case
                                                   when p_description is not null then
                                                     g_package || '.' || p_description
                                                 end);
  end;
  --
  --
  --
  procedure plog(p_book_name varchar2,
                 p_query     varchar2 default null,
                 p_path      varchar2 default null,
                 p_inputs    clob,
                 p_meta      varchar2 default null) is
    pragma autonomous_transaction;
  begin
    insert into XXDOO_BK_LOGS_T(
      creation_date, 
      book_name,
      query    ,
      path     ,
      inputs   ,
      meta
    ) values(
      systimestamp,
      p_book_name,
      p_query    ,
      p_path     ,
      p_inputs   ,
      p_meta     
    );
    --
    commit;
  exception
    when others then
      rollback;
  end;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------------------------------------
  procedure page_error(p_result in out nocopy clob) is
    h xxdoo_html := xxdoo_html;
  begin
    h := h.h('html',
             h.h('head',
                 h.h('title','Error')
             ).
             h('body',
               h.h('div','Что-то пошло не так.'))
         );
    xxdoo_html_pkg.get_html(
      p_result,
      h.get_method
    );
  end page_error;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- Процедура добавляет книгу в g_books (предварительно удаляя оттуда...)
  -----------------------------------------------------------------------------------------------------------
  procedure push_book(p_book xxdoo_bk_book_base_typ) is
  begin
    g_books.delete(p_book.name);
    g_books(p_book.name) := p_book;
  end;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- Функция ищет книгу в g_books по p_name, если находит и версия книги не изменилась - возвращает ее. Иначе - null
  -----------------------------------------------------------------------------------------------------------
  function get_book(p_name varchar2) return xxdoo_bk_book_base_typ is
  begin
    --return null;
    if g_books.exists(p_name) then
      if g_books(p_name).check_version = true then
        return g_books(p_name);
      end if;
    end if;
    --
    push_book(xxdoo_bk_book_base_typ(p_name));
    return g_books(p_name);
    --
  end;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- Процедура добавляет объект DAO в g_dao_list (предварительно удаляя оттуда...)
  -----------------------------------------------------------------------------------------------------------
  procedure push_dao(p_dao xxdoo_dao) is
  begin
    --null; --ZHURAVOV_15
    g_dao_list.delete(p_dao.table_id);
    g_dao_list(p_dao.table_id) := p_dao;
  end push_dao;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- Функция ищет DAO в g_dao_list по p_entity_id
  -----------------------------------------------------------------------------------------------------------
  function get_dao(p_entity_id number) return xxdoo_dao is
  begin
    --return null;
    if not g_dao_list.exists(p_entity_id) then
      null;--ZHURAVOV_15 
      push_dao(xxdoo_dao(p_entity_id));
    else
      null;--ZHURAVOV_15 g_dao_list(p_entity_id).update_version;
    end if;
    --
    return g_dao_list(p_entity_id);
    --
  end;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- Процедура добавляет шаблон html в g_templates (предварительно удаляя оттуда...)
  -----------------------------------------------------------------------------------------------------------
  procedure push_template(p_template_name varchar2, p_template xxdoo_bk_template_typ) is
  begin
    g_templates.delete(p_template_name);
    g_templates(p_template_name) := p_template;
  end push_template;
  -----------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------------------------------------
  function get_template(p_book_id number, p_template_name varchar2) return xxdoo_bk_template_typ is
    l_name varchar2(220) := to_char(p_book_id) || '.' || p_template_name;
  begin
    if not g_templates.exists(l_name) or not g_templates(l_name).check_version then
      push_template(l_name,xxdoo_bk_template_typ(p_book_id,p_template_name));
    end if;
    --
    return g_templates(l_name);
    --
  end get_template;
  --
  --
  --
  procedure set_json(p_json clob) is 
  begin
    g_json := p_json;
  end;
  --
  --
  --
  function get_json return clob is
  begin
    return g_json;
  end;
  --
  --
  --
  function get_medium_uri(p_book_name varchar2) return varchar2 
    result_cache relies_on(xxdoo_bk_services_t) is
    --
    l_result varchar2(1024);
    --
  begin
    --
    select '/' || regexp_substr(s.url,'[^/]+',1,3) || 
           '/' || sys_context('USERENV', 'DB_NAME') || 
           '/' || regexp_substr(s.url,'[^/]+',1,5) || '/' medium_uri
    into   l_result
    from   xxdoo_bk_books_t    b,
           xxdoo_bk_services_t s
    where  1=1
    and    s.id = b.service
    and    b.name = p_book_name;
    --
    return l_result;
    --
  end;
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------
  -- NEW REQUEST
  ---------------------------------------------------------------------------------------
  function request(p_book_name varchar2,
                   p_query     varchar2,
                   p_path      varchar2,
                   p_inputs    clob,
                   p_meta      varchar2) return xxdoo_bk_service_raw_typ is
    --
  begin
    --
    xxdoo_utl_pkg.init_exceptions;
    --
    plog(p_book_name => p_book_name,
         p_query     => p_query ,
         p_path      => p_path  ,
         p_inputs    => p_inputs,
         p_meta      => p_meta  
    );   
    --
    g_answer := xxdoo_bk_answer_typ(
      p_book_name,
      p_query    ,
      p_path     ,
      p_inputs   ,
      p_meta     
    );
    --
    g_answer.authenticate;
    g_answer.define_role;
    g_answer.define_params;
    g_answer.define_entries;
    --
    g_answer.role_prepare;
    --
    g_answer.execute_callbacks;
    --
    g_answer.refresh_regions;
    --
    g_answer.create_result(g_respond);
    --
    plog(p_book_name => p_book_name,
         p_path      => 'Result'     ,
         p_inputs    => g_respond.clob_value);
    return g_respond;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      --
      if length(g_respond.clob_value) = 0 or g_respond.clob_value is null then
        page_error(g_respond.clob_value);
      end if;
      --
      execute immediate 'begin 
      xxapps.xxapps_alert_pkg.trap(
        ''XXDOO'',
        ''XXDOO_BK'',
        ''Alert'',
        :1,
        -1); end;' using xxdoo.xxdoo_utl_pkg.get_full_exception;
                                 
      --
      return g_respond;
  end request;
  --
  --
  --
  function request(p_book_name      varchar2,
                   p_request_body   clob,
                   p_request_params sys.odcivarchar2list) return xxdoo_bk_service_raw_typ is
    --
    l_key_list sys.odcivarchar2list;
    --
    procedure create_key_list is
    begin
      l_key_list := sys.odcivarchar2list();
      l_key_list.extend(3);
      l_key_list(1) := 'path';
      l_key_list(2) := 'inputs';
      l_key_list(3) := 'meta';
      return;
    end;
    --
    procedure parse_body is
    begin
      create_key_list;
      --
      l_key_list := 
        xxdoo.xxdoo_json_pkg.parse_json_on_key(
          p_json     => p_request_body,
          p_key_list => l_key_list
        );
    end;
  begin
    --
    parse_body;
    --
    return
      request(
        p_book_name => p_book_name,
        p_query     => l_key_list(1),
        p_path      => p_request_params(2),
        p_inputs    => l_key_list(2),
        p_meta      => l_key_list(3)
      );
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      --
      if length(g_respond.clob_value) = 0 or g_respond.clob_value is null then
        page_error(g_respond.clob_value);
      end if;
      --
      execute immediate 'begin 
      xxapps.xxapps_alert_pkg.trap(
        ''XXDOO'',
        ''XXDOO_BK'',
        ''Alert'',
        :1,
        -1); end;' using xxdoo.xxdoo_utl_pkg.get_full_exception;
                                 
      --
      return g_respond;
  end;
  --
  --
  --
  procedure respond_init is
  begin
    --
    g_respond           := xxdoo_bk_service_raw_typ(null, null, null, null, null, null);
    g_respond.is_blob   := 'N';
    g_respond.is_error  := 'N';
    g_respond.mime_type := 'text/html';
    --
  end respond_init;
  --
begin
  --
  respond_init;
  --
end xxdoo_bk_core_pkg;
/
