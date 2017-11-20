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
    if parser.parse(p_path).count > 0 then
      parser.first;
      while parser.next(key,value) loop
        dbms_output.put_line('KEY ="' || key || '", value = "' || value || '"');
      end loop;
    else
      dbms_output.put_line('Not matched');
    end if;
      dbms_output.put_line('');
  end;
begin
  start_time := current_timestamp;
  dbms_output.put_line('----------------- EXAMPLE 1 -----------------');
  parser := new xxdoo_p2r_parser('/:filter/:entry(\d+)?/:state(\w+)?/');
  parseAndDisplay('/all');
  parseAndDisplay('/all/12/edit');
  parseAndDisplay('/all/new');
  parseAndDisplay('/all/12');
  dbms_output.put_line('----------------- EXAMPLE 2 -----------------');
  parser := new xxdoo_p2r_parser('/:filter/:entry(\d+)/invoices/:invoice(\d+)? ');
  parseAndDisplay('/all/12/invoices/4');
  parseAndDisplay('/all/12/invoices');
  parseAndDisplay('/all/12/4');
  parseAndDisplay('/all/invoizes/3');  
  dbms_output.put_line('Totall processing time = ' || regexp_substr(to_char(current_timestamp - start_time),'[^ ]+',1,2));
end;
/  
