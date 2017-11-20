create or replace view xxdoo_bk_entities_v of xxdoo_bk_entity_typ with object oid(entity_id) as
  select d.id entity_id,
         d.scheme_id,
         d.scheme_name,
         d.dev_code,
         d.owner,
         d.name entity_name,
         d.entry_name,
         d.db_type object_name,
         d.db_coll_type collect_name,
         d.db_table table_name,
         d.db_view view_name,
         d.db_sequence sequence_name,
         null,--p.name pk_field,
         null--p.type pk_type
  from   xxdoo_db_exp_tables_v d--,
         --table(d.pk_columns)(+) p
  where  1=1
  --and    p.position = 1
/
create or replace view xxdoo_bk_methods_v of xxdoo_bk_method_typ with object oid(id) as
  select id,
         version,
         name,
         owner,
         package,
         spc,
         body
  from   xxdoo_bk_methods_t t
/
create or replace view xxdoo_bk_services_v of xxdoo_bk_service_typ with object oid(id) as
select t.id,
       t.name,
       t.namespace,
       value(m)  method,
       t.url,
       t.is_default
from   xxdoo_bk_services_t t,
       xxdoo_bk_methods_v  m
where  m.id(+) = t.method_id
/
create or replace view xxdoo_bk_callbacks_v of xxdoo_bk_callback_typ with object oid(id) as
  select t.id,
         t.book_id,
         upper(m.owner||'.'||m.package||'.'||m.name) code,
         value(m) method
  from   xxdoo_bk_callbacks_t t,
         xxdoo_bk_methods_v   m
  where  1=1
  and    m.id(+) = t.method_id 
/
create or replace view xxdoo_bk_resources_v of xxdoo_bk_resource_typ with object oid(id) as
  select id,
         book_id,
         name,
         value
  from   xxdoo_bk_resources_t t
/
create or replace view xxdoo_bk_pages_v of xxdoo_bk_page_typ with object oid(id) as
  select p.id,
         p.book_id,
         p.name,
         value(cm) content_method,
         value(e) entity,
         value(pm) prepare_method
  from   xxdoo_bk_pages_t    p,
         xxdoo_bk_methods_v  cm,
         xxdoo_bk_methods_v  pm,
         xxdoo_bk_entities_v e
  where  1=1
  and    pm.id(+) = p.prepare_method_id
  and    cm.id(+) = p.content_method_id
  and    e.entity_id(+) = p.entity_id
/
create or replace view xxdoo_bk_role_pages_v of xxdoo_bk_role_page_typ with object oid(id) as
  select t.id,
         t.role_id,
         value(p)  page,
         'Y' is_show,
         t.order_num,
         null filters,
         value(m) condition_method_id,
         'N' save
  from   xxdoo_bk_role_pages_t t,
         xxdoo_bk_pages_v      p,
         xxdoo_bk_methods_v    m
  where  1=1
  and    m.id(+) = t.condition_method_id
  and    p.id(+) = t.page_id
/
create or replace view xxdoo_bk_roles_v of xxdoo_bk_role_typ with object oid(id) as
  select t.id,
         t.book_id,
         t.name,
         value(m) method,
         cast(multiset (select value(v) from xxdoo_bk_role_pages_v v where v.role_id = t.id order by v.order_num) as xxdoo_bk_role_pages_typ) pages,
         xxdoo_db_list(
           cast(
             multiset(
               select xxdoo_db_list_value(rp.key,rp.value)
               from   xxdoo_bk_role_params_t rp
               where  rp.role_id = t.id
             ) as xxdoo_db_list_values
           )
         ) parameters,
         null current_role_page
  from   xxdoo_bk_roles_t t,
         xxdoo_bk_methods_v m
  where  m.id(+) = t.method_id
/
create or replace view xxdoo_bk_regions_v of xxdoo_bk_region_typ with object oid(id) as
  select t.id,
         t.book_id,
         t.name,
         value(bm) build_method,
         value(hm) html_method,
         null html,
         null refresh
  from   xxdoo_bk_regions_t t,
         xxdoo_bk_methods_v    bm,
         xxdoo_bk_methods_v    hm
  where  1=1
  and    bm.id(+) = t.build_method_id
  and    hm.id(+) = t.html_method_id
/
create or replace view xxdoo_bk_templates_v of xxdoo_bk_template_typ with object oid(id) as
  select t.id,
         t.book_id,
         t.name,
         value(e) entity ,
         value(m) method,
         t.source
  from   xxdoo_bk_templates_t t,
         xxdoo_bk_methods_v   m,
         xxdoo_bk_entities_v  e
  where  1=1
  and    e.entity_id(+) = t.entity_id
  and    m.id(+) = t.method_id
/
create or replace view xxdoo_bk_books_base_v of xxdoo_bk_book_base_typ with object oid(id) as
  select b.id,
         b.name,
         b.owner,
         b.dev_code,
         b.title,
         b.search,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_regions_v v 
             where  v.book_id = b.id
           ) as xxdoo_bk_regions_typ
         ) regions,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_callbacks_v v 
             where v.book_id = b.id
           ) as xxdoo_bk_callbacks_typ
         ) callbacks,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_resources_v v 
             where  v.book_id = b.id
           ) as xxdoo_bk_resources_typ
         ) resources,
         value(e) entity,
         b.path,
         b.version,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_templates_v v 
             where  v.book_id = b.id
           ) as xxdoo_bk_templates_typ
         ) templates,
         null path_parser
  from   xxdoo_bk_books_t    b,
         xxdoo_bk_entities_v e
  where  1=1
  and    e.entity_id(+)  = b.entity_id
/
create or replace view xxdoo_bk_books_v of xxdoo_bk_book_typ with object oid(id) as
  select b.id,
         b.name,
         b.owner,
         b.dev_code,
         b.title,
         b.search,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_regions_v v 
             where  v.book_id = b.id
           ) as xxdoo_bk_regions_typ
         ) regions,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_callbacks_v v 
             where v.book_id = b.id
           ) as xxdoo_bk_callbacks_typ
         ) callbacks,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_resources_v v 
             where  v.book_id = b.id
           ) as xxdoo_bk_resources_typ
         ) resources,
         value(e) entity,
         b.path,
         b.version,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_templates_v v 
             where  v.book_id = b.id
           ) as xxdoo_bk_templates_typ
         ) templates,
         null path_parse
         value(s)  service,
         b.state,
         b.created_date,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_pages_v v 
             where v.book_id = b.id
           ) as xxdoo_bk_pages_typ
         ) pages,
         cast(
           multiset(
             select value(v) 
             from   xxdoo_bk_roles_v v 
             where  v.book_id = b.id
           ) as xxdoo_bk_roles_typ
         ) roles,
         value(m) package,
         b.home_page home,
         null
  from   xxdoo_bk_books_t    b,
         xxdoo_bk_services_v s,
         xxdoo_bk_methods_v  m,
         xxdoo_bk_entities_v e
  where  1=1
  and    s.id(+)  = b.service
  and    m.id(+)  = b.package_id
  and    e.entity_id(+)  = b.entity_id
/
