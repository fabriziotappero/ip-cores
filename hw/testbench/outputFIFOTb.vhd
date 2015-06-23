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
--* Version 1.0 - 2012/8/12 - LS
--*   started file
--*
--* Version 1.0 - 2013/4/5 - LS
--*   release
--*
--***************************************************************************************************************
--*
--* Naming convention:  http://dz.ee.ethz.ch/en/information/hdl-help/vhdl-naming-conventions.html
--*
--***************************************************************************************************************
--*
--* Test bench for outputFIFO.vhd
--*
--***************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;


entity outputFIFO_tb is

end outputFIFO_tb;


architecture tb of outputFIFO_tb is

  component outputFIFO
    generic (
      frameSize : integer);
    port (
      ClkxCI          : in  std_logic;
      RstxRI          : in  std_logic;
      BodyDataxDI     : in  std_logic_vector(7 downto 0);
      BodyStrobexSI   : in  std_logic;
      HeaderDataxDI   : in  std_logic_vector(frameSize-1 downto 0);
      HeaderStrobexSI : in  std_logic;
      BuffersEmptyxSO : out std_logic;
      BufOutxDO       : out std_logic_vector(7 downto 0);
      OutputValidxSO  : out std_logic;
      RdStrobexSI     : in  std_logic;
      LengthxDO       : out integer range 0 to 1024);
  end component;

  -- component generics
  constant frameSize : integer := 8;

  -- component ports
  signal ClkxCI          : std_logic;
  signal RstxRI          : std_logic                              := '1';
  signal BodyDataxDI     : std_logic_vector(7 downto 0)           := (others => '0');
  signal BodyStrobexSI   : std_logic                              := '0';
  signal HeaderDataxDI   : std_logic_vector(frameSize-1 downto 0) := (others => '0');
  signal HeaderStrobexSI : std_logic                              := '0';
  signal BuffersEmptyxSO : std_logic;
  signal BufOutxDO       : std_logic_vector(7 downto 0);
  signal OutputValidxSO  : std_logic;
  signal RdStrobexSI     : std_logic                              := '0';
  signal LengthxDO       : integer range 0 to 1024;

  -- clock
  signal Clk : std_logic := '1';

  constant PERIOD : time := 20ns;
  
begin  -- tb


  -- component instantiation
  DUT : outputFIFO
    generic map (
      frameSize => frameSize)
    port map (
      ClkxCI          => ClkxCI,
      RstxRI          => RstxRI,
      BodyDataxDI     => BodyDataxDI,
      BodyStrobexSI   => BodyStrobexSI,
      HeaderDataxDI   => HeaderDataxDI,
      HeaderStrobexSI => HeaderStrobexSI,
      BuffersEmptyxSO => BuffersEmptyxSO,
      BufOutxDO       => BufOutxDO,
      OutputValidxSO  => OutputValidxSO,
      RdStrobexSI     => RdStrobexSI,
      LengthxDO       => LengthxDO);

  -- clock generation
  Clk    <= not Clk after PERIOD/2;
  ClkxCI <= Clk;

  -- waveform generation
  WaveGen_Proc : process
  begin
    wait for 20 ns;
    wait until ClkxCI'event and ClkxCI = '1';
    RstxRI          <= '0';
    -- send a data frame with an odd number of bytes (header and body)
    BodyDataxDI     <= x"00";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"01";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"00";
    BodyStrobexSI   <= '0';
    HeaderDataxDI   <= x"0f";
    HeaderStrobexSI <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"00";
    BodyStrobexSI   <= '0';
    HeaderDataxDI   <= x"00";
    HeaderStrobexSI <= '0';

    -- send a data frame to the input buffer
    BodyDataxDI     <= x"10";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"11";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"12";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"13";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"14";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyStrobexSI   <= '0';
    wait until ClkxCI'event and ClkxCI = '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"15";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"16";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyStrobexSI   <= '0';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"17";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyDataxDI     <= x"18";
    HeaderDataxDI   <= x"1f";
    HeaderStrobexSI <= '1';
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyStrobexSI   <= '0';
    HeaderStrobexSI <= '0';
    HeaderDataxDI   <= x"00";
    BodyDataxDI     <= x"00";

    -- send a short frame (this is allowed for the last frame only)
    BodyDataxDI     <= x"ff";
    BodyStrobexSI   <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    BodyStrobexSI   <= '1';
    HeaderStrobexSI <= '1';
    HeaderDataxDI   <= x"ff";
    BodyDataxDI     <= x"ff";
    wait until ClkxCI'event and ClkxCI = '1';
    BodyStrobexSI   <= '0';
    HeaderStrobexSI <= '0';
    HeaderDataxDI   <= x"00";
    BodyDataxDI     <= x"00";

    wait until ClkxCI'event and ClkxCI = '1';
    wait until ClkxCI'event and ClkxCI = '1';
    wait until ClkxCI'event and ClkxCI = '1';
    wait until ClkxCI'event and ClkxCI = '1';

    RdStrobexSI <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    RdStrobexSI <= '0';
    wait until ClkxCI'event and ClkxCI = '1';
    RdStrobexSI <= '1';
    wait for 15 * PERIOD;
    RdStrobexSI <= '0';
    wait until ClkxCI'event and ClkxCI = '1';
    wait until ClkxCI'event and ClkxCI = '1';

    -- try illegal read
    RdStrobexSI <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    RdStrobexSI <= '0';



    wait;
  end process WaveGen_Proc;



  
end tb;


configuration outputFIFO_tb_tb_cfg of outputFIFO_tb is
  for tb
  end for;
end outputFIFO_tb_tb_cfg;

