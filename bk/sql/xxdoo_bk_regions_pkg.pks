create or replace package xxdoo_bk_regions_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 22.08.2014 14:28:45
  -- Purpose : 
  
  function get_content(p_answer in out nocopy xxdoo_bk_answer_typ) return clob;
  function get_toolbar(p_answer in out nocopy xxdoo_bk_answer_typ) return clob;
  function get_sidebar(p_answer in out nocopy xxdoo_bk_answer_typ) return clob;
  

end xxdoo_bk_regions_pkg;
/
