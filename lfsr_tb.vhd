----------------------------------------------------------------------------
---- Create Date:    20:14:07 07/28/2010 											----		
---- Design Name: lfsr_tb																----				
---- Project Name: lfsr_randgen													   ----	
---- Description: 																		----	
----  A testbench code for the lfsr.vhd code                            ----
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
 
entity lfsr_tb is
end lfsr_tb;
 
architecture behavior of lfsr_tb is     

	signal width : integer :=8;     --change the width value here for a different regsiter width.
   signal clk,set_seed,out_enable : std_logic := '0';
   signal seed : std_logic_vector(width-1 downto 0) := (0 => '1',others => '0');
   signal rand_out : std_logic_vector(width-1 downto 0);
   -- clock period definitions
   constant clk_period : time := 1 ns;
 
begin
 
	-- entity instantiation for the lfsr component.
   uut: entity work.lfsr generic map (width => 8)    --change the width value here for a different regsiter width.
	PORT MAP (
          clk => clk,
			 set_seed => set_seed,
			 out_enable => out_enable,
          seed => seed,
          rand_out => rand_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   -- Applying stimulation inputs.
   stim_proc: process
   begin		
	wait for 10 ns;
	set_seed <= '1';	
	wait for 1 ns;
	set_seed <= '0';
	wait for 20 ns;
	out_enable <= '1';
      wait;
   end process;

END;
