create or replace package xxdoo_edu_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 21.08.2014 12:01:07
  -- Purpose : 
  
  function when_welcome(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean;
  --
  function when_journal_view(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean;
  --
  function when_journal_edit(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean;
  --
  function when_student_edit(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean;
  --
  function state_is_empty(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean;
  --
  procedure prep_contractor_info(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure callback(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure prepare_owner(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure sidebar_select_cb(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure sidebar_scroll(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure journal_new_cb(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure student_select(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure journal_entry_new_cb(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure journal_save_cb(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure journal_entry_delete_cb(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure list_students_cb(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  procedure list_disciplines_cb(p_answer in out nocopy xxdoo_bk_answer_typ);
  --
  function get_student(p_object xxdoo_edu_student_typ) return varchar2;
  --
  function when_test(p_object xxdoo_edu_journal_typ, p_ctx xxdoo_html_context) return boolean;
  --
  function when_test2(p_object xxdoo_edu_journal_typ, p_ctx xxdoo_html_context) return boolean;
  --
  function get_entires_qty(p_object xxdoo_edu_journal_typ, p_ctx xxdoo_html_context) return number;
  --
end xxdoo_edu_pkg;
/
create or replace package body xxdoo_edu_pkg is

  -- Private type declarations
  function when_welcome(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean is
    l_result boolean := true;
  begin
    return true;
    if p_answer.parameter('journal') is not null then
      l_result := false;
    end if;
    --
    return l_result;
  end when_welcome;
  --
  function when_journal_view(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean is
    l_result boolean := true;
  begin
    --
    if p_answer.parameter('journal') is null then
      l_result := false;
    end if;
    --
    return l_result;
  end when_journal_view;
  --
  function when_journal_edit(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean is
    l_result boolean := false;
  begin
    --return true;
    if p_answer.parameter('state') in ('New','Edit') then
      l_result := true;
    end if;
    --
    return l_result;
  end when_journal_edit;
  --
  function when_student_edit(p_answer in out nocopy xxdoo_bk_answer_typ) return boolean is
    l_result boolean := false;
  begin
    --
    if p_answer.parameter('student') is not null then
      l_result := true;
    end if;
    --
    return l_result;
  end;
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
    l_object xxdoo_edu_journal_typ;
  begin
    dbms_output.put_line('Callback Ok.');
   -- l_object := xxdoo_edu_journal_typ(p_answer.entry('educations'));
    --l_object.name := 'APPLE';
    p_answer.entry('educations',l_object.get_anydata);
    p_answer.refresh('content');
  end;
  --
  --
  --
  procedure prepare_owner(p_answer in out nocopy xxdoo_bk_answer_typ) is
    --l_object xxdoo_cntr_contractor_typ;
  begin
    dbms_output.put_line('Prepare role "Owner" - Ok.');
    dbms_output.put_line('Parameter Filter: '||p_answer.role.get('Filter'));
    --l_object := xxdoo_cntr_contractor_typ(p_answer.entry('contractors'));
    --l_object.name := 'APPLE';
    --p_answer.entry('contractors',l_object.get_anydata);
    --p_answer.refresh('content');
  end;
  --
  procedure sidebar_select_cb(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj xxdoo_edu_journal_typ;
    l_jrnl_id number;
    l_dao     xxdoo_dao;
  begin
    --
    l_jrnl_id := to_number(regexp_substr(p_answer.meta,'[^\.]+',1,3));
    if l_jrnl_id is null then
      return;
    end if;
    --
    l_dao := p_answer.dao(p_answer.book.entity.entity_name);
    l_dao.query.w('id',l_jrnl_id);
    --
    l_obj := xxdoo_edu_journal_typ(l_dao.get);
    if l_obj.entries is null then
      l_obj.entries := xxdoo_edu_entries_typ();
    end if;
    --
    if l_obj.entries.count = 0 then
      l_obj.entries.extend;
      l_obj.entries(1) := xxdoo_edu_entry_typ();
    end if;
    --
    p_answer.entry('journal',anydata.ConvertObject(l_obj));
    p_answer.parameter('state','Edit');
    p_answer.parameter('journal',l_jrnl_id);
    p_answer.refresh('content');
  end;
  --
  procedure sidebar_scroll(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj xxdoo_edu_journal_typ;
  begin
    return;
    /*
    select value(j)
    into   l_obj
    from   xxdoo_edu_journals_v j
    where  j.id = 6;
    p_answer.entry('journals',anydata.ConvertObject(l_obj));
    p_answer.parameter('state','New');
    p_answer.refresh('content');--*/
  end;
  
  --
  procedure journal_new_cb(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj xxdoo_edu_journal_typ;
  begin
    --xxdoo.xxdoo_bk_core_pkg.plog(p_message => 'cb_journal_entry_new');
    
    l_obj := xxdoo_edu_journal_typ();
    l_obj.entries.extend(1);
    l_obj.entries(l_obj.entries.count) := xxdoo_edu_entry_typ();
    p_answer.entry('journal',anydata.ConvertObject(l_obj));
    p_answer.parameter('state','New');
    p_answer.parameter('journal',null);
    p_answer.refresh('content');
  end;
  --
  procedure journal_entry_new_cb(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj xxdoo_edu_journal_typ;
    l_ids sys.odcinumberlist;
  begin
    l_obj := xxdoo_edu_journal_typ(p_answer.entry('journal'));
    l_obj.entries.extend(1);
    l_obj.entries(l_obj.entries.count) := xxdoo_edu_entry_typ();
    p_answer.entry('journal',anydata.ConvertObject(l_obj));
    p_answer.parameter('state','New');
    p_answer.refresh('content');
  end;
  --
  procedure student_select(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj     xxdoo_edu_journal_typ;
    l_ids     sys.odcinumberlist;
    l_std_num number;
  begin
    l_obj     := xxdoo_edu_journal_typ(p_answer.entry('journal'));
    l_std_num := to_number(regexp_substr(p_answer.meta,'[^\.]+',1,3));
    if nvl(l_std_num,0) <> 0 then
      p_answer.parameter('student',l_obj.entries(l_std_num).id);
      p_answer.refresh('content');
    end if;
  end;
  --
  procedure journal_save_cb(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj anydata;
    l_jrnl xxdoo_edu_journal_typ;
    l_dao xxdoo_dao;
  begin
    l_dao := p_answer.dao('journal');
    l_obj := p_answer.entry('journal');
    --dbms_output.put_line(xmltype.createXML(l_obj).getStringVal);
    l_dao.put(l_obj);
    p_answer.entry('journal', l_obj);
    l_jrnl := xxdoo_edu_journal_typ(l_obj);
    --dbms_output.put_line(l_jrnl.id);
    p_answer.parameter('state','Edit');
    p_answer.parameter('journal', l_jrnl.id);
    p_answer.refresh('content');
    p_answer.refresh('sidebar');
    return;
  end;
  --
  procedure journal_entry_delete_cb(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_obj xxdoo_edu_journal_typ;
    l_entries xxdoo_edu_entries_typ;
    l_del_num number;
    j         number;
    --
  begin
    l_obj := xxdoo_edu_journal_typ(p_answer.entry('journal'));
    l_del_num := to_number(regexp_substr(p_answer.meta,'[^\.]+',1,3));
    --
    if l_obj.entries(l_del_num).id is not null then
      delete from xxdoo_edu_entries_t
      where  id = l_obj.entries(l_del_num).id;
    end if;
    l_entries := xxdoo_edu_entries_typ();
    l_entries.extend(l_obj.entries.count-1);
    --
    j := 1;
    for i in 1..l_obj.entries.count loop
      if i <> nvl(l_del_num,-1) then
        l_entries(j) := l_obj.entries(i);
        j := j + 1;
      end if;
    end loop;
    --
    l_obj.entries := l_entries;
    if l_obj.entries.count =0 then
      l_obj.entries.extend(1);
    end if;
    --
    p_answer.entry('journal',anydata.ConvertObject(l_obj));
    p_answer.refresh('content'); 
    p_answer.parameter('state','New');
    return;
  end;
  --
  --
  --
  procedure list_students_cb(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_dao    xxdoo_dao;
  begin
    p_answer.layout_mode := 'L';
    l_dao := p_answer.dao('students');
    l_dao.query.query_list(p_json => p_answer.meta, p_field_condition => 'name');
    p_answer.append(p_answer.template('students', l_dao.get_all));
    return;
  end;
  --
  --
  --
  procedure list_disciplines_cb(p_answer in out nocopy xxdoo_bk_answer_typ) is
    l_dao    xxdoo_dao;
  begin
    p_answer.layout_mode := 'L';
    l_dao := p_answer.dao('disciplines');
    l_dao.query.query_list(p_json => p_answer.meta, p_field_condition => 'full_name');
    p_answer.append(p_answer.template('disciplines', l_dao.get_all));
    return;
  end;
  --
  --
  --
  function get_student(p_object xxdoo_edu_student_typ) return varchar2 is
  begin
    return p_object.name || ' '  || p_object.last_name;
  end;
  --
  --
  --
  function when_test(p_object xxdoo_edu_journal_typ, p_ctx xxdoo_html_context) return boolean is
  begin
    return false;
  end;
  --
  --
  --
  function when_test2(p_object xxdoo_edu_journal_typ, p_ctx xxdoo_html_context) return boolean is
  begin
    return true;
  end;
  --
  --
  --
  function get_entires_qty(p_object xxdoo_edu_journal_typ, p_ctx xxdoo_html_context) return number is
  begin
    return p_object.entries.count;
  end;
  --
end xxdoo_edu_pkg;
/
