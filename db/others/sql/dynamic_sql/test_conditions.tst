PL/SQL Developer Test script 3.0
12
-- Created on 08.09.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  cond xxdoo_db_condition;
begin
  cond := xxdoo_db_condition('name',anydata.ConvertVarchar2('%template%'),'like');
  dbms_output.put_line(cond.as_string);
  cond := xxdoo_db_condition('id',anydata.ConvertNumber(1),'=');
  dbms_output.put_line(cond.as_string);
  cond := xxdoo_db_condition('creation_date',anydata.ConvertDate(sysdate),'=');
  dbms_output.put_line(cond.as_string);
end;
0
0
