-- Copyright (c) 2011 Antonio de la Piedra
 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
                
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
                                
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

use work.aes_lib.all;

entity aes_enc is
	port(	  clk: in std_logic;
		  block_in : in std_logic_vector(127 downto 0);
		  sub_key : in std_logic_vector(127 downto 0);
		  last : in std_logic;
		  block_out : out std_logic_vector(127 downto 0));
	end aes_enc;

architecture Behavioral of aes_enc is

	signal sub_tmp_s   : std_logic_vector(127 downto 0);
	signal sub_tmp_mix : std_logic_vector(127 downto 0);

	signal test_2_1, test_2_2, test_2_3, test_2_4, test_2_5, test_2_6, test_2_7, test_2_8 : std_logic_vector(7 downto 0);
	signal test_2_9, test_2_10, test_2_11, test_2_12, test_2_13, test_2_14, test_2_15, test_2_16 : std_logic_vector(7 downto 0);
	signal test_3_1, test_3_2, test_3_3, test_3_4, test_3_5, test_3_6, test_3_7, test_3_8 : std_logic_vector(7 downto 0);
	signal test_3_9, test_3_10, test_3_11, test_3_12, test_3_13, test_3_14, test_3_15, test_3_16 : std_logic_vector(7 downto 0);

	signal sub_key_delay, sub_tmp_s_delay, sub_tmp_s_delay_1, sub_tmp_mix_delay : std_logic_vector(127 downto 0);
begin

	S_BOX_DUAL_1: entity work.dual_mem(rtl) port map (clk, '0', block_in(7 downto 0),     block_in(47 downto 40), (others=>'0'),    sub_tmp_s(7 downto 0),  sub_tmp_s(15 downto 8));
	S_BOX_DUAL_2: entity work.dual_mem(rtl) port map (clk, '0', block_in(87 downto 80),   block_in(127 downto 120), (others=>'0'),  sub_tmp_s(23 downto 16),  sub_tmp_s(31 downto 24));
	S_BOX_DUAL_3: entity work.dual_mem(rtl) port map (clk, '0', block_in(39 downto 32),   block_in(79 downto 72), (others=>'0'),   sub_tmp_s(39 downto 32),  sub_tmp_s(47 downto 40));
	S_BOX_DUAL_4: entity work.dual_mem(rtl) port map (clk, '0', block_in(119 downto 112),   block_in(31 downto 24), (others=>'0'),   sub_tmp_s(55 downto 48),  sub_tmp_s(63 downto 56));
	S_BOX_DUAL_5: entity work.dual_mem(rtl) port map (clk, '0', block_in(71 downto 64),   block_in(111 downto 104), (others=>'0'),   sub_tmp_s(71 downto 64),  sub_tmp_s(79 downto 72));
	S_BOX_DUAL_6: entity work.dual_mem(rtl) port map (clk, '0', block_in(23 downto 16),   block_in(63 downto 56), (others=>'0'),   sub_tmp_s(87 downto 80), sub_tmp_s(95 downto 88));
	S_BOX_DUAL_7: entity work.dual_mem(rtl) port map (clk, '0', block_in(103 downto 96),  block_in(15 downto 8), (others=>'0'), sub_tmp_s(103 downto 96), sub_tmp_s(111 downto 104));
	S_BOX_DUAL_8: entity work.dual_mem(rtl) port map (clk, '0', block_in(55 downto 48), block_in(95 downto 88), (others=>'0'), sub_tmp_s(119 downto 112), sub_tmp_s(127 downto 120));

	GF_MULT_2_1: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(7 downto 0), sub_tmp_s(15 downto 8), (others=>'0'), test_2_1, test_2_2);
	GF_MULT_2_2: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(23 downto 16), sub_tmp_s(31 downto 24), (others=>'0'), test_2_3, test_2_4);
	GF_MULT_2_3: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(39 downto 32), sub_tmp_s(47 downto 40), (others=>'0'), test_2_5, test_2_6);
	GF_MULT_2_4: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(55 downto 48), sub_tmp_s(63 downto 56), (others=>'0'), test_2_7, test_2_8);
	GF_MULT_2_5: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(71 downto 64), sub_tmp_s(79 downto 72), (others=>'0'), test_2_9, test_2_10);
	GF_MULT_2_6: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(87 downto 80), sub_tmp_s(95 downto 88), (others=>'0'), test_2_11, test_2_12);
	GF_MULT_2_7: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(103 downto 96), sub_tmp_s(111 downto 104), (others=>'0'), test_2_13, test_2_14);
	GF_MULT_2_8: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(119 downto 112), sub_tmp_s(127 downto 120), (others=>'0'), test_2_15, test_2_16);

	GF_MULT_3_1: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(7 downto 0), sub_tmp_s(15 downto 8), (others=>'0'), test_3_4, test_3_1);
	GF_MULT_3_2: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(23 downto 16), sub_tmp_s(31 downto 24), (others=>'0'), test_3_2, test_3_3);
	GF_MULT_3_3: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(39 downto 32), sub_tmp_s(47 downto 40), (others=>'0'), test_3_8, test_3_5);
	GF_MULT_3_4: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(55 downto 48), sub_tmp_s(63 downto 56), (others=>'0'), test_3_6, test_3_7);
	GF_MULT_3_5: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(71 downto 64), sub_tmp_s(79 downto 72), (others=>'0'), test_3_12, test_3_9);
	GF_MULT_3_6: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(87 downto 80), sub_tmp_s(95 downto 88), (others=>'0'), test_3_10, test_3_11);
	GF_MULT_3_7: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(103 downto 96), sub_tmp_s(111 downto 104), (others=>'0'), test_3_16, test_3_13);
	GF_MULT_3_8: entity work.dual_mem(rtl) port map (clk, '0', sub_tmp_s(119 downto 112), sub_tmp_s(127 downto 120), (others=>'0'), test_3_14, test_3_15);

	MIX_COL: process(test_2_1, 
                         test_2_2,
                         test_2_3,
                         test_2_4,
                         test_2_5,
                         test_2_6,
                         test_2_7,
                         test_2_8,
                         test_2_9,
                         test_2_10,
                         test_2_11,
                         test_2_12,
                         test_2_13,
                         test_2_14,
                         test_2_15,
                         test_2_16,
                         test_3_1,
                         test_3_2,
                         test_3_3,
                         test_3_4,
                         test_3_5,
                         test_3_6,
                         test_3_7,
                         test_3_8,
                         test_3_9,
                         test_3_10,
                         test_3_11,
                         test_3_12,
                         test_3_13,
                         test_3_14,
                         test_3_15,
                         test_3_16,
                         sub_tmp_s,
                         last)	
	begin
	        if last = '0' then

	                sub_tmp_mix(7 downto 0)  <= test_2_1 xor test_3_1 xor sub_tmp_s(23 downto 16) xor sub_tmp_s(31 downto 24);
	                sub_tmp_mix(15 downto 8) <= sub_tmp_s(7 downto 0) xor test_2_2 xor test_3_2 xor sub_tmp_s(31 downto 24);
	                sub_tmp_mix(23 downto 16) <= sub_tmp_s(7 downto 0) xor sub_tmp_s(15 downto 8) xor test_2_3 xor test_3_3;
	                sub_tmp_mix(31 downto 24) <= test_3_4 xor sub_tmp_s(15 downto 8) xor sub_tmp_s(23 downto 16) xor test_2_4;
	        
	                sub_tmp_mix(39 downto 32) <= test_2_5 xor test_3_5 xor sub_tmp_s(55 downto 48) xor sub_tmp_s(63 downto 56); 
	                sub_tmp_mix(47 downto 40) <= sub_tmp_s(39 downto 32) xor test_2_6 xor test_3_6 xor sub_tmp_s(63 downto 56);
	                sub_tmp_mix(55 downto 48) <= sub_tmp_s(39 downto 32) xor sub_tmp_s(47 downto 40) xor test_2_7 xor test_3_7;
	                sub_tmp_mix(63 downto 56) <= test_3_8 xor sub_tmp_s(47 downto 40) xor sub_tmp_s(55 downto 48) xor test_2_8;
	        
	                sub_tmp_mix(71 downto 64) <= test_2_9 xor test_3_9 xor sub_tmp_s(87 downto 80) xor sub_tmp_s(95 downto 88); 
	                sub_tmp_mix(79 downto 72) <= sub_tmp_s(71 downto 64) xor test_2_10 xor test_3_10 xor sub_tmp_s(95 downto 88);
	                sub_tmp_mix(87 downto 80) <= sub_tmp_s(71 downto 64) xor sub_tmp_s(79 downto 72) xor test_2_11 xor test_3_11;
	                sub_tmp_mix(95 downto 88) <= test_3_12 xor sub_tmp_s(79 downto 72) xor sub_tmp_s(87 downto 80) xor test_2_12;
	        
	                sub_tmp_mix(103 downto 96) <= test_2_13 xor test_3_13 xor sub_tmp_s(119 downto 112) xor sub_tmp_s(127 downto 120); 
	                sub_tmp_mix(111 downto 104) <= sub_tmp_s(103 downto 96) xor test_2_14 xor test_3_14 xor sub_tmp_s(127 downto 120);
	                sub_tmp_mix(119 downto 112) <= sub_tmp_s(103 downto 96) xor sub_tmp_s(111 downto 104) xor test_2_15 xor test_3_15; 
	                sub_tmp_mix(127 downto 120) <= test_3_16 xor sub_tmp_s(111 downto 104) xor sub_tmp_s(119 downto 112) xor test_2_16;

	        else
	                sub_tmp_mix <= sub_tmp_s;
	                
	        end if;        
	end process;
                     
        block_out <= sub_tmp_mix xor sub_key;
        
end Behavioral;

