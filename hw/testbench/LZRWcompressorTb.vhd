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
--* Version 1.0 - 2012/9/16 - LS
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
--* This is a file based testbench for the LZRW1 compressor core. It reads data
--* binary from a configured file, and feeds it int the core. The compressed data
--* is stored in a second file for verifycation. (Use the two java programs
--* provided with this project to create and verify test vectors)
--*
--***************************************************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;

-------------------------------------------------------------------------------

entity LZRWcompressor_tb is

end LZRWcompressor_tb;

-------------------------------------------------------------------------------

architecture tb of LZRWcompressor_tb is

  component LZRWcompressor
    port (
      ClkxCI         : in  std_logic;
      RstxRI         : in  std_logic;
      DataInxDI      : in  std_logic_vector(7 downto 0);
      StrobexSI      : in  std_logic;
      FlushBufxSI    : in  std_logic;
      BusyxSO        : out std_logic;
      DonexSO        : out std_logic;
      BufOutxDO      : out std_logic_vector(7 downto 0);
      OutputValidxSO : out std_logic;
      RdStrobexSI    : in  std_logic;
      LengthxDO      : out integer range 0 to 1024);
  end component;

  -- component ports
  signal ClkxCI         : std_logic;
  signal RstxRI         : std_logic                    := '1';
  signal DInxDI         : std_logic_vector(7 downto 0) := (others => '0');
  signal StrobexSI      : std_logic                    := '0';
  signal FlushBufxSI    : std_logic                    := '0';
  signal BusyxSO        : std_logic;
  signal DonexSO        : std_logic;
  signal BufOutxDO      : std_logic_vector(7 downto 0);
  signal OutputValidxSO : std_logic;
  signal RdStrobexSI    : std_logic                    := '0';
  signal LengthxDO      : integer range 0 to 1024;


  -- clock
  signal Clk : std_logic := '1';


  signal TbDone : std_logic := '0';

  -- configuration
  constant DATA_IN_FILE_NAME  : string := "../../test files/TVect1.bin";  -- file with stimuli which will be compressed (relative to XST directroy)
  constant DATA_OUT_FILE_NAME : string := "../../test files/TVect1.cmp";  -- filename for compressed data

  constant PERIOD : time := 20 ns;

  type binFileType is file of character;
  
begin  -- tb

  -- component instantiation
  DUT : LZRWcompressor
    port map (
      ClkxCI         => ClkxCI,
      RstxRI         => RstxRI,
      DataInxDI      => DInxDI,
      StrobexSI      => StrobexSI,
      FlushBufxSI    => FlushBufxSI,
      BusyxSO        => BusyxSO,
      DonexSO        => DonexSO,
      BufOutxDO      => BufOutxDO,
      OutputValidxSO => OutputValidxSO,
      RdStrobexSI    => RdStrobexSI,
      LengthxDO      => LengthxDO
      );

  -- clock generation
  Clk    <= not Clk after (PERIOD / 2);
  ClkxCI <= Clk;

  -- waveform generation
  WaveGen_Proc : process
    file srcFile     : binFileType is in DATA_IN_FILE_NAME;  -- uncompressed data input in file
    variable srcChar : character;
    variable l       : line;
  begin
    wait for PERIOD;
    wait until Clk'event and Clk = '1';
    RstxRI <= '0';

    while not endfile(srcFile) loop
      read(srcFile, srcChar);
--      write(l, "found char ");
--      write(l, character'image(srcChar));
--      write(l, "   ");
--      write(l, character'pos(srcChar));
--      writeline(OUTPUT, l);

      wait until Clk'event and Clk = '1';
      if BusyxSO = '0' then
        DInxDI    <= std_logic_vector(to_unsigned(character'pos(srcChar), 8));
        StrobexSI <= '1';
      end if;
      wait until Clk'event and Clk = '1';
      StrobexSI <= '0';
      DInxDI    <= "--------";
      
    end loop;
    StrobexSI <= '0';

    for i in 0 to 10 loop
      wait until Clk'event and Clk = '1';
    end loop;

    --wait until Clk'event and Clk = '1';
    FlushBufxSI <= '1';
    wait until Clk'event and Clk = '1';
    FlushBufxSI <= '0';

    file_close(srcFile);

    for i in 0 to 10 loop
      wait until Clk'event and Clk = '1';
    end loop;

    TbDone <= '1';

    wait;
    
  end process WaveGen_Proc;

  -- process to receive compressed data from the core and store it in a file
  pickupPrcs : process
    file destFile     : binFileType is out DATA_OUT_FILE_NAME;  -- receives compressed data
    variable destChar : character;
    variable l        : line;
  begin

    while true loop
      wait until Clk'event and Clk = '1';
      if LengthxDO > 0 then
        RdStrobexSI <= '1';
      else
        RdStrobexSI <= '0';
      end if;
      if OutputValidxSO = '1' then
        --     wait until Clk'event and Clk = '1';
        destChar := character'val(to_integer(unsigned(BufOutxDO)));
        write(destFile, destChar);
      end if;
    end loop;

    file_close(destFile);
    wait;
  end process;
  

end tb;

-------------------------------------------------------------------------------

configuration LZRWcompressor_tb_tb_cfg of LZRWcompressor_tb is
  for tb
  end for;
end LZRWcompressor_tb_tb_cfg;

-------------------------------------------------------------------------------
