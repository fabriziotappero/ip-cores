------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	gen_mul_61x61
-- File:	mul_inferred.vhd
-- Author:	Edvin Catovic - Gaisler Research
-- Description:	Generic 61x61 multplier
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.stdlib.all;

entity gen_mul_61x61 is
    port(A       : in std_logic_vector(60 downto 0);  
         B       : in std_logic_vector(60 downto 0);
         EN      : in std_logic;
         CLK     : in std_logic;     
         PRODUCT : out std_logic_vector(121 downto 0));
end;

architecture rtl of gen_mul_61x61 is

  signal r1, r1in, r2, r2in : std_logic_vector(121 downto 0);
  
begin
   comb : process(A, B, r1)
   begin
-- pragma translate_off
    if not (is_x(A) or is_x(B)) then
-- pragma translate_on            
      r1in <= std_logic_vector(unsigned(A) * unsigned(B));
-- pragma translate_off
    end if;
-- pragma translate_on            
      r2in <= r1;  
    end process;
 
    reg : process(clk)
    begin
      if rising_edge(clk) then
        if EN = '1' then
          r1 <= r1in;
          r2 <= r2in;
        end if;
      end if;
    end process;
    PRODUCT <= r2;
end;

