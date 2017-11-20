-- ----------------------------------------------------------------------------
-- Key-value pair element
-- ----------------------------------------------------------------------------
create or replace type xxdoo_p2r_element as object (
  key   varchar2(1024),
  value varchar2(1024)
);

-- ----------------------------------------------------------------------------
-- Key-value pair array
-- ----------------------------------------------------------------------------
create or replace type xxdoo_p2r_set as table of xxdoo_p2r_element;

-- ----------------------------------------------------------------------------
-- Parser "regexp" element
-- ----------------------------------------------------------------------------
create or replace type xxdoo_p2r_key as object (
  key         varchar2(1024),
  regexp      varchar2(1024),
  required    char(1),
  capture_it  char(1),
  stop_flag   char(1),
  constructor function xxdoo_p2r_key return self as result
);  

-- ----------------------------------------------------------------------------
-- Parser "regexp" array
-- ----------------------------------------------------------------------------
create or replace type xxdoo_p2r_keys as table of xxdoo_p2r_key;

-- ----------------------------------------------------------------------------
-- Main parser object
-- ----------------------------------------------------------------------------
create or replace type xxdoo_p2r_parser as object (
  parts     xxdoo_p2r_keys,
  parsed    xxdoo_p2r_set,
  iterator  integer,
  constructor function xxdoo_p2r_parser(p_template in varchar2)                    return self as result,
  constructor function xxdoo_p2r_parser(p_template in varchar2,p_path in varchar2) return self as result,
  member procedure initialize(p_template in varchar2),
  member function  parse(self in out nocopy xxdoo_p2r_parser,p_path in varchar2) return xxdoo_p2r_set,
  member procedure parse(p_path in varchar2),
  member function  valueOf(p_key in varchar2) return varchar2,
  member procedure first,
  member function  next (self in out nocopy xxdoo_p2r_parser,p_key out varchar2,p_value out varchar2) return boolean,
  member procedure next (p_key out varchar2,p_value out varchar2)
);   


-- ----------------------------------------------------------------------------
-- Parsers key-value
-- ----------------------------------------------------------------------------
create or replace type xxdoo_p2r_parser_key as object (
  name    varchar2(1024),
  parser  xxdoo_p2r_parser
);  

-- ----------------------------------------------------------------------------
-- Parsers set
-- ----------------------------------------------------------------------------
create or replace type xxdoo_p2r_parsers as table of xxdoo_p2r_parser_key;

-- ----------------------------------------------------------------------------
-- Parsers query
-- ----------------------------------------------------------------------------
create or replace type xxdoo_p2r_query as object (
  parsers   xxdoo_p2r_parsers,
  constructor function xxdoo_p2r_query return self as result,
  constructor function xxdoo_p2r_query(p_templates in varchar2) return self as result,
  member procedure addTemplate(p_template in varchar2,p_name in varchar2),
  member function query(self in out nocopy xxdoo_p2r_query,p_path in varchar2) return xxdoo_p2r_parser,
  member function query(self in out nocopy xxdoo_p2r_query,p_path in varchar2,p_name out varchar2) return xxdoo_p2r_parser
);  

