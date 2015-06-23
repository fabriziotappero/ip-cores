-- #########################################################################################################
-- #                        <<< STORM CORE PROCESSOR SYSTEM by Stephan Nolting >>>                         #
-- # ***************************************************************************************************** #
-- #    ~ STORM Core Processor System ~     | Make sure, that all files listed on the left are added to    #
-- #             File Hierarchy             | the project library, of which this file is the top entity.   #
-- # ---------------------------------------+------------------------------------------------------------- #
-- #   STORM_TOP.vhd (this file)            |                                                              #
-- #   + CORE_PKG.vhd (package file)        |  SSSS TTTTT  OOO  RRRR  M   M        CCCC  OOO  RRRR  EEEEE  #
-- #   - BUS_UNIT.vhd                       | S       T   O   O R   R MM MM       C     O   O R   R E      #
-- #   - CACHE.vhd                          |  SSS    T   O   O RRRR  M M M  ###  C     O   O RRRR   EEE   #
-- #   - CORE.vhd                           |     S   T   O   O R  R  M   M       C     O   O R  R  E      #
-- #     - REG_FILE.vhd                     | SSSS    T    OOO  R   R M   M        CCCC  OOO  R   R EEEEE  #
-- #     - OPERANT_UNIT.vhd                 |                                                              #
-- #     - MS_UNIT.vhd                      +------------------------------------------------------------- #
-- #       - MULTIPLY_UNIT.vhd              |                                                              #
-- #       - BARREL_SHIFTER.vhd             | The STORM Core Processor System                              #
-- #     - ALU.vhd                          | ==========================================                   #
-- #     - FLOW_CTRL.vhd                    |  Created by Stephan Nolting (Z3R0_gr4vi7y / zero_gravity)    #
-- #     - WB_UNIT.vhd                      |  Contact: stnolting@googlemail.com                           #
-- #     - MC_SYS.vhd                       |  Published at opencores.org                                  #
-- #     - LOAD_STORE_UNIT.vhd              |  Download at http://opencores.org/project,storm_core         #
-- #     - OPCODE_DECODER.vhd               |                                                              #
-- # ***************************************************************************************************** #
-- # Last modified: 17.03.2012                                                                        =/\= #
-- #########################################################################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity STORM_TOP is
	generic (
-- ###############################################################################################
-- ##       System Architecture Configuration                                                   ##
-- ###############################################################################################

				I_CACHE_PAGES     : natural := 8;  -- number of pages in I cache
				I_CACHE_PAGE_SIZE : natural := 32; -- page size in I cache
				D_CACHE_PAGES     : natural := 8;  -- number of pages in D cache
				D_CACHE_PAGE_SIZE : natural := 32;  -- page size in D cache
				BOOT_VECTOR       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000"; -- boot address
				IO_UC_BEGIN       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000"; -- io begin address
				IO_UC_END         : STD_LOGIC_VECTOR(31 downto 0) := x"00000000"  -- io end address
			);
-- ###############################################################################################
-- ##       Global Interface                                                                    ##
-- ###############################################################################################
	port	(
				CORE_CLK_I    : in  STD_LOGIC; -- core clock input
				RST_I         : in  STD_LOGIC; -- global reset input
				IO_PORT_O     : out STD_LOGIC_VECTOR(15 downto 0); -- direct output
				IO_PORT_I     : in  STD_LOGIC_VECTOR(15 downto 0); -- direct input

-- ###############################################################################################
-- ##       Wishbone Interface                                                                  ##
-- ###############################################################################################

				WB_ADR_O      : out STD_LOGIC_VECTOR(31 downto 0); -- address
				WB_CTI_O      : out STD_LOGIC_VECTOR(02 downto 0); -- cycle type
				WB_TGC_O      : out STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
				WB_SEL_O      : out STD_LOGIC_VECTOR(03 downto 0); -- byte select
				WB_WE_O       : out STD_LOGIC; -- write enable
				WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- data out
				WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- data in
				WB_STB_O      : out STD_LOGIC; -- valid transfer
				WB_CYC_O      : out STD_LOGIC; -- valid cycle
				WB_ACK_I      : in  STD_LOGIC; -- acknowledge
				WB_ERR_I      : in  STD_LOGIC; -- abnormal cycle termination
				WB_HALT_I     : in  STD_LOGIC; -- halt request

-- ###############################################################################################
-- ##       Interrupt Lines                                                                     ##
-- ###############################################################################################

				IRQ_I         : in  STD_LOGIC; -- interrupt request
				FIQ_I         : in  STD_LOGIC  -- fast interrupt request

			);
end STORM_TOP;

architecture Structure of STORM_TOP is

	-- Logarithm duales --
	function log2(temp : natural) return natural is
		variable result : natural;
	begin
		for i in 0 to integer'high loop
			if (2**i >= temp) then
				return i;
			end if;
		end loop;
		return 0;
	end function log2;

	-- Special processor lines --
	signal ST_HALT       : STD_LOGIC;
	signal ST_MODE       : STD_LOGIC_VECTOR(04 downto 0);
	signal C_WTHRU       : STD_LOGIC;
	signal C_BUS_CYCC    : STD_LOGIC_VECTOR(15 downto 0);
	signal ADR_FEEDBACK  : STD_LOGIC_VECTOR(31 downto 0);

	-- STORM D-Cache Interface --
	signal ST_DC_REQ     : STD_LOGIC;
	signal ST_DC_ADR     : STD_LOGIC_VECTOR(31 downto 0);
	signal ST_DC_RD_DTA  : STD_LOGIC_VECTOR(31 downto 0);
	signal ST_DC_WR_DTA  : STD_LOGIC_VECTOR(31 downto 0);
	signal ST_DC_DQ      : STD_LOGIC_VECTOR(01 downto 0);
	signal ST_DC_RW      : STD_LOGIC;
	signal ST_DC_CLEAR   : STD_LOGIC;
	signal ST_DC_FLUSH   : STD_LOGIC;
	signal ST_DC_HIT     : STD_LOGIC;
	signal ST_DC_FRESH   : STD_LOGIC;
	signal ST_DC_CIO     : STD_LOGIC;
	signal ST_DC_SYNC    : STD_LOGIC;
	signal ST_PRTCT_IO   : STD_LOGIC;

	-- Bus Unit D-Cache Interface --
	signal BS_DC_CS      : STD_LOGIC;
	signal BS_DC_P_SEL   : STD_LOGIC_VECTOR(log2(D_CACHE_PAGES)-1 downto 0);
	signal BS_DC_D_SEL   : STD_LOGIC;
	signal BS_DC_A_SEL   : STD_LOGIC_VECTOR(31 downto 0);
	signal BS_DC_ADR     : STD_LOGIC_VECTOR(31 downto 0);
	signal BS_DC_DATA_I  : STD_LOGIC_VECTOR(31 downto 0);
	signal BS_DC_DATA_O  : STD_LOGIC_VECTOR(31 downto 0);
	signal BS_DC_WE      : STD_LOGIC;
	signal BS_DC_DIRTY   : STD_LOGIC;
	signal BS_DC_MISS    : STD_LOGIC;
	signal BS_DC_DRT_ACK : STD_LOGIC;
	signal BS_DC_MSS_ACK : STD_LOGIC;
	signal BS_DC_IO_ACC  : STD_LOGIC;

	-- STORM I-Cache Interface --
	signal ST_IC_REQ     : STD_LOGIC;
	signal ST_IC_ADR     : STD_LOGIC_VECTOR(31 downto 0);
	signal ST_IC_RD_DTA  : STD_LOGIC_VECTOR(31 downto 0);
	signal ST_IC_CLEAR   : STD_LOGIC;
	signal ST_IC_HIT     : STD_LOGIC;
	signal ST_IC_FRESH   : STD_LOGIC;

	-- Bus Unit I-Cache Interface --
	signal BS_IC_CS      : STD_LOGIC;
	signal BS_IC_P_SEL   : STD_LOGIC_VECTOR(log2(I_CACHE_PAGES)-1 downto 0);
	signal BS_IC_ADR     : STD_LOGIC_VECTOR(31 downto 0);
	signal BS_IC_DATA_I  : STD_LOGIC_VECTOR(31 downto 0);
	signal BS_IC_WE      : STD_LOGIC;
	signal BS_IC_MISS    : STD_LOGIC;
	signal BS_IC_MSS_ACK : STD_LOGIC;

	-- Abort Signals --
	signal D_ABORT       : STD_LOGIC;
	signal I_ABORT       : STD_LOGIC;

begin

	-- STORM Core Processor -------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------------
		PROCESSOR_CORE: CORE
		generic map (
						BOOT_VEC        => BOOT_VECTOR   -- Start-up boot vector
					)
		port map (
						-- Global Control --
						RES             => RST_I,        -- global reset input (high active)
						CLK             => CORE_CLK_I,   -- global clock input

						-- Special Control --
						HALT            => ST_HALT,      -- halt processor
						MODE            => ST_MODE,      -- processor mode

						-- Data Cache Interface --
						D_CACHE_REQ     => ST_DC_REQ,    -- memory access in next cycle
						D_CACHE_ADR     => ST_DC_ADR,    -- data address
						D_CACHE_RD_DTA  => ST_DC_RD_DTA, -- read data
						D_CACHE_WR_DTA  => ST_DC_WR_DTA, -- write data
						D_CACHE_DQ      => ST_DC_DQ,     -- data transfer quantity
						D_CACHE_RW      => ST_DC_RW,     -- read/write signal
						D_CACHE_ABORT   => D_ABORT,      -- memory abort request
						D_CACHE_CLEAR   => ST_DC_CLEAR,  -- clear d-cache
						D_CACHE_FLUSH   => ST_DC_FLUSH,  -- flush d-cache
						D_CACHE_MISS    => BS_DC_MISS,   -- d-cache miss
						D_CACHE_HIT     => ST_DC_HIT,    -- d-cache hit
						D_CACHE_FRESH   => ST_DC_FRESH,  -- refresh d-cache
						D_CACHE_CIO     => ST_DC_CIO,    -- en cached IO
						IO_PROTECT_O    => ST_PRTCT_IO,  -- protected IO
						D_CACHE_SYNC    => ST_DC_SYNC,   -- d-cache is sync

						-- Instruction Cache Interface --
						I_CACHE_REQ     => ST_IC_REQ,    -- memory access in next cycle
						I_CACHE_ADR     => ST_IC_ADR,    -- instruction address
						I_CACHE_RD_DTA  => ST_IC_RD_DTA, -- read data
						I_CACHE_ABORT   => I_ABORT,      -- memory abort request
						I_CACHE_CLEAR   => ST_IC_CLEAR,  -- clear i-cache
						I_CACHE_MISS    => BS_IC_MISS,   -- i-cache miss
						I_CACHE_HIT     => ST_IC_HIT,    -- i-cache hit
						I_CACHE_FRESH   => ST_IC_FRESH,  -- refresh i-cache

						-- General Control Lines --
						C_BUS_CYCC_O    => C_BUS_CYCC,   -- max bus cycle length
						C_WTHRU_O       => C_WTHRU,      -- cache write through
						IO_PORT_OUT     => IO_PORT_O,    -- direct output
						IO_PORT_IN      => IO_PORT_I,    -- direct input
						ADR_FEEDBACK_I  => ADR_FEEDBACK, -- address feedback for exceptions

						-- Interrupt Request Lines --
						IRQ             => IRQ_I,        -- interrupt request
						FIQ             => FIQ_I         -- fast interrupt request
				);



	-- STORM Instruction Cache ----------------------------------------------------------------
	-- -------------------------------------------------------------------------------------------
		I_CACHE_INST: CACHE
		generic map (
						CACHE_PAGES      => I_CACHE_PAGES,
						LOG2_CACHE_PAGES => log2(I_CACHE_PAGES),
						PAGE_SIZE        => I_CACHE_PAGE_SIZE,
						LOG2_PAGE_SIZE   => log2(I_CACHE_PAGE_SIZE)
					)
		port map (
						-- Global Control --
						CORE_CLK_I  => CORE_CLK_I,    -- core clock, all triggering on rising edge
						RST_I       => RST_I,         -- global reset, high active, sync
						HALT_I      => ST_HALT,       -- halt cache

						-- Processor Access --
						P_CS_I      => ST_IC_REQ,     -- processor request
						B_P_SEL_I   => BS_IC_P_SEL,   -- bus unit page select
						B_D_SEL_O   => open,          -- selected dirty bit
						B_A_SEL_O   => open,          -- selected base adr
						P_ADR_I     => ST_IC_ADR,     -- address input
						P_DATA_I    => x"00000000",   -- data input
						P_DATA_O    => ST_IC_RD_DTA,  -- data output
						P_DQ_I      => DQ_WORD,       -- data quantity, allways word
						P_WE_I      => '0',           -- read only

						-- Bus Unit Access --
						B_CS_I      => BS_IC_CS,      -- bus unit request
						B_ADR_I     => BS_IC_ADR,     -- address input
						B_DATA_I    => BS_IC_DATA_I,  -- data input
						B_DATA_O    => open,          -- data output
						B_WE_I      => BS_IC_WE,      -- write enable
						B_DRT_ACK_I => '1',           -- dirty acknowledged
						B_MSS_ACK_I => BS_IC_MSS_ACK, -- miss acknowledged
						B_IO_ACC_I  => '0',           -- IO access

						-- Cache Control -- 
						C_FRESH_I   => ST_IC_FRESH,   -- refresh accessed page
						C_FLUSH_I   => '0',           -- flush cache
						C_CLEAR_I   => ST_IC_CLEAR,   -- clear cache
						C_MISS_O    => BS_IC_MISS,    -- cache miss access
						C_HIT_O     => ST_IC_HIT,     -- cache hit access
						C_DIRTY_O   => open,          -- cache modified
						C_WTHRU_I   => '0',           -- write through
						C_SYNC_O    => open           -- cache is sync
				);

			-- selector dummy --
			BS_IC_P_SEL <= (others => '0');



	-- STORM Data Cache -----------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------------
		D_CACHE_INST: CACHE
		generic map (
						CACHE_PAGES      => D_CACHE_PAGES,
						LOG2_CACHE_PAGES => log2(D_CACHE_PAGES),
						PAGE_SIZE        => D_CACHE_PAGE_SIZE,
						LOG2_PAGE_SIZE   => log2(D_CACHE_PAGE_SIZE)
					)
		port map (
						-- Global Control --
						CORE_CLK_I  => CORE_CLK_I,    -- core clock, all triggering on rising edge
						RST_I       => RST_I,         -- global reset, high active, sync
						HALT_I      => ST_HALT,       -- halt cache

						-- Processor Access --
						P_CS_I      => ST_DC_REQ,     -- processor request
						P_ADR_I     => ST_DC_ADR,     -- address input
						P_DATA_I    => ST_DC_WR_DTA,  -- data input
						P_DATA_O    => ST_DC_RD_DTA,  -- data output
						P_DQ_I      => ST_DC_DQ,      -- data quantity, allways word
						P_WE_I      => ST_DC_RW,      -- read only

						-- Bus Unit Access --
						B_CS_I      => BS_DC_CS,      -- bus unit request
						B_P_SEL_I   => BS_DC_P_SEL,   -- bus unit page select
						B_D_SEL_O   => BS_DC_D_SEL,   -- selected dirty bit
						B_A_SEL_O   => BS_DC_A_SEL,   -- selected base adr
						B_ADR_I     => BS_DC_ADR,     -- address input
						B_DATA_I    => BS_DC_DATA_I,  -- data input
						B_DATA_O    => BS_DC_DATA_O,  -- data output
						B_WE_I      => BS_DC_WE,      -- write enable
						B_DRT_ACK_I => BS_DC_DRT_ACK, -- dirty acknowledged
						B_MSS_ACK_I => BS_DC_MSS_ACK, -- miss acknowledged
						B_IO_ACC_I  => BS_DC_IO_ACC,  -- IO access

						-- Cache Control -- 
						C_FRESH_I   => ST_DC_FRESH,   -- refresh accessed page
						C_FLUSH_I   => ST_DC_FLUSH,   -- flush cache
						C_CLEAR_I   => ST_DC_CLEAR,   -- clear cache
						C_MISS_O    => BS_DC_MISS,    -- cache miss access
						C_HIT_O     => ST_DC_HIT,     -- cache hit access
						C_DIRTY_O   => BS_DC_DIRTY,   -- cache modified
						C_WTHRU_I   => C_WTHRU,       -- write through
						C_SYNC_O    => ST_DC_SYNC     -- cache is sync
				);
				


	-- STORM <-> Wishbone Bus Unit ------------------------------------------------------------
	-- -------------------------------------------------------------------------------------------
		BUS_UNIT_INST: BUS_UNIT
		generic map (
						-- Cache Configuration --
						I_CACHE_PAGES            => I_CACHE_PAGES,           -- number of pages in I cache
						LOG2_I_CACHE_PAGES       => log2(I_CACHE_PAGES),     -- log2 of page count
						I_CACHE_PAGE_SIZE        => I_CACHE_PAGE_SIZE,       -- page size in I cache
						LOG2_I_CACHE_PAGE_SIZE   => log2(I_CACHE_PAGE_SIZE), -- log2 of page size
						D_CACHE_PAGES            => D_CACHE_PAGES,           -- number of pages in D cache
						LOG2_D_CACHE_PAGES       => log2(D_CACHE_PAGES),     -- log2 of page count
						D_CACHE_PAGE_SIZE        => D_CACHE_PAGE_SIZE,       -- page size in D cache
						LOG2_D_CACHE_PAGE_SIZE   => log2(D_CACHE_PAGE_SIZE), -- log2 of page size
						IO_UC_BEGIN              => IO_UC_BEGIN,             -- begin of uncachable IO area
						IO_UC_END                => IO_UC_END                -- end of uncachable IO area
					)
		port map (
						-- Global Control --
						CORE_CLK_I          => CORE_CLK_I,    -- core clock signal, rising edge
						RST_I               => RST_I,         -- reset signal, sync, active high
						FREEZE_STORM_O      => ST_HALT,       -- freeze processor
						STORM_MODE_I        => ST_MODE,       -- current processor mode
						D_ABORT_O           => D_ABORT,       -- bus error during data transfer
						I_ABORT_O           => I_ABORT,       -- bus error during instruction transfer
						C_BUS_CYCC_I        => C_BUS_CYCC,    -- max bus cycle length
						CACHED_IO_I         => ST_DC_CIO,     -- enable cached IO
						PROTECTED_IO_I      => ST_PRTCT_IO,   -- protected IO
						ADR_FEEDBACK_O      => ADR_FEEDBACK,  -- address feedback for exception handling

						-- Data Cache Interface --
						DC_CS_O             => BS_DC_CS,      -- chip select
						DC_P_ADR_I          => ST_DC_ADR,     -- processor address
						DC_P_SEL_O          => BS_DC_P_SEL,   -- page select
						DC_D_SEL_I          => BS_DC_D_SEL,   -- dirty bit of selected page
						DC_A_SEL_I          => BS_DC_A_SEL,   -- base adr of sel page
						DC_P_CS_I           => ST_DC_REQ,     -- processor cache request
						DC_P_WE_I           => ST_DC_RW,      -- processor write enable
						DC_ADR_O            => BS_DC_ADR,     -- cache address
						DC_DATA_O           => BS_DC_DATA_I,  -- data outut
						DC_DATA_I           => BS_DC_DATA_O,  -- data input
						DC_WE_O             => BS_DC_WE,      -- write enable
						DC_MISS_I           => BS_DC_MISS,    -- cache miss access
						DC_DIRTY_I          => BS_DC_DIRTY,   -- cache modified
						DC_DRT_ACK_O        => BS_DC_DRT_ACK, -- dirty acknowledged
						DC_MSS_ACK_O        => BS_DC_MSS_ACK, -- miss acknowledged
						DC_IO_ACC_O         => BS_DC_IO_ACC,  -- IO access

						-- Instruction Cache Interface --
						IC_CS_O             => BS_IC_CS,      -- chip select
						IC_P_ADR_I          => ST_IC_ADR,     -- processor address
						IC_P_CS_I           => ST_IC_REQ,     -- processor cache request
						IC_ADR_O            => BS_IC_ADR,     -- cache address
						IC_DATA_O           => BS_IC_DATA_I,  -- data output
						IC_WE_O             => BS_IC_WE,      -- write enable
						IC_MISS_I           => BS_IC_MISS,    -- cache miss access
						IC_MSS_ACK_O        => BS_IC_MSS_ACK, -- miss acknowledged

						-- Wishbone Bus --
						WB_ADR_O            => WB_ADR_O,      -- address
						WB_CTI_O            => WB_CTI_O,      -- cycle type
						WB_DATA_O           => WB_DATA_O,     -- data
						WB_SEL_O            => WB_SEL_O,      -- byte select
						WB_TGC_O            => WB_TGC_O,      -- cycle tag
						WB_WE_O             => WB_WE_O,       -- read/write
						WB_CYC_O            => WB_CYC_O,      -- cycle
						WB_STB_O            => WB_STB_O,      -- strobe
						WB_DATA_I           => WB_DATA_I,     -- data
						WB_ACK_I            => WB_ACK_I,      -- acknowledge
						WB_ERR_I            => WB_ERR_I,      -- abnormal termination
						WB_HALT_I           => WB_HALT_I      -- halt
				);



end Structure;