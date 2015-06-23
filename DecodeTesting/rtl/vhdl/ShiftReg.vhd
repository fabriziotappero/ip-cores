-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Shift register with parallel input/output. Nothing special----
---- except configuration - it enables wider input than output and ----
---- inverse config.                                                ----
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftReg is
    generic (
	     length_1      : integer :=  8;
	     length_2      : integer :=  64;
        internal_data : integer :=  64
	 );
    port ( 
	     input  : in  STD_LOGIC_VECTOR(length_1 - 1 downto 0);
        output : out STD_LOGIC_VECTOR(length_2 - 1 downto 0);
        en     : in  STD_LOGIC;
        shift  : in  STD_LOGIC;
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC
	 );
end ShiftReg;

architecture Behavioral of ShiftReg is

signal data : STD_LOGIC_VECTOR(internal_data - 1 downto 0);

begin
    reg : process (clk, reset, data)
	     begin
		      if (reset = '1') then
				    data <= (others => '0');
		      elsif (clk'event and clk = '1') then
				    if (en = '1') then 
					     data(internal_data - 1 downto internal_data - length_1) <= input;
					 else
                    if (shift = '1') then
					         data <= '0' & data(internal_data - 1 downto 1);
						  end if;
					 end if;
				end if;
				output <= data(length_2 - 1 downto 0);
		  end process reg;

end Behavioral;

