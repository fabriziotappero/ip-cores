-- This is the implementation of a constant delay
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
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package const_delay_pkg is
component const_delay
	generic(
		data_width : integer;
		delay_in_clks : integer
	);
	port(
	    clk_i : in std_logic;
	    rst_i : in std_logic;
	    data_i : in std_logic_vector(data_width-1 downto 0);
	    data_str_i : in std_logic;
	    data_o : out std_logic_vector(data_width-1 downto 0);
	    data_str_o : out std_logic
	);
end component; 
end const_delay_pkg;

package body const_delay_pkg is
end const_delay_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity const_delay is
	generic(
		data_width : integer := 16;
		delay_in_clks : integer := 10
	);
	port(
	    clk_i : in std_logic;
	    rst_i : in std_logic;
	    data_i : in std_logic_vector(data_width-1 downto 0);
	    data_str_i : in std_logic;
	    data_o : out std_logic_vector(data_width-1 downto 0);
	    data_str_o : out std_logic
	);
end const_delay; 

architecture const_delay_arch of const_delay is


type register_line is array(0 to delay_in_clks-1) of std_logic_vector(data_width-1 downto 0);
type data_str_line is array(0 to delay_in_clks-1) of std_logic;

signal data_int : register_line;
signal data_str_int : data_str_line;

begin

process (clk_i, rst_i)
begin
	if rst_i = '1' then
    for i in 0 to delay_in_clks-1 loop
      data_int(i) <= (others => '0');
      data_str_int(i) <= '0';
    end loop;
	elsif clk_i'EVENT and clk_i = '1' then	
    data_int(0) <= data_i;
    data_str_int(0) <= data_str_i;
  
    for i in 0 to delay_in_clks-2 loop
      data_int(i+1) <= data_int(i);
      data_str_int(i+1) <= data_str_int(i);
    end loop;
    
  end if;
end process;
data_o <= data_int(delay_in_clks-1);
data_str_o <= data_str_int(delay_in_clks-1);


end const_delay_arch;