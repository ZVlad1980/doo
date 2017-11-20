create or replace package xxsl.xxsl_dc_dashboards_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 28.02.2014 16:53:25
  -- Purpose : 
  --
  function get_shipment_num return varchar2 deterministic;
  function get_deal_number  return varchar2 deterministic;
  function get_operation_id return number   deterministic;
  function get_from_date    return date     deterministic;
  function get_is_show_controls return boolean     deterministic;
  
  procedure init(p_deal_number  varchar2 ,
                 p_shipment_num varchar2 ,
                 p_operation_id number   );
  --
  function get_script return varchar2;
  function get_style return varchar2;
  --
  procedure log(p_msg varchar2);
end xxsl_dc_dashboards_pkg;
/
