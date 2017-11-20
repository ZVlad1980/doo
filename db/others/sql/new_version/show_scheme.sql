select *
--delete
from   xxdoo_db_schemes_t
/
select *--t.rowid,t.load_method,t.put_method--,t.*--t.version,t.load_method,t.put_method,t.name
from   xxdoo_db_tables_t t
/
select *
from   xxdoo_db_tabs_v
/
select *
from   xxdoo_db_tab_columns_t
/
select *
from   xxdoo_db_indexes_t
/
select *
from   xxdoo_db_ind_columns_t
/
select *
from   xxdoo_db_constraints_t
where  type = 'R'
/
select *
from   xxdoo_db_cons_columns_t
/
select *
from   xxdoo_db_tab_joins_t
/
