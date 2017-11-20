create or replace package body xxdoo_bk_regions_pkg is

  -- 
  function get_content(p_answer in out nocopy xxdoo_bk_answer_typ) return clob is
    l_result clob;
  begin
    dbms_lob.createtemporary(l_result,true);
    --страницы роли
    for p in 1..p_answer.role.pages.count loop
      --условие доступа
      if p_answer.page_conditions(p) = true then
        --подготовка страницы
        p_answer.page_prepare(p);
        --
        dbms_lob.append(
            l_result,
            p_answer.page_content(p)
          );
      end if;
      --
    end loop;
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Get content for region Content error.');
      raise;
  end get_content;
  --
  --
  --
  function get_toolbar(p_answer in out nocopy xxdoo_bk_answer_typ) return clob is
  begin
    return p_answer.template(p_template_name => 'toolbar');  
  end;
  --
  function get_sidebar(p_answer in out nocopy xxdoo_bk_answer_typ) return clob is
    l_dao    xxdoo_dao;
  begin
    --
    l_dao := p_answer.dao(p_answer.book.entity.entity_name);
    --
    l_dao.query.o('name');
    l_dao.query.range.set_limits(p_from => 1, p_to => 50); 
    return p_answer.template('sidebar', l_dao.get_all);
    --
  end;
  --
end xxdoo_bk_regions_pkg;
/
