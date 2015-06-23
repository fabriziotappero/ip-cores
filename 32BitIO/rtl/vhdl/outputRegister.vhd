-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Not "pure" registers. Main function of this component is  ----
---- to convert 64 bit input to 32 bit output. For more see below. ----
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

entity outputRegister is
	generic (
		w_2 : integer := 2;
		w_32: integer := 32;
		w_64: integer := 64
	);
   port(
		rst, clk, rd : in std_logic;
		ctrl : in std_logic_vector(w_2-1 downto 0);
		input : in std_logic_vector(w_64-1 downto 0);
		output : out std_logic_vector(w_32-1 downto 0);
		ready : out std_logic
   );
end outputRegister;

architecture Behavioral of outputRegister is
	signal reg : std_logic_vector(w_64-1 downto 0);
	begin
		process( rst, clk, ctrl, input)
			begin
				if (rst = '1') then 
					output <= (others=>'Z');
				elsif(clk'event and clk = '1') then
				    -- loading internal signal
					if(ctrl = out_ld_reg) then	
						reg <= input;
						output <= (others=>'Z');
					---- leas significant 32 bits to output
					elsif (ctrl = out_reg_L) then
						output <= reg(w_32-1 downto 0);
					---- most significant 32 bits to output
					elsif (ctrl = out_reg_H) then
						output <= reg(w_64-1 downto w_32);
					---- this should not happen
					else
						output <= (others=>'Z');
					end if;
				end if;
			end process;
			ready <= rd;
	end Behavioral;

