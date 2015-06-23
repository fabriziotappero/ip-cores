-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Present key gen test bench - nothing special.             ----
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY PresentKeyGenTB IS
END PresentKeyGenTB;
 
ARCHITECTURE behavior OF PresentKeyGenTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PresentEncKeyGen
    PORT(
         key : IN  std_logic_vector(79 downto 0);
         key_end : OUT  std_logic_vector(79 downto 0);
         start : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal key : std_logic_vector(79 downto 0) := (others => '0');
   signal start : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal key_end : std_logic_vector(79 downto 0);
   signal ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PresentEncKeyGen PORT MAP (
          key => key,
			 key_end => key_end,
          start => start,
          clk => clk,
          reset => reset,
          ready => ready
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

---- Preparation for test case 1 -----------------
--   key <= x"00000000000000000000";
--   expected_key_end <= x"6dab31744f41d7008759";
--------------------------------------------------

		reset <= '1';
      start <= '0';
		wait for 100 ns;	
		reset <= '0';
		
		key <= (others => '0');
		start <= '1';
      wait until ready = '1';
		
		if key_end /= x"6dab31744f41d7008759" then
			report "RESULT MISMATCH! Test case 1 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 1 successful" severity note;	
		end if;

---- Preparation for test case 2 -----------------
--   key <= x"ffffffffffffffffffff";
--   expected_key_end <= x"fe7a548fb60eb167c511";
--------------------------------------------------

		start <= '0';
		wait for clk_period;
		
		key <= (others => '1');
		start <= '1';
      wait until ready = '1';
		
		if key_end /= x"fe7a548fb60eb167c511" then
			report "RESULT MISMATCH! Test case 2 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 2 successful" severity note;	
		end if;

---- Preparation for test case 3 -----------------
--   key <= x"00000000000000000000";
--   expected_key_end <= x"6dab31744f41d7008759";
--   same as test case 1
--------------------------------------------------
		
		start <= '0';
		wait for clk_period;

		key <= (others => '0');
		start <= '1';
      wait until ready = '1';
		
		if key_end /= x"6dab31744f41d7008759" then
			report "RESULT MISMATCH! Test case 3 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 3 successful" severity note;	
		end if;

---- Preparation for test case 4 -----------------
--   key <= x"ffffffffffffffffffff";
--   expected_key_end <= x"fe7a548fb60eb167c511";
--------------------------------------------------
		
		start <= '0';
		wait for clk_period;
		
		key <= (others => '1');
		start <= '1';
      wait until ready = '1';

		if key_end /= x"fe7a548fb60eb167c511" then
			report "RESULT MISMATCH! Test case 4 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 4 successful" severity note;	
		end if;
		
		assert false severity failure;

   end process;

END;