create or replace package body xxweb_api_json_pkg as
  /******************************************************************************
  NAME:       JSON
  PURPOSE:    Output in JSON format (http://www.json.org) for oracle
          Javascript Simple Object Notation
        
        /!\ the values are encoded according to JSON specifications language.
        Passing an heaxdecimal value in a string must be done with 
        the following syntax :
        
        'someString...someString...#hex[four hexa digits] ... someString...'
  
  REVISIONS:
  Ver        Date        Author  Description
  ---------  ----------  ------  ---------------------------------------------
  0.1        03/07/2007  PGL     Created this package body.
  1.0        03/12/2007  PGL     Add basic object validation.
  1.1        11/03/2008  PGL     - Add some stuff to prevent from javascript 
                       Hijacking, prototype framework compatible : 
                 /*-secure-\n{...json object...}\n*/ /*
                  - Add procedure to send appropriate mime type 
                    for Web output "application/json"
                  - printing enhancement.
                  - suppress global variable g_output_type.
                  - bug corrections in String2Json func.
                  - Add procedure to stream out the json object
                  - Suppress indentation for better perf on
                    long json objects.
                  - Refactor terms to match on the english terms
                  - bug correction in getAttrValue, add param
                    pOutPutStringDelimiter and pOutPutSeparator
                  that allow to format the output of the 
                  function.
                  - Add function getAttrArray that return an
                    array of values in an plsql array of varchar2
                  - Add Array2String utility.
                  - Add License informations 
                  
******************************************************************************

/******************************************************************************
        This program is published under the GNU LGPL License 
                http://www.gnu.org/licenses/lgpl.html
*******************************************************************************
 This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
********************************************************************************

******************************************************************************
-- TODO
       - Implement a complete function validatejsonobj that parses the object
       and verify its structure.
     - Implement correctly indentation.
     
******************************************************************************/
  --------------------------------------------------------------------------------
  -- Internal Types and records
  --------------------------------------------------------------------------------
  -- type for special char table
  type specialcharreplace is record(
    pattern  varchar(4),
    changeto varchar2(2));
  type specialchar is table of specialcharreplace index by binary_integer;

  --------------------------------------------------------------------------------
  -- Internal variables and constants
  --------------------------------------------------------------------------------
  tspcchr specialchar;

  x_type_no_defined exception;
  msg_type_no_defined constant varchar2(255) := 'Type of item "%1" not supported in this package.';
  x_invalid_object exception;
  msg_invalid_object constant varchar2(255) := 'Invalid JSON object. Check syntax at item #%1...';

  --g_doindetation boolean := false; -- true for doing indentation

  g_secure boolean := false; -- true for securing object by adding javascript comments
  -- prevent form javascript hijacking.

  nullobj jsonstructobj; -- Null JSONObject : never intialized.

  --------------------------------------------------------------------------------
  -- Internal Procedures and functions
  --------------------------------------------------------------------------------

  /*
  procedure my_customized_print(p_str varchar2) is
  begin
     -- this my customized output comment these line above to put your's.
     affiche.p(p_str);
     
     -- dbms_output.put_line(p_str);
     htp.p(p_str);
     
     -- end of customization.
  end my_customized_print;
  */
  --------------------------------------------------------------------------------
  -- Procedure that can be customize to print the JSON result string 
  -- in a table, in a file, ont the web with your own procedure, with dbms_output,
  -- WRITE YOUR OWN CUSTOM OUTPUT HERE
  --------------------------------------------------------------------------------
  procedure print(p_str varchar2) is
  begin
    -- this my customized output comment these line above to put your's.
    --htp.print(p_str);
     dbms_output.put_line(p_str);
    -- end of customization.
  end print;

  --------------------------------------------------------------------------------
  -- Procedure that sends the appropriate maime type for web output.
  --------------------------------------------------------------------------------
  procedure sendjsonmime is
  begin
    print('application/json');
  end sendjsonmime;

  --------------------------------------------------------------------------------
  -- Procedure that streams the Json Structure to ouput.
  --------------------------------------------------------------------------------
  procedure streamoutput(pobj jsonstructobj) is
    i number;
  begin
    i := pobj.first;
    while (i is not null) loop
      print(pobj(i).item);
      i := pobj.next(i);
    end loop;
  end streamoutput;

  --------------------------------------------------------------------------------
  -- set the right number of spaces to indent JSON object correctly.
  --------------------------------------------------------------------------------
  -- procedure indent(p_what varchar2 default '+') is
  -- begin
  --   if (g_doindetation) then 
  --    if (p_what = '+') then
  --      g_indent := g_indent || g_spc;
  --    else 
  --      g_indent := substr(g_indent, - length(g_spc));
  --    end if;
  --   end if;
  -- end indent;

  --------------------------------------------------------------------------------
  -- returns a boolean converted in a string: true => 'true', false => 'false'
  --------------------------------------------------------------------------------
  function bool2str(boolean_in in boolean) return varchar2 is
  begin
    if (boolean_in) then
      return 'true';
    end if;
    return 'false';
  end bool2str;

  --------------------------------------------------------------------------------
  -- returns true if the string can be converted to a number
  --------------------------------------------------------------------------------
  function isnumber(p_str varchar2 default null) return boolean is
    n number;
  begin
    n := to_number(p_str);
    return true;
  exception
    when others then
      return false;
  end isnumber;

  --------------------------------------------------------------------------------
  -- returns the deencoded string according to JSON encoding specification
  --------------------------------------------------------------------------------
  function decodevalue(p_str varchar2 default null) return varchar2 is
    my_str varchar2(2000) := p_str;
    i      pls_integer;
  begin
    i := tspcchr.first;
    while (i is not null) loop
      -- formating according to JSON specs.
      my_str := replace(my_str,
                        tspcchr(i).changeto,
                        tspcchr(i).pattern);
      i      := tspcchr.next(i);
    end loop;
    -- removing the string delimiter
    if (substr(my_str,
               1,
               1) = g_stringdelimiter) then
      my_str := substr(my_str,
                       2);
    end if;
    if (substr(my_str,
               -1) = g_stringdelimiter) then
      my_str := substr(my_str,
                       1,
                       length(my_str) - 1);
    end if;
    return my_str;
  end decodevalue;

  --------------------------------------------------------------------------------
  -- returns the encoded string according to JSON specification langage
  --------------------------------------------------------------------------------
  function formatvalue(p_str varchar2 default null) return varchar2 is
    my_str varchar2(2000) := p_str;
    i      pls_integer;
  begin
    -- if the string is null we have to put ''.
    if (my_str is null) then
      my_str := '''''';
    elsif (lower(my_str) in ('true',
                             'false')) then
      -- format a boolean without quote.
      my_str := my_str;
    elsif (not isnumber(my_str)) then
      -- format a string
      i := tspcchr.first;
      while (i is not null) loop
        -- formating according to JSON specs.
        my_str := replace(my_str,
                          tspcchr(i).pattern,
                          tspcchr(i).changeto);
        i      := tspcchr.next(i);
      end loop;
      -- adding the string delimiter
      my_str := g_stringdelimiter || my_str || g_stringdelimiter;
    else
      -- format a number
      my_str := replace(my_str,
                        ',',
                        '.');
    end if;
    return my_str;
  end formatvalue;

  --------------------------------------------------------------------------------
  -- Returns a JSON Item for our JSON structure 
  --------------------------------------------------------------------------------
  function additem(p_type     varchar2,
                   p_item     varchar2,
                   p_formated boolean default false) return jsonitem is
    my_item jsonitem;
  begin
    -- structure controls
    if (p_type not in ('OPENBRACE',
                       'OPENBRACKET',
                       'CLOSEBRACE',
                       'CLOSEBRACKET',
                       'SEPARATION',
                       'AFFECTATION',
                       'ATTRNAME',
                       'ATTRDATA',
                       'ARRAYDATA',
                       'INDENTATION')) then
      raise x_type_no_defined;
    end if;
    my_item.type     := p_type;
    my_item.item     := p_item;
    my_item.formated := p_formated;
    return my_item;
  exception
    when x_type_no_defined then
      print(replace(msg_type_no_defined,
                    '%1',
                    p_type));
      return null;
  end additem;

  --------------------------------------------------------------------------------
  -- opens object
  --------------------------------------------------------------------------------
  function openobj return jsonitem is
  begin
    --  indent('+');
    return additem('OPENBRACE',
                   g_cr || g_openbrace);
  end openobj;

  --------------------------------------------------------------------------------
  -- Closes object
  --------------------------------------------------------------------------------
  function closeobj return jsonitem is
  begin
    --  indent('-');
    -- dealing with indentation
    --  if (g_doindetation) then
    --     return addItem('CLOSEBRACE', g_CR || g_closeBrace);
    --  end if;
    return additem('CLOSEBRACE',
                   g_closebrace);
  end closeobj;

  --------------------------------------------------------------------------------
  -- opens array
  --------------------------------------------------------------------------------
  function openarray return jsonitem is
  begin
    return additem('OPENBRACKET',
                   g_openbracket);
  end openarray;

  --------------------------------------------------------------------------------
  -- Closes array
  --------------------------------------------------------------------------------
  function closearray return jsonitem is
  begin
    return additem('CLOSEBRACKET',
                   g_closebracket);
  end closearray;

  --------------------------------------------------------------------------------
  -- Inits special char table for coding and decoding value.
  --------------------------------------------------------------------------------
  procedure initspecchartable is
  begin
    tspcchr(1).pattern := '\';
    tspcchr(2).pattern := '/';
    tspcchr(3).pattern := g_stringdelimiter;
    tspcchr(4).pattern := chr(8); -- backspace
    tspcchr(5).pattern := chr(12); -- form feed
    tspcchr(6).pattern := chr(10); -- new line
    tspcchr(7).pattern := chr(13); -- carriage return
    tspcchr(8).pattern := chr(9); -- tablulation
    tspcchr(9).pattern := '#hex'; -- four hexadecimal digit
    --
    tspcchr(1).changeto := '\\';
    tspcchr(2).changeto := '\/';
    tspcchr(3).changeto := '\' || g_stringdelimiter;
    tspcchr(4).changeto := '\b'; -- backspace
    tspcchr(5).changeto := '\f'; -- form feed
    tspcchr(6).changeto := '\n'; -- new line
    tspcchr(7).changeto := '\r'; -- carriage return
    tspcchr(8).changeto := '\t'; -- tablulation
    tspcchr(9).changeto := '\u'; -- four hexadecimal digit
  end initspecchartable;

  --------------------------------------------------------------------------------
  -- Inits package environment.
  --------------------------------------------------------------------------------
  procedure newjsonobj(p_obj          in out nocopy jsonstructobj,
                       p_doindetation boolean default true,
                       p_secure       boolean default false) is
    i pls_integer := 1;
  begin
    -- init special char table
    initspecchartable;
    -- init json object.
    p_obj.delete;
    --   if (p_doindetation) then
    --      g_doindetation := true;
    --    p_obj(1) := addItem('INDENTATION', g_indent);
    --    i := 2;
    --      else
    --     g_doindetation := false;
    --   end if;
    if (p_secure) then
      g_secure := true;
    end if;
    p_obj(i) := openobj();
  end newjsonobj;

  --------------------------------------------------------------------------------
  -- Returns the first item where the problem is, else return 0
  --------------------------------------------------------------------------------
  function validatejsonobj(p_obj     in out nocopy jsonstructobj,
                           pvalidate boolean default false) return pls_integer is
    i               pls_integer;
    isbracketopened boolean := false;
    isbracketopened boolean := false;
    x_invalid_structure exception;
    idxelmterr pls_integer := 0;
    ------------------------------------------------------------------------
    -- Returns 0 if syntax {...} is correct, else returns the last incorrect 
    -- element.
    ------------------------------------------------------------------------
    function validatestructure(p_elmt_type varchar2 default 'BRACE') return number is
      cntopndbrcks pls_integer := 0;
      x_counter_not_0 exception;
    begin
      i := p_obj.first;
      while (i is not null) loop
        case p_obj(i).type
          when 'OPEN' || p_elmt_type then
            cntopndbrcks := cntopndbrcks + 1;
          when 'CLOSE' || p_elmt_type then
            cntopndbrcks := cntopndbrcks - 1;
          else
            null;
        end case;
        -- if the counter count down under 0 => structure problem : 
        -- object is already close whether the structure isn't parsed at all.
        if (cntopndbrcks < 0) then
          raise x_counter_not_0;
        end if;
        i := p_obj.next(i);
      end loop;
      -- if the counter is upper than 0 => structure problem : 
      -- one or more brackets still opened. 
      if (cntopndbrcks > 0) then
        -- when we are here, i is null so initializing i = p_obj.count.
        i := p_obj.count;
        raise x_counter_not_0;
      end if;
      return 0;
    exception
      when x_counter_not_0 then
        return i;
    end validatestructure;
    ------------------------------------------------------------------------
  begin
    -- see if formatting have to be done 
    i := p_obj.first;
    while (i is not null) loop
      if (not p_obj(i).formated and p_obj(i).type in ('ATTRNAME',
                                                      'ATTRDATA',
                                                      'ARRAYDATA')) then
        p_obj(i).item := formatvalue(p_obj(i).item);
        p_obj(i).formated := true;
      end if;
      i := p_obj.next(i);
    end loop;
  
    --
    -- General Validation : counting and comparing opened and closed brackets and brackets.
    --
    if (pvalidate) then
      idxelmterr := validatestructure('BRACE');
      if (idxelmterr != 0) then
        raise x_invalid_structure;
      end if;
      idxelmterr := validatestructure('BRACKET');
      if (idxelmterr != 0) then
        raise x_invalid_structure;
      end if;
      --
    end if;
    return 0;
  exception
    when x_invalid_structure then
      return idxelmterr;
  end validatejsonobj;

  --------------------------------------------------------------------------------
  -- Closes the JSON Object
  --------------------------------------------------------------------------------
  procedure closejsonobj(p_obj in out nocopy jsonstructobj) is
    i      pls_integer;
    status pls_integer;
  begin
    -- adding closing bracket
    p_obj(p_obj.last + 1) := closeobj;
    -- when closing object, removing trailing ','
    i := p_obj.last;
    while (i is not null) loop
      if (p_obj(i).type = 'SEPARATION') then
        -- if the futher item of the list is not in these type ('ATTRNAME', 'ATTRDATA', 'ARRAYDATA')
        -- we have to trash the comma.
        if (p_obj.exists(p_obj.next(i)) and p_obj(p_obj.next(i))
           .type not in ('ATTRNAME',
                         'ATTRDATA',
                         'ARRAYDATA')) then
          p_obj.delete(i);
          exit;
        end if;
      end if;
      i := p_obj.prior(i);
    end loop;
    status := validatejsonobj(p_obj);
    if (status != 0) then
      raise x_invalid_object;
    end if;
  exception
    when x_invalid_object then
      print(replace(msg_invalid_object,
                    '%1',
                    status));
  end closejsonobj;

  --------------------------------------------------------------------------------
  -- modify a JSON object to remove indentation elements
  --------------------------------------------------------------------------------
  function removeindent(p_obj jsonstructobj) return jsonstructobj is
    my_obj jsonstructobj := p_obj;
    i      pls_integer;
  begin
    i := my_obj.first;
    while (i is not null) loop
      if (my_obj(i).type = 'INDENTATION') then
        my_obj.delete(i);
      end if;
      i := my_obj.next(i);
    end loop;
    return my_obj;
  end removeindent;

  --------------------------------------------------------------------------------
  -- Returns a the values of an array in varchar2 type from the JSON Structure
  --------------------------------------------------------------------------------
  function getcomplexvalue(p_obj           jsonstructobj,
                           pidx            pls_integer,
                           p_arrayorobject varchar2 default 'ARRAY') return varchar2 is
    my_obj               jsonstructobj := p_obj;
    ln_count_openbracket pls_integer := 1;
    my_value             varchar2(32000);
    j                    pls_integer := pidx;
    lv_what              varchar2(10);
  begin
    -- see what we are attempting to retrieve...
    if (p_arrayorobject = 'ARRAY') then
      lv_what := 'BRACKET';
    else
      lv_what := 'BRACE';
    end if;
    --
    while (j is not null) loop
      if (my_obj(j).type = 'OPEN' || lv_what) then
        ln_count_openbracket := ln_count_openbracket + 1;
      elsif (my_obj(j).type = 'CLOSE' || lv_what) then
        ln_count_openbracket := ln_count_openbracket - 1;
      end if;
      my_value := my_value || my_obj(j).item;
      if (ln_count_openbracket = 0) then
        my_value := substr(my_value,
                           1,
                           length(my_value) - 1);
        exit;
      end if;
      j := my_obj.next(j);
    end loop;
    return my_value;
  exception
    when others then
      return null;
  end getcomplexvalue;

  --------------------------------------------------------------------------------
  -- Returns a the values of an array in JSONArray type from the JSON Structure
  --------------------------------------------------------------------------------
  function getcomplexvalueasarray(p_obj           jsonstructobj,
                                  pidx            pls_integer,
                                  p_arrayorobject varchar2 default 'ARRAY') return jsonarray is
    my_obj               jsonstructobj := p_obj;
    ln_count_openbracket pls_integer := 1;
    my_value             jsonarray;
    blank_tab            jsonarray;
    i                    number := 1; -- index of the array of values which are extracted from jsonStruct.
    j                    pls_integer := pidx;
    lv_what              varchar2(10);
  begin
    -- see what we are attempting to retrieve : object or Array ?
    if (p_arrayorobject = 'ARRAY') then
      -- Array
      lv_what := 'BRACKET';
    else
      -- object
      lv_what := 'BRACE';
    end if;
    --
    while (j is not null) loop
      if (my_obj(j).type = 'OPEN' || lv_what) then
        ln_count_openbracket := ln_count_openbracket + 1;
      elsif (my_obj(j).type = 'CLOSE' || lv_what) then
        ln_count_openbracket := ln_count_openbracket - 1;
      end if;
      -- Retrieving only the data
      if (my_obj(j).type = 'ARRAYDATA') then
        -- removing the string delimiter
        my_value(i) := replace(my_obj(j).item,
                               g_stringdelimiter,
                               null);
        i := i + 1;
      end if;
      if (ln_count_openbracket = 0) then
        exit;
      end if;
      j := my_obj.next(j);
    end loop;
    return my_value;
  exception
    when others then
      return blank_tab;
  end getcomplexvalueasarray;

  --------------------------------------------------------------------------------
  -- Set a value to an attribut
  --------------------------------------------------------------------------------
  function setattrsimplevalue(p_obj     jsonstructobj,
                              pname     varchar2,
                              pvalue    varchar2,
                              pformated boolean default false) return jsonstructobj is
    my_obj      jsonstructobj := p_obj;
    i           pls_integer;
    j           pls_integer;
    value_found boolean := false;
  begin
    i := my_obj.first;
    while (i is not null) loop
      if (lower(my_obj(i).item) = g_stringdelimiter || lower(pname) || g_stringdelimiter and my_obj(i).type = 'ATTRNAME') then
        -- the arrtibute exists.
        j := my_obj.next(i);
        while (j is not null) loop
          if (my_obj(j).type = 'ATTRDATA') then
            -- we have found the value to be replaced
            if (pformated) then
              my_obj(j).item := pvalue;
            else
              my_obj(j).item := formatvalue(pvalue);
            end if;
            my_obj(j).formated := not pformated;
            -- exiting this loop;
            value_found := true;
            exit;
          end if;
          j := my_obj.next(j);
        end loop;
      end if;
      if (value_found) then
        exit;
      end if;
      i := my_obj.next(i);
    end loop;
    return my_obj;
  end setattrsimplevalue;

  --------------------------------------------------------------------------------
  -- Set a value to an attribut
  --------------------------------------------------------------------------------
  function setattrsimplevalue(p_obj     jsonstructobj,
                              pname     varchar2,
                              pbool     boolean,
                              pformated boolean default false) return jsonstructobj is
    val varchar2(10) := bool2str(pbool);
  begin
    return setattrsimplevalue(p_obj,
                              pname,
                              val,
                              pformated);
  end setattrsimplevalue;

  --------------------------------------------------------------------------------
  -- Returns an array of value of an attribute.
  --------------------------------------------------------------------------------
  function getattrarray(p_obj   jsonstructobj,
                        pname   varchar2,
                        pdecode boolean default true) return jsonarray is
    blank_tab jsonarray; -- null array used for exceptions
    my_obj    jsonstructobj := p_obj;
    i         pls_integer;
    -----------------------------------------------------------------
    function returnvalue(pidx pls_integer,
                         pdec boolean default true) return jsonarray is
      j             pls_integer := pidx;
      firstnextval  pls_integer := my_obj.next(j);
      secondnextval pls_integer := my_obj.next(firstnextval);
      thirdnextval  pls_integer := my_obj.next(secondnextval);
      -- due to removing INDENTATION, the index may not be 2,3,4,5... but 2,4,5,8,...
      -- so we can't access to the structure with j, j+1, j+2,... 
      -- We'd better access by j, my_obj.next(j), my_obj.next(my_obj.next(j)), ...
      my_tab_value jsonarray;
    begin
      if (my_obj(j).type = 'ATTRNAME') then
        if (my_obj(secondnextval).type = 'OPENBRACKET') then
          -- This is a table
          -- from ThirdNextVal to first closing bracket for this level [...[...]...], extracting array values
          my_tab_value := getcomplexvalueasarray(my_obj,
                                                 thirdnextval,
                                                 'ARRAY');
        elsif (my_obj(secondnextval).type = 'OPENBRACE') then
          -- This is an object
          -- from ThirdNextVal to first closing bracket for this level {...{...}...}, extracting object values
          my_tab_value := getcomplexvalueasarray(my_obj,
                                                 thirdnextval,
                                                 'OBJECT');
        end if;
        return my_tab_value;
      else
        -- not an ATTRNAME returning a null array
        return blank_tab;
      end if;
    exception
      when others then
        return blank_tab;
    end returnvalue;
    ----------------------------------------------------------------
  begin
    -- remove indentation
    my_obj := removeindent(my_obj);
    i      := my_obj.first;
    while (i is not null) loop
      if (upper(my_obj(i).item) = upper(g_stringdelimiter || replace(pname,
                                                                     g_stringdelimiter,
                                                                     null) || g_stringdelimiter)) then
        return returnvalue(i,
                           pdecode);
      end if;
      i := my_obj.next(i);
    end loop;
    -- if we go here, the value for pname doesn't exist in p_obj, returning a null array.
    return blank_tab;
  exception
    when no_data_found then
      return blank_tab;
  end getattrarray;

  --------------------------------------------------------------------------------
  -- Returns the value of an attribut. This can be an simple value or an array
  --------------------------------------------------------------------------------
  function getattrvalue(p_obj               jsonstructobj,
                        pname               varchar2,
                        pdecode             boolean default true,
                        poutputstrdelimiter varchar2 default g_stringdelimiter,
                        poutputseparator    varchar2 default replace(g_separation,
                                                                     ' ',
                                                                     null)) return varchar2 is
    my_obj jsonstructobj := p_obj;
    i      pls_integer;
    -----------------------------------------------------------------
    function returnvalue(pidx pls_integer,
                         pdec boolean default true) return varchar2 is
      j             pls_integer := pidx;
      firstnextval  pls_integer := my_obj.next(j);
      secondnextval pls_integer := my_obj.next(firstnextval);
      thirdnextval  pls_integer := my_obj.next(secondnextval);
      -- due to removing INDENTATION, the index may not be 2,3,4,5... but 2,4,5,8,...
      -- so we can't access to the structure with j, j+1, j+2,... 
      -- We'd better access by j, my_obj.next(j), my_obj.next(my_obj.next(j)), ...
      my_tab_value varchar2(32000);
    begin
      if (my_obj(j).type = 'ATTRNAME') then
        -- see if the value is a table, an object or a simple value.
        if (my_obj(secondnextval).type = 'ATTRDATA') then
          -- this is a simple attribut
          if (pdec) then
            initspecchartable;
            my_tab_value := decodevalue(my_obj(secondnextval).item);
          else
            my_tab_value := my_obj(secondnextval).item;
          end if;
        elsif (my_obj(secondnextval).type = 'OPENBRACKET') then
          -- This is a table
          -- from ThirdNextVal to first closing bracket for this level [...[...]...], extracting array values
          my_tab_value := getcomplexvalue(my_obj,
                                          thirdnextval,
                                          'ARRAY');
        elsif (my_obj(secondnextval).type = 'OPENBRACE') then
          -- This is an object
          -- from ThirdNextVal to first closing bracket for this level {...{...}...}, extracting object values
          my_tab_value := getcomplexvalue(my_obj,
                                          thirdnextval,
                                          'OBJECT');
        end if;
        -- see if custom separator and delimiter have been passed : formating return value.
        -- for example if we received pOutputStrDelimiter= ' and  pOutPutSeparator= | 
        -- we replace "," by '|'.
        my_tab_value := replace(replace(my_tab_value,
                                        g_stringdelimiter,
                                        poutputstrdelimiter),
                                poutputstrdelimiter || replace(g_separation,
                                                               ' ',
                                                               null) || poutputstrdelimiter,
                                poutputstrdelimiter || poutputseparator || poutputstrdelimiter);
        return my_tab_value;
      else
        -- not an ATTRNAME returning null
        return null;
      end if;
    exception
      when others then
        return null;
    end returnvalue;
    ----------------------------------------------------------------
  begin
    -- remove indentation
    my_obj := removeindent(my_obj);
    i      := my_obj.first;
    while (i is not null) loop
      if (upper(my_obj(i).item) = upper(g_stringdelimiter || replace(pname,
                                                                     g_stringdelimiter,
                                                                     null) || g_stringdelimiter)) then
        return returnvalue(i,
                           pdecode);
      end if;
      i := my_obj.next(i);
    end loop;
    -- if we go here, the value for pname doesn't exist in p_obj.
    return null;
  exception
    when no_data_found then
      return null;
  end getattrvalue;

  --------------------------------------------------------------------------------
  -- Returns a JSON object with a varchar2 value
  --------------------------------------------------------------------------------
  function addattr(p_obj      jsonstructobj,
                   n          varchar2,
                   v          varchar2,
                   p_formated boolean default false) return jsonstructobj is
    my_obj jsonstructobj := p_obj;
  begin
    --  if (g_doindetation) then
    --     my_obj(my_obj.last+1) := addItem('INDENTATION', g_CR || g_indent);
    --  end if;
    my_obj(my_obj.last + 1) := additem('ATTRNAME',
                                       n);
    my_obj(my_obj.last + 1) := additem('AFFECTATION',
                                       g_affectation);
    my_obj(my_obj.last + 1) := additem('ATTRDATA',
                                       v,
                                       p_formated);
    my_obj(my_obj.last + 1) := additem('SEPARATION',
                                       g_separation);
    return my_obj;
  end addattr;

  --------------------------------------------------------------------------------
  -- Returns a JSON object with a boolean value
  --------------------------------------------------------------------------------
  function addattr(p_obj      jsonstructobj,
                   n          varchar2,
                   pbool      boolean,
                   p_formated boolean default false) return jsonstructobj is
    val varchar2(10) := bool2str(pbool);
  begin
    return addattr(p_obj,
                   n,
                   val,
                   p_formated);
  end addattr;

  --------------------------------------------------------------------------------
  -- Returns a JSON object : The value could be an object
  --------------------------------------------------------------------------------
  function addattr(p_obj      jsonstructobj,
                   n          varchar2,
                   p_objvalue jsonstructobj) return jsonstructobj is
    my_obj jsonstructobj := p_obj;
    i      pls_integer;
  begin
    --  if (g_doindetation) then
    --     my_obj(my_obj.last+1) := addItem('INDENTATION', g_CR || g_indent);
    --  end if;
    my_obj(my_obj.last + 1) := additem('ATTRNAME',
                                       n);
    my_obj(my_obj.last + 1) := additem('AFFECTATION',
                                       g_affectation);
    i := p_objvalue.first;
    while (i is not null) loop
      my_obj(my_obj.last + 1) := additem(p_objvalue(i).type,
                                         p_objvalue(i).item,
                                         p_objvalue(i).formated);
      i := p_objvalue.next(i);
    end loop;
    my_obj(my_obj.last + 1) := additem('SEPARATION',
                                       g_separation);
    return my_obj;
  end addattr;

  --------------------------------------------------------------------------------
  -- Returns a JSON array of a plsql table (JSONArray type)
  --------------------------------------------------------------------------------
  function addarray(p_obj      jsonstructobj,
                    p_table    jsonarray,
                    p_formated boolean default false) return jsonstructobj is
    my_obj jsonstructobj := p_obj;
    i      pls_integer;
    j      pls_integer;
  begin
    j := my_obj.first;
    -- if no object has been passed, that because the array is embeded
    if (j is null) then
      j := 1;
    else
      j := my_obj.last + 1;
    end if;
    --
    --my_obj(j) := addItem('INDENTATION', g_CR || g_indent);
    my_obj(j) := openarray;
    i := p_table.first;
    j := my_obj.last + 1;
    while (i is not null) loop
      if (i != p_table.first) then
        my_obj(j) := additem('SEPARATION',
                             g_separation);
        j := j + 1;
      end if;
      my_obj(j) := additem('ARRAYDATA',
                           p_table(i),
                           p_formated);
      j := j + 1;
      i := p_table.next(i);
    end loop;
    my_obj(my_obj.last + 1) := closearray;
    return my_obj;
  end addarray;

  --------------------------------------------------------------------------------
  -- Returns a JSON array 
  --------------------------------------------------------------------------------
  function addarray(p_tab    jsonarray,
                    p_format boolean default false) return jsonstructobj is
  begin
    return addarray(p_obj      => nullobj,
                    p_table    => p_tab,
                    p_formated => p_format);
  end addarray;

  --------------------------------------------------------------------------------
  -- Returns the JSON array into a string
  --------------------------------------------------------------------------------
  function array2string(p_tab jsonarray) return varchar2 is
    i        pls_integer;
    mystrobj varchar2(32000);
  begin
    -- fetching all the table
    i := p_tab.first;
    while (i is not null) loop
      mystrobj := mystrobj || p_tab(i);
      i        := p_tab.next(i);
    end loop;
    return mystrobj;
  end array2string;

  --------------------------------------------------------------------------------
  -- Returns the JSON object into a string
  --------------------------------------------------------------------------------
  function json2string(p_obj           in out nocopy jsonstructobj,
                       p_only_an_array boolean default false) return varchar2 is
    i        pls_integer;
    mystrobj varchar2(32000);
  begin
    if (p_only_an_array) then
      -- the object only contains an array so remove { and }.
      i := p_obj.first;
      while (i is not null) loop
        if (p_obj(i).type = 'OPENBRACE') then
          p_obj.delete(i);
          exit;
        end if;
        i := p_obj.next(i);
      end loop;
      --
      i := p_obj.last;
      while (i is not null) loop
        if (p_obj(i).type = 'CLOSEBRACE') then
          p_obj.delete(i);
          exit;
        end if;
        i := p_obj.prior(i);
      end loop;
    end if;
    -- fetching all the object
    i := p_obj.first;
    while (i is not null) loop
      mystrobj := mystrobj || p_obj(i).item;
      i        := p_obj.next(i);
    end loop;
    -- anti hijacking comments
    if (g_secure) then
      mystrobj := g_js_comment_open || mystrobj || g_js_comment_close;
    end if;
    return mystrobj;
  end json2string;

  --------------------------------------------------------------------------------
  -- Returns a JSON object with a string
  --------------------------------------------------------------------------------
  function string2json(p_str         varchar2,
                       pstrdelimiter varchar2 default g_stringdelimiter) return jsonstructobj is
    obj         jsonstructobj;
    tmpstr      varchar2(32000) := p_str;
    buf         varchar2(32000);
    i           pls_integer := 1;
    cutposition pls_integer := 1;
    my_tabtmp   jsonarray;
    x_bad_jsonstruct exception;
  
    haveseen_attrname boolean := false;
    we_are_in_a_table boolean := false;
    chrtmp            varchar2(1);
    typetmp           varchar2(20);
    itemtmp           varchar2(2000);
  begin
    -- defining string delimiter 
    g_stringdelimiter := pstrdelimiter;
  
    -- formatting the string 
    -- suppress CR
    tmpstr := replace(tmpstr,
                      g_cr,
                      ' ');
  
    -- Suppress anti-hijacking comments
    tmpstr := replace(tmpstr,
                      g_js_comment_open,
                      ' ');
    tmpstr := replace(tmpstr,
                      g_js_comment_close,
                      ' ');
  
    -- turning to null the spacing before and afters symbols 
    g_openbrace    := replace(g_openbrace,
                              ' ',
                              null);
    g_closebrace   := replace(g_closebrace,
                              ' ',
                              null);
    g_openbracket  := replace(g_openbracket,
                              ' ',
                              null);
    g_closebracket := replace(g_closebracket,
                              ' ',
                              null);
    g_affectation  := replace(g_affectation,
                              ' ',
                              null);
    g_separation   := replace(g_separation,
                              ' ',
                              null);
  
    -- suppress indentation, and non usefull spaces
    while (instr(tmpstr,
                 '  ') > 0) loop
      tmpstr := replace(tmpstr,
                        '  ',
                        ' ');
    end loop;
  
    -- replace backSlash + StringDelimiter with a sequence of easy identifiable characters 
    tmpstr := replace(tmpstr,
                      '\' || g_stringdelimiter,
                      '\§');
  
    -- placing the string into the jsonS tructure
    i := 1;
    --
    -- BUG : Seems to have an infinite loop when the json object is not correct ??
    --        that's why there is the condition : "and i < 1000"
    -- I have to correct that sucking bug...
    --
    while (length(tmpstr) > 0 and i < 1000) loop
      -- removing first spaces
      while (substr(tmpstr,
                    1,
                    1) = ' ') loop
        tmpstr := substr(tmpstr,
                         2,
                         length(tmpstr));
      end loop;
      -- now : it's ' or { or [
      chrtmp := substr(tmpstr,
                       1,
                       1);
      if (chrtmp = g_openbrace) then
        obj(i) := openobj;
        haveseen_attrname := false;
        tmpstr := substr(tmpstr,
                         2);
      
      elsif (chrtmp = g_openbracket) then
        obj(i) := openarray;
        we_are_in_a_table := true;
        tmpstr := substr(tmpstr,
                         2);
      
      elsif (chrtmp = g_closebrace) then
        obj(i) := closeobj;
        tmpstr := substr(tmpstr,
                         2);
      
      elsif (chrtmp = g_closebracket) then
        obj(i) := closearray;
        we_are_in_a_table := false;
        tmpstr := substr(tmpstr,
                         2);
      
      elsif (chrtmp = g_stringdelimiter) then
        if (haveseen_attrname or we_are_in_a_table) then
          if (haveseen_attrname) then
            typetmp           := 'ATTRDATA';
            haveseen_attrname := false;
          end if;
          if (we_are_in_a_table) then
            typetmp := 'ARRAYDATA';
          end if;
        else
          typetmp           := 'ATTRNAME';
          haveseen_attrname := true;
        end if;
        obj(i) := additem(typetmp,
                          substr(tmpstr,
                                 1,
                                 instr(tmpstr,
                                       g_stringdelimiter,
                                       2)),
                          true);
        tmpstr := substr(tmpstr,
                         instr(tmpstr,
                               g_stringdelimiter,
                               2) + 1);
      
      elsif (chrtmp = g_affectation) then
        obj(i) := additem('AFFECTATION',
                          g_affectation,
                          false);
        tmpstr := substr(tmpstr,
                         2);
      
      elsif (chrtmp = g_separation) then
        obj(i) := additem('SEPARATION',
                          g_separation,
                          false);
        tmpstr := substr(tmpstr,
                         2);
      
      else
        -- if the data is a number, there's no string delimiter
        if (haveseen_attrname or we_are_in_a_table) then
          if (haveseen_attrname) then
            typetmp           := 'ATTRDATA';
            haveseen_attrname := false;
          end if;
          if (we_are_in_a_table) then
            typetmp := 'ARRAYDATA';
          end if;
          -- see if we are at the end of a table or an objet => no separation !
          if (instr(tmpstr,
                    g_separation,
                    1) = 0) then
            if (instr(tmpstr,
                      g_closebracket,
                      1) = 0) then
              if (instr(tmpstr,
                        g_closebrace,
                        1) = 0) then
                -- bad struture !
                raise x_bad_jsonstruct;
              else
                -- last data before ending an object
                itemtmp := substr(tmpstr,
                                  1,
                                  instr(tmpstr,
                                        g_closebrace,
                                        1) - 1);
                tmpstr  := substr(tmpstr,
                                  instr(tmpstr,
                                        g_closebrace,
                                        1));
              end if;
            else
              -- last data before ending an array
              itemtmp := substr(tmpstr,
                                1,
                                instr(tmpstr,
                                      g_closebracket,
                                      1) - 1);
              tmpstr  := substr(tmpstr,
                                instr(tmpstr,
                                      g_closebracket,
                                      1));
            end if;
          else
            -- Some data
            itemtmp := substr(tmpstr,
                              1,
                              instr(tmpstr,
                                    g_separation,
                                    1) - 1);
            tmpstr  := substr(tmpstr,
                              instr(tmpstr,
                                    g_separation,
                                    1));
          end if;
        
          obj(i) := additem(typetmp,
                            replace(itemtmp,
                                    '\§',
                                    '\' || g_stringdelimiter),
                            true);
        end if;
      
      end if;
      i := i + 1;
    end loop;
  
    return obj;
  exception
    when x_bad_jsonstruct then
      print('Bad JSON structure : missing "' || g_openbrace || '" or "' || g_closebrace || '".');
      return nullobj;
  end string2json;

  --------------------------------------------------------------------------------
  -- Dumping pl/sql structure using print routine.
  --------------------------------------------------------------------------------
  procedure htmldumpjsonobj(p_obj in out nocopy jsonstructobj) is
    i pls_integer;
  begin
    print('<style>
	#dump {font-size:9px;}
	#dump table {border:1px dashed #cccccc;}
	#dump table tr td{text-align:center;}
	#idx, #nok {color:red;font-size:7px;}
	#type, #ok {color:green;font-size:7px;}
	#formated {color:blue;}
	#item {color:black; font-weight:bold; font-size:11px;}
	</style>');
    print('<table id="dump"><tr>');
    i := p_obj.first;
    while (i is not null) loop
      print('<td><table>');
      print('<tr><td id="idx">' || i || '</td></tr>');
      print('<tr><td id="type">' || p_obj(i).type || '</td></tr>');
      print('<tr><td id="formated">' || bool2str(p_obj(i).formated) || '</td></tr>');
      print('<tr><td id="item">' || p_obj(i).item || '</td></tr>');
      print('</table></td>');
      i := p_obj.next(i);
    end loop;
    print('</tr></table>');
  end htmldumpjsonobj;

  --------------------------------------------------------------------------------
  -- Printing the version of this package
  --------------------------------------------------------------------------------
  function getversion return varchar2 is
  begin
    return g_package_version;
  end getversion;

  --------------------------------------------------------------------------------
  -- Testing this package
  --------------------------------------------------------------------------------
  procedure test is
    my_str      varchar2(255) := '", ' || chr(8) || ', ' || chr(9) || ', ' || chr(10) || ', ' || chr(12) || ', ' || chr(13) || ', /, \, #hexABCD ';
    my_tab      jsonarray;
    my_obj      jsonstructobj;
    my_obj2     jsonstructobj;
    my_objinstr varchar2(8000);
    val         number;
    --------------------------------------------------------------------------------
    function assertdifferent(calculated_value number,
                             ref_value        number,
                             ok_msg           varchar2 default 'OK',
                             error_msg        varchar2) return varchar2 is
    begin
      if (calculated_value != ref_value) then
        return 'result : ' || calculated_value || '. <span id="ok">' || ok_msg || '</span>';
      end if;
      return 'result : ' || calculated_value || '.<span id="nok">' || error_msg || '</span>';
    end assertdifferent;
    --------------------------------------------------------------------------------
    function assertequal(calculated_value number,
                         ref_value        number,
                         ok_msg           varchar2 default 'OK',
                         error_msg        varchar2) return varchar2 is
    begin
      if (calculated_value = ref_value) then
        return 'result : ' || calculated_value || '.<span id="ok">' || ok_msg || '</span>';
      end if;
      return 'result : ' || calculated_value || '.<span id="nok">' || error_msg || '</span>';
    end assertequal;
    --------------------------------------------------------------------------------
  begin
    print('<h2>JSON PL/SQL Package - ' || getversion || '</h2>');
    --
    -- Value encoded
    --
    newjsonobj(my_obj);
    print('<hr><h5>Testing the decoder</h5><br>');
    print('values => ' || my_str || '<br>');
    print('encoded values => ' || formatvalue(my_str));
    --
    -- simple object
    --
    print('<hr><h5>simple object</h5><br>');
    newjsonobj(my_obj);
    my_obj := addattr(my_obj,
                      'FirstName',
                      'Pierre-Gilles/"levallois"\');
    my_obj := addattr(my_obj,
                      'UserID',
                      '1234');
    closejsonobj(my_obj);
    print(json2string(my_obj));
    print('<br>');
    htmldumpjsonobj(my_obj);
    --
    -- Simple table
    --
    print('<hr><h5>simple table</h5><br>');
    my_tab(1) := 'a';
    my_tab(my_tab.last + 1) := 'b';
    my_tab(my_tab.last + 1) := 'c';
    my_tab(my_tab.last + 1) := 'd';
    my_tab(my_tab.last + 1) := '1';
    my_tab(my_tab.last + 1) := '2';
    my_tab(my_tab.last + 1) := '3';
    my_tab(my_tab.last + 1) := '-1,1';
    my_tab(my_tab.last + 1) := '2e2';
    newjsonobj(my_obj);
    my_obj := addarray(my_obj,
                       my_tab);
    closejsonobj(my_obj);
    print(json2string(my_obj,
                      true));
    --
    -- Complex object
    --
    print('<hr><h5>Complex object</h5><br>');
    newjsonobj(my_obj);
    my_obj := addattr(my_obj,
                      'Table',
                      addarray(my_tab));
    closejsonobj(my_obj);
    print(json2string(my_obj));
    --
    -- Complex object 2
    --  
    print('<hr><h5>Complex object 2</h5><br>');
    newjsonobj(my_obj);
    my_obj := addattr(my_obj,
                      'UserID',
                      '1234');
    my_obj := addattr(my_obj,
                      'Table',
                      addarray(my_tab));
    newjsonobj(my_obj2);
    my_obj2 := addattr(my_obj2,
                       'email',
                       'me@mydomin.com');
    my_obj2 := addattr(my_obj2,
                       'adr',
                       '1, rue de Paris 69001 Lyon');
    closejsonobj(my_obj2);
    my_obj := addattr(my_obj,
                      'Addresses',
                      my_obj2);
    closejsonobj(my_obj);
    print(json2string(my_obj));
    --
    -- testing Decoding function and getters
    --
    print('<hr><h5>testing Decoding function and getters</h5><br>');
    print('<hr>Object is :');
    print(json2string(my_obj) || '<br>');
    htmldumpjsonobj(my_obj);
    print('<hr>Trying to get UserID''s value with getAttrValue() : <br>');
    print(getattrvalue(my_obj,
                       'UserID'));
    print('<br>Trying to get adr''s value with getAttrValue() : <br>');
    print(getattrvalue(my_obj,
                       'adr'));
    print('<br>Trying to get a table with getAttrValue() : <br>');
    print(getattrvalue(my_obj,
                       'table'));
  
    print('<br>Trying to get the same table with getAttrValue() and delimiter = " and separator = | : <br>');
    print(getattrvalue(my_obj,
                       'table',
                       true,
                       '"',
                       '|'));
  
    print('<br>Trying to get the same table with getAttrArray()');
    my_tab := getattrarray(my_obj,
                           'table',
                           true);
    for i in my_tab.first .. my_tab.last loop
      print('my_tab(' || i || ')=' || my_tab(i) || '<br/>');
    end loop;
  
    print('<br>Trying to get an object (Addresses) with getAttrValue() : <br>');
    print(getattrvalue(my_obj,
                       'Addresses'));
  
    print('<hr><h5>testing setAttrSimpleValue</h5><br>');
    print('<br>Trying to set UserID''s value with "4321" :<br>');
    my_obj := setattrsimplevalue(my_obj,
                                 'UserID',
                                 '4321');
    htmldumpjsonobj(my_obj);
    print('<br>Trying to set email''s value with "webmaster@laclasse.com" :<br>');
    my_obj := setattrsimplevalue(my_obj,
                                 'email',
                                 'webmaster@laclasse.com');
    htmldumpjsonobj(my_obj);
  
    --
    --   Testing String2JSON
    --
    print('<hr><h5>Testing the deserializer String2JSON</h5><br>');
    my_objinstr := '{"id":"25820","img":"picto_img.gif","checksum":"8744","txt":"<a href=\"javascript:go2(25820, ''597f5f4533730c881ddd96d4b8d63e02'');\" class=\"docUrlF\">test</a>","nature":"ELT","draggable":1,"imgopen":"folderopen.gif","imgclose":"folder.gif","imgselected":"page.gif","imgopenselected":"folderopen.gif","imgcloseselected":"folder.gif","open":true,"check":0,"canhavechildren":false,"acceptdrop":true,"last":false,"editable":true,"checkbox":true,"ondropajax":true,"droplink":"http://ias.erasme.lan/pls/education/!ajax_server.service?serviceName=service_deplacer&p_rendertype=none"}';
    print(my_objinstr || '<br>');
    my_obj := string2json(my_objinstr,
                          '"');
    print('Here is the object after calling String2JSON<br>');
    htmldumpjsonobj(my_obj);
    print('<hr>Trying to get nature''s value with getAttrValue() : <br>');
    print(getattrvalue(my_obj,
                       'nature'));
    --
    --   Testing String2JSON with array
    --
    print('<hr><h5>Testing the deserializer String2JSON with array</h5><br>');
    my_objinstr := '{''3B'':[''ACCOMPAGNEMENT TRAVAIL PERSONNEL''],''3C'':[''PHYSIQUE-CHIMIE''],''4C'':[''PHYSIQUE-CHIMIE''],''4A'':[''PHYSIQUE-CHIMIE''],''4B'':[''PHYSIQUE-CHIMIE''],''6D'':[''PHYSIQUE-CHIMIE'']}';
    print(my_objinstr || '<br>');
    my_obj := string2json(my_objinstr,
                          '''');
    print('Here is the object after calling String2JSON<br>');
    htmldumpjsonobj(my_obj);
    print('<hr>Trying to get 3B''s value with getAttrValue() : <br>');
    print(getattrvalue(my_obj,
                       '3B'));
    --
    -- Testing validation function
    --
    print('<hr><h5>testing validation function</h5><br>');
    my_objinstr := '{"id":"25820","img":"picto_img.gif"';
    print('<br>Here is an incorrect Json Object : ' || my_objinstr || '<br>');
    my_obj := string2json(my_objinstr,
                          '"');
    htmldumpjsonobj(my_obj);
    print('Now calling validateJSONObj<br>');
    print('Result of json validation : ' ||
          assertdifferent(validatejsonobj(my_obj,
                                          true),
                          0,
                          'The validateJSONObj function is correct.',
                          'This should not be 0 because the object is inccorect.'));
  
    my_objinstr := '"id":"25820","img":"picto_img.gif"}';
    print('<br><br>Here is an incorrect Json Object : ' || my_objinstr || '<br>');
    my_obj := string2json(my_objinstr,
                          '"');
    htmldumpjsonobj(my_obj);
    print('Now calling validateJSONObj<br>');
    print('Result of json validation : ' ||
          assertdifferent(validatejsonobj(my_obj,
                                          true),
                          0,
                          'The validateJSONObj function is correct.',
                          'This should not be 0 because the object is inccorect.'));
  
    my_objinstr := '{"id":"25820","img": ["picto_img.gif",}';
    print('<br><br>Here is an incorrect Json Object : ' || my_objinstr || '<br>');
    my_obj := string2json(my_objinstr,
                          '"');
    htmldumpjsonobj(my_obj);
    print('Now calling validateJSONObj<br>');
    print('Result of json validation : ' ||
          assertdifferent(validatejsonobj(my_obj,
                                          true),
                          0,
                          'The validateJSONObj function is correct.',
                          'This should not be 0 because the object is inccorect.'));
  
    my_objinstr := '{"id":"25820","imgs" : { img1 : "picto_img.gif", "width" : 100, "height" : 200 }, }';
    print('<br><br>Here is an incorrect Json Object : ' || my_objinstr || '<br>');
    my_obj := string2json(my_objinstr,
                          '"');
    htmldumpjsonobj(my_obj);
    print('Now calling validateJSONObj<br>');
    print('Result of json validation : ' ||
          assertdifferent(validatejsonobj(my_obj,
                                          true),
                          0,
                          'The validateJSONObj function is correct.',
                          'This should not be 0 because the object is inccorect.'));
  exception
    when others then
      print(sqlerrm);
  end test;

end xxweb_api_json_pkg;
/
