-- Implementation of Filter H_a3(z)
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

package analytic_filter_h_a3_pkg is
  component analytic_filter_h_a3
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
end analytic_filter_h_a3_pkg;

package body analytic_filter_h_a3_pkg is
end analytic_filter_h_a3_pkg;

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

entity analytic_filter_h_a3 is
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
end analytic_filter_h_a3; 

architecture analytic_filter_h_a3_arch of analytic_filter_h_a3 is

--signal y						: std_logic_vector (data_width-1 downto 0);
--signal x						: std_logic_vector (data_width-1 downto 0);

signal data_i_res	: std_logic_vector (data_width-1 downto 0);
signal t1	: std_logic_vector (data_width-1 downto 0);
signal t1_res	: std_logic_vector (data_width-1 downto 0);
signal t2	: std_logic_vector (data_width-1 downto 0);
signal t3	: std_logic_vector (data_width-1 downto 0);
signal t4	: std_logic_vector (data_width-1 downto 0);

signal c1_i	: std_logic_vector (data_width-1 downto 0);
signal c1_q	: std_logic_vector (data_width-1 downto 0);
signal c2_i	: std_logic_vector (data_width-1 downto 0);
signal c2_q	: std_logic_vector (data_width-1 downto 0);
signal c2_i_res	: std_logic_vector (data_width-1 downto 0);
signal c2_q_res	: std_logic_vector (data_width-1 downto 0);
signal c3_i	: std_logic_vector (data_width-1 downto 0);
signal c3_q	: std_logic_vector (data_width-1 downto 0);
signal c3_i_res	: std_logic_vector (data_width-1 downto 0);
signal c3_q_res	: std_logic_vector (data_width-1 downto 0);
signal c4_i	: std_logic_vector (data_width-1 downto 0);
signal c4_q	: std_logic_vector (data_width-1 downto 0);

signal t1_str	: std_logic;
signal t2_str	: std_logic;
signal t3_str	: std_logic;
signal t4_str	: std_logic;
signal c1_str	: std_logic;
signal c2_str	: std_logic;
signal c3_str	: std_logic;
signal c4_str	: std_logic;


begin

  data_i_res <= resize_to_msb_round(std_logic_vector(shift_right(signed(data_i),1)),data_width);

  comb_stage1 : fsf_comb_filter
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

  t1_res <= resize_to_msb_round(std_logic_vector(shift_right(signed(t1),1)),data_width);

  comb_stage2 : fsf_comb_filter
    generic map (
    	data_width => data_width,
    	comb_delay => 4
    )
    port map(
    		clk_i				=> clk_i,
    		rst_i				=> rst_i,
    		data_i			=> t1_res,
    	  data_str_i	=> t1_str,
    		data_o			=> t2,
    		data_str_o	=> t2_str
    );

  c_0_180_filter1 : fsf_pole_filter
  	generic map (
  		data_width => data_width,
 			coeff     => c_0_180_coeff,
  		no_of_coefficients => 2
  	)
  	port map(
  			clk_i				=> clk_i,
  			rst_i				=> rst_i,
  			data_i			=> t2,
  		  data_str_i	=> t2_str,
  			data_o			=> t3,
   			data_str_o	=> t3_str
  	);

  c_0_180_filter2 : fsf_pole_filter
  	generic map (
  		data_width => data_width,
 			coeff     => c_0_180_coeff,
  		no_of_coefficients => 2
  	)
  	port map(
  			clk_i				=> clk_i,
  			rst_i				=> rst_i,
  			data_i			=> t3,
  		  data_str_i	=> t3_str,
  			data_o			=> t4,
   			data_str_o	=> t4_str
  	);

  complex_fsf_filter_c_90_1 : complex_fsf_filter_c_90
    generic map (
    	data_width => data_width
    )
    port map(
    		clk_i				=> clk_i,
    		rst_i				=> rst_i,
    		data_i_i		=> t4,
    		data_q_i		=> (others => '0'),
    	  data_str_i	=> t4_str,
    		data_i_o		=> c1_i,
    		data_q_o    => c1_q,
    		data_str_o	=> c1_str

    );

  complex_fsf_filter_c_90_2 : complex_fsf_filter_c_90
    generic map (
    	data_width => data_width
    )
    port map(
    		clk_i				=> clk_i,
    		rst_i				=> rst_i,
    		data_i_i		=> c1_i,
    		data_q_i		=> c1_q,
    	  data_str_i	=> c1_str,
    		data_i_o		=> c2_i,
    		data_q_o    => c2_q,
    		data_str_o	=> c2_str

    );

  c2_i_res <= resize_to_msb_round(std_logic_vector(shift_right(signed(c2_i),1)),data_width);
  c2_q_res <= resize_to_msb_round(std_logic_vector(shift_right(signed(c2_q),1)),data_width);

  complex_fsf_filter_inv_c_m30_m150_1 : complex_fsf_filter_inv_c_m30_m150
    generic map (
    	data_width => data_width
    )
    port map(
    		clk_i				=> clk_i,
    		rst_i				=> rst_i,
    		data_i_i		=> c2_i_res,
    		data_q_i		=> c2_q_res,
    	  data_str_i	=> c2_str,
    		data_i_o		=> c3_i,
    		data_q_o    => c3_q,
    		data_str_o	=> c3_str
    );

  c3_i_res <= resize_to_msb_round(std_logic_vector(shift_right(signed(c3_i),2)),data_width);
  c3_q_res <= resize_to_msb_round(std_logic_vector(shift_right(signed(c3_q),2)),data_width);

  complex_fsf_filter_inv_c_m30_m150_2 : complex_fsf_filter_inv_c_m30_m150
    generic map (
    	data_width => data_width
    )
    port map(
    		clk_i				=> clk_i,
    		rst_i				=> rst_i,
    		data_i_i		=> c3_i_res,
    		data_q_i		=> c3_q_res,
    	  data_str_i	=> c3_str,
    		data_i_o		=> c4_i,
    		data_q_o    => c4_q,
    		data_str_o	=> c4_str
    );

  data_i_o <= c4_i;
  data_q_o <= c4_q;
  data_str_o <= c4_str;

end analytic_filter_h_a3_arch;


