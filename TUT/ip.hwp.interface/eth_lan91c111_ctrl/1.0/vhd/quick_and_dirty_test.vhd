library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lan91c111_ctrl_pkg.all;

entity quick_and_dirty_test is
  
  port (
    clk               : in    std_logic;
    rst_n             : in    std_logic;
    but_in            : in    std_logic;
    but2_in           : in    std_logic;

    -- interface to LAN91C111
    eth_data_inout    : inout std_logic_vector( lan91_data_width_c-1 downto 0 );
    eth_addr_out      : out   std_logic_vector( lan91_addr_width_c-1 downto 0 );
    eth_interrupt_in  : in    std_logic;
    eth_read_out      : out   std_logic;
    eth_write_out     : out   std_logic;
    eth_nADS_out      : out   std_logic;
    eth_nAEN_out      : out   std_logic;
    eth_nBE_out       : out   std_logic_vector(3 downto 0);

    ready_out         : out   std_logic

    );

end quick_and_dirty_test;

architecture structural of quick_and_dirty_test is

  signal clk25, tx_re : std_logic;

  signal but_r1, but_r, but2_r1, but2_r : std_logic;

  signal but_cnt_r : integer range 0 to 25000000;

  signal tx_len_r : integer range 0 to 1400;

  signal new_tx_r : std_logic;
  
begin  -- structural

  synch: process (clk, rst_n)
  begin  -- process synch
    if rst_n = '0' then                 -- asynchronous reset (active low)
      but_r1 <= '0';
      but_r <= '0';
      but2_r1 <= '0';
      but2_r <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      but_r <= but_r1;
      but_r1 <= not but_in;
      but2_r <= but2_r1;
      but2_r1 <= not but2_in;
    end if;
  end process synch;

  joo: process (clk, rst_n)
  begin  -- process joo
    if rst_n = '0' then                 -- asynchronous reset (active low)
      new_tx_r <= '0';
      tx_len_r <= 28; --899;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if but_cnt_r /= 0 then
        but_cnt_r <= but_cnt_r - 1;
      end if;

      if but_r = '1' and but_cnt_r = 0 then
        new_tx_r <= '1';
        tx_len_r <= tx_len_r + 1;
        but_cnt_r <= 25000000;
      end if;

      if new_tx_r = '1' and tx_re = '1' then
        new_tx_r <= '0';
      end if;

    end if;
  end process joo;

  pll_1: entity work.pll
    port map (
      inclk0 => clk,
      c0     => clk25);
  
  lan91c111_controller_1: entity work.lan91c111_controller
    generic map (
      enable_tx_g => '1',
      enable_rx_g => '1',
      interface_width_g => 16)
    port map (
      clk               => clk25,
      rst_n             => rst_n,
      eth_data_inout    => eth_data_inout,
      eth_addr_out      => eth_addr_out,
      eth_interrupt_in  => eth_interrupt_in,
      eth_read_out      => eth_read_out,
      eth_write_out     => eth_write_out,
      eth_nADS_out      => eth_nADS_out,
      eth_nAEN_out      => eth_nAEN_out,
      eth_nBE_out       => eth_nBE_out,
      tx_data_in        => x"ABCD",
      tx_data_valid_in  => '1',
      tx_re_out         => tx_re,
      rx_re_in          => '1',
      rx_data_out       => open,
      rx_data_valid_out => open,
      target_MAC_in     => x"000102CEF343",  -- vanha kone
--      target_MAC_in     => x"FFFFFFFFFFFF",
      new_tx_in         => new_tx_r or but2_r,
      tx_len_in         => std_logic_vector(to_unsigned(tx_len_r, 11)),
      tx_frame_type_in  => x"0800",
      new_rx_out        => open,
      rx_len_out        => open,
      rx_frame_type_out => open,
      rx_erroneous_out  => open,
      ready_out         => ready_out,
      fatal_error_out   => open);

end structural;
