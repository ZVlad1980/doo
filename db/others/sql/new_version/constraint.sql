select *
from   all_constraints c
where  c.TABLE_NAME = upper('xxdoo_tst_types')
/
select *
from   all_cons_columns cc
where  cc.table_name = upper('xxdoo_tst_types')
/
select *
from   all_tab_columns t
where  t.TABLE_NAME = upper('xxdoo_tst_types')
/
select (select listagg(ic.COLUMN_NAME,',') within group (order by ic.COLUMN_POSITION)
        from   all_ind_columns ic
        where  ic.INDEX_OWNER = i.OWNER
        and    ic.INDEX_NAME = i.INDEX_NAME) column_list, i.*
from   all_indexes i
where  i.TABLE_NAME = upper('xxdoo_tst_types')
/
select *
from   all_ind_columns ic
where  ic.TABLE_NAME = upper('xxdoo_tst_types')
/
alter table XXDOO_CNTR_CONTRACTORS_T add constraint xxdoo_cntr_contractors_n1 check(name is not null);
alter table XXDOO_CNTR_CONTRACTORS_T drop constraint xxdoo_cntr_contractors_n1;
alter table XXDOO_CNTR_CONTRACTORS_T modify(name varchar2(150) constraint xxdoo_cntr_contractors_n1 not null);
alter table XXDOO_CNTR_CONTRACTORS_T add constraint xxdoo_cntr_contractors_uc1 unique (name)
/
insert into XXDOO_CNTR_CONTRACTORS_T(name,type)values('','Vendor')
/
create 
--drop 
table xxdoo_tst_types(id integer, name varchar2(10) not null unique, code varchar2(10))
/
create index xxdoo_tst_types_n1 on xxdoo_tst_types(code)
create index xxdoo_tst_types_n2 on xxdoo_tst_types(code,name)
/
create 
--drop
table xxdoo_tst_parent(id integer, parent_name varchar2(10), type_id number)
/
create 
--drop
table xxdoo_tst_child(id number(10,2), parent_id number, name varchar2(10), code varchar2(10))
/
--
alter table xxdoo_tst_parent --drop constraint SYS_C00560721
add constraint xxdoo_tst_parent_pk primary key(id);
/
create index xxdoo_tst_parent_pk on xxdoo_tst_parent(type_id)
/
alter table xxdoo_tst_child --drop constraint SYS_C00560721
add constraint xxdoo_tst_parent_pk primary key(id);
/
alter table xxdoo_tst_types add constraint xxdoo_tst_types_c1 check (name in ('A','B','D'));
--
alter table xxdoo_tst_types modify (name varchar2(10) null)
/
insert into xxdoo_tst_types(id, name)values(1,'F')

/
