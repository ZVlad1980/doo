declare
  parsers xxdoo_p2r_query;
  parser  xxdoo_p2r_parser;
  l_name  varchar2(1024);
  procedure displayParsed is
    key     varchar2(1024);
    value   varchar2(1024);
  begin
    dbms_output.put_line('----------------------------------');
    dbms_output.put_line('NAME = [' || l_name || ']');
    dbms_output.put_line('----------------------------------');
    parser.first;
    while parser.next(key,value) loop
      dbms_output.put_line('KEY ="' || key || '", value = "' || value || '"');
    end loop;
    dbms_output.put_line('');
  end;
begin
  parsers := new xxdoo_p2r_query('
       NewDocument=/:filter/new/:name
       QueryDocument=/:filter/query/:id?
  ');
  --
  parser := parsers.query('/all/new/Sergey',l_name);
  displayParsed;
  --
  parser := parsers.query('/all/query/5',l_name);
  displayParsed;
end;  