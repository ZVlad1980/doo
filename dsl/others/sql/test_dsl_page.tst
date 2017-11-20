PL/SQL Developer Test script 3.0
56
-- Created on 21.04.2015 by ZHURAVOV_VB 
declare 
  -- Local variables here
  h xxdoo_html;
  p xxdoo_dsl_page;
  x xmltype;
begin
  --dbms_session.reset_package; return;
  xxdoo.xxdoo_utl_pkg.init_exceptions;
  -- Test statements here
  p := xxdoo_dsl_page();
  h := xxdoo_html();
  --
  p.page(
    p_name    => 'Test',
    p_header  => 
      xxdoo_dsl_header(
        p_heading => h.G('id'),
        p_message => 'Title',
        p_toolbar => 
          xxdoo_dsl_toolbar(
            xxdoo_dsl_buttons(
              xxdoo_dsl_button(
                p_label     => 'Save',
                p_callback  => 2
              )
            )
          )
      ),
    p_summary => 
      xxdoo_dsl_summary(
        xxdoo_dsl_terms(
          xxdoo_dsl_term(
            p_term  => 'Journal: ',
            p_when  => p.eql(p.G('name'),'Journal'),
            p_value => p.G('name')
          ),
          xxdoo_dsl_term(
            p_term  => '  Count of entry: ',
            p_when  => p.G('cnt'),
            p_value => p.G('cnt')
          )
        )
      ),
    p_content => h.h('div.page')
  );
  --
  xxdoo_utl_pkg.output_object(anydata.ConvertObject(p.h));
  dbms_output.put_line(p.h.get_method(p_src_owner  => 'xxdoo',
                                      p_src_object => 'xxdoo_edu_journal_typ'));
  --   
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
0
