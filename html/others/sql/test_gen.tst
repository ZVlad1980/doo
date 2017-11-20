PL/SQL Developer Test script 3.0
44
declare
  --
  l_package_name varchar2(40) := 'xxsl_dc_db_html_pkg';
  o xxweb.xxweb_api := xxweb.xxweb_api(p_src_owner    => 'xxsl',
                                           p_src_name     => 'xxsl_dc_db_hdr_type',
                                           p_package_name => 'xxsl_dc_db_html_pkg');
  --
  h xxweb.xxweb_api := xxweb.xxweb_api(p_src_owner    => null,
                                           p_src_name     => null,
                                           p_package_name => l_package_name);
  f xxweb.xxweb_api := xxweb.xxweb_api();
  b xxweb.xxweb_api := xxweb.xxweb_api();
  t xxweb.xxweb_api := xxweb.xxweb_api();
  --
  l_pkg_name varchar2(30);
  l_package clob;
  l_html    clob;
begin
  --
  h := h.h('input', h.attrs(type => 'text', name => 'deal_number', value => h.G('deal')));
  
  --dbms_session.reset_package;
  /*h := h.h('head',
               h.h('meta',
                   h.attr('http-equiv','"Content-Type"').attr('content','"text/html; charset=ISO-8859-1"')
                  ).
                 h('title',
                   content  => 'title').
                 h('link',
                   h.attr('rel','"stylesheet"'),
                   href     => 'link').
                 h('style', 
                   type     => 'text/css', 
                   content  => 'style').
                 h('script', 
                   type     => 'text/javascript', 
                   content  => 'script')
             );*/
  l_package := h.generate;
  
  execute immediate 'begin :1 := xxweb.'||l_package_name||'.call; end;' using out l_html;
  dbms_output.put_line(l_html);
  
end;
0
2
substr(l_value,1,1)
length(p_content)
