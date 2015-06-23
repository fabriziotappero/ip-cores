-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Key update test bench. It was much more used during       ----
---- inverse so data below are the same.                           ----
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
 
ENTITY keyupdTB IS
END keyupdTB;
 
ARCHITECTURE behavior OF keyupdTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT keyupd
    PORT(
         key : IN  std_logic_vector(79 downto 0);
         num : IN  std_logic_vector(4 downto 0);
         keyout : OUT  std_logic_vector(79 downto 0)--;
			--clk, reset : std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal key : std_logic_vector(79 downto 0) := (others => '0');
   signal num : std_logic_vector(4 downto 0) := (others => '0');
	signal clk : std_logic := '0';
	signal reset : std_logic := '0';

 	--Outputs
   signal keyout : std_logic_vector(79 downto 0);
	
	constant clk_period : time := 1ns;
		
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: keyupd PORT MAP (
          key => key,
          num => num,
          keyout => keyout--,
			 --clk => clk,
			 --reset => reset
        );
 
   -- No clocks detected in port list. Replace clk below with 
   -- appropriate port name 
 
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
		reset <='0';
      wait for clk_period;
		
---- Preparation for test case 1 -----------------
--   key <= x"00000000000000000000";
--   num <= "00001";
--   expected_keyout <= x"c0000000000000008000";
--------------------------------------------------
		
		key <= (others => '0');
		num <= "00001";
		wait for clk_period;
		
		if keyout /= x"c0000000000000008000" then
			report "RESULT MISMATCH! Test case 1 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 1 successful" severity note;	
		end if;
		
---- Preparation for test case 2 -----------------
--   key <= x"c0000000000000008000";
--   num <= "00010";
--   expected_keyout <= x"50001800000000010000";
--------------------------------------------------
		
		key <= x"c0000000000000008000";
		num <= "00010";
		wait for clk_period;
		
		if keyout /= x"50001800000000010000" then
			report "RESULT MISMATCH! Test case 2 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 2 successful" severity note;	
		end if;
		
---- Preparation for test case 3 -----------------
--   key <= x"50001800000000010000";
--   num <= "00011";
--   expected_keyout <= x"60000a00030000018000";
--------------------------------------------------
		
		key <= x"50001800000000010000";
		num <= "00011";
		wait for clk_period;

		if keyout /= x"60000a00030000018000" then
			report "RESULT MISMATCH! Test case 3 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 3 successful" severity note;	
		end if;
		
		key <= x"8ba27a0eb8783ac96d59";
		num <= "11111";
		wait for clk_period;
		
---- Preparation for test case 4 -----------------
--   key <= x"8ba27a0eb8783ac96d59";
--   num <= "11111";
--   expected_keyout <= x"6dab31744f41d7008759";
--------------------------------------------------
		
		if keyout /= x"6dab31744f41d7008759" then
			report "RESULT MISMATCH! Test case 4 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 4 successful" severity note;	
		end if;
		
		assert false severity failure;
   end process;
END;