select o.status,o.*
from   all_objects  o
where  o.OBJECT_NAME like upper('xxdoo_bk%')
and    o.status = 'INVALID'


-- drop package XXDOO_CNTR_GATEWAY_PKG
