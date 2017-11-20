grant select on xxdoo_db_seq to apps with grant option;
grant execute,debug on xxdoo_db_utils_pkg to apps with grant option;
grant execute,debug on xxdoo_db_engine_pkg to apps with grant option;
grant execute on xxdoo_db_engine_pkg to xxapps,xxportal;
/
