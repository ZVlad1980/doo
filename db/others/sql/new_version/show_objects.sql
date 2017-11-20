select *
from   all_objects ao
where  ao.OBJECT_NAME like upper('xxdoo_cntr%')

drop type xxdoo_cntr_sites_typ;
drop type xxdoo_cntr_site_typ;
drop type xxdoo_cntr_addresses_typ;
drop type XXDOO_CNTR_ADDRESS_TYP;
