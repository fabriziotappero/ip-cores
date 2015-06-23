------------------------------------------------------------------- 
--                                                               --
--  Copyright (C) 2013 Author and VariStream Studio              --
--  Author : Yu Peng                                             --
--                                                               -- 
--  This source file may be used and distributed without         -- 
--  restriction provided that this copyright statement is not    -- 
--  removed from the file and that any derivative work contains  -- 
--  the original copyright notice and the associated disclaimer. -- 
--                                                               -- 
--  This source file is free software; you can redistribute it   -- 
--  and/or modify it under the terms of the GNU Lesser General   -- 
--  Public License as published by the Free Software Foundation; -- 
--  either version 2.1 of the License, or (at your option) any   -- 
--  later version.                                               -- 
--                                                               -- 
--  This source is distributed in the hope that it will be       -- 
--  useful, but WITHOUT ANY WARRANTY; without even the implied   -- 
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      -- 
--  PURPOSE.  See the GNU Lesser General Public License for more -- 
--  details.                                                     -- 
--                                                               -- 
--  You should have received a copy of the GNU Lesser General    -- 
--  Public License along with this source; if not, download it   -- 
--  from http://www.opencores.org/lgpl.shtml                     -- 
--                                                               -- 
-------------------------------------------------------------------
--  Notes : Introduce delay of 1 clock cycle
-------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use work.sha_256_pkg.ALL;

entity sha_256_ext_func_1c is
	port(
		iClk : in std_logic;
		iRst_async : in std_logic;

		ivWIM2 : in std_logic_vector(31 downto 0);
		ivWIM7 : in std_logic_vector(31 downto 0);	
		ivWIM15 : in std_logic_vector(31 downto 0);
		ivWIM16 : in std_logic_vector(31 downto 0);
				 
		ovWO : out std_logic_vector(31 downto 0)
	);
end sha_256_ext_func_1c;

architecture behavioral of sha_256_ext_func_1c is

begin
	
	process(iClk)
	begin
		if rising_edge(iClk) then
			ovWO <= ivWIM16 + sigma_0(ivWIM15) + ivWIM7 + sigma_1(ivWIM2);
		end if;
	end process;
		
end behavioral;
