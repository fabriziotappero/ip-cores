--/**************************************************************************************************************
--*
--*    L Z R W 1   E N C O D E R   C O R E
--*
--*  A high throughput loss less data compression core.
--* 
--* Copyright 2012-2013   Lukas Schrittwieser (LS)
--*
--*    This program is free software: you can redistribute it and/or modify
--*    it under the terms of the GNU General Public License as published by
--*    the Free Software Foundation, either version 2 of the License, or
--*    (at your option) any later version.
--*
--*    This program is distributed in the hope that it will be useful,
--*    but WITHOUT ANY WARRANTY; without even the implied warranty of
--*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--*    GNU General Public License for more details.
--*
--*    You should have received a copy of the GNU General Public License
--*    along with this program; if not, write to the Free Software
--*    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--*    Or see <http://www.gnu.org/licenses/>
--*
--***************************************************************************************************************
--*
--* Change Log:
--*
--* Version 1.0 - 2012/7/22 - LS
--*   started file
--*
--* Version 1.0 - 2013/04/05 - LS
--*   released
--*
--***************************************************************************************************************
--*
--* Naming convention:  http://dz.ee.ethz.ch/en/information/hdl-help/vhdl-naming-conventions.html
--*
--***************************************************************************************************************
--*
--* Simple testbench for manual signal inspection of inputFIFO.vhd
--*
--***************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity InputFIFO_tb is

end InputFIFO_tb;

-------------------------------------------------------------------------------

architecture tb of InputFIFO_tb is

  component InputFIFO
    port (
      ClkxCI        : in  std_logic;
      RstxRI        : in  std_logic;
      DInxDI        : in  std_logic_vector(31 downto 0);
      WExSI         : in  std_logic;
      StopOutputxSI : in  std_logic;
      BusyxSO       : out std_logic;
      DOutxDO       : out std_logic_vector(7 downto 0);
      OutStrobexSO  : out std_logic;
      LengthxDO     : out integer range 0 to 2048);
  end component;

  -- component ports
  signal ClkxCI        : std_logic;
  signal RstxRI        : std_logic                     := '1';
  signal DInxDI        : std_logic_vector(31 downto 0) := (others => '0');
  signal WExSI         : std_logic                     := '0';
  signal StopOutputxSI : std_logic                     := '0';
  signal BusyxSO       : std_logic;
  signal DOutxDO       : std_logic_vector(7 downto 0);
  signal OutStrobexSO  : std_logic;
  signal LengthxDO     : integer range 0 to 2048;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : InputFIFO
    port map (
      ClkxCI        => ClkxCI,
      RstxRI        => RstxRI,
      DInxDI        => DInxDI,
      WExSI         => WExSI,
      StopOutputxSI => StopOutputxSI,
      BusyxSO       => BusyxSO,
      DOutxDO       => DOutxDO,
      OutStrobexSO  => OutStrobexSO,
      LengthxDO     => LengthxDO);

  -- clock generation
  Clk    <= not Clk after 10 ns;
  ClkxCI <= Clk;

  -- waveform generation
  WaveGen_Proc : process
  begin
    wait for 10 ns;
    
    RstxRI <= '0';

    wait until ClkxCI'event and ClkxCI = '1';
    DInxDI        <= x"03020100";
    WExSI         <= '1';
    StopOutputxSI <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    DInxDI        <= x"07060504";
    WExSI         <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    DInxDI        <= x"0b0a0908";
    WExSI         <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    DInxDI        <= x"0f0e0d0c";
    WExSI         <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    DInxDI        <= x"00000000";
    WExSI         <= '0';

    -- tell DUT to send one byte every second cycle
    for i in 0 to 15 loop
      wait until ClkxCI'event and ClkxCI = '1';
      StopOutputxSI <= '0';
      wait until ClkxCI'event and ClkxCI = '1';
      StopOutputxSI <= '1';
    end loop;

    wait;
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration InputFIFO_tb_tb_cfg of InputFIFO_tb is
  for tb
  end for;
end InputFIFO_tb_tb_cfg;

-------------------------------------------------------------------------------
