----------------------------------------------------------------------------
---- Create Date:    13:06:08 07/28/2010 											----		
---- Design Name: lfsr																	----				
---- Project Name: lfsr_randgen													   ----	
---- Description: 																		----	
----  A random number generator based on linear feedback shift          ----
----  register(LFSR).A LFSR is a shift register whose input bit is a    ----
----  linear function of its previous state.The detailed documentation  ----	
----  is available in the file named manual.pdf.   							----	
----																							----	
----------------------------------------------------------------------------
----                                                                    ----
---- This file is a part of the lfsr_randgen project at                 ----
---- http://www.opencores.org/						                        ----
----                                                                    ----
---- Author(s):                                                         ----
----   Vipin Lal, lalnitt@gmail.com                                     ----
----                                                                    ----
----------------------------------------------------------------------------
----                                                                    ----
---- Copyright (C) 2010 Authors and OPENCORES.ORG                       ----
----                                                                    ----
---- This source file may be used and distributed without               ----
---- restriction provided that this copyright statement is not          ----
---- removed from the file and that any derivative work contains        ----
---- the original copyright notice and the associated disclaimer.       ----
----                                                                    ----
---- This source file is free software; you can redistribute it         ----
---- and/or modify it under the terms of the GNU Lesser General         ----
---- Public License as published by the Free Software Foundation;       ----
---- either version 2.1 of the License, or (at your option) any         ----
---- later version.                                                     ----
----                                                                    ----
---- This source is distributed in the hope that it will be             ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied         ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR            ----
---- PURPOSE. See the GNU Lesser General Public License for more        ----
---- details.                                                           ----
----                                                                    ----
---- You should have received a copy of the GNU Lesser General          ----
---- Public License along with this source; if not, download it         ----
---- from http://www.opencores.org/lgpl.shtml                           ----
----                                                                    ----
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.lfsr_pkg.ALL; 

entity lfsr is
   generic (width : integer := 4);
port (clk : in std_logic;
		set_seed : in std_logic; 
      seed : in std_logic_vector(width-1 downto 0);
      rand_out : out std_logic_vector(width-1 downto 0)  		
    );
end lfsr;

architecture Behavioral of lfsr is

begin

process(clk)

variable rand_temp : std_logic_vector (width-1 downto 0):=(0 => '1',others => '0');
variable temp : std_logic := '0';

begin

if(rising_edge(clk)) then

if(set_seed = '1') then
rand_temp := seed;
end if;

temp := xor_gates(rand_temp);
rand_temp(width-1 downto 1) := rand_temp(width-2 downto 0);
rand_temp(0) := temp;

end if;
rand_out <= rand_temp;

end process;

end Behavioral;

