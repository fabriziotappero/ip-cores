
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

entity gamma is
	port(clk : in std_logic;
		  a_0_in : in std_logic_vector(31 downto 0);
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_3_in : in std_logic_vector(31 downto 0);		  
		  
		  a_0_out : out std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0);
		  a_2_out : out std_logic_vector(31 downto 0);
		  a_3_out : out std_logic_vector(31 downto 0));				  
end gamma;

architecture Behavioral of gamma is

	signal a_0_tmp_s : std_logic_vector(31 downto 0);
	signal a_1_tmp_s : std_logic_vector(31 downto 0);
	signal a_2_tmp_s : std_logic_vector(31 downto 0);
	signal a_3_tmp_s : std_logic_vector(31 downto 0);
	signal a_1_1_tmp_s : std_logic_vector(31 downto 0);
	signal a_0_1_tmp_s : std_logic_vector(31 downto 0);	
	signal a_0_2_tmp_s : std_logic_vector(31 downto 0);	

	component g_m_1 is
	port(clk : in std_logic;
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_3_in : in std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0));
	end component;

	component g_m_2 is
	port(clk : in std_logic;
		  a_0_in : in std_logic_vector(31 downto 0);
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_0_out : out std_logic_vector(31 downto 0));
	end component;

	component g_m_3 is
	port(clk : in std_logic;
	     a_0_in : in std_logic_vector(31 downto 0);
		  a_3_in : in std_logic_vector(31 downto 0);
		  a_0_out : out std_logic_vector(31 downto 0);
		  a_3_out : out std_logic_vector(31 downto 0));
	end component;

	component g_m_4 is
	port(clk : in std_logic;
		  a_0_in : in std_logic_vector(31 downto 0);
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_3_in : in std_logic_vector(31 downto 0);
		  a_2_out : out std_logic_vector(31 downto 0));
	end component;

	component g_m_5 is
	port(clk : in std_logic;
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_3_in : in std_logic_vector(31 downto 0);
		  a_1_out : out std_logic_vector(31 downto 0));
	end component;

	component g_m_6 is
	port(clk : in std_logic;
	     a_0_in : in std_logic_vector(31 downto 0);
		  a_1_in : in std_logic_vector(31 downto 0);
		  a_2_in : in std_logic_vector(31 downto 0);
		  a_0_out : out std_logic_vector(31 downto 0));
	end component;

begin

	G_M_1_0 : g_m_1 port map (clk, a_1_in, a_2_in, a_3_in, a_1_tmp_s);
	G_M_2_0 : g_m_2 port map (clk, a_0_in, a_1_tmp_s, a_2_in, a_0_tmp_s);
	G_M_3_0 : g_m_3 port map (clk, a_0_tmp_s, a_3_in, a_0_1_tmp_s, a_3_tmp_s);
	G_M_4_0 : g_m_4 port map (clk, a_0_1_tmp_s, a_1_tmp_s, a_2_in, a_3_tmp_s, a_2_tmp_s);
	G_M_5_0 : g_m_5 port map (clk, a_1_tmp_s, a_2_tmp_s, a_3_tmp_s, a_1_1_tmp_s);
	G_M_6_0 : g_m_6 port map (clk, a_0_1_tmp_s, a_1_1_tmp_s, a_2_tmp_s, a_0_2_tmp_s);

	a_3_out <= a_3_tmp_s;
	a_2_out <= a_2_tmp_s;
	a_1_out <= a_1_1_tmp_s;
	a_0_out <= a_0_2_tmp_s;
	
--Gamma(a){
--a[1] ^= ~a[3]&~a[2];
--a[0] ^= a[2]& a[1];
--tmp = a[3]; 
--a[3] = a[0]; 
--a[0] = tmp;
--a[2] ^= a[0]^a[1]^a[3];
--a[1] ^= ~a[3]&~a[2];
--a[0] ^= a[2]& a[1];
--}


end Behavioral;

