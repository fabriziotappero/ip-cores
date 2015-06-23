library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;               -- conv_integer()

package opb_spi_slave_pack is

  constant C_ADR_CTL         : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#0#, 6);
  constant C_ADR_STATUS      : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#1#, 6);
  constant C_ADR_TX_DATA     : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#2#, 6);
  constant C_ADR_RX_DATA     : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#3#, 6);
  constant C_ADR_TX_THRESH   : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#4#, 6);
  constant C_ADR_RX_THRESH   : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#5#, 6);
  constant C_ADR_TX_DMA_CTL  : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#6#, 6);
  constant C_ADR_TX_DMA_ADDR : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#7#, 6);
  constant C_ADR_TX_DMA_NUM  : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#8#, 6);
  constant C_ADR_RX_DMA_CTL  : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#9#, 6);
  constant C_ADR_RX_DMA_ADDR : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#A#, 6);
  constant C_ADR_RX_DMA_NUM  : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#B#, 6);
  constant C_ADR_RX_CRC      : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#C#, 6);
  constant C_ADR_TX_CRC      : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#D#, 6);

-- XIIF_V123B compatible
  constant C_ADR_DGIE : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#10#, 6);
  constant C_ADR_ISR  : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#11#, 6);
  constant C_ADR_IER  : std_logic_vector(7 downto 2) := conv_std_logic_vector(16#12#, 6);

  constant C_NUM_FLG       : integer := 16;
  constant C_NUM_INT       : integer := 11;
  constant C_WIDTH_DMA_NUM : integer := 24;


-- CTL_Register
  -- width
  constant C_OPB_CTL_REG_WIDTH   : integer := 6;
  -- bits
  constant C_OPB_CTL_REG_DGE     : integer := 0;
  constant C_OPB_CTL_REG_TX_EN   : integer := 1;
  constant C_OPB_CTL_REG_RX_EN   : integer := 2;
  constant C_OPB_CTL_REG_RST     : integer := 3;
  constant C_OPB_CTL_REG_CRC_EN  : integer := 4;
  constant C_OPB_CTL_REG_CRC_CLR : integer := 5;

  -- Status Register
  constant SPI_SR_Bit_TX_Prog_Full  : integer := 0;
  constant SPI_SR_Bit_TX_Full       : integer := 1;
  constant SPI_SR_Bit_TX_Overflow   : integer := 2;
  constant SPI_SR_Bit_TX_Prog_empty : integer := 3;
  constant SPI_SR_Bit_TX_Empty      : integer := 4;
  constant SPI_SR_Bit_TX_Underflow  : integer := 5;

  constant SPI_SR_Bit_RX_Prog_Full  : integer := 6;
  constant SPI_SR_Bit_RX_Full       : integer := 7;
  constant SPI_SR_Bit_RX_Overflow   : integer := 8;
  constant SPI_SR_Bit_RX_Prog_empty : integer := 9;
  constant SPI_SR_Bit_RX_Empty      : integer := 10;
  constant SPI_SR_Bit_RX_Underflow  : integer := 11;

  constant SPI_SR_Bit_SS_n : integer := 12;
  constant SPI_SR_Bit_TX_DMA_Done : integer := 13;
  constant SPI_SR_Bit_RX_DMA_Done : integer := 14;
  
  -- Interrupt Status Register
  constant SPI_ISR_Bit_TX_Prog_Empty : integer := 0;
  constant SPI_ISR_Bit_TX_Empty      : integer := 1;
  constant SPI_ISR_Bit_TX_Underflow  : integer := 2;
  constant SPI_ISR_Bit_RX_Prog_Full  : integer := 3;
  constant SPI_ISR_Bit_RX_Full       : integer := 4;
  constant SPI_ISR_Bit_RX_Overflow   : integer := 5;
  constant SPI_ISR_Bit_SS_Fall       : integer := 6;
  constant SPI_ISR_Bit_SS_Rise       : integer := 7;
end opb_spi_slave_pack;
