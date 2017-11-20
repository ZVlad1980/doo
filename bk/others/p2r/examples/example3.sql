-- Create and re-use parser
declare
  parser      xxdoo_p2r_parser;
  key         varchar2(1024);
  value       varchar2(1024);
  start_time  timestamp;  
  procedure parseAndDisplay(p_path in varchar2) is
  begin
    dbms_output.put_line('----------------------------------');
    dbms_output.put_line(p_path);
    dbms_output.put_line('----------------------------------');
    parser.parse(p_path);
    parser.first;
    while parser.next(key,value) loop
      dbms_output.put_line('KEY ="' || key || '", value = "' || value || '"');
    end loop;
    dbms_output.put_line('');
  end;
begin
  start_time := current_timestamp;
  dbms_output.put_line('----------------- EXAMPLE 1 -----------------');
  parser := new xxdoo_p2r_parser('/:filter/:entry(\d+)?/:state(\w+)?/');
  parseAndDisplay('/all/new/12');
  parseAndDisplay('/all/new');
  dbms_output.put_line('Totall processing time = ' || regexp_substr(to_char(current_timestamp - start_time),'[^ ]+',1,2));
end;
/  
