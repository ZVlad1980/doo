create or replace view xxdoo_html_obj_members_v as
select tc.owner           object_owner,
       tc.table_name      object_name,
       tc.column_name     member_name,
       tc.data_type       data_type,
       tc.data_type_owner data_type_owner,
       t.typecode         data_type_code,
       tc.data_length     lenght
from   all_tab_cols tc,
       all_types    t
where  1=1
and    t.type_name(+) = tc.data_type
and    t.owner(+) = tc.data_type_owner
union all
select ta.owner           object_owner,
       ta.type_name       object_name,
       ta.attr_name       member_name,
       ta.attr_type_name  data_type,
       ta.attr_type_owner data_type_owner,
       t.typecode         data_type_code,
       ta.length          lenght
from   all_type_attrs ta,
       all_types      t
where  1 = 1
and    t.type_name(+) = ta.attr_type_name
and    t.owner(+) = ta.attr_type_owner
union all
select m.owner           object_owner,
       m.type_name       object_name,
       m.method_name     member_name,
       cast('METHOD'  as varchar2(30))  data_type,
       cast(null as varchar2(30))       data_type_owner,
       cast(case
              when m.results = 0 then
                'PROCEDURE'
              else
                'FUNCTION'
            end as varchar2(30))         data_type_code,
       cast(null as number)             lenght
from   all_type_methods m
/
