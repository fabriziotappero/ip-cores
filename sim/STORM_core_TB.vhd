-- #######################################################
-- #     < STORM Core Processor by Stephan Nolting >     #
-- # *************************************************** #
-- #        STORM Core / STORM Demo SoC Testbench        #
-- # *************************************************** #
-- # Last modified: 04.03.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity STORM_core_TB is
end STORM_core_TB;

architecture Structure of STORM_core_TB is

	-- Address Map --------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		constant INT_MEM_BASE_C  : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
		constant INT_MEM_SIZE_C  : natural := 1*1024; -- bytes
		constant GP_IO_BASE_C    : STD_LOGIC_VECTOR(31 downto 0) := x"FFFFE020";
		constant GP_IO_SIZE_C    : natural := 2*4; -- two 4-byte registers = 8 bytes


	-- Architecture Constants ---------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		constant BOOT_VECTOR_C        : STD_LOGIC_VECTOR(31 downto 0) := INT_MEM_BASE_C;
		constant IO_BEGIN_C           : STD_LOGIC_VECTOR(31 downto 0) :=  x"FFFFE020"; -- first addr of IO area
		constant IO_END_C             : STD_LOGIC_VECTOR(31 downto 0) :=  x"FFFFE024"; -- last addr of IO area
		constant I_CACHE_PAGES_C      : natural := 4;  -- number of pages in I cache
		constant I_CACHE_PAGE_SIZE_C  : natural := 16; -- page size in I cache
		constant D_CACHE_PAGES_C      : natural := 4;  -- number of pages in D cache
		constant D_CACHE_PAGE_SIZE_C  : natural := 4;  -- page size in D cache


	-- Global Signals -----------------------------------------------------------------
	-- -----------------------------------------------------------------------------------

		-- Global Clock & Reset --
		signal EXT_RST         : STD_LOGIC;
		signal MAIN_RST        : STD_LOGIC;
		signal MAIN_CLK        : STD_LOGIC := '0';
		signal STORM_IRQ       : STD_LOGIC;
		signal STORM_FIQ       : STD_LOGIC;

		-- Wishbone Core Bus --
		signal CORE_WB_ADR_O   : STD_LOGIC_VECTOR(31 downto 0); -- address
		signal CORE_WB_CTI_O   : STD_LOGIC_VECTOR(02 downto 0); -- cycle type
		signal CORE_WB_TGC_O   : STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
		signal CORE_WB_SEL_O   : STD_LOGIC_VECTOR(03 downto 0); -- byte select
		signal CORE_WB_WE_O    : STD_LOGIC;                     -- write enable
		signal CORE_WB_DATA_O  : STD_LOGIC_VECTOR(31 downto 0); -- data out
		signal CORE_WB_DATA_I  : STD_LOGIC_VECTOR(31 downto 0); -- data in
		signal CORE_WB_STB_O   : STD_LOGIC;                     -- valid transfer
		signal CORE_WB_CYC_O   : STD_LOGIC;                     -- valid cycle
		signal CORE_WB_ACK_I   : STD_LOGIC;                     -- acknowledge
		signal CORE_WB_ERR_I   : STD_LOGIC;                     -- abnormal termination
		signal CORE_WB_HALT_I  : STD_LOGIC;                     -- halt request


	-- Component interface ------------------------------------------------------------
	-- -----------------------------------------------------------------------------------

		-- Internal Working Memory --
		signal INT_MEM_DATA_O    : STD_LOGIC_VECTOR(31 downto 0);
		signal INT_MEM_STB_I     : STD_LOGIC;
		signal INT_MEM_ACK_O     : STD_LOGIC;
		signal INT_MEM_ERR_O     : STD_LOGIC;
		signal INT_MEM_HALT_O    : STD_LOGIC;

		-- General Purpose IO Controller --
		signal GP_IO_CTRL_DATA_O : STD_LOGIC_VECTOR(31 downto 0);
		signal GP_IO_CTRL_STB_I  : STD_LOGIC;
		signal GP_IO_CTRL_ACK_O  : STD_LOGIC;
		signal GP_IO_CTRL_ERR_O  : STD_LOGIC;
		signal GP_IO_CTRL_HALT_O : STD_LOGIC;
		signal GP_IO_OUT_PORT    : STD_LOGIC_VECTOR(31 downto 0);
		signal GP_IO_IN_PORT     : STD_LOGIC_VECTOR(31 downto 0);


	-- Logarithm duales ---------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		function log2(temp : natural) return natural is
		begin
			for i in 0 to integer'high loop
				if (2**i >= temp) then
					return i;
				end if;
			end loop;
			return 0;
		end function log2;


	-- STORM Core Top Entity ----------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component STORM_TOP
			generic (
						I_CACHE_PAGES     : natural := 4;  -- number of pages in I cache
						I_CACHE_PAGE_SIZE : natural := 32; -- page size in I cache
						D_CACHE_PAGES     : natural := 8;  -- number of pages in D cache
						D_CACHE_PAGE_SIZE : natural := 4;  -- page size in D cache
						BOOT_VECTOR       : STD_LOGIC_VECTOR(31 downto 0); -- boot address
						IO_UC_BEGIN       : STD_LOGIC_VECTOR(31 downto 0); -- begin of uncachable IO area
						IO_UC_END         : STD_LOGIC_VECTOR(31 downto 0)  -- end of uncachable IO area
				);
			port (
						-- Global Control --
						CORE_CLK_I    : in  STD_LOGIC; -- core clock input
						RST_I         : in  STD_LOGIC; -- global reset input
						IO_PORT_O     : out STD_LOGIC_VECTOR(15 downto 0); -- direct output
						IO_PORT_I     : in  STD_LOGIC_VECTOR(15 downto 0); -- direct input

						-- Wishbone Bus --
						WB_ADR_O      : out STD_LOGIC_VECTOR(31 downto 0); -- address
						WB_CTI_O      : out STD_LOGIC_VECTOR(02 downto 0); -- cycle type
						WB_TGC_O      : out STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
						WB_SEL_O      : out STD_LOGIC_VECTOR(03 downto 0); -- byte select
						WB_WE_O       : out STD_LOGIC;                     -- write enable
						WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- data out
						WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- data in
						WB_STB_O      : out STD_LOGIC;                     -- valid transfer
						WB_CYC_O      : out STD_LOGIC;                     -- valid cycle
						WB_ACK_I      : in  STD_LOGIC;                     -- acknowledge
						WB_ERR_I      : in  STD_LOGIC;                     -- abnormal cycle termination
						WB_HALT_I     : in  STD_LOGIC;                     -- halt request

						-- Interrupt Request Lines --
						IRQ_I         : in  STD_LOGIC; -- interrupt request
						FIQ_I         : in  STD_LOGIC  -- fast interrupt request
				);
		end component;


	-- Internal Working Memory --------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component MEMORY
			generic	(
						MEM_SIZE      : natural := 256;  -- memory cells
						LOG2_MEM_SIZE : natural := 8;    -- log2(memory cells)
						OUTPUT_GATE   : boolean := FALSE -- output and-gate, might be necessary for some bus systems
					);
			port	(
						-- Wishbone Bus --
						WB_CLK_I      : in  STD_LOGIC; -- memory master clock
						WB_RST_I      : in  STD_LOGIC; -- high active sync reset
						WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
						WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
						WB_ADR_I      : in  STD_LOGIC_VECTOR(LOG2_MEM_SIZE-1 downto 0); -- adr in
						WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
						WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
						WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
						WB_WE_I       : in  STD_LOGIC; -- write enable
						WB_STB_I      : in  STD_LOGIC; -- valid cycle
						WB_ACK_O      : out STD_LOGIC; -- acknowledge
						WB_HALT_O     : out STD_LOGIC; -- throttle master
						WB_ERR_O      : out STD_LOGIC  -- abnormal cycle termination
					);
		end component;


	-- General Purpose IO Controller --------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component GP_IO_CTRL
			port (
						-- Wishbone Bus --
						WB_CLK_I      : in  STD_LOGIC; -- memory master clock
						WB_RST_I      : in  STD_LOGIC; -- high active sync reset
						WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
						WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
						WB_ADR_I      : in  STD_LOGIC;                     -- adr in
						WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
						WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
						WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
						WB_WE_I       : in  STD_LOGIC; -- write enable
						WB_STB_I      : in  STD_LOGIC; -- valid cycle
						WB_ACK_O      : out STD_LOGIC; -- acknowledge
						WB_HALT_O     : out STD_LOGIC; -- throttle master
						WB_ERR_O      : out STD_LOGIC; -- abnormal termination

						-- IO Port --
						GP_IO_O       : out STD_LOGIC_VECTOR(31 downto 00);
						GP_IO_I       : in  STD_LOGIC_VECTOR(31 downto 00);

						-- Input Change INT --
						IO_IRQ_O      : out STD_LOGIC
				 );
		end component;

begin

-- #################################################################################################################################
-- ###  STORM CORE PROCESSOR                                                                                                     ###
-- #################################################################################################################################

	-- CLOCK/RESET GENERATOR -------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------

		-- Clock Generator --
		MAIN_CLK <= not MAIN_CLK after 20 ns; -- 50MHz

		-- Reset System --
		EXT_RST  <= '1', '0' after 400 ns;
		MAIN_RST <= EXT_RST;

		-- Interrupt Generator --
		STORM_IRQ <= '0', '1' after 2000 ns, '0' after 2020 ns;
		STORM_FIQ <= '0';



	-- STORM CORE PROCESSOR --------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		STORM_TOP_INST: STORM_TOP
			generic map (
								I_CACHE_PAGES     => I_CACHE_PAGES_C,     -- number of pages in I cache
								I_CACHE_PAGE_SIZE => I_CACHE_PAGE_SIZE_C, -- page size in I cache
								D_CACHE_PAGES     => D_CACHE_PAGES_C,     -- number of pages in D cache
								D_CACHE_PAGE_SIZE => D_CACHE_PAGE_SIZE_C, -- page size in D cache
								BOOT_VECTOR       => BOOT_VECTOR_C,       -- startup boot address
								IO_UC_BEGIN       => IO_BEGIN_C,          -- begin of uncachable IO area
								IO_UC_END         => IO_END_C             -- end of uncachable IO area
						)
			port map (
								-- Global Control --
								CORE_CLK_I        => MAIN_CLK,        -- core clock input
								RST_I             => MAIN_RST,        -- global reset input
								IO_PORT_O         => open,            -- direct output
								IO_PORT_I         => x"0000",         -- direct input

								-- Wishbone Bus --
								WB_ADR_O          => CORE_WB_ADR_O,   -- address
								WB_CTI_O          => CORE_WB_CTI_O,   -- cycle type
								WB_TGC_O          => CORE_WB_TGC_O,   -- cycle tag
								WB_SEL_O          => CORE_WB_SEL_O,   -- byte select
								WB_WE_O           => CORE_WB_WE_O,    -- write enable
								WB_DATA_O         => CORE_WB_DATA_O,  -- data out
								WB_DATA_I         => CORE_WB_DATA_I,  -- data in
								WB_STB_O          => CORE_WB_STB_O,   -- valid transfer
								WB_CYC_O          => CORE_WB_CYC_O,   -- valid cycle
								WB_ACK_I          => CORE_WB_ACK_I,   -- acknowledge
								WB_ERR_I          => CORE_WB_ERR_I,   -- abnormal cycle termination
								WB_HALT_I         => CORE_WB_HALT_I,  -- halt request

								-- Interrupt Request Lines --
								IRQ_I             => STORM_IRQ,       -- interrupt request
								FIQ_I             => STORM_FIQ        -- fast interrupt request
					);



-- #################################################################################################################################
-- ###  WISHBONE FABRIC                                                                                                          ###
-- #################################################################################################################################

	-- Valid Transfer Signal -------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		INT_MEM_STB_I    <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= INT_MEM_BASE_C) and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(INT_MEM_BASE_C) + INT_MEM_SIZE_C))) else '0';
		GP_IO_CTRL_STB_I <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= GP_IO_BASE_C)   and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(GP_IO_BASE_C)   + GP_IO_SIZE_C)))   else '0';
--		DUMMY0_STB_I     <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= DUMMY0_BASE_C)  and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(DUMMY0_BASE_C)  + DUMMY0_SIZE_C)))  else '0';
--		DUMMY1_STB_I     <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= DUMMY1_BASE_C)  and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(DUMMY1_BASE_C)  + DUMMY1_SIZE_C)))  else '0';


	-- Read-Back Data Selector -----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_DATA_I <=
			INT_MEM_DATA_O    when (INT_MEM_STB_I    = '1') else
			GP_IO_CTRL_DATA_O when (GP_IO_CTRL_STB_I = '1') else
--			DUMMY0_DATA_O     when (DUMMY0_STB_I     = '1') else
--			DUMMY1_DATA_O     when (DUMMY1_STB_I     = '1') else
			x"00000000";


	-- Use this style of data read-back terminal for pipelined Wishbone systems.
	-- You have to ensure, that all not-selected IO devices set their data output to 0.
	-- => Output and-gates controlled by the device's STB_I signal.
--		CORE_WB_DATA_I <= INT_MEM_DATA_O     or
--		                  GP_IO_CTRL_DATA_O  or
--			              DUMMY0_DATA_O      or
--			              DUMMY1_DATA_O      or
--		                  '0';


	-- Acknowledge Terminal --------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_ACK_I <=  INT_MEM_ACK_O      or
		                  GP_IO_CTRL_ACK_O   or
--		                  DUMMY0_ACK_O       or
--		                  DUMMY1_ACK_O       or
		                  '0';


	-- Halt Terminal ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_HALT_I <= INT_MEM_HALT_O     or
		                  GP_IO_CTRL_HALT_O  or
--		                  DUMMY0_HALT_O      or
--		                  DUMMY1_HALT_O      or
		                  '0';


	-- Halt Terminal ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_ERR_I <=  INT_MEM_ERR_O      or
		                  GP_IO_CTRL_ERR_O   or
--		                  DUMMY0_ERR_O       or
--		                  DUMMY1_ERR_O       or
		                  '0';



-- #################################################################################################################################
-- ###  SYSTEM COMPONENTS                                                                                                        ###
-- #################################################################################################################################

	-- Internal Working Memory -----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		INTERNAL_MEMORY: MEMORY
			generic map	(
						MEM_SIZE      => INT_MEM_SIZE_C/4, -- memory size in 32-bit cells
						LOG2_MEM_SIZE => log2(INT_MEM_SIZE_C/4), -- log2 memory size in 32-bit cells
						OUTPUT_GATE   => FALSE -- not necessary here
						)
			port map(
						WB_CLK_I      => MAIN_CLK,
						WB_RST_I      => MAIN_RST,
						WB_CTI_I      => CORE_WB_CTI_O,
						WB_TGC_I      => CORE_WB_TGC_O,
						WB_ADR_I      => CORE_WB_ADR_O(log2(INT_MEM_SIZE_C/4)+1 downto 2), -- word boundary access
						WB_DATA_I     => CORE_WB_DATA_O,
						WB_DATA_O     => INT_MEM_DATA_O,
						WB_SEL_I      => CORE_WB_SEL_O,
						WB_WE_I       => CORE_WB_WE_O,
						WB_STB_I      => INT_MEM_STB_I,
						WB_ACK_O      => INT_MEM_ACK_O,
						WB_HALT_O     => INT_MEM_HALT_O,
						WB_ERR_O      => INT_MEM_ERR_O
					);



	-- General Purpose IO ----------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		IO_CONTROLLER: GP_IO_CTRL
			port map (
						-- Wishbone Bus --
						WB_CLK_I      => MAIN_CLK,
						WB_RST_I      => MAIN_RST,
						WB_CTI_I      => CORE_WB_CTI_O,
						WB_TGC_I      => CORE_WB_TGC_O,
						WB_ADR_I      => CORE_WB_ADR_O(2),
						WB_DATA_I     => CORE_WB_DATA_O,
						WB_DATA_O     => GP_IO_CTRL_DATA_O,
						WB_SEL_I      => CORE_WB_SEL_O,
						WB_WE_I       => CORE_WB_WE_O,
						WB_STB_I      => GP_IO_CTRL_STB_I,
						WB_ACK_O      => GP_IO_CTRL_ACK_O,
						WB_HALT_O     => GP_IO_CTRL_HALT_O,
						WB_ERR_O      => GP_IO_CTRL_ERR_O,

						-- IO Port --
						GP_IO_O       => GP_IO_OUT_PORT,
						GP_IO_I       => GP_IO_IN_PORT,

						-- Input Change INT --
						IO_IRQ_O      => open
				 );

			-- Dummy input --
			GP_IO_IN_PORT <= "00000000001100111100110000000000";

end Structure;