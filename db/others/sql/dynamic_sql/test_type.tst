PL/SQL Developer Test script 3.0
21
-- Created on 08.09.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  a anydata;
  o xxdoo_cntr_contractor_typ;
  c xxdoo_cntr_contractors_typ;
  
  --
  procedure show(a anydata) is
    l_type_code pls_integer;
    l_type      anytype;
  begin
    l_type_code := a.GetType(l_type);
    dbms_output.put_line(l_type_code);
  end;
begin
  -- Test statements here
  show(anydata.ConvertObject(o));
  show(anydata.ConvertCollection(c));
  
end;
0
0
