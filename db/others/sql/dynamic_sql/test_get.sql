declare
  a anydata;
  coll xxdoo_cntr_contractors_typ;
  l_dummy pls_integer;
begin
  select anydata.ConvertCollection(cast(multiset(
           select value(v)
           from   xxdoo_cntr_contractors_v v
           where  1=1
           and    v.id = 1)
         as xxdoo_cntr_contractors_typ)) d
  into   a
  from   dual;
  --
  l_dummy := a.getCollection(coll);
  --
  for c in 1..coll.count loop
    dbms_output.put_line(coll(c).name);
  end loop;
end;
