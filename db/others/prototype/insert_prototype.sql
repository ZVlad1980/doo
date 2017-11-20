/*
insert into xxdoo_CNTR_COUNTRIES_T(ID, NAME, LOCALIZEDNAME, UNION_COUNTRIES)values('RU','Russian Federation','Russia',null)
/
insert into xxdoo_CNTR_COUNTRIES_T(ID, NAME, LOCALIZEDNAME, UNION_COUNTRIES)values('US','United State','USA',null);
/
select *
from   xxdoo_CNTR_COUNTRIES_T
/
insert into xxdoo_CNTR_ADDRESSES_T(COUNTRY, POSTAL_CODE, ADDR_LINE) values('RU','111111','Moscow')
/
insert into xxdoo_CNTR_ADDRESSES_T(COUNTRY, POSTAL_CODE, ADDR_LINE) values('US','999999','New York')
/
select *
from   xxdoo_CNTR_ADDRESSES_T
/
insert into xxdoo_CNTR_CONTRACTORS_T(NAME, TYPE) values('Lenovo','Vendor')
/
select *
from   xxdoo_CNTR_CONTRACTORS_T
/
insert into xxdoo_CNTR_SITES_T(CONTRACTOR_ID, ROLE, ADDRESS_ID)values(1,'Ship to',1)
/
insert into xxdoo_CNTR_SITES_T(CONTRACTOR_ID, ROLE, ADDRESS_ID)values(1,'Bill to',1)
/
select *
from   xxdoo_CNTR_SITES_T
/
insert into xxdoo_CNTR_BANKACCOUNTS_T(SITEID, ACCOUNTNUM)values(1,10101010101)
/
select *
from   xxdoo_CNTR_BANKACCOUNTS_T
/
insert into xxdoo_CNTR_SITEACCOUNTS_T(ACCOUNTID, SITEID)values(1,1)
/
select *
from   xxdoo_CNTR_SITEACCOUNTS_T
/
--роли
select *
from   xxdoo_cntr_roles_t
*/
--xmlroot(xmltype.createxml(s), version 1.0)
select xmlroot(xmltype.createxml(value(c)),
               version 1.0) xml_info,
       c.*
from   xxdoo_cntr_contractors_v c
/
