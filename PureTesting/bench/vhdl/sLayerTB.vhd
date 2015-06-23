-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Substitution layer test bench of Present encoder.         ----
---- Nothing special.                                              ----
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY sLayerTB IS
END sLayerTB;
 
ARCHITECTURE behavior OF sLayerTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT slayer
    PORT(
         input : IN  std_logic_vector(3 downto 0);
         output : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

	--BiDirs
   signal input : std_logic_vector(3 downto 0);
   signal output : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: slayer PORT MAP (
          input => input,
          output => output
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		reset <= '1';
      wait for 100ns;	
		reset <= '0';
      wait for clk_period;
		
---- Preparation for test case 1 -----------------
--   input <= x"0";
--   expected_output <= x"";
--------------------------------------------------
		
		input <= x"0";
      wait for clk_period;

		if output /= x"C" then
			report "RESULT MISMATCH! Test case 1 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 1 successful" severity note;	
		end if;

---- Preparation for test case 2 -----------------
--   input <= x"A";
--   expected_output <= x"F";
--------------------------------------------------
		
		input <= x"A";
      wait for clk_period;

		if output /= x"F" then
			report "RESULT MISMATCH! Test case 2 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 2 successful" severity note;	
		end if;

---- Preparation for test case 3 -----------------
--   input <= x"F";
--   expected_output <= x"2";
--------------------------------------------------
		
		input <= x"F";
      wait for clk_period;
		
		if output /= x"2" then
			report "RESULT MISMATCH! Test case 3 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 3 successful" severity note;	
		end if;
		
      -- insert stimulus here 
		assert false severity failure;
   end process;

END;