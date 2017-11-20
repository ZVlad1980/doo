declare
  --
  g_owner varchar2(30) := 'xxsl';
  procedure plog(p_msg in varchar2, p_eof in boolean default false) is
  begin
    if p_eof = true then
      dbms_output.put_line(p_msg);
    else
      dbms_output.put(p_msg);
    end if;
  end;
  --
  procedure create_obj(p_type  in varchar2,
                       p_name  in varchar2,
                       p_body  in varchar2,
                       p_owner  in varchar2 default g_owner) is
    l_obj_exist_exc exception;
    l_obj_exist2_exc exception;
    pragma exception_init(l_obj_exist_exc, -955);
    pragma exception_init(l_obj_exist2_exc, -2303);
    --
  begin
    plog('Create '||p_type||' '||p_name||'...');
    execute immediate 'create '||p_type||' '||p_owner||'.'||p_name||' '||p_body;
    execute immediate 'grant execute, debug on '||p_owner||'.'||p_name||' to apps with grant option';
    plog('Ok',true);
  exception
    when l_obj_exist_exc or l_obj_exist2_exc then
      plog('exist',true);
    when others then
      plog('error: '||sqlerrm, true);
      raise;
  end;
  --
  procedure alter_obj(p_type  in varchar2,
                      p_name  in varchar2,
                      p_body  in varchar2,
                      p_owner  in varchar2 default g_owner) is
    l_element_exists_exc exception;
    pragma exception_init(l_element_exists_exc, -1442);
    l_element_exists2_exc exception; --дубирование элементов в типе
    pragma exception_init(l_element_exists2_exc, -22324);
  begin
    plog('Alter '||p_type||' '||p_name||'...');
    execute immediate 'alter '||p_type||' '||p_owner||'.'||p_name||' '||p_body;
    plog('Ok',true);
  exception
    when l_element_exists_exc or l_element_exists2_exc then
      plog('exist',true);
    when others then
      plog('error'||sqlerrm,true); --plog('error: '||sqlerrm, true);
      raise;
  end;
  --
begin
  --return;
  dbms_output.enable(100000);
  --тип для строк
  create_obj(p_type  => 'type',
             p_name  => 'xxsl_dc_db_line_type',
             p_body  => ' as object (
                          event_id           number, 
                          deal_number        varchar2(4000), 
                          deal_cnt           number,
                          deal_row_num       number,
                          shipment_num       varchar2(4000), 
                          shipment_cnt       number,
                          shipment_row_num   number,
                          operation_id       number, 
                          operation_cnt      number,
                          operation_row_num  number,
                          creation_date      date, 
                          company_code       varchar2(10), 
                          event_name         varchar2(40), 
                          request_id         number, 
                          last_update_date   date, 
                          status             varchar2(20), 
                          state              varchar2(20), 
                          cancel_yn          varchar2(1), 
                          canceling_event_id number, 
                          parsed             varchar2(1),
                          -- Member functions and procedures
                          constructor function xxsl_dc_db_line_type return self as result,
                          member function status_as_string return varchar2,
                          member function status_class return varchar2,
                          member function onclick_invoke return varchar2,
                          member function onclick_in_xml return varchar2,
                          member function onclick_out_xml return varchar2,
                          member function class_deal      return varchar2,
                          member function class_shipment  return varchar2,
                          member function class_operation return varchar2,
                          member function redo_class return varchar2,
                          member function is_hide_controls return varchar2
                          )');
  --Коллекция для хранения аргументов функций 
  create_obj(p_type  => 'type',
             p_name  => 'xxsl_dc_db_lines_type',
             p_body  => ' as table of xxsl_dc_db_line_type');
  --тип для описания члена типа
  create_obj(p_type  => 'type',
             p_name  => 'xxsl_dc_db_hdr_type',
             p_body  => ' as object (
                          title        varchar2(200),
                          style        varchar2(4000),
                          script       varchar2(2000),
                          deal         varchar2(200),
                          shipment     varchar2(200),
                          operation_id varchar2(200),
                          lines        xxsl_dc_db_lines_type,
                          -- Member functions and procedures
                          constructor function xxsl_dc_db_hdr_type return self as result,
                          member procedure getter,
                          member procedure find
                          )');
exception
  when others then
    plog('Crashed creation objects');
end;
/
