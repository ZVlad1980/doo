PL/SQL Developer Test script 3.0
41
 -- Created on 22.08.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  r xxapps.xxapps_service_raw_block;
  start_time  timestamp;  
  l_callback_id varchar2(32);
begin
  --dbms_session.reset_package; return;
  /*select id
  into   l_callback_id
  from   xxdoo.xxdoo_bk_callbacks_t
  where  rownum = 1; --*/
  
  xxdoo.xxdoo_utl_pkg.init_exceptions;
    start_time := current_timestamp;
    --r := xxdoo_ee.xxdoo_bk_ee_gateway_pkg."request"("path" => '/journals/New', "data" => null);
   /*r := xxdoo_ee.xxdoo_bk_ee_gateway_pkg."request"(
          "book_name" => 'journals', 
          "path"      => null,  --'?callback=4', 
          "inputs"    => null, 
          "meta"      => null); --*/
   r := xxdoo_ee.xxdoo_bk_ee_gateway_pkg."request"(
          "book_name" => 'journals', 
          "path"      => '/raw/DEV12/oralce.organaizers.journals/call/ALL/New?callback=9',
          "inputs"    => '', 
          "meta"      => 'journals.id.1'--
          ); --*/
    --
    dbms_output.put_line(r.clob_value);
    --
    -- --------------------------------------------------------------------------
    --dbms_output.put_line('---------------------------------------------');
    dbms_output.put_line('Total processing time = ' || regexp_substr(to_char(current_timestamp - start_time),'[^ ]+',1,2));
    xxdoo.xxdoo_utl_pkg.show_errors;
  --end loop;
  --
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
2
self.path
