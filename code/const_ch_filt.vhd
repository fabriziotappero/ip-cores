--  Copyright (C) 2004-2005 Digish Pandya <digish.pandya@gmail.com>

--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


-- A.4
-- channel filter with optimized for constant input data and 
-- constant coefficients
-- coefficients are rounded to power of two

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity const_ch_filt is
    Port ( clock : in std_logic;
           data_in : in std_logic_vector(7 downto 0);
           shifted_data_out : out std_logic_vector(7 downto 0);
           filtered_data_out : out std_logic_vector(7 downto 0));
end const_ch_filt;

architecture structural of const_ch_filt is

	component ch_filt_tap
	    Port ( din : in std_logic_vector(7 downto 0);
	           dout : out std_logic_vector(7 downto 0);
	           c1_in : in std_logic_vector(7 downto 0);
	           c2_in : in std_logic_vector(7 downto 0);
	           add_in : in std_logic_vector(7 downto 0);
	           add_out : out std_logic_vector(7 downto 0);
	           clock : in std_logic);
	end component;

	signal t_data_out1: std_logic_vector (7 downto 0);
	signal t_data_out2: std_logic_vector (7 downto 0);
	signal t_res_out1: std_logic_vector (7 downto 0);
	signal t_res_out2: std_logic_vector (7 downto 0);

begin

tap1: ch_filt_tap	--	-0.2031
	port map(
			din => data_in,
           	dout => t_data_out1, 
           	c1_in => "11110011",   		    -- +1
           	c2_in => "00001101", 		    -- -1
           	add_in => "00000000", 
           	add_out => t_res_out1,
           	clock => clock 	
		    );

tap2: ch_filt_tap	  -- 0.4063
	port map(
			din => t_data_out1,
           	dout => t_data_out2, 
           	c1_in => "00011010", 
           	c2_in => "11100110", 
           	add_in => t_res_out1, 
           	add_out => t_res_out2,
           	clock => clock 	
		    );
tap3: ch_filt_tap	  --   -0.7969
	port map(
			din => t_data_out2,
           	dout => shifted_data_out, 
           	c1_in => "11001101", 
           	c2_in => "00110011", 
           	add_in => t_res_out2, 
           	add_out => filtered_data_out,
           	clock => clock 	
		    );



end structural;
