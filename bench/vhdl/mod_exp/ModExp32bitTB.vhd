-----------------------------------------------------------------------
----                                                               ----
---- Montgomery modular multiplier and exponentiator               ----
----                                                               ----
---- This file is part of the Montgomery modular multiplier        ----
---- and exponentiator project                                     ----
---- http://opencores.org/project,mod_mult_exp                     ----
----                                                               ----
---- Description:                                                  ----
----   This is TestBench for the Montgomery modular exponentiator  ----
----   with the 32 bit width.                                      ----
----   It takes four nubers - base, power, modulus and Montgomery  ----
----   residuum (2^(2*word_length) mod N) as the input and results ----
----   the modular exponentiation A^B mod M.                       ----
----   In fact input data are read through one input controlled by ----
----   the ctrl input.                                             ----
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
use work.properties.ALL;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ModExp32bitTB IS
END ModExp32bitTB;
 
ARCHITECTURE behavior OF ModExp32bitTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ModExp
    PORT(
         input         : in  STD_LOGIC_VECTOR(31 downto 0);
         ctrl          : in  STD_LOGIC_VECTOR(2 downto 0);
         clk           : in  STD_LOGIC;
         reset         : in  STD_LOGIC;
			data_in_ready : in  STD_LOGIC;
         ready         : out STD_LOGIC;
         output        : out STD_LOGIC_VECTOR(31 downto 0)
    );
    END COMPONENT;
    

   --Inputs
   signal input         : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
   signal ctrl          : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
   signal clk           : STD_LOGIC := '0';
   signal reset         : STD_LOGIC := '0';
	signal data_in_ready : STD_LOGIC := '0';

 	--Outputs
   signal ready  : STD_LOGIC;
   signal output : STD_LOGIC_VECTOR(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ModExp PORT MAP (
          input => input,
          ctrl => ctrl,
          clk => clk,
          reset => reset,
			 data_in_ready => data_in_ready,
          ready => ready,
          output => output
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      reset <= '1';
      wait for 100 ns;	
		reset <= '0';
      wait for clk_period*10;

---- Preparation for test case 1 -----------------
--    base        = 123456789 in decimal
--                = 0x75bcd15 in hexadecimal
--    exponent    = 654321    in decimal
--                = 0x9fbf1   in hexhexadecimal
--    modulus     = 2147483659 in decimal
--                = 0x8000000b in hexhexadecimal
--    expected_result = 347621222 in decimal,  
--               in hex 0x14b84766
--    power_mod(
--         123456789,
--         654321,
--         2147483659
--      ) = 
--        = 347621222
--        = 0x14b84766 in hexadecimal
--    where 484 is the residuum
--------------------------------------------------
		
		data_in_ready <= '1';
		ctrl <= mn_read_base;
		input <= x"075bcd15";
		wait for clk_period*2;
		
		ctrl <= mn_read_modulus;
		input <= x"8000000b";
		wait for clk_period*2;
		
		ctrl <= mn_read_exponent;
		input <= x"0009fbf1";
		wait for clk_period*2;
		
		ctrl <= mn_read_residuum;
		input <= x"000001e4";
		wait for clk_period*2;
		
		ctrl <= mn_count_power;
		
		wait until ready = '1' and clk = '0';
		
	   if output /= x"14b84766" then
		 report "RESULT MISMATCH! Test case 1 failed" severity ERROR;
		 assert false severity failure;
	   else
		 report "Test case 1 successful" severity note;	
	   end if;
		
		ctrl <= mn_show_result;
		wait for clk_period*10;
		
		ctrl <= mn_prepare_for_data;
		wait for clk_period*10;
	
---- Preparation for test case 2 -----------------
--    base        = 17654321 in decimal
--                = 10d6231 in hexadecimal
--    exponent    = 434342 in decimal
--                = 6a0a6 in hexhexadecimal
--    modulus     = 2147483693 in decimal
--                = 0x8000002d in hexhexadecimal
--    expected_result = 1290319095 in decimal,  
--               in hex 0x4ce8b4f7
--    power_mod(
--         17654321,
--         434342,
--         2147483693
--      ) = 
--        = 1290319095
--        = 0x4ce8b4f7 in hexadecimal
--    where 8100 is the residuum
--------------------------------------------------		
		
		ctrl <= mn_read_base;
		input <= x"010d6231";
		wait for clk_period*2;
		
		ctrl <= mn_read_modulus;
		input <= x"8000002d";
		wait for clk_period*2;
		
		ctrl <= mn_read_exponent;
		input <= x"0006a0a6";
		wait for clk_period*2;
		
		ctrl <= mn_read_residuum;
		input <= x"00001fa4";
		wait for clk_period*2;
		
		ctrl <= mn_count_power;

		wait until ready = '1' and clk = '0';
		
	   if output /= x"4ce8b4f7" then
		 report "RESULT MISMATCH! Test case 2 failed" severity ERROR;
		 assert false severity failure;
	   else
		 report "Test case 2 successful" severity note;	
	   end if;

		ctrl <= mn_show_result;
		wait for clk_period*10;
		ctrl <= mn_prepare_for_data;
		wait for clk_period*10;

      assert false severity failure;
   end process;

END;
