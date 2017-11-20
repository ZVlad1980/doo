create or replace view xxdoo_html_objs_v as
select ao.owner           object_owner,
       ao.object_name,
       ao.object_type     object_type,
       ct.elem_type_name  data_type,
       ct.elem_type_owner data_type_owner,
       dao.object_type    data_object_type,
       t.typecode         type_code,
       ct.coll_type       collection_type
from   all_objects    ao,
       all_types      t,
       all_coll_types ct,
       all_objects    dao
where  1 = 1
and    dao.object_type(+) not like '%BODY'
and    dao.subobject_name(+) is null
and    dao.object_name(+) = ct.elem_type_name
and    dao.owner(+) = ct.elem_type_owner
and    ct.type_name(+) = t.type_name
and    ct.owner(+) = t.owner
and    t.type_name(+) = ao.object_name
and    t.owner(+) = ao.owner
and    ao.subobject_name is null
and    ao.object_type not like '%BODY'
/
