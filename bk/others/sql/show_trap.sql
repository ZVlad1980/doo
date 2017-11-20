select *
--delete
from   xxapps.xxapps_alert_traps_t a
where  application_name like 'XXDOO_BK'
order by a.trap_date desc
