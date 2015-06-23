-----------------------------------------------------------------------
----                                                               ----
---- Montgomery modular multiplier and exponentiator               ----
----                                                               ----
---- This file is part of the Montgomery modular multiplier        ----
---- and exponentiator project                                     ----
---- http://opencores.org/project,mod_mult_exp                     ----
----                                                               ----
---- Description:                                                  ----
----   This is TestBench for the Montgomery modular multiplier     ----
----   with the 64 bit width.                                      ----
----   it takes two nubers and modulus as the input and results    ----
----   the Montgomery product A*B*(R^{-1}) mod M                   ----
----   where R^{-1} is the modular multiplicative inverse.         ----
----   R*R^{-1} == 1 mod M                                         ----
----   R = 2^word_length mod M                                     ----
----               and word_length is the binary width of the      ----
----               operated word (in this case 64 bit)             ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2014 Authors and OPENCORES.ORG                  ----
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
 
ENTITY ModularMultiplierIterative64bitTB IS
END ModularMultiplierIterative64bitTB;
 
ARCHITECTURE behavior OF ModularMultiplierIterative64bitTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ModularMultiplierIterative
    PORT(
         A       : IN  STD_LOGIC_VECTOR(63 downto 0);
         B       : IN  STD_LOGIC_VECTOR(63 downto 0);
         M       : IN  STD_LOGIC_VECTOR(63 downto 0);
         start   : IN  STD_LOGIC;
         product : OUT STD_LOGIC_VECTOR(63 downto 0);
         ready   : OUT STD_LOGIC;
         clk     : IN  STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   signal A     : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
   signal B     : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
   signal M     : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
   signal start : STD_LOGIC := '0';
   signal clk   : STD_LOGIC := '0';

 	--Outputs
   signal product : std_logic_vector(63 downto 0);
   signal ready   : STD_LOGIC;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ModularMultiplierIterative PORT MAP (
          A => A,
          B => B,
          M => M,
          start => start,
          product => product,
          ready => ready,
          clk => clk
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
      -- hold reset state for 100 ns.
      
		start <= '0';
      wait for 100 ns;	

---- Preparation for test case 1 -----------------
--    A = 1234567890123 in decimal
--    B = 9876543210987 in decimal
--    M = 9223372036854775837 in decimal
--    expected_result = 1075674849379283795 in decimal,  in hex
--    mod(1234567890123*9876543210987*2703402148733296366, 9223372036854775837) = 1075674849379283795
--    where 2703402148733296366 is the inverse modulus
--------------------------------------------------
      
		start <= '1';
      -- A = 1234567890123 in decimal
      A <=  "0000000000000000000000010001111101110001111110110000010011001011";
      --    B = 9876543210987 in decimal
	  B <=  "0000000000000000000010001111101110001111110110011000010111101011";      
	  -- M = 9223372036854775837 in decimal
      M <=  "1000000000000000000000000000000000000000000000000000000000011101";
      
	  --wait for 80*clk_period;
	  wait until ready = '1' and clk = '0';
		
	  if product /= x"0eed90938b12f353" then
		report "RESULT MISMATCH! Test case 1 failed" severity ERROR;
		assert false severity failure;
	  else
		report "Test case 1 successful" severity note;	
	  end if;

---- Preparation for test case 2 -----------------
--    A = 2405361651273580285 in decimal
--    B = 1851187696912577658 in decimal
--    M = 4612794175830006917 in decimal
--    expected_result = 1075674849379283795 in decimal
--    mod(2405361651273580285*1851187696912577658*377014635792245467, 4612794175830006917) = 1424433616378222832
--    where 377014635792245467 is the inverse modulus
--------------------------------------------------


		start <= '0';
		-- A = 2405361651273580285
		A <= "0010000101100001100011111010110101111100100000100011111011111101";
		-- B = 1851187696912577658
		B <= "0001100110110000101111010110011011111111000011000011010001111010";
		-- M = 4612794175830006917
		M <= "0100000000000011111011111101110100000000010101101001110010000101";
		wait for clk_period;
		start <= '1';
		
		--wait for 80*clk_period;
	    wait until ready = '1' and clk = '0';
		
	    if product /= x"13c49ad3be5958f0" then
		  report "RESULT MISMATCH! Test case 2 failed" severity ERROR;
		  assert false severity failure;
	    else
		  report "Test case 2 successful" severity note;	
	    end if;
		
		assert false severity failure;
   end process;

END;
