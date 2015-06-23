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
-- Entity: 	dw_mul_61x61
-- File:	mul_dw_gen.vhd
-- Author:	Edvin Catovic - Gaisler Research
-- Description:	DW 61x61 multiplier 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library DW02;
use DW02.DW02_components.all;


entity dw_mul_61x61 is
    port(A       : in std_logic_vector(60 downto 0);  
         B       : in std_logic_vector(60 downto 0);
         CLK     : in std_logic;     
         PRODUCT : out std_logic_vector(121 downto 0));
end;

architecture rtl of dw_mul_61x61 is
  
  signal gnd       : std_ulogic;
  signal pin, p  : std_logic_vector(121 downto 0);
  
begin
  gnd <= '0';
  u0 : DW02_mult_2_stage
    generic map ( A_width => A'length,   B_width => B'length  )
    port map ( A => A,   B => B,   TC => gnd,  CLK => CLK,   PRODUCT => pin );

  reg0 : process(CLK)
  begin
    if rising_edge(CLK) then
      p <= pin;
    end if;    
  end process;

  PRODUCT <= p;
  
end;

