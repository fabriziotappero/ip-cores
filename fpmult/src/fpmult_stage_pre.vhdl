library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fp_generic.all;
use work.fpmult_stage_pre_comp.all;

entity fpmult_stage_pre is
  port(
    clk:in std_logic;
    d:in fpmult_stage_pre_in_type;
    q:out fpmult_stage_pre_out_type
  );
end;

architecture twoproc of fpmult_stage_pre is
  type reg_type is record
    a:fp_type;
    b:fp_type;
  end record;
  signal r,rin:reg_type;
begin
  comb:process(d,r)
    variable v:reg_type;
    variable a_is_normal,b_is_normal:boolean;
    variable a_is_subnormal,b_is_subnormal:boolean;
    variable a_is_zero,b_is_zero:boolean;
    variable a_is_infinite,b_is_infinite:boolean;
    variable a_is_nan,b_is_nan:boolean;
    variable is_normal:boolean;
    variable is_zero:boolean;
    variable is_infinite:boolean;
    variable is_nan:boolean;
  begin
    -- sample register outputs
    v:=r;

    -- overload
    a_is_normal:=fp_is_normal(d.a);
    b_is_normal:=fp_is_normal(d.b);
    a_is_subnormal:=fp_is_subnormal(d.a);
    b_is_subnormal:=fp_is_subnormal(d.b);
    a_is_zero:=fp_is_zero(d.a);
    b_is_zero:=fp_is_zero(d.b);
    a_is_infinite:=fp_is_infinite(d.a);
    b_is_infinite:=fp_is_infinite(d.b);
    a_is_nan:=fp_is_nan(d.a);
    b_is_nan:=fp_is_nan(d.b);

    -- This implementation does not support subnormal numbers.
    -- They are treated as zero.
    -- This is not in conformance with IEEE-754 but greatly simplifies the implementation
    --
    -- +-----------+------+----------+-----------+----------+------+
    -- |           | zero |  normal  | subnormal | infinite | NaN  |
    -- +-----------+------+----------+-----------+----------+------+
    -- |   zero    | zero |   zero   |   zero    |   qNaN   | qNaN |
    -- |  normal   | zero |  A * B   |   zero    | infinite | qNaN |
    -- | subnormal | zero |   zero   |   zero    |   qNaN   | qNaN |
    -- | infinite  | qNaN | infinite |   qNaN    | infinite | qNaN |
    -- |    NaN    | qNaN |   qNaN   |   qNaN    |   qNaN   | qNaN |
    -- +-----------+------+----------+-----------+----------+------+

    is_normal:=false;
    is_zero:=false;
    is_infinite:=false;
    is_nan:=false;
    if a_is_zero or b_is_zero then
      if a_is_zero and b_is_zero then
        is_zero:=true;
      end if;
      if a_is_normal or b_is_normal then
        is_zero:=true;
      end if;
      if a_is_subnormal or b_is_subnormal then
        is_zero:=true;
      end if;
      if a_is_infinite or b_is_infinite then
        is_nan:=true;
      end if;
      if a_is_nan or b_is_nan then
        is_nan:=true;
      end if;
    end if;
     
    if a_is_normal or b_is_normal then
      if a_is_normal and b_is_normal then
        is_normal:=true;
      end if;
      if a_is_subnormal or b_is_subnormal then
        is_zero:=true;
      end if;
      if a_is_infinite or b_is_infinite then
        is_infinite:=true;
      end if;
      if a_is_nan or b_is_nan then
        is_nan:=true;
      end if;
    end if;
     
    if a_is_subnormal or b_is_subnormal then
      if a_is_subnormal and b_is_subnormal then
        is_zero:=true;
      end if;
      if a_is_infinite or b_is_infinite then
        is_nan:=true;
      end if;
      if a_is_nan or b_is_nan then
        is_nan:=true;
      end if;
    end if;
     
    if a_is_infinite or b_is_infinite then
      if a_is_infinite and b_is_infinite then
        is_infinite:=true;
      end if;
      if a_is_nan or b_is_nan then
        is_nan:=true;
      end if;
    end if;
     
    if a_is_nan and b_is_nan then
      is_nan:=true;
    end if;

    if is_zero or is_infinite or is_nan then
      v.b:=d.b(31)&"01111111"&"00000000000000000000000";  -- 1.0
    end if;
    if is_normal then
      v.b:=d.b;
    end if;

    if is_zero then
      v.a:=d.a(31)&"00000000"&"00000000000000000000000";  -- 0.0
    end if;
    if is_infinite then
      v.a:=d.a(31)&"11111111"&"00000000000000000000000";  -- infinite
    end if;
    if is_nan then
      v.a:=d.a(31)&"11111111"&"10000000000000000000000";  -- qNaN
    end if;
    if is_normal then
      v.a:=d.a;
    end if;

    -- drive register inputs
    rin<=v;

    -- drive outputs
    q.a<=r.a;
    q.b<=r.b;
  end process;
  
  seq:process(clk,rin)
  begin
    if rising_edge(clk) then
      r<=rin;
    end if;
  end process;
end;