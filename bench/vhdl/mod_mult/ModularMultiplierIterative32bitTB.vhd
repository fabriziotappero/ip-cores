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
----   with the 32 bit width.                                      ----
----   it takes two nubers and modulus as the input and results    ----
----   the Montgomery product A*B*(R^{-1}) mod M                   ----
----   where R^{-1} is the modular multiplicative inverse.         ----
----   R*R^{-1} == 1 mod M                                         ----
----   R = 2^word_length mod M                                     ----
----               and word_length is the binary width of the      ----
----               operated word (in this case 32 bit)             ----
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
 
ENTITY ModularMultiplierIterative32bitTB IS
END ModularMultiplierIterative32bitTB;
 
ARCHITECTURE behavior OF ModularMultiplierIterative32bitTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ModularMultiplierIterative
    PORT(
         A       : IN  STD_LOGIC_VECTOR(31 downto 0);
         B       : IN  STD_LOGIC_VECTOR(31 downto 0);
         M       : IN  STD_LOGIC_VECTOR(31 downto 0);
         start   : IN  STD_LOGIC;
         product : OUT STD_LOGIC_VECTOR(31 downto 0);
         ready   : OUT STD_LOGIC;
         clk     : IN  STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   signal A     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal B     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal M     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal start : STD_LOGIC := '0';
   signal clk   : STD_LOGIC := '0';

 	--Outputs
   signal product : std_logic_vector(31 downto 0);
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
--    A = 1073741827 in decimal
--    B = 1876543287 in decimal
--    M = 2147483659 in decimal
--    expected_result = 1075674849379283795 in decimal,  in hex 66e4624e
--    mod(1073741827*1876543287*1659419191, 2147483659) = 1726243406
--    where 2703402148733296366 is the inverse modulus
--------------------------------------------------
      
		start <= '1';
      -- A = 1073741827 in decimal
      A <=  "01000000000000000000000000000011";
      -- B = 1876543210987 in decimal
	   B <=  "01101111110110011100011100110111";      
	   -- M = 2147483659 in decimal
      M <=  "10000000000000000000000000001011";
      
	  --wait for 80*clk_period;
	  wait until ready = '1' and clk = '0';
		
	  if product /= x"66e4624e" then
		report "RESULT MISMATCH! Test case 1 failed" severity ERROR;
		assert false severity failure;
	  else
		report "Test case 1 successful" severity note;	
	  end if;

     start <= '0';
	  
---- Preparation for test case 2 -----------------
--    A = 1073741826 in decimal
--    B = 1876543286 in decimal
--    M = 2147483659 in decimal
--    expected_result = 1075674849379283795 in decimal,  in hex 66e4624e
--    mod(1073741826*1876543286*1659419191, 2147483659) = 1567508594
--    where 1659419191 is the inverse modulus
--------------------------------------------------

      -- A = 1073741826 in decimal
      A <=  "01000000000000000000000000000010";
      -- B = 1876543210986 in decimal
	   B <=  "01101111110110011100011100110110";      
	   -- M = 2147483659 in decimal
      M <=  "10000000000000000000000000001011";
		wait for clk_period;
      start <= '1';
	  --wait for 80*clk_period;
	  wait until ready = '1' and clk = '0';
		
	  if product /= x"5d6e4872" then
		report "RESULT MISMATCH! Test case 2 failed" severity ERROR;
		assert false severity failure;
	  else
		report "Test case 2 successful" severity note;	
	  end if;
		
		assert false severity failure;
   end process;

END;
