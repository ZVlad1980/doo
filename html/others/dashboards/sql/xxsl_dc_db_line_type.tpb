create or replace type body xxsl_dc_db_line_type is
  
  -- Member procedures and functions
  constructor function xxsl_dc_db_line_type return self as result is
  begin
    return;
  end;
  --
  member function status_as_string return varchar2 is
  begin
    return self.status ||
              case
               when self.status = 'ERROR' then
                 case
                   when self.parsed = 'Y' then
                     ', Parsed'
                   else
                     ', No parsed'
                 end
             end;
  end;
  --
  member function status_class return varchar2 is
  begin
    if self.status = 'ERROR' then
      return 'error';
    end if;
    return '';
  end status_class;
  --
  member function onclick_invoke return varchar2 is
  begin
    return 'actionEvent(' || self.event_id || ',''INVOKE'');return false;';
    return '';
  end onclick_invoke;
  --
  member function onclick_in_xml return varchar2 is
  begin
    return 'openMsg(' || self.event_id || ',''IN_XML''); return false;';
  end onclick_in_xml;
  --
  member function onclick_out_xml return varchar2 is
  begin
    return 'openMsg(' || self.event_id || ',''OUT_XML''); return false;';
  end onclick_out_xml;
  --
  member function class_deal return varchar2 is
  begin
    return case
             when self.deal_row_num = 1 then
               'lvl'
             else
               'hidden'
           end;
  end class_deal;
  --
  member function class_shipment  return varchar2 is
  begin
    return case
             when self.shipment_row_num = 1 then
               'lvl'
             else
               'hidden'
           end;
  end class_shipment;
  --
  member function class_operation return varchar2 is
  begin
    return case
             when self.operation_row_num = 1 then
               'lvl'
             else
               'hidden'
           end;
  end class_operation;
  --
  member function redo_class return varchar2 is
  begin
    return case
             when self.status = 'ERROR' then
               'invoke'
             else
               'hidden'
           end;
  end redo_class;
  --
  member function is_hide_controls return varchar2 is
  begin
    return case
             when xxsl.xxsl_dc_dashboards_pkg.get_is_show_controls = true then
               'false'
             else
               'true'
           end;
  end is_hide_controls;
  --
  --
end;
/
