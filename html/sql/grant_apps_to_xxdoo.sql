declare
  procedure process_grant(p_object_name in varchar2,
                          p_grant_type in varchar2 default 'execute',
                          p_with  in varchar2 default null) is
  begin
    execute immediate 'grant '||p_grant_type||' on apps.'||p_object_name||' to xxdoo ' || p_with;
  exception
    when others then
      dbms_output.put_line('Error grant '||p_grant_type||' on apps.'||p_object_name||' to xxdoo : ' || sqlerrm);
  end;
begin
  process_grant('fnd_date');
  process_grant('fnd_api');
  --process_grant('fnd_profile');
  process_grant('fnd_profile_options','select');
  process_grant('fnd_profile_option_values','select');
  --process_grant('','select');
  --process_grant('','select');
  --process_grant('','select');
  
end;
/
