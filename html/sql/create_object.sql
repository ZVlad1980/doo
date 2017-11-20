declare
  --
  g_owner varchar2(30) := 'xxdoo';
  procedure plog(p_msg in varchar2, p_eof in boolean default false) is
  begin
    if p_eof = true then
      dbms_output.put_line(p_msg);
    else
      dbms_output.put(p_msg);
    end if;
  end;
  --
  procedure execute_immediate(p_owner in varchar2 default g_owner,
                              p_type  in varchar2 default 'table',
                              p_name  in varchar2,
                              p_body  in varchar2,
                              p_operation in varchar2 default 'create') is
    l_object_exists_exc exception;
    pragma exception_init(l_object_exists_exc, -955);
    l_element_exists_exc exception;
    pragma exception_init(l_element_exists_exc, -1430);
  begin
    plog(p_operation||' '||p_type||' '||p_name||' ... ');
    execute immediate p_operation||' '||p_type||' '||p_owner||'.'||p_name||' '||p_body;
    plog('Ok',true);
  exception
    when l_object_exists_exc then
      plog('exist',true);
    when l_element_exists_exc then
      plog('exist',true);
    when others then
      plog('error: '||sqlerrm, true);
      raise;
  end;
  --
begin
  dbms_output.enable(100000);
  --
  execute_immediate(p_type  => 'sequence',
                    p_name  => 'xxdoo_html_seq',
                    p_body  => ' start with 1 
                                 nocache');
  --
  execute_immediate(p_type  => 'table',
                    p_name  => 'xxdoo_html_log_t',
                    p_body  => '(msg varchar2(3000),
                                 creation_date date)');
  --
end;
/