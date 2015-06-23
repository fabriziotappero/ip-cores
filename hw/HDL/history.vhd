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
--* Version 1.0 - 2012/6/21 - LS
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
--* 
--*
--***************************************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

entity historyBuffer is


  port (
    ClkxCI          : in  std_logic;
    RstxRI          : in  std_logic;
    WriteInxDI      : in  std_logic_vector(7 downto 0);
    WExSI           : in  std_logic;
    NextWrAdrxDO    : out std_logic_vector(11 downto 0);  -- memory address at which the next byte will be written
    RExSI           : in  std_logic;    -- initiate a memory read back
    ReadBackAdrxDI  : in  std_logic_vector(11 downto 2);  -- for speed up read back is only word adressable
    ReadBackxDO     : out std_logic_vector(16*8-1 downto 0);
    ReadBackDonexSO : out std_logic);  -- indicates that requested read back data is available

end historyBuffer;


architecture Behavioral of historyBuffer is

  signal WrPtrxDN, WrPtrxDP                     : std_logic_vector(11 downto 0) := (others => '0');
  signal Ram0RdAdrAxD, Ram0RdAdrBxD             : std_logic_vector(13 downto 0);
  signal Ram1RdAdrAxD, Ram1RdAdrBxD             : std_logic_vector(13 downto 0);
  signal Ram0AdrAxD, Ram1AdrAxD                 : std_logic_vector(13 downto 0);
  signal RamWrDataxD                            : std_logic_vector(31 downto 0);
  signal Ram0OutAxD, Ram0OutBxD                 : std_logic_vector(31 downto 0);
  signal Ram1OutAxD, Ram1OutBxD                 : std_logic_vector(31 downto 0);
  signal Ram0WExS, Ram1WExS                     : std_logic_vector(3 downto 0);
  signal Ram0EnAxS, Ram1EnAxS                   : std_logic;
  signal RdAdrIntxD                             : integer;  -- to split up long expressions (type casts)
  signal Ram0RdAdrBasexD, Ram1RdAdrBasexD       : integer;
  signal DataReadyxSN, DataReadyxSP             : std_logic;
  signal LastReadBackAdrxDN, LastReadBackAdrxDP : std_logic_vector(11 downto 2);
  
begin

-- Note: If the requested address is not a multiple of 8 (ie bit 2 is 1) the
-- first word (4 bytes) we read is in ram 1. Therefore the adress for ram 0 has
-- to be incremented by 1. 
  RdAdrIntxD      <= to_integer(unsigned(ReadBackAdrxDI(11 downto 3)));
  Ram0RdAdrBasexD <= RdAdrIntxD   when ReadBackAdrxDI(2) = '0' else (RdAdrIntxD+1);
  Ram1RdAdrBasexD <= RdAdrIntxD;
  Ram0RdAdrAxD    <= std_logic_vector(to_unsigned(Ram0RdAdrBasexD, 9)) & "00000";
  Ram0RdAdrBxD    <= std_logic_vector(to_unsigned(Ram0RdAdrBasexD+1, 9)) & "00000";
  Ram1RdAdrAxD    <= std_logic_vector(to_unsigned(Ram1RdAdrBasexD, 9)) & "00000";
  Ram1RdAdrBxD    <= std_logic_vector(to_unsigned(Ram1RdAdrBasexD+1, 9)) & "00000";
  -- select port A address based on read/write mode
  Ram0AdrAxD      <= Ram0RdAdrAxD when WExSI = '0' else (WrPtrxDP(11 downto 3)& "00000");
  Ram1AdrAxD      <= Ram1RdAdrAxD when WExSI = '0' else (WrPtrxDP(11 downto 3) & "00000");
--  Ram0AdrAxD      <= Ram0RdAdrAxD when WExSI = '0' else (WrAdrxDI(11 downto 3)& "00000");
--  Ram1AdrAxD      <= Ram1RdAdrAxD when WExSI = '0' else (WrAdrxDI(11 downto 3) & "00000");


  RamWrDataxD <= WriteInxDI & WriteInxDI & WriteInxDI & WriteInxDI;

  -- The memory behaves like a register -> save requested adress for output decoder
  LastReadBackAdrxDN <= ReadBackAdrxDI;

  -- the read back value is reordered depending on wether the requested address
-- is a multiple of 8 or not. See comment above.
  ReadBackxDO <= (Ram1OutBxD & Ram0OutBxD & Ram1OutAxD & Ram0OutAxD) when LastReadBackAdrxDP(2) = '0' else (Ram0OutBxD & Ram1OutBxD & Ram0OutAxD & Ram1OutAxD);

  Ram0EnAxS <= WExSI or RExSI;
  Ram1EnAxS <= WExSI or RExSI;

  -- implement a write address counter
  wrCntPrcs : process (WExSI, WrPtrxDP)
  begin
    WrPtrxDN <= WrPtrxDP;
    Ram0WExS <= "0000";
    Ram1WExS <= "0000";
    if WExSI = '1' then
      if WrPtrxDP = x"fff" then
        WrPtrxDN <= x"000";
      else
        WrPtrxDN <= std_logic_vector(to_unsigned(to_integer(unsigned(WrPtrxDP))+1, 12));
      end if;
      -- decode lower 3 bits to the 8 write enable lines
      if WrPtrxDP(2) = '0' then
        -- write to ram 0
        Ram0WExS(to_integer(unsigned(WrPtrxDP(1 downto 0)))) <= '1';
      else
        Ram1WExS(to_integer(unsigned(WrPtrxDP(1 downto 0)))) <= '1';
      end if;
--      if WrAdrxDI(2) = '0' then
--        -- write to ram 0
--        Ram0WExS(to_integer(unsigned(WrAdrxDI(1 downto 0)))) <= '1';
--      else
--        Ram1WExS(to_integer(unsigned(WrAdrxDI(1 downto 0)))) <= '1';
--      end if;
      
    end if;
  end process wrCntPrcs;

  DataReadyxSN    <= RExSI;             -- it takes one clock cycle to read the
-- data, delay read enable for one cycle to create a output valid signal
  NextWrAdrxDO    <= WrPtrxDP;
  ReadBackDonexSO <= DataReadyxSP;

  process (ClkxCI, RstxRI)
  begin  -- process
    if RstxRI = '1' then
      LastReadBackAdrxDP <= (others => '0');
      WrPtrxDP           <= (others => '0');
      DataReadyxSP       <= '0';
    elsif ClkxCI'event and ClkxCI = '1' then  -- rising clock edge
      LastReadBackAdrxDP <= LastReadBackAdrxDN;
      WrPtrxDP           <= WrPtrxDN;
      DataReadyxSP       <= DataReadyxSN;
    end if;
  end process;

  -- port A is used to write and read (lower bytes) data, port B is for read only
  HistMem0Inst : RAMB16BWER
    generic map (
      -- DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
      DATA_WIDTH_A        => 36,
      DATA_WIDTH_B        => 36,
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
      DOA    => Ram0OutAxD,             -- 32-bit A port data output
      DOPA   => open,                   -- 4-bit A port parity output
      -- Port B Data: 32-bit (each) Port B data
      DOB    => Ram0OutBxD,
      DOPB   => open,
      -- Port A Address/Control Signals: 14-bit (each) Port A address and control signals
      ADDRA  => Ram0AdrAxD,             -- 14-bit A port address input
      CLKA   => ClkxCI,                 -- 1-bit A port clock input
      ENA    => Ram0EnAxS,              -- 1-bit A port enable input
      REGCEA => '1',           -- 1-bit A port register clock enable input
      RSTA   => RstxRI,        -- 1-bit A port register set/reset input
      WEA    => Ram0WExS,      -- 4-bit Port A byte-wide write enable input
      -- Port A Data: 32-bit (each) Port A data
      DIA    => RamWrDataxD,            -- 32-bit A port data input
      DIPA   => "0000",                 -- 4-bit A port parity input
      -- Port B Address/Control Signals: 14-bit (each) Port B address and control signals
      ADDRB  => Ram0RdAdrBxD,           -- 14-bit B port address input
      CLKB   => ClkxCI,                 -- 1-bit B port clock input
      ENB    => RExSI,                  -- 1-bit B port enable input
      REGCEB => '1',           -- 1-bit B port register clock enable input
      RSTB   => RstxRI,        -- 1-bit B port register set/reset input
      WEB    => x"0",          -- 4-bit Port B byte-wide write enable input
      -- Port B Data: 32-bit (each) Port B data
      DIB    => x"00000000",            -- 32-bit B port data input
      DIPB   => x"0"                    -- 4-bit B port parity input
      );


  -- RAM 1
  -- port A is used to write and read (lower bytes) data, port B is for read only
  HistMem1Inst : RAMB16BWER
    generic map (
      -- DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
      DATA_WIDTH_A        => 36,
      DATA_WIDTH_B        => 36,
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
      DOA    => Ram1OutAxD,             -- 32-bit A port data output
      DOPA   => open,                   -- 4-bit A port parity output
      -- Port B Data: 32-bit (each) Port B data
      DOB    => Ram1OutBxD,
      DOPB   => open,
      -- Port A Address/Control Signals: 14-bit (each) Port A address and control signals
      ADDRA  => Ram1AdrAxD,             -- 14-bit A port address input
      CLKA   => ClkxCI,                 -- 1-bit A port clock input
      ENA    => Ram1EnAxS,              -- 1-bit A port enable input
      REGCEA => '1',           -- 1-bit A port register clock enable input
      RSTA   => RstxRI,        -- 1-bit A port register set/reset input
      WEA    => Ram1WExS,      -- 4-bit Port A byte-wide write enable input
      -- Port A Data: 32-bit (each) Port A data
      DIA    => RamWrDataxD,            -- 32-bit A port data input
      DIPA   => "0000",                 -- 4-bit A port parity input
      -- Port B Address/Control Signals: 14-bit (each) Port B address and control signals
      ADDRB  => Ram1RdAdrBxD,           -- 14-bit B port address input
      CLKB   => ClkxCI,                 -- 1-bit B port clock input
      ENB    => RExSI,                  -- 1-bit B port enable input
      REGCEB => '1',           -- 1-bit B port register clock enable input
      RSTB   => RstxRI,        -- 1-bit B port register set/reset input
      WEB    => x"0",          -- 4-bit Port B byte-wide write enable input
      -- Port B Data: 32-bit (each) Port B data
      DIB    => x"00000000",            -- 32-bit B port data input
      DIPB   => x"0"                    -- 4-bit B port parity input
      );

end Behavioral;



