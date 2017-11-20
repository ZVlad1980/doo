select *
from   xxdoo_db_archive_lines_t al
where  1=1
--and    type = 'view'
and    al.archive_id in 
       (select max(id)
        from   xxdoo_db_archive_t a
        where  a.scheme_name = 'xxdoo_cntr'
       )
order by al.position
