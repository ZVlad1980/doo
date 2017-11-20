PL/SQL Developer Test script 3.0
39
-- Created on 11.08.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  t xxdoo_db_prgType_typ := xxdoo_db_prgType_typ(p_owner          => 'xxdoo',
                                                 p_name           => 'xxdoo_test_typ',
                                                 p_superTypeOwner => null,
                                                 p_superTypeName  => null,
                                                 p_final          => 'N');
  --
  m xxdoo_db_prgMethod_typ := xxdoo_db_prgMethod_typ(
    p_type        => 'static procedure',
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
begin
  -- Test statements here
  m.put_line('begin');
  m.inc;
  m.put_line('null;');
  t.add_method(m);
  --
  t.add_attr('attr1','varchar2(100)');
  t.add_attr('attr2','number');
  --
  t.create_ddl;--(p_is_full => 'N');
  --
  dbms_output.put_line(t.specification);
  dbms_output.put_line('/');
  dbms_output.put_line(t.body);
end;
0
0
