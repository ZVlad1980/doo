PL/SQL Developer Test script 3.0
32
-- Created on 04.06.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  p xxweb.xxweb_api_ap_pkg_typ;
begin
  -- Test statements here
  p := xxweb.xxweb_api_ap_pkg_typ('XXWEB','XXWEB_TEST_PKG');
  p.add_method(p_type => 'F',p_name => 'get_name',
               p_in_params => xxweb.xxweb_api_ap_pkg_m_pars_typ(
                                xxweb.xxweb_api_ap_pkg_m_par_typ('p_par1',null,'varchar2'),
                                xxweb.xxweb_api_ap_pkg_m_par_typ('p_par2',null,'number')
                              ),
               p_out_type => 'number',
               p_is_public => 'Y');
  --
  
  --
  p.methods(p.methods.count).add_line('dbms_output.put_line(''Ok'');');
  p.methods(p.methods.count).add_line('for i in 1..3 loop');
  p.methods(p.methods.count).indent_inc;
  p.methods(p.methods.count).add_line('dbms_output.put_line(i);');
  p.methods(p.methods.count).indent_dec;
  p.methods(p.methods.count).add_line('end loop;');
  p.methods(p.methods.count).add_line('--');
  p.methods(p.methods.count).add_line('return 1;');
  --
  p.generate;
  dbms_output.put_line(p.specification);
  dbms_output.put_line('/');
  dbms_output.put_line(p.body);
  
end;
0
0
