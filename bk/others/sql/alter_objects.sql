/*
alter type xxdoo_bk_callback_typ drop member procedure call(p_answer in out xxdoo_bk_answer_typ) cascade
alter type xxdoo_bk_book_base_typ drop member procedure execute_callback(p_callback_id number, p_answer in out nocopy xxdoo_bk_answer_typ) cascade;
alter type xxdoo_bk_book_typ drop member function get_callback_num(p_callback_code varchar2) return number cascade;
alter type xxdoo_bk_book_base_typ add member function get_callback_num(p_callback_code varchar2) return number cascade;
alter type xxdoo_bk_book_base_typ add member function get_callback_num_from_id(p_callback_id varchar2) return number cascade;
alter type xxdoo_bk_answer_typ add member procedure create_result(p_result in out nocopy xxapps.xxapps_service_raw_block) cascade;
*/
/*
alter type xxdoo.xxdoo_bk_role_typ drop attribute filter_page cascade
alter type xxdoo.xxdoo_bk_role_typ add attribute parameters  xxdoo_db_list cascade
alter type xxdoo.xxdoo_bk_book_typ drop member function get_region_html(p_region_name varchar2) return clob cascade
alter type xxdoo.xxdoo_bk_book_base_typ drop member procedure region_mark_refresh(p_region_name varchar2) cascade
alter type xxdoo.xxdoo_bk_book_typ drop member procedure execute_callback(p_callback_id number, p_answer in out nocopy xxdoo_bk_answer_typ) cascade;
alter type xxdoo.xxdoo_bk_book_base_typ add member procedure execute_callback(p_callback_id number, p_answer in out nocopy xxdoo_bk_answer_typ) cascade;
alter type xxdoo.xxdoo_bk_context_typ add member procedure execute_callbacks cascade
alter type xxdoo.xxdoo_bk_answer_typ add attribute layout_mode varchar2(1) cascade
alter type xxdoo.xxdoo_bk_answer_typ drop attribute callback_id cascade
alter type xxdoo.xxdoo_bk_context_typ add member procedure refresh_regions cascade
alter type xxdoo.xxdoo_bk_context_typ add member function get_callback_num(p_callback_id varchar2) return number cascade
alter type xxdoo.xxdoo_bk_context_typ add member procedure create_result(p_result in out nocopy clob) cascade

alter type xxdoo_bk_region_typ add attribute refresh varchar2(1) cascade
alter type xxdoo_bk_region_typ add member procedure mark_refresh cascade
alter type xxdoo.xxdoo_bk_book_base_typ add member function region_exists(p_region_name varchar2) return boolean cascade
*/
/*
  !!! 20140926 MOVING prepare_method from role_page to page
--ROLE
alter type xxdoo.xxdoo_bk_role_typ drop member procedure prepare cascade;
alter type xxdoo.xxdoo_bk_role_typ add member procedure prepare_role cascade;
alter type xxdoo.xxdoo_bk_role_typ add member procedure set_method(p_method xxdoo_bk_method_typ) cascade;
alter type xxdoo.xxdoo_bk_role_typ add member procedure prepare(p_answer in out nocopy xxdoo_bk_answer_typ) cascade;
alter type xxdoo.xxdoo_bk_book_typ drop member function role(self in out nocopy xxdoo_bk_book_typ, p_name varchar2) return xxdoo_bk_role_typ cascade;
alter type xxdoo.xxdoo_bk_book_typ add member function role(self in out nocopy xxdoo_bk_book_typ, p_name varchar2, p_method xxdoo_bk_method_typ default null) return xxdoo_bk_role_typ cascade;
*/
/* 
  !!! 20140926 MOVING prepare_method from role_page to page
--PAGE
alter type xxdoo.xxdoo_bk_page_typ add attribute prepare_method xxdoo_bk_method_typ cascade;
alter table XXDOO.XXDOO_BK_PAGES_T add prepare_method_id number;
alter table XXDOO.XXDOO_BK_PAGES_T add constraint xxdoo_bk_pages_fk4 foreign key(prepare_method_id) references XXDOO.XXDOO_BK_METHODS_T(id);
alter type xxdoo.xxdoo_bk_page_typ drop member procedure create_html(p_html xxdoo_html) cascade;
alter type xxdoo.xxdoo_bk_page_typ add member procedure build_html_method(p_html xxdoo_html)              cascade;
alter type xxdoo.xxdoo_bk_page_typ add member procedure set_prepare_method(p_method xxdoo_bk_method_typ) cascade;
alter type xxdoo.xxdoo_bk_page_typ add member procedure prepare(p_answer in out nocopy xxdoo_bk_answer_typ)  cascade;
--ROLE PAGE
alter type xxdoo.xxdoo_bk_role_page_typ drop attribute prepare_mthd cascade; --   xxdoo_bk_method_typ
alter type xxdoo.xxdoo_bk_role_page_typ drop member function prepare_method(p_method  xxdoo_bk_method_typ) return xxdoo_bk_role_page_typ cascade;
alter table XXDOO.XXDOO_BK_ROLE_PAGES_T drop column prepare_method_id;
--BOOK
alter type xxdoo.xxdoo_bk_book_typ drop member procedure page(p_name varchar2, p_html xxdoo_html, p_entity_name varchar2 default null) cascade;
alter type xxdoo.xxdoo_bk_book_typ add member procedure page(p_name varchar2, p_html xxdoo_html, p_entity_name varchar2 default null, p_prepare xxdoo_bk_method_typ default null) cascade;
*/
/*
   !!! refactoring interface registration role
-- BOOK
alter type xxdoo.xxdoo_bk_book_typ add member procedure role(p_role xxdoo_bk_role_typ) cascade;
alter type xxdoo.xxdoo_bk_book_typ drop member procedure role(p_name varchar2, p_role_pages xxdoo_bk_role_pages_typ default null) cascade;
-- ROLE
alter type xxdoo.xxdoo_bk_role_typ drop member function page(self in out nocopy xxdoo_bk_role_typ, p_page xxdoo_bk_page_typ) return xxdoo_bk_role_page_typ cascade;
alter type xxdoo.xxdoo_bk_role_typ add member function page(p_page xxdoo_bk_page_typ) return xxdoo_bk_role_typ cascade;
alter type xxdoo.xxdoo_bk_role_typ add member function is_when(p_method xxdoo_bk_method_typ) return xxdoo_bk_role_typ cascade;
alter type xxdoo.xxdoo_bk_role_typ drop member procedure build(p_pages xxdoo_bk_role_pages_typ) cascade;
alter type xxdoo.xxdoo_bk_role_typ drop member procedure build_condition_methods cascade;
alter type xxdoo.xxdoo_bk_role_typ add member procedure prepare cascade;
alter type xxdoo.xxdoo_bk_role_typ add attribute current_role_page number cascade;
alter type xxdoo.xxdoo_bk_role_typ add member procedure page(p_page xxdoo_bk_page_typ) cascade;
alter type xxdoo.xxdoo_bk_role_typ add member procedure is_when(p_method xxdoo_bk_method_typ) cascade;
alter type xxdoo.xxdoo_bk_role_typ add member procedure is_when(p_method xxdoo_bk_method_typ, p_pages xxdoo_bk_pages_typ) cascade;
alter type xxdoo.xxdoo_bk_role_typ drop member procedure filter_pages(p_entry in out nocopy anydata, p_entry_type varchar2, l_state varchar2, l_user varchar2) cascade;
-- ROLE PAGE
alter type xxdoo.xxdoo_bk_role_page_typ drop member procedure copy(p_role_page xxdoo_bk_role_page_typ) cascade;
alter type xxdoo.xxdoo_bk_role_page_typ drop constructor function xxdoo_bk_role_page_typ(p_page_name varchar2) return self as result cascade;
alter type xxdoo.xxdoo_bk_role_page_typ drop member function condition_method(p_method  xxdoo_bk_method_typ) return xxdoo_bk_role_page_typ cascade;
alter type xxdoo.xxdoo_bk_role_page_typ drop member function is_when(p_method  xxdoo_bk_method_typ) return xxdoo_bk_role_page_typ cascade;
alter type xxdoo.xxdoo_bk_role_page_typ  add member procedure is_when(p_method  xxdoo_bk_method_typ) cascade;
alter type xxdoo.xxdoo_bk_role_page_typ drop attribute condition_mthd cascade;
alter type xxdoo.xxdoo_bk_role_page_typ add attribute filters xxdoo_bk_methods_typ cascade;
alter type xxdoo.xxdoo_bk_role_page_typ add member function get_filter_num(p_method_name varchar2) return number cascade;
alter type xxdoo.xxdoo_bk_role_page_typ add attribute condition_method xxdoo_bk_method_typ cascade;
alter type xxdoo.xxdoo_bk_role_page_typ add attribute save varchar2(1) cascade;
alter type xxdoo.xxdoo_bk_role_page_typ add member procedure build_condition_method cascade;
alter type xxdoo.xxdoo_bk_role_page_typ add member procedure set_page(p_page xxdoo_bk_page_typ) cascade;
*/
