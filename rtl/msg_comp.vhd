
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

entity msg_comp is
        port(clk  : in std_logic;
             rst : in std_logic;
				 
				 h_0 : in std_logic_vector(31 downto 0);
				 h_1 : in std_logic_vector(31 downto 0);
				 h_2 : in std_logic_vector(31 downto 0);  
				 h_3 : in std_logic_vector(31 downto 0);
				 h_4 : in std_logic_vector(31 downto 0);
			    h_5 : in std_logic_vector(31 downto 0);
			    h_6 : in std_logic_vector(31 downto 0);
				 h_7 : in std_logic_vector(31 downto 0);
				 	 	 
			    w_i : in std_logic_vector(31 downto 0);
				 k_i : in std_logic_vector(31 downto 0);
				 
				 a : out std_logic_vector(31 downto 0);
				 b : out std_logic_vector(31 downto 0);
				 c : out std_logic_vector(31 downto 0);
				 d : out std_logic_vector(31 downto 0);
				 e : out std_logic_vector(31 downto 0);
				 f : out std_logic_vector(31 downto 0);
				 g : out std_logic_vector(31 downto 0);
				 h : out std_logic_vector(31 downto 0));
end msg_comp;

architecture structural of msg_comp is

        component ff_bank is
			port(clk : in std_logic;
				  d   : in std_logic_vector(31 downto 0);
              q   : out std_logic_vector(31 downto 0));
        end component;

	signal d_a_tmp : std_logic_vector(31 downto 0);
	signal d_b_tmp : std_logic_vector(31 downto 0);
	signal d_c_tmp : std_logic_vector(31 downto 0);
	signal d_d_tmp : std_logic_vector(31 downto 0);
	signal d_e_tmp : std_logic_vector(31 downto 0);
	signal d_f_tmp : std_logic_vector(31 downto 0);
	signal d_g_tmp : std_logic_vector(31 downto 0);
	signal d_h_tmp : std_logic_vector(31 downto 0);
	
	signal q_a_tmp : std_logic_vector(31 downto 0);
	signal q_b_tmp : std_logic_vector(31 downto 0);
	signal q_c_tmp : std_logic_vector(31 downto 0);
	signal q_d_tmp : std_logic_vector(31 downto 0);
	signal q_e_tmp : std_logic_vector(31 downto 0);
	signal q_f_tmp : std_logic_vector(31 downto 0);
	signal q_g_tmp : std_logic_vector(31 downto 0);
	signal q_h_tmp : std_logic_vector(31 downto 0);
	
	signal t_1, t_2 : std_logic_vector(31 downto 0);
	
begin

	mux_ff_a:process(rst, h_0, t_1, t_2)
	begin
			if rst = '1' then
				d_a_tmp <= h_0;
			else
				d_a_tmp <= std_logic_vector(unsigned(t_1) + unsigned(t_2));
			end if;
	end process;

	mux_ff_b:process(rst, h_1, q_a_tmp)
	begin
			if rst = '1' then
				d_b_tmp <= h_1;
			else
				d_b_tmp <= q_a_tmp;
			end if;
	end process;

	mux_ff_c:process(rst, h_2, q_b_tmp)
	begin
			if rst = '1' then
				d_c_tmp <= h_2;
			else
				d_c_tmp <= q_b_tmp;
			end if;
	end process;

	mux_ff_d:process(rst, h_3, q_c_tmp)
	begin
			if rst = '1' then
				d_d_tmp <= h_3;
			else
				d_d_tmp <= q_c_tmp;
			end if;
	end process;

	mux_ff_e:process(rst, h_4, q_d_tmp, t_1)
	begin
			if rst = '1' then
				d_e_tmp <= h_4;
			else
				d_e_tmp <= std_logic_vector(unsigned(q_d_tmp) + unsigned(t_1));
			end if;
	end process;
	
	mux_ff_f:process(rst, h_5, q_e_tmp)
	begin
			if rst = '1' then
				d_f_tmp <= h_5;
			else
				d_f_tmp <= q_e_tmp;
			end if;
	end process;

	mux_ff_g:process(rst, h_6, q_f_tmp)
	begin
			if rst = '1' then
				d_g_tmp <= h_6;
			else
				d_g_tmp <= q_f_tmp;
			end if;
	end process;

	mux_ff_h:process(rst, h_7, q_g_tmp)
	begin
			if rst = '1' then
				d_h_tmp <= h_7;
			else
				d_h_tmp <= q_g_tmp;
			end if;
	end process;
	
	ff_a : ff_bank port map (clk, d_a_tmp, q_a_tmp);
	ff_b : ff_bank port map (clk, d_b_tmp, q_b_tmp);
	ff_c : ff_bank port map (clk, d_c_tmp, q_c_tmp);
	ff_d : ff_bank port map (clk, d_d_tmp, q_d_tmp);
	ff_e : ff_bank port map (clk, d_e_tmp, q_e_tmp);
	ff_f : ff_bank port map (clk, d_f_tmp, q_f_tmp);
	ff_g : ff_bank port map (clk, d_g_tmp, q_g_tmp);
	ff_h : ff_bank port map (clk, d_h_tmp, q_h_tmp);
		
	a <= d_a_tmp;
	b <= d_b_tmp;
	c <= d_c_tmp;
	d <= d_d_tmp;
	e <= d_e_tmp;
	f <= d_f_tmp;
	g <= d_g_tmp;
	h <= d_h_tmp;
	
	
	t_1 <= std_logic_vector(unsigned(q_h_tmp) + 
			 unsigned(sum_1(q_e_tmp)) + 
			 unsigned(chi(q_e_tmp, q_f_tmp, q_g_tmp)) +
			 unsigned(k_i) + 
			 unsigned(w_i)); 
	
	t_2 <= std_logic_vector(unsigned(sum_0(q_a_tmp)) +
			 unsigned(maj(q_a_tmp, q_b_tmp, q_c_tmp)));
		
end structural;
