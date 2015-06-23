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
--*   release
--*
--***************************************************************************************************************
--*
--* Naming convention:  http://dz.ee.ethz.ch/en/information/hdl-help/vhdl-naming-conventions.html
--*
--***************************************************************************************************************
--*
--* Implements a 4 byte input, 1 byte output FIFO buffer. Note: so far only writes where all 4 bytes contain
--* data are supported.
--*
--***************************************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

entity InputFIFO is
  
  port (
    ClkxCI        : in  std_logic;
    RstxRI        : in  std_logic;
    DInxDI        : in  std_logic_vector(31 downto 0);
--    SelInxSI      : in  std_logic_vector(3 downto 0); -- not supported
    WExSI         : in  std_logic;
    StopOutputxSI : in  std_logic;
    BusyxSO       : out std_logic;
    DOutxDO       : out std_logic_vector(7 downto 0);
    OutStrobexSO  : out std_logic;
    LengthxDO     : out integer range 0 to 2048);

end InputFIFO;

architecture Behavioral of InputFIFO is

  constant ADR_BIT_LEN : integer := 11;    -- addresses are in _bytes_
  constant DEPTH       : integer := 2048;  -- max length of the fifo in _bytes_

  signal LengthxDN, LengthxDP       : integer range 0 to DEPTH   := 0;  -- number of _bytes_ in fifo
  signal WrPtrxDN, WrPtrxDP         : integer range 0 to DEPTH-1 := 0;  -- write pointer in _bytes_
  signal RdPtrxDN, RdPtrxDP         : integer range 0 to DEPTH-1 := 0;  -- read pointer in _bytes_
  signal DoWritexS, DoReadxS        : std_logic;
  signal OutStrobexSN, OutStrobexSP : std_logic                  := '0';
  signal BusyxSN, BusyxSP           : std_logic                  := '0';

  signal BRamDOutxD  : std_logic_vector(31 downto 0);
  signal BRamDInxD   : std_logic_vector(31 downto 0);
  signal BRamWrAdrxD : std_logic_vector(13 downto 0);
  signal BRamRdAdrxD : std_logic_vector(13 downto 0);
  
begin  -- Behavorial

  -- implement write port logic
  process (LengthxDP, WExSI, WrPtrxDP)
  begin
    WrPtrxDN    <= WrPtrxDP;
    BusyxSN     <= '0';
    BRamWrAdrxD <= std_logic_vector(to_unsigned(WrPtrxDP, ADR_BIT_LEN)) & "000";
    DoWritexS <= '0';

    if WExSI = '1' and LengthxDP <= (DEPTH-4) then
      DoWritexS <= '1';
      if WrPtrxDP < DEPTH-4 then
        WrPtrxDN <= WrPtrxDP + 4;
      else
        WrPtrxDN <= 0;
      end if;
    end if;
    -- use busy signal as an almost full indicator
    if LengthxDP >= DEPTH-8 then  -- indicate it when we have room for two or less writes
      BusyxSN <= '1';
    end if;
  end process;

  -- purpose: implement data output port logic
  process (DInxDI, LengthxDP, RdPtrxDP, StopOutputxSI)
  begin
    RdPtrxDN     <= RdPtrxDP;
    DoReadxS     <= '0';
    OutStrobexSN <= '0';
    BRamDInxD    <= DInxDI;
    BRamRdAdrxD  <= std_logic_vector(to_unsigned(RdPtrxDP, ADR_BIT_LEN)) & "000";

    if LengthxDP > 0 and StopOutputxSI = '0' then
      DoReadxS     <= '1';
      OutStrobexSN <= '1';  -- bram delays data output by one clock cycle, do same for strobe
      if RdPtrxDP < DEPTH-1 then
        RdPtrxDN <= RdPtrxDP + 1;
      else
        RdPtrxDN <= 0;
      end if;
    end if;
    
  end process;

  -- purpose: implement a length counter
  lenCntPrcs : process (DoReadxS, DoWritexS, LengthxDP)
  begin
    LengthxDN <= LengthxDP;
    if DoWritexS = '1' and DoReadxS = '0' then
      if LengthxDP <= (DEPTH-4) then
        LengthxDN <= LengthxDP + 4;
      else
        assert false report "Input FIFO overrun" severity error;
      end if;
    end if;
    if DoWritexS = '0' and DoReadxS = '1' then
      assert LengthxDP > 0 report "input FIFO underrun" severity error;
      LengthxDN <= LengthxDP - 1;
    end if;
    if DoWritexS = '1' and DoReadxS = '1' then
      assert LengthxDP < DEPTH-3 report "Input FIFO underrun at simultaneous read and write" severity error;
      LengthxDN <= LengthxDP + 4 - 1;
    end if;
  end process lenCntPrcs;

  DOutxDO      <= BRamDOutxD(7 downto 0);
  LengthxDO    <= LengthxDP;
  OutStrobexSO <= OutStrobexSP;
  BusyxSO      <= BusyxSP;

  -- purpose: implement registers
  process (ClkxCI, RstxRI)
  begin
    if ClkxCI'event and ClkxCI = '1' then  -- rising clock edge
      if RstxRI = '1' then
        LengthxDP    <= 0;
        WrPtrxDP     <= 0;
        RdPtrxDP     <= 0;
        OutStrobexSP <= '0';
        BusyxSP      <= '0';
      else
        LengthxDP    <= LengthxDN;
        WrPtrxDP     <= WrPtrxDN;
        RdPtrxDP     <= RdPtrxDN;
        OutStrobexSP <= OutStrobexSN;
        BusyxSP      <= BusyxSN;
      end if;
    end if;
  end process;

  FifoBRam : RAMB16BWER
    generic map (
      -- DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
      DATA_WIDTH_A        => 36,
      DATA_WIDTH_B        => 9,
      -- DOA_REG/DOB_REG: Optional output register (0 or 1)
      DOA_REG             => 0,
      DOB_REG             => 0,
      -- EN_RSTRAM_A/EN_RSTRAM_B: Enable/disable RST
      EN_RSTRAM_A         => true,
      EN_RSTRAM_B         => true,
      -- INIT_A/INIT_B: Initial values on output port
      INIT_A              => X"000000000",
      INIT_B              => X"000000000",
      -- INIT_FILE: Optional file used to specify initial RAM contents
      INIT_FILE           => "NONE",
      -- RSTTYPE: "SYNC" or "ASYNC" 
      RSTTYPE             => "SYNC",
      -- RST_PRIORITY_A/RST_PRIORITY_B: "CE" or "SR" 
      RST_PRIORITY_A      => "CE",
      RST_PRIORITY_B      => "CE",
      -- SIM_COLLISION_CHECK: Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE" 
      SIM_COLLISION_CHECK => "ALL",
      -- SIM_DEVICE: Must be set to "SPARTAN6" for proper simulation behavior
      SIM_DEVICE          => "SPARTAN6",
      -- SRVAL_A/SRVAL_B: Set/Reset value for RAM output
      SRVAL_A             => X"000000000",
      SRVAL_B             => X"000000000",
      -- WRITE_MODE_A/WRITE_MODE_B: "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      WRITE_MODE_A        => "WRITE_FIRST",
      WRITE_MODE_B        => "WRITE_FIRST"
      )
    port map (
      -- Port A Data: 32-bit (each) Port A data
      DOA    => open,                   -- 32-bit A port data output
      DOPA   => open,                   -- 4-bit A port parity output
      -- Port B Data: 32-bit (each) Port B data
      DOB    => BRamDOutxD,             -- 32-bit B port data output
      DOPB   => open,                   -- 4-bit B port parity output
      -- Port A Address/Control Signals: 14-bit (each) Port A address and control signals
      ADDRA  => BRamWrAdrxD,            -- 14-bit A port address input
      CLKA   => ClkxCI,                 -- 1-bit A port clock input
      ENA    => DoWritexS,              -- 1-bit A port enable input
      REGCEA => '1',          -- 1-bit A port register clock enable input
      RSTA   => RstxRI,       -- 1-bit A port register set/reset input
      WEA    => "1111",       -- 4-bit Port A byte-wide write enable input
      -- Port A Data: 32-bit (each) Port A data
      DIA    => DInxDI,                 -- 32-bit A port data input
      DIPA   => "0000",                 -- 4-bit A port parity input
      -- Port B Address/Control Signals: 14-bit (each) Port B address and control signals
      ADDRB  => BRamRdAdrxD,            -- 14-bit B port address input
      CLKB   => ClkxCI,                 -- 1-bit B port clock input
      ENB    => DoReadxS,               -- 1-bit B port enable input
      REGCEB => '1',          -- 1-bit B port register clock enable input
      RSTB   => RstxRI,       -- 1-bit B port register set/reset input
      WEB    => "0000",       -- 4-bit Port B byte-wide write enable input
      -- Port B Data: 32-bit (each) Port B data
      DIB    => x"00000000",            -- 32-bit B port data input
      DIPB   => "0000"                  -- 4-bit B port parity input
      );

end Behavioral;
