-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #       Load/Store Unit for Data Memory Access        #
-- # *************************************************** #
-- # Last modified: 26.03.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity LOAD_STORE_UNIT is
port	(
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

				CLK_I           : in  STD_LOGIC;
				G_HALT_I        : in  STD_LOGIC; -- global halt line
				RST_I           : in  STD_LOGIC;
				CTRL_I          : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);

-- ###############################################################################################
-- ##           Operand Connection                                                              ##
-- ###############################################################################################

				MEM_DATA_I      : in  STD_LOGIC_VECTOR(31 downto 0);
				MEM_ADR_I       : in  STD_LOGIC_VECTOR(31 downto 0);
				MEM_BP_I        : in  STD_LOGIC_VECTOR(31 downto 0);
				
				MODE_I          : in  STD_LOGIC_VECTOR(04 downto 0); -- current processor mode
				LNK_PC_I        : in  STD_LOGIC_VECTOR(31 downto 0); -- pc for link operations

				ADR_O           : out STD_LOGIC_VECTOR(31 downto 0);
				BP_O            : out STD_LOGIC_VECTOR(31 downto 0);

-- ###############################################################################################
-- ##           Forwarding Path                                                                 ##
-- ###############################################################################################

				LDST_FW_O       : out STD_LOGIC_VECTOR(FWD_MSB downto 0);

-- ###############################################################################################
-- ##           External Memory Interface                                                       ##
-- ###############################################################################################

				XMEM_MODE_O     : out STD_LOGIC_VECTOR(04 downto 0); -- processor mode for access
				XMEM_ADR_O      : out STD_LOGIC_VECTOR(31 downto 0); -- Address Output
				XMEM_WR_DTA_O   : out STD_LOGIC_VECTOR(31 downto 0); -- Data Output
				XMEM_ACC_REQ_O  : out STD_LOGIC; -- Access Request
				XMEM_RW_O       : out STD_LOGIC; -- Read/write signal
				XMEM_DQ_O       : out STD_LOGIC_VECTOR(01 downto 0) -- Data Quantity

		);
end LOAD_STORE_UNIT;

architecture Structure of LOAD_STORE_UNIT is

	-- Pipeline Regs --
	signal DATA_BUFFER : STD_LOGIC_VECTOR(31 downto 0);
	signal ADR_BUFFER  : STD_LOGIC_VECTOR(31 downto 0);
	signal BP_BUFFER   : STD_LOGIC_VECTOR(31 downto 0);

	-- Local Signals --
	signal BP_TEMP     : STD_LOGIC_VECTOR(31 downto 0);

begin

	-- Pipeline-Buffers -----------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------------
		MEM_BUFFER: process(CLK_I)
		begin
			if rising_edge(CLK_i) then
				if (RST_I = '1') then
					DATA_BUFFER <= (others => '0');
					ADR_BUFFER  <= (others => '0');
					BP_BUFFER   <= (others => '0');
				elsif (G_HALT_I = '0') then
					DATA_BUFFER <= MEM_DATA_I; -- Memory write data buffer
					ADR_BUFFER  <= MEM_ADR_I;  -- Memory adress buffer
					BP_BUFFER   <= MEM_BP_I;   -- Memory bypass buffer
				end if;
			end if;
		end process MEM_BUFFER;
		
		-- Address Output --
		ADR_O      <= ADR_BUFFER;
		XMEM_ADR_O <= ADR_BUFFER;



	-- Bypass Multiplexer ---------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------------

		-- bypass multiplexer for link operations --
		BP_O <= LNK_PC_I when (CTRL_I(CTRL_LINK) = '1') else DATA_BUFFER;
		-- Memory Write Data --
		BP_TEMP <= DATA_BUFFER;



	-- Forwarding Path ------------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------------

		-- Forwarding Data--
		LDST_FW_O(FWD_DATA_MSB downto FWD_DATA_LSB) <= BP_TEMP;
		-- Destination Register --
		LDST_FW_O(FWD_RD_MSB downto FWD_RD_LSB) <= CTRL_I(CTRL_RD_3 downto CTRL_RD_0);
		-- Write Back --
		LDST_FW_O(FWD_WB) <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_WB_EN);
		-- Mode bits modification --
		LDST_FW_O(FWD_MCR_MOD)   <= '0'; -- not needed here
		-- Flag bits modification --
		LDST_FW_O(FWD_FLAG_MOD)  <= '0'; -- not needed here
		-- MCR Read Access --
		LDST_FW_O(FWD_MCR_R_ACC) <= '0'; -- not needed here
		-- Memory Read Access --
		LDST_FW_O(FWD_MEM_R_ACC) <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_MEM_ACC) and (not CTRL_I(CTRL_MEM_RW));
		-- Memory-Pc Load --
		LDST_FW_O(FWD_MEM_PC_LD) <= '0'; -- not needed here



	-- External Memory Interface --------------------------------------------------------------
	-- -------------------------------------------------------------------------------------------
		MEM_DATA_INTERFACE: process(CTRL_I, BP_BUFFER, MODE_I)
			variable OUTPUT_DATA_BUFFER : STD_LOGIC_VECTOR(31 downto 0);
			variable ENDIAN_TMP         : STD_LOGIC_VECTOR(31 downto 0);
		begin
			--- Output Data Alignment ---
			case (CTRL_I(CTRL_MEM_DQ_1 downto CTRL_MEM_DQ_0)) is
				when DQ_WORD => -- Word Transfer
					OUTPUT_DATA_BUFFER := BP_BUFFER;
				when DQ_BYTE => -- Byte Transfer
					OUTPUT_DATA_BUFFER := BP_BUFFER(07 downto 00) & BP_BUFFER(07 downto 00) &
					                      BP_BUFFER(07 downto 00) & BP_BUFFER(07 downto 00);
				when others => -- Halfword Transfer
					OUTPUT_DATA_BUFFER := BP_BUFFER(15 downto 00) & BP_BUFFER(15 downto 00);
			end case;

			--- Endianess Converter ---
			if (USE_BIG_ENDIAN = FALSE) then -- Little Endian
				ENDIAN_TMP := OUTPUT_DATA_BUFFER(07 downto 00) & OUTPUT_DATA_BUFFER(15 downto 08) &
				              OUTPUT_DATA_BUFFER(23 downto 16) & OUTPUT_DATA_BUFFER(31 downto 24);
			else -- Big Endian
				ENDIAN_TMP := OUTPUT_DATA_BUFFER(31 downto 24) & OUTPUT_DATA_BUFFER(23 downto 16) &
				              OUTPUT_DATA_BUFFER(15 downto 08) & OUTPUT_DATA_BUFFER(07 downto 00);
			end if;

			--- D-MEM Interface ---
			XMEM_WR_DTA_O  <= ENDIAN_TMP;
			XMEM_RW_O      <= CTRL_I(CTRL_MEM_RW); -- Read/Write
			XMEM_DQ_O      <= CTRL_I(CTRL_MEM_DQ_1 downto CTRL_MEM_DQ_0);  -- Data Quantity
			XMEM_ACC_REQ_O <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_MEM_ACC);

			--- Mode for MEM access --
			XMEM_MODE_O <= MODE_I; -- current processor mode
		end process MEM_DATA_INTERFACE;


end Structure;