library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity tx_fifo_emu is
  generic (
    C_SR_WIDTH : integer := 8;
    C_TX_CMP_VALUE : integer);
  port (
    rst     : in std_logic;
    tx_clk  : in std_logic;
    tx_en   : in std_logic;
    tx_data : out std_logic_vector(C_SR_WIDTH-1 downto 0));

end tx_fifo_emu;

architecture behavior of tx_fifo_emu is

  signal tx_data_int : std_logic_vector(C_SR_WIDTH-1 downto 0);


begin  -- behavior

  tx_data <= tx_data_int;
  
  process(rst, tx_clk)
  begin
    if (rst = '1') then
      tx_data_int <= conv_std_logic_vector(C_TX_CMP_VALUE,C_SR_WIDTH);
    elsif rising_edge(tx_clk) then
      if (tx_en = '1') then
        tx_data_int <= tx_data_int + 1;
      end if;
    end if;
  end process;

end behavior;
