----------------------------------------------------------------------------
---- Create Date:    19:12:45 10/24/2010 					      ----						
---- Design Name: pic_tb							      ----										
---- Project Name: PIC								      ----	
---- Description: 								      ----										
----  A testbench code for the pic.vhd code                             ----
----											      ----												
----------------------------------------------------------------------------
----                                                                    ----
---- This file is a part of the pic project at                 		----
---- http://www.opencores.org/						      ----
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY pic_tb IS
END pic_tb;
 
ARCHITECTURE behavior OF pic_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PIC
    PORT(
         CLK_I : IN  std_logic;
         RST_I : IN  std_logic;
         IR : IN  unsigned(7 downto 0);
         DataBus : INOUT  unsigned(7 downto 0);
         INTR_O : OUT  std_logic;
         INTA_I : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_I : std_logic := '0';
   signal RST_I : std_logic := '0';
   signal IR : unsigned(7 downto 0) := (others => '0');
   signal INTA_I : std_logic := '1';

	--BiDirs
   signal DataBus : unsigned(7 downto 0);

 	--Outputs
   signal INTR_O : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PIC PORT MAP (
          CLK_I => CLK_I,
          RST_I => RST_I,
          IR => IR,
          DataBus => DataBus,
          INTR_O => INTR_O,
          INTA_I => INTA_I
        );

   -- Clock process definitions
   CLK_I_process :process
   begin
		CLK_I <= '0';
		wait for CLK_period/2;
		CLK_I <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process.
   stim_proc: process
   begin		
		DataBus <= (others => 'Z');
      RST_I <= '1';
		wait for clk_period;
		RST_I <= '0';
		wait for clk_period*3;
		DataBus(1 downto 0) <= "01";  --set polling method.
		wait for clk_period;
		DataBus <= (others => 'Z');  --make databus as high impedance.
		wait until INTR_O = '1';   --wait for an interrupt.
		wait for clk_period;  
		INTA_I <= '0';  --send ack in the next clk cycle.
		wait for clk_period;
		INTA_I <= '1';   --reset ack.
		wait until DataBus = "01011011";  --wait till info abt interrupt is received.
		wait for clk_period;
		INTA_I <= '0';  --send ack in the next clk cycle.
		wait for clk_period;
		INTA_I <= '1';   --reset ack.
		wait for clk_period*20;  --ISR takes 20 clk cycles for execution.
		DataBus <= "10100011";  --tell pic that ISR is completed.
		INTA_I <= '0';
		wait for clk_period;
		INTA_I <= '1';
		DataBus <= (others => 'Z');
		--First interrupt executed successfully.
		
		wait for clk_period*10;
		RST_I <= '1';
		wait for clk_period;
		RST_I <= '0';
		wait for clk_period;
		--set polling method and priority of interrupts.
		--descending order of priority: 7,3,4,5,6,1,2,0;
		DataBus <= "11101110";  
		wait for clk_period;
		DataBus <= "10010110";  
		wait for clk_period;
		DataBus <= "11000110";  
		wait for clk_period;
		DataBus <= "01000010";  
		wait for clk_period;
		DataBus <= (others => 'Z');  --make databus as high impedance.
		wait until INTR_O = '1';   --wait for an interrupt.
		wait for clk_period;  
		INTA_I <= '0';  --send ack in the next clk cycle.
		wait for clk_period;
		INTA_I <= '1';   --reset ack.
		wait until DataBus = "10011011";  --wait till info abt interrupt is received.
		wait for clk_period;
		INTA_I <= '0';  --send ack in the next clk cycle.
		wait for clk_period;
		INTA_I <= '1';   --reset ack.
		wait for clk_period*20;  --ISR takes 20 clk cycles for execution.
		DataBus <= "01100011";  --tell pic that ISR is completed.
		INTA_I <= '0';
		wait for clk_period;
		INTA_I <= '1';
		DataBus <= (others => 'Z');
      wait;
   end process;
	
	--External interrupts.
	external_ints : process
	begin
		wait for clk_period*15;
		IR(3) <= '1';
		wait until INTA_I='1';
		wait until INTA_I='1';
		IR(3) <= '0';
		wait for clk_period*60;
		IR <= "00101001";  --Interrupts 0,3 and 5.
		wait until INTA_I='1';
		wait until INTA_I='1';
		IR <= (others => '0');
		wait;
	end process;
	
END;
