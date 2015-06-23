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
--* Version 1.0 - 2013/04/05 - LS
--*   release
--*
--***************************************************************************************************************
--*
--* Naming convention:  http://dz.ee.ethz.ch/en/information/hdl-help/vhdl-naming-conventions.html
--*
--***************************************************************************************************************
--*
--* Implements a hash table. The number of entries is fixed to 2048. The entries length is configurable
--* (up to 18 bits)
--*
--***************************************************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity HashTable is
  generic (
    entryBitWidth : integer := 12);
  port (
    ClkxCI      : in  std_logic;
    RstxRI      : in  std_logic;
    NewEntryxDI : in  std_logic_vector(entryBitWidth-1 downto 0);  -- new entry
-- to be stored in the table
    EnWrxSI     : in  std_logic;  -- initiate a write access to hash table
    -- the three bytes that serve as a key
    Key0xDI     : in  std_logic_vector(7 downto 0);
    Key1xDI     : in  std_logic_vector(7 downto 0);
    Key2xDI     : in  std_logic_vector(7 downto 0);
    -- the old entry which was stored under the given keys hash
    OldEntryxDO : out std_logic_vector(entryBitWidth-1 downto 0));
end HashTable;

architecture Behavioral of HashTable is

  constant HASH_BIT_LEN : integer := 11;  -- number of address bits of the hash table

  constant SEED : integer := 40543;  -- seed value for hash algorithm as specified by Ross Williamson

  constant ZERO : std_logic_vector(17 downto 0) := (others => '0');

  signal Stage0xS : std_logic_vector(11 downto 0);
  signal Stage1xS : std_logic_vector(15 downto 0);

  signal ProductxS : integer;
  signal RawHashxS : std_logic_vector(31 downto 0);  -- This is the full output which is then truncated

  signal BRamAddrxD               : std_logic_vector(13 downto 0);
  signal TblInxD, TblOutxD        : std_logic_vector(17 downto 0);  -- data input and out of table memory
  signal BRamWexS                 : std_logic_vector(3 downto 0);
  signal BRamLDInxD, BRamHDInxD   : std_logic_vector(31 downto 0);
  signal BRamLPInxD, BRamHPInxD   : std_logic_vector(3 downto 0);
  signal BRamLDOutxD, BRamHDOutxD : std_logic_vector(31 downto 0);
  signal BRamLPOutxD, BRamHPOutxD : std_logic_vector(3 downto 0);
  
begin


  -- first stage is: ((k0<<4)^k1)
  Stage0xS <= Key0xDI(7 downto 4) & (Key0xDI(3 downto 0) xor Key1xDI(7 downto 4)) & Key1xDI(3 downto 0);

  -- second stage: (stage0<<4) ^ k2
  Stage1xS <= Stage0xS(11 downto 4) & (Stage0xS(3 downto 0) xor Key2xDI(7 downto 4)) & Key2xDI(3 downto 0);

  ProductxS <= SEED * to_integer(unsigned(Stage1xS));
  RawHashxS <= std_logic_vector(to_unsigned(ProductxS, 32));

  -- note: The hash algorithm used by Ross Williamson does not use the last 4
  -- bits, I don't know why. However we keep this
  --HashxD <= RawHashxS(HASH_BIT_LEN+4-1 downto 4);
  BRamAddrxD <= RawHashxS(HASH_BIT_LEN+4-1 downto 4) & ZERO(13-HASH_BIT_LEN downto 0);

  -- reformat signals to adapt buswidth for memory blocks
  BRamWexS   <= EnWrxSI & EnWrxSI & EnWrxSI & EnWrxSI;
  TblInxD    <= ZERO(17 downto entryBitWidth) & NewEntryxDI;
  BRamLDInxD <= x"000000" & TblInxD(7 downto 0);
  BRamHDInxD <= x"000000" & TblInxD(16 downto 9);
  BRamLPInxD <= "000" & TblInxD(8);
  BRamHPInxD <= "000" & TblInxD(17);

  TblOutxD    <= BRamHPOutxD(0) & BRamHDOutxD(7 downto 0) & BRamLPOutxD(0) & BRamLDOutxD(7 downto 0);
  OldEntryxDO <= TblOutxD(entryBitWidth-1 downto 0);


  -- lower byte of hash table. Only port A is used
  hashTableMemLowInst : RAMB16BWER
    generic map (
      -- DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
      DATA_WIDTH_A        => 9,
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
      DOA    => BRamLDOutxD,            -- 8-bit A port data output
      DOPA   => BRamLPOutxD,            -- 1-bit A port parity output
      -- Port B Data: 32-bit (each) Port B data
      DOB    => open,
      DOPB   => open,
      -- Port A Address/Control Signals: 14-bit (each) Port A address and control signals
      ADDRA  => BRamAddrxD,             -- 11-bit A port address input
      CLKA   => ClkxCI,                 -- 1-bit A port clock input
      ENA    => '1',                    -- 1-bit A port enable input
      REGCEA => '1',               -- 1-bit A port register clock enable input
      RSTA   => '0',               -- 1-bit A port register set/reset input
      WEA    => BRamWexS,          -- 4-bit Port A byte-wide write enable input
      -- Port A Data: 32-bit (each) Port A data
      DIA    => BRamLDInxD,             -- 32-bit A port data input
      DIPA   => BRamLPInxD,             -- 4-bit A port parity input
      -- Port B Address/Control Signals: 14-bit (each) Port B address and control signals
      ADDRB  => "00000000000000",       -- 14-bit B port address input
      CLKB   => '0',                    -- 1-bit B port clock input
      ENB    => '0',                    -- 1-bit B port enable input
      REGCEB => '0',               -- 1-bit B port register clock enable input
      RSTB   => '0',               -- 1-bit B port register set/reset input
      WEB    => x"0",              -- 4-bit Port B byte-wide write enable input
      -- Port B Data: 32-bit (each) Port B data
      DIB    => x"00000000",            -- 32-bit B port data input
      DIPB   => x"0"                    -- 4-bit B port parity input
      );

  -- higher byte of hash table. Only port A is used
  hashTableMemHighInst : RAMB16BWER
    generic map (
      -- DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
      DATA_WIDTH_A        => 9,
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
      DOA    => BRamHDOutxD,            -- 8-bit A port data output
      DOPA   => BRamHPOutxD,            -- 1-bit A port parity output
      -- Port B Data: 32-bit (each) Port B data
      DOB    => open,
      DOPB   => open,
      -- Port A Address/Control Signals: 14-bit (each) Port A address and control signals
      ADDRA  => BRamAddrxD,             -- 11-bit A port address input
      CLKA   => ClkxCI,                 -- 1-bit A port clock input
      ENA    => '1',                    -- 1-bit A port enable input
      REGCEA => '1',               -- 1-bit A port register clock enable input
      RSTA   => '0',               -- 1-bit A port register set/reset input
      WEA    => BRamWexS,          -- 4-bit Port A byte-wide write enable input
      -- Port A Data: 32-bit (each) Port A data
      DIA    => BRamHDInxD,             -- 32-bit A port data input
      DIPA   => BRamHPInxD,             -- 4-bit A port parity input
      -- Port B Address/Control Signals: 14-bit (each) Port B address and control signals
      ADDRB  => "00000000000000",       -- 14-bit B port address input
      CLKB   => '0',                    -- 1-bit B port clock input
      ENB    => '0',                    -- 1-bit B port enable input
      REGCEB => '0',               -- 1-bit B port register clock enable input
      RSTB   => '0',               -- 1-bit B port register set/reset input
      WEB    => x"0",              -- 4-bit Port B byte-wide write enable input
      -- Port B Data: 32-bit (each) Port B data
      DIB    => x"00000000",            -- 32-bit B port data input
      DIPB   => x"0"                    -- 4-bit B port parity input
      );


end Behavioral;

