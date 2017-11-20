create or replace package xxweb_api_json_pkg as
  /******************************************************************************
     NAME:       JSON
     PURPOSE:
  
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.1        04/12/2007             1. Created this package.
  ******************************************************************************/
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
  ********************************************************************************/
  --------------------------------------------------------------------------------
  -- Global Types and records
  --------------------------------------------------------------------------------
  -- type for JSON Array
  type jsonarray is table of varchar2(2000) index by binary_integer;

  -- type for all Name/Value Couples in JSON
  type gr_jsonnvcouple is record(
    name  varchar2(255),
    value varchar2(2000));

  -- Type for the final JSON generated string
  type jsonitem is record(
    type varchar2(100), -- OPENBRACE, OPENHOOK, CLOSEBRACE, CLOSEHOOK, 
    -- SEPARATION, AFFECTATION, ATTRNAME, ATTRDATA, ARRAYDATA
    -- INDENTATION
    item     varchar2(2000), -- the attribute name or value.
    formated boolean default false); -- true if "item" has been already formatted.          
  type jsonstructobj is table of jsonitem index by binary_integer;

  --------------------------------------------------------------------------------
  -- Global variables and constants
  --------------------------------------------------------------------------------
  -- Package Version
  g_package_version constant varchar2(100) := '1.1';
  -- 
  g_openbrace        varchar2(2) := '{ ';
  g_closebrace       varchar2(2) := ' }';
  g_openbracket      varchar2(2) := '[ ';
  g_closebracket     varchar2(2) := ' ]';
  g_stringdelimiter  varchar2(1) := '''';
  g_affectation      varchar2(3) := ' : ';
  g_separation       varchar2(3) := ', ';
  g_cr               varchar2(1) := chr(10); -- used to indent the JSON object correctly
  g_spc              varchar2(2) := '  '; -- used to indent the JSON object correctly
  g_js_comment_open  varchar2(20) := '/*-secure-\n'; -- used to prevent from javascript hijacking
  g_js_comment_close varchar2(20) := '\n*/'; -- used to prevent from javascript hijacking

  g_indent varchar2(2000) := null; -- count the recursive imbrications for object 
  -- +2 spaces when calling openObj 
  -- -2 spaces when calling closeObj

  --------------------------------------------------------------------------------
  -- Public proc. and  funct. signatures
  --------------------------------------------------------------------------------
  procedure newjsonobj(p_obj          in out nocopy jsonstructobj,
                       p_doindetation boolean default true,
                       p_secure       boolean default false);
  procedure closejsonobj(p_obj in out nocopy jsonstructobj);
  function addattr(p_obj      jsonstructobj,
                   n          varchar2,
                   v          varchar2,
                   p_formated boolean default false) return jsonstructobj;
  function addattr(p_obj      jsonstructobj,
                   n          varchar2,
                   pbool      boolean,
                   p_formated boolean default false) return jsonstructobj;
  function addattr(p_obj      jsonstructobj,
                   n          varchar2,
                   p_objvalue jsonstructobj) return jsonstructobj;
  function addarray(p_tab    jsonarray,
                    p_format boolean default false) return jsonstructobj;
  function addarray(p_obj      jsonstructobj,
                    p_table    jsonarray,
                    p_formated boolean default false) return jsonstructobj;
  function array2string(p_tab jsonarray) return varchar2;
  function json2string(p_obj           in out nocopy jsonstructobj,
                       p_only_an_array boolean default false) return varchar2;
  function string2json(p_str         varchar2,
                       pstrdelimiter varchar2 default g_stringdelimiter) return jsonstructobj;
  procedure htmldumpjsonobj(p_obj in out nocopy jsonstructobj);
  function getattrvalue(p_obj               jsonstructobj,
                        pname               varchar2,
                        pdecode             boolean default true,
                        poutputstrdelimiter varchar2 default g_stringdelimiter,
                        poutputseparator    varchar2 default replace(g_separation,
                                                                     ' ',
                                                                     null)) return varchar2;
  function getattrarray(p_obj   jsonstructobj,
                        pname   varchar2,
                        pdecode boolean default true) return jsonarray;
  function setattrsimplevalue(p_obj     jsonstructobj,
                              pname     varchar2,
                              pvalue    varchar2,
                              pformated boolean default false) return jsonstructobj;
  function setattrsimplevalue(p_obj     jsonstructobj,
                              pname     varchar2,
                              pbool     boolean,
                              pformated boolean default false) return jsonstructobj;
  function validatejsonobj(p_obj     in out nocopy jsonstructobj,
                           pvalidate boolean default false) return pls_integer;
  procedure print(p_str varchar2);
  function getversion return varchar2;
  procedure streamoutput(pobj jsonstructobj);
  procedure test;

end xxweb_api_json_pkg;
/
