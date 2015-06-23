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
--* Simple testebench for manual signal inspection of the Wishbone interfaces
--* and the DMA unit of CompressorTop.vhd
--*
--***************************************************************************************************************
library ieee;
use ieee.std_logic_1164.all;


entity CompressorTop_tb is

end CompressorTop_tb;


architecture TB of CompressorTop_tb is

  component CompressorTop
    port (
      ClkxCI   : in  std_logic;
      RstxRI   : in  std_logic;
      SlCycxSI : in  std_logic;
      SlStbxSI : in  std_logic;
      SlWexSI  : in  std_logic;
      SlSelxDI : in  std_logic_vector(3 downto 0);
      SlAdrxDI : in  std_logic_vector(4 downto 2);
      SlDatxDI : in  std_logic_vector(31 downto 0);
      SlDatxDO : out std_logic_vector(31 downto 0);
      SlAckxSO : out std_logic;
      SlErrxSO : out std_logic;
      IntxSO   : out std_logic;
      MaCycxSO : out std_logic;
      MaStbxSO : out std_logic;
      MaWexSO  : out std_logic;
      MaSelxDO : out std_logic_vector(3 downto 0);
      MaAdrxDO : out std_logic_vector(31 downto 0);
      MaDatxDO : out std_logic_vector(31 downto 0);
      MaDatxDI : in  std_logic_vector(31 downto 0);
      MaAckxSI : in  std_logic;
      MaErrxSI : in  std_logic);
  end component;

  constant PERIOD : time := 25 ns;


  signal ClkxCI   : std_logic                     := '0';
  signal RstxRI   : std_logic                     := '1';
  signal SlCycxSI : std_logic                     := '0';
  signal SlStbxSI : std_logic                     := '0';
  signal SlWexSI  : std_logic                     := '0';
  signal SlSelxDI : std_logic_vector(3 downto 0)  := "0000";
  signal SlAdrxDI : std_logic_vector(4 downto 2)  := (others => '0');
  signal SlDatxDI : std_logic_vector(31 downto 0) := (others => '0');
  signal SlDatxDO : std_logic_vector(31 downto 0) := (others => '0');
  signal SlAckxSO : std_logic;
  signal SlErrxSO : std_logic;
  signal IntxSO   : std_logic;
  signal MaCycxSO : std_logic;
  signal MaStbxSO : std_logic;
  signal MaWexSO  : std_logic;
  signal MaSelxDO : std_logic_vector(3 downto 0)  := (others => '0');
  signal MaAdrxDO : std_logic_vector(31 downto 0) := (others => '0');
  signal MaDatxDO : std_logic_vector(31 downto 0) := (others => '0');
  signal MaDatxDI : std_logic_vector(31 downto 0) := (others => '0');
  signal MaAckxSI : std_logic                     := '0';
  signal MaErrxSI : std_logic                     := '0';
  
begin

  ClkxCI <= not ClkxCI after PERIOD/2;

  process
  begin
    RstxRI <= '1';
    wait until ClkxCI'event and ClkxCI = '1';
    RstxRI <= '0';
    wait until ClkxCI'event and ClkxCI = '1';

    -- reset core
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "111";
    SlWexSI  <= '1';
    SlSelxDI <= "1111";
    SlDatxDI <= x"00000001";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- set inc dest addr flag and IE for in fifo full and for core done
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "001";
    SlWexSI  <= '1';
    SlDatxDI <= x"00020100";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- read flags
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "001";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";


    -- setup dma destination
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "100";
    SlWexSI  <= '1';
    SlDatxDI <= x"12345670";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- setup dma length
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "101";
    SlWexSI  <= '1';
    SlDatxDI <= x"00000030";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- read dma destination
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "100";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- setup in fifo thresholds
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "010";
    SlWexSI  <= '1';
    SlDatxDI <= x"000f0004";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";


    -- write data
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "000";
    SlWexSI  <= '1';
    SlDatxDI <= x"03020100";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- write data
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "000";
    SlWexSI  <= '1';
    SlDatxDI <= x"07060504";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- write data
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "000";
    SlWexSI  <= '1';
    SlDatxDI <= x"0b0a0908";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- write data
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "000";
    SlWexSI  <= '1';
    SlDatxDI <= x"0f0e0d0c";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- write data
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "000";
    SlWexSI  <= '1';
    SlDatxDI <= x"05030201";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "000";
    SlWexSI  <= '1';
    SlDatxDI <= x"0b0a0706";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- write data
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "000";
    SlWexSI  <= '1';
    SlDatxDI <= x"1413120c";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    -- write data
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "000";
    SlWexSI  <= '1';
    SlDatxDI <= x"08070605";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    --wait for PERIOD*2*20;

    -- enable done interrupt
--    wait until ClkxCI'event and ClkxCI = '1';
--    SlCycxSI <= '1';
--    SlStbxSI <= '1';
--    SlAdrxDI <= "001";
--    SlWexSI  <= '1';
--    SlDatxDI <= x"00200102";
--    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
--    SlCycxSI <= '0';
--    SlStbxSI <= '0';
--    SlAdrxDI <= "000";
--    SlWexSI  <= '0';
--    SlDatxDI <= x"00000000";

    -- flush core
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "111";
    SlWexSI  <= '1';
    SlDatxDI <= x"00000002";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";

    wait for PERIOD*200;

    -- read flags
    wait until ClkxCI'event and ClkxCI = '1';
    SlCycxSI <= '1';
    SlStbxSI <= '1';
    SlAdrxDI <= "001";
    SlWexSI  <= '0';
    SlDatxDI <= x"00000000";
    wait until ClkxCI'event and ClkxCI = '1' and SlAckxSO = '1';
    SlCycxSI <= '0';
    SlStbxSI <= '0';
    SlAdrxDI <= "000";




    wait;
  end process;

  MaAckxSI <= MaCycxSO and MaStbxSO;
  --MaErrxSI <= MaCycxSO and MaStbxSO;

  DUT : CompressorTop
    port map (
      ClkxCI   => ClkxCI,
      RstxRI   => RstxRI,
      SlCycxSI => SlCycxSI,
      SlStbxSI => SlStbxSI,
      SlWexSI  => SlWexSI,
      SlSelxDI => SlSelxDI,
      SlAdrxDI => SlAdrxDI,
      SlDatxDI => SlDatxDI,
      SlDatxDO => SlDatxDO,
      SlAckxSO => SlAckxSO,
      SlErrxSO => SlErrxSO,
      IntxSO   => IntxSO,
      MaCycxSO => MaCycxSO,
      MaStbxSO => MaStbxSO,
      MaWexSO  => MaWexSO,
      MaSelxDO => MaSelxDO,
      MaAdrxDO => MaAdrxDO,
      MaDatxDO => MaDatxDO,
      MaDatxDI => MaDatxDI,
      MaAckxSI => MaAckxSI,
      MaErrxSI => MaErrxSI);


end TB;


