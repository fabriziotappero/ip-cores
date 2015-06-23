-------------------------------------------------------------------------------
-- Title      : LAN91C111 controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Originally: DM9kA_controller.vhd
-- Author     : Antti Alhonen
-- Company    : 
-- Last update: 2011-11-08
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Top level
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/24  1.0      niemin95	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.lan91c111_ctrl_pkg.all;


entity lan91c111_controller is
  generic (
    enable_tx_g  : std_logic := '1';
    enable_rx_g  : std_logic := '1';
    interface_width_g : integer := 16   -- 16 or 32.
    );
  
  port (
    clk               : in    std_logic;
    rst_n             : in    std_logic;

    -- interface to LAN91C111
    eth_data_inout    : inout std_logic_vector( lan91_data_width_c-1 downto 0 );
    eth_addr_out      : out   std_logic_vector( lan91_addr_width_c-1 downto 0 );
    eth_interrupt_in  : in    std_logic;
    eth_read_out      : out   std_logic;
    eth_write_out     : out   std_logic;
    eth_nADS_out      : out   std_logic;
    eth_nAEN_out      : out   std_logic;
    eth_nBE_out       : out   std_logic_vector(3 downto 0);

    tx_data_in        : in    std_logic_vector( interface_width_g-1 downto 0 );
    tx_data_valid_in  : in    std_logic;
    tx_re_out         : out   std_logic;
    rx_re_in          : in    std_logic;
    rx_data_out       : out   std_logic_vector( interface_width_g-1 downto 0 );
    rx_data_valid_out : out   std_logic;
    target_MAC_in     : in    std_logic_vector( 47 downto 0 );
    new_tx_in         : in    std_logic;
    tx_len_in         : in    std_logic_vector( tx_len_w_c-1 downto 0 );
    tx_frame_type_in  : in    std_logic_vector( 15 downto 0 );
    new_rx_out        : out   std_logic;
    rx_len_out        : out   std_logic_vector( tx_len_w_c-1 downto 0 );
    rx_frame_type_out : out   std_logic_vector( 15 downto 0 );
    rx_erroneous_out  : out   std_logic;
    ready_out         : out   std_logic;
    fatal_error_out   : out   std_logic
    );

end lan91c111_controller;


architecture structural of lan91c111_controller is

  signal register_addrs : std_logic_vector( (submodules_c+1) * real_addr_width_c - 1 downto 0 );
  signal config_datas : std_logic_vector( (submodules_c+1) * lan91_data_width_c - 1 downto 0 );
  signal config_nBEs : std_logic_vector( (submodules_c+1) * 4 - 1 downto 0);
  signal read_not_writes : std_logic_vector( submodules_c downto 0 );
  signal configs_valid : std_logic_vector( submodules_c downto 0 );
  signal data_to_submodules : std_logic_vector( lan91_data_width_c-1 downto 0 );
  signal data_to_sb_valid : std_logic;
  signal busy_to_submodules : std_logic;

  signal comm_reqs : std_logic_vector( submodules_c-1 downto 0 );
  signal comm_grants : std_logic_vector( submodules_c-1 downto 0 );

  signal init_ready : std_logic;
  signal interrupt : std_logic;

  signal tx_data_send_comm : std_logic_vector( lan91_data_width_c-1 downto 0 );
  signal tx_data_valid_send_comm : std_logic;
  signal tx_re_comm_send : std_logic;

  signal rx_data_comm_read : std_logic_vector( lan91_data_width_c-1 downto 0 );
  signal rx_data_valid_comm_read : std_logic;
  signal rx_re_read_comm : std_logic;
  signal tx_ready_int_send : std_logic;
  signal rx_waiting_int_read : std_logic;

  signal rx_data_tmp : std_logic_vector(lan91_data_width_c-1 downto 0);


-------------------------------------------------------------------------------
begin  -- structural
-------------------------------------------------------------------------------

  assert enable_rx_g = '1' or enable_tx_g = '1' report "You probably want to enable at least either tx or rx..." severity failure;
  assert interface_width_g = 32 or interface_width_g = 16 report "Data interface width has to be 32 or 16" severity failure;
  
  comm_module: entity work.lan91c111_comm_module
    port map (
        clk                    => clk,
        rst_n                  => rst_n,
        comm_requests_in       => comm_reqs,
        comm_grants_out        => comm_grants,
        interrupt_out          => interrupt,
        init_ready_in          => init_ready,
        register_addrs_in      => register_addrs,
        config_datas_in        => config_datas,
        config_nBEs_in         => config_nBEs,
        read_not_write_in      => read_not_writes,
        configs_valid_in       => configs_valid,
        data_to_submodules_out => data_to_submodules,
        data_to_sb_valid_out   => data_to_sb_valid,
        busy_to_submodules_out => busy_to_submodules,
        eth_data_inout         => eth_data_inout,
        eth_addr_out           => eth_addr_out,
        eth_interrupt_in       => eth_interrupt_in,
        eth_read_out           => eth_read_out,
        eth_write_out          => eth_write_out,
        eth_nADS_out           => eth_nADS_out,
        eth_nAEN_out           => eth_nAEN_out,
        eth_nBE_out            => eth_nBE_out
        );

  init_module: entity work.lan91c111_init_module
    generic map (
      enable_tx_g => enable_tx_g,
      enable_rx_g => enable_rx_g)
    port map (
        clk                     => clk,
        rst_n                   => rst_n,
        ready_out               => init_ready,
        reg_addr_out            => register_addrs( (submodules_c+1)*real_addr_width_c - 1 downto submodules_c*real_addr_width_c ),
        config_data_out         => config_datas( (submodules_c+1)*lan91_data_width_c - 1 downto submodules_c*lan91_data_width_c ),
        nBE_out                 => config_nBEs( (submodules_c+1)*4 - 1 downto submodules_c*4 ),
        read_not_write_out      => read_not_writes( submodules_c ),
        config_valid_out        => configs_valid( submodules_c ),
        data_from_comm_in       => data_to_submodules,
        data_from_comm_valid_in => data_to_sb_valid,
        comm_busy_in            => busy_to_submodules
        );

  ready_out <= init_ready;


  enable_tx: if enable_tx_g = '1' generate

    tx_if_32bit: if interface_width_g = 32 generate
      send_module: entity work.lan91c111_send_module
        generic map (
          mode_16bit_g => 0)
        port map (
          clk                     => clk,
          rst_n                   => rst_n,
          tx_completed_in         => tx_ready_int_send,
          comm_req_out            => comm_reqs(2),
          comm_grant_in           => comm_grants(2),
          reg_addr_out            => register_addrs( 3*real_addr_width_c-1 downto 2*real_addr_width_c ),
          config_data_out         => config_datas( 3*lan91_data_width_c-1 downto 2*lan91_data_width_c ),
          config_nBE_out          => config_nBEs( 3*4-1 downto 2*4 ),
          read_not_write_out      => read_not_writes(2),
          config_valid_out        => configs_valid(2),
          data_from_comm_in       => data_to_submodules,
          data_from_comm_valid_in => data_to_sb_valid,
          comm_busy_in            => busy_to_submodules,
          tx_data_in              => tx_data_in,
          tx_data_valid_in        => tx_data_valid_in,
          tx_re_out               => tx_re_out,
          tx_MAC_addr_in          => target_MAC_in,
          new_tx_in               => new_tx_in,
          tx_len_in               => tx_len_in,
          tx_frame_type_in        => tx_frame_type_in
          );           
    end generate tx_if_32bit;

    tx_if_16bit: if interface_width_g = 16 generate
      send_module: entity work.lan91c111_send_module
        generic map (
          mode_16bit_g => 1)
        port map (
          clk                     => clk,
          rst_n                   => rst_n,
          tx_completed_in         => tx_ready_int_send,
          comm_req_out            => comm_reqs(2),
          comm_grant_in           => comm_grants(2),
          reg_addr_out            => register_addrs( 3*real_addr_width_c-1 downto 2*real_addr_width_c ),
          config_data_out         => config_datas( 3*lan91_data_width_c-1 downto 2*lan91_data_width_c ),
          config_nBE_out          => config_nBEs( 3*4-1 downto 2*4 ),
          read_not_write_out      => read_not_writes(2),
          config_valid_out        => configs_valid(2),
          data_from_comm_in       => data_to_submodules,
          data_from_comm_valid_in => data_to_sb_valid,
          comm_busy_in            => busy_to_submodules,
          tx_data_in              => x"0000" & tx_data_in,
          tx_data_valid_in        => tx_data_valid_in,
          tx_re_out               => tx_re_out,
          tx_MAC_addr_in          => target_MAC_in,
          new_tx_in               => new_tx_in,
          tx_len_in               => tx_len_in,
          tx_frame_type_in        => tx_frame_type_in
          );           
    end generate tx_if_16bit;
    
    
  end generate enable_tx;

  disable_tx: if enable_tx_g = '0' generate
    comm_reqs(2) <= '0';
  end generate disable_tx;

  int_handler_module: entity work.lan91c111_interrupt_handler
    port map (
        clk                     => clk,
        rst_n                   => rst_n,
        interrupt_in            => eth_interrupt_in,
        comm_req_out            => comm_reqs(0),
        comm_grant_in           => comm_grants(0),
        rx_waiting_out          => rx_waiting_int_read,
        tx_ready_out            => tx_ready_int_send,
        reg_addr_out            => register_addrs( real_addr_width_c-1 downto 0 ),
        config_data_out         => config_datas( lan91_data_width_c-1 downto 0 ),
        config_nBE_out          => config_nBEs( 3 downto 0 ),
        read_not_write_out      => read_not_writes(0),
        config_valid_out        => configs_valid(0),
        data_from_comm_in       => data_to_submodules,
        data_from_comm_valid_in => data_to_sb_valid,
        comm_busy_in            => busy_to_submodules
        );

  enable_rx: if enable_rx_g = '1' generate

    rx_if_32bit: if interface_width_g = 32 generate
      read_module: entity work.lan91c111_read_module
        generic map (
          mode_16bit_g => 0)
        port map (
          clk                     => clk,
          rst_n                   => rst_n,
          rx_waiting_in           => rx_waiting_int_read,
          reg_addr_out            => register_addrs( 2*real_addr_width_c-1 downto real_addr_width_c ),
          config_data_out         => config_datas( 2*lan91_data_width_c-1 downto lan91_data_width_c ),
          nBE_out                 => config_nBEs( 2*4-1 downto 4),
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
    end generate rx_if_32bit;

    rx_if_16bit: if interface_width_g = 16 generate
      read_module: entity work.lan91c111_read_module
        generic map (
          mode_16bit_g => 1)
        port map (
          clk                     => clk,
          rst_n                   => rst_n,
          rx_waiting_in           => rx_waiting_int_read,
          reg_addr_out            => register_addrs( 2*real_addr_width_c-1 downto real_addr_width_c ),
          config_data_out         => config_datas( 2*lan91_data_width_c-1 downto lan91_data_width_c ),
          nBE_out                 => config_nBEs( 2*4-1 downto 4),
          read_not_write_out      => read_not_writes(1),
          config_valid_out        => configs_valid(1),
          data_from_comm_in       => data_to_submodules,
          data_from_comm_valid_in => data_to_sb_valid,
          comm_busy_in            => busy_to_submodules,
          comm_req_out            => comm_reqs(1),
          comm_grant_in           => comm_grants(1),
          rx_data_out             => rx_data_tmp,
          rx_data_valid_out       => rx_data_valid_out,
          rx_re_in                => rx_re_in,
          new_rx_out              => new_rx_out,
          rx_len_out              => rx_len_out,
          frame_type_out          => rx_frame_type_out,
          rx_erroneous_out        => rx_erroneous_out,
          fatal_error_out         => fatal_error_out
          );
          rx_data_out <= rx_data_tmp(15 downto 0);
    end generate rx_if_16bit;
    
  end generate enable_rx;

  disable_rx: if enable_rx_g = '0' generate
    comm_reqs(1) <= '0';
  end generate disable_rx;

end structural;
