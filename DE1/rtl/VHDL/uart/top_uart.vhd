-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity 	TOP_UART is
	port(

    -- Clocks
    CLOCK_27,                                      -- 27 MHz
    CLOCK_50,                                      -- 50 MHz
    EXT_CLOCK : in std_logic;                      -- External Clock

    -- Buttons and switches
    KEY : in std_logic_vector(3 downto 0);         -- Push buttons
    SW : in std_logic_vector(9 downto 0);          -- Switches

    -- LED displays
    HEX0, HEX1, HEX2, HEX3                         -- 7-segment displays
			: out std_logic_vector(6 downto 0);
    LEDG : out std_logic_vector(7 downto 0);       -- Green LEDs
    LEDR : out std_logic_vector(9 downto 0);       -- Red LEDs

    -- RS-232 interface
    UART_TXD : out std_logic;                      -- UART transmitter   
    UART_RXD : in std_logic;                       -- UART receiver

    -- IRDA interface

    -- IRDA_TXD : out std_logic;                      -- IRDA Transmitter
    IRDA_RXD : in std_logic;                       -- IRDA Receiver

    -- SDRAM
    DRAM_DQ : inout std_logic_vector(15 downto 0); -- Data Bus
    DRAM_ADDR : out std_logic_vector(11 downto 0); -- Address Bus    
    DRAM_LDQM,                                     -- Low-byte Data Mask 
    DRAM_UDQM,                                     -- High-byte Data Mask
    DRAM_WE_N,                                     -- Write Enable
    DRAM_CAS_N,                                    -- Column Address Strobe
    DRAM_RAS_N,                                    -- Row Address Strobe
    DRAM_CS_N,                                     -- Chip Select
    DRAM_BA_0,                                     -- Bank Address 0
    DRAM_BA_1,                                     -- Bank Address 0
    DRAM_CLK,                                      -- Clock
    DRAM_CKE : out std_logic;                      -- Clock Enable

    -- FLASH
    FL_DQ : inout std_logic_vector(7 downto 0);      -- Data bus
    FL_ADDR : out std_logic_vector(21 downto 0);     -- Address bus
    FL_WE_N,                                         -- Write Enable
    FL_RST_N,                                        -- Reset
    FL_OE_N,                                         -- Output Enable
    FL_CE_N : out std_logic;                         -- Chip Enable

    -- SRAM
    SRAM_DQ : inout std_logic_vector(15 downto 0); -- Data bus 16 Bits
    SRAM_ADDR : out std_logic_vector(17 downto 0); -- Address bus 18 Bits
    SRAM_UB_N,                                     -- High-byte Data Mask 
    SRAM_LB_N,                                     -- Low-byte Data Mask 
    SRAM_WE_N,                                     -- Write Enable
    SRAM_CE_N,                                     -- Chip Enable
    SRAM_OE_N : out std_logic;                     -- Output Enable

    -- SD card interface
    SD_DAT : in std_logic;      -- SD Card Data      SD pin 7 "DAT 0/DataOut"
    SD_DAT3 : out std_logic;    -- SD Card Data 3    SD pin 1 "DAT 3/nCS"
    SD_CMD : out std_logic;     -- SD Card Command   SD pin 2 "CMD/DataIn"
    SD_CLK : out std_logic;     -- SD Card Clock     SD pin 5 "CLK"

    -- USB JTAG link
    TDI,                        -- CPLD -> FPGA (data in)
    TCK,                        -- CPLD -> FPGA (clk)
    TCS : in std_logic;         -- CPLD -> FPGA (CS)
    TDO : out std_logic;        -- FPGA -> CPLD (data out)

    -- I2C bus
    I2C_SDAT : inout std_logic; -- I2C Data
    I2C_SCLK : out std_logic;   -- I2C Clock

    -- PS/2 port
    PS2_DAT,                    -- Data
    PS2_CLK : inout std_logic;     -- Clock

    -- VGA output
    VGA_HS,                                             -- H_SYNC
    VGA_VS : out std_logic;                             -- SYNC
    VGA_R,                                              -- Red[3:0]
    VGA_G,                                              -- Green[3:0]
    VGA_B : out std_logic_vector(3 downto 0);           -- Blue[3:0]
   
    -- Audio CODEC
    AUD_ADCLRCK : inout std_logic;                      -- ADC LR Clock
    AUD_ADCDAT : in std_logic;                          -- ADC Data
    AUD_DACLRCK : inout std_logic;                      -- DAC LR Clock
    AUD_DACDAT : out std_logic;                         -- DAC Data
    AUD_BCLK : inout std_logic;                         -- Bit-Stream Clock
    AUD_XCK : out std_logic;                            -- Chip Clock
      
    -- General-purpose I/O
    GPIO_0,                                      -- GPIO Connection 0
    GPIO_1 : inout std_logic_vector(35 downto 0) -- GPIO Connection 1	
);
end TOP_UART;

architecture rtl of TOP_UART is
		
	component miniUART 
	port (
		SysClk   : in  Std_Logic;  -- System Clock
		Reset    : in  Std_Logic;  -- Reset input
		CS_N     : in  Std_Logic;
		RD_N     : in  Std_Logic;
		WR_N     : in  Std_Logic;
		RxD      : in  Std_Logic;
		TxD      : out Std_Logic;
		IntRx_N  : out Std_Logic;  -- Receive interrupt
		IntTx_N  : out Std_Logic;  -- Transmit interrupt
		Addr     : in  Std_Logic_Vector(1 downto 0); -- 
		DataIn   : in  Std_Logic_Vector(7 downto 0); -- 
		DataOut  : out Std_Logic_Vector(7 downto 0)); --     
	end component;
	
begin

	U1 : miniUART PORT MAP ( 
		SysClk   => CLOCK_50, 		--: in  Std_Logic;  -- System Clock
		Reset    => KEY(0), 		--: in  Std_Logic;  -- Reset input
		CS_N     => SW(0), 			--: in  Std_Logic;
		RD_N     => SW(1), 			--: in  Std_Logic;
		WR_N     => SW(2), 			--: in  Std_Logic;
		RxD      => UART_RXD, 		--: in  Std_Logic;
		TxD      => UART_TXD, 		--: out Std_Logic;
		IntRx_N  => LEDG(0), 		--: out Std_Logic;  -- Receive interrupt
		IntTx_N  => LEDG(1), 		--: out Std_Logic;  -- Transmit interrupt
		Addr     => SW(8 downto 7), --: in  Std_Logic_Vector(1 downto 0); -- 
		DataIn   => x"69",			--: in  Std_Logic_Vector(7 downto 0); -- 
		DataOut  => LEDR(7 downto 0)--: out Std_Logic_Vector(7 downto 0)); -- 				
		);

	--
	SRAM_DQ(15 downto 8) <= (others => 'Z');
	SRAM_ADDR(17 downto 16) <= "00";
	SRAM_UB_N <= '1';
	SRAM_LB_N <= '0';
	SRAM_CE_N <= '0';
	--
	UART_TXD <= 'Z';
	DRAM_ADDR <= (others => '0');
	DRAM_LDQM <= '0';
	DRAM_UDQM <= '0';
	DRAM_WE_N <= '1';
	DRAM_CAS_N <= '1';
	DRAM_RAS_N <= '1';
	DRAM_CS_N <= '1';
	DRAM_BA_0 <= '0';
	DRAM_BA_1 <= '0';
	DRAM_CLK <= '0';
	DRAM_CKE <= '0';
	FL_ADDR <= (others => '0');
	FL_WE_N <= '1';
	FL_RST_N <= '0';
	FL_OE_N <= '1';
	FL_CE_N <= '1';
	TDO <= '0';
	I2C_SCLK <= '0';
	AUD_DACDAT <= '0';
	AUD_XCK <= '0';
	-- Set all bidirectional ports to tri-state
	DRAM_DQ     <= (others => 'Z');
	FL_DQ       <= (others => 'Z');
	I2C_SDAT    <= 'Z';
	AUD_ADCLRCK <= 'Z';
	AUD_DACLRCK <= 'Z';
	AUD_BCLK    <= 'Z';
	GPIO_0 <= (others => 'Z');
	GPIO_1 <= (others => 'Z');	
end;