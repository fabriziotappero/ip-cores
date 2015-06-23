-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Test bench of Present encoder. Nothing special. Data taken----
---- from http://homes.esat.kuleuven.be/~abogdano/papers/          ----
---- present_ches07.pdf                                            ----
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
 
ENTITY PresentTB IS
END PresentTB;
 
ARCHITECTURE behavior OF PresentTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PresentEnc
    PORT(
         plaintext : IN  std_logic_vector(63 downto 0);
         key : IN  std_logic_vector(79 downto 0);
         ciphertext : OUT  std_logic_vector(63 downto 0);
         start : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal plaintext : std_logic_vector(63 downto 0) := (others => '0');
   signal key : std_logic_vector(79 downto 0) := (others => '0');
   signal start : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal ciphertext : std_logic_vector(63 downto 0);
   signal ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PresentEnc PORT MAP (
          plaintext => plaintext,
          key => key,
          ciphertext => ciphertext,
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

		reset <= '1';
      start <= '0';
		wait for 100 ns;	
		reset <= '0';
		
---- Preparation for test case 1 -----------------
--   plaintext <= x"0000000000000000";
--   key <= x"00000000000000000000";
--   expected_ciphertext <= x"5579c1387b228445";
--------------------------------------------------

		plaintext <= (others => '0');
		key <= (others => '0');
		start <= '1';
      
		wait until ready = '1' and clk = '0';
		
		if ciphertext /= x"5579c1387b228445" then
			report "RESULT MISMATCH! Test case 1 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 1 successful" severity note;	
		end if;
		
---- Preparation for test case 2 -----------------
--   plaintext <= x"0000000000000000";
--   key <= x"ffffffffffffffffffff";
--   expected_ciphertext <= x"e72c46c0f5945049";
--------------------------------------------------		
		
		start <= '0';
		wait for clk_period;
		
		plaintext <= (others => '0');
		key <= (others => '1');
		start <= '1';
      wait until ready = '1' and clk = '0';
		
      if ciphertext /= x"e72c46c0f5945049" then
			report "RESULT MISMATCH! Test case 2 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 2 successful" severity note;	
		end if;

---- Preparation for test case 3 -----------------
--   plaintext <= x"a112ffc72f68417b";
--   key <= x"00000000000000000000";
--   expected_ciphertext <= x"ffffffffffffffff";
--------------------------------------------------
		
		start <= '0';
		wait for clk_period;
		
		plaintext <= (others => '1');
		key <= (others => '0');
		start <= '1';
      wait until ready = '1' and clk = '0';
		
		if ciphertext /= x"a112ffc72f68417b" then
			report "RESULT MISMATCH! Test case 3 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 3 successful" severity note;	
		end if;

---- Preparation for test case 4 -----------------
--   plaintext <= x"ffffffffffffffff";
--   key <= x"ffffffffffffffffffff";
--   expected_ciphertext <= x"3333dcd3213210d2";
--------------------------------------------------
		
		start <= '0';
		wait for clk_period;
		
		plaintext <= (others => '1');
		key <= (others => '1');
		start <= '1';
      wait until ready = '1' and clk = '0';
		
		if ciphertext /= x"3333dcd3213210d2" then
			report "RESULT MISMATCH! Test case 4 failed" severity ERROR;
			assert false severity failure;
		else
			report "Test case 4 successful" severity note;	
		end if;
		
		assert false severity failure;

   end process;

END;
