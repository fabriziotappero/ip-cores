--##############################################################################
-- light52 MCU demo on Avnet's Spartan-3A Evaluation Kit board.
--##############################################################################
-- 
-- This is a minimal demo of the light52 core targetting Avnet's Spartan-3A 
-- Evaluation Kit board for Xilinx Spartan-3A FPGAs. 
-- This file is strictly for trial purposes and has not been tested.
--
-- This demo has been built from a generic template for designs targetting the
-- same development board. The entity defines all the inputs and outputs present
-- in the actual board, whether or not they are used in the design at hand.
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Define the entity outputs as they are connected in the DE-1 development 
-- board. Many of the outputs will be left unused in this demo.
entity s3aeval_soc is
    port ( 
        -- ***** Clocks
        CLK_12MHZ       : in std_logic;
        CLK_16MHZ       : in std_logic;
        CLK_32KHZ       : in std_logic;

        -- ***** Parallel Flash 4MB
        FLASH_A         : out std_logic_vector(21 downto 0);
        FLASH_D         : inout std_logic_vector(15 downto 0);
        FLASH_BYTEn     : out std_logic;
        FLASH_CEn       : out std_logic;
        FLASH_OEn       : out std_logic;
        FLASH_RESETn    : out std_logic;
        FLASH_RY_BYn    : out std_logic;
        FLASH_WEn       : out std_logic;
        
        -- ***** Serial flash
        FPGA_MOSI       : in std_logic;
        FPGA_SPI_SELn   : in std_logic;
        SF_HOLDn        : in std_logic;
        SF_Wn           : in std_logic;
        SPI_CLK         : in std_logic;
        --FLASH_D00       : inout std_logic;

        -- ***** User I/O
        FPGA_RESET      : in std_logic;
        FPGA_PUSH_A     : in std_logic;
        FPGA_PUSH_B     : in std_logic;
        FPGA_PUSH_C     : in std_logic;
        LEDS            : out std_logic_vector(3 downto 0);

        -- ***** I2C
        IIC_SCL         : in std_logic;
        IIC_SDA         : in std_logic;

        -- ***** PSoC
        PSOC_P0_4       : in std_logic;
        PSOC_P2_1       : in std_logic;
        PSOC_P2_3       : in std_logic;
        PSOC_P2_5       : in std_logic;
        PSOC_P2_7       : in std_logic;
        PSOC_P4_6       : in std_logic;
        PSOC_P5_3       : in std_logic;
        PSOC_P5_4       : in std_logic;
        PSOC_P5_6       : in std_logic;
        PSOC_P5_7       : in std_logic;
        PSOC_P7_0       : in std_logic;
        PSOC_P7_7       : in std_logic;        

        -- ***** RS-232
        uart_rxd        : in std_logic;
        uart_txd        : out std_logic;

        -- ***** Digi Headers
        DIGI1           : inout std_logic_vector(3 downto 0);
        DIGI2           : inout std_logic_vector(3 downto 0);

        -- ***** GPIO
        BANK0_IO        : inout std_logic_vector(32 downto 1);
        BANK1_IO        : inout std_logic_vector(1 downto 1);
        BANK2_IO        : inout std_logic_vector(2 downto 1)        
    );
end s3aeval_soc;

architecture minimal of s3aeval_soc is

-- light52 MCU signals ---------------------------------------------------------
signal p0_out :             std_logic_vector(7 downto 0);
signal p1_out :             std_logic_vector(7 downto 0);
signal p2_in :              std_logic_vector(7 downto 0);
signal p3_in :              std_logic_vector(7 downto 0);
signal external_irq :       std_logic_vector(7 downto 0);  
signal reset :              std_logic;
signal clk :                std_logic;


begin

    -- The clock comes from the on-board oscillator. We need no speed so we
    -- won't instantiate a DCM.
    clk <= clk_16MHz;

    -- SOC instantiation 
    mcu: entity work.light52_mcu 
    generic map (
        -- Memory size is defined in package obj_code_pkg...
        CODE_ROM_SIZE => work.obj_code_pkg.XCODE_SIZE,
        XDATA_RAM_SIZE => work.obj_code_pkg.XDATA_SIZE,
        -- ...as is the object code initialization constant.
        OBJ_CODE => work.obj_code_pkg.object_code,
        -- Leave BCD opcodes disabled.
        IMPLEMENT_BCD_INSTRUCTIONS => true,
        -- UART baud rate isn't programmable in run time.
        UART_HARDWIRED => true,
        -- We're using the 16MHz clock of the Avnet S3A board.
        CLOCK_RATE => 16e6
    )
    port map (
        clk             => clk,
        reset           => reset,
            
        txd             => uart_txd,
        rxd             => uart_rxd,
        
        external_irq    => external_irq, 
        
        p0_out          => p0_out,
        p1_out          => p1_out,
        p2_in           => p2_in,
        p3_in           => p3_in
    );

    -- The CPU reset input will be wired straight to the PSoC-controlled
    -- capacitive button labelled 'reset'. This is a recipe for faulty resets
    -- but it will do for the first quick tests.
    reset <= FPGA_RESET;
  
    p2_in <= "00000" & FPGA_PUSH_C & FPGA_PUSH_B & FPGA_PUSH_A;
    p3_in <= p1_out;
    
    LEDS <= p1_out(3 downto 0);

    -- The parallel flash is not used so leave its interface inactive.  
    FLASH_A <= (others => '0');
    FLASH_D <= (others => 'Z');
    FLASH_BYTEn  <= '1';
    FLASH_CEn    <= '1';
    FLASH_OEn    <= '1';
    FLASH_RESETn <= '1';
    FLASH_RY_BYn <= '1';
    FLASH_WEn    <= '1';

    -- FIXME he board has some other peripheral devices which are not accounted
    -- for; there will be plenty of warnings.
  
end minimal;
