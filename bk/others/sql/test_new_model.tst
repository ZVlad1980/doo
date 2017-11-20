PL/SQL Developer Test script 3.0
48
-- Created on 22.08.2014 by ZHURAVOV_VB 
declare
  -- Local variables here
  r             xxapps.xxapps_service_raw_block;
  start_time    timestamp;
  l_callback_id varchar2(32);
  --
  function request(book_name varchar2,
                    query     varchar2,
                    path      varchar2,
                    inputs    varchar2,
                    meta      varchar2) return xxapps.xxapps_service_raw_block is
  begin
    dbms_session.set_context(namespace => 'CLIENTCONTEXT', attribute => 'SERVICE_TAILURI', value => query);
    return xxdoo_ee.xxdoo_bk_ee_gateway_pkg."request"("book_name" => book_name,
                                                      "path"      => path,
                                                      "inputs"    => inputs,
                                                      "meta"      => meta --
                                                      );
  end;
begin
  --dbms_session.reset_package; return;
  /*select id
  into   l_callback_id
  from   xxdoo.xxdoo_bk_callbacks_t
  where  rownum = 1; --*/

  xxdoo.xxdoo_utl_pkg.init_exceptions;

  start_time := current_timestamp;

  r := request(book_name => 'journals',
               query     => '',
               path      => '/raw/DEV12/oralce.organaizers.journals/call/',
               inputs    => '',
               meta      => '' --
               ); --*/
  --
  dbms_output.put_line(r.clob_value);
  --
  dbms_output.put_line('Total processing time = ' || regexp_substr(to_char(current_timestamp - start_time), '[^ ]+', 1, 2));
  xxdoo.xxdoo_utl_pkg.show_errors;
  --
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
2
self.path
