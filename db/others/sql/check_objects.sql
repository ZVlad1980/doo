select o.status,o.*
from   all_objects  o
where  o.OBJECT_NAME like upper('xxdoo_db%')
and    o.status = 'INVALID'
