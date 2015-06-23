-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #             Storm Cache Memory Component            #
-- # --------------------------------------------------- #
-- # Usable as data and instruction cache.               #
-- # I-Cache is read-only for the processor and          #
-- # write-only for the bus unit.                        #
-- # A cache line contains a complete word (32-bit).     #
-- # The cache is fully associative.                     #
-- # *************************************************** #
-- # Last modified: 08.03.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity CACHE is
-- ################################################################################################################
-- ##       Cache Configuration                                                                                  ##
-- ################################################################################################################
	generic (
				CACHE_PAGES      : natural := 8;
				LOG2_CACHE_PAGES : natural := 3;
				PAGE_SIZE        : natural := 2; -- #words
				LOG2_PAGE_SIZE   : natural := 1
			);
	port (
-- ################################################################################################################
-- ##       Global Control                                                                                       ##
-- ################################################################################################################

				CORE_CLK_I       : in  STD_LOGIC; -- core clock, all triggering on rising edge
				RST_I            : in  STD_LOGIC; -- global reset, high active, sync
				HALT_I           : in  STD_LOGIC; -- global storm halt signal

-- ################################################################################################################
-- ##       Processor Access                                                                                     ##
-- ################################################################################################################

				P_CS_I           : in  STD_LOGIC;                     -- processor request
				P_ADR_I          : in  STD_LOGIC_VECTOR(31 downto 0); -- address input
				P_DATA_I         : in  STD_LOGIC_VECTOR(31 downto 0); -- data input
				P_DATA_O         : out STD_LOGIC_VECTOR(31 downto 0); -- data output
				P_DQ_I           : in  STD_LOGIC_VECTOR(01 downto 0); -- data quantity
				P_WE_I           : in  STD_LOGIC;                     -- write enable

-- ################################################################################################################
-- ##       Bus Unit Access                                                                                      ##
-- ################################################################################################################

				B_CS_I           : in  STD_LOGIC;                     -- bus unit request
				B_P_SEL_I        : in  STD_LOGIC_VECTOR(LOG2_CACHE_PAGES-1 downto 0); -- bus unit page select
				B_D_SEL_O        : out STD_LOGIC;                     -- selected dirty bit
				B_A_SEL_O        : out STD_LOGIC_VECTOR(31 downto 0); -- selected base adr
				B_ADR_I          : in  STD_LOGIC_VECTOR(31 downto 0); -- address input
				B_DATA_I         : in  STD_LOGIC_VECTOR(31 downto 0); -- data input
				B_DATA_O         : out STD_LOGIC_VECTOR(31 downto 0); -- data output
				B_WE_I           : in  STD_LOGIC;                     -- write enable
				B_DRT_ACK_I      : in  STD_LOGIC;                     -- dirty acknowledged
				B_MSS_ACK_I      : in  STD_LOGIC;                     -- miss acknowledged
				B_IO_ACC_I       : in  STD_LOGIC;                     -- IO access

-- ################################################################################################################
-- ##       Cache Control Port                                                                                   ##
-- ################################################################################################################

				C_FRESH_I        : in  STD_LOGIC; -- refresh accessed page
				C_FLUSH_I        : in  STD_LOGIC; -- flush cache
				C_CLEAR_I        : in  STD_LOGIC; -- clear cache
				C_MISS_O         : out STD_LOGIC; -- cache miss access
				C_HIT_O          : out STD_LOGIC; -- cache hit access
				C_DIRTY_O        : out STD_LOGIC; -- cache modified
				C_WTHRU_I        : in  STD_LOGIC; -- write through
				C_SYNC_O         : out STD_LOGIC  -- cache is sync to mem/io
			);
end CACHE;

architecture Behavioral of CACHE is

	-- Cache Arbiter --
	type   ARB_STATE_TYPE is (STORM_ACCESS, MISS_STATE, IO_REQUEST, IO_PIPE_RESYNC, IO_PIPE_RESYNC_END, DIRTY_STATE, PIPE_RESYNC);
	signal ARB_STATE, ARB_STATE_NXT : ARB_STATE_TYPE;
	signal ADR_BUF,   ADR_BUF_NXT   : STD_LOGIC_VECTOR(31 downto 0);
	signal DAT_BUF,   DAT_BUF_NXT   : STD_LOGIC_VECTOR(31 downto 0);
	signal HST_BUF,   HST_BUF_NXT   : STD_LOGIC_VECTOR(LOG2_CACHE_PAGES-1 downto 0);
	signal BIT_BUF,   BIT_BUF_NXT   : STD_LOGIC;

	-- Cache Memory --
	signal CACHE_WE       : STD_LOGIC;
	signal CACHE_ADR      : STD_LOGIC_VECTOR(LOG2_CACHE_PAGES+(LOG2_PAGE_SIZE-1) downto 0);
	signal CACHE_R_DATA   : STD_LOGIC_VECTOR(31 downto 0);
	signal CACHE_W_DATA   : STD_LOGIC_VECTOR(31 downto 0);
	signal ADR_INT        : STD_LOGIC_VECTOR(31 downto 0);
	signal DQ_INT         : STD_LOGIC_VECTOR(01 downto 0);
	type   cache_mem_type is array(0 to (CACHE_PAGES*PAGE_SIZE)-1) of STD_LOGIC_VECTOR(07 downto 0);
	signal CACHE_MEM_LL   : cache_mem_type := (others => (others => '0'));
	signal CACHE_MEM_LH   : cache_mem_type := (others => (others => '0'));
	signal CACHE_MEM_HL   : cache_mem_type := (others => (others => '0'));
	signal CACHE_MEM_HH   : cache_mem_type := (others => (others => '0'));
	type   sim_mem_type   is array(0 to (CACHE_PAGES*PAGE_SIZE)-1) of STD_LOGIC_VECTOR(31 downto 0);
	signal SIM_MEM        : sim_mem_type;

	-- Page Base Memory --
	type   page_base_type is array(0 to CACHE_PAGES-1) of STD_LOGIC_VECTOR(31 downto LOG2_PAGE_SIZE+2);
	signal PAGE_BASE_ADR  : page_base_type;
	signal SET_NEW_BAS    : STD_LOGIC;

	-- Status Flags --
	signal VALID_FLAG     : STD_LOGIC_VECTOR(CACHE_PAGES-1 downto 0);
	signal CLR_CUR_VAL    : STD_LOGIC;
	signal SET_CUR_VAL    : STD_LOGIC;
	signal CLR_ALL_VAL    : STD_LOGIC;
	signal DIRTY_FLAG     : STD_LOGIC_VECTOR(CACHE_PAGES-1 downto 0);
	signal CACHE_DIRTY    : STD_LOGIC;
	signal CLR_CUR_DRT    : STD_LOGIC;
	signal SET_CUR_DRT    : STD_LOGIC;
	signal SET_ALL_DRT    : STD_LOGIC;

	-- Cache Access History --
	type   cache_hist_mem is array(CACHE_PAGES-1 downto 0) of STD_LOGIC_VECTOR(LOG2_CACHE_PAGES-1 downto 0);
	signal HIST_MEM       : cache_hist_mem;
	signal UPDATE_HISTORY : STD_LOGIC;
	signal UPDATE_HIST_FF : STD_LOGIC;

	-- Page Selector --
	signal PAGE_SELECT    : STD_LOGIC_VECTOR(LOG2_CACHE_PAGES-1 downto 0);
	signal PAGE_SELECT_FF : STD_LOGIC_VECTOR(LOG2_CACHE_PAGES-1 downto 0);
	signal PAGE_TRANSLATE : STD_LOGIC_VECTOR(LOG2_CACHE_PAGES-1 downto 0);
	signal NEW_ENTRY_PAGE : STD_LOGIC_VECTOR(LOG2_CACHE_PAGES-1 downto 0);
	signal B_BASE_O_SEL   : STD_LOGIC_VECTOR(LOG2_CACHE_PAGES-1 downto 0);

	-- Internal Control --
	signal CACHE_HIT      : STD_LOGIC;
	signal CACHE_MISS     : STD_LOGIC;
	signal BYTE_SEL       : STD_LOGIC_VECTOR(03 downto 0);
	signal P_DATA_O_SEL   : STD_LOGIC;
	signal P_DATA_O_BUF   : STD_LOGIC_VECTOR(31 downto 0);
	signal P_DATA_O_INT   : STD_LOGIC_VECTOR(31 downto 0);

begin

	-- Page Base Address System ----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		PAGE_ADR_SYS: process(CORE_CLK_I, PAGE_BASE_ADR, B_BASE_O_SEL, B_P_SEL_I)
		begin
			-- Update Base Adr Register --
			if rising_edge(CORE_CLK_I) then
				if (RST_I = '1') then
					for i in 0 to CACHE_PAGES-1 loop
						PAGE_BASE_ADR(i) <= (others => '0');
					end loop;
				else
					if (SET_NEW_BAS = '1') then
						PAGE_BASE_ADR(to_integer(unsigned(NEW_ENTRY_PAGE))) <= ADR_INT(31 downto LOG2_PAGE_SIZE+2);
					end if;
				end if;
			end if;

			-- Base ADR output for bus unit --
			B_A_SEL_O <= (others => '0');
			B_A_SEL_O(31 downto LOG2_PAGE_SIZE+2) <= PAGE_BASE_ADR(to_integer(unsigned(B_P_SEL_I)));
		end process PAGE_ADR_SYS;



	-- Cache Access History --------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CACHE_ACCESS_HIST_BUF: process(CORE_CLK_I)
		begin
			if rising_edge(CORE_CLK_I) then
				if (RST_I = '1') then
					PAGE_SELECT_FF <= (others => '0');
					UPDATE_HIST_FF <= '0';
				else
					PAGE_SELECT_FF <= PAGE_SELECT;
					UPDATE_HIST_FF <= UPDATE_HISTORY;
				end if;
			end if;
		end process CACHE_ACCESS_HIST_BUF;


		CACHE_ACCESS_HISTORY: process(HIST_MEM, PAGE_SELECT_FF, CORE_CLK_I)
			variable hist_mem_ce_v  : std_logic_vector(CACHE_PAGES-1 downto 0);
		begin
			--- CE signal hierarchy comparator ---
			hist_mem_ce_v := (others => '1');
			for i in 0 to CACHE_PAGES-1 loop
				if (HIST_MEM(CACHE_PAGES-1-i) = PAGE_SELECT_FF) then
					exit;
				else
					hist_mem_ce_v(CACHE_PAGES-1-i) := '0'; -- compare hit
				end if;
			end loop;

			--- Sync update ---
			if rising_edge(CORE_CLK_I) then
				if (RST_I = '1') then
					for i in 0 to CACHE_PAGES-1 loop
						HIST_MEM(i) <= std_logic_vector(to_unsigned(i, LOG2_CACHE_PAGES));
					end loop;
				else
					if (UPDATE_HIST_FF = '1') then
						for i in 0 to CACHE_PAGES-1 loop
							if (hist_mem_ce_v(CACHE_PAGES-1-i) = '1') then
								if (i = CACHE_PAGES-1) then
									HIST_MEM(CACHE_PAGES-1-i) <= PAGE_SELECT_FF;
								else
									HIST_MEM(CACHE_PAGES-1-i) <= HIST_MEM(CACHE_PAGES-1-i-1);
								end if;
							end if;
						end loop;
					end if;
				end if;
			end if;
		end process CACHE_ACCESS_HISTORY;



	-- Page Validation System ------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		PAGE_VALID_SYS: process(CORE_CLK_I)
		begin
			-- Update Valid Status Flag --
			if rising_edge(CORE_CLK_I) then
				if (RST_I = '1') or (CLR_ALL_VAL = '1') then
					for i in 0 to CACHE_PAGES-1 loop
						VALID_FLAG(i) <= '0';
					end loop;
				else
					if (CLR_CUR_VAL = '1') then
						VALID_FLAG(to_integer(unsigned(PAGE_SELECT))) <= '0';
					elsif (SET_CUR_VAL = '1') then
						VALID_FLAG(to_integer(unsigned(PAGE_SELECT))) <= '1';
					end if;
				end if;
			end if;
		end process PAGE_VALID_SYS;



	-- Page Modification Flag ------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		DIRTY_REG: process(CORE_CLK_I, DIRTY_FLAG, VALID_FLAG)
			variable temp1_v : std_logic;
			variable temp2_v : std_logic;
		begin
			-- Sync update --
			if rising_edge(CORE_CLK_I) then
				if (RST_I = '1') then
					for i in 0 to CACHE_PAGES-1 loop
						DIRTY_FLAG(i) <= '0';
					end loop;
				else
					if (SET_ALL_DRT = '1') then
						for i in 0 to CACHE_PAGES-1 loop
							DIRTY_FLAG(i) <= '1';
						end loop;
					else
						if (CLR_CUR_DRT = '1') then
							DIRTY_FLAG(to_integer(unsigned(PAGE_SELECT))) <= '0';
						elsif (SET_CUR_DRT = '1') then
							DIRTY_FLAG(to_integer(unsigned(PAGE_SELECT))) <= '1';
						end if;
					end if;
				end if;
			end if;

			-- Any dirty bits? --
			temp1_v := '0';
			for i in 0 to CACHE_PAGES-1 loop
				temp1_v := temp1_v or (DIRTY_FLAG(i) and VALID_FLAG(i));
			end loop;
			CACHE_DIRTY <= temp1_v;

			-- Cache sync? --
			temp2_v := '1';
			for i in 0 to CACHE_PAGES-1 loop
				temp2_v := temp2_v and (DIRTY_FLAG(i) nand VALID_FLAG(i));
			end loop;
			C_SYNC_O <= temp2_v;
		end process DIRTY_REG;

		--- Bus Unit Single Dirty Flag Output ---
		B_D_SEL_O <= DIRTY_FLAG(to_integer(unsigned(B_P_SEL_I))) and VALID_FLAG(to_integer(unsigned(B_P_SEL_I)));



	-- HIT / MISS Detector ---------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CONTENT_DETECTOR: process(ADR_INT, PAGE_BASE_ADR, VALID_FLAG, P_CS_I)
			variable miss_v : std_logic;
		begin
			miss_v := '1';
			for i in 0 to CACHE_PAGES-1 loop
				PAGE_TRANSLATE <= std_logic_vector(to_unsigned(i, LOG2_CACHE_PAGES));
				if (PAGE_BASE_ADR(i) = ADR_INT(31 downto LOG2_PAGE_SIZE+2)) and (VALID_FLAG(i) = '1') then
					miss_v := '0';
					exit;
				end if;
			end loop;
			CACHE_HIT  <= not miss_v;
			CACHE_MISS <= miss_v;
			C_HIT_O    <= (not miss_v) and P_CS_I; -- Output for statistic generator
		end process CONTENT_DETECTOR;



	-- Cache Arbiter ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CACHE_ARBITER_SYNC: process(CORE_CLK_I)
		begin
			if rising_edge(CORE_CLK_I) then
				if (RST_I = '1') then
					ARB_STATE <= STORM_ACCESS;
					ADR_BUF   <= (others => '0');
					DAT_BUF   <= (others => '0');
					HST_BUF   <= (others => '0');
					BIT_BUF   <= '0';
				else
					ARB_STATE <= ARB_STATE_NXT;
					ADR_BUF   <= ADR_BUF_NXT;
					DAT_BUF   <= DAT_BUF_NXT;
					HST_BUF   <= HST_BUF_NXT;
					BIT_BUF   <= BIT_BUF_NXT;
				end if;
			end if;
		end process CACHE_ARBITER_SYNC;



		CACHE_ARBITER: process(ARB_STATE, HIST_MEM, PAGE_TRANSLATE, ADR_BUF, DAT_BUF, HST_BUF, BIT_BUF, CACHE_R_DATA, DIRTY_FLAG, VALID_FLAG,
		                       CACHE_MISS, CACHE_DIRTY, C_FRESH_I, C_CLEAR_I, C_FLUSH_I, CACHE_HIT, C_WTHRU_I,
		                       P_ADR_I, P_DATA_I, P_CS_I, P_WE_I, P_DQ_I,
							   B_ADR_I, B_DATA_I, B_CS_I, B_WE_I, B_IO_ACC_I, B_MSS_ACK_I, B_DRT_ACK_I)
		begin
			--- Arbiter ---
			ARB_STATE_NXT <= ARB_STATE;
			ADR_BUF_NXT   <= ADR_BUF;
			DAT_BUF_NXT   <= DAT_BUF;
			HST_BUF_NXT   <= HST_BUF;
			BIT_BUF_NXT   <= BIT_BUF;

			--- Cache Control ---
			CACHE_WE     <= '0';
			CACHE_W_DATA <= P_DATA_I; -- (others => '0');
			CACHE_ADR    <= (others => '0');
			ADR_INT      <= P_ADR_I; -- (others => '0');
			DQ_INT       <= DQ_WORD;
			PAGE_SELECT  <= PAGE_TRANSLATE;

			--- Cache History ---
			UPDATE_HISTORY <= '0';
			NEW_ENTRY_PAGE <= HST_BUF; -- (others => '0');

			--- Cache Status ---
			CLR_CUR_DRT <= '0';
			SET_CUR_DRT <= '0';
			SET_ALL_DRT <= C_FLUSH_I;
			CLR_CUR_VAL <= '0';
			SET_CUR_VAL <= '0';
			CLR_ALL_VAL <= C_CLEAR_I;
			SET_NEW_BAS <= '0';

			--- STORM ---
			P_DATA_O_INT <= CACHE_R_DATA; -- (others => '0');

			--- Bus Unit ---
			B_DATA_O     <= CACHE_R_DATA; -- (others => '0');
			C_DIRTY_O    <= '0';
			C_MISS_O     <= '0';
			B_BASE_O_SEL <= HIST_MEM(CACHE_PAGES-1);

			--- State machine ---
			case (ARB_STATE) is

				when STORM_ACCESS => -- STORM can use the cache
				----------------------------------------------------------------
					ADR_INT        <= P_ADR_I;
					DQ_INT         <= P_DQ_I;
					PAGE_SELECT    <= PAGE_TRANSLATE;
					CACHE_ADR      <= PAGE_TRANSLATE & P_ADR_I((LOG2_PAGE_SIZE-1)+2 downto 2);
					CACHE_W_DATA   <= P_DATA_I;
					CACHE_WE       <= P_CS_I and CACHE_HIT and P_WE_I and (not B_IO_ACC_I);
					CLR_CUR_VAL    <= C_FRESH_I and CACHE_HIT and P_CS_I and (not B_IO_ACC_I);
					SET_CUR_DRT    <= P_CS_I and CACHE_HIT and P_WE_I and (not B_IO_ACC_I);
					UPDATE_HISTORY <= P_CS_I and CACHE_HIT and (not B_IO_ACC_I);
					P_DATA_O_INT   <= CACHE_R_DATA;
					DAT_BUF_NXT    <= P_DATA_I;
					ADR_BUF_NXT    <= P_ADR_I;
					HST_BUF_NXT    <= HIST_MEM(CACHE_PAGES-1); -- next page for writing
					BIT_BUF_NXT    <= P_CS_I and P_WE_I;
					if (C_WTHRU_I = '0') and (DIRTY_FLAG(to_integer(unsigned(HIST_MEM(CACHE_PAGES-1)))) = '1') and
					   (VALID_FLAG(to_integer(unsigned(HIST_MEM(CACHE_PAGES-1)))) = '1') then
						ARB_STATE_NXT <= DIRTY_STATE;
					elsif (B_IO_ACC_I = '1') and (P_CS_I = '1') then
						ARB_STATE_NXT <= IO_REQUEST;
					elsif ((CACHE_MISS = '1') or (C_FRESH_I = '1')) and (P_CS_I = '1') then
						ARB_STATE_NXT <= MISS_STATE;
					elsif ((CACHE_DIRTY = '1') and (C_WTHRU_I = '1')) then -- write through
						ARB_STATE_NXT <= DIRTY_STATE;
					end if;

				when IO_REQUEST => -- IO Access
				----------------------------------------------------------------
					B_DATA_O <= DAT_BUF;
					if (B_MSS_ACK_I = '1') or (B_DRT_ACK_I = '1') then
						DAT_BUF_NXT   <= B_DATA_I;
						if (BIT_BUF = '1') then -- write
							ARB_STATE_NXT <= IO_PIPE_RESYNC_END;
						else -- read
							ARB_STATE_NXT <= IO_PIPE_RESYNC;
						end if;
					end if;
				when IO_PIPE_RESYNC => -- IO Pipeline Re-Sync
					P_DATA_O_INT   <= DAT_BUF;
					ARB_STATE_NXT  <= IO_PIPE_RESYNC_END;
				when IO_PIPE_RESYNC_END => -- IO Pipeline Re-Sync finished
					P_DATA_O_INT   <= DAT_BUF;
					ARB_STATE_NXT  <= STORM_ACCESS;

				when MISS_STATE => -- Cache miss
				----------------------------------------------------------------
					C_MISS_O       <= '1'; -- we're missing something
					ADR_INT        <= B_ADR_I;
					DQ_INT         <= DQ_WORD;
					PAGE_SELECT    <= HST_BUF;
					CACHE_ADR      <= HST_BUF & B_ADR_I((LOG2_PAGE_SIZE-1)+2 downto 2);
					CACHE_W_DATA   <= B_DATA_I;
					CACHE_WE       <= B_CS_I;-- and B_WE_I;
					SET_CUR_VAL    <= B_CS_I;-- and B_WE_I;
					CLR_CUR_DRT    <= B_CS_I;-- and B_WE_I;
					SET_CUR_DRT    <= BIT_BUF;
					SET_NEW_BAS    <= B_CS_I;-- and B_WE_I;
					UPDATE_HISTORY <= B_CS_I;-- and B_WE_I;
					B_DATA_O       <= CACHE_R_DATA;
					NEW_ENTRY_PAGE <= HST_BUF;
					if (B_MSS_ACK_I = '1') then
						ARB_STATE_NXT <= PIPE_RESYNC;
					end if;

				when DIRTY_STATE => -- Cache dirty
				----------------------------------------------------------------
					C_DIRTY_O      <= '1';
					if (C_WTHRU_I = '1') then
						B_BASE_O_SEL <= PAGE_TRANSLATE;
					end if;
					ADR_INT        <= B_ADR_I;
					DQ_INT         <= DQ_WORD;
					PAGE_SELECT    <= PAGE_TRANSLATE;--HST_BUF;
					CACHE_ADR      <= PAGE_TRANSLATE & B_ADR_I((LOG2_PAGE_SIZE-1)+2 downto 2);--HST_BUF & B_ADR_I((LOG2_PAGE_SIZE-1)+2 downto 2);
					CLR_CUR_DRT    <= B_CS_I;-- and B_WE_I;
					--UPDATE_HISTORY <= B_CS_I;-- and B_WE_I;
					B_DATA_O       <= CACHE_R_DATA;
					if (B_DRT_ACK_I = '1') then
						ARB_STATE_NXT <= PIPE_RESYNC;
					end if;

				when PIPE_RESYNC => -- Re-sync Pipeline
				----------------------------------------------------------------
					ADR_INT        <= ADR_BUF;
					DQ_INT         <= DQ_WORD;
					PAGE_SELECT    <= PAGE_TRANSLATE;
					CACHE_ADR      <= PAGE_TRANSLATE & ADR_BUF((LOG2_PAGE_SIZE-1)+2 downto 2);
					CACHE_W_DATA   <= DAT_BUF;
					CACHE_WE       <= BIT_BUF;
					P_DATA_O_INT   <= CACHE_R_DATA;
					if (CACHE_DIRTY = '1') and (C_WTHRU_I = '1') then -- write through
						ARB_STATE_NXT <= DIRTY_STATE;
					else
						ARB_STATE_NXT <= STORM_ACCESS;
					end if;

			end case;
		end process CACHE_ARBITER;



	-- Data Quantity Decoder ----------------------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------------------------------
		DQ_DECODER: process(DQ_INT, ADR_INT(1 downto 0))
			variable case_v, temp_v : std_logic_vector(3 downto 0);
		begin
			case_v := DQ_INT & ADR_INT(1 downto 0);
			case (case_v) is
				when "0000" | "0001" | "0010" | "0011" => -- WORD with any offset
					temp_v := "1111";
				when "0100" => -- BYTE with no offset
					temp_v := "1000";
				when "0101" => -- BYTE with one byte offset
					temp_v := "0100";
				when "0110" => -- BYTE with two bytes offset
					temp_v := "0010";
				when "0111" => -- BYTE with three bytes offset
					temp_v := "0001";
				when "1000" | "1100" => -- HALFWORD with no offset
					temp_v := "1100";
				when "1001" | "1101" => -- HALFWORD with one byte offset
					temp_v := "0110";
				when "1010" | "1110" => -- HALFWORD with two bytes offset
					temp_v := "0011";
				when others          => -- HALFWORD with three bytes offset
					temp_v := "1001";
			end case;
			-- Memory organization --
			if (USE_BIG_ENDIAN = TRUE) then
				BYTE_SEL(3) <= temp_v(3);
				BYTE_SEL(2) <= temp_v(2);
				BYTE_SEL(1) <= temp_v(1);
				BYTE_SEL(0) <= temp_v(0);
			else
				BYTE_SEL(3) <= temp_v(0);
				BYTE_SEL(2) <= temp_v(1);
				BYTE_SEL(1) <= temp_v(2);
				BYTE_SEL(0) <= temp_v(3);
			end if;
		end process DQ_DECODER;



	-- Cache Memory Access ---------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CACHE_ACCESS: process(CORE_CLK_I)
		begin
			-- Sync Write--
			if rising_edge(CORE_CLK_I) then
				if (CACHE_WE = '1') then -- cache write access
					if (BYTE_SEL(0) = '1') then
						CACHE_MEM_LL(to_integer(unsigned(CACHE_ADR))) <= CACHE_W_DATA(0*8+7 downto 0*8);
					end if;
					if (BYTE_SEL(1) = '1') then
						CACHE_MEM_LH(to_integer(unsigned(CACHE_ADR))) <= CACHE_W_DATA(1*8+7 downto 1*8);
					end if;
					if (BYTE_SEL(2) = '1') then
						CACHE_MEM_HL(to_integer(unsigned(CACHE_ADR))) <= CACHE_W_DATA(2*8+7 downto 2*8);
					end if;
					if (BYTE_SEL(3) = '1') then
						CACHE_MEM_HH(to_integer(unsigned(CACHE_ADR))) <= CACHE_W_DATA(3*8+7 downto 3*8);
					end if;
				end if;
				CACHE_R_DATA(07 downto 00) <= CACHE_MEM_LL(to_integer(unsigned(CACHE_ADR)));
				CACHE_R_DATA(15 downto 08) <= CACHE_MEM_LH(to_integer(unsigned(CACHE_ADR)));
				CACHE_R_DATA(23 downto 16) <= CACHE_MEM_HL(to_integer(unsigned(CACHE_ADR)));
				CACHE_R_DATA(31 downto 24) <= CACHE_MEM_HH(to_integer(unsigned(CACHE_ADR)));
			end if;
		end process CACHE_ACCESS;

		-- Dummy for simulation --
--		GEN_DEBUG_MEM:
--		for i in 0 to (CACHE_PAGES*PAGE_SIZE)-1 generate
--			SIM_MEM(i) <= CACHE_MEM_HH(i) & CACHE_MEM_HL(i) & CACHE_MEM_LH(i) & CACHE_MEM_LL(i) when (IS_SIM = TRUE) else x"00000000";
--		end generate;



	-- Read-Access Synchronizer ----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		R_ACC_SYNC: process(CORE_CLK_I)
		begin
			if rising_edge(CORE_CLK_I) then
				if (RST_I = '1') then
					P_DATA_O_SEL <= '0';
					P_DATA_O_BUF <= (others => '0');
				elsif (ARB_STATE = STORM_ACCESS) then
					P_DATA_O_SEL <= HALT_I;
					if (P_DATA_O_SEL = '0') then
						P_DATA_O_BUF <= P_DATA_O_INT;
					end if;
				end if;
			end if;
		end process R_ACC_SYNC;

		--- Data output buffer ---
		P_DATA_O <= P_DATA_O_INT when (P_DATA_O_SEL = '0') else P_DATA_O_BUF;




end Behavioral;