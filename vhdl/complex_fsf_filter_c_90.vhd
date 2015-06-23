-- This is the implementation of the complex filter C_90(z)=1/(1-j*z^-1)
-- which creates a single pole at e^j90 [deg]
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

package complex_fsf_filter_c_90_pkg is
  component complex_fsf_filter_c_90
  	generic(
  		data_width  : integer
  	);
  	port(
  			clk_i						:	in  std_logic;
  			rst_i						:	in  std_logic;
  			data_i_i				:	in std_logic_vector(data_width-1 downto 0);
  			data_q_i				:	in std_logic_vector(data_width-1 downto 0);
  		  data_str_i			:	in std_logic;
  			data_i_o				:	out std_logic_vector(data_width-1 downto 0);
  			data_q_o				:	out std_logic_vector(data_width-1 downto 0);
   			data_str_o			:	out std_logic
  	);
  end component;
end complex_fsf_filter_c_90_pkg;

package body complex_fsf_filter_c_90_pkg is
end complex_fsf_filter_c_90_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.resize_tools_pkg.all;

entity complex_fsf_filter_c_90 is
	generic(
  		data_width  : integer := 16
	);
	port(
			clk_i						:	in  std_logic;
			rst_i						:	in  std_logic;
			data_i_i				:	in std_logic_vector(data_width-1 downto 0);
			data_q_i				:	in std_logic_vector(data_width-1 downto 0);
		  data_str_i			:	in std_logic;
			data_i_o				:	out std_logic_vector(data_width-1 downto 0);
			data_q_o				:	out std_logic_vector(data_width-1 downto 0);
 			data_str_o			:	out std_logic
	);
end complex_fsf_filter_c_90; 

architecture complex_fsf_filter_c_90_arch of complex_fsf_filter_c_90 is

  signal xi : std_logic_vector(data_width-1 downto 0);
  signal xq : std_logic_vector(data_width-1 downto 0);
  signal yi : std_logic_vector(data_width-1 downto 0);
  signal yq : std_logic_vector(data_width-1 downto 0);

  signal xisyq : std_logic_vector(data_width-1 downto 0);
  signal xqayi : std_logic_vector(data_width-1 downto 0);
  

begin
  
  xi <= data_i_i;
  xq <= data_q_i;

  data_i_o <= yi;
  data_q_o <= yq;

  xisyq <= resize_to_msb_round(std_logic_vector(signed(xi) - signed(yq)),data_width);
  xqayi <= resize_to_msb_round(std_logic_vector(signed(xq) + signed(yi)),data_width);


process (clk_i, rst_i)
begin
	if rst_i = '1' then
    yi <= (others => '0');
    yq <= (others => '0');
    data_str_o <= '0';
	elsif clk_i'EVENT and clk_i = '1' then	
    data_str_o <= data_str_i;
    if data_str_i='1' then
      yi <= xisyq;
      yq <= xqayi;
    end if;
  end if;
end process;


end complex_fsf_filter_c_90_arch;


