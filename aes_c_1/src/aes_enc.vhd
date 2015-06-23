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
		  rst : in std_logic;
		  block_in : in std_logic_vector(127 downto 0);
		  sub_key : in std_logic_vector(127 downto 0);
		  load : in std_logic;
		  enc : in std_logic;
		  last : in std_logic;
		  
		  block_out : out std_logic_vector(127 downto 0));		  
	end aes_enc;

architecture Behavioral of aes_enc is
	signal reg: std_logic_vector(127 downto 0);
	signal key_reg_delayed: std_logic_vector(127 downto 0);

	signal sub_tmp_0 : std_logic_vector(7 downto 0);
	signal sub_tmp_1 : std_logic_vector(7 downto 0);
	signal sub_tmp_2 : std_logic_vector(7 downto 0);
	signal sub_tmp_3 : std_logic_vector(7 downto 0);

	signal sub_tmp_mix_0 : std_logic_vector(7 downto 0);
	signal sub_tmp_mix_1 : std_logic_vector(7 downto 0);
	signal sub_tmp_mix_2 : std_logic_vector(7 downto 0);
	signal sub_tmp_mix_3 : std_logic_vector(7 downto 0);

	signal sub_tmp_key_0 : std_logic_vector(7 downto 0);
	signal sub_tmp_key_1 : std_logic_vector(7 downto 0);
	signal sub_tmp_key_2 : std_logic_vector(7 downto 0);
	signal sub_tmp_key_3 : std_logic_vector(7 downto 0);

	signal key_reg : std_logic_vector(127 downto 0);	
begin

	S_BOX_DUAL_1: entity work.dual_mem(rtl) port map (clk, '0', reg(7 downto 0),   reg(15 downto 8), (others=>'0'), sub_tmp_0, sub_tmp_1);
	S_BOX_DUAL_2: entity work.dual_mem(rtl) port map (clk, '0', reg(23 downto 16), reg(31 downto 24), (others=>'0'), sub_tmp_2, sub_tmp_3);


	sum_proc_1: process(clk, rst, block_in, sub_key)
		variable reg_v : std_logic_vector(127 downto 0);
		variable key_reg_v : std_logic_vector(127 downto 0);
	begin
		if rising_edge(clk) then
			if rst = '1' then
				reg_v := (others=>'0');
				key_reg_v := (others=>'0');
			elsif load = '1' then
			        
			        
                                -- The current state is arranged to:
			        -- { 0,5,a,f; 4,9,e,3; 8,d,2,7; c,1,6,b; } as
			        -- Gaj & Chodowiec describe in "FPGA and ASIC Implementations of AES" from
			        -- Cryptographic Engineering, Çetin Kaya Koç, Springer, 2009.
			        
				reg_v := block_in(95 downto 88)   &   block_in(55 downto 48)   & block_in(15 downto 8)    & block_in(103 downto 96) & -- (b,6,1,c)
					 block_in(63 downto 56)   &   block_in(23 downto 16)   & block_in(111 downto 104) & block_in(71 downto 64)  & -- (7,2,d,8)
					 block_in(31 downto 24)   &   block_in(119 downto 112) & block_in(79 downto 72)   & block_in(39 downto 32)  & -- (3,e,9,4)
					 block_in(127 downto 120) &   block_in(87 downto 80)   & block_in(47 downto 40)   & block_in(7 downto 0);     -- (f,a,5,0) 

				key_reg_v := sub_key; 	 
			elsif enc = '1' then
        			reg_v := to_stdlogicvector(to_bitvector(reg_v) ror 32);
	        		key_reg_v := to_stdlogicvector(to_bitvector(key_reg_v) ror 32);
			end if;	
		end if;
		
		reg <= reg_v;
		key_reg <= key_reg_v;
		
	end process;

	MIX_COL: process(sub_tmp_0, sub_tmp_1, sub_tmp_2, sub_tmp_3, last)
	begin
	        if last = '0' then
	                sub_tmp_mix_0 <= gfmult2(sub_tmp_0) xor gfmult3(sub_tmp_1) xor sub_tmp_2 xor sub_tmp_3; 
	                sub_tmp_mix_1 <= sub_tmp_0 xor gfmult2(sub_tmp_1) xor gfmult3(sub_tmp_2) xor sub_tmp_3;
	                sub_tmp_mix_2 <= sub_tmp_0 xor sub_tmp_1 xor gfmult2(sub_tmp_2) xor gfmult3(sub_tmp_3);
	                sub_tmp_mix_3 <= gfmult3(sub_tmp_0) xor sub_tmp_1 xor sub_tmp_2 xor gfmult2(sub_tmp_3);
	        else
	                sub_tmp_mix_0 <= sub_tmp_0; 
	                sub_tmp_mix_1 <= sub_tmp_1;
	                sub_tmp_mix_2 <= sub_tmp_2;
	                sub_tmp_mix_3 <= sub_tmp_3;
	        end if;        
	end process;

	ADD_KEY: process(key_reg_delayed, sub_tmp_mix_0, sub_tmp_mix_1, sub_tmp_mix_2, sub_tmp_mix_3)
	begin
	        sub_tmp_key_0 <= sub_tmp_mix_0 xor key_reg_delayed(7 downto 0); 
	        sub_tmp_key_1 <= sub_tmp_mix_1 xor key_reg_delayed(15 downto 8);
	        sub_tmp_key_2 <= sub_tmp_mix_2 xor key_reg_delayed(23 downto 16);
	        sub_tmp_key_3 <= sub_tmp_mix_3 xor key_reg_delayed(31 downto 24);
        end process;

        FF_DELAY: process(clk, key_reg)
        begin
                if rising_edge(clk) then
                        key_reg_delayed <= key_reg;
                end if;
        end process;
        
        gen_output: process(enc, clk, sub_tmp_key_0, sub_tmp_key_1, sub_tmp_key_2, sub_tmp_key_3)
                variable out_buffer_v : std_logic_vector(127 downto 0);
        begin
                if rising_edge(clk) then
                        if enc = '1' then
                                out_buffer_v := out_buffer_v(127 downto 32) & sub_tmp_key_3 & sub_tmp_key_2 & sub_tmp_key_1 & sub_tmp_key_0;
                                out_buffer_v := to_stdlogicvector(to_bitvector(out_buffer_v) ror 32);
                        end if;
                end if;
                
                block_out <= out_buffer_v;
                
        end process;

end Behavioral;

