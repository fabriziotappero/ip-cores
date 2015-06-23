-------------------------------------------------------------------------------
-- Title      : DM9kA controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DM9kA_controller.vhd
-- Author     : Jussi Nieminen
-- Company    : TUT
-- Last update: 2012-04-04
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Top level of controller unit. Used withDM9000A Ethernet PHY chip,
-- which is used e.g. in Altera/Terasic DE2 FPGA board.
-- Contains 4 or 5 sub-modules (rx can be disabled=nonexisting).
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/24  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.DM9kA_ctrl_pkg.all;

entity DM9kA_controller is
  generic (
    disable_rx_g : integer := 0
    );

  port (
    clk               : in    std_logic;
    rst_n             : in    std_logic;
    eth_clk_out       : out   std_logic;
    eth_reset_out     : out   std_logic;
    eth_cmd_out       : out   std_logic;
    eth_write_out     : out   std_logic;
    eth_read_out      : out   std_logic;
    eth_interrupt_in  : in    std_logic;
    eth_data_inout    : inout std_logic_vector(data_width_c-1 downto 0);
    eth_chip_sel_out  : out   std_logic;  -- active low

    tx_data_in        : in    std_logic_vector(data_width_c-1 downto 0);
    tx_data_valid_in  : in    std_logic;
    tx_re_out         : out   std_logic;
    rx_re_in          : in    std_logic;
    rx_data_out       : out   std_logic_vector(data_width_c-1 downto 0);
    rx_data_valid_out : out   std_logic;
    target_MAC_in     : in    std_logic_vector(47 downto 0);
    new_tx_in         : in    std_logic;
    tx_len_in         : in    std_logic_vector(tx_len_w_c-1 downto 0);
    tx_frame_type_in  : in    std_logic_vector(15 downto 0);
    new_rx_out        : out   std_logic;

    rx_len_out        : out   std_logic_vector(tx_len_w_c-1 downto 0);
    rx_frame_type_out : out   std_logic_vector(15 downto 0);
    rx_erroneous_out  : out   std_logic;
    ready_out         : out   std_logic;
    fatal_error_out   : out   std_logic
    );

end DM9kA_controller;


architecture structural of DM9kA_controller is

  signal register_addrs     : std_logic_vector((submodules_c+1) * 8 - 1 downto 0);
  signal config_datas       : std_logic_vector((submodules_c+1) * 8 - 1 downto 0);
  signal read_not_writes    : std_logic_vector(submodules_c downto 0);
  signal configs_valid      : std_logic_vector(submodules_c downto 0);
  signal data_to_submodules : std_logic_vector(data_width_c-1 downto 0);
  signal data_to_sb_valid   : std_logic;
  signal busy_to_submodules : std_logic;

  signal comm_reqs   : std_logic_vector(submodules_c-1 downto 0);
  signal comm_grants : std_logic_vector(submodules_c-1 downto 0);

  signal init_ready      : std_logic;
  signal init_sleep_time : std_logic_vector(sleep_time_w_c-1 downto 0);
  signal interrupt       : std_logic;

  signal tx_data_send_comm       : std_logic_vector(data_width_c-1 downto 0);
  signal tx_data_valid_send_comm : std_logic;
  signal tx_re_comm_send         : std_logic;

  signal rx_data_comm_read       : std_logic_vector(data_width_c-1 downto 0);
  signal rx_data_valid_comm_read : std_logic;
  signal rx_re_read_comm         : std_logic;
  signal tx_ready_int_send       : std_logic;
  signal rx_waiting_int_read     : std_logic;


-------------------------------------------------------------------------------
begin  -- structural
-------------------------------------------------------------------------------

--  debug_out(15 downto 13) <= comm_reqs;
--  debug_out(12 downto 10) <= comm_grants;


  --
  -- Structure
  --
  --         DM9000A chip
  --             ^ |
  --             | V
  --
  --    init -> comm  <---> interrupt handler
  --            ^  |
  --            |  V
  --         send  read
  --          ^      |
  --          |      V
  --
  --         "application"


  
  comm_module : entity work.DM9kA_comm_module
    port map (
      clk                    => clk,
      rst_n                  => rst_n,
      comm_requests_in       => comm_reqs,
      comm_grants_out        => comm_grants,
      interrupt_out          => interrupt,

      -- send -> comm
      tx_data_in             => tx_data_send_comm,
      tx_data_valid_in       => tx_data_valid_send_comm,
      tx_re_out              => tx_re_comm_send,

      -- comm -> rx
      rx_data_out            => rx_data_comm_read,
      rx_data_valid_out      => rx_data_valid_comm_read,
      rx_re_in               => rx_re_read_comm,

      -- init ->
      init_ready_in          => init_ready,
      init_sleep_time_in     => init_sleep_time,

      -- to/from other sub-modules
      register_addrs_in      => register_addrs,
      config_datas_in        => config_datas,
      read_not_write_in      => read_not_writes,
      configs_valid_in       => configs_valid,
      data_to_submodules_out => data_to_submodules,
      data_to_sb_valid_out   => data_to_sb_valid,
      busy_to_submodules_out => busy_to_submodules,

      -- to eth chip
      eth_data_inout         => eth_data_inout,
      eth_clk_out            => eth_clk_out,
      eth_cmd_out            => eth_cmd_out,
      eth_chip_sel_out       => eth_chip_sel_out,
      eth_interrupt_in       => eth_interrupt_in,
      eth_read_out           => eth_read_out,
      eth_write_out          => eth_write_out,
      eth_reset_out          => eth_reset_out
      );

  init_module : entity work.DM9kA_init_module
    port map (
      clk                     => clk,
      rst_n                   => rst_n,
      ready_out               => init_ready,
      sleep_time_out          => init_sleep_time,
      reg_addr_out            => register_addrs((submodules_c+1)*8 - 1 downto submodules_c*8),
      config_data_out         => config_datas((submodules_c+1)*8 - 1 downto submodules_c*8),
      read_not_write_out      => read_not_writes(submodules_c),
      config_valid_out        => configs_valid(submodules_c),
      data_from_comm_in       => data_to_submodules,
      data_from_comm_valid_in => data_to_sb_valid,
      comm_busy_in            => busy_to_submodules
      );

  ready_out <= init_ready;


  send_module : entity work.DM9kA_send_module
    port map (
      clk                     => clk,
      rst_n                   => rst_n,
      tx_completed_in         => tx_ready_int_send,
      
      -- To/from comm module
      reg_addr_out            => register_addrs(3*8-1 downto 2*8),
      config_data_out         => config_datas(3*8-1 downto 2*8),
      read_not_write_out      => read_not_writes(2),
      config_valid_out        => configs_valid(2),
      data_from_comm_in       => data_to_submodules,
      data_from_comm_valid_in => data_to_sb_valid,
      comm_busy_in            => busy_to_submodules,

      comm_req_out            => comm_reqs(2),
      comm_grant_in           => comm_grants(2),
      tx_data_out             => tx_data_send_comm,
      tx_data_valid_out       => tx_data_valid_send_comm,
      tx_re_in                => tx_re_comm_send,

      -- From application
      tx_data_in              => tx_data_in,
      tx_data_valid_in        => tx_data_valid_in,
      tx_re_out               => tx_re_out,
      tx_MAC_addr_in          => target_MAC_in,
      new_tx_in               => new_tx_in,
      tx_len_in               => tx_len_in,
      tx_frame_type_in        => tx_frame_type_in
      );

  int_handler_module : entity work.DM9kA_interrupt_handler
    port map (
      clk                     => clk,
      rst_n                   => rst_n,
      interrupt_in            => eth_interrupt_in,
      comm_req_out            => comm_reqs(0),
      comm_grant_in           => comm_grants(0),

      -- Interrupt reasons
      rx_waiting_out          => rx_waiting_int_read,
      tx_ready_out            => tx_ready_int_send,

      reg_addr_out            => register_addrs(7 downto 0),
      config_data_out         => config_datas(7 downto 0),
      read_not_write_out      => read_not_writes(0),
      config_valid_out        => configs_valid(0),
      data_from_comm_in       => data_to_submodules,
      data_from_comm_valid_in => data_to_sb_valid,
      comm_busy_in            => busy_to_submodules
      );

  enable_rx : if disable_rx_g = 0 generate
    read_module : entity work.DM9kA_read_module
      port map (
        clk                     => clk,
        rst_n                   => rst_n,
        rx_waiting_in           => rx_waiting_int_read,
        rx_data_in              => rx_data_comm_read,
        rx_data_valid_in        => rx_data_valid_comm_read,
        rx_re_out               => rx_re_read_comm,
        reg_addr_out            => register_addrs(2*8-1 downto 8),
        config_data_out         => config_datas(2*8-1 downto 8),
        read_not_write_out      => read_not_writes(1),
        config_valid_out        => configs_valid(1),
        data_from_comm_in       => data_to_submodules,
        data_from_comm_valid_in => data_to_sb_valid,
        comm_busy_in            => busy_to_submodules,
        comm_req_out            => comm_reqs(1),
        comm_grant_in           => comm_grants(1),
        rx_data_out             => rx_data_out,
        rx_data_valid_out       => rx_data_valid_out,
        rx_re_in                => rx_re_in,
        new_rx_out              => new_rx_out,
        rx_len_out              => rx_len_out,
        frame_type_out          => rx_frame_type_out,
        rx_erroneous_out        => rx_erroneous_out,
        fatal_error_out         => fatal_error_out
        );
  end generate enable_rx;

  disable_rx : if disable_rx_g = 1 generate
    comm_reqs(1) <= '0';
  end generate disable_rx;

end structural;
