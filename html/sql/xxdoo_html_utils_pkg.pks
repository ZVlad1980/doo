create or replace package xxdoo_html_utils_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 02.06.2014 13:02:12
  -- Purpose : 
  
  -- Public type declarations
  --package
  g_owner             varchar2(30) := 'xxdoo';
  g_fn_html           varchar2(30) := 'create_html';
  g_fn_json           varchar2(30) := 'get_json';
  g_fn_html_clob_name varchar2(30) := 'l_html';
  g_fn_service        varchar2(30) := 'service';
  g_path_oracle_client varchar2(100) := '/OA_HTML/cabo/jsLibs/custom/oracle-client.js';
  --параметры сервиса
  g_fn_service_pars xxdoo_html_ap_pkg_m_pars_typ :=
    xxdoo_html_ap_pkg_m_pars_typ(
      xxdoo_html_ap_pkg_m_par_typ('"callback"',null,'varchar2'),
      xxdoo_html_ap_pkg_m_par_typ('"params"',null,'clob')
    );
  --
  g_namespace varchar2(1024) := 'oracle.web.apps';
  --
  type g_fn_args is table of varchar2(32000);
  --
  function version return varchar2;
  --
  function get_session_sequence return number;
  --
  procedure fix_exception(p_description in varchar2 default null);
  --
  function get_exception_str(p_type in varchar2 default 'FULL') return varchar2;
  --
  function get_object_type(p_object_owner  varchar2,
                           p_object_name   varchar2) return varchar2;
  --
  function parse_tag(p_tag   in varchar2,
                     p_attrs in out nocopy xxdoo_html_el_tag_attrs_typ) return varchar2;
  --
  function get_function_xml(p_fn_name varchar2,
                            p_fn_args g_fn_args) return xmltype;
  --
  function get_function_str(p_fn_name varchar2,
                            p_fn_args g_fn_args) return varchar2;
  --
  function get_member_info(p_src  xxdoo_html_ap_source_typ, 
                           p_path varchar2) return xxdoo_html_el_member_info_typ;
  --
  function get_collection_info(p_member_info xxdoo_html_el_member_info_typ) return xxdoo_html_el_member_info_typ;
  --
  function get_status_obj(p_type  varchar2,
                          p_owner varchar2,
                          p_name  varchar2) return varchar2;
  --
  procedure compile_obj(p_type varchar2,p_owner varchar2, p_name varchar2,p_content clob);
  --
  function exists_member(p_source      xxdoo_html_ap_source_typ,
                         p_member_name varchar2,
                         p_member_type varchar2) return varchar2;
  --
  function exists_function_type(p_source      xxdoo_html_ap_source_typ,
                                p_method_name varchar2) return varchar2;
  --
  function exists_procedure_type(p_source      xxdoo_html_ap_source_typ,
                                p_method_name varchar2) return varchar2;
  --
  procedure log(p_msg varchar2);
  --
end xxdoo_html_utils_pkg;
/
