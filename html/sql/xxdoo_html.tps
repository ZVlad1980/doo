create or replace type xxdoo_html as object
(
  -- Attributes
  id          number,
  application xxdoo_html_ap_appl_typ,
  elements    xxdoo_html_elements_typ,
  -- Member functions and procedures
  constructor function xxdoo_html return self as result,
  constructor function xxdoo_html(p_appl_name   varchar2,
                                 p_src_owner   varchar2,
                                 p_src_object  varchar2,
                                 p_appl_code   varchar2 default null) return self as result,
  constructor function xxdoo_html(p_html_object xxdoo_html,
                                  p_src_owner    varchar2,
                                  p_src_object   varchar2) return self as result,
  constructor function xxdoo_html(p_src_owner    varchar2,
                                  p_src_object   varchar2) return self as result,
  --
  member procedure init,
  --
  member procedure init_source(p_src_owner    varchar2,
                               p_src_object   varchar2),
  --
  member function append(self in out xxdoo_html,
                         p_tag       varchar2, 
                         p_attrs     xxdoo_html_el_tag_attrs_typ default null,  
                         p_content   varchar2                   default null) return number,
  member function append(self     in out xxdoo_html,
                         p_object xxdoo_html_element_typ) return number, 
  member procedure merge_new(p_object xxdoo_html),
  member procedure merge_different(p_object xxdoo_html),
  member function merge(self in out xxdoo_html, p_object in out xxdoo_html) return xxdoo_html,
  member function is_equal_object(p_object xxdoo_html) return varchar2,
  --
  member function h(p_tag         varchar2, 
                    p_attrs       xxdoo_html_el_tag_attrs_typ, 
                    p_content     varchar2 default null) return xxdoo_html,
  member function h(p_tag         varchar2,
                    p_content     varchar2) return xxdoo_html,
  member function h(p_tag         varchar2) return xxdoo_html,
  member function h(p_tag         varchar2, 
                    p_attrs       xxdoo_html_el_tag_attrs_typ, 
                    p_object      xxdoo_html) return xxdoo_html,
  member function h(p_tag         varchar2, 
                    p_object      xxdoo_html) return xxdoo_html,
  member function h(p_object xxdoo_html) return xxdoo_html,
  member procedure set_parent(p_parent_id number),
  --
  member function attr(p_name varchar2,p_content varchar2) return xxdoo_html_el_tag_attrs_typ,
  member function attrs(attrs         xxdoo_html_el_tag_attrs_typ default null, 
                        class         varchar2 default null, 
                        type          varchar2 default null, 
                        name          varchar2 default null, 
                        value         varchar2 default null, 
                        id            varchar2 default null, 
                        colspan       varchar2 default null, 
                        rowspan       varchar2 default null, 
                        href          varchar2 default null, 
                        title         varchar2 default null, 
                        data_behavior varchar2 default null,
                        rel           varchar2 default null,
                        http_equiv    varchar2 default null,
                        width         varchar2 default null,
                        content       varchar2 default null,
                        onclick       varchar2 default null,
                        charset       varchar2 default null,
                        data_book     varchar2 default null,
                        data_action   varchar2 default null) 
      return xxdoo_html_el_tag_attrs_typ,
  member function text(p_content varchar2) return xxdoo_html,
  --
  member function  g(p_value varchar2) return varchar2,
  member function  each(p_each_src varchar2, p_object xxdoo_html) return xxdoo_html,
  member function each(p_object xxdoo_html) return xxdoo_html,
  member function  callbacks(p_value varchar2) return varchar2,
  member function region(p_id number) return xxdoo_html,
  --
  member function  as_string(p_parent_id number default null,
                             p_indent    number default 1) return varchar2,
  member procedure prepare(p_parent_id number default null, p_ctx xxdoo_html_el_context_typ default null),
  member procedure create_fn_html(p_method in out nocopy xxdoo_html_ap_pkg_mthd_typ,
                                  p_parent_id number default null),
  member procedure create_fn_html,
  member function get_method(self in out nocopy xxdoo_html, p_name varchar2 default null) return clob --*/
)
/
