

-- Copyright (c) 2013 Antonio de la Piedra
 
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
use IEEE.NUMERIC_STD.ALL;
use work.sha_fun.ALL;

entity sh_reg is
        port(clk  : in std_logic;
             rst : in std_logic;
				 
				 msg_0 : in std_logic_vector(31 downto 0);
				 msg_1 : in std_logic_vector(31 downto 0);
				 msg_2 : in std_logic_vector(31 downto 0);  
				 msg_3 : in std_logic_vector(31 downto 0);
				 msg_4 : in std_logic_vector(31 downto 0);
			    msg_5 : in std_logic_vector(31 downto 0);
			    msg_6 : in std_logic_vector(31 downto 0);
				 msg_7 : in std_logic_vector(31 downto 0);
				 msg_8 : in std_logic_vector(31 downto 0);
				 msg_9 : in std_logic_vector(31 downto 0);
		       msg_10 : in std_logic_vector(31 downto 0);
		       msg_11 : in std_logic_vector(31 downto 0);
		       msg_12 : in std_logic_vector(31 downto 0);
		       msg_13 : in std_logic_vector(31 downto 0);
		       msg_14 : in std_logic_vector(31 downto 0);
		       msg_15 : in std_logic_vector(31 downto 0);   
				 	 
				 w_j : out std_logic_vector(31 downto 0));
end sh_reg;

architecture structural of sh_reg is

        component ff_bank is
			port(clk : in std_logic;
				  d   : in std_logic_vector(31 downto 0);
              q   : out std_logic_vector(31 downto 0));
        end component;

	signal d_0_tmp : std_logic_vector(31 downto 0);
	signal d_1_tmp : std_logic_vector(31 downto 0);
	signal d_2_tmp : std_logic_vector(31 downto 0);
	signal d_3_tmp : std_logic_vector(31 downto 0);
	signal d_4_tmp : std_logic_vector(31 downto 0);
	signal d_5_tmp : std_logic_vector(31 downto 0);
	signal d_6_tmp : std_logic_vector(31 downto 0);
	signal d_7_tmp : std_logic_vector(31 downto 0);
	signal d_8_tmp : std_logic_vector(31 downto 0);
	signal d_9_tmp : std_logic_vector(31 downto 0);
	signal d_10_tmp : std_logic_vector(31 downto 0);
	signal d_11_tmp : std_logic_vector(31 downto 0);
	signal d_12_tmp : std_logic_vector(31 downto 0);
	signal d_13_tmp : std_logic_vector(31 downto 0);
	signal d_14_tmp : std_logic_vector(31 downto 0);
	signal d_15_tmp : std_logic_vector(31 downto 0);
	
	signal q_0_tmp : std_logic_vector(31 downto 0);
	signal q_1_tmp : std_logic_vector(31 downto 0);
	signal q_2_tmp : std_logic_vector(31 downto 0);
	signal q_3_tmp : std_logic_vector(31 downto 0);
	signal q_4_tmp : std_logic_vector(31 downto 0);
	signal q_5_tmp : std_logic_vector(31 downto 0);
	signal q_6_tmp : std_logic_vector(31 downto 0);
	signal q_7_tmp : std_logic_vector(31 downto 0);
	signal q_8_tmp : std_logic_vector(31 downto 0);
	signal q_9_tmp : std_logic_vector(31 downto 0);
	signal q_10_tmp : std_logic_vector(31 downto 0);
	signal q_11_tmp : std_logic_vector(31 downto 0);
	signal q_12_tmp : std_logic_vector(31 downto 0);
	signal q_13_tmp : std_logic_vector(31 downto 0);
	signal q_14_tmp : std_logic_vector(31 downto 0);
	signal q_15_tmp : std_logic_vector(31 downto 0);
	
	signal w_j_tmp : std_logic_vector(31 downto 0);
	
begin

	mux_ff_0:process(rst, msg_0, w_j_tmp)
	begin
			if rst = '1' then
				d_0_tmp <= msg_0;
			else
				d_0_tmp <= w_j_tmp;
			end if;
	end process;

	mux_ff_1:process(rst, msg_1, q_0_tmp)
	begin
			if rst = '1' then
				d_1_tmp <= msg_1;
			else
				d_1_tmp <= q_0_tmp;
			end if;
	end process;

	mux_ff_2:process(rst, msg_2, q_1_tmp)
	begin
			if rst = '1' then
				d_2_tmp <= msg_2;
			else
				d_2_tmp <= q_1_tmp;
			end if;
	end process;

	mux_ff_3:process(rst, msg_3, q_2_tmp)
	begin
			if rst = '1' then
				d_3_tmp <= msg_3;
			else
				d_3_tmp <= q_2_tmp;
			end if;
	end process;

	mux_ff_4:process(rst, msg_4, q_3_tmp)
	begin
			if rst = '1' then
				d_4_tmp <= msg_4;
			else
				d_4_tmp <= q_3_tmp;
			end if;
	end process;
	
	mux_ff_5:process(rst, msg_5, q_4_tmp)
	begin
			if rst = '1' then
				d_5_tmp <= msg_5;
			else
				d_5_tmp <= q_4_tmp;
			end if;
	end process;

	mux_ff_6:process(rst, msg_6, q_5_tmp)
	begin
			if rst = '1' then
				d_6_tmp <= msg_6;
			else
				d_6_tmp <= q_5_tmp;
			end if;
	end process;

	mux_ff_7:process(rst, msg_7, q_6_tmp)
	begin
			if rst = '1' then
				d_7_tmp <= msg_7;
			else
				d_7_tmp <= q_6_tmp;
			end if;
	end process;

	mux_ff_8:process(rst, msg_8, q_7_tmp)
	begin
			if rst = '1' then
				d_8_tmp <= msg_8;
			else
				d_8_tmp <= q_7_tmp;
			end if;
	end process;

	mux_ff_9:process(rst, msg_9, q_8_tmp)
	begin
			if rst = '1' then
				d_9_tmp <= msg_9;
			else
				d_9_tmp <= q_8_tmp;
			end if;
	end process;

	mux_ff_10:process(rst, msg_10, q_9_tmp)
	begin
			if rst = '1' then
				d_10_tmp <= msg_10;
			else
				d_10_tmp <= q_9_tmp;
			end if;
	end process;

	mux_ff_11:process(rst, msg_11, q_10_tmp)
	begin
			if rst = '1' then
				d_11_tmp <= msg_11;
			else
				d_11_tmp <= q_10_tmp;
			end if;
	end process;

	mux_ff_12:process(rst, msg_12, q_11_tmp)
	begin
			if rst = '1' then
				d_12_tmp <= msg_12;
			else
				d_12_tmp <= q_11_tmp;
			end if;
	end process;

	mux_ff_13:process(rst, msg_13, q_12_tmp)
	begin
			if rst = '1' then
				d_13_tmp <= msg_13;
			else
				d_13_tmp <= q_12_tmp;
			end if;
	end process;

	mux_ff_14:process(rst, msg_14, q_13_tmp)
	begin
			if rst = '1' then
				d_14_tmp <= msg_14;
			else
				d_14_tmp <= q_13_tmp;
			end if;
	end process;

	mux_ff_15:process(rst, msg_15, q_14_tmp)
	begin
			if rst = '1' then
				d_15_tmp <= msg_15;
			else
				d_15_tmp <= q_14_tmp;
			end if;
	end process;	
	
	ff_0 : ff_bank port map (clk, d_0_tmp, q_0_tmp);
	ff_1 : ff_bank port map (clk, d_1_tmp, q_1_tmp);
	ff_2 : ff_bank port map (clk, d_2_tmp, q_2_tmp);
	ff_3 : ff_bank port map (clk, d_3_tmp, q_3_tmp);
	ff_4 : ff_bank port map (clk, d_4_tmp, q_4_tmp);
	ff_5 : ff_bank port map (clk, d_5_tmp, q_5_tmp);
	ff_6 : ff_bank port map (clk, d_6_tmp, q_6_tmp);
	ff_7 : ff_bank port map (clk, d_7_tmp, q_7_tmp);
	ff_8 : ff_bank port map (clk, d_8_tmp, q_8_tmp);
	ff_9 : ff_bank port map (clk, d_9_tmp, q_9_tmp);
	ff_10 : ff_bank port map (clk, d_10_tmp, q_10_tmp);
	ff_11 : ff_bank port map (clk, d_11_tmp, q_11_tmp);
	ff_12 : ff_bank port map (clk, d_12_tmp, q_12_tmp);
	ff_13 : ff_bank port map (clk, d_13_tmp, q_13_tmp);
	ff_14 : ff_bank port map (clk, d_14_tmp, q_14_tmp);	
	ff_15 : ff_bank port map (clk, d_15_tmp, q_15_tmp);	
	
	w_j_tmp <= std_logic_vector(unsigned(sigma_0(q_14_tmp)) + unsigned(q_15_tmp) +
			 unsigned(sigma_1(q_1_tmp)) + unsigned(q_6_tmp));
		
	w_j <= w_j_tmp;
	
end structural;
