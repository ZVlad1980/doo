declare
  --
  g_owner varchar2(15) := 'xxdoo';
  --
  procedure plog(p_msg in varchar2, p_eof in boolean default true) is
  begin
    if p_eof = true then
      dbms_output.put_line(p_msg);
    else
      dbms_output.put(p_msg);
    end if;
  end;
  --
  procedure ei(p_body  in varchar2 default null) is
    l_object_exists_exc exception;
    pragma exception_init(l_object_exists_exc, -955);
    l_element_exists_exc exception;
    pragma exception_init(l_element_exists_exc, -1430);
    l_element_not_exists_exc exception;
    pragma exception_init(l_element_not_exists_exc, -942);
    l_element_exists2_exc exception;
    pragma exception_init(l_element_exists2_exc, -1442);
    l_element_exists3_exc exception; --дубирование элементов в типе
    pragma exception_init(l_element_exists3_exc, -22324);
    l_element_exists4_exc exception; --дубирование элементов в типе
    pragma exception_init(l_element_exists4_exc, -1430);
    --
  begin
    --plog(p_operation||' '||p_type||' '||p_name||' ... ');
    execute immediate p_body;
    --plog('Ok',true);
  exception
    when l_object_exists_exc or l_element_exists_exc or l_element_exists2_exc or l_element_exists3_exc or l_element_exists4_exc then
      null;--nplog('exist',true);
    when l_element_not_exists_exc then
      null;--plog('not exist',true);
    when others then
      plog('error: '||sqlerrm);
      plog(p_body);
      raise;
  end;
  --
begin
  dbms_output.enable(100000); 
  ei(p_body => 
'create type xxdoo.xxdoo_bk_service_raw_typ as object (
  clob_value  clob,
  blob_value  blob,
  is_blob     char(1),
  file_name   varchar2(1024),
  mime_type   varchar2(1024),
  is_error    char(1)
)
'
  ); 
  --
  --
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_method_typ as object (
  id number
, version integer
, name varchar2(120)
, owner varchar2(32)
, package varchar2(32)
, spc  varchar2(4000)
, body clob
--
, member function get_method_name return varchar2
, constructor function xxdoo_bk_method_typ(p_name varchar2) return self as result
, constructor function xxdoo_bk_method_typ(p_owner varchar2, p_package varchar2, p_method varchar2) return self as result
, member procedure set_id
, member function check_version return boolean
, member procedure set_package(p_owner varchar2, p_package varchar2)
, member procedure set_text(p_spc varchar2, p_body clob)
, member procedure set_text(p_body clob)
, member procedure build(p_html xxdoo_html)
, member function get_body return clob
)
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_methods_typ is table of xxdoo.xxdoo_bk_method_typ
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_service_typ as object (
  id number
, name varchar2(20)
, namespace varchar2(400)
, method xxdoo.xxdoo_bk_method_typ
, url varchar2(400)
, is_default varchar2(1)
, member procedure set_id
, constructor function xxdoo_bk_service_typ(p_service_name varchar2, p_namespace varchar2 default null) return self as result
, member procedure set_method(p_method xxdoo_bk_method_typ)
, member procedure export
, member function get_url return varchar2
)
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_services_typ is table of xxdoo.xxdoo_bk_service_typ
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_callback_typ as object (
  id varchar2(32)
, book_id number
, code varchar2(200)
, method xxdoo.xxdoo_bk_method_typ
, constructor function xxdoo_bk_callback_typ(p_callback_code varchar2, p_callback_name varchar2) return self as result
, member procedure set_name(p_name varchar2)
, member procedure set_method(p_method xxdoo_bk_method_typ)
, member procedure set_id
)
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_callbacks_typ is table of xxdoo.xxdoo_bk_callback_typ
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_entity_typ as object (
  entity_id     number,
  scheme_id     number,
  scheme_name   varchar2(32),
  dev_code      varchar2(15),
  owner         varchar2(30),
  entity_name   varchar2(32),
  entry_name    varchar2(32),
  object_name   varchar2(32),
  collect_name  varchar2(32),
  table_name    varchar2(32),
  view_name     varchar2(32),
  sequence_name varchar2(32),
  pk_field      varchar2(32),
  pk_type       varchar2(32),
  constructor function xxdoo_bk_entity_typ return self as result,
  constructor function xxdoo_bk_entity_typ(p_entity_id number) return self as result,
  constructor function xxdoo_bk_entity_typ(p_scheme_id number, p_source_name varchar2) return self as result,
  constructor function xxdoo_bk_entity_typ(p_scheme_name varchar2, p_source_name varchar2) return self as result
)');
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_page_typ as object (
  id number
, book_id number
, name varchar2(45)
, content_method xxdoo.xxdoo_bk_method_typ
, entity xxdoo_bk_entity_typ
, prepare_method xxdoo_bk_method_typ
--
, constructor function xxdoo_bk_page_typ return self as result
, member procedure set_id
, constructor function xxdoo_bk_page_typ(p_name varchar2, p_entity xxdoo_bk_entity_typ default null) return self as result
, member procedure build_html_method(p_html xxdoo_html)            
, member procedure set_prepare_method(p_method xxdoo_bk_method_typ)
)
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_pages_typ is table of xxdoo.xxdoo_bk_page_typ
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_role_page_typ as object (
  id number
, role_id number
, page xxdoo.xxdoo_bk_page_typ
, is_show varchar2(1)
, order_num number
, filters xxdoo_bk_methods_typ
, condition_method xxdoo_bk_method_typ
, save varchar2(1)
--
, constructor function xxdoo_bk_role_page_typ return self as result
, constructor function xxdoo_bk_role_page_typ(p_page xxdoo_bk_page_typ) return self as result
, member procedure set_id
, member procedure set_page(p_page xxdoo_bk_page_typ)
, member function get_filter_num(p_method_name varchar2) return number
, member procedure is_when(p_method  xxdoo_bk_method_typ)
, member procedure build_condition_method
)');
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_role_pages_typ is table of xxdoo.xxdoo_bk_role_page_typ
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_role_typ as object (
  id          number
, book_id     number
, name        varchar2(45)
, method      xxdoo.xxdoo_bk_method_typ
, pages       xxdoo.xxdoo_bk_role_pages_typ
, parameters  xxdoo_db_list
--
, current_role_page number
--
, constructor function xxdoo_bk_role_typ return self as result
, constructor function xxdoo_bk_role_typ(p_name varchar2) return self as result
, constructor function xxdoo_bk_role_typ(p_book_name varchar2, p_role_name varchar2) return self as result
, member procedure set_id
, member procedure set_method(p_method xxdoo_bk_method_typ)
, member function get_role_page_num(p_page_name varchar2) return number
, member procedure page(p_page xxdoo_bk_page_typ)
, member function page(p_page xxdoo_bk_page_typ) return xxdoo_bk_role_typ
, member procedure is_when(p_method xxdoo_bk_method_typ)
, member function is_when(p_method xxdoo_bk_method_typ) return xxdoo_bk_role_typ
, member procedure is_when(p_method xxdoo_bk_method_typ, p_pages xxdoo_bk_pages_typ)
, member procedure prepare_role
, member procedure set_par(p_key varchar2, p_value varchar2)
, member procedure set_par(p_key varchar2, p_value number)
, member procedure set_par(p_key varchar2, p_value date)
, member procedure set_par(p_key varchar2, p_value anydata)
, member function get(p_key varchar2) return varchar2
, member function get_number(p_key varchar2) return number
, member function get_date(p_key varchar2) return date
, member function get_anydata(p_key varchar2) return anydata
)');
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_roles_typ is table of xxdoo.xxdoo_bk_role_typ
'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_resource_typ as object (
  id number
, book_id number
, name varchar2(45)
, value varchar2(400)
, constructor function xxdoo_bk_resource_typ return self as result
, constructor function xxdoo_bk_resource_typ(p_name varchar2) return self as result
--procedure assignment sequence numbers
, member procedure set_id
)');
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_resources_typ is table of xxdoo.xxdoo_bk_resource_typ');
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_region_typ as object (
  id number
, book_id number
, name varchar2(45)
, build_method xxdoo_bk_method_typ --create html_method. If emtpy - call default method for name (content, toolbar, sidebar)
, html_method xxdoo_bk_method_typ --method returning html
, html clob
, refresh varchar2(1)
, constructor function xxdoo_bk_region_typ return self as result
--procedure assignment sequence numbers
, member procedure set_id
, constructor function xxdoo_bk_region_typ(p_name varchar2) return self as result
, member procedure build(p_build_method xxdoo_bk_method_typ, p_html_method xxdoo_bk_method_typ)
)');
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_regions_typ is table of xxdoo.xxdoo_bk_region_typ');
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_template_typ as object (
  id        number
, book_id   number
, name      varchar2(200)
, entity    xxdoo_bk_entity_typ
, method    xxdoo_bk_method_typ
, source_name varchar2(100)
, constructor function xxdoo_bk_template_typ return self as result
, member procedure set_id
, constructor function xxdoo_bk_template_typ(p_name varchar2, p_entity xxdoo_bk_entity_typ default null, p_source varchar2) return self as result
, constructor function xxdoo_bk_template_typ(p_book_id number, p_name varchar2) return self as result
, member procedure build(p_html xxdoo_html, p_source_name varchar2)
, member function content(p_context in out nocopy xxdoo_html_context, p_object anydata) return clob
, member function check_version return boolean
)');
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_templates_typ is table of xxdoo.xxdoo_bk_template_typ'
  );
  --
  -- BOOK base
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_book_base_typ as object (
  id number
, name varchar2(15)
, owner varchar2(15)
, dev_code varchar2(10)
, title varchar2(200)
, search varchar2(200)
, regions xxdoo_bk_regions_typ
, callbacks xxdoo_bk_callbacks_typ
, resources xxdoo_bk_resources_typ
, entity    xxdoo_bk_entity_typ
, path varchar2(1024)
, version number
, templates xxdoo_bk_templates_typ
, path_parser xxdoo_p2r_parser
--
, constructor function xxdoo_bk_book_base_typ(p_name varchar2) return self as result
, constructor function xxdoo_bk_book_base_typ return self as result
, member function check_version return boolean
, member function get_region_num(p_region_name varchar2) return number
, member function get_region_html(p_region_name varchar2) return clob
, member function get_callback_num(p_callback_code varchar2) return number
, member function get_callback_num_from_id(p_callback_id varchar2) return number
, member function region_exists(p_region_name varchar2) return boolean
, member function get_content return clob 
, member function get_sidebar return clob 
, member function get_toolbar return clob
, member function get_resource(p_name varchar2) return varchar2 
, member function get_js_link return varchar2 
, member function get_css_link return varchar2 
, member function get_image_link return varchar2 
) not final');
  --
  --
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_book_typ under xxdoo_bk_book_base_typ (
  service xxdoo.xxdoo_bk_service_typ
, state varchar2(8)
, created_date date
, pages xxdoo.xxdoo_bk_pages_typ
, roles xxdoo.xxdoo_bk_roles_typ
, package xxdoo.xxdoo_bk_method_typ
, home_page  varchar2(45)
, layout     varchar2(1)
--
, constructor function xxdoo_bk_book_typ return self as result 
, constructor function xxdoo_bk_book_typ(p_name varchar2) return self as result 
, constructor function xxdoo_bk_book_typ(p_name     varchar2,
                                         p_scheme   varchar2,
                                         p_table    varchar2,
                                         p_package  varchar2 default null,
                                         p_path     varchar2 default null,
                                         p_dev_code varchar2 default null,
                                         p_owner    varchar2 default null,
                                         p_title    varchar2 default null) return self as result
, member procedure set_id
, member procedure role(p_role xxdoo_bk_role_typ)
, member function role(self in out nocopy xxdoo_bk_book_typ, p_name varchar2, p_method xxdoo_bk_method_typ default null) return xxdoo_bk_role_typ
, member procedure cresource(p_name varchar2, p_value varchar2) 
, member function  page(p_name varchar2) return xxdoo_bk_page_typ
, member procedure page(p_name varchar2, p_html xxdoo_html, p_entity_name varchar2 default null, p_prepare xxdoo_bk_method_typ default null)
, member procedure home(p_name varchar2, p_html xxdoo_html, p_entity_name varchar2 default null)
, member function  role_page(p_page_name varchar2) return xxdoo_bk_role_page_typ
, member procedure create_layout(p_html xxdoo_html) 
, member procedure put 
, member function  get_role_num(p_name varchar2) return number 
, member function  get_page_num(p_name varchar2) return number 
, member function  get_template_num(p_template_name varchar2) return number
, member procedure template(p_name varchar2, p_html xxdoo_html, p_source_name varchar2 default null)

, member procedure generate 
, member function callback(self     in out nocopy xxdoo_bk_book_typ, 
                           p_callback_name varchar2,
                           p_method xxdoo_bk_method_typ) return varchar2
, member function callback(self     in out nocopy xxdoo_bk_book_typ, 
                           p_method xxdoo_bk_method_typ) return varchar2
, member function callback(self in out nocopy xxdoo_bk_book_typ, 
                           p_callback_name varchar2) return varchar2
, member function get_service_url return varchar2
, member procedure create_toolbar(p_toolbar xxdoo_dsl_toolbar)
, member procedure region(p_name varchar2, p_build_method xxdoo_bk_method_typ, p_html_method xxdoo_bk_method_typ default null)
, member function fn(p_owner   varchar2,
                     p_package varchar2,
                     p_method  varchar2) return xxdoo_bk_method_typ
, member function fn(p_method  varchar2) return xxdoo_bk_method_typ
, member function handler(self     in out nocopy xxdoo_bk_book_typ, 
                          p_method xxdoo_bk_method_typ) return varchar2
)');
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_books_typ is table of xxdoo.xxdoo_bk_book_typ'
  );
  --
  ei(p_body => 
'create type xxdoo.xxdoo_bk_answer_typ as object (
  book        xxdoo_bk_book_base_typ,
  role        xxdoo_bk_role_typ,
  scheme_id   number,
  callbacks   xxdoo_db_list_varchar2,
  layout_mode varchar2(1),
  entity_id   varchar2(200),
  path        varchar2(1024),
  inputs      xmltype,
  meta        varchar2(1024),
  context     xxdoo_html_context,
  regions     xxdoo_db_list,
  result      clob,
  user_id     number,
  user_name   varchar2(100),
  --
  constructor function xxdoo_bk_answer_typ return self as result,
  constructor function xxdoo_bk_answer_typ(p_book_name varchar2, 
                                           p_query     varchar2,
                                           p_path      varchar2, 
                                           p_inputs    clob, 
                                           p_meta      varchar2) return self as result,
  --
  member procedure authenticate,
  member procedure define_role,
  member procedure define_params,
  member procedure define_entries,
  --
  member function  get_callback_num(p_callback_id varchar2) return number,
  member procedure push_callback(p_callback_id varchar2),
  member procedure execute_callbacks,
  --
  member procedure refresh_regions,
  member procedure create_result(p_result in out nocopy xxdoo_bk_service_raw_typ),
  member function entry(p_name varchar2) return anydata,
  member procedure entry(p_name varchar2, p_object anydata),
  member procedure parameter(p_name varchar2, p_value varchar2),
  member function parameter(p_name varchar2) return varchar2,
  member procedure refresh(p_region_name varchar2),
  member function is_region(p_region_name varchar2) return boolean,
  member procedure append(p_str varchar2),
  member procedure append(p_str clob),
  member function dao(p_entity_id number) return xxdoo_dao,
  member function dao(p_entity_name varchar2) return xxdoo_dao,
  --
  member function template(self in out nocopy xxdoo_bk_answer_typ, p_template_name varchar2, p_object anydata default null) return clob,
  member function page_conditions(self in out nocopy xxdoo_bk_answer_typ, rpn number) return boolean,
  member procedure page_prepare(rpn number),
  member function page_content(self in out nocopy xxdoo_bk_answer_typ, rpn number) return clob,
  member procedure role_prepare
)');
  --
end;
/
