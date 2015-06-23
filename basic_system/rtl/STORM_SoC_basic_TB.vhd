-- #######################################################
-- #     < STORM System on Chip by Stephan Nolting >     #
-- # *************************************************** #
-- #                 STORM SoC TESTBENCH                 #
-- # *************************************************** #
-- # Version 1.0, 06.03.2012                             #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity STORM_SoC_basic_TB is
end STORM_SoC_basic_TB;

architecture Structure of STORM_SoC_basic_TB is

	-- Global signals ----------------------------------------------------
	-- ----------------------------------------------------------------------
		signal CLK, RST   : STD_LOGIC := '1';
		signal SCL, SDA   : STD_LOGIC;
		signal IRQ        : STD_LOGIC;

		signal SDRAM_CLK  : STD_LOGIC;
		signal SDRAM_CASN : STD_LOGIC;
		signal SDRAM_CKE  : STD_LOGIC;
		signal SDRAM_RASN : STD_LOGIC;
		signal SDRAM_CSN  : STD_LOGIC;
		signal SDRAM_WEN  : STD_LOGIC;
		signal SDRAM_DQM  : STD_LOGIC_VECTOR(01 downto 0);
		signal SDRAM_BA   : STD_LOGIC_VECTOR(01 downto 0);
		signal SDRAM_ADR  : STD_LOGIC_VECTOR(11 downto 0);
        signal SDRAM_DAT  : STD_LOGIC_VECTOR(15 downto 0);

	-- STORM SoC TOP ENTITY ----------------------------------------------
	-- ----------------------------------------------------------------------
		component STORM_SoC_basic
		port (
			-- Global Control --
			CLK_I         : in    STD_LOGIC;
			RST_I         : in    STD_LOGIC;

			-- General purpose (debug) UART --
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

--			-- SDRAM Interface --
--			SDRAM_CLK_O   : out   STD_LOGIC;
--			SDRAM_CSN_O   : out   STD_LOGIC;
--			SDRAM_CKE_O   : out   STD_LOGIC;
--			SDRAM_RASN_O  : out   STD_LOGIC;
--			SDRAM_CASN_O  : out   STD_LOGIC;
--			SDRAM_WEN_O   : out   STD_LOGIC;
--			SDRAM_DQM_O   : out   STD_LOGIC_VECTOR(01 downto 0);
--			SDRAM_BA_O    : out   STD_LOGIC_VECTOR(01 downto 0);
--			SDRAM_ADR_O   : out   STD_LOGIC_VECTOR(11 downto 0);
--			SDRAM_DAT_IO  : inout STD_LOGIC_VECTOR(15 downto 0)
			 );
		end component;


begin

	-- Clock/Reset Generator ---------------------------------------------
	-- ----------------------------------------------------------------------
		CLK <= not CLK after 5 ns;
		RST <= '0', '1' after 200 ns;



	-- STORM SoC TOP ENTITY ----------------------------------------------
	-- ----------------------------------------------------------------------
		UUT: STORM_SoC_basic
		port map (
			-- Global Control --
			CLK_I         => CLK,
			RST_I         => RST,

			-- General purpose (debug) UART --
			UART0_RXD_I   => '1',
			UART0_TXD_O   => open,

			-- System Control --
			START_I       => '0',
			BOOT_CONFIG_I => "0000",
			LED_BAR_O     => open,

			-- GP Input Pins --
			GP_INPUT_I    => x"00",

			-- GP Output Pins --
			GP_OUTPUT_O   => open,

			-- I²C Port --
			I2C_SCL_IO    => open,
			I2C_SDA_IO    => open,

			-- SPI Port 0 [3 devices] --
			SPI_P0_CLK_O  => open,
			SPI_P0_MISO_I => '0',
			SPI_P0_MOSI_O => open,
			SPI_P0_CS_O   => open,

			-- SPI Port 1 [3 devices] --
			SPI_P1_CLK_O  => open,
			SPI_P1_MISO_I => '0',
			SPI_P1_MOSI_O => open,
			SPI_P1_CS_O   => open,

			-- SPI Port 2 [2 devices] --
			SPI_P2_CLK_O  => open,
			SPI_P2_MISO_I => '0',
			SPI_P2_MOSI_O => open,
			SPI_P2_CS_O   => open,

			-- PWM Port 0 --
			PWM0_PORT_O   => open

--			-- SDRAM Interface --
--			SDRAM_CLK_O   : out   STD_LOGIC;
--			SDRAM_CSN_O   : out   STD_LOGIC;
--			SDRAM_CKE_O   : out   STD_LOGIC;
--			SDRAM_RASN_O  : out   STD_LOGIC;
--			SDRAM_CASN_O  : out   STD_LOGIC;
--			SDRAM_WEN_O   : out   STD_LOGIC;
--			SDRAM_DQM_O   : out   STD_LOGIC_VECTOR(01 downto 0);
--			SDRAM_BA_O    : out   STD_LOGIC_VECTOR(01 downto 0);
--			SDRAM_ADR_O   : out   STD_LOGIC_VECTOR(11 downto 0);
--			SDRAM_DAT_IO  : inout STD_LOGIC_VECTOR(15 downto 0)
				);
		
		SCL <= 'H';
		SDA <= 'H';



end Structure;