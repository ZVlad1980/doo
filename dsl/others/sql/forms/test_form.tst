PL/SQL Developer Test script 3.0
46
-- Created on 02.05.2015 by ZHURAVOV_VB 
declare 
  -- Local variables here
  f xxdoo_dsl_frm_form;
  --
  x xmltype;
begin
  --dbms_session.reset_package; return;
  xxdoo_utl_pkg.init_exceptions;
  -- Test statements here
  f := xxdoo_dsl_frm_form();
  f:= f.form('student',
    f.fieldset('Student', 
      2,
      f.field('Name',
        f.text('FirstName').
          text('LastName')
      ).
        field('Age',
          f.date#('age')
      ).
        field('Class',
          f.suggest('class')
      )
    ).
      fieldset('Marks',
        2,
        f.field('A').
          field('B').
          collection('marks',
            f.fieldset(p_cols => 2,
              p_object => f.field(f.text('a').text('b'))
            )
          )--*/
    )--*/
  );
  --
  select xmlroot(xmltype.createXML(f), version 1.0) into x from dual;
  --
  dbms_output.put_line(x.getStringVal);
  --
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
0
0
