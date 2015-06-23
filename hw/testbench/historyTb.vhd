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
--* Version 1.0 - 2012/10/16 - LS
--*   started file
--*
--* Version 1.0 - 2013/04/05 - LS
--*   release
--*
--***************************************************************************************************************
--*
--* Naming convention:  http://dz.ee.ethz.ch/en/information/hdl-help/vhdl-naming-conventions.html
--*
--***************************************************************************************************************
--*
--* Simple testbench for manual signal inspection for histroy buffer.
--*
--***************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity historyBuffer_tb is

end historyBuffer_tb;

-------------------------------------------------------------------------------

architecture tb of historyBuffer_tb is

  component historyBuffer
    port (
      ClkxCI          : in  std_logic;
      RstxRI          : in  std_logic;
      WriteInxDI      : in  std_logic_vector(7 downto 0);
      WExSI           : in  std_logic;
      NextWrAdrxDO    : out std_logic_vector(11 downto 0);
      RExSI           : in  std_logic;
      ReadBackAdrxDI  : in  std_logic_vector(11 downto 2);
      ReadBackxDO     : out std_logic_vector(16*8-1 downto 0);
      ReadBackDonexSO : out std_logic);
  end component;

  -- component ports
  signal ClkxCI          : std_logic;
  signal RstxRI          : std_logic := '1';
  signal WriteInxDI      : std_logic_vector(7 downto 0) := (others => '0');
  signal WExSI           : std_logic := '0';
  signal NextWrAdrxDO    : std_logic_vector(11 downto 0);
  signal RExSI           : std_logic := '0';
  signal ReadBackAdrxDI  : std_logic_vector(11 downto 2) := (others => '0');
  signal ReadBackxDO     : std_logic_vector(16*8-1 downto 0);
  signal ReadBackDonexSO : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT: historyBuffer
    port map (
      ClkxCI          => ClkxCI,
      RstxRI          => RstxRI,
      WriteInxDI      => WriteInxDI,
      WExSI           => WExSI,
      NextWrAdrxDO    => NextWrAdrxDO,
      RExSI           => RExSI,
      ReadBackAdrxDI  => ReadBackAdrxDI,
      ReadBackxDO     => ReadBackxDO,
      ReadBackDonexSO => ReadBackDonexSO);

  -- clock generation
  Clk <= not Clk after 10 ns;
  ClkxCI <= Clk;
  
  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for 10 ns;
    wait until Clk = '1';
    RstxRI <= '0';

    -- first: write some data to buffer
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"00";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"01";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"02";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"03";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"04";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"05";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"06";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"07";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"08";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"09";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"0a";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"0b";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"0c";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"0d";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"0e";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"0f";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"10";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"11";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"12";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
 WriteInxDI <= x"13";
    WExSI <= '1';
    wait until Clk'event and Clk='1';
    WExSI <= '0';

    -- now read back
    ReadBackAdrxDI <= "0000000000";
    wait until Clk'event and Clk='1';
    ReadBackAdrxDI <= "0000000001";
    wait until Clk'event and Clk='1';
    ReadBackAdrxDI <= "0000000010";
    wait until Clk'event and Clk='1';
    
    wait;
    
    
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration historyBuffer_tb_tb_cfg of historyBuffer_tb is
  for tb
  end for;
end historyBuffer_tb_tb_cfg;

-------------------------------------------------------------------------------
