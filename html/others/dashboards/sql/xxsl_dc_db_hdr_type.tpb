create or replace type body xxsl_dc_db_hdr_type is
  
  -- Member procedures and functions
  constructor function xxsl_dc_db_hdr_type return self as result is
  begin
    self.lines  := xxsl.xxsl_dc_db_lines_type();
    self.style  := xxsl_dc_dashboards_pkg.get_style;
    self.script := xxsl_dc_dashboards_pkg.get_script;
    self.title  := 'Deal chain events dashboard on ' || sys_context('USERENV','DB_NAME');
    xxsl_dc_dashboards_pkg.init('12',null,null);
    return;
  end;
  --
  member procedure find is
  begin
    xxsl_dc_dashboards_pkg.log('FIND OK!!!');
    xxsl_dc_dashboards_pkg.init('9',
                                self.shipment,self.operation_id);
  end;
  --
  member procedure getter is
  begin
    self.deal := xxsl_dc_dashboards_pkg.get_deal_number;
    self.shipment := xxsl_dc_dashboards_pkg.get_shipment_num;
    self.operation_id := xxsl_dc_dashboards_pkg.get_operation_id;
    --
    self.deal := case
                   when self.deal <> 'NULL' then
                     self.deal
                   else
                     null
                 end;
    self.shipment := case
                       when self.shipment <> 'NULL' then
                         self.shipment
                       else
                         null
                     end;             
    --
    select xxsl_dc_db_line_type(event_id,
                                deal_number,
                                deal_cnt,
                                deal_row_num,
                                shipment_num,
                                shipment_cnt,
                                shipment_row_num,
                                operation_id,
                                operation_cnt,
                                operation_row_num,
                                creation_date,
                                company_code,
                                event_name,
                                request_id,
                                last_update_date,
                                status,
                                state,
                                cancel_yn,
                                canceling_event_id,
                                parsed) bulk collect
    into   self.lines
    from   xxsl.xxsl_dc_db_events2_v e;
--    where  e.deal_number = '17481';
  end;
  --
end;
/
