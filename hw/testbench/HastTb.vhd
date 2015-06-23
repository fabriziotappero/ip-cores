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
--* Version 1.0 - 2012/6/17 - LS
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
--* Test bench for entity hashTable
--*
--***************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity HashTable_tb is

end HashTable_tb;

-------------------------------------------------------------------------------

architecture tb of HashTable_tb is

  component HashTable
    generic (
      entryBitWidth : integer);
    port (
      ClkxCI      : in  std_logic;
      RstxRI      : in  std_logic;
      NewEntryxDI : in  std_logic_vector(entryBitWidth-1 downto 0);
      EnWrxSI     : in  std_logic;
      Key0xDI     : in  std_logic_vector(7 downto 0);
      Key1xDI     : in  std_logic_vector(7 downto 0);
      Key2xDI     : in  std_logic_vector(7 downto 0);
      OldEntryxDO : out std_logic_vector(entryBitWidth-1 downto 0));
  end component;

  -- component generics
  constant entryBitWidth : integer := 12;

  -- component ports
  signal ClkxCI      : std_logic;
  signal RstxRI      : std_logic                                  := '1';
  signal NewEntryxDI : std_logic_vector(entryBitWidth-1 downto 0) := (others => '0');
  signal EnWrxSI     : std_logic                                  := '0';
  signal Key0xDI     : std_logic_vector(7 downto 0)               := (others => '0');
  signal Key1xDI     : std_logic_vector(7 downto 0)               := (others => '0');
  signal Key2xDI     : std_logic_vector(7 downto 0)               := (others => '0');
  signal OldEntryxDO : std_logic_vector(entryBitWidth-1 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : HashTable
    generic map (
      entryBitWidth => entryBitWidth)
    port map (
      ClkxCI      => ClkxCI,
      RstxRI      => RstxRI,
      NewEntryxDI => NewEntryxDI,
      EnWrxSI     => EnWrxSI,
      Key0xDI     => Key0xDI,
      Key1xDI     => Key1xDI,
      Key2xDI     => Key2xDI,
      OldEntryxDO => OldEntryxDO);

  -- clock generation
  Clk    <= not Clk after 10 ns;
  ClkxCI <= Clk;


  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    wait until Clk = '1';
    Key0xDI     <= x"10";
    Key1xDI     <= x"32";
    Key2xDI     <= x"54";
    NewEntryxDI <= x"210";
    EnWrxSI     <= '1';
    wait until Clk'event and Clk = '1';

    Key0xDI     <= x"00";
    Key1xDI     <= x"00";
    Key2xDI     <= x"00";
    NewEntryxDI <= x"000";
    EnWrxSI     <= '1';
    wait until Clk'event and Clk = '1';

    Key0xDI     <= x"10";
    Key1xDI     <= x"32";
    Key2xDI     <= x"54";
    NewEntryxDI <= x"fff";
    EnWrxSI     <= '0';
    wait until Clk'event and Clk = '1';

    Key0xDI     <= x"00";
    Key1xDI     <= x"00";
    Key2xDI     <= x"00";
    NewEntryxDI <= x"111";
    EnWrxSI     <= '0';
    wait until Clk'event and Clk = '1';

    Key0xDI     <= x"10";
    Key1xDI     <= x"32";
    Key2xDI     <= x"54";
    NewEntryxDI <= x"fff";
    EnWrxSI     <= '1';
    wait until Clk'event and Clk = '1';

    Key0xDI     <= x"10";
    Key1xDI     <= x"32";
    Key2xDI     <= x"54";
    NewEntryxDI <= x"000";
    EnWrxSI     <= '0';
    wait until Clk'event and Clk = '1';

    wait;
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration HashTable_tb_tb_cfg of HashTable_tb is
  for tb
  end for;
end HashTable_tb_tb_cfg;

-------------------------------------------------------------------------------
