-- This filter produces a pole pair at +/-zp=sqrt(2^-shift_value) on the real axis 
-- A shift register is used instead of a multiplier
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
use ieee.numeric_std.all;
use ieee.math_real.all;

package real_pole_filter_shift_reg_pkg is
  component real_pole_filter_shift_reg
  	generic(
  		data_width  : integer;
  		internal_data_width : integer;
  		shift_value : integer
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
end real_pole_filter_shift_reg_pkg;

package body real_pole_filter_shift_reg_pkg is
end real_pole_filter_shift_reg_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.resize_tools_pkg.all;

entity real_pole_filter_shift_reg is
	generic(
  		data_width  : integer := 16;
  		internal_data_width : integer := 16;
  		shift_value : integer := 1
	);
	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			data_i				:	in std_logic_vector(data_width-1 downto 0);
  	  data_str_i				:	in std_logic;
			data_o				:	out std_logic_vector(data_width-1 downto 0);
 			data_str_o				:	out std_logic
	);
end real_pole_filter_shift_reg; 

architecture real_pole_filter_shift_reg_arch of real_pole_filter_shift_reg is

  signal x_res : std_logic_vector(internal_data_width-1 downto 0);
  signal xaydmb0 : std_logic_vector(internal_data_width-1 downto 0);
  signal ydmb0 : std_logic_vector(internal_data_width-1 downto 0); 
  signal y					: std_logic_vector (internal_data_width-1 downto 0);
  signal yd					: std_logic_vector (internal_data_width-1 downto 0);

begin

  x_res <= resize_to_msb_round(data_i,internal_data_width);
  xaydmb0 <= resize_to_msb_round(std_logic_vector(signed(x_res) + signed(ydmb0)),internal_data_width);
  ydmb0 <= resize_to_msb_round(std_logic_vector(shift_right(signed(yd),shift_value)),internal_data_width);

process (clk_i, rst_i)
begin
	if rst_i = '1' then
    y <= (others => '0');
    yd <= (others => '0');
    data_str_o <= '0';
    data_o <= (others => '0');
	elsif clk_i'EVENT and clk_i = '1' then	
    data_str_o <= data_str_i;
    data_o <= y;
    if data_str_i='1' then
      y <= xaydmb0;
      yd <= y;
    end if;
  end if;
end process;


end real_pole_filter_shift_reg_arch;


