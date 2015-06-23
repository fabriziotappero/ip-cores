----------------------------------------------------------------------------------
-- Company: RIIC
-- Engineer: Gerhard Hohner Mat.nr.: 7555111
-- 
-- Create Date:    01/07/2004 
-- Design Name:    Diplomarbeit
-- Module Name:    MYCPU - Rtl 
-- Project Name:   32 bit FORTH processor
-- Target Devices: Spartan 3
-- Tool versions:  ISE 8.2
-- Description: contains declarations valid for every source
-- Dependencies: none
-- 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;

---------------------------------------------------------------------------------------------------
package Global is
function To_Integer(Arg : in std_ulogic_vector) return integer;
function To_Integer(Arg : in std_ulogic) return integer;
function TO_UNSIGNED (ARG, SIZE: natural) return UNSIGNED;

subtype RAMrange     is natural range 25 downto 0; -- 64MB as example MUST BE REDEFINED !!!


end Global;


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
package body Global is
function To_Integer(Arg : in std_ulogic) return integer is
begin
  return CONV_INTEGER(Arg);
end;


---------------------------------------------------------------------------------------------------
function To_Integer(Arg : in std_ulogic_vector) return integer is
begin
 return CONV_INTEGER(unsigned(Arg));
end;

---------------------------------------------------------------------------------------------------
  function TO_UNSIGNED (ARG, SIZE: natural) return UNSIGNED is
    variable RESULT: UNSIGNED(SIZE-1 downto 0);
    variable I_VAL: NATURAL := ARG;
  begin
    for I in 0 to RESULT'LEFT loop
      if (I_VAL mod 2) = 0 then
        RESULT(I) := '0';
      else RESULT(I) := '1';
      end if;
      I_VAL := I_VAL/2;
    end loop;
    return RESULT;
  end TO_UNSIGNED;

end Global;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
