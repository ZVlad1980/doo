create or replace type body xxdoo_html_ap_pkg_mthd_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_ap_pkg_mthd_typ return self as result is
  begin
    self.indent := 2;
    return;
  end;
  --
  constructor function xxdoo_html_ap_pkg_mthd_typ(p_array_id  number,
                                                 p_type      varchar2,
                                                 p_name      varchar2,
                                                 p_in_params xxdoo_html_ap_pkg_m_pars_typ default null,
                                                 p_out_type  varchar2 default null,
                                                 p_body      clob default null,
                                                 p_is_public varchar2 default 'N') return self as result is
  begin
    self.id        := xxdoo_html_seq.nextval;
    self.array_id  := p_array_id;
    self.type      := case
                        when upper(substr(p_type,1,1)) = 'F' then
                          'function'
                        else
                          'procedure'
                      end    ;
    self.name      := p_name     ;
    self.in_params := nvl(p_in_params,xxdoo_html_ap_pkg_m_pars_typ());
    self.out_type  := p_out_type ;
    if p_body is null then
      dbms_lob.createtemporary(self.body,true);
    else
      self.body      := p_body     ;
    end if;
    self.is_public := p_is_public;
    --
    self.indent := 2;
    return;
  end;
  --
  member procedure add_params(p_name varchar2, p_mod varchar2, p_type varchar2) is
  begin
    self.in_params.extend;
    self.in_params(self.in_params.count) := xxdoo_html_ap_pkg_m_par_typ(p_name,p_mod,p_type);
  end;
  --
  member procedure add_line(p_line varchar2,
                            p_new  boolean default true,
                            p_eof  boolean default true) is
  begin 
    dbms_lob.append(self.body,
      case
        when p_new = true then
          '  '||rpad(' ',(self.indent-1)*2,' ')
      end ||
      p_line ||
      case
        when p_eof = true then
          chr(10)
      end);
  end;
  --
  member function get_method_spc return varchar2 is
    l_result varchar2(2000);
    l_indent number := 2;
    l_params_max_length number;
    l_indent_param      number;
    l_dummy             varchar2(100);
    --
    cursor l_param_cur is
      select max(length(p.name)) max_lenght
      from   table(self.in_params) p;
    --
    procedure push(p_str varchar2,
                   p_eol boolean default true,
                   p_nl  boolean default true) is
    begin
      l_result := substr(
                    l_result || 
                    case
                      when p_nl = true then
                        lpad(' ', l_indent, ' ')
                    end ||
                    p_str ||
                    case
                      when p_eol = true then
                        chr(10)
                    end,
                    1,
                    2000
                   );
    end;
  begin
    l_dummy := self.type||' '||self.name||case
                                            when self.in_params.count > 0 then
                                              '('
                                          end;
    l_indent_param := length(l_dummy) - l_indent;
    push(l_dummy,false);
    --
    open l_param_cur;
    fetch l_param_cur into l_params_max_length;
    close l_param_cur;
    --
    for p in 1..self.in_params.count loop
      if p > 1 then
        push(rpad(' ',l_indent_param,' '),false);
      end if;
      --
      push(p_str => rpad(lower(self.in_params(p).name),l_params_max_length,' ') || 
                    ' ' || lower(self.in_params(p).type) ||
                    case
                      when p < self.in_params.count then
                        ','
                      else
                        ')'
                    end,
           p_eol => case
                      when p < self.in_params.count then
                        true
                      else
                        false
                    end,
           p_nl  => case
                      when p=1 then
                        false
                      else
                        true
                    end
          );
    end loop;
    --
    l_indent := 2;
    if upper(substr(self.type,1,1)) = 'F' then
      push(' return '||self.out_type,false,false);
    end if;
    --
    return l_result;
  end;
  --
  member function get_method return clob is
    l_result clob;
  begin
    dbms_lob.createtemporary(l_result,true);
    dbms_lob.append(l_result,self.get_method_spc || ' is'||chr(10));
    dbms_lob.append(l_result,self.body);
    dbms_lob.append(l_result,'  end '||self.name||';'||chr(10));
    return l_result;
  end;
  --
  member procedure indent_inc is begin self.indent := self.indent + 1; end;
  member procedure indent_dec is begin self.indent := self.indent - 1; end;
  
end;
/
