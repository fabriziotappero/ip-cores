
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

entity noekeon is
	port(clk     : in std_logic;
		  rst     : in std_logic;
		  enc     : in std_logic; -- (enc, 0) / (dec, 1)
		  a_0_in  : in std_logic_vector(31 downto 0);
		  a_1_in  : in std_logic_vector(31 downto 0);
		  a_2_in  : in std_logic_vector(31 downto 0);
		  a_3_in  : in std_logic_vector(31 downto 0);		
		  k_0_in  : in std_logic_vector(31 downto 0);
		  k_1_in  : in std_logic_vector(31 downto 0);
		  k_2_in  : in std_logic_vector(31 downto 0);
		  k_3_in  : in std_logic_vector(31 downto 0);
		  a_0_out : out std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0);
		  a_2_out : out std_logic_vector(31 downto 0);
		  a_3_out : out std_logic_vector(31 downto 0));
end noekeon;

architecture Behavioral of noekeon is

	component round_f is
	port(clk     : in std_logic;
	     enc : in std_logic;
		  rc_in   : in std_logic_vector(31 downto 0);
		  a_0_in  : in std_logic_vector(31 downto 0);
		  a_1_in  : in std_logic_vector(31 downto 0);
		  a_2_in  : in std_logic_vector(31 downto 0);
		  a_3_in  : in std_logic_vector(31 downto 0);		
		  k_0_in  : in std_logic_vector(31 downto 0);
		  k_1_in  : in std_logic_vector(31 downto 0);
		  k_2_in  : in std_logic_vector(31 downto 0);
		  k_3_in  : in std_logic_vector(31 downto 0);
		  a_0_out : out std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0);
		  a_2_out : out std_logic_vector(31 downto 0);
		  a_3_out : out std_logic_vector(31 downto 0));
	end component;

	component rc_gen is
	port(clk : in std_logic;
	     rst : in std_logic;
		  enc : in std_logic; -- (enc, 0) / (dec, 1)
		  rc_out : out std_logic_vector(7 downto 0));
	end component;

	component output_trans is
	port(clk     : in std_logic;
		  enc		 : in std_logic; -- (enc, 0) / (dec, 1)
		  rc_in   : in std_logic_vector(31 downto 0);
		  a_0_in  : in std_logic_vector(31 downto 0);
		  a_1_in  : in std_logic_vector(31 downto 0);
		  a_2_in  : in std_logic_vector(31 downto 0);
		  a_3_in  : in std_logic_vector(31 downto 0);		
		  k_0_in  : in std_logic_vector(31 downto 0);
		  k_1_in  : in std_logic_vector(31 downto 0);
		  k_2_in  : in std_logic_vector(31 downto 0);
		  k_3_in  : in std_logic_vector(31 downto 0);
		  a_0_out : out std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0);
		  a_2_out : out std_logic_vector(31 downto 0);
		  a_3_out : out std_logic_vector(31 downto 0));
	end component;

	component theta is
	port(clk : in std_logic;

	     a_0_in : in std_logic_vector(31 downto 0);
	     a_1_in : in std_logic_vector(31 downto 0);
	     a_2_in : in std_logic_vector(31 downto 0);
	     a_3_in : in std_logic_vector(31 downto 0);
		  
	     k_0_in : in std_logic_vector(31 downto 0);
	     k_1_in : in std_logic_vector(31 downto 0);
	     k_2_in : in std_logic_vector(31 downto 0);
	     k_3_in : in std_logic_vector(31 downto 0);

	     a_0_out : out std_logic_vector(31 downto 0);
	     a_1_out : out std_logic_vector(31 downto 0);
	     a_2_out : out std_logic_vector(31 downto 0);
	     a_3_out : out std_logic_vector(31 downto 0));
	end component;

	signal rc_s : std_logic_vector(7 downto 0);
	signal rc_ext_s : std_logic_vector(31 downto 0);

	signal a_0_in_s  : std_logic_vector(31 downto 0);
	signal a_1_in_s  : std_logic_vector(31 downto 0);
	signal a_2_in_s  : std_logic_vector(31 downto 0);
	signal a_3_in_s  : std_logic_vector(31 downto 0);		

	signal out_t_a_0_in_s  : std_logic_vector(31 downto 0);
	signal out_t_a_1_in_s  : std_logic_vector(31 downto 0);
	signal out_t_a_2_in_s  : std_logic_vector(31 downto 0);
	signal out_t_a_3_in_s  : std_logic_vector(31 downto 0);		
	
	signal a_0_out_s : std_logic_vector(31 downto 0);
	signal a_1_out_s : std_logic_vector(31 downto 0);
	signal a_2_out_s : std_logic_vector(31 downto 0);
	signal a_3_out_s : std_logic_vector(31 downto 0);

	signal k_0_d_s  : std_logic_vector(31 downto 0);
	signal k_1_d_s  : std_logic_vector(31 downto 0);
	signal k_2_d_s  : std_logic_vector(31 downto 0);
	signal k_3_d_s  : std_logic_vector(31 downto 0);	

	signal k_0_mux_s  : std_logic_vector(31 downto 0);
	signal k_1_mux_s  : std_logic_vector(31 downto 0);
	signal k_2_mux_s  : std_logic_vector(31 downto 0);
	signal k_3_mux_s  : std_logic_vector(31 downto 0);	

begin

	RC_GEN_0 : rc_gen port map (clk, rst, enc, rc_s);

	rc_ext_s <= X"000000" & rc_s;

	ROUND_F_0 : round_f port map (clk, 
										   enc,
										   rc_ext_s, 
											a_0_in_s,
											a_1_in_s,
										   a_2_in_s,
											a_3_in_s,
											k_0_mux_s,
											k_1_mux_s,
											k_2_mux_s,
											k_3_mux_s,
											a_0_out_s,
											a_1_out_s,
											a_2_out_s,
											a_3_out_s);

	pr_noe: process(clk, rst, enc)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				a_0_in_s <= a_0_in;
				a_1_in_s <= a_1_in;
				a_2_in_s <= a_2_in;
				a_3_in_s <= a_3_in;				
			else
				a_0_in_s <= a_0_out_s;
				a_1_in_s <= a_1_out_s;
				a_2_in_s <= a_2_out_s;
				a_3_in_s <= a_3_out_s;				
			end if;
		end if;
	end process;

--	a_0_out <= a_0_out_s;
--	a_1_out <= a_1_out_s;
--	a_2_out <= a_2_out_s;
--	a_3_out <= a_3_out_s;	

	out_trans_pr: process(clk, rst, a_0_out_s, a_1_out_s, a_2_out_s, a_3_out_s)
	begin
		if rising_edge(clk) then
			out_t_a_0_in_s <= a_0_out_s;
			out_t_a_1_in_s <= a_1_out_s;
			out_t_a_2_in_s <= a_2_out_s;
			out_t_a_3_in_s <= a_3_out_s;			
		end if;
	end process;

	OUT_TRANS_0 : output_trans port map (clk, enc, rc_ext_s,
			out_t_a_0_in_s,
			out_t_a_1_in_s,
			out_t_a_2_in_s,
			out_t_a_3_in_s,
			k_0_mux_s,
			k_1_mux_s,
			k_2_mux_s,
			k_3_mux_s,			
			a_0_out,
			a_1_out,
			a_2_out,
			a_3_out);

	-- key decrypt
	
	THETA_DECRYPT_0 : theta port map (clk, 
			k_0_in,
			k_1_in,
			k_2_in,
			k_3_in,	
			(others => '0'),
			(others => '0'),
			(others => '0'),
			(others => '0'),			
			k_0_d_s,	
	      k_1_d_s,	
	      k_2_d_s,	
	      k_3_d_s);

			k_0_mux_s <= k_0_in when enc = '0' else k_0_d_s;
			k_1_mux_s <= k_1_in when enc = '0' else k_1_d_s;
			k_2_mux_s <= k_2_in when enc = '0' else k_2_d_s;
			k_3_mux_s <= k_3_in when enc = '0' else k_3_d_s;

end Behavioral;

