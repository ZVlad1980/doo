create or replace package body xxsl_org_simply_pkg is
  -- Private type declarations
  function simply("callback" varchar2, "params" clob) return xxapps.xxapps_service_raw_block is
    l_ret xxapps.xxapps_service_raw_block;
    l_data xxsl_org_simply_typ := xxsl_org_simply_typ();
    procedure insert_call is
      pragma autonomous_transaction;
    begin
      insert into xxsl_simply_call_t(callback,params,creation_date) values("callback","params",sysdate);
      commit;
    end;
  begin
    if "callback" is not null then
      insert_call;
    end if;
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
    execute immediate 'begin :1 := xxweb.xxsl_org_simply_pkg.call(p_source => :2); end;' using out l_ret.clob_value, in l_data;
    --
    return l_ret;
    --
  end;
  --
end xxsl_org_simply_pkg;
/
