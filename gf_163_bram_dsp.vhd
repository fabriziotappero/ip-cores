
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

entity gf_163_bram_dsp is
	port(clk : in std_logic;
	     rst : in std_logic;
	     a : in std_logic_vector(162 downto 0);
	     b : in std_logic_vector(162 downto 0);
		  p : out std_logic_vector(162 downto 0));
end gf_163_bram_dsp;

architecture Behavioral of gf_163_bram_dsp is

	COMPONENT poly_rom
		PORT (clka : IN STD_LOGIC;
				addra : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
				douta : OUT STD_LOGIC_VECTOR(162 DOWNTO 0));
	END COMPONENT;

	component dsp_xor is
		port (clk     : in std_logic;
				op_1	  : in std_logic_vector(47 downto 0);
				op_2	  : in std_logic_vector(47 downto 0);
				op_3	  : out std_logic_vector(47 downto 0));
	end component;

	component shift_xor_128 is
		port(clk : in std_logic;
		     a : in std_logic_vector(162 downto 0);
			  m : in std_logic_vector(162 downto 0);
		     c : out std_logic_vector(162 downto 0));
	end component;

	signal p_1_s : std_logic_vector(162 downto 0);
	signal p_2_s : std_logic_vector(162 downto 0);
	signal b_s : std_logic;
	signal p_s : std_logic_vector(162 downto 0);
	signal m_s : std_logic_vector(162 downto 0);
	signal c_s : std_logic_vector(162 downto 0);
	
	signal r_0_s : std_logic_vector(47 downto 0);
	signal r_1_s : std_logic_vector(47 downto 0);
	signal r_2_s : std_logic_vector(47 downto 0);
	signal r_3_s : std_logic_vector(47 downto 0);

	signal xor_in_aux_0_s : std_logic_vector(47 downto 0);
	signal xor_in_aux_1_s : std_logic_vector(47 downto 0);
	signal xor_out_aux_s : std_logic_vector(47 downto 0);

begin

	shr_p_2_pr : process(clk, rst, b)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				p_2_s <= b;
			else
				p_2_s <= '0' & p_2_s(162 downto 1);
			end if;
		end if;
	
		b_s <= p_2_s(0);
		
	end process;

	pr_1_seq: process(clk, rst, b_s, p_1_s, r_3_s, r_2_s, r_1_s, r_0_s)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				p_s <= (others => '0');
			elsif b_s = '1' then
				p_s <= r_3_s(47 downto 29) & r_2_s & r_1_s & r_0_s; 
			end if;
		end if;
	end process;

	DSP_XOR_0 : dsp_xor port map (clk, p_s(47 downto 0),    p_1_s(47 downto 0),   r_0_s);
	DSP_XOR_1 : dsp_xor port map (clk, p_s(95 downto 48),   p_1_s(95 downto 48),  r_1_s);
	DSP_XOR_2 : dsp_xor port map (clk, p_s(143 downto 96),  p_1_s(143 downto 96),  r_2_s);

	xor_in_aux_0_s <= p_s(162 downto 134) & "0000000000000000000";
	xor_in_aux_1_s <= p_1_s(162 downto 134) & "0000000000000000000";

	DSP_XOR_3 : dsp_xor port map (clk, xor_in_aux_0_s,  xor_in_aux_1_s, r_3_s);

	SHIFT_XOR_0 : shift_xor_128 port map (clk, p_1_s, m_s, c_s);

	pr_2_seq: process(clk, a, c_s)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				p_1_s <= a;
			else
				p_1_s <= c_s;
			end if;
		end if;
	end process;
	
	p <= p_s;

	POLY_ROM_0 : poly_rom port map (clk, "0", m_s);

end Behavioral;

