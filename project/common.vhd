library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package common is

  constant YES                :    std_logic := '1';
  constant NO                 :    std_logic := '0';
  constant HI                 :    std_logic := '1';
  constant LO                 :    std_logic := '0';
  constant ONE                :    std_logic := '1';
  constant ZERO               :    std_logic := '0';
  function boolean2stdlogic(b : in boolean) return std_logic;
  function log2(v             : in natural) return natural;

end package common;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package body common is

  function boolean2stdlogic(b : in boolean) return std_logic is
    variable s                :    std_logic;
  begin
    if b then
      s := '1';
    else
      s := '0';
    end if;
    return s;
  end function boolean2stdlogic;

  function log2(v : in natural) return natural is
    variable n    :    natural;
    variable logn :    natural;
  begin
    n      := 1;
    for i in 0 to 128 loop
      logn := i;
      exit when (n >= v);
      n    := n * 2;
    end loop;
    return logn;
  end function log2;

end package body common;
