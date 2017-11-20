PL/SQL Developer Test script 3.0
28
-- Created on 16.06.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  db xxweb_db := xxweb_db(p_dev_code => 'xxweb_test');
  l_result xmltype;
begin
  -- Test statements here
  db.add_table(name   => 'contractor_site',
               pk     => 'id',
               fields => db.fields(name      => 'id',
                                   type      => 'number',
                                   key       => 'PRIMARY_KEY',
                                   is_sequence => true),
               joins  => 
  );
  db.add_table(name   => 'contractor_site',
               pk     => 'id',
               fields => db.fields(name      => 'id',
                                   type      => 'number',
                                   key       => 'PRIMARY_KEY',
                                   is_sequence => true),
               joins  => 
  );
  select xmlroot(xmltype.createxml(db),version 1.0)
  into   l_result
  from   dual;
  dbms_output.put_line(l_result.getStringVal);
end;
0
0
