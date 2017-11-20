PL/SQL Developer Test script 3.0
42
-- Created on 11.08.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  p xxdoo_db_prgPackage_typ := xxdoo_db_prgPackage_typ('xxdoo','xxdoo_test_pkg');
  m xxdoo_db_prgMethod_typ := xxdoo_db_prgMethod_typ(
    p_type        => 'p',
    p_name        => 'test',
    p_paramters   => xxdoo_db_prgVariables_typ(
                       xxdoo_db_prgVariable_typ('p_par1',
                                                'in out nocopy',
                                                'varchar2',
                                                'default ''def'''),
                       xxdoo_db_prgVariable_typ('p_par2',null,'varchar2','default null')
                     ) ,
    p_return_type => null,
    p_is_public   => 'Y',
    p_comment     => 'Test procedure'
  );
  g xxdoo_db_prgText_typ := xxdoo_db_prgText_typ(p_is_public => 'Y');
  l xxdoo_db_prgText_typ := xxdoo_db_prgText_typ(p_is_public => 'N');
  i xxdoo_db_prgText_typ := xxdoo_db_prgText_typ();
begin
  -- Test statements here
  m.put_line('begin');
  m.inc;
  m.put_line('null;');
  p.add_method(m);
  --
  g.put_line('g_public constant varchar2(100) := ''PUBLIC'';');
  l.put_line('g_private varchar2(100);');
  i.put_line('g_private := ''PRIVATE'';');
  --
  p.add_preCode(g);
  p.add_preCode(l);
  p.set_initCode(i);
  p.create_ddl;
  -- Test statements here
  dbms_output.put_line(p.specification);
  dbms_output.put_line('/');
  dbms_output.put_line(p.body);
  --
end;
0
0
