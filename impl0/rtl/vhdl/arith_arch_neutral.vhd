--------------------------------------------------------------
-- arith_arch_neutral.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: Generic Arithmetic unit of hpc-16 ALU  
--
-- dependency: con_pkg.vhd 
--
-- Author: M. Umair Siddiqui (umairsiddiqui@opencores.org)
---------------------------------------------------------------
------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2005, M. Umair Siddiqui all rights reserved                   --
--                                                                                --
--    This file is part of HPC-16.                                                --
--                                                                                --
--    HPC-16 is free software; you can redistribute it and/or modify              --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    HPC-16 is distributed in the hope that it will be useful,                   --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with HPC-16; if not, write to the Free Software                       --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity arith is
   PORT(  c_out     :   OUT STD_LOGIC; 
          ofl_out   :   OUT STD_LOGIC; 
          s0        :   IN  STD_LOGIC; 
          c_in      :   IN  STD_LOGIC; 
          s1        :   IN  STD_LOGIC; 
          a         :   IN  STD_LOGIC_VECTOR (15 DOWNTO 0); 
          b         :   IN  STD_LOGIC_VECTOR (15 DOWNTO 0); 
          result    :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
       );
end arith;

--(s1,s0)---|--Operation--
---00-------|--sub--------
---01-------|--add--------
---10-------|--sbb--------
---11-------|--adc--------

architecture rtl of arith is
 	signal ci      : std_logic;
 	signal sum     : STD_LOGIC_VECTOR (15 DOWNTO 0);
 	signal temp    : std_logic_vector(17 downto 0);
 	
begin 	
 	
 	ci <= c_in when s1 = '1' else
 	      '0';
 		
 	process (a, b, s0, ci)		
	begin
		if(s0 = '1') then
			temp <= ("0" & a & ci) + ("0" & b & "1");
		else
			temp <= ("0" & a & ci) - ("0" & b & "1");
		end if;
	end process;
	
	sum      <= temp(16 downto 1);
	
	c_out    <= temp(17) when s0 = '1' else
	            not temp(17);
	
	ofl_out  <= temp(17) xor sum(15) xor a(15) xor b(15);
	
	result   <= sum;

end rtl;
