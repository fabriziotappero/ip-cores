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
--* Version 1.0 - 2012/7/8 - LS
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
--* This is the test bench for outputEncoder.vhd
--*
--***************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity outputEncoder_tb is

end outputEncoder_tb;

-------------------------------------------------------------------------------

architecture Tb of outputEncoder_tb is

  component outputEncoder
    generic (
      frameSize   : integer;
      minMatchLen : integer;
      maxMatchLen : integer);
    port (
      ClkxCI          : in  std_logic;
      RstxRI          : in  std_logic;
      OffsetxDI       : in  std_logic_vector(11 downto 0);
      MatchLengthxDI  : in  integer range 0 to maxMatchLen;
      EnxSI           : in  std_logic;
      EndOfDataxSI    : in  std_logic;
      LiteralxDI      : in  std_logic_vector(7 downto 0);
      BodyStrobexSO   : out std_logic;  -- strobe signal: is assert when a new item is available
      BodyOutxDO      : out std_logic_vector(7 downto 0);  -- encoded data output
      HeaderStrobexSO : out std_logic;
      HeaderOutxDO    : out std_logic_vector(frameSize-1 downto 0);
      DonexSO         : out std_logic);
  end component;

  -- component generics
  constant frameSize   : integer := 8;
  constant minMatchLen : integer := 3;
  constant maxMatchLen : integer := 16;

  -- component ports
  signal ClkxCI          : std_logic;
  signal RstxRI          : std_logic                      := '1';
  signal OffsetxDI       : std_logic_vector(11 downto 0)  := (others => '0');
  signal MatchLengthxDI  : integer range 0 to maxMatchLen := 0;
  signal EnxSI           : std_logic                      := '0';
  signal EndOfDataxSI    : std_logic                      := '0';
  signal LiteralxDI      : std_logic_vector(7 downto 0)   := x"00";
--  signal EncHeaderOutxDO   : std_logic_vector(frameSize-1 downto 0);
--  signal EncBodyOutputxDO  : std_logic_vector(frameSize*8-1 downto 0);
--  signal EncOutputValidxSO : std_logic;
  signal BodyStrobexSO   : std_logic;  -- strobe signal: is assert when a new item is available
  signal BodyOutxDO      : std_logic_vector(7 downto 0);  -- encoded data output
  signal HeaderStrobexSO : std_logic;
  signal HeaderOutxDO    : std_logic_vector(frameSize-1 downto 0);
  signal DonexSO         : std_logic;
  -- clock
  signal Clk             : std_logic                      := '1';

begin  -- Tb

  -- component instantiation
  DUT : outputEncoder
    generic map (
      frameSize   => frameSize,
      minMatchLen => minMatchLen,
      maxMatchLen => maxMatchLen)
    port map (
      ClkxCI          => ClkxCI,
      RstxRI          => RstxRI,
      OffsetxDI       => OffsetxDI,
      MatchLengthxDI  => MatchLengthxDI,
      EnxSI           => EnxSI,
      EndOfDataxSI    => EndOfDataxSI,
      LiteralxDI      => LiteralxDI,
      BodyStrobexSO   => BodyStrobexSO,
      BodyOutxDO      => BodyOutxDO,
      HeaderStrobexSO => HeaderStrobexSO,
      HeaderOutxDO    => HeaderOutxDO,
      DonexSO         => DonexSO);

  -- clock generation
  Clk    <= not Clk after 10 ns;
  ClkxCI <= Clk;

  -- waveform generation
  WaveGen_Proc : process
  begin
    wait until Clk'event and Clk = '1';
    wait until Clk'event and Clk = '1';
    RstxRI         <= '0';
    MatchLengthxDI <= 3;
    OffsetxDI      <= x"00a";
    EnxSI          <= '1';
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 0;                -- will be suppressed
    LiteralxDI     <= x"11";
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 0;                -- will be suppressed
    OffsetxDI      <= x"222";
    LiteralxDI     <= x"22";
    wait until Clk'event and Clk = '1';


    MatchLengthxDI <= 2;
    LiteralxDI     <= x"11";
    OffsetxDI      <= x"fff";
    EnxSI          <= '1';
    wait until Clk'event and Clk = '1';

    MatchLengthxDI <= 4;
    OffsetxDI      <= x"010";
    EnxSI          <= '1';
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 0;                -- will be suppressed
    LiteralxDI     <= x"11";
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 0;                -- will be suppressed
    OffsetxDI      <= x"222";
    LiteralxDI     <= x"22";
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 5;                -- will be suppressed
    LiteralxDI     <= x"33";
    wait until Clk'event and Clk = '1';


    EnxSI <= '0';
    wait until Clk'event and Clk = '1';

    MatchLengthxDI <= 0;
    LiteralxDI     <= x"ab";
    OffsetxDI      <= x"000";
    EnxSI          <= '1';
    wait until Clk'event and Clk = '1';

    EnxSI <= '0';
    wait until Clk'event and Clk = '1';

    MatchLengthxDI <= 1;
    LiteralxDI     <= x"cd";
    OffsetxDI      <= x"00a";
    EnxSI          <= '1';
    wait until Clk'event and Clk = '1';

    EnxSI <= '0';
    wait until Clk'event and Clk = '1';

    MatchLengthxDI <= 4;
    OffsetxDI      <= x"123";
    EnxSI          <= '1';
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 0;                -- will be suppressed
    LiteralxDI     <= x"11";
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 0;                -- will be suppressed
    OffsetxDI      <= x"222";
    LiteralxDI     <= x"22";
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 5;                -- will be suppressed
    LiteralxDI     <= x"33";
    wait until Clk'event and Clk = '1';

    MatchLengthxDI <= 3;
    OffsetxDI      <= x"aaa";
    EnxSI          <= '1';
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 0;                -- will be suppressed
    LiteralxDI     <= x"11";
    wait until Clk'event and Clk = '1';
    MatchLengthxDI <= 0;                -- will be suppressed
    OffsetxDI      <= x"222";
    LiteralxDI     <= x"22";
    wait until Clk'event and Clk = '1';

    EnxSI <= '0';
    wait until Clk'event and Clk = '1';

    MatchLengthxDI <= 1;
    LiteralxDI     <= x"ef";
    OffsetxDI      <= x"00a";
    EnxSI          <= '1';
    wait until Clk'event and Clk = '1';

    EnxSI <= '0';
    wait until Clk'event and Clk = '1';

    MatchLengthxDI <= 1;
    LiteralxDI     <= x"00";
    OffsetxDI      <= x"00a";
    EnxSI          <= '1';
    wait until Clk'event and Clk = '1';


    EnxSI        <= '0';
    EndOfDataxSI <= '1';
    wait until Clk'event and Clk = '1';

    EndOfDataxSI <= '0';
    EnxSI        <= '0';
    wait;
    
  end process WaveGen_Proc;

  

end Tb;

-------------------------------------------------------------------------------

configuration outputEncoder_tb_Tb_cfg of outputEncoder_tb is
  for Tb
  end for;
end outputEncoder_tb_Tb_cfg;

-------------------------------------------------------------------------------
