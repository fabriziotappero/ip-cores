-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Present full decoder test bench. Test signals were taken  ----
---- from  'pure' Presnet encoder simulation (it is proper work,   ----
---- because it was good implementation).                          ----
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
 
ENTITY PresentFullDecoderTB IS
END PresentFullDecoderTB;
 
ARCHITECTURE behavior OF PresentFullDecoderTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PresentFullDecoder
    PORT(
         ciphertext : IN  std_logic_vector(63 downto 0);
         key : IN  std_logic_vector(79 downto 0);
         plaintext : OUT  std_logic_vector(63 downto 0);
         start : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal ciphertext : std_logic_vector(63 downto 0) := (others => '0');
   signal key : std_logic_vector(79 downto 0) := (others => '0');
   signal start : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal plaintext : std_logic_vector(63 downto 0);
   signal ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PresentFullDecoder PORT MAP (
          ciphertext => ciphertext,
          key => key,
          plaintext => plaintext,
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
--   ciphertext <= x"5579c1387b228445";
--   key <= x"00000000000000000000";
--   expected_plaintext <= x"0000000000000000";
--------------------------------------------------
		
		reset <= '1';
      start <= '0';
		ciphertext <= x"5579c1387b228445";
		key <= (others => '0');
		wait for 100 ns;	
		reset <= '0';
		
		ciphertext <= x"5579c1387b228445";
		key <= (others => '0');
		start <= '1';
      wait until ready = '1';

      if plaintext /= x"0000000000000000" then
			report "RESULT MISMATCH! Test case 1 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 1 successful" severity note;	
		end if;

---- Preparation for test case 2 -----------------
--   ciphertext <= x"e72c46c0f5945049";
--   key <= x"ffffffffffffffffffff";
--   expected_plaintext <= x"0000000000000000";
--------------------------------------------------
		
		start <= '0';
		wait for clk_period;
		
		ciphertext <= x"e72c46c0f5945049";
		key <= (others => '1');
		start <= '1';
      wait until ready = '1';

      if plaintext /= x"0000000000000000" then
			report "RESULT MISMATCH! Test case 2 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 2 successful" severity note;	
		end if;

---- Preparation for test case 3 -----------------
--   ciphertext <= x"a112ffc72f68417b";
--   key <= x"00000000000000000000";
--   expected_plaintext <= x"ffffffffffffffff";
--------------------------------------------------
		
		start <= '0';
		wait for clk_period;
		
		ciphertext <= x"a112ffc72f68417b";
		key <= (others => '0');
		start <= '1';
      wait until ready = '1';
		
		if plaintext /= x"ffffffffffffffff" then
			report "RESULT MISMATCH! Test case 3 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 3 successful" severity note;	
		end if;

---- Preparation for test case 4 -----------------
--   ciphertext <= x"3333dcd3213210d2";
--   key <= x"ffffffffffffffffffff";
--   expected_plaintext <= x"ffffffffffffffff";
--------------------------------------------------
		
		start <= '0';
		wait for clk_period;
		
		ciphertext <= x"3333dcd3213210d2";
		key <= (others => '1');
		start <= '1';
      wait until ready = '1';
		
		start <= '0';
		wait for clk_period;
		
		if plaintext /= x"ffffffffffffffff" then
			report "RESULT MISMATCH! Test case 4 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 4 successful" severity note;	
		end if;
		
		assert false severity failure;

   end process;

END;
