create or replace package xxdoo_cntr_bk_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 21.08.2014 12:01:07
  -- Purpose : 
  
  function when_welcome(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean;
  --
  function when_contractor_info(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean;
  --
  function when_contractor_edit(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean;
  --
  function state_is_empty(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean;
  --
  procedure prep_contractor_info(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure callback(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure prepare_owner(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure sidebar_element(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure cb_contractor_new(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure cb_contractor_save(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure cb_contractor_discard(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
end xxdoo_cntr_bk_pkg;
/
create or replace package body xxdoo_cntr_bk_pkg is

  -- Private type declarations
  function when_welcome(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean is
    l_result boolean := true;
  begin
    if p_answer.parameter('contractors') is not null then
      l_result := false;
    end if;
    --
    return l_result;
  end when_welcome;
  --
  function when_contractor_info(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean is
    l_result boolean := true;
  begin
    if p_answer.parameter('contractors') is null then
      l_result := false;
    end if;
    --
    return l_result;
  end when_contractor_info;
  --
  function when_contractor_edit(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean is
    l_result boolean := false;
  begin
    if p_answer.parameter('state') = 'New' then
      l_result := true;
    end if;
    --
    return l_result;
  end when_contractor_edit;
  --
  function state_is_empty(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean is
    l_result boolean := false;
  begin
    if p_answer.parameter('state') is null then
      l_result := true;
    end if;
    --
    return l_result;
  end state_is_empty;
  --
  procedure prep_contractor_info(p_answer in out nocopy xxdoo_bk_answer_typ) is
  begin
    dbms_output.put_line('contractors_prepare ok.');
    return;
  end prep_contractor_info;
  --
  procedure callback(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_object xxdoo_cntr_contractor_typ;
  begin
    dbms_output.put_line('Callback Ok.');
    l_object := xxdoo_cntr_contractor_typ(p_answer.entry('contractors'));
    l_object.name := 'APPLE';
    p_answer.entry('contractors',l_object.get_anydata);
    p_answer.refresh('content');
  end;
  --
  --
  --
  procedure prepare_owner(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_object xxdoo_cntr_contractor_typ;
  begin
    dbms_output.put_line('Prepare role "Owner" - Ok.');
    dbms_output.put_line('Parameter Filter: '||p_answer.role.get('Filter'));
    --l_object := xxdoo_cntr_contractor_typ(p_answer.entry('contractors'));
    --l_object.name := 'APPLE';
    --p_answer.entry('contractors',l_object.get_anydata);
    --p_answer.refresh('content');
  end;
  --
  procedure sidebar_element(p_answer in out nocopy xxdoo_bk_answer_typ) is
  begin
    p_answer.refresh('content');
  end;
  --
  procedure cb_contractor_new(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj xxdoo_cntr_contractor_typ;
  begin
    p_answer.entry('contractors',anydata.ConvertObject(xxdoo_cntr_contractor_typ()));
    p_answer.parameter('state','New');
    p_answer.refresh('content');
  end;
  --
  procedure cb_contractor_save(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj xxdoo_cntr_contractor_typ;
  begin
    p_answer.entry('contractors',anydata.ConvertObject(xxdoo_cntr_contractor_typ()));
    p_answer.parameter('state','New');
    p_answer.refresh('content');
  end;
  --
  procedure cb_contractor_discard(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj xxdoo_cntr_contractor_typ;
  begin
    p_answer.entry('contractors',anydata.ConvertObject(xxdoo_cntr_contractor_typ()));
    p_answer.parameter('state','New');
    p_answer.refresh('content');
  end;
  --
end xxdoo_cntr_bk_pkg;
/
