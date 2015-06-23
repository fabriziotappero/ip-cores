--	Package File Template
--
--	Purpose: This package defines useful functions


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package MY_FUNCS is
	-- Operator sll and srl for a std_logic_vector
	function "sll"(val : std_logic_vector; shift : integer) return std_logic_vector;
	function "srl"(val : std_logic_vector; shift : integer) return std_logic_vector;
end MY_FUNCS;


package body MY_FUNCS is
  function "sll"(val : std_logic_vector; shift : integer) return std_logic_vector is
    variable ret : std_logic_vector(val'range) := val;
  begin
    if (shift > 0) then
      for i in 1 to shift loop
        ret := ret(val'high - 1 downto val'low) & '0';
      end loop;
    end if;
    return ret;
  end;
  
  function "srl"(val : std_logic_vector; shift : integer) return std_logic_vector is
    variable ret : std_logic_vector(val'range) := val;
  begin
    if (shift > 0) then
      for i in 1 to shift loop
        ret := '0' & ret(val'high downto val'low + 1) ;
      end loop;
    end if;
    return ret;
  end;
end MY_FUNCS;
