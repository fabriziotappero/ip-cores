-- pole filter implementation for frequency sampling filers (FSF)
-- 
-- This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along with this program; 
-- if not, see <http://www.gnu.org/licenses/>.

-- Package Definition of fsf_pole_filter_coeff_array_type

library ieee;
use ieee.std_logic_1164.all;

package fsf_pole_filter_coeff_def_pkg is

type fsf_pole_filter_coeff_array_type is array(0 to 5) of integer range -1 to 1;

constant c_0_coeff : fsf_pole_filter_coeff_array_type := (-1,0,0,0,0,0);
constant c_180_coeff : fsf_pole_filter_coeff_array_type := (1,0,0,0,0,0);
constant c_120_coeff : fsf_pole_filter_coeff_array_type := (1,1,0,0,0,0);
constant c_90_coeff : fsf_pole_filter_coeff_array_type := (0,1,0,0,0,0);
constant c_60_coeff : fsf_pole_filter_coeff_array_type := (-1,1,0,0,0,0);
constant c_0_180_coeff : fsf_pole_filter_coeff_array_type := (0,-1,0,0,0,0);
constant c_0_90_coeff : fsf_pole_filter_coeff_array_type := (-1,1,-1,0,0,0);
constant c_0_120_coeff : fsf_pole_filter_coeff_array_type := (0,0,-1,0,0,0);
constant c_180_60_coeff : fsf_pole_filter_coeff_array_type := (0,0,1,0,0,0);
constant c_180_90_coeff : fsf_pole_filter_coeff_array_type := (1,1,1,0,0,0);


--and in meyer-baese syntax:
constant c_1_coeff : fsf_pole_filter_coeff_array_type := c_0_coeff;
constant c_2_coeff : fsf_pole_filter_coeff_array_type := c_180_coeff;
constant c_3_coeff : fsf_pole_filter_coeff_array_type := c_120_coeff;
constant c_4_coeff : fsf_pole_filter_coeff_array_type := c_90_coeff;
constant c_6_coeff : fsf_pole_filter_coeff_array_type := c_60_coeff;

end fsf_pole_filter_coeff_def_pkg;
package body fsf_pole_filter_coeff_def_pkg is
end fsf_pole_filter_coeff_def_pkg;


library ieee;
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_signed.all;
use work.fsf_pole_filter_coeff_def_pkg.all;

package fsf_pole_filter_pkg is
  component fsf_pole_filter
  	generic(
  		data_width  : integer;
  		no_of_coefficients : integer;  --must be in the range 1..6
      coeff             : fsf_pole_filter_coeff_array_type
  	);
  	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			data_i				    :	in std_logic_vector(data_width-1 downto 0);
		  data_str_i				:	in std_logic;
			data_o				    :	out std_logic_vector(data_width-1 downto 0);
 			data_str_o				:	out std_logic
  	);
  end component;
end fsf_pole_filter_pkg;

package body fsf_pole_filter_pkg is
end fsf_pole_filter_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_signed.all;
use work.fsf_pole_filter_coeff_def_pkg.all;

entity fsf_pole_filter is
	generic(
		data_width  : integer;
		no_of_coefficients : integer;  --must be in the range 1..6
    coeff             : fsf_pole_filter_coeff_array_type
	);
	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			data_i				:	in std_logic_vector(data_width-1 downto 0);
		  data_str_i				:	in std_logic;
			data_o				:	out std_logic_vector(data_width-1 downto 0);
 			data_str_o				:	out std_logic
	);
end fsf_pole_filter; 

architecture fsf_pole_filter_arch of fsf_pole_filter is

signal y						: std_logic_vector (data_width-1 downto 0);
signal x						: std_logic_vector (data_width-1 downto 0);

type signal_chain_array_type is array (0 to no_of_coefficients-1) of std_logic_vector (data_width-1 downto 0);
signal t	: signal_chain_array_type;
signal td	: signal_chain_array_type;

begin
  data_o <= y;
  x <= data_i;
  y <= td(no_of_coefficients-1);

  t(0) <= conv_std_logic_vector(conv_integer(x) + (((-1)*coeff(no_of_coefficients-1)) * conv_integer(y)),data_width);

  next_adder_decision : if no_of_coefficients > 1 generate
    next_adder : for i in 1 to no_of_coefficients-1 generate
      t(i) <= conv_std_logic_vector(conv_integer(td(i-1)) + (((-1)*coeff(no_of_coefficients-i-1))*conv_integer(y)),data_width);
    end generate;
  end generate;


  process (clk_i, rst_i)
  begin
  	if rst_i = '1' then
      for i in 0 to no_of_coefficients-1 loop
        td(i) <= (others => '0');
      end loop;
      data_str_o <= '0';
  	elsif clk_i'EVENT and clk_i = '1' then	
      if data_str_i='1' then
        data_str_o <= '1';
        for i in 0 to no_of_coefficients-1 loop
          td(i) <= t(i);
        end loop;
      else
        data_str_o <= '0';
      end if;
  	end if;
  end process;


end fsf_pole_filter_arch;