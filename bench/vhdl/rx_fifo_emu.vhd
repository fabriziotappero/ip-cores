library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity rx_fifo_emu is
  
  generic (
    C_SR_WIDTH  : integer;
    C_RX_CMP_VALUE : integer);

  port (
    rst     : in std_logic;
    rx_clk  : in std_logic;
    rx_en   : in std_logic;
    rx_data : in std_logic_vector(C_SR_WIDTH-1 downto 0));

end rx_fifo_emu;


architecture behavior of rx_fifo_emu is

  signal rx_data_cmp : std_logic_vector(C_SR_WIDTH-1 downto 0) := conv_std_logic_vector(C_RX_CMP_VALUE,C_SR_WIDTH);
  
begin  -- behavior
  process(rst, rx_clk)
  begin
    if (rst = '1') then
    elsif rising_edge(rx_clk) then
      if (rx_en = '1') then
        assert (rx_data = rx_data_cmp) report "RX-FIFO Compare Error" severity warning;
        rx_data_cmp <= rx_data_cmp+1;
      end if;
    end if;
  end process;
end behavior;
