select *
--delete
from   xxdoo_bk_role_params_t
/
select *
--delete
from   xxdoo_bk_roles_t
/
select *
--delete
from   xxdoo_bk_pages_t
/
select *
--delete
from   xxdoo_bk_role_pages_t
/
select *
from   xxdoo_bk_callbacks_t
/
select m.rowid, m.*
--delete
from   xxdoo_bk_methods_t m
where  m.name = 'get_journalview_page'
/
select *
--delete
from   xxdoo_bk_services_t
/
select *
--delete
from   xxdoo_bk_layouts_t
/
select *
--delete
from   xxdoo_bk_resources_t --XXDOO_BK_RESOURCES_FK2
/
select *
--delete
from   xxdoo_bk_toolbars_t
/
select *
--delete
from   xxdoo_bk_buttons_t
/
select *
from   xxdoo_bk_regions_t
/
select *
from   xxdoo_bk_templates_t
/
select b.rowid,b.*
--delete
from   xxdoo_bk_books_t b

/*
delete
from   xxdoo_bk_books_t
/
delete
from   xxdoo_bk_services_t
/
delete
from   xxdoo_bk_methods_t
/
commit
/
select m.rowid, m.*
--delete
from   xxdoo_bk_methods_t m
/
*/
