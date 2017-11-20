create or replace package body xxdoo_dao_pkg is

  -- Private type declarations
  g_sequence number;
  g_version varchar2(15) := '1.0.2';
  --
  function version return varchar2 is begin return g_version; end;
  --
  --
  --
  procedure seq_init is
  begin
    g_sequence := 0;
  end;
  --
  --
  --
  function seq_nextval return integer is
  begin
    g_sequence := g_sequence + 1;
    return g_sequence;
  end;
  --
end xxdoo_dao_pkg;
/
