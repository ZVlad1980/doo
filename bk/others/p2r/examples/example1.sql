-- Create and re-use parser
declare
  parser      xxdoo_p2r_parser;
  content     xxdoo_p2r_set;
  start_time  timestamp;  
begin
  start_time := current_timestamp;
  -- --------------------------------------------------------------------------
  dbms_output.put_line('----------------- EXAMPLE 1 -----------------');
  -- use parser..
  parser := new xxdoo_p2r_parser('/:filter/:entry(\d)/:state/:other*');
  content := parser.parse('/deal/1/ok/to/this/path');
  for i in 1..content.count loop
    dbms_output.put_line('KEY ="' || content(i).key || '", value = "' || content(i).value || '"');
  end loop;
  -- --------------------------------------------------------------------------
  dbms_output.put_line('----------------- EXAMPLE 2 -----------------');
  -- re-use parser 
  content := parser.parse('/deal/2/draft/to/this/path');
  for i in 1..content.count loop
    dbms_output.put_line('KEY ="' || content(i).key || '", value = "' || content(i).value || '"');
  end loop;
  -- --------------------------------------------------------------------------
  dbms_output.put_line('----------------- EXAMPLE 3 -----------------');
  -- Make static parser + valueOf
  parser:= new xxdoo_p2r_parser('/:filter/:entry(\d)/:state/:other*','/deal/2/draft/to/this/path');
  dbms_output.put_line('value of "filter" = "' || parser.valueOf('filter') || '"');
  dbms_output.put_line('value of "entry" = "' || parser.valueOf('entry') || '"');  
  dbms_output.put_line('value of "not_exists" = "' || parser.valueOf('not_exists') || '"');  
  -- --------------------------------------------------------------------------
  dbms_output.put_line('----------------- EXAMPLE 4 -----------------');
  -- Iterator
  declare
    l_key   varchar2(1024);
    l_value varchar2(1024);
  begin
    parser.first;
    while parser.next(l_key,l_value) loop
      dbms_output.put_line('KEY ="' || l_key || '", value = "' || l_value || '"');
    end loop;
  end;
  -- --------------------------------------------------------------------------
  dbms_output.put_line('---------------------------------------------');
  dbms_output.put_line('Totall processing time = ' || regexp_substr(to_char(current_timestamp - start_time),'[^ ]+',1,2));
end;
/  
