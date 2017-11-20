create or replace type xxsl_org_simply_typ as object
(
  -- Author  : ZHURAVOV_VB
  -- Created : 30.05.2014 13:34:40
  -- Purpose : 
  
  -- Attributes
  dummy varchar2(1),
  constructor function xxsl_org_simply_typ return self as result,
  static function on_click_me(params clob) return clob
)
/
create or replace type body xxsl_org_simply_typ is
  
  -- Member procedures and functions
  constructor function xxsl_org_simply_typ return self as result is
  begin
    return;
  end;
  --
  static function on_click_me(params clob) return clob is
    l_result clob;
  begin
    return l_result;
  end;
end;
/
