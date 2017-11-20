declare
  o xxdoo_bk_book_typ := xxdoo_bk_book_typ('Contractors');
  o2 xxdoo_cntr_contractor_typ := xxdoo_cntr_contractor_typ();
  a anydata := null;
  l pls_integer;
begin
  a := anydata.convertObject(o);
  l := a.getObject(o);
  dbms_output.put_line(o.name);
end;
