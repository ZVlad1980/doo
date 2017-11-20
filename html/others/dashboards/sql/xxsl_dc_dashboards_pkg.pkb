create or replace package body xxsl.xxsl_dc_dashboards_pkg is
  -----------------------------------------------------------------------------------------------------------
  -- Разработка XXSL_A001. Реализация операционной модели продаж: Order management
  --                       Публикация: http://dov.eurochem.ru/projects/125/posts/8031  
  --
  --   Реализация Dashboards
  --
  -- MODIFICATION HISTORY
  -- Person         Date         Comments
  -- ---------      ------       ------------------------------------------
  -- Журавов В.Б.   28.02.2014   Создание             
  -- Журавов В.Б.   06.05.2014   Реализовал формирование дашборда.
  --                             Формирование входящих и исходящих сообщений операции
  --                             Обработку повторного запуска операции и ее отмены
  --                07.05.2014   Исправил сортировку операций, для корректного вывода
  --                14.05.2014   Добавил вохранение истории событий из дашборда
  --                15.05.2014   Исправил ошибку в функции проверки профиля на пользователе
  -----------------------------------------------------------------------------------------------------------
  --
  g_package_name varchar2(50) := 'XXSL_DC_DASHBOARDS_PKG';
  --
  g_deal_number      varchar2(100) := '17153';
  g_shipment_num     varchar2(100) := 'NULL'; 
  g_operation_id     varchar2(100);
  g_from_date        date;
  g_is_show_controls boolean;
  g_title            varchar2(2000);
  --
  g_is_first_row boolean;
  --
  
  cursor g_events_cur is
    select e.event_id,
           e.deal_number,
           count(e.deal_number) over(partition by e.deal_number) deal_cnt,
           row_number() over(partition by e.deal_number order by e.deal_max_date desc,e.deal_number, e.shipment_num, e.operation_id desc, e.creation_date desc, e.event_id desc) deal_row_num,
           e.shipment_num,
           count(e.shipment_num) over(partition by e.deal_number, e.shipment_num) shipment_cnt,
           row_number() over(partition by e.deal_number, e.shipment_num order by e.deal_max_date desc,e.deal_number, e.shipment_num, e.operation_id desc, e.creation_date desc, e.event_id desc) shipment_row_num,
           e.operation_id,
           count(e.operation_id) over(partition by e.deal_number, e.shipment_num, e.operation_id) operation_cnt,
           row_number() over(partition by e.deal_number, e.shipment_num, e.operation_id order by e.deal_max_date desc,e.deal_number, e.shipment_num, e.operation_id desc, e.creation_date desc, e.event_id desc) operation_row_num,
           e.creation_date,
           e.company_code,
           e.event_name,
           e.request_id,
           e.last_update_date,
           e.status,
           e.state,
           e.cancel_yn,
           e.canceling_event_id,
           e.parsed
    from   xxsl.xxsl_dc_db_events_v e
    order  by e.deal_max_date desc,e.deal_number, e.shipment_num, e.operation_id desc, e.creation_date desc, e.event_id desc;
  --
  function get_shipment_num return varchar2   is begin return g_shipment_num;     end;
  function get_deal_number  return varchar2   is begin return g_deal_number;      end;
  function get_operation_id return number     is begin return g_operation_id;     end;
  function get_from_date    return date       is begin return g_from_date;        end;
  function get_is_show_controls return boolean       is begin return g_is_show_controls; end;
  --обвертки
  procedure fix_exception(p_description in varchar2 default null,
                          p_type        in varchar2 default null) is
  begin
    --
    xxsl.xxsl_dc_utils_pkg.fix_exception(g_package_name || ': '||p_description,p_type);
    --
  end fix_exception;
  --
  --
  --
  procedure save_action(p_action_rec   in out nocopy xxsl.xxsl_dc_db_actions_hist_t%rowtype) is
    pragma autonomous_transaction;
  begin
    merge into xxsl.xxsl_dc_db_actions_hist_t a
      using (select p_action_rec.action_id   action_id,
                    p_action_rec.event_id    event_id,
                    p_action_rec.action_name action_name,
                    p_action_rec.result      result,
                    p_action_rec.creation_by creation_by
             from   dual) u
      on    (a.action_id = u.action_id)
      when matched then
        update
        set    a.result = u.result
      when not matched then
        insert(action_id, 
               event_id, 
               action_name, 
               result, 
               creation_by, 
               creation_date)
        values(xxsl.xxsl_dc_action_seq.nextval,
               u.event_id,
               u.action_name,
               u.result,
               u.creation_by,
               sysdate);
    --
    if p_action_rec.action_id is null then
      p_action_rec.action_id := xxsl.xxsl_dc_action_seq.currval;
    end if;
    --
    commit;
  exception
    when others then
      rollback;
      fix_exception('save_action finishe with error.');
      raise;
  end save_action;
  ----------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------
  --
  ----------------------------------------------------------------------------------------------
  function get_user_id return number is
    l_user_id number;
  begin
    --
    select fu.user_id
    into   l_user_id
    from   apps.fnd_user fu
    where  1=1
    and    fu.user_name = upper(SYS_CONTEXT('CLIENTCONTEXT','SERVICE_USERNAME'));
    --
    return l_user_id;
    --
  exception 
    when others then 
      return null;            
  end get_user_id;
  ----------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------
  --
  ----------------------------------------------------------------------------------------------
  function is_show_controls return boolean is
    l_profile_option_value apps.fnd_profile_option_values.profile_option_value%type;
    l_user_id number := get_user_id;
    --
    cursor l_profile_option_cur is
      select pov.profile_option_value
      from   apps.fnd_profile_options       po,
             apps.fnd_profile_option_values pov
      where  1=1
      and    pov.level_value = to_char(l_user_id)
      and    pov.level_id = 10004
      and    pov.profile_option_id = po.profile_option_id
      and    pov.application_id = po.application_id
      and    po.profile_option_name = 'XXSL_DC_CONTROL_DB_PRF';
  begin
    --
    open l_profile_option_cur;
    fetch l_profile_option_cur
      into l_profile_option_value;
    close l_profile_option_cur;
    --
    if nvl(l_profile_option_value,'N') = 'Y' then
      return true;
    end if;
    --
    return false;
    --
  exception 
    when others then 
      return false;            
  end is_show_controls;
  --
  procedure init(p_deal_number  varchar2 ,
                 p_shipment_num varchar2 ,
                 p_operation_id number   ) is
  begin
    g_shipment_num := p_shipment_num;
    g_deal_number  := p_deal_number;
    g_operation_id := p_operation_id;
    --
    if g_shipment_num is null
       and g_deal_number is null
       and g_operation_id is null then
      g_from_date := sysdate - 10;
    else
      g_from_date := sysdate - 50000;
    end if;
    --
    if g_shipment_num is not null
       or g_deal_number is not null then
      g_shipment_num := nvl(g_shipment_num,
                            'NULL');
      g_deal_number  := nvl(g_deal_number,
                            'NULL');
    end if;
    --
    g_is_show_controls := is_show_controls;
  end ;
  --
  procedure log(p_msg varchar2) is
    pragma autonomous_transaction; 
    --create table xxsl_dc_db_log_t(msg varchar2(3000),creation_date date)
  begin
    insert into xxsl_dc_db_log_t(msg, creation_date)values(p_msg,sysdate);
    commit;
  exception
    when others then
     rollback;
  end;
  --
  function get_style return varchar2 is
  begin
    return chr(35)||'mark_left  {border-color: transparent red transparent transparent;border-style:solid;border-width:5px;width:0;height:0;}
'||chr(35)||'mark_right {border-color: transparent transparent transparent green;border-style:solid;border-width:5px;width:0;height:0;}
html, body {height:100%; margin: 0; padding: 0; }
html>body {font-size: 16px; font-size: 60%;} 
body { font-family: Verdana, helvetica, arial, sans-serif;font-size: 60%;background: '||chr(35)||'fff;color: '||chr(35)||'333;}
h1, h2 { font-family: ''trebuchet ms'', verdana, arial; padding: 10px; margin: 0 }
h1 { font-size: large }
.bd {position:absolute;top:25px;bottom:5px;left:5px;right:5px;overflow: auto;}
.dt_resend {border-radius: 3px; text-align: center; border: 1px '||chr(35)||'FF9933 solid; text-decoration:none; background-color:'||chr(35)||'FFDDCC}
'||chr(35)||'banner { padding: 2px; background-color: '||chr(35)||'3300ff; color: white; font-size: large; text-align: center;border-bottom: 1px solid '||chr(35)||'ccc;background: linear-gradient(to top, '||chr(35)||'3300ff, '||chr(35)||'330066);}
'||chr(35)||'banner a { color: white; }
'||chr(35)||'main { padding: 1em; }
a img { border: none; }
table.deals {width:100%;}
table.params {float: right;}
tr.new_deal td {border-bottom: 1px solid green;border-collapse: collapse;background-color: '||chr(35)||'FFFFFF}
tr.pst td {background-color: '||chr(35)||'E0E0E0}
tr:hover {background: AliceBlue;}  
th {background-color: '||chr(35)||'E0E2E0;border-radius: 3px;}  
td {background-color: '||chr(35)||'F0F0F0;border: 1px '||chr(35)||'D0D0D0 solid;}
td.error {background-color: '||chr(35)||'FF0000;color: '||chr(35)||'FFFFFF;border: 1px '||chr(35)||'D0D0D0 solid;}
td.hidden {display: none; }
td.right {background-color: '||chr(35)||'E0E0E0; width: 100%; float: right;}
button.cancel {background-color: '||chr(35)||'FFBB00;color: '||chr(35)||'FFFFFF;border: 1px '||chr(35)||'D0D0D0 solid;border-radius: 5px;text-align: center;}
button.invoke {background-color: '||chr(35)||'03EF41;color: '||chr(35)||'294FC9;border: 1px '||chr(35)||'D0D0D0 solid;border-radius: 5px;text-align: center;}
button.hidden { display: none; }
td.lvl {padding:1px;border-radius: 3px;text-align: center;vertical-align: middle;border: 1px '||chr(35)||'D0D0D0 solid;background-color: '||chr(35)||'F0F0F0}
.lv1 {padding:10px;border-radius: 3px;text-align: center;border: 1px '||chr(35)||'808080 solid;background-color: '||chr(35)||'E0E0E0}
.lv2 {padding:1px;border-radius: 3px;text-align: center;border: 1px '||chr(35)||'80F080 solid;background-color: '||chr(35)||'E0F0E0}
.lv3 {padding:1px;border-radius: 3px;text-align: center;border: 1px '||chr(35)||'F08080 solid;background-color: '||chr(35)||'F0E0E0}
.rotated {
     -moz-transform: rotate(-90.0deg); 
     -o-transform: rotate(-90.0deg); 
     -webkit-transform: rotate(-90.0deg); 
     filter:  progid:DXImageTransform.Microsoft.BasicImage(rotation=0.083); 
     -ms-filter: "progid:DXImageTransform.Microsoft.BasicImage(rotation=0.083);}
div.form {float: right; background-color: '||chr(35)||'E0E0E0; width: 100%;}
.body {width: 100%;}
';
  end;
  function get_script return varchar2 is
  begin
    return 'function openMsg(eventId,messageType) { var newWin = window.open("'||xxapps.xxapps_service_pkg.getNSRawURL('oracle.so.dc','message') || '?event_id="+eventId+"'||chr(38)||'message_type="+messageType,"Message"); }
function actionEvent(eventId,actionName) 
{ 
  var r=confirm("Repeat processing operation?");
  if (r==true) {var newWin = window.open("'||xxapps.xxapps_service_pkg.getNSRawURL('oracle.so.dc','action') || '?event_id="+eventId+"'||chr(38)||'action_name="+actionName,"Action");}
}';
  end;
  ----------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------
  --
  /*----------------------------------------------------------------------------------------------
  function get_header return clob is
  begin
    return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>' || g_title || '</title>  
<link rel="stylesheet" href="http://jquery.bassistance.de/treeview/jquery.treeview.css">
<style type="text/css">
'||chr(35)||'mark_left  {border-color: transparent red transparent transparent;border-style:solid;border-width:5px;width:0;height:0;}
'||chr(35)||'mark_right {border-color: transparent transparent transparent green;border-style:solid;border-width:5px;width:0;height:0;}
html, body {height:100%; margin: 0; padding: 0; }
html>body {font-size: 16px; font-size: 60%;} 
body { font-family: Verdana, helvetica, arial, sans-serif;font-size: 60%;background: '||chr(35)||'fff;color: '||chr(35)||'333;}
h1, h2 { font-family: ''trebuchet ms'', verdana, arial; padding: 10px; margin: 0 }
h1 { font-size: large }
.bd {position:absolute;top:25px;bottom:5px;left:5px;right:5px;overflow: auto;}
.dt_resend {border-radius: 3px; text-align: center; border: 1px '||chr(35)||'FF9933 solid; text-decoration:none; background-color:'||chr(35)||'FFDDCC}
'||chr(35)||'banner { padding: 2px; background-color: '||chr(35)||'3300ff; color: white; font-size: large; text-align: center;border-bottom: 1px solid '||chr(35)||'ccc;background: linear-gradient(to top, '||chr(35)||'3300ff, '||chr(35)||'330066);}
'||chr(35)||'banner a { color: white; }
'||chr(35)||'main { padding: 1em; }
a img { border: none; }
tr.new_deal td {border-bottom: 1px solid green;border-collapse: collapse;background-color: '||chr(35)||'FFFFFF}
tr.pst td {background-color: '||chr(35)||'E0E0E0}
tr:hover {background: AliceBlue;}  
th {background-color: '||chr(35)||'E0E2E0;border-radius: 3px;}  
td {background-color: '||chr(35)||'F0F0F0;border: 1px '||chr(35)||'D0D0D0 solid;}
td.error {background-color: '||chr(35)||'FF0000;color: '||chr(35)||'FFFFFF;border: 1px '||chr(35)||'D0D0D0 solid;}
button.cancel {background-color: '||chr(35)||'FFBB00;color: '||chr(35)||'FFFFFF;border: 1px '||chr(35)||'D0D0D0 solid;border-radius: 5px;text-align: center;}
button.invoke {background-color: '||chr(35)||'03EF41;color: '||chr(35)||'294FC9;border: 1px '||chr(35)||'D0D0D0 solid;border-radius: 5px;text-align: center;}
td.lvl {padding:1px;border-radius: 3px;text-align: center;vertical-align: middle;border: 1px '||chr(35)||'D0D0D0 solid;background-color: '||chr(35)||'F0F0F0}
.lv1 {padding:10px;border-radius: 3px;text-align: center;border: 1px '||chr(35)||'808080 solid;background-color: '||chr(35)||'E0E0E0}
.lv2 {padding:1px;border-radius: 3px;text-align: center;border: 1px '||chr(35)||'80F080 solid;background-color: '||chr(35)||'E0F0E0}
.lv3 {padding:1px;border-radius: 3px;text-align: center;border: 1px '||chr(35)||'F08080 solid;background-color: '||chr(35)||'F0E0E0}
.rotated {
     -moz-transform: rotate(-90.0deg); 
     -o-transform: rotate(-90.0deg); 
     -webkit-transform: rotate(-90.0deg); 
     filter:  progid:DXImageTransform.Microsoft.BasicImage(rotation=0.083); 
     -ms-filter: "progid:DXImageTransform.Microsoft.BasicImage(rotation=0.083);
} 
</style>'; --
--
  end get_header;
  ----------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------
  --
  ----------------------------------------------------------------------------------------------
  procedure event_init(p_html in out nocopy xxapps.xxapps_service_raw_block) is
  begin
    p_html := xxapps.xxapps_service_raw_block(null,null,null,null,null,null);
    p_html.is_blob    := 'N';
    p_html.is_error   := 'N';
    p_html.mime_type  := 'text/html';
    --
    p_html.clob_value := get_header;
    --
    dbms_lob.append(p_html.clob_value, 
    '<script type="text/javascript">
function openMsg(eventId,messageType) { var newWin = window.open("'||xxapps.xxapps_service_pkg.getNSRawURL('oracle.so.dc','message') || '?event_id="+eventId+"'||chr(38)||'message_type="+messageType,"Message"); }
function actionEvent(eventId,actionName) 
{ 
  var r=confirm("Repeat processing operation?");
  if (r==true) {var newWin = window.open("'||xxapps.xxapps_service_pkg.getNSRawURL('oracle.so.dc','action') || '?event_id="+eventId+"'||chr(38)||'action_name="+actionName,"Action");}
}
</script>
</head><body>
<div width=100%>
<h1 id="banner">'|| g_title || '</h1>
<div class="bd">
<form><table width=100%><tr class="pst"><td align=right><table><tr>'||
'<td>Deal number:<input type="text" name="deal_number" value="'||
  case
    when g_deal_number <> 'NULL' then
      g_deal_number
  end ||'"></td>' ||
'<td>Shipment number:<input type="text" name="shipment_number" value="'||
  case
    when g_shipment_num <> 'NULL' then
      g_shipment_num
  end ||'"></td>' ||
'<td>Operation id:<input type="text" name="operation_id" value="'||g_operation_id||'"></td>' ||
'<td><input type="submit"></td>' ||
'</tr></table></td></tr></table></form>
<table width=100%><tr><th width="15%">Deals</th><th width="15%">Shipments</th><th width="10%">Operations</th>'||
'<th>Company</th><th>Event</th><th>Created At</th><th>Status</th><th>Messages</th>'||
  case
    when g_is_show_controls = true then
      '<th>Controls</th>'
  end ||'</tr>'); --
  end;
--function openMsg(eventId,messageType) { var newWin = window.open("'||xxapps.xxapps_service_pkg.getNSRawURL('oracle.so.dc','message') || '?event_id="+eventId+"'||chr(38)||'message_type="+messageType,"Message"); }
  ----------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------
  -- Функция формирует строку данных по событию
  ----------------------------------------------------------------------------------------------
  function get_event_html_row(p_row g_events_cur%rowtype) return varchar2 is
    l_result varchar2(2000);
  begin
    --
    l_result := case 
                 when not g_is_first_row and p_row.deal_row_num = 1 then --если новая сделка - вывод разделительной строки
                   '<tr class="new_deal"><td colspan=9>'||chr(38)||'nbsp;</td></tr><tr class="new_deal"><td colspan=9>'||chr(38)||'nbsp;</td></tr>' 
                end || 
                '<tr>' || 
                case 
                   when p_row.deal_row_num = 1 then --class="lv1"
                     '<td rowspan=' || p_row.deal_cnt || ' class="lvl"><div>' || p_row.deal_number || '</div></td>' 
                end ||
                case 
                   when p_row.shipment_row_num = 1 then --class="lv2"
                     '<td rowspan=' || p_row.shipment_cnt || ' class="lvl"><div>' || p_row.shipment_num || '</div></td>' 
                end ||
                case 
                   when p_row.operation_row_num = 1 then --class="lv3"
                     '<td rowspan=' || p_row.operation_cnt || ' class="lvl"><div>' || p_row.operation_id || '</div></td>' 
                end ||
                '<td>'||p_row.company_code||'</td><td>'||
                        p_row.event_name||'</td><td>'||
                        apps.fnd_date.date_to_displayDT(p_row.creation_date)||'</td><td'||
                        case 
                          when p_row.status = 'ERROR' then
                            ' class="error"'
                        end ||'>' ||
                        p_row.status||
                        case
                          when p_row.status = 'ERROR' then
                            case
                              when p_row.parsed = 'Y' then
                                ', Parsed'
                              else
                                ', No parsed'
                            end
                        end || '</td><td>'||
                        chr(38) || 'nbsp;<a href="" onclick="openMsg(' || p_row.event_id || ',''IN_XML''); return false;">In XML</a>'||
                        chr(38) || 'nbsp;<a href="" onclick="openMsg(' || p_row.event_id || ',''OUT_XML''); return false;">Out XML</a></td>'
                        || '</td>' ||
                        case
                          when g_is_show_controls then
                            '<td>'||
                            case
                              when p_row.status = 'ERROR' then
                                '<button class="invoke" onclick="actionEvent(' || p_row.event_id || ',''INVOKE'');return false;">Redo</button></td>'
                              end
                        end 
                        
                || '</tr>';
    --
    g_is_first_row := false;
    return l_result;
  end;
  function get_link return varchar2 is
  begin
    return '"http://jquery.bassistance.de/treeview/jquery.treeview.css"';
  end;
  
  ----------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------
  -- Функция возвращает html страницу с дашбордом по событиям разработки XXSL_DC
  ----------------------------------------------------------------------------------------------
  function events("deal_number"     in varchar2,
                  "shipment_number" in varchar2,
                  "operation_id"    in number) return xxapps.xxapps_service_raw_block is
    --
    l_ret xxapps.xxapps_service_raw_block;
    --
    type l_events_tab_type is table of g_events_cur%rowtype;
    l_data       xxsl_dc_db_hdr_type := xxsl_dc_db_hdr_type();
    l_events_tab l_events_tab_type;
    --
  begin
    g_shipment_num := "shipment_number";
    g_deal_number  := "deal_number";
    g_operation_id := "operation_id";
    --
    if g_shipment_num is null
       and g_deal_number is null
       and g_operation_id is null then
      g_from_date := sysdate - 2;
    else
      g_from_date := sysdate - 50000;
    end if;
    --
    g_is_show_controls := is_show_controls;
    --
    l_data.title        := 'Deal chain events dashboard on ' || sys_context('USERENV',
                                                                            'DB_NAME');
    l_data.link         := get_link;
    l_data.style        := get_style;
    l_data.script       := get_script;
    l_data.deal         := g_deal_number;
    l_data.shipment     := g_shipment_num;
    l_data.operation_id := g_operation_id;
    --
    if g_shipment_num is not null
       or g_deal_number is not null then
      g_shipment_num := nvl(g_shipment_num,
                            'NULL');
      g_deal_number  := nvl(g_deal_number,
                            'NULL');
    end if;
    --
    l_data.lines := xxsl_dc_db_lines_type();
    select xxsl_dc_db_line_type(event_id,
                                deal_number,
                                deal_cnt,
                                deal_row_num,
                                shipment_num,
                                shipment_cnt,
                                shipment_row_num,
                                operation_id,
                                operation_cnt,
                                operation_row_num,
                                creation_date,
                                company_code,
                                event_name,
                                request_id,
                                last_update_date,
                                status,
                                state,
                                cancel_yn,
                                canceling_event_id,
                                parsed) bulk collect
    into   l_data.lines
    from   xxsl.xxsl_dc_db_events2_v;
    --
    l_ret           := xxapps.xxapps_service_raw_block(null,
                                                       null,
                                                       null,
                                                       null,
                                                       null,
                                                       null);
    l_ret.is_blob   := 'N';
    l_ret.is_error  := 'N';
    l_ret.mime_type := 'text/html';
    --
    execute immediate 'begin :1 := xxweb.xxsl_dc_db_html_pkg.call(p_source => :2); end;' using out l_ret.clob_value, in l_data;
    --l_ret.clob_value := xxapps.xxsl_dc_db_html_pkg.call(p_source => l_data);
    --
    return l_ret;
  
  end events;
  ----------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------
  --
  ----------------------------------------------------------------------------------------------
  function  message("event_id"     in varchar2,
                    "message_type" in varchar2)  return xxapps.xxapps_service_raw_block is
    l_ret     xxapps.xxapps_service_raw_block;
  begin
    l_ret := xxapps.xxapps_service_raw_block(null,null,null,null,null,null);
    l_ret.is_blob    := 'N';
    l_ret.is_error   := 'N';
    l_ret.mime_type  := 'text/xml';
    --
    select case when upper("message_type")='IN_XML'  then t.in_xml.getClobVal()
                when upper("message_type")='OUT_XML' then t.out_xml.getClobVal()
           end 
    into   l_ret.clob_value
    from   xxsl.xxsl_dc_events_t t 
    where  event_id = "event_id";
    --        
   return l_ret;
  end;
  --
  procedure process_action(p_action_rec   in out nocopy xxsl.xxsl_dc_db_actions_hist_t%rowtype) is
    l_operation_id xxsl.xxsl_dc_events_t.operation_id%type;
    l_event_name   xxsl.xxsl_dc_events_t.event_name%type;
  begin
  if p_action_rec.action_name not in (xxsl.xxsl_dc_business_event_pkg.g_mode_invoke,
                                      xxsl.xxsl_dc_business_event_pkg.g_mode_check, 
                                      xxsl.xxsl_dc_business_event_pkg.g_mode_cancel) then
      fix_exception('Unknown action: '||p_action_rec.action_name);
      raise apps.fnd_api.g_exc_error;
    else
      select e.operation_id,
             e.event_name
      into   l_operation_id,
             l_event_name  
      from   xxsl.xxsl_dc_events_t e
      where  1=1
      and    e.event_id = p_action_rec.event_id;
      --
      p_action_rec.result := apps.xxsl_dc_gateway_pkg.sales_chain(p_operation_id => l_operation_id, 
                                                                  p_event_name   => l_event_name, 
                                                                  p_mode         => p_action_rec.action_name, 
                                                                  p_xml_info     => null);
      --
    end if;
  exception
    when others then
      fix_exception('process_action finishe with error.');
      raise;
  end process_action;
  ----------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------
  --
  ----------------------------------------------------------------------------------------------
  function action("event_id"    in varchar2,
                  "action_name" in varchar2) return xxapps.xxapps_service_raw_block is
    l_ret          xxapps.xxapps_service_raw_block;
    l_result       xmltype;
    l_action_rec   xxsl.xxsl_dc_db_actions_hist_t%rowtype;
  begin
    dbms_session.reset_package;
    xxsl.xxsl_dc_utils_pkg.reset_exception;
    --
    l_ret := xxapps.xxapps_service_raw_block(null,null,null,null,null,null);
    l_ret.is_blob    := 'N';
    l_ret.is_error   := 'N';
    l_ret.mime_type  := 'text/xml';
    --
    l_action_rec.event_id := "event_id";
    l_action_rec.action_name := "action_name";
    l_action_rec.creation_by := get_user_id;
    --
    save_action(l_action_rec);
    --
    process_action(l_action_rec);
    --
    save_action(l_action_rec);
    --
    l_ret.clob_value := l_action_rec.result.getClobVal();
    --
    return l_ret;
  exception
    when others then
      fix_exception('Action '||"action_name"||' crashed. ');
      l_ret.clob_value := xxsl.xxsl_dc_utils_pkg.get_exception_str;
      l_action_rec.result := xxsl.xxsl_dc_utils_pkg.errormessage(xxsl.xxsl_dc_utils_pkg.get_exception_str);
      return l_ret;
  end; 
  --*/
end xxsl_dc_dashboards_pkg;
/
