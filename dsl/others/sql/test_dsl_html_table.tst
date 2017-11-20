PL/SQL Developer Test script 3.0
77
-- Created on 21.04.2015 by ZHURAVOV_VB 
declare
  l_entries xxdoo.xxdoo_edu_entries_typ;
  -- Local variables here
  function get_html(p_ctx xxdoo.xxdoo_edu_entries_typ) return clob is
    l_result clob;
    ----------------
    procedure append(p_str clob) is
    begin
      if p_str is not null then
        dbms_lob.append(l_result, p_str);
      end if;
    end;
    ----------------
    function condition_54(p_ctx xxdoo.xxdoo_edu_entries_typ) return boolean is
      l_result boolean := false;
    begin
      if p_ctx is not null then
        if p_ctx.count > 0 then
          l_result := true;
        end if;
      end if;
      return l_result;
    end condition_54;
    ----------------
  begin
    dbms_lob.createtemporary(l_result, true);
    append('<div class="table">');
    if condition_54(p_ctx) then
      append('<table>');
      append('<thead>');
      append('<tr>');
      append('<th>Column1</th>');
      append('<th>Column2</th>');
      append('</tr>');
      append('</thead>');
      append('<tbody>');
      for id55 in 1 .. p_ctx.count loop
        append('<tr></tr>');
        append('<td>');
        append('<div>');
        append('<p>test</p>');
        append('</div>');
        append('</td>');
        append('<td>');
        append('<div>');
        append('<p>test2</p>');
        append('</div>');
        append('</td>');
      end loop;
      append('</tbody>');
      append('<caption>TEST</caption>');
      append('</table>');
    else
      append('<div class="empty">');
      append('<div>');
      append('<p>Collection is empty</p>');
      append('</div>');
      append('</div>');
    end if;
    append('</div>');
    ----------------
    return l_result;
    ----------------
  exception
    when others then
      xxdoo.xxdoo_utl_pkg.fix_exception;
      raise;
  end get_html;

begin
  -- Test statements here
  l_entries := xxdoo.xxdoo_edu_entries_typ();
  --select value(e) bulk collect into l_entries from xxdoo.xxdoo_edu_entries_v e;
  --
  dbms_output.put_line(get_html(l_entries));
end;
0
0
