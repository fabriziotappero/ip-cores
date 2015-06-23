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
----   with the 512 bit width.                                     ----
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
 
ENTITY ModExp512bitTB IS
END ModExp512bitTB;
 
ARCHITECTURE behavior OF ModExp512bitTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ModExp
    PORT(
         input         : in   STD_LOGIC_VECTOR(511 downto 0);
         ctrl          : in   STD_LOGIC_VECTOR(2 downto 0);
         clk           : in   STD_LOGIC;
         reset         : in   STD_LOGIC;
         data_in_ready : in   STD_LOGIC;
         ready         : out  STD_LOGIC;
         output        : out  STD_LOGIC_VECTOR(511 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal input         : STD_LOGIC_VECTOR(511 downto 0) := (others => '0');
   signal ctrl          : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
   signal clk           : STD_LOGIC := '0';
   signal reset         : STD_LOGIC := '0';
   signal data_in_ready : STD_LOGIC := '0';

 	--Outputs
   signal ready  : STD_LOGIC;
   signal output : STD_LOGIC_VECTOR(511 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ModExp PORT MAP (
          input         => input,
          ctrl          => ctrl,
          clk           => clk,
          reset         => reset,
          data_in_ready => data_in_ready,
          ready         => ready,
          output        => output
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
--    base        = 409173825987017733751648542997566029938148046617392981389751408119740010106823408957031501223019018303621410623709446515603337041483208280918267736985 in decimal
--                = 0x1ffffffffffffffffffff003031300d060960864801650304020105000420f75db0d45d3189d910fc5d782745578c59481accf6f7cbf5e79bdecbe5233399 in hexadecimal
--    exponent    = 4991398326204141236652697335767169457643189913066361675852469427068576791337775798287514344957972397666876518042551243608843475377858636774161719825165098 in decimal
--                = 0x5f4d7261a28d1e9c9a45059eb0ce9122f6840ec7878d2d2a87057fb15db61eac7a37af6b0cb80f0001870b2a29e350f7b052cc89f1c7fbed07926640d6926b2a in hexhexadecimal
--    modulus     = 7630362531884975956392615644472323592768112181489355162005628253173318027895577525003064336256778044210380071348425604079063304117213210643679811834656203 in decimal
--                = 0x91b06f65a203bebb1cfa1b065cb2142e3771d113024a902f0829be8effe539ff6caa7c4b7f87e1913481e8c4f88a3f3e27a853179119aa029fe00e4c45a6b5cb in hexhexadecimal
--    expected_result = 1030188469358454649940099943953262093153216946958355916901057176262906329079894663437512624898962713254938994365603039233579679436863344699542897702118673 in decimal,  
--               in hex 13ab74d318c919ec6faa10bea70211d4a981e7c31fc5205a8bb28e754ea59bcdd7459d6880758653918e72376c061177fdd51e72bece6815aa24001bda6ea511
--    power_mod(
--         409173825987017733751648542997566029938148046617392981389751408119740010106823408957031501223019018303621410623709446515603337041483208280918267736985,
--         4991398326204141236652697335767169457643189913066361675852469427068576791337775798287514344957972397666876518042551243608843475377858636774161719825165098,
--         7630362531884975956392615644472323592768112181489355162005628253173318027895577525003064336256778044210380071348425604079063304117213210643679811834656203
--      ) = 
--        = 1030188469358454649940099943953262093153216946958355916901057176262906329079894663437512624898962713254938994365603039233579679436863344699542897702118673
--        = 13ab74d318c919ec6faa10bea70211d4a981e7c31fc5205a8bb28e754ea59bcdd7459d6880758653918e72376c061177fdd51e72bece6815aa24001bda6ea511 in hexadecimal
--    where 1398454690893823236632472980512935706632382980363069616905016603014572888067778885889245016848922097099694154000460402372958600055088633374563202044624216 is the residuum
--------------------------------------------------
		
		data_in_ready <= '1';
		ctrl <= mn_read_base;
		input <= x"0001ffffffffffffffffffff003031300d060960864801650304020105000420f75db0d45d3189d910fc5d782745578c59481accf6f7cbf5e79bdecbe5233399";
		wait for clk_period*2;
		
		ctrl <= mn_read_modulus;
		input <= x"91b06f65a203bebb1cfa1b065cb2142e3771d113024a902f0829be8effe539ff6caa7c4b7f87e1913481e8c4f88a3f3e27a853179119aa029fe00e4c45a6b5cb";
		wait for clk_period*2;
		
		ctrl <= mn_read_exponent;
		input <= x"5f4d7261a28d1e9c9a45059eb0ce9122f6840ec7878d2d2a87057fb15db61eac7a37af6b0cb80f0001870b2a29e350f7b052cc89f1c7fbed07926640d6926b2a";
		wait for clk_period*2;
		
		ctrl <= mn_read_residuum;
		input <= "00011010101100111000000100001111010111001110011000001010110100001111011110111000011110111011111111011111011001111011010101010101010110010011001000010110100100100000010000100101001111011100001101111011001011010100011101100100011100101001110000101011100100101110111100101110011111101000111100101010100010000100011111010101111000100111101101011011000010111010011011000100000101001000111011010110110100001111001100001110001111111110000000011001010101111000101010101000110111011000110110110000000100010111110101011000";
		wait for clk_period*2;
		
		ctrl <= mn_count_power;
		
		report "Please wait. It may take up ro few minutes..." severity note;
		
	   wait until ready = '1' and clk = '0';
		
	   if output /= x"13ab74d318c919ec6faa10bea70211d4a981e7c31fc5205a8bb28e754ea59bcdd7459d6880758653918e72376c061177fdd51e72bece6815aa24001bda6ea511" then
		 report "RESULT MISMATCH! Test case 1 failed" severity ERROR;
		 assert false severity failure;
	   else
		 report "Test case 1 successful" severity note;	
	   end if;
		
	   ctrl <= mn_show_result;
	   wait for clk_period*10;
		
	   ctrl <= mn_prepare_for_data;
	   wait for clk_period*2;

---- Preparation for test case 2 -----------------
--    base        = 3273390607896141870013189696827599152216642046043064789483291368096133796404674554883270092325904157150886684127560071009217256545885393053328527589431 in decimal
--                = 0x100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000037 in hexadecimal
--    exponent    = 622376668989630299558359971768444342820680304013329676986135064534413345603604938346345762083389451304101819605682193623416033951320823027994905238921170 in decimal
--                = 0xbe21d214053f66c3e101fd875b531ecaccca3befca14d989ae2ffe4d6bbf1a3df0c694dc4c83af61ee3cf7c7bc97c9d6844d5d1fe428105082910c637c55fd2 in hexhexadecimal
--    modulus     = 3351951982485649274893506249551461531869841455148098344430890360930446855046914914263767984168972974033957028381338463851007479808527777429670210341401251 in decimal
--                = 0x400000000000000000000000000000000000000000000000000000000302929200000000000000000000000000000000000000000000000000005af3fbdb72a3 in hexhexadecimal
--    expected_result = 1135574785903187283000914738069914842639275616893687122668359807022003618585980215260939798952644749528921700342000274265548842002316414917974647561961683 in decimal,  
--               in hex 15ae92ed25cdbb29458414ad1a28fa35f5bfc311d7e1efedba753e48ccee1e9ff1d160714449bf6f85a0e3fe0784548b3c461ac5fbf28b7a1c3c83f4dff6c0d3
--    power_mod(
--        3273390607896141870013189696827599152216642046043064789483291368096133796404674554883270092325904157150886684127560071009217256545885393053328527589431,
--        622376668989630299558359971768444342820680304013329676986135064534413345603604938346345762083389451304101819605682193623416033951320823027994905238921170,
--        3351951982485649274893506249551461531869841455148098344430890360930446855046914914263767984168972974033957028381338463851007479808527777429670210341401251
--      ) = 
--        = 1135574785903187283000914738069914842639275616893687122668359807022003618585980215260939798952644749528921700342000274265548842002316414917974647561961683
--        = 15ae92ed25cdbb29458414ad1a28fa35f5bfc311d7e1efedba753e48ccee1e9ff1d160714449bf6f85a0e3fe0784548b3c461ac5fbf28b7a1c3c83f4dff6c0d3 in hexadecimal
--    where 3351951982485649274893506249551461531869841455148097408724357100071878499222574108103974817495155088879387961281773763412796138005544310585710276679277619 is the residuum
--------------------------------------------------


		ctrl <= mn_read_base;
		input <= x"00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000037";
		wait for clk_period*2;
		
		ctrl <= mn_read_modulus;
		input <= x"400000000000000000000000000000000000000000000000000000000302929200000000000000000000000000000000000000000000000000005af3fbdb72a3";
		wait for clk_period*2;
		
		ctrl <= mn_read_exponent;
		input <= x"0be21d214053f66c3e101fd875b531ecaccca3befca14d989ae2ffe4d6bbf1a3df0c694dc4c83af61ee3cf7c7bc97c9d6844d5d1fe428105082910c637c55fd2";
		wait for clk_period*2;
		
		ctrl <= mn_read_residuum;
		input <= "00111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111001010100001100110001111100000111011101010001011101111101110101100000111111010100011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100110100000000001000000110110110010000010111000001100010111100011000101010110010110110111001110000110011";
		wait for clk_period*2;
		
		ctrl <= mn_count_power;
		
		report "Please wait. It may take up ro few minutes..." severity note;
		
		wait until ready = '1' and clk = '0';
		
	    if output /= x"15ae92ed25cdbb29458414ad1a28fa35f5bfc311d7e1efedba753e48ccee1e9ff1d160714449bf6f85a0e3fe0784548b3c461ac5fbf28b7a1c3c83f4dff6c0d3" then
		  report "RESULT MISMATCH! Test case 2 failed" severity ERROR;
		  assert false severity failure;
	    else
		  report "Test case 2 successful" severity note;	
	    end if;
		
		ctrl <= mn_show_result;
		wait for clk_period*10;
		
		ctrl <= mn_prepare_for_data;
		wait for clk_period*2;
		
       assert false severity failure;
   end process;

END;
