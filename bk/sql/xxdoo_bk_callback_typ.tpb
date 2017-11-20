create or replace type body xxdoo.xxdoo_bk_callback_typ is
  --
  --
  --
  constructor function xxdoo_bk_callback_typ(p_callback_code varchar2,
                                             p_callback_name varchar2) return self as result is
  begin
    self.code := p_callback_code;
    self.id   := p_callback_name;
    if self.id is null then
      self.id := xxdoo_bk_callbacks_seq.nextval;
    end if;
    return;
  end;
  --
  --procedure assignment sequence numbers
  --
  member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_bk_callbacks_seq.nextval;
    end if;
    --
    self.method.set_id;
  end set_id;
  --
  --
  --
  member procedure set_name(p_name varchar2) is
  begin
    self.id := nvl(p_name,self.id);
  end;
  --
  --
  --
  member procedure set_method(p_method xxdoo_bk_method_typ) is
    l_id number;
  begin
    l_id := self.method.id;
    self.method := p_method;
    self.method.id := l_id;
  end;
  --
end;
/
