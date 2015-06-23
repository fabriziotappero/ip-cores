-- Implementation of Filter H_a2(z)
-- using Complex Frequency sampling filer (FSF) as Hilbert transformer
-- 
-- This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along with this program; 
-- if not, see <http://www.gnu.org/licenses/>.

library ieee;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

package analytic_filter_h_a2_pkg is
  component analytic_filter_h_a2
  	generic(
  		data_width  : integer
  	);
  	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			data_i				    :	in std_logic_vector(data_width-1 downto 0);
		  data_str_i				:	in std_logic;
			data_i_o				  :	out std_logic_vector(data_width-1 downto 0);
			data_q_o				  :	out std_logic_vector(data_width-1 downto 0);
 			data_str_o				:	out std_logic
  	);
  end component;
end analytic_filter_h_a2_pkg;

package body analytic_filter_h_a2_pkg is
end analytic_filter_h_a2_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.fsf_comb_filter_pkg.all;
use work.fsf_pole_filter_pkg.all;
use work.fsf_pole_filter_coeff_def_pkg.all;
use work.complex_fsf_filter_c_90_pkg.all;
use work.complex_fsf_filter_inv_c_m30_m150_pkg.all;
use work.resize_tools_pkg.all;

entity analytic_filter_h_a2 is
  	generic(
  		data_width  : integer := 16
  	);
  	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			data_i				    :	in std_logic_vector(data_width-1 downto 0);
		  data_str_i				:	in std_logic;
			data_i_o				  :	out std_logic_vector(data_width-1 downto 0);
			data_q_o				  :	out std_logic_vector(data_width-1 downto 0);
 			data_str_o				:	out std_logic
  	);
end analytic_filter_h_a2; 

architecture analytic_filter_h_a2_arch of analytic_filter_h_a2 is

--signal y						: std_logic_vector (data_width-1 downto 0);
--signal x						: std_logic_vector (data_width-1 downto 0);

signal data_i_res	: std_logic_vector (data_width-1 downto 0);
signal t1	: std_logic_vector (data_width-1 downto 0);

signal c1_i	: std_logic_vector (data_width-1 downto 0);
signal c1_q	: std_logic_vector (data_width-1 downto 0);

signal t1_str	: std_logic;
signal c1_str	: std_logic;


begin

  data_i_res <= resize_to_msb_round(std_logic_vector(shift_right(signed(data_i),1)),data_width);

  real_pole_filter_1 : fsf_comb_filter
    generic map (
    	data_width => data_width,
    	comb_delay => 4
    )
    port map(
    		clk_i				=> clk_i,
    		rst_i				=> rst_i,
    		data_i			=> data_i_res,
    	  data_str_i	=> data_str_i,
    		data_o			=> t1,
    		data_str_o	=> t1_str
    );

  complex_fsf_filter_c_90_1 : complex_fsf_filter_c_90
    generic map (
    	data_width => data_width
    )
    port map(
    		clk_i				=> clk_i,
    		rst_i				=> rst_i,
    		data_i_i		=> t1,
    		data_q_i		=> (others => '0'),
    	  data_str_i	=> t1_str,
    		data_i_o		=> c1_i,
    		data_q_o    => c1_q,
    		data_str_o	=> c1_str

    );


  data_i_o <= c1_i;
  data_q_o <= c1_q;
  data_str_o <= c1_str;

end analytic_filter_h_a2_arch;