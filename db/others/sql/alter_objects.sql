alter type xxdoo_db_dao add attribute db_view_fast      varchar2(32) cascade
alter type xxdoo_db_dao drop member function  get(p_from_row number default null, p_to_row number default null) return anydata cascade
alter type xxdoo_db_dao add member function  get(p_from_row number default null, p_to_row number default null, p_fast_mode boolean default null) return anydata cascade
alter type xxdoo_db_attribute add attribute r_db_view_fast      varchar2(32) cascade
alter type xxdoo_db_attribute  add
constructor function xxdoo_db_attribute(p_name              varchar2, 
                                          p_column_name       varchar2,
                                          p_owner_type        varchar2, 
                                          p_type              varchar2, 
                                          p_type_code         varchar2,
                                          p_column_list       xxdoo_db_columns,
                                          p_r_table_name      varchar2,
                                          p_r_constraint_name varchar2,
                                          p_r_db_table        varchar2,
                                          p_r_db_type         varchar2,
                                          p_r_db_coll_type    varchar2,
                                          p_r_db_view         varchar2,
                                          p_r_db_view_fase    varchar2,
                                          p_r_column_list     xxdoo_db_columns)
    return self as result
cascade
/
alter type xxdoo_db_attribute  add
member procedure push_view(s           in out nocopy xxdoo_db_select, 
                             p_owner     varchar2, 
                             p_tab_alias varchar2, 
                             p_col_alias varchar2,
                             p_fast_view boolean default false) cascade
