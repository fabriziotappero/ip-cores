-- DDS Frequency Synthesizer
--
-- Output frequency is f=ftw_i/2^ftw_width*fclk
-- Output initial phase is phi=phase_i/2^phase_width*2*pi
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
use work.sine_lut_pkg.all;

package dds_synthesizer_pkg is
  component dds_synthesizer
    generic(
      ftw_width : integer
      );
    port(
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      ftw_i   : in  std_logic_vector(ftw_width-1 downto 0);
      phase_i : in  std_logic_vector(PHASE_WIDTH-1 downto 0);
      phase_o : out std_logic_vector(PHASE_WIDTH-1 downto 0);
      ampl_o  : out std_logic_vector(AMPL_WIDTH-1 downto 0)
      );
  end component;
end dds_synthesizer_pkg;

package body dds_synthesizer_pkg is
end dds_synthesizer_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use work.sine_lut_pkg.all;

entity dds_synthesizer is
  generic(
    ftw_width : integer := 32
    );
  port(
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    ftw_i   : in  std_logic_vector(ftw_width-1 downto 0);
    phase_i : in  std_logic_vector(PHASE_WIDTH-1 downto 0);
    phase_o : out std_logic_vector(PHASE_WIDTH-1 downto 0);
    ampl_o  : out std_logic_vector(AMPL_WIDTH-1 downto 0)
    );
end dds_synthesizer;

architecture dds_synthesizer_arch of dds_synthesizer is

  signal ftw_accu               : std_logic_vector(ftw_width-1 downto 0);
  signal phase                  : std_logic_vector(PHASE_WIDTH-1 downto 0);
  signal lut_in                 : std_logic_vector(PHASE_WIDTH-3 downto 0);
  signal lut_out                : std_logic_vector(AMPL_WIDTH-1 downto 0);
  signal lut_out_delay          : std_logic_vector(AMPL_WIDTH-1 downto 0);
  signal lut_out_inv_delay      : std_logic_vector(AMPL_WIDTH-1 downto 0);
  signal quadrant_2_or_4        : std_logic;
  signal quadrant_3_or_4        : std_logic;
  signal quadrant_3_or_4_delay  : std_logic;
  signal quadrant_3_or_4_2delay : std_logic;

begin
  phase_o         <= phase;
  quadrant_2_or_4 <= phase(PHASE_WIDTH-2);
  quadrant_3_or_4 <= phase(PHASE_WIDTH-1);

  lut_in <= phase(PHASE_WIDTH-3 downto 0) when quadrant_2_or_4 = '0' else conv_std_logic_vector(2**(PHASE_WIDTH-2)-conv_integer(phase(PHASE_WIDTH-3 downto 0)), PHASE_WIDTH-2);
  ampl_o <= lut_out_delay                 when quadrant_3_or_4_2delay = '0' else lut_out_inv_delay;

  process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      ftw_accu <= (others => '0');
      phase  <= (others => '0');
      lut_out <= (others => '0');
      lut_out_delay <= (others => '0');
      lut_out_inv_delay <= (others => '0');
      quadrant_3_or_4_delay <= '0';
      quadrant_3_or_4_2delay <= '0';
    elsif clk_i'event and clk_i = '1' then
      ftw_accu <= ftw_accu + ftw_i;
      phase    <= ftw_accu(ftw_width-1 downto ftw_width-PHASE_WIDTH) + phase_i;
      if quadrant_2_or_4 = '1' and phase(PHASE_WIDTH - 3 downto 0) = conv_std_logic_vector (0, PHASE_WIDTH - 2) then
        lut_out <= conv_std_logic_vector(2**(AMPL_WIDTH - 1) - 1, AMPL_WIDTH);
      else
        lut_out <= sine_lut(conv_integer(lut_in));
      end if;
      quadrant_3_or_4_delay <= quadrant_3_or_4;
      quadrant_3_or_4_2delay <= quadrant_3_or_4_delay;
      lut_out_inv_delay <= conv_std_logic_vector(-1*conv_integer(lut_out), AMPL_WIDTH);
      lut_out_delay <= lut_out;
    end if;
  end process;

end dds_synthesizer_arch;
