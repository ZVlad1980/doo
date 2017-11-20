select *
from   xxdoo.xxdoo_cntr_contractors_t
/
select *
from   xxdoo.xxdoo_cntr_contractors_t
/
select *
from   xxdoo.xxdoo_cntr_sites_t
--create index xxdoo_cntr_sites_n1 on xxdoo_cntr_sites_t(contractor_id)
/
select *
from   xxdoo.xxdoo_cntr_site_uses_t
--create index xxdoo_cntr_site_uses_n1 on xxdoo_cntr_site_uses_t(site_id)
/
select a.rowid, a.*
from   xxdoo.xxdoo_cntr_addresses_t a
where  country = 'LT'
/
select *
from   xxdoo.xxdoo_cntr_countries_t
/
select *
from   xxdoo.xxdoo_cntr_bank_branches_t
/
select *
from   xxdoo.xxdoo_cntr_bank_accounts_t
/
select *
from   xxdoo.xxdoo_cntr_bank_acc_uses_t
/


