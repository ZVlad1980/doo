create or replace view xxdoo_db_ind_columns_v of xxdoo_db_column with object oid(id) as
  select cast(null as integer) instance_version ,
         ic.id,
         ic.index_id owner_id,
         ic.name,
         ic.position
  from   xxdoo_db_ind_columns_t ic
/
create or replace view xxdoo_db_indexes_v of xxdoo_db_index with object oid(id) as
  select cast(null as integer) instance_version,
         i.id,
         i.table_id,
         i.name,
         i.uniqueness,
         cast(
           multiset(
             select value(f)
             from   xxdoo_db_ind_columns_v f
             where  1=1
             and    f.owner_id = i.id
             order by f.position)
           as xxdoo_db_columns) column_list
  from   xxdoo_db_indexes_t i
/
create or replace view xxdoo_db_indexes_db_v as
  select i.owner,
         i.table_name,
         i.index_name name,
         i.uniqueness,
         (select listagg(ic.column_name,
                         ',') within group(order by ic.column_position)
          from   all_ind_columns ic
          where  ic.index_owner = i.owner
          and    ic.index_name = i.index_name) column_list
  from   all_indexes i
/
create or replace view xxdoo_db_cons_columns_v of xxdoo_db_column with object oid(id) as
  select cast(null as integer) instance_version,
         cc.id,
         cc.constraint_id owner_id,
         cc.name,
         cc.position
  from   xxdoo_db_cons_columns_t cc
/
create or replace view xxdoo_db_tab_joins_v of xxdoo_db_tab_join with object oid(id) as
  select cast(null as integer) instance_version,
         cc.id                ,
         cc.table_id          ,
         cc.table_name        ,
         cc.column_name       ,
         cc.r_table_name      ,
         cc.condition_template
  from   xxdoo_db_tab_joins_t cc
/
create or replace view xxdoo_db_dao_pk_columns_v of xxdoo_db_tab_column with object oid(id) as
  select cast(null as integer) instance_version,
         null id,
         tt.id owner_id,
         cc.name,
         cc.position,
         null nullable ,
         null default_value ,
         null length ,
         null scale ,
         tc.type type,
         null is_sequence 
  from   xxdoo_db_tables_t tt,
         xxdoo_db_tab_columns_t tc,
         xxdoo_db_constraints_t c,
         xxdoo_db_cons_columns_t cc
  where  1=1
  and    tc.name = cc.name
  and    cc.constraint_id = c.id
  and    c.type = 'P'
  and    c.table_id = tt.id
  and    tc.table_id = tt.id    
/
create or replace view xxdoo_db_daos_v of xxdoo_db_dao with object oid(id) as
  select t.version instance_version ,
         t.id,
         t.scheme_id,
         t.owner,
         t.entry_name,
         t.name,
         t.db_table,
         t.db_view,
         t.db_view_fast,
         t.db_type,
         t.db_coll_type,
         t.db_sequence,
         t.db_trigger,
         t.put_method,
         t.load_method,
         cast(
           multiset(
             select value(j)
             from   xxdoo_db_tab_joins_v j
             where  j.table_id = t.id
           ) as xxdoo_db_tab_joins
         ) joins,
         null query,
         cast(
           multiset(
             select value(j)
             from   xxdoo_db_dao_pk_columns_v j
             where  j.owner_id = t.id
           ) as xxdoo_db_tab_columns
         ) pk_columns
  from   xxdoo_db_tables_t t
/
create or replace view xxdoo_db_exp_tables_v as
  select t.version instance_version ,
         t.id,
         s.id scheme_id,
         s.name scheme_name,
         s.name dev_code,
         t.owner,
         t.entry_name,
         t.name,
         t.db_table,
         t.db_view,
         t.db_type,
         t.db_coll_type,
         t.db_sequence,
         t.db_trigger,
         t.put_method,
         t.load_method,
         null query
  from   xxdoo_db_tables_t t,
         xxdoo_db_schemes_t s
/
create or replace view xxdoo_db_constraints_v of xxdoo_db_constraint with object oid(id) as
  select cast(null as integer) instance_version,
         c.id,
         c.table_id,
         c.name,
         c.type,
         c.table_name,
         c.db_table_name,
         cast(
           multiset(
             select value(f)
             from   xxdoo_db_cons_columns_v f
             where  1=1
             and    f.owner_id = c.id
             order by f.position)
           as xxdoo_db_columns) column_list,
         c.r_table_name,
         null r_db_table,
         c.r_constraint_name,
         c.r_type,
         c.r_collection_name,
         null,
         c.delete_rule,
         c.update_rule
  from   xxdoo_db_constraints_t c
/
create or replace view xxdoo_db_constraints_db_v as
  select ac.owner,
         ac.table_name,
         ac.constraint_type,
         ac.constraint_name,
         (select listagg(acc.column_name,
                         ',') within group(order by acc.position)
          from   all_cons_columns acc
          where  acc.owner = ac.owner
          and    acc.constraint_name = ac.constraint_name) column_list
  from   all_constraints ac
/
create or replace view xxdoo_db_tab_columns_v of xxdoo_db_tab_column with object oid(id) as
  select cast(null as integer) instance_version,
         tc.id,
         tc.table_id owner_id,
         tc.name,
         tc.position,
         tc.nullable,
         tc.default_value,
         tc.length,
         tc.scale,
         tc.type,
         tc.is_sequence
  from   xxdoo_db_tab_columns_t tc
/
create or replace view xxdoo_db_tab_columns_db_v as
  select atc.owner,
         atc.table_name,
         atc.column_name name,
         atc.column_id position,
         atc.data_type type,
         null owner_type,
         atc.data_length length,
         atc.data_scale scale,
         atc.nullable
  from   all_tab_columns atc
/
create or replace view xxdoo_db_tables_v of xxdoo_db_table with object oid(id) as
  select t.version instance_version,
         t.id,
         t.scheme_id,
         t.owner,
         t.entry_name, 
         t.name,
         t.db_table,
         t.db_view,
         t.db_view_fast,
         t.db_type,
         t.db_coll_type,
         t.db_sequence,
         t.db_trigger,
         t.put_method,
         t.load_method,
         cast(
           multiset(
             select value(j)
             from   xxdoo_db_tab_joins_v j
             where  j.table_id = t.id
           ) as xxdoo_db_tab_joins
         ) joins,
         null query,
         cast(
           multiset(
             select value(j)
             from   xxdoo_db_dao_pk_columns_v j
             where  j.owner_id = t.id
           ) as xxdoo_db_tab_columns
         ) pk_columns,
         (select s.name
          from   xxdoo_db_schemes_t s
          where  s.id = t.scheme_id) dev_code,
         cast(
           multiset(
             select value(f)
             from   xxdoo_db_tab_columns_v f
             where  1=1
             and    f.owner_id = t.id
             order by f.position)
           as xxdoo_db_tab_columns) column_list,
         null attribute_list ,
         cast(
           multiset(
             select value(f)
             from   xxdoo_db_indexes_v f
             where  1=1
             and    f.table_id = t.id)
           as xxdoo_db_indexes) index_list,
         cast(
           multiset(
             select value(f)
             from   xxdoo_db_constraints_v f
             where  1=1
             and    f.table_id = t.id)
           as xxdoo_db_constraints) constraints,
         null content,
         t.creation_date,
         t.last_update_date,
         'N' status,
         null position_tab ,
         null position_typ ,
         null alias_xml    ,
         null alias_vw     ,
         null dao_path
  from   xxdoo_db_tables_t t
/
create or replace view xxdoo_db_schemes_v of xxdoo_db_scheme with object oid(id) as
  select s.version instance_version,
         s.id,
         s.name,
         s.full_name,
         s.owner,
         cast(
           multiset(
             select value(f)
             from   xxdoo_db_tables_v f
             where  1=1
             and    f.scheme_id = s.id)
           as xxdoo_db_tables) table_list,
         null objects_list,
         s.creation_date,
         s.last_update_date,
         null tmp_indexes,
         null tmp_constraints,
         null iterator
  from   xxdoo_db_schemes_t s
/
