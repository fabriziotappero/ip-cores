-- ########################################################################
-- #                 <<< STORM SoC by Stephan Nolting >>>                 #
-- # ******************************************************************** #
-- #                      Basic System Configuration                      #
-- # Components:                                                          #
-- #  - Boot ROM with pre-installed bootloader                            #
-- #  - I²C-controller (core can boot from attached I²C EEPROM)           #
-- #  - IO controller, providing general purpose IO's                     #
-- #  - miniUART, fixed settings 9600-8-n-1                               #
-- #  - Reset protector                                                   #
-- #  - SPI controller, 8 CS lines, split up into 3 ports                 #
-- #  - System timer, 32 bit                                              #
-- #  - Vector-interrupt-controller (LPC controller)                      #
-- #  - PWM controller, 8 channels                                        #
-- #                                                                      #
-- # ******************************************************************** #
-- # Last modified: 15.05.2012                                            #
-- ########################################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity STORM_SoC_basic is
	port (
			-- Global Control --
			CLK_I         : in    STD_LOGIC;
			RST_I         : in    STD_LOGIC;

			-- General purpose (console) UART --
			UART0_RXD_I   : in    STD_LOGIC;
			UART0_TXD_O   : out   STD_LOGIC;

			-- System Control --
			START_I       : in    STD_LOGIC; -- low active
			BOOT_CONFIG_I : in    STD_LOGIC_VECTOR(03 downto 0); -- low active
			LED_BAR_O     : out   STD_LOGIC_VECTOR(07 downto 0);

			-- GP Input Pins --
			GP_INPUT_I    : in    STD_LOGIC_VECTOR(07 downto 0);

			-- GP Output Pins --
			GP_OUTPUT_O   : out   STD_LOGIC_VECTOR(07 downto 0);

			-- I²C Port --
			I2C_SCL_IO    : inout STD_LOGIC;
			I2C_SDA_IO    : inout STD_LOGIC;

			-- SPI Port 0 [3 devices] --
			SPI_P0_CLK_O  : out   STD_LOGIC;
			SPI_P0_MISO_I : in    STD_LOGIC;
			SPI_P0_MOSI_O : out   STD_LOGIC;
			SPI_P0_CS_O   : out   STD_LOGIC_VECTOR(02 downto 0);

			-- SPI Port 1 [3 devices] --
			SPI_P1_CLK_O  : out   STD_LOGIC;
			SPI_P1_MISO_I : in    STD_LOGIC;
			SPI_P1_MOSI_O : out   STD_LOGIC;
			SPI_P1_CS_O   : out   STD_LOGIC_VECTOR(02 downto 0);

			-- SPI Port 2 [2 devices] --
			SPI_P2_CLK_O  : out   STD_LOGIC;
			SPI_P2_MISO_I : in    STD_LOGIC;
			SPI_P2_MOSI_O : out   STD_LOGIC;
			SPI_P2_CS_O   : out   STD_LOGIC_VECTOR(01 downto 0);

			-- PWM Port 0 --
			PWM0_PORT_O   : out   STD_LOGIC_VECTOR(07 downto 0)
	     );
end STORM_SoC_basic;

architecture Structure of STORM_SoC_basic is

	-- Address Map --------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		constant INT_MEM_BASE_C    : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
		constant INT_MEM_SIZE_C    : natural := 32*1024; -- byte
		constant BOOT_ROM_BASE_C   : STD_LOGIC_VECTOR(31 downto 0) := x"FFF00000";
		constant BOOT_ROM_SIZE_C   : natural := 8*1024; -- byte
		-- Begin of IO area ------------------------------------------------------
		constant IO_AREA_BEGIN     : STD_LOGIC_VECTOR(31 downto 0) := x"FFFF0000";
		constant GP_IO0_BASE_C     : STD_LOGIC_VECTOR(31 downto 0) := x"FFFF0000";
		constant GP_IO0_SIZE_C     : natural := 2*4; -- byte
		constant UART0_BASE_C      : STD_LOGIC_VECTOR(31 downto 0) := x"FFFF0018";
		constant UART0_SIZE_C      : natural := 2*4; -- byte
		constant SYS_TIMER0_BASE_C : STD_LOGIC_VECTOR(31 downto 0) := x"FFFF0020";
		constant SYS_TIMER0_SIZE_C : natural := 4*4; -- byte
		constant SPI0_CTRL_BASE_C  : STD_LOGIC_VECTOR(31 downto 0) := x"FFFF0030";
		constant SPI0_CTRL_SIZE_C  : natural := 8*4; -- byte
		constant I2C0_CTRL_BASE_C  : STD_LOGIC_VECTOR(31 downto 0) := x"FFFF0050";
		constant I2C0_CTRL_SIZE_C  : natural := 8*4; -- byte
		constant PWM_CTRL0_BASE_C  : STD_LOGIC_VECTOR(31 downto 0) := x"FFFF0070";
		constant PWM_CTRL0_SIZE_C  : natural := 2*4; -- byte
		constant VIC_BASE_C        : STD_LOGIC_VECTOR(31 downto 0) := x"FFFFF000";
		constant VIC_SIZE_C        : natural := 64*4; -- byte
		constant IO_AREA_END       : STD_LOGIC_VECTOR(31 downto 0) := x"FFFFFFFF";
		-- End of IO area --------------------------------------------------------


	-- Architecture Constants ---------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		constant BOOT_VECTOR_C       : STD_LOGIC_VECTOR(31 downto 0) := BOOT_ROM_BASE_C;
		constant BOOT_IMAGE_C        : string  := "STORM_SOC_BASIC_BL_32_8";
		constant I_CACHE_PAGES_C     : natural := 8;
		constant I_CACHE_PAGE_SIZE_C : natural := 32;
		constant D_CACHE_PAGES_C     : natural := 8;
		constant D_CACHE_PAGE_SIZE_C : natural := 32;
		constant CORE_CLOCK_C        : natural := 50000000; -- Hz
		constant RST_RTIGGER_C       : natural := CORE_CLOCK_C/2;
		constant LOW_ACTIVE_RST_C    : boolean := TRUE;
		constant UART0_BAUD_C        : natural := 9600;
		constant UART0_BAUD_VAL_C    : natural := CORE_CLOCK_C/(4*UART0_BAUD_C);
		constant USE_OUTPUT_GATES_C  : boolean := FALSE;


	-- Global signals -----------------------------------------------------------------
	-- -----------------------------------------------------------------------------------

		-- Global Clock, Reset, Interrupt, Control --
		signal MAIN_RST           : STD_LOGIC;
		signal MAIN_RST_N         : STD_LOGIC;
		signal XMEM_CLK           : STD_LOGIC;
		signal XMEMD_CLK          : STD_LOGIC;
		signal CLK_LOCK           : STD_LOGIC;
		signal CLK_DIV            : STD_LOGIC_VECTOR(01 downto 0) := "00"; -- just for sim
		signal MAIN_CLK           : STD_LOGIC;
		signal SAVE_RST           : STD_LOGIC;
		signal STORM_IRQ          : STD_LOGIC;
		signal STORM_FIQ          : STD_LOGIC;
		signal SYS_CTRL_O         : STD_LOGIC_VECTOR(15 downto 0);
		signal SYS_CTRL_I         : STD_LOGIC_VECTOR(15 downto 0);

		-- Wishbone Core Bus --
		signal CORE_WB_ADR_O      : STD_LOGIC_VECTOR(31 downto 0); -- address
		signal CORE_WB_CTI_O      : STD_LOGIC_VECTOR(02 downto 0); -- cycle type
		signal CORE_WB_TGC_O      : STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
		signal CORE_WB_SEL_O      : STD_LOGIC_VECTOR(03 downto 0); -- byte select
		signal CORE_WB_WE_O       : STD_LOGIC;                     -- write enable
		signal CORE_WB_DATA_O     : STD_LOGIC_VECTOR(31 downto 0); -- data out
		signal CORE_WB_DATA_I     : STD_LOGIC_VECTOR(31 downto 0); -- data in
		signal CORE_WB_STB_O      : STD_LOGIC;                     -- valid transfer
		signal CORE_WB_CYC_O      : STD_LOGIC;                     -- valid cycle
		signal CORE_WB_ACK_I      : STD_LOGIC;                     -- acknowledge
		signal CORE_WB_HALT_I     : STD_LOGIC;                     -- halt request
		signal CORE_WB_ERR_I      : STD_LOGIC;                     -- abnormal termination


	-- Component interface ------------------------------------------------------------
	-- -----------------------------------------------------------------------------------

		-- Internal SRAM Memory --
		signal INT_MEM_DATA_O     : STD_LOGIC_VECTOR(31 downto 0);
		signal INT_MEM_STB_I      : STD_LOGIC;
		signal INT_MEM_ACK_O      : STD_LOGIC;
		signal INT_MEM_HALT_O     : STD_LOGIC;
		signal INT_MEM_ERR_O      : STD_LOGIC;

		-- UART 0 - miniUART --
		signal UART0_DATA_O       : STD_LOGIC_VECTOR(31 downto 0);
		signal UART0_STB_I        : STD_LOGIC;
		signal UART0_ACK_O        : STD_LOGIC;
		signal UART0_ERR_O        : STD_LOGIC;
		signal UART0_TX_IRQ       : STD_LOGIC;
		signal UART0_RX_IRQ       : STD_LOGIC;
		signal UART0_HALT_O       : STD_LOGIC;
		
		-- Boot ROM --
		signal BOOT_ROM_DATA_O    : STD_LOGIC_VECTOR(31 downto 0);
		signal BOOT_ROM_STB_I     : STD_LOGIC;
		signal BOOT_ROM_ACK_O     : STD_LOGIC;
		signal BOOT_ROM_HALT_O    : STD_LOGIC;
		signal BOOT_ROM_ERR_O     : STD_LOGIC;

		-- General Purpose IO Controller 0 --
		signal GP_IO0_CTRL_DATA_O : STD_LOGIC_VECTOR(31 downto 0);
		signal GP_IO0_CTRL_STB_I  : STD_LOGIC;
		signal GP_IO0_CTRL_ACK_O  : STD_LOGIC;
		signal GP_IO0_CTRL_HALT_O : STD_LOGIC;
		signal GP_IO0_CTRL_ERR_O  : STD_LOGIC;
		signal GP_IO0_IRQ         : STD_LOGIC;
		signal GP_IO0_TEMP_I      : STD_LOGIC_VECTOR(31 downto 0);
		signal GP_IO0_TEMP_O      : STD_LOGIC_VECTOR(31 downto 0);

		-- SPI Controller 0 --
		signal SPI0_CTRL_DATA_O   : STD_LOGIC_VECTOR(31 downto 0);
		signal SPI0_CTRL_STB_I    : STD_LOGIC;
		signal SPI0_CTRL_ACK_O    : STD_LOGIC;
		signal SPI0_CTRL_HALT_O   : STD_LOGIC;
		signal SPI0_CTRL_ERR_O    : STD_LOGIC;
		signal SPI0_CTRL_IRQ      : STD_LOGIC;
		signal MISO_PORT_0        : STD_LOGIC;
		signal MISO_PORT_1        : STD_LOGIC;
		signal MISO_PORT_2        : STD_LOGIC;
		signal SPI_CS_INT         : STD_LOGIC_VECTOR(07 downto 0);
		signal SPI_MOSI_INT       : STD_LOGIC;
		signal SPI_CLK_INT        : STD_LOGIC;
		signal SPI_MISO_INT       : STD_LOGIC;

		-- I²C Controller 0 --
		signal I2C0_CTRL_DATA_O   : STD_LOGIC_VECTOR(31 downto 0);
		signal I2C_DATA_TMP       : STD_LOGIC_VECTOR(07 downto 0);
		signal I2C0_CTRL_STB_I    : STD_LOGIC;
		signal I2C0_CTRL_ACK_O    : STD_LOGIC;
		signal I2C0_CTRL_HALT_O   : STD_LOGIC;
		signal I2C0_CTRL_ERR_O    : STD_LOGIC;
		signal I2C0_CTRL_IRQ      : STD_LOGIC;
		signal SCL_PAD_I          : STD_LOGIC;
		signal SCL_PAD_O          : STD_LOGIC;
		signal SCL_PADOE          : STD_LOGIC;
		signal SDA_PAD_I          : STD_LOGIC;
		signal SDA_PAD_O          : STD_LOGIC;
		signal SDA_PADOE          : STD_LOGIC;

		-- System Timer 0 --
		signal SYS_TIMER0_DATA_O  : STD_LOGIC_VECTOR(31 downto 0);
		signal SYS_TIMER0_STB_I   : STD_LOGIC;
		signal SYS_TIMER0_ACK_O   : STD_LOGIC;
		signal SYS_TIMER0_IRQ     : STD_LOGIC;
		signal SYS_TIMER0_HALT_O  : STD_LOGIC;
		signal SYS_TIMER0_ERR_O   : STD_LOGIC;

		-- PWM Controller 0 --
		signal PWM_CTRL0_DATA_O   : STD_LOGIC_VECTOR(31 downto 0);
		signal PWM_CTRL0_STB_I    : STD_LOGIC;
		signal PWM_CTRL0_ACK_O    : STD_LOGIC;
		signal PWM_CTRL0_HALT_O   : STD_LOGIC;
		signal PWM_CTRL0_ERR_O    : STD_LOGIC;

		-- Vector Interrupt Controller --
		signal VIC_DATA_O         : STD_LOGIC_VECTOR(31 downto 0);
		signal VIC_STB_I          : STD_LOGIC;
		signal VIC_ACK_O          : STD_LOGIC;
		signal VIC_HALT_O         : STD_LOGIC;
		signal VIC_ERR_O          : STD_LOGIC;
		signal INT_LINES          : STD_LOGIC_VECTOR(31 downto 0);
		signal INT_LINES_ACK      : STD_LOGIC_VECTOR(31 downto 0);


	-- Logarithm duales ---------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
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


	-- STORM SYSTEM TOP ENTITY --------------------------------------------------------
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

	-- Altera Megawizzard PLL ---------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component SYSTEM_PLL
			port	(
						inclk0        : in  STD_LOGIC; -- external clock input
						c0	          : out STD_LOGIC; -- system clock
						c1	          : out STD_LOGIC; -- external mem clock for internal use
						c2	          : out STD_LOGIC; -- external mem clock, -3ns phase shifted
						locked        : out STD_LOGIC  -- clock stable
					);
		end component;

	-- Reset Protector ----------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component RST_PROTECT
			generic	(
						TRIGGER_VAL   : natural := 50000000; -- trigger in sys clocks
						LOW_ACT_RST   : boolean := TRUE      -- valid reset level
					);
			port	(
						-- Interface --
						MAIN_CLK_I    : in  STD_LOGIC; -- system master clock
						EXT_RST_I     : in  STD_LOGIC; -- external reset input
						SYS_RST_O     : out STD_LOGIC  -- system master reset
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

	-- Simple general purpose UART ----------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component MINI_UART
			generic	(
						BRDIVISOR : integer range 0 to 65535
					);
			port	(
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

						-- Terminal signals --
						IntTx_O       : out STD_LOGIC; -- Transmit interrupt: indicate waiting for Byte
						IntRx_O       : out STD_LOGIC; -- Receive interrupt: indicate Byte received
						BR_Clk_I      : in  STD_LOGIC; -- Clock used for Transmit/Receive
						TxD_PAD_O     : out STD_LOGIC; -- Tx RS232 Line
						RxD_PAD_I     : in  STD_LOGIC  -- Rx RS232 Line
					);
		end component;
	
	-- Bootloader ROM -----------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component BOOT_ROM_FILE
			generic	(
						MEM_SIZE      : natural; -- memory cells
						LOG2_MEM_SIZE : natural; -- log2(memory cells)
						OUTPUT_GATE   : boolean; -- use output gate
						INIT_IMAGE_ID : string   -- init image
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
						WB_ERR_O      : out STD_LOGIC; -- abnormal cycle termination

						-- IO Port --
						GP_IO_O       : out STD_LOGIC_VECTOR(31 downto 00);
						GP_IO_I       : in  STD_LOGIC_VECTOR(31 downto 00);

						-- Input Change INT --
						IO_IRQ_O      : out STD_LOGIC
				 );
		end component;

	-- SPI Controller -----------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component spi_top
			port (
						-- Wishbone Bus --
						wb_clk_i      : in  STD_LOGIC;
						wb_rst_i      : in  STD_LOGIC;
						wb_adr_i      : in  STD_LOGIC_VECTOR(04 downto 0);
						wb_dat_i      : in  STD_LOGIC_VECTOR(31 downto 0);
						wb_dat_o      : out STD_LOGIC_VECTOR(31 downto 0);
						wb_sel_i      : in  STD_LOGIC_VECTOR(03 downto 0);
						wb_we_i       : in  STD_LOGIC;
						wb_stb_i      : in  STD_LOGIC;
						wb_cyc_i      : in  STD_LOGIC;
						wb_ack_o      : out STD_LOGIC;
						wb_err_o      : out STD_LOGIC;
						wb_int_o      : out STD_LOGIC;

						-- SPI Signals --
						ss_pad_o      : out STD_LOGIC_VECTOR(07 downto 0);
						sclk_pad_o    : out STD_LOGIC;
						mosi_pad_o    : out STD_LOGIC;
						miso_pad_i    : in  STD_LOGIC
				 );
		end component;

	-- I²C Controller -----------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component i2c_master_top
			generic (
						ARST_LVL      : std_logic := '0'                  -- asynchronous reset level
					);
			port (
						-- Wishbone Bus --
						wb_clk_i      : in  std_logic;                    -- master clock input
						wb_rst_i      : in  std_logic := '0';             -- synchronous active high reset
						arst_i        : in  std_logic := not ARST_LVL;    -- asynchronous reset
						wb_adr_i      : in  std_logic_vector(2 downto 0); -- lower address bits
						wb_dat_i      : in  std_logic_vector(7 downto 0); -- Databus input
						wb_dat_o      : out std_logic_vector(7 downto 0); -- Databus output
						wb_we_i       : in  std_logic;                    -- Write enable input
						wb_stb_i      : in  std_logic;                    -- Strobe signals / core select signal
						wb_cyc_i      : in  std_logic;                    -- Valid bus cycle input
						wb_ack_o      : out std_logic;                    -- Bus cycle acknowledge output
						wb_inta_o     : out std_logic;                    -- interrupt request output signal
						
						-- I²C lines --
						scl_pad_i     : in  std_logic;                    -- i2c clock line input
						scl_pad_o     : out std_logic;                    -- i2c clock line output
						scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low
						sda_pad_i     : in  std_logic;                    -- i2c data line input
						sda_pad_o     : out std_logic;                    -- i2c data line output
						sda_padoen_o  : out std_logic                     -- i2c data line output enable, active low
					);
		end component;

	-- Seven-Segment Controller -------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component SEVEN_SEG_CTRL
			generic	(
						HIGH_ACTIVE_OUTPUT : boolean := FALSE
					);
			port (
						-- Wishbone Bus --
						WB_CLK_I      : in  STD_LOGIC; -- master clock
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
						WB_ERR_O      : out STD_LOGIC; -- abnormal cycle termination

						-- HEX-Display output --
						HEX_O         : out STD_LOGIC_VECTOR(27 downto 00)
				 );
		end component;

	-- System Timer -------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component TIMER
			port (
						-- Wishbone Bus --
						WB_CLK_I      : in  STD_LOGIC; -- memory master clock
						WB_RST_I      : in  STD_LOGIC; -- high active sync reset
						WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
						WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
						WB_ADR_I      : in  STD_LOGIC_VECTOR(01 downto 0); -- adr in
						WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
						WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
						WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
						WB_WE_I       : in  STD_LOGIC; -- write enable
						WB_STB_I      : in  STD_LOGIC; -- valid cycle
						WB_ACK_O      : out STD_LOGIC; -- acknowledge
						WB_HALT_O     : out STD_LOGIC; -- throttle master
						WB_ERR_O      : out STD_LOGIC; -- abnormal termination

						-- Match Interrupt --
						INT_O         : out STD_LOGIC
				 );
		end component;

	-- PS2 Keyboard Interface ---------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component ps2_wb
			port (
						-- Wishbone Bus --
						wb_clk_i      : in  std_logic;
						wb_rst_i      : in  std_logic;
						wb_dat_i      : in  std_logic_vector(7 downto 0);
						wb_dat_o      : out std_logic_vector(7 downto 0);
						wb_adr_i      : in  std_logic_vector(0 downto 0);
						wb_stb_i      : in  std_logic;
						wb_we_i       : in  std_logic;
						wb_ack_o      : out std_logic;

						-- IRQ output --
						irq_o         : out std_logic;

						-- PS2 signals --
						ps2_clk       : inout std_logic;
						ps2_dat       : inout std_logic
				 );
		end component;

	-- PWM Controller -----------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component PWM_CTRL
			port (
						-- Wishbone Bus --
						WB_CLK_I      : in  STD_LOGIC; -- memory master clock
						WB_RST_I      : in  STD_LOGIC; -- high active sync reset
						WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
						WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
						WB_ADR_I      : in  STD_LOGIC; -- adr in
						WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
						WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
						WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
						WB_WE_I       : in  STD_LOGIC; -- write enable
						WB_STB_I      : in  STD_LOGIC; -- valid cycle
						WB_ACK_O      : out STD_LOGIC; -- acknowledge
						WB_HALT_O     : out STD_LOGIC; -- throttle master
						WB_ERR_O      : out STD_LOGIC; -- abnormal termination

						-- PWM Port --
						PWM_O         : out STD_LOGIC_VECTOR(07 downto 0)
				 );
		end component;
		

	-- Vector Interrupt Controller ----------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component VIC
			port (
						-- Wishbone Bus --
						WB_CLK_I      : in  STD_LOGIC; -- memory master clock
						WB_RST_I      : in  STD_LOGIC; -- high active sync reset
						WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
						WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
						WB_ADR_I      : in  STD_LOGIC_VECTOR(05 downto 0); -- adr in (word boundary)
						WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
						WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
						WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
						WB_WE_I       : in  STD_LOGIC; -- write enable
						WB_STB_I      : in  STD_LOGIC; -- valid cycle
						WB_ACK_O      : out STD_LOGIC; -- acknowledge
						WB_HALT_O     : out STD_LOGIC; -- throttle master
						WB_ERR_O      : out STD_LOGIC; -- abnormal termination

						-- INT Lines & ACK --
						IRQ_LINES_I   : in  STD_LOGIC_VECTOR(31 downto 0);
						ACK_LINES_O   : out STD_LOGIC_VECTOR(31 downto 0);

						-- Global FIQ/IRQ signal to STORM --
						STORM_IRQ_O   : out STD_LOGIC;
						STORM_FIQ_O   : out STD_LOGIC
				 );
		end component;

begin

-- #################################################################################################################################
-- ###  STORM CORE PROCESSOR                                                                                                     ###
-- #################################################################################################################################

	-- Clock Manager (PLL) ---------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		SYSCON_CLK: SYSTEM_PLL
			port map (
						inclk0 => CLK_I,     -- external clock input
						c0     => MAIN_CLK,  -- system clock
						c1     => XMEM_CLK,  -- ext mem clock for internal use
						c2     => XMEMD_CLK, -- ext mem clock, -3ns phase shifted
						locked => CLK_LOCK   -- clock stable
					);

		CLOCK_DIVIDER: process(CLK_I)
		begin
			if rising_edge(CLK_I) then
				CLK_DIV <= Std_Logic_Vector(unsigned(CLK_DIV)+1);
			end if;
		end process CLOCK_DIVIDER;

--		-- FOR SIMULATION --
--		CLK_LOCK  <= '1';
--		MAIN_CLK  <= CLK_I; -- system clock for xilinx isim
--		XMEM_CLK  <= CLK_DIV(0);
--		XMEMD_CLK <= CLK_DIV(0);



	-- Reset Manager ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		SYSCON_RST: RST_PROTECT
			generic	map (
							TRIGGER_VAL => RST_RTIGGER_C, -- trigger in sys clocks
							LOW_ACT_RST => LOW_ACTIVE_RST_C -- valid reset level
						)
			port map (
						MAIN_CLK_I => MAIN_CLK,
						EXT_RST_I  => RST_I,
						SYS_RST_O  => SAVE_RST
					 );

		MAIN_RST   <= SAVE_RST or (not CLK_LOCK); -- system reset
		MAIN_RST_N <= not MAIN_RST;

		-- FOR SIMULATION --
--		SAVE_RST <= not RST_I;



	-- STORM CORE PROCESSOR --------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		STORM_TOP_INST: STORM_TOP
			generic map (
								I_CACHE_PAGES     => I_CACHE_PAGES_C,     -- number of pages in I cache
								I_CACHE_PAGE_SIZE => I_CACHE_PAGE_SIZE_C, -- page size in I cache
								D_CACHE_PAGES     => D_CACHE_PAGES_C,     -- number of pages in D cache
								D_CACHE_PAGE_SIZE => D_CACHE_PAGE_SIZE_C, -- page size in D cache
								BOOT_VECTOR       => BOOT_VECTOR_C,       -- startup boot address
								IO_UC_BEGIN       => IO_AREA_BEGIN,       -- begin of uncachable IO area
								IO_UC_END         => IO_AREA_END          -- end of uncachable IO area
						)
			port map (
								-- Global Control --
								CORE_CLK_I        => MAIN_CLK,        -- core clock input
								RST_I             => MAIN_RST,        -- global reset input
								IO_PORT_O         => SYS_CTRL_O,      -- direct output
								IO_PORT_I         => SYS_CTRL_I,      -- direct input

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
								WB_ERR_I          => CORE_WB_ERR_I,   -- abnormal termination
								WB_HALT_I         => CORE_WB_HALT_I,  -- halt request

								-- Interrupt Request Lines --
								IRQ_I             => STORM_IRQ,       -- interrupt request
								FIQ_I             => STORM_FIQ        -- fast interrupt request
					);

			-- Status LEDs --
			LED_BAR_O   <= SYS_CTRL_O(07 downto 0);

			-- Boot config --
			SYS_CTRL_I(00)           <= START_I;
			SYS_CTRL_I(04 downto 01) <= BOOT_CONFIG_I;
			SYS_CTRL_I(15 downto 05) <= (others => '0');



-- #################################################################################################################################
-- ###  WISHBONE FABRIC                                                                                                          ###
-- #################################################################################################################################

	-- Valid Transfer Signal Terminal ----------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		INT_MEM_STB_I     <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= INT_MEM_BASE_C)    and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(INT_MEM_BASE_C)    + INT_MEM_SIZE_C)))    else '0';
		BOOT_ROM_STB_I    <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= BOOT_ROM_BASE_C)   and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(BOOT_ROM_BASE_C)   + BOOT_ROM_SIZE_C)))   else '0';
		SYS_TIMER0_STB_I  <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= SYS_TIMER0_BASE_C) and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(SYS_TIMER0_BASE_C) + SYS_TIMER0_SIZE_C))) else '0';
		GP_IO0_CTRL_STB_I <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= GP_IO0_BASE_C)     and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(GP_IO0_BASE_C)     + GP_IO0_SIZE_C)))     else '0';
		UART0_STB_I       <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= UART0_BASE_C)      and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(UART0_BASE_C)      + UART0_SIZE_C)))      else '0';
		SPI0_CTRL_STB_I   <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= SPI0_CTRL_BASE_C)  and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(SPI0_CTRL_BASE_C)  + SPI0_CTRL_SIZE_C)))  else '0';
		I2C0_CTRL_STB_I   <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= I2C0_CTRL_BASE_C)  and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(I2C0_CTRL_BASE_C)  + I2C0_CTRL_SIZE_C)))  else '0';
		PWM_CTRL0_STB_I   <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= PWM_CTRL0_BASE_C)  and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(PWM_CTRL0_BASE_C)  + PWM_CTRL0_SIZE_C)))  else '0';
		VIC_STB_I         <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= VIC_BASE_C)        and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(VIC_BASE_C)        + VIC_SIZE_C)))        else '0';


	-- Read-Back Data Selector Terminal --------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_DATA_I <=
			INT_MEM_DATA_O     when (INT_MEM_STB_I     = '1') else
			BOOT_ROM_DATA_O    when (BOOT_ROM_STB_I    = '1') else
			SYS_TIMER0_DATA_O  when (SYS_TIMER0_STB_I  = '1') else
			GP_IO0_CTRL_DATA_O when (GP_IO0_CTRL_STB_I = '1') else
			UART0_DATA_O       when (UART0_STB_I       = '1') else
			SPI0_CTRL_DATA_O   when (SPI0_CTRL_STB_I   = '1') else
			I2C0_CTRL_DATA_O   when (I2C0_CTRL_STB_I   = '1') else
			PWM_CTRL0_DATA_O   when (PWM_CTRL0_STB_I   = '1') else
			VIC_DATA_O         when (VIC_STB_I         = '1') else
			x"00000000";


	-- Acknowledge Terminal --------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_ACK_I  <= INT_MEM_ACK_O      or
						  BOOT_ROM_ACK_O     or
						  SYS_TIMER0_ACK_O   or
						  GP_IO0_CTRL_ACK_O  or
						  UART0_ACK_O        or
						  SPI0_CTRL_ACK_O    or
						  I2C0_CTRL_ACK_O    or
						  PWM_CTRL0_ACK_O    or
						  VIC_ACK_O          or
						  '0';


	-- Abnormal Termination Terminal -----------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_ERR_I  <= INT_MEM_ERR_O      or
						  BOOT_ROM_ERR_O     or
						  SYS_TIMER0_ERR_O   or
						  GP_IO0_CTRL_ERR_O  or
						  UART0_ERR_O        or
						  SPI0_CTRL_ERR_O    or
						  I2C0_CTRL_ERR_O    or
						  PWM_CTRL0_ERR_O    or
						  VIC_ERR_O          or
						  '0';


	-- Halt Terminal ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_HALT_I <= INT_MEM_HALT_O     or
						  BOOT_ROM_HALT_O    or
						  SYS_TIMER0_HALT_O  or
						  GP_IO0_CTRL_HALT_O or
						  UART0_HALT_O       or
						  SPI0_CTRL_HALT_O   or
						  I2C0_CTRL_HALT_O   or
						  PWM_CTRL0_HALT_O   or
						  VIC_HALT_O         or
						  '0';



-- #################################################################################################################################
-- ###  SYSTEM COMPONENTS                                                                                                        ###
-- #################################################################################################################################

	-- Internal Working Memory -----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		INTERNAL_SRAM_MEMORY: MEMORY
			generic map	(
						MEM_SIZE      => INT_MEM_SIZE_C/4,       -- memory size in 32-bit cells
						LOG2_MEM_SIZE => log2(INT_MEM_SIZE_C/4), -- log2 memory size in 32-bit cells
						OUTPUT_GATE   => USE_OUTPUT_GATES_C      -- output and-gate, might be necessary for some bus systems
						)
			port map (
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



	-- Boot ROM Memory -------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		BOOT_MEMORY: BOOT_ROM_FILE
			generic map (
							MEM_SIZE      => BOOT_ROM_SIZE_C/4, -- memory size in 32-bit words
							LOG2_MEM_SIZE => log2(BOOT_ROM_SIZE_C/4), -- log2 memory size in words
							OUTPUT_GATE   => USE_OUTPUT_GATES_C, -- use output gate
							INIT_IMAGE_ID => BOOT_IMAGE_C -- init image
						)
			port map (
						-- Wishbone Bus --
						WB_CLK_I      => MAIN_CLK,
						WB_RST_I      => MAIN_RST,
						WB_CTI_I      => CORE_WB_CTI_O,
						WB_TGC_I      => CORE_WB_TGC_O,
						WB_ADR_I      => CORE_WB_ADR_O(log2(BOOT_ROM_SIZE_C/4)+1 downto 2), -- word boundary
						WB_DATA_I     => CORE_WB_DATA_O,
						WB_DATA_O     => BOOT_ROM_DATA_O,
						WB_SEL_I      => CORE_WB_SEL_O,
						WB_WE_I       => CORE_WB_WE_O,
						WB_STB_I      => BOOT_ROM_STB_I,
						WB_ACK_O      => BOOT_ROM_ACK_O,
						WB_HALT_O     => BOOT_ROM_HALT_O,
						WB_ERR_O      => BOOT_ROM_ERR_O
					);


	
	-- General Purpose IO 0 --------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		IO_CONTROLLER_0: GP_IO_CTRL
			port map (
						-- Wishbone Bus --
						WB_CLK_I      => MAIN_CLK,
						WB_RST_I      => MAIN_RST,
						WB_CTI_I      => CORE_WB_CTI_O,
						WB_TGC_I      => CORE_WB_TGC_O,
						WB_ADR_I      => CORE_WB_ADR_O(2),
						WB_DATA_I     => CORE_WB_DATA_O,
						WB_DATA_O     => GP_IO0_CTRL_DATA_O,
						WB_SEL_I      => CORE_WB_SEL_O,
						WB_WE_I       => CORE_WB_WE_O,
						WB_STB_I      => GP_IO0_CTRL_STB_I,
						WB_ACK_O      => GP_IO0_CTRL_ACK_O,
						WB_HALT_O     => GP_IO0_CTRL_HALT_O,
						WB_ERR_O      => GP_IO0_CTRL_ERR_O,

						-- IO Port --
						GP_IO_O       => GP_IO0_TEMP_O,
						GP_IO_I       => GP_IO0_TEMP_I,

						-- Input Change INT --
						IO_IRQ_O      => GP_IO0_IRQ
				 );

			-- Outputs --
			GP_OUTPUT_O <= GP_IO0_TEMP_O(07 downto 0);

			-- Inputs --
			GP_IO0_TEMP_I(07 downto 00) <= GP_INPUT_I;
			GP_IO0_TEMP_I(31 downto 08) <= (others => '0'); -- unused



	-- General Purpose UART 0 ------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		GP_UART_0: MINI_UART
			generic map	(
							BRDIVISOR => UART0_BAUD_VAL_C
						)
			port map (
						-- Wishbone Bus --
						WB_CLK_I      => MAIN_CLK,
						WB_RST_I      => MAIN_RST,
						WB_CTI_I      => CORE_WB_CTI_O,
						WB_TGC_I      => CORE_WB_TGC_O,
						WB_ADR_I      => CORE_WB_ADR_O(2),
						WB_DATA_I     => CORE_WB_DATA_O,
						WB_DATA_O     => UART0_DATA_O,
						WB_SEL_I      => CORE_WB_SEL_O,
						WB_WE_I       => CORE_WB_WE_O,
						WB_STB_I      => UART0_STB_I,
						WB_ACK_O      => UART0_ACK_O,
						WB_HALT_O     => UART0_HALT_O,
						WB_ERR_O      => UART0_ERR_O,

						-- Terminal signals --
						IntTx_O       => UART0_TX_IRQ,
						IntRx_O       => UART0_RX_IRQ,
						BR_Clk_I      => MAIN_CLK,
						TxD_PAD_O     => UART0_TXD_O,
						RxD_PAD_I     => UART0_RXD_I
					);



	-- System Timer 0 --------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		SYSTEM_TIMER_0: TIMER
			port map (
						-- Wishbone Bus --
						WB_CLK_I      => MAIN_CLK,
						WB_RST_I      => MAIN_RST,
						WB_CTI_I      => CORE_WB_CTI_O,
						WB_TGC_I      => CORE_WB_TGC_O,
						WB_ADR_I      => CORE_WB_ADR_O(3 downto 2),
						WB_DATA_I     => CORE_WB_DATA_O,
						WB_DATA_O     => SYS_TIMER0_DATA_O,
						WB_SEL_I      => CORE_WB_SEL_O,
						WB_WE_I       => CORE_WB_WE_O,
						WB_STB_I      => SYS_TIMER0_STB_I,
						WB_ACK_O      => SYS_TIMER0_ACK_O,
						WB_HALT_O     => SYS_TIMER0_HALT_O,
						WB_ERR_O      => SYS_TIMER0_ERR_O,

						-- Match Interrupt --
						INT_O         => SYS_TIMER0_IRQ
				 );



	-- SPI Controller 0 ------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		SPI_CTRL_0: spi_top
			port map (
						-- Wishbone Bus --
						wb_clk_i      => MAIN_CLK,
						wb_rst_i      => MAIN_RST,
						wb_adr_i      => CORE_WB_ADR_O(log2(SPI0_CTRL_SIZE_C/4)+1 downto 0),
						wb_dat_i      => CORE_WB_DATA_O,
						wb_dat_o      => SPI0_CTRL_DATA_O,
						wb_sel_i      => CORE_WB_SEL_O,
						wb_we_i       => CORE_WB_WE_O,
						wb_stb_i      => SPI0_CTRL_STB_I,
						wb_cyc_i      => CORE_WB_CYC_O,
						wb_ack_o      => SPI0_CTRL_ACK_O,
						wb_err_o      => SPI0_CTRL_ERR_O,
						wb_int_o      => SPI0_CTRL_IRQ,

						-- SPI Signals --
						ss_pad_o      => SPI_CS_INT,
						sclk_pad_o    => SPI_CLK_INT,
						mosi_pad_o    => SPI_MOSI_INT,
						miso_pad_i    => SPI_MISO_INT
					);

		-- HALT --
		SPI0_CTRL_HALT_O <= '0';

		-- SPI Port 0 (devices 0,1,2) --
		SPI_P0_CLK_O  <= SPI_CLK_INT;
		MISO_PORT_0   <= '0' when (SPI_CS_INT(2 downto 0) = "111") else SPI_P0_MISO_I;
		SPI_P0_MOSI_O <= SPI_MOSI_INT;
		SPI_P0_CS_O   <= SPI_CS_INT(2 downto 0);

		-- SPI Port 1 (devices 3,4,5) --
		SPI_P1_CLK_O  <= SPI_CLK_INT;
		MISO_PORT_1   <= '0' when (SPI_CS_INT(5 downto 3) = "111") else SPI_P1_MISO_I;
		SPI_P1_MOSI_O <= SPI_MOSI_INT;
		SPI_P1_CS_O   <= SPI_CS_INT(5 downto 3);

		-- SPI Port 2 (devices 6,7) --
		SPI_P2_CLK_O  <= SPI_CLK_INT;
		MISO_PORT_2   <= '0' when (SPI_CS_INT(7 downto 6) =  "11") else SPI_P2_MISO_I;
		SPI_P2_MOSI_O <= SPI_MOSI_INT;
		SPI_P2_CS_O   <= SPI_CS_INT(7 downto 6);

		-- SPI Port Readback --
		SPI_MISO_INT <= MISO_PORT_0 or MISO_PORT_1 or MISO_PORT_2;



	-- I²C Controller 0 ------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		I2C_CONTROLLER_0: i2c_master_top
			generic map (
							ARST_LVL => '1' -- asynchronous reset level
						)
			port map (
						-- Wishbone Bus --
						wb_clk_i      => MAIN_CLK, -- master clock input
						wb_rst_i      => MAIN_RST, -- synchronous active high reset
						arst_i        => '0',      -- asynchronous reset
						wb_adr_i      => CORE_WB_ADR_O(log2(I2C0_CTRL_SIZE_C/4)+1 downto 2), -- lower address bits
						wb_dat_i      => CORE_WB_DATA_O(07 downto 0), -- Databus input (lowest 8 bit)
						wb_dat_o      => I2C_DATA_TMP, -- Databus output
						wb_we_i       => CORE_WB_WE_O, -- Write enable input
						wb_stb_i      => I2C0_CTRL_STB_I, -- Strobe signals / core select signal
						wb_cyc_i      => CORE_WB_CYC_O, -- Valid bus cycle input
						wb_ack_o      => I2C0_CTRL_ACK_O, -- Bus cycle acknowledge output
						wb_inta_o     => I2C0_CTRL_IRQ, -- interrupt request output signal
						
						-- I²C lines --
						scl_pad_i     => SCL_PAD_I, -- i2c clock line input
						scl_pad_o     => SCL_PAD_O, -- i2c clock line output
						scl_padoen_o  => SCL_PADOE, -- i2c clock line output enable, active low
						sda_pad_i     => SDA_PAD_I, -- i2c data line input
						sda_pad_o     => SDA_PAD_O, -- i2c data line output
						sda_padoen_o  => SDA_PADOE  -- i2c data line output enable, active low
					);

		-- Data Width Adaption --
		I2C0_CTRL_DATA_O <= x"000000" & I2C_DATA_TMP;

		-- IO Buffer --
		I2C_SCL_IO <= SCL_PAD_O when (SCL_PADOE = '0') else 'Z';
		I2C_SDA_IO <= SDA_PAD_O when (SDA_PADOE = '0') else 'Z';
		SCL_PAD_I  <= I2C_SCL_IO;
		SDA_PAD_I  <= I2C_SDA_IO;

		-- Halt / Error --
		I2C0_CTRL_HALT_O <= '0'; -- no throttle -> full speed
		I2C0_CTRL_ERR_O  <= '0'; -- nothing can go wrong - never ever!



	-- PWM Controller 0 ------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		PWM_CONTROLLER_0: PWM_CTRL
			port map (
						-- Wishbone Bus --
						WB_CLK_I      => MAIN_CLK, -- memory master clock
						WB_RST_I      => MAIN_RST, -- high active sync reset
						WB_CTI_I      => CORE_WB_CTI_O,    -- cycle indentifier
						WB_TGC_I      => CORE_WB_TGC_O,    -- cycle tag
						WB_ADR_I      => CORE_WB_ADR_O(2), -- adr in
						WB_DATA_I     => CORE_WB_DATA_O,   -- write data
						WB_DATA_O     => PWM_CTRL0_DATA_O, -- read data
						WB_SEL_I      => CORE_WB_SEL_O,    -- data quantity
						WB_WE_I       => CORE_WB_WE_O,     -- write enable
						WB_STB_I      => PWM_CTRL0_STB_I,  -- valid cycle
						WB_ACK_O      => PWM_CTRL0_ACK_O,  -- acknowledge
						WB_HALT_O     => PWM_CTRL0_HALT_O, -- throttle master
						WB_ERR_O      => PWM_CTRL0_ERR_O,   -- abnormal termination

						-- PWM Port --
						PWM_O         => PWM0_PORT_O
					);


	-- Vector Interrupt Controller -------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		VECTOR_INTERRUPT_CONTROLLER: VIC
			port map (
						-- Wishbone Bus --
						WB_CLK_I      => MAIN_CLK,
						WB_RST_I      => MAIN_RST,
						WB_CTI_I      => CORE_WB_CTI_O,
						WB_TGC_I      => CORE_WB_TGC_O,
						WB_ADR_I      => CORE_WB_ADR_O(log2(VIC_SIZE_C/4)+1 downto 2),
						WB_DATA_I     => CORE_WB_DATA_O,
						WB_DATA_O     => VIC_DATA_O,
						WB_SEL_I      => CORE_WB_SEL_O,
						WB_WE_I       => CORE_WB_WE_O,
						WB_STB_I      => VIC_STB_I,
						WB_ACK_O      => VIC_ACK_O,
						WB_HALT_O     => VIC_HALT_O,
						WB_ERR_O      => VIC_ERR_O,

						-- INT Lines & ACK --
						IRQ_LINES_I   => INT_LINES,
						ACK_LINES_O   => INT_LINES_ACK,

						-- Global IRQ/FIQ signal to STORM --
						STORM_IRQ_O   => STORM_IRQ,
						STORM_FIQ_O   => STORM_FIQ
				 );

			-- IRQ/FIQ Lines --
			INT_LINES(00) <= SYS_TIMER0_IRQ;
			INT_LINES(01) <= GP_IO0_IRQ;
			INT_LINES(02) <= UART0_TX_IRQ;
			INT_LINES(03) <= UART0_RX_IRQ;
			INT_LINES(04) <= SPI0_CTRL_IRQ;
			INT_LINES(05) <= I2C0_CTRL_IRQ;
			INT_LINES(31 downto 06) <= (others => '0'); -- unused



end Structure;