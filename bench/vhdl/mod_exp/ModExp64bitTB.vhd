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
----   with the 64 bit width.                                      ----
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
 
ENTITY ModExp64bitTB IS
END ModExp64bitTB;
 
ARCHITECTURE behavior OF ModExp64bitTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ModExp
    PORT(
         input         : in  STD_LOGIC_VECTOR(63 downto 0);
         ctrl          : in  STD_LOGIC_VECTOR(2 downto 0);
         clk           : in  STD_LOGIC;
         reset         : in  STD_LOGIC;
			data_in_ready : in  STD_LOGIC;
         ready         : out STD_LOGIC;
         output        : out STD_LOGIC_VECTOR(63 downto 0)
    );
    END COMPONENT;
    

   --Inputs
   signal input         : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
   signal ctrl          : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
   signal clk           : STD_LOGIC := '0';
   signal reset         : STD_LOGIC := '0';
	signal data_in_ready : STD_LOGIC := '0';

 	--Outputs
   signal ready  : STD_LOGIC;
   signal output : STD_LOGIC_VECTOR(63 downto 0);

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
--    base        =  816881283968894723 in decimal
--                =  0xb56253322a18703  in hexadecimal
--    exponent    =  281474976710679    in decimal
--                =  0x1000000000017    in hexhexadecimal
--    modulus     =  4612794175830006917 in decimal
--                =  0x4003efdd00569c85    in hexhexadecimal
--    expected_result = 1851187696912577658 in decimal,  
--               in hex 19b0bd66ff0c347a
--    power_mod(
--         816881283968894723,
--         281474976710679,
--         4612794175830006917
--      ) = 
--        = 1851187696912577658
--        = 19b0bd66ff0c347a in hexadecimal
--    where 1762515348761952014 is the residuum
--------------------------------------------------
		
		data_in_ready <= '1';
		ctrl <= mn_read_base;
		input <= x"0b56253322a18703";
		wait for clk_period*2;
		
		ctrl <= mn_read_modulus;
		input <= x"4003efdd00569c85";
		wait for clk_period*2;
		
		ctrl <= mn_read_exponent;
		input <= x"0001000000000017";
		wait for clk_period*2;
		
		ctrl <= mn_read_residuum;
		input <= "0001100001110101101101100101111100011010001000010011111100001110";
		wait for clk_period*2;
		
		ctrl <= mn_count_power;
		
		wait until ready = '1' and clk = '0';
		
	   if output /= x"19b0bd66ff0c347a" then
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
--    base        = 816881283968894722 in decimal
--                = 0xb56253322a18702 in hexadecimal
--    exponent    = 281474976710678 in decimal
--                = 0x1000000000016 in hexhexadecimal
--    modulus     = 4612794175830006917 in decimal
--                = 0x4003efdd00569c85 in hexhexadecimal
--    expected_result = 3178815025358931436 in decimal,  
--               in hex 2c1d6b6c693185ec
--    power_mod(
--         816881283968894722,
--         281474976710678,
--         4612794175830006917
--      ) = 
--        = 3178815025358931436
--        = 2c1d6b6c693185ec in hexadecimal
--    where 1762515348761952014 is the residuum
--------------------------------------------------		
		
		ctrl <= mn_read_base;
		input <= x"0b56253322a18702";
		wait for clk_period*2;
		
		ctrl <= mn_read_modulus;
		input <= x"4003efdd00569c85";
		wait for clk_period*2;
		
		ctrl <= mn_read_exponent;
		input <= x"0001000000000016";
		wait for clk_period*2;
		
		ctrl <= mn_read_residuum;
		input <= "0001100001110101101101100101111100011010001000010011111100001110";
		wait for clk_period*2;
		
		ctrl <= mn_count_power;

		wait until ready = '1' and clk = '0';
		
	   if output /= x"2c1d6b6c693185ec" then
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
