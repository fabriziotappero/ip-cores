-----------------------------------------------------------------------------
-- Entity:  pcifbackend
-- File:    pcifbackend.vhd
-- Author:  Nils-Johan Wessman - Gaisler Research
-- Description: CAN Multiplexer (to connect two CAN buses to one CAN core) 
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity canmux is
   port(
      sel      : in std_logic;
      canrx    : out std_logic;
      cantx    : in std_logic;
      canrxv   : in std_logic_vector(0 to 1);
      cantxv   : out std_logic_vector(0 to 1)
       );
end;

architecture rtl of canmux is
begin

comb : process(sel, cantx, canrxv)
begin
   if sel = '1' then
      canrx <= canrxv(1);
      cantxv(0) <= '1';
      cantxv(1) <= cantx;
   else
      canrx <= canrxv(0);
      cantxv(0) <= cantx;
      cantxv(1) <= '1';
   end if;
end process;
end;
