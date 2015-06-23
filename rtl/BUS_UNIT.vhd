-- ######################################################
-- #      < STORM CORE SYSTEM by Stephan Nolting >      #
-- # ************************************************** #
-- #             STORM PROCESSOR BUS UNIT               #
-- # -------------------------------------------------- #
-- # This bus unit connects the data and instruction    #
-- # cache of the STORM Core processor to a pipelined   #
-- # Wishbone compatible 32-bit bus system.             #
-- # ************************************************** #
-- # Last modified: 05.05.2012                          #
-- ######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity BUS_UNIT is
	generic (
-- ################################################################################################################
-- ##       Cache Configuration                                                                                  ##
-- ################################################################################################################

				I_CACHE_PAGES           : natural;                       -- number of pages in I cache
				LOG2_I_CACHE_PAGES      : natural;                       -- log2 of page count
				I_CACHE_PAGE_SIZE       : natural;                       -- page size in I cache
				LOG2_I_CACHE_PAGE_SIZE  : natural;                       -- log2 of page size
				D_CACHE_PAGES           : natural;                       -- number of pages in D cache
				LOG2_D_CACHE_PAGES      : natural;                       -- log2 of page count
				D_CACHE_PAGE_SIZE       : natural;                       -- page size in D cache
				LOG2_D_CACHE_PAGE_SIZE  : natural;                       -- log2 of page size
				IO_UC_BEGIN             : STD_LOGIC_VECTOR(31 downto 0); -- begin of uncachable IO area
				IO_UC_END               : STD_LOGIC_VECTOR(31 downto 0)  -- end of uncachable IO area
			);
	port    (
-- ################################################################################################################
-- ##       Global Control                                                                                       ##
-- ################################################################################################################

				CORE_CLK_I         : in  STD_LOGIC;                     -- core clock signal, rising edge
				RST_I              : in  STD_LOGIC;                     -- reset signal, sync, active high
				FREEZE_STORM_O     : out STD_LOGIC;                     -- freeze processor
				STORM_MODE_I       : in  STD_LOGIC_VECTOR(04 downto 0); -- current processor mode
				D_ABORT_O          : out STD_LOGIC;                     -- bus error during data transfer
				I_ABORT_O          : out STD_LOGIC;                     -- bus error during instruction transfer
				C_BUS_CYCC_I       : in  STD_LOGIC_VECTOR(15 downto 0); -- max bus cycle length
				CACHED_IO_I        : in  STD_LOGIC;                     -- enable cached IO
				PROTECTED_IO_I     : in  STD_LOGIC;                     -- protected IO
				ADR_FEEDBACK_O     : out STD_LOGIC_VECTOR(31 downto 0); -- address feedback for exception handling

-- ################################################################################################################
-- ##       STORM Data Cache Interface                                                                           ##
-- ################################################################################################################

				DC_CS_O            : out STD_LOGIC;                     -- chip select
				DC_P_ADR_I         : in  STD_LOGIC_VECTOR(31 downto 0); -- processor address
				DC_P_SEL_O         : out STD_LOGIC_VECTOR(LOG2_D_CACHE_PAGES-1 downto 0); -- page select
				DC_D_SEL_I         : in  STD_LOGIC;                     -- dirty bit of selected page
				DC_A_SEL_I         : in  STD_LOGIC_VECTOR(31 downto 0); -- base adr of sel page
				DC_P_CS_I          : in  STD_LOGIC;                     -- processor cache request
				DC_P_WE_I          : in  STD_LOGIC;                     -- processor write enable
				DC_ADR_O           : out STD_LOGIC_VECTOR(31 downto 0); -- cache address
				DC_DATA_O          : out STD_LOGIC_VECTOR(31 downto 0); -- data output
				DC_DATA_I          : in  STD_LOGIC_VECTOR(31 downto 0); -- data input
				DC_WE_O            : out STD_LOGIC;                     -- write enable
				DC_MISS_I          : in  STD_LOGIC;                     -- cache miss access
				DC_DIRTY_I         : in  STD_LOGIC;                     -- cache modified
				DC_DRT_ACK_O       : out STD_LOGIC;                     -- dirty acknowledged
				DC_MSS_ACK_O       : out STD_LOGIC;                     -- miss acknowledged
				DC_IO_ACC_O        : out STD_LOGIC;                     -- IO access

-- ################################################################################################################
-- ##       STORM Instruction Cache Interface                                                                    ##
-- ################################################################################################################

				IC_CS_O            : out STD_LOGIC;                     -- chip select
				IC_P_ADR_I         : in  STD_LOGIC_VECTOR(31 downto 0); -- processor address
				IC_P_CS_I          : in  STD_LOGIC;                     -- processor cache request
				IC_ADR_O           : out STD_LOGIC_VECTOR(31 downto 0); -- cache address
				IC_DATA_O          : out STD_LOGIC_VECTOR(31 downto 0); -- data outut
				IC_WE_O            : out STD_LOGIC;                     -- write enable
				IC_MISS_I          : in  STD_LOGIC;                     -- cache miss access
				IC_MSS_ACK_O       : out STD_LOGIC;                     -- miss acknowledged

-- ################################################################################################################
-- ##       Wishbone Bus                                                                                         ##
-- ################################################################################################################

				WB_ADR_O           : out STD_LOGIC_VECTOR(31 downto 0); -- address
				WB_CTI_O           : out STD_LOGIC_VECTOR(02 downto 0); -- cycle type
				WB_DATA_O          : out STD_LOGIC_VECTOR(31 downto 0); -- data
				WB_SEL_O           : out STD_LOGIC_VECTOR(03 downto 0); -- byte select
				WB_TGC_O           : out STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
				WB_WE_O            : out STD_LOGIC;                     -- read/write
				WB_CYC_O           : out STD_LOGIC;                     -- cycle
				WB_STB_O           : out STD_LOGIC;                     -- strobe
				WB_DATA_I          : in  STD_LOGIC_VECTOR(31 downto 0); -- data
				WB_ACK_I           : in  STD_LOGIC;                     -- acknowledge
				WB_ERR_I           : in  STD_LOGIC;                     -- abnormal termination
				WB_HALT_I          : in  STD_LOGIC                      -- halt
            );
end BUS_UNIT;

architecture Structure of BUS_UNIT is

	-- Architecture Constants --
	constant WB_PIPE_EN     : boolean := FALSE;

	-- Arbiter FSM --
	type   ARB_STATE_TYPE is (IDLE, ASSIGN_D_PAGE, UPLOAD_D_PAGE, IO_REQUEST, DOWNLOAD_I_PAGE, DOWNLOAD_D_PAGE, END_TRANSFER);
	signal ARB_STATE,   ARB_STATE_NXT   : ARB_STATE_TYPE;

	-- Address Buffer --
	signal IC_ADR_BUF,   IC_ADR_BUF_NXT  : STD_LOGIC_VECTOR(31 downto 0);
	signal DC_ADR_BUF,   DC_ADR_BUF_NXT  : STD_LOGIC_VECTOR(31 downto 0);
	signal WB_ADR_BUF,   WB_ADR_BUF_NXT  : STD_LOGIC_VECTOR(31 downto 0);
	signal DC_P_ADR_BUF, IC_P_ADR_BUF    : STD_LOGIC_VECTOR(31 downto 0);
	signal BASE_BUF,     BASE_BUF_NXT    : STD_LOGIC_VECTOR(31 downto 0);
	signal PAGE_BUF,     PAGE_BUF_NXT    : STD_LOGIC_VECTOR(LOG2_D_CACHE_PAGES-1 downto 0);

	-- Wishbone Syncs --
	signal WB_DATA_BUF                   : STD_LOGIC_VECTOR(31 downto 0);
	signal WB_ACK_BUF                    : STD_LOGIC;
	signal WB_ERR_BUF                    : STD_LOGIC;
	signal WB_DATA_FF,   WB_DATA_FF_NXT  : STD_LOGIC_VECTOR(31 downto 0);
	signal WB_CTI_O_NXT                  : STD_LOGIC_VECTOR(02 downto 0);
	signal WB_TGC_O_NXT                  : STD_LOGIC_VECTOR(06 downto 0);
	signal WB_STB_O_NXT                  : STD_LOGIC;
	signal WB_CYC_O_NXT                  : STD_LOGIC;
	signal WB_WE_O_NXT                   : STD_LOGIC;

	-- Access System --
	signal IO_ACCESS                     : STD_LOGIC;

	-- Local Signals --
	signal FREEZE_FLAG,  FREEZE_FLAG_NXT : STD_LOGIC; -- freeze flag
	signal FREEZE_DIS,   FREEZE_DIS_NXT  : STD_LOGIC; -- freeze disable
	signal BIT_BUF,      BIT_BUF_NXT     : STD_LOGIC; -- GP bit buffer
	signal WORD_BUF,     WORD_BUF_NXT    : STD_LOGIC_VECTOR(31 downto 0); -- GP word buffer

	-- Timeout System --
	signal TIMEOUT_CNT,  TIMEOUT_CNT_NXT : STD_LOGIC_VECTOR(15 downto 0);
	signal WB_ACK_CNT,   WB_ACK_CNT_NXT  : STD_LOGIC_VECTOR(15 downto 0);

begin

	-- STORM Freezer ------------------------------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------------------------------
		FRIDGE: process(CORE_CLK_I)
		begin
			if rising_edge(CORE_CLK_I) then
				if (RST_I = '1') then
					FREEZE_FLAG <= '0';
					FREEZE_DIS  <= '0';
				else
					FREEZE_FLAG <= FREEZE_FLAG_NXT;
					FREEZE_DIS  <= FREEZE_DIS_NXT;
				end if;
			end if;
		end process FRIDGE;

		--- Immediate HALT ---
		FREEZE_STORM_O  <= (DC_DIRTY_I or IC_MISS_I or DC_MISS_I or FREEZE_FLAG) and (not FREEZE_DIS);



	-- Static Interface ---------------------------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------------------------------
		--- D-Cache ---
		DC_DATA_O   <= WB_DATA_BUF;
		DC_ADR_O    <= DC_ADR_BUF;
		DC_P_SEL_O  <= PAGE_BUF;

		--- I-Cache ---
		IC_DATA_O   <= WB_DATA_BUF;
		IC_ADR_O    <= IC_ADR_BUF;
		IC_WE_O     <= '1'; -- storm cannot change i-cache, no readback necessary

		--- Wishbone Bus ---
		WB_SEL_O       <= "1111"; -- cache entry = 32-bit word
		WB_DATA_FF_NXT <= x"00000000"    when (ARB_STATE = IDLE) else DC_DATA_I; -- reduce switching losses...
		WB_DATA_O      <= WB_DATA_FF_NXT when (ARB_STATE = UPLOAD_D_PAGE) else WB_DATA_FF;

		--- IO Access ---
		IO_ACCESS <= '1' when (DC_P_ADR_I >= IO_UC_BEGIN) and (DC_P_ADR_I <= IO_UC_END) and (CACHED_IO_I = '0') else '0';
		DC_IO_ACC_O <= IO_ACCESS;

		--- Core Feedback ---
		ADR_FEEDBACK_O <= WB_ADR_BUF;



	-- Arbiter State Machine (Sync) ---------------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------------------------------
		ARBITER_SYNC: process(CORE_CLK_I)
		begin
			if rising_edge(CORE_CLK_I) then
				if (RST_I = '1') then
					ARB_STATE    <= IDLE;
					TIMEOUT_CNT  <= (others => '0');
					WB_DATA_BUF  <= (others => '0');
					WB_ACK_BUF   <= '0';
					WB_ACK_CNT   <= (others => '0');
					WB_ERR_BUF   <= '0';
					IC_ADR_BUF   <= (others => '0');
					DC_ADR_BUF   <= (others => '0');
					PAGE_BUF     <= (others => '0');
					WB_ADR_BUF   <= (others => '0');
					BASE_BUF     <= (others => '0');
					DC_P_ADR_BUF <= (others => '0');
					IC_P_ADR_BUF <= (others => '0');
					WB_DATA_FF   <= (others => '0');
					WB_ADR_O     <= (others => '0');
					WB_CTI_O     <= (others => '0');
					WB_TGC_O     <= (others => '0');
					WB_STB_O     <= '0';
					WB_CYC_O     <= '0';
					WB_WE_O      <= '0';
					BIT_BUF      <= '0';
					WORD_BUF     <= (others => '0');
				else
					-- Arbiter CTRL --
					ARB_STATE    <= ARB_STATE_NXT;
					BIT_BUF      <= BIT_BUF_NXT;
					WORD_BUF     <= WORD_BUF_NXT;
					TIMEOUT_CNT  <= TIMEOUT_CNT_NXT;
					DC_P_ADR_BUF <= DC_P_ADR_I;
					IC_P_ADR_BUF <= IC_P_ADR_I;
					if (WB_HALT_I = '0') then
						WB_DATA_FF   <= WB_DATA_FF_NXT;
						WB_ADR_O     <= WB_ADR_BUF;
						WB_CTI_O     <= WB_CTI_O_NXT;
						WB_TGC_O     <= WB_TGC_O_NXT;
						WB_STB_O     <= WB_STB_O_NXT;
						WB_CYC_O     <= WB_CYC_O_NXT;
						WB_WE_O      <= WB_WE_O_NXT;
					-- Bus interface --
					--if (WB_HALT_I = '0') then
						-- Wishbone Sync --
						WB_DATA_BUF <= WB_DATA_I;
						WB_ACK_BUF  <= WB_ACK_I;
						WB_ACK_CNT  <= WB_ACK_CNT_NXT;
						WB_ERR_BUF  <= WB_ERR_I;
						-- Address Buffer --
						IC_ADR_BUF  <= IC_ADR_BUF_NXT;
						DC_ADR_BUF  <= DC_ADR_BUF_NXT;
						PAGE_BUF    <= PAGE_BUF_NXT;
						WB_ADR_BUF  <= WB_ADR_BUF_NXT;
						BASE_BUF    <= BASE_BUF_NXT;
					end if;
				end if;
			end if;
		end process ARBITER_SYNC;



	-- Arbiter State Machine (Async) --------------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------------------------------
		ARBITER_ASYNC: process(ARB_STATE,  STORM_MODE_I, FREEZE_FLAG, BASE_BUF,   TIMEOUT_CNT, IO_ACCESS,  BIT_BUF,    WORD_BUF,  PROTECTED_IO_I,
		                       DC_ADR_BUF, DC_P_ADR_BUF, DC_P_ADR_I,  PAGE_BUF,   DC_D_SEL_I,  DC_A_SEL_I, DC_DIRTY_I, DC_MISS_I, DC_P_WE_I,      DC_P_CS_I,
		                       IC_ADR_BUF, IC_P_ADR_BUF, IC_MISS_I,
		                       WB_ADR_BUF, WB_ACK_BUF,   WB_ACK_I,    WB_ACK_CNT, WB_ERR_BUF,  C_BUS_CYCC_I)
			variable IF_BASE_ADR_V, DF_BASE_ADR_V : STD_LOGIC_VECTOR(31 downto 0);
		begin
			--- Base Address Alignment ---
			IF_BASE_ADR_V := (others => '0');
			IF_BASE_ADR_V(31 downto LOG2_I_CACHE_PAGE_SIZE+2) := IC_P_ADR_BUF(31 downto LOG2_I_CACHE_PAGE_SIZE+2);
			DF_BASE_ADR_V := (others => '0');
			DF_BASE_ADR_V(31 downto LOG2_D_CACHE_PAGE_SIZE+2) := DC_P_ADR_BUF(31 downto LOG2_D_CACHE_PAGE_SIZE+2);

			--- Arbiter Defaults ---
			ARB_STATE_NXT   <= ARB_STATE;
			TIMEOUT_CNT_NXT <= TIMEOUT_CNT;
			DC_ADR_BUF_NXT  <= DC_ADR_BUF;
			IC_ADR_BUF_NXT  <= IC_ADR_BUF;
			PAGE_BUF_NXT    <= PAGE_BUF;
			WB_ACK_CNT_NXT  <= WB_ACK_CNT;
			WB_ADR_BUF_NXT  <= WB_ADR_BUF;
			FREEZE_FLAG_NXT <= FREEZE_FLAG;
			FREEZE_DIS_NXT  <= '0';
			BASE_BUF_NXT    <= BASE_BUF;
			BIT_BUF_NXT     <= BIT_BUF;
			WORD_BUF_NXT    <= WORD_BUF;
			TIMEOUT_CNT_NXT <= (others => '0');

			--- Wishbone Bus Defaults ---
			WB_CTI_O_NXT    <= WB_CLASSIC_CYC;
			WB_TGC_O_NXT    <= "00" & STORM_MODE_I;
			WB_CYC_O_NXT    <= '0';
			WB_STB_O_NXT    <= '0';
			WB_WE_O_NXT     <= '0';

			--- Wishbone ACK Counter ---
			if (WB_ACK_I = '1') then
				WB_ACK_CNT_NXT <= Std_Logic_Vector(unsigned(WB_ACK_CNT) + 1);
			end if;

			--- D-Cache Interface Defaults ---
			DC_CS_O         <= '0';
			DC_WE_O         <= '0';
			D_ABORT_O       <= '0';
			DC_DRT_ACK_O    <= '0';   
			DC_MSS_ACK_O    <= '0';
                           
			--- I-Cache Interface Defaults ---
			IC_CS_O         <= '0';
		    I_ABORT_O       <= '0';
			IC_MSS_ACK_O    <= '0';

			--- State Machine ---
			case (ARB_STATE) is

				when IDLE => -- waiting for requests
				-------------------------------------------------------------------------------
					IC_ADR_BUF_NXT <= IF_BASE_ADR_V;
					DC_ADR_BUF_NXT <= DF_BASE_ADR_V;
					WB_ACK_CNT_NXT <= (others => '0');
					PAGE_BUF_NXT   <= (others => '1'); -- last entry
					if (IC_MISS_I = '1') then -- i-cache miss -> reload cache page
						ARB_STATE_NXT   <= DOWNLOAD_I_PAGE;
						FREEZE_FLAG_NXT <= '1';
						WB_ADR_BUF_NXT  <= IF_BASE_ADR_V;
						BASE_BUF_NXT    <= IF_BASE_ADR_V;
					elsif (DC_MISS_I = '1') then  -- d-cache miss -> reload cache page
						ARB_STATE_NXT   <= DOWNLOAD_D_PAGE;
						FREEZE_FLAG_NXT <= '1';
						WB_ADR_BUF_NXT  <= DF_BASE_ADR_V;
						BASE_BUF_NXT    <= DF_BASE_ADR_V;
					elsif (IO_ACCESS = '1') and (DC_P_CS_I = '1') then -- IO access
						if (STORM_MODE_I = User32_MODE) and (PROTECTED_IO_I = '1') then -- unauthorized?
							D_ABORT_O <= '1'; -- abort interrupt
						else
							ARB_STATE_NXT   <= IO_REQUEST;
							FREEZE_FLAG_NXT <= '1';
							WB_ADR_BUF_NXT  <= DC_P_ADR_I;
							BIT_BUF_NXT     <= DC_P_WE_I; -- bus read/write
						end if;
					elsif (DC_DIRTY_I = '1') then -- d-cache modification -> copy page to main memory
						ARB_STATE_NXT   <= ASSIGN_D_PAGE;
						FREEZE_FLAG_NXT <= '1';
					end if;

				when DOWNLOAD_I_PAGE => -- get new i-cache page
				-------------------------------------------------------------------------------
					WB_TGC_O_NXT(5) <= '1'; -- indicate instruction transfer
					WB_TGC_O_NXT(6) <= '0'; -- mem access
					WB_CTI_O_NXT    <= WB_INC_BST_CYC;
					WB_CYC_O_NXT    <= '1'; -- valid cycle
					WB_STB_O_NXT    <= '1'; -- valid transfer
					WB_WE_O_NXT     <= '0'; -- bus read
					TIMEOUT_CNT_NXT <= Std_Logic_Vector(unsigned(TIMEOUT_CNT) + 1);
					if (IC_ADR_BUF >= Std_Logic_Vector(unsigned(BASE_BUF) + (I_CACHE_PAGE_SIZE-1)*4)) and
					   (to_integer(unsigned(WB_ACK_CNT)) >= I_CACHE_PAGE_SIZE) then
						WB_CTI_O_NXT    <= WB_BST_END_CYC;
						ARB_STATE_NXT   <= END_TRANSFER;
						IC_MSS_ACK_O    <= '1'; -- ack miss!
						WB_CYC_O_NXT    <= '0'; -- terminate cycle
						WB_STB_O_NXT    <= '0'; -- terminate cycle
					elsif (WB_ADR_BUF < Std_Logic_Vector(unsigned(BASE_BUF) + (I_CACHE_PAGE_SIZE-1)*4)) then
						WB_ADR_BUF_NXT <= Std_Logic_Vector(unsigned(WB_ADR_BUF) + 4); -- inc counter
					end if;
					if (IC_ADR_BUF < Std_Logic_Vector(unsigned(BASE_BUF) + I_CACHE_PAGE_SIZE*4)) and
					   (WB_ACK_BUF = '1') then
						IC_CS_O <= '1';
						IC_ADR_BUF_NXT <= Std_Logic_Vector(unsigned(IC_ADR_BUF) + 4); -- inc counter
					end if;
					-- Timeout or abnormal cycle termination --
					if (TIMEOUT_CNT > C_BUS_CYCC_I) or (WB_ERR_BUF = '1') then
						WB_CTI_O_NXT    <= WB_BST_END_CYC;
						ARB_STATE_NXT   <= END_TRANSFER;
						IC_MSS_ACK_O    <= '1'; -- ack miss!
						I_ABORT_O       <= '1'; -- abort interrupt
						FREEZE_DIS_NXT  <= '1';
						WB_CYC_O_NXT    <= '0'; -- terminate cycle
						WB_STB_O_NXT    <= '0'; -- terminate cycle
					end if;

				when DOWNLOAD_D_PAGE => -- get new d-cache page
				-------------------------------------------------------------------------------
					WB_TGC_O_NXT(5) <= '0'; -- indicate data transfer
					WB_TGC_O_NXT(6) <= '0'; -- mem access
					WB_CTI_O_NXT    <= WB_INC_BST_CYC;
					WB_CYC_O_NXT    <= '1'; -- valid cycle
					WB_STB_O_NXT    <= '1'; -- valid transfer
					DC_WE_O         <= '1'; -- cache write access
					WB_WE_O_NXT     <= '0'; -- bus read
					TIMEOUT_CNT_NXT <= Std_Logic_Vector(unsigned(TIMEOUT_CNT) + 1);
					if (DC_ADR_BUF >= Std_Logic_Vector(unsigned(BASE_BUF) + (D_CACHE_PAGE_SIZE-1)*4)) and
					   (to_integer(unsigned(WB_ACK_CNT)) >= D_CACHE_PAGE_SIZE) then
						WB_CTI_O_NXT    <= WB_BST_END_CYC;
						ARB_STATE_NXT   <= END_TRANSFER;
						DC_MSS_ACK_O    <= '1'; -- ack miss!
						WB_CYC_O_NXT    <= '0'; -- terminate cycle
						WB_STB_O_NXT    <= '0'; -- terminate cycle
					elsif (WB_ADR_BUF < Std_Logic_Vector(unsigned(BASE_BUF) + (D_CACHE_PAGE_SIZE-1)*4)) then
						WB_ADR_BUF_NXT <= Std_Logic_Vector(unsigned(WB_ADR_BUF) + 4); -- inc counter
					end if;
					if (DC_ADR_BUF < Std_Logic_Vector(unsigned(BASE_BUF) + D_CACHE_PAGE_SIZE*4)) and
					   (WB_ACK_BUF = '1') then
						DC_CS_O <= '1';
						DC_ADR_BUF_NXT <= Std_Logic_Vector(unsigned(DC_ADR_BUF) + 4); -- inc counter
					end if;
					-- Timeout or abnormal cycle termination --
					if (TIMEOUT_CNT > C_BUS_CYCC_I) or (WB_ERR_BUF = '1') then
						WB_CTI_O_NXT    <= WB_BST_END_CYC;
						ARB_STATE_NXT   <= END_TRANSFER;
						DC_MSS_ACK_O    <= '1'; -- ack miss!
						D_ABORT_O       <= '1'; -- abort interrupt
						WB_CYC_O_NXT    <= '0'; -- terminate cycle
						WB_STB_O_NXT    <= '0'; -- terminate cycle
					end if;

				when IO_REQUEST => -- read/write IO location (single 32-bit word)
				-------------------------------------------------------------------------------
					WB_TGC_O_NXT(5) <= '0'; -- indicate data transfer
					WB_TGC_O_NXT(6) <= '1'; -- io access
					WB_CTI_O_NXT    <= WB_CLASSIC_CYC;
					WB_CYC_O_NXT    <= '1'; -- valid cycle
					WB_STB_O_NXT    <= '1'; -- valid transfer
					WB_WE_O_NXT     <= BIT_BUF; -- bus read/write
					DC_WE_O         <= '1'; -- dummy cache write access
					DC_ADR_BUF_NXT  <= WB_ADR_BUF;
					TIMEOUT_CNT_NXT <= Std_Logic_Vector(unsigned(TIMEOUT_CNT) + 1);	
					if (to_integer(unsigned(WB_ACK_CNT)) >= 1) then
						WB_CTI_O_NXT    <= WB_CLASSIC_CYC;
						ARB_STATE_NXT   <= END_TRANSFER;
						DC_DRT_ACK_O    <= '1'; -- ack of pseudo dirty signal
						DC_MSS_ACK_O    <= '1'; -- ack of pseudo miss signal
						WB_CYC_O_NXT    <= '0'; -- terminate cycle
						WB_STB_O_NXT    <= '0'; -- terminate cycle
					end if;
					-- Timeout or abnormal cycle termination --
					if (TIMEOUT_CNT > C_BUS_CYCC_I) or (WB_ERR_BUF = '1') then
						WB_CTI_O_NXT   <= WB_CLASSIC_CYC;
						ARB_STATE_NXT  <= END_TRANSFER;
						DC_DRT_ACK_O   <= '1'; -- ack of pseudo dirty signal
						DC_MSS_ACK_O   <= '1'; -- ack of pseudo miss signal
						D_ABORT_O      <= '1'; -- abort interrupt
						FREEZE_DIS_NXT <= '1';
						WB_CYC_O_NXT   <= '0'; -- terminate cycle
						WB_STB_O_NXT   <= '0'; -- terminate cycle
					end if;

				when ASSIGN_D_PAGE => -- find dirty pages in cache
				-------------------------------------------------------------------------------
					if (DC_D_SEL_I = '1') then -- entry is dirty
						DC_ADR_BUF_NXT <= DC_A_SEL_I;
						WB_ADR_BUF_NXT <= DC_A_SEL_I;
						WORD_BUF_NXT   <= DC_A_SEL_I;
						BASE_BUF_NXT   <= DC_A_SEL_I;
						ARB_STATE_NXT  <= UPLOAD_D_PAGE;
					elsif (to_integer(unsigned(PAGE_BUF)) = 0) then -- all pages analyzed
						ARB_STATE_NXT  <= END_TRANSFER;
					else
						PAGE_BUF_NXT   <= Std_Logic_Vector(unsigned(PAGE_BUF)-1);
					end if;

				when UPLOAD_D_PAGE => -- copy d-cache page to main memory
				-------------------------------------------------------------------------------
					WB_TGC_O_NXT(5) <= '0'; -- indicate data transfer
					WB_TGC_O_NXT(6) <= '0'; -- mem access
					WB_CTI_O_NXT    <= WB_INC_BST_CYC;
					WB_CYC_O_NXT    <= '1'; -- valid cycle, delayed one cycle
					WB_STB_O_NXT    <= '1'; -- valid transfer, delayed one cycle
					WB_WE_O_NXT     <= '1'; -- bus write
					DC_CS_O         <= '1'; -- enable data read back
					DC_WE_O         <= '0'; -- cache read access
					TIMEOUT_CNT_NXT <= Std_Logic_Vector(unsigned(TIMEOUT_CNT) + 1);
					if (WB_ADR_BUF >= Std_Logic_Vector(unsigned(BASE_BUF) + (D_CACHE_PAGE_SIZE-1)*4))  then
						if (to_integer(unsigned(WB_ACK_CNT)) >= D_CACHE_PAGE_SIZE) then
							ARB_STATE_NXT  <= END_TRANSFER;
							WB_CYC_O_NXT   <= '0';
							WB_STB_O_NXT <= '0';
							WB_CTI_O_NXT <= WB_BST_END_CYC;
							DC_DRT_ACK_O <= '1'; -- ack of dirty signal
						end if;
					end if;
					if (DC_ADR_BUF < Std_Logic_Vector(unsigned(BASE_BUF) + (D_CACHE_PAGE_SIZE-1)*4)) then
						DC_ADR_BUF_NXT <= Std_Logic_Vector(unsigned(DC_ADR_BUF) + 4); -- inc mem pointer
						WB_ADR_BUF_NXT <= Std_Logic_Vector(unsigned(WB_ADR_BUF) + 4); -- inc wb pointer
					end if;
					-- Timeout or abnormal cycle termination --
					if (TIMEOUT_CNT > C_BUS_CYCC_I) or (WB_ERR_BUF = '1') then
						WB_CTI_O_NXT    <= WB_BST_END_CYC;
						ARB_STATE_NXT   <= ASSIGN_D_PAGE;
						DC_DRT_ACK_O    <= '1'; -- ack dirty signal
						D_ABORT_O       <= '1'; -- abort interrupt
						FREEZE_DIS_NXT  <= '1';
						WB_CYC_O_NXT    <= '0'; -- terminate cycle
						WB_STB_O_NXT    <= '0'; -- terminate cycle
					end if;

				when END_TRANSFER => -- break between cycles
				-------------------------------------------------------------------------------
					WB_ACK_CNT_NXT  <= (others => '0');
					PAGE_BUF_NXT    <= (others => '1'); -- last entry
					FREEZE_FLAG_NXT <= '0';
					FREEZE_DIS_NXT  <= '0';
					ARB_STATE_NXT   <= IDLE;

			end case;
		end process ARBITER_ASYNC;


end Structure;