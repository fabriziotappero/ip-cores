-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     This is not "strict" implementation of multiplexer but    ----
---- contains its functionality. There are two inputs. One -       ----
---- 32 bit input, and one 80 bit input - because of way, in which ----
---- Present is working. For more information see below            ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2013 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and-or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.kody.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux80 is
	generic (
		w_2 : integer := 2;
		w_32 : integer := 32;
		w_80 : integer := 80
	);
	port(
		i0ctrl : in std_logic_vector (w_2-1 downto 0);
		input0 : in std_logic_vector(w_32-1 downto 0);
		input1 : in std_logic_vector(w_80-1 downto 0);		
		output : inout std_logic_vector(w_80-1 downto 0);
		ctrl, clk, reset : in std_logic		
	);
end mux80;

architecture Behavioral of mux80 is
	
begin
	inne : process (clk, reset)
		begin
			if (reset = '1') then
				output <= (others => '0');
			elsif (clk'Event and clk = '1') then
					if ctrl = '0' then
					    -- load least significant 32 bits of output from input0 (32 bit wide)
						if (i0ctrl = in_ld_reg_L ) then 
							output <= output(80-1 downto 32) & input0;
						-- load "middle" significant 32 bits of output from input0 (32 bit wide)
						elsif (i0ctrl = in_ld_reg_H) then
							output <= output(79 downto 64) & input0 & output(31 downto 0);
						-- load most significant 16 bits of output from input0 (16 bit wide)
						elsif (i0ctrl = in_ld_reg_HH) then
							output <= input0(15 downto 0) & output(63 downto 0);
						else 
						-- do nothing
							output <= output;
						end if;
					-- on output goes data from 80 bit input
					else
						output <= input1;
				end if;
			end if;
		end process inne;
end Behavioral;

