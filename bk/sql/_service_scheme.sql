begin
  merge into xxdoo_db_schemes_t s
  using (select -1                     id,
                1                      version,
                'xxdoo_bk'             name,
                'Base scheme API BOOK' full_name,
                'xxdoo'                owner
         from   dual
        ) u
  on    (s.id = u.id)
  when not matched then
    insert(id,version,name,full_name,owner,creation_date,last_update_date)
    values(u.id,u.version,u.name,u.full_name,u.owner,sysdate,sysdate);
  --
  merge into xxdoo_db_tables_t t
  using (select -1                       id,
                -1                       scheme_id,
                1                        version,
                'xxdoo'                  owner,
                'book'                   entry_name,
                'books'                  name,
                'xxdoo_bk_books_t'       db_table,
                'xxdoo_bk_books_base_v'  db_view,
                'xxdoo_bk_book_base_typ' db_type
         from   dual
        ) u
  on    (t.id = u.id)
  when not matched then
    insert(id, scheme_id, version, owner, entry_name, name, db_table, db_view, db_view_fast, db_type, db_coll_type, db_sequence, db_trigger, pk_template, pk_joins_template, creation_date, last_update_date)
    values(u.id, u.scheme_id, u.version, u.owner, u.entry_name, u.name, u.db_table, u.db_view, u.db_view, u.db_type, null, null, null, null, null, sysdate, sysdate);
  --
  commit;
end;
/