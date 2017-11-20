PL/SQL Developer Test script 3.0
63
declare
  --
  l_package_name varchar2(40) := 'xxsl_org_simply_pkg';
  o xxweb.xxweb_api := xxweb_api(p_src_owner    => 'xxsl',
                                           p_src_name     => 'xxsl_org_simply_typ',
                                           p_package_name => l_package_name);
  --
  l_org_data xxsl.xxsl_org_simply_typ := xxsl.xxsl_org_simply_typ();
  --
  l_package clob;
  l_html    clob;
begin
  --
  --xxweb.xxsl_org_simply_pkg
  /*
  <!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  </head>
  <body data-book="koala">
    <div class="content">
      <a data-action="1">Click me</a>
    </div>

    <script src="oracle-client.js"></script>
  </body>
</html>*/
  --
  o := o.h('html',
         o.h('head',
           o.h('meta',o.attrs(charset=>'utf-8')).h('meta',o.attrs(http_equiv=>'X-UA-Compatible', content=>'IE=edge,chrome=1'))
         ).
         h('body',o.attr('data-book','simply'), --'http://e-router.eurochem.ru:8081/raw/UTFWEEK/oracle.organizers.simply/call'),
           o.h('form#content',o.h('input',o.attrs(type => 'text', name => 'deal_number', value => '""')).
           h('div.content',o.h('a',o.attr('data-action',o.callbacks('on_click_me')),'Click me'))).
           h('script',o.attr('src',o.src_oracle_client_js)))
       );
  dbms_output.put_line(o.);
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
  --l_package := o.generate;
  --execute immediate 'begin :1 := xxweb.xxsl_dc_db_html_pkg.call(p_source => :2); end;' using out l_ret.clob_value, in l_data;
  --execute immediate 'begin :1 := xxweb.'||l_package_name||'.call(p_source => :2); end;' using out l_html, in l_org_data;
  --dbms_output.put_line(l_html);
  
end;
0
2
substr(l_value,1,1)
length(p_content)
