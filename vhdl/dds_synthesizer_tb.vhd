-- Testbench of DDS Frequency Synthesizer
--
-- Copyright (C) 2009 Martin Kumm
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
use work.dds_synthesizer_pkg.all;
use work.sine_lut_pkg.all;

entity dds_synthesizer_tb is
    generic(
      clk_period : time := 10 ns;
			ftw_width : integer := 32
   );
end dds_synthesizer_tb;
architecture dds_synthesizer_tb_arch of dds_synthesizer_tb is

signal clk,rst : std_logic := '0';
signal ftw : std_logic_vector(ftw_width-1 downto 0);
signal init_phase : std_logic_vector(phase_width-1 downto 0);
signal phase_out : std_logic_vector(phase_width-1 downto 0);
signal ampl_out : std_logic_vector(ampl_width-1 downto 0);

begin

	dds_synth: dds_synthesizer
  generic map(
		ftw_width   => ftw_width
  )
  port map(
		clk_i => clk,
		rst_i => rst,
		ftw_i    => ftw,
		phase_i  => init_phase,
		phase_o  => phase_out,
		ampl_o => ampl_out
  );

	init_phase <= (others => '0');
	ftw <= conv_std_logic_vector(2147483,ftw_width);  --20us period @ 100MHz, ftw_width=32

  clk <= not clk after clk_period/2;
  rst <= '1','0' after 2*clk_period;

end dds_synthesizer_tb_arch;