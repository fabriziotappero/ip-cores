-- comb filter implementation for frequency sampling filers (FSF)
-- The filter transfer function F(z)=1+z^(-comb_delay)
-- 
-- This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along with this program; 
-- if not, see <http://www.gnu.org/licenses/>.

-- Package Definition

library ieee;
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_signed.all;

package fsf_comb_filter_pkg is
  component fsf_comb_filter
  	generic(
  		data_width  : integer;
  		comb_delay  : integer
  	);
  	port(
  			clk_i							:	in  std_logic;
  			rst_i							:	in  std_logic;
  			data_i				:	in std_logic_vector(data_width-1 downto 0);
  		  data_str_i				:	in std_logic;
  			data_o				:	out std_logic_vector(data_width-1 downto 0);
   			data_str_o				:	out std_logic
  	);
  end component;
end fsf_comb_filter_pkg;

package body fsf_comb_filter_pkg is
end fsf_comb_filter_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_signed.all;

entity fsf_comb_filter is
	generic(
		data_width  : integer := 16;
		comb_delay  : integer := 2
	);
	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			data_i				:	in std_logic_vector(data_width-1 downto 0);
  	  data_str_i				:	in std_logic;
			data_o				:	out std_logic_vector(data_width-1 downto 0);
 			data_str_o				:	out std_logic
	);
end fsf_comb_filter; 

architecture fsf_comb_filter_arch of fsf_comb_filter is

signal xc						: std_logic_vector (data_width-1 downto 0);
signal yc						: std_logic_vector (data_width-1 downto 0);

type delay_array_type is array (0 to comb_delay-1) of std_logic_vector (data_width-1 downto 0);
signal ycd						: delay_array_type;

begin

  xc <= data_i;
  yc <= conv_std_logic_vector(conv_integer(xc) - conv_integer(ycd(comb_delay-1)), data_width);

process (clk_i, rst_i)
begin
	if rst_i = '1' then
	  for i in 0 to comb_delay-1 loop
	     ycd(i) <= (others => '0');
	  end loop;
    data_str_o <= '0';
    data_o <= (others => '0');
	elsif clk_i'EVENT and clk_i = '1' then	
    data_str_o <= data_str_i;
    data_o <= yc;
    if data_str_i='1' then
      ycd(0) <= xc;
      for i in 1 to comb_delay-1 loop
        ycd(i) <= ycd(i-1);
      end loop;
    end if;
  end if;
end process;


end fsf_comb_filter_arch;


