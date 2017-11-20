create or replace package xxdoo_bk_core_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 19.08.2014 17:53:24
  -- Purpose : 
  --
  g_exc_error exception;
  --
  procedure plog(p_book_name varchar2,
                 p_query     varchar2 default null,

                 p_path      varchar2 default null,
                 p_inputs    clob,
                 p_meta      varchar2 default null);
  --
  function get_book(p_name varchar2) return xxdoo_bk_book_base_typ;
  --
  function get_dao(p_entity_id number) return xxdoo_dao;
  --
  function get_template(p_book_id number, p_template_name varchar2) return xxdoo_bk_template_typ;
  --
  procedure set_json(p_json clob);
  --
  function get_json return clob;
  --
  function get_medium_uri(p_book_name varchar2) return varchar2 
    result_cache;
  --
  function request(p_book_name varchar2,
                   p_query     varchar2,
                   p_path      varchar2,
                   p_inputs    clob,
                   p_meta      varchar2) return xxdoo_bk_service_raw_typ;
  --
  function request(p_book_name      varchar2,
                   p_request_body   clob,
                   p_request_params sys.odcivarchar2list) return xxdoo_bk_service_raw_typ;
  --
end xxdoo_bk_core_pkg;
/
