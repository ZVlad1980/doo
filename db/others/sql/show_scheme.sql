select *
--delete
from   xxdoo_db_entity_content_t
/
select *
--delete
from   xxdoo_db_fields_v f,
       xxdoo_db_entities_v      e
where  f.entity_id = e.id
and    e.scheme_id = 699
/
select *
--delete
from   xxdoo_db_relationships_v r,
       xxdoo_db_entities_v      e
where  r.entity_id = e.id
and    e.scheme_id = 699
/
select *
--delete
from   xxdoo_db_indexes_t
/
select *
--delete
from   xxdoo_db_objects_t o
where  o.scheme_id = 1--o.name = 'xxdoo_SALE_CMRRANGES_T'--scheme_id = 13607
/
select *
--delete
from   xxdoo_db_tables_v e
--where -- e.name in (upper('documentRanges'),upper('cmrRanges'))--
where   scheme_id = 1
/
select s.*
--delete
from   xxdoo_db_schemes_t s
where  name = 'Books' --'SALE'
/
select *
--delete
from   xxdoo_db_objects_t o
where  o.scheme_id = 699
and    type in ('TABLE','TYPE BODY')
order by idx desc
