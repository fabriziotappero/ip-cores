-------------------------------------------------------------------------------
-- Title      : Supertoplevel
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : eth_udpip_udp2hibi_top.vhd
-- Author     : Jussi Nieminen
-- Last update: 2010/01/08
-------------------------------------------------------------------------------
-- Description: Combines DM9kA_controller, udp/ip and udp2hibi blocks
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/28  1.0      niemin95        Created
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use work.udp2hibi_pkg.all;

entity eth_udpip_udp2hibi_top is

  generic (
    receiver_table_size_g    : integer := 2;
    ack_fifo_depth_g         : integer := 4;
    tx_multiclk_fifo_depth_g : integer := 5;
    rx_multiclk_fifo_depth_g : integer := 5;
    hibi_tx_fifo_depth_g     : integer := 5;
    hibi_data_width_g        : integer := 32;
    hibi_addr_width_g        : integer := 32;
    hibi_comm_width_g        : integer := 3;
    frequency_g              : integer := 50000000
    );

  port (
    clk              : in    std_logic;
    clk_udp          : in    std_logic;
    rst_n            : in    std_logic;
    -- ethernet interface
    eth_clk_out      : out   std_logic;
    eth_reset_out    : out   std_logic;
    eth_cmd_out      : out   std_logic;
    eth_write_out    : out   std_logic;
    eth_read_out     : out   std_logic;
    eth_interrupt_in : in    std_logic;
    eth_data_inout   : inout std_logic_vector( 15 downto 0 );
    eth_chip_sel_out : out   std_logic;
    ready_out        : out   std_logic;
    fatal_error_out  : out   std_logic;
    -- hibi interface
    hibi_comm_in     : in    std_logic_vector( hibi_comm_width_g-1 downto 0 );
    hibi_data_in     : in    std_logic_vector( hibi_data_width_g-1 downto 0 );
    hibi_av_in       : in    std_logic;
    hibi_empty_in    : in    std_logic;
    hibi_re_out      : out   std_logic;
    hibi_comm_out    : out   std_logic_vector( hibi_comm_width_g-1 downto 0 );
    hibi_data_out    : out   std_logic_vector( hibi_data_width_g-1 downto 0 );
    hibi_av_out      : out   std_logic;
    hibi_we_out      : out   std_logic;
    hibi_full_in     : in    std_logic
    );

end eth_udpip_udp2hibi_top;



architecture structural of eth_udpip_udp2hibi_top is

  signal tx_data_udp_eth       : std_logic_vector( udp_block_data_w_c-1 downto 0 );
  signal tx_data_valid_udp_eth : std_logic;
  signal tx_re_eth_udp         : std_logic;
  signal rx_re_udp_eth         : std_logic;
  signal rx_data_eth_udp       : std_logic_vector( udp_block_data_w_c-1 downto 0 );
  signal rx_data_valid_eth_udp : std_logic;
  signal target_MAC_udp_eth    : std_logic_vector( 47 downto 0 );
  signal new_tx_udp_eth        : std_logic;
  signal tx_len_udp_eth        : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal tx_frame_type_udp_eth : std_logic_vector( 15 downto 0 );
  signal new_rx_eth_udp        : std_logic;
  signal rx_len_eth_udp        : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal rx_frame_type_eth_udp : std_logic_vector( 15 downto 0 );
  signal rx_erroneous_eth_udp  : std_logic;

  signal new_tx_udp2hibi_udp        : std_logic;
  signal tx_len_udp2hibi_udp        : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal target_addr_udp2hibi_udp   : std_logic_vector( ip_addr_w_c-1 downto 0 );
  signal target_port_udp2hibi_udp   : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal source_port_udp2hibi_udp   : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal tx_data_udp2hibi_udp       : std_logic_vector( udp_block_data_w_c-1 downto 0 );
  signal tx_data_valid_udp2hibi_udp : std_logic;
  signal tx_re_udp_udp2hibi         : std_logic;
  signal new_rx_udp_udp2hibi        : std_logic;
  signal rx_data_valid_udp_udp2hibi : std_logic;
  signal rx_data_udp_udp2hibi       : std_logic_vector( udp_block_data_w_c-1 downto 0 );
  signal rx_re_udp2hibi_udp         : std_logic;
  signal rx_erroneous_udp_udp2hibi  : std_logic;
  signal source_addr_udp_udp2hibi   : std_logic_vector( ip_addr_w_c-1 downto 0 );
  signal source_port_udp_udp2hibi   : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal dest_port_udp_udp2hibi     : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal rx_len_udp_udp2hibi        : std_logic_vector( tx_len_w_c-1 downto 0 );

  signal fatal_error_from_eth : std_logic;
  signal rx_error_from_udp    : std_logic;
  signal eth_ready            : std_logic;

-------------------------------------------------------------------------------
begin  -- structural
-------------------------------------------------------------------------------


  eth_controller: entity work.DM9kA_controller
    port map (
        clk               => clk_udp,
        rst_n             => rst_n,
        eth_clk_out       => eth_clk_out,
        eth_reset_out     => eth_reset_out,
        eth_cmd_out       => eth_cmd_out,
        eth_write_out     => eth_write_out,
        eth_read_out      => eth_read_out,
        eth_interrupt_in  => eth_interrupt_in,
        eth_data_inout    => eth_data_inout,
        eth_chip_sel_out  => eth_chip_sel_out,
        tx_data_in        => tx_data_udp_eth,
        tx_data_valid_in  => tx_data_valid_udp_eth,
        tx_re_out         => tx_re_eth_udp,
        rx_re_in          => rx_re_udp_eth,
        rx_data_out       => rx_data_eth_udp,
        rx_data_valid_out => rx_data_valid_eth_udp,
        target_MAC_in     => target_MAC_udp_eth,
        new_tx_in         => new_tx_udp_eth,
        tx_len_in         => tx_len_udp_eth,
        tx_frame_type_in  => tx_frame_type_udp_eth,
        new_rx_out        => new_rx_eth_udp,
        rx_len_out        => rx_len_eth_udp,
        rx_frame_type_out => rx_frame_type_eth_udp,
        rx_erroneous_out  => rx_erroneous_eth_udp,
        ready_out         => eth_ready,
        fatal_error_out   => fatal_error_from_eth
        );

  ready_out <= eth_ready;


  udp_ip_block: entity work.udp_ip
    port map (
        clk               => clk_udp,
        rst_n             => rst_n,
        new_tx_in         => new_tx_udp2hibi_udp,
        tx_len_in         => tx_len_udp2hibi_udp,
        target_addr_in    => target_addr_udp2hibi_udp,
        target_port_in    => target_port_udp2hibi_udp,
        source_port_in    => source_port_udp2hibi_udp,
        tx_data_in        => tx_data_udp2hibi_udp,
        tx_data_valid_in  => tx_data_valid_udp2hibi_udp,
        tx_re_out         => tx_re_udp_udp2hibi,
        new_rx_out        => new_rx_udp_udp2hibi,
        rx_data_valid_out => rx_data_valid_udp_udp2hibi,
        rx_data_out       => rx_data_udp_udp2hibi,
        rx_re_in          => rx_re_udp2hibi_udp,
        rx_erroneous_out  => rx_erroneous_udp_udp2hibi,
        source_addr_out   => source_addr_udp_udp2hibi,
        source_port_out   => source_port_udp_udp2hibi,
        dest_port_out     => dest_port_udp_udp2hibi,
        rx_len_out        => rx_len_udp_udp2hibi,
        tx_data_out       => tx_data_udp_eth,
        tx_data_valid_out => tx_data_valid_udp_eth,
        tx_re_in          => tx_re_eth_udp,
        target_MAC_out    => target_MAC_udp_eth,
        new_tx_out        => new_tx_udp_eth,
        tx_len_out        => tx_len_udp_eth,
        tx_frame_type_out => tx_frame_type_udp_eth,
        rx_data_in        => rx_data_eth_udp,
        rx_data_valid_in  => rx_data_valid_eth_udp,
        rx_re_out         => rx_re_udp_eth,
        new_rx_in         => new_rx_eth_udp,
        rx_len_in         => rx_len_eth_udp,
        rx_frame_type_in  => rx_frame_type_eth_udp,
        rx_erroneous_in   => rx_erroneous_eth_udp,
        rx_error_out      => rx_error_from_udp
        );

  fatal_error_out <= fatal_error_from_eth or rx_error_from_udp;


  udp2hibi_block: entity work.udp2hibi
    generic map (
        receiver_table_size_g    => receiver_table_size_g,
        ack_fifo_depth_g         => ack_fifo_depth_g,
        tx_multiclk_fifo_depth_g => tx_multiclk_fifo_depth_g,
        rx_multiclk_fifo_depth_g => rx_multiclk_fifo_depth_g,
        hibi_tx_fifo_depth_g     => hibi_tx_fifo_depth_g,
        hibi_data_width_g        => hibi_data_width_g,
        hibi_addr_width_g        => hibi_addr_width_g,
        hibi_comm_width_g        => hibi_comm_width_g,
        frequency_g              => frequency_g
        )
    port map (
        clk               => clk,
        clk_udp           => clk_udp,
        rst_n             => rst_n,
        hibi_comm_in      => hibi_comm_in,
        hibi_data_in      => hibi_data_in,
        hibi_av_in        => hibi_av_in,
        hibi_empty_in     => hibi_empty_in,
        hibi_re_out       => hibi_re_out,
        hibi_comm_out     => hibi_comm_out,
        hibi_data_out     => hibi_data_out,
        hibi_av_out       => hibi_av_out,
        hibi_we_out       => hibi_we_out,
        hibi_full_in      => hibi_full_in,
        tx_data_out       => tx_data_udp2hibi_udp,
        tx_data_valid_out => tx_data_valid_udp2hibi_udp,
        tx_re_in          => tx_re_udp_udp2hibi,
        new_tx_out        => new_tx_udp2hibi_udp,
        tx_len_out        => tx_len_udp2hibi_udp,
        dest_ip_out       => target_addr_udp2hibi_udp,
        dest_port_out     => target_port_udp2hibi_udp,
        source_port_out   => source_port_udp2hibi_udp,
        rx_data_in        => rx_data_udp_udp2hibi,
        rx_data_valid_in  => rx_data_valid_udp_udp2hibi,
        rx_re_out         => rx_re_udp2hibi_udp,
        new_rx_in         => new_rx_udp_udp2hibi,
        rx_len_in         => rx_len_udp_udp2hibi,
        source_ip_in      => source_addr_udp_udp2hibi,
        dest_port_in      => dest_port_udp_udp2hibi,
        source_port_in    => source_port_udp_udp2hibi,
        rx_erroneous_in   => rx_erroneous_udp_udp2hibi,
        eth_link_up_in    => eth_ready
        );

end structural;
