create or replace type body xxdoo_html_ap_pkg_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_ap_pkg_typ return self as result is
  begin
    self.methods    := xxdoo_html_ap_pkg_mthds_typ();
    self.status     := 'NEW';
    return;
  end;
  --
  constructor function xxdoo_html_ap_pkg_typ(p_owner      varchar2,
                                            p_name       varchar2) return self as result is
  begin
    self := xxdoo_html_ap_pkg_typ;
    self.owner      := p_owner;
    self.name       := p_name;
    --
    return;
  end;
  --
  member procedure add_methods(p_methods xxdoo_html_ap_pkg_mthds_typ) is
  begin
    for m in 1..p_methods.count loop
      self.methods.extend;
      self.methods(self.methods.count) := p_methods(m);
      self.methods(self.methods.count).array_id := self.methods.count;
    end loop;
  end;
  --
  member function add_method(self in out nocopy xxdoo_html_ap_pkg_typ,
                             p_type      varchar2,
                             p_name      varchar2,
                             p_in_params xxdoo_html_ap_pkg_m_pars_typ default null,
                             p_out_type  varchar2 default null,
                             p_is_public varchar2 default 'N',
                             p_body      clob default null) return number is
  begin
    self.methods.extend;
    self.methods(self.methods.count) := xxdoo_html_ap_pkg_mthd_typ(
                                          p_array_id  => self.methods.count,
                                          p_type      => p_type     ,
                                          p_name      => p_name     ,
                                          p_in_params => p_in_params,
                                          p_out_type  => p_out_type,
                                          p_body      => p_body,
                                          p_is_public => p_is_public
                                        );
    return self.methods.count;
  end;
  --
  member procedure generate(p_mode varchar2 default 'SPC') is
    l_result clob;
    cr varchar2(1) := chr(10);
    l_owner varchar(30) := lower(self.owner);
    l_name  varchar(30) := lower(self.name);
  begin
    dbms_lob.createtemporary(l_result,false);
    if p_mode = 'SPC' then
      dbms_lob.append(l_result,'create or replace package ' || l_owner || '.' || l_name ||' is'|| chr(10));
    else
      dbms_lob.append(l_result,'create or replace package body ' || l_owner || '.' || l_name ||' is'|| chr(10));
    end if;
    dbms_lob.append(l_result,rpad('  ',30,'-')||cr);
    dbms_lob.append(l_result,'  -- The package is generated automatically.'||cr);
    dbms_lob.append(l_result,'  --  Application: xxdoo_html, version: '||xxdoo_html_utils_pkg.version||cr);
    dbms_lob.append(l_result,'  --  Date: '||apps.fnd_date.date_to_displayDT(sysdate)||cr);
    dbms_lob.append(l_result,rpad('  ',30,'-')||cr);
    --
    for m in 1..self.methods.count loop
      if p_mode = 'SPC' and self.methods(m).is_public = 'Y' then
        dbms_lob.append(l_result,'  --'||chr(10));
        dbms_lob.append(l_result,self.methods(m).get_method_spc||';'||chr(10));
        dbms_lob.append(l_result,'  --'||chr(10));
      elsif p_mode <> 'SPC' then
        dbms_lob.append(l_result,rpad('  -',30,'-')||chr(10));
        dbms_lob.append(l_result,self.methods(m).get_method);
        dbms_lob.append(l_result,rpad('  -',30,'-')||chr(10));
      end if;
    end loop;
    --
    dbms_lob.append(l_result,'end '||l_name||';');
    --
    if p_mode = 'SPC' then
      self.specification := l_result;
      self.generate('BODY');
    else
      self.body := l_result;
    end if;
    dbms_lob.freetemporary(l_result); 
  end;
  --
  member procedure compile is
  begin
    execute immediate self.specification;
    if xxdoo_html_utils_pkg.get_status_obj('PACKAGE',self.owner,self.name) <> 'VALID' then
      xxdoo_html_utils_pkg.fix_exception('Error compile package '||' '||self.owner || '.' || self.name);
      raise apps.fnd_api.g_exc_error;
    end if;
    execute immediate self.body;
    if xxdoo_html_utils_pkg.get_status_obj('PACKAGE BODY',self.owner,self.name) <> 'VALID' then
      xxdoo_html_utils_pkg.fix_exception('Error compile package '||' '||self.owner || '.' || self.name);
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    execute immediate 'grant execute on '||self.owner||'.'||self.name||' to xxportal,xxapps';
    execute immediate 'grant execute,debug on '||self.owner||'.'||self.name||' to apps with grant option';
    --
    self.set_status('COMPILE');
  end;
  --
  member function get_method_array_id(p_id number) return number is
    l_result number;
    cursor l_methods_cur is
      select array_id
      from   table(self.methods) m
      where  1=1
      and    m.id = p_id;
  begin
    open l_methods_cur;
    fetch l_methods_cur
      into l_result;
    close l_methods_cur;
    --
    return l_result;
  end;
  --
  member function get_method(p_name varchar2) return xxdoo_html_ap_pkg_mthd_typ is
    l_result xxdoo_html_ap_pkg_mthd_typ;
  begin
    select value(m) obj
    into l_result
    from   table(self.methods) m
    where  m.name = p_name;
    --
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member procedure set_status(p_status varchar2) is begin self.status := p_status; end;
  member function  get_status return varchar2 is begin return self.status; end;
end;
/
