-------------------------------------------------------------------------------
-- Title      : UDP2HIBI toplevel
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : udp2hibi.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-06-20
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Converter that should be placed between HIBI wrapper and
--              UDP_IP block. This is converter's toplevel entity that
--              includes 5 sub-blocks.
--             
--              All blocks wishing to use UDP/IP must first configure
--              this unit before sending data, or being able to receive.
--              Only one sender can be active at a time.
--              Configurations are acknowledged.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2009/12/15  1.0      niemin95        Created
-- 2012-03-23  1.0      ege             Beautifying and commenting.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.udp2hibi_pkg.all;

entity udp2hibi is

  generic (
    receiver_table_size_g      : integer := 4;
    ack_fifo_depth_g           : integer := 4;
    tx_multiclk_fifo_depth_g   : integer := 10;
    rx_multiclk_fifo_depth_g   : integer := 10;
    hibi_tx_fifo_depth_g       : integer := 10;
    hibi_data_width_g          : integer := 32;
    hibi_addr_width_g          : integer := 32;
    hibi_comm_width_g          : integer := 5;
    frequency_g                : integer := 50000000);

  port (
    clk               : in  std_logic;
    clk_udp           : in  std_logic;
    rst_n             : in  std_logic;
    -- ** to/from HIBI **
    -- receiver
    hibi_comm_in      : in  std_logic_vector( hibi_comm_width_g-1 downto 0 );
    hibi_data_in      : in  std_logic_vector( hibi_data_width_g-1 downto 0 );
    hibi_av_in        : in  std_logic;
    hibi_empty_in     : in  std_logic;
    hibi_re_out       : out std_logic;
    -- sender
    hibi_comm_out     : out std_logic_vector( hibi_comm_width_g-1 downto 0 );
    hibi_data_out     : out std_logic_vector( hibi_data_width_g-1 downto 0 );
    hibi_av_out       : out std_logic;
    hibi_we_out       : out std_logic;
    hibi_full_in      : in  std_logic;
    -- ** to/from UDP/IP **
    -- tx
    tx_data_out       : out std_logic_vector( udp_block_data_w_c-1 downto 0 );
    tx_data_valid_out : out std_logic;
    tx_re_in          : in  std_logic;
    new_tx_out        : out std_logic;
    tx_len_out        : out std_logic_vector( tx_len_w_c-1 downto 0 );
    dest_ip_out       : out std_logic_vector( ip_addr_w_c-1 downto 0 );
    dest_port_out     : out std_logic_vector( udp_port_w_c-1 downto 0 );
    source_port_out   : out std_logic_vector( udp_port_w_c-1 downto 0 );
    -- rx
    rx_data_in        : in  std_logic_vector( udp_block_data_w_c-1 downto 0 );
    rx_data_valid_in  : in  std_logic;
    rx_re_out         : out std_logic;
    new_rx_in         : in  std_logic;
    rx_len_in         : in  std_logic_vector( tx_len_w_c-1 downto 0 );
    source_ip_in      : in  std_logic_vector( ip_addr_w_c-1 downto 0 );
    dest_port_in      : in  std_logic_vector( udp_port_w_c-1 downto 0 );
    source_port_in    : in  std_logic_vector( udp_port_w_c-1 downto 0 );
    rx_erroneous_in   : in  std_logic;
    -- from eth controller
    eth_link_up_in    : in  std_logic
    );

end udp2hibi;


architecture structural of udp2hibi is

  -- hibi_receiver <-> tx_ctrl
  signal tx_data_receiver_txctrl    : std_logic_vector( udp_block_data_w_c-1 downto 0 );
  signal tx_we_receiver_txctrl      : std_logic;
  signal tx_full_txctrl_receiver    : std_logic;
  signal new_tx_receiver_txctrl     : std_logic;
  signal tx_len_receiver_txctrl     : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal new_tx_ack_txctrl_receiver : std_logic;
  signal timeout_receiver_txctrl    : std_logic_vector( timeout_w_c-1 downto 0 );
  signal timeout_txctrl_receiver    : std_logic;

  -- hibi_receiver <-> ctrl_regs
  signal release_lock_receiver_regs  : std_logic;
  signal new_tx_conf_receiver_regs   : std_logic;
  signal new_rx_conf_receiver_regs   : std_logic;
  signal ip_receiver_regs            : std_logic_vector( ip_addr_w_c-1 downto 0 );
  signal dest_port_receiver_regs     : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal source_port_receiver_regs   : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal lock_addr_receiver_regs     : std_logic_vector( hibi_addr_width_g-1 downto 0 );
  signal response_addr_receiver_regs : std_logic_vector( hibi_addr_width_g-1 downto 0 );
  signal lock_regs_receiver          : std_logic;
  signal lock_addr_regs_receiver     : std_logic_vector( hibi_addr_width_g-1 downto 0 );

  -- ctrl_regs <-> tx_ctrl
  signal ip_regs_txctrl              : std_logic_vector( ip_addr_w_c-1 downto 0 );
  signal dest_port_regs_txctrl       : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal source_port_regs_txctrl     : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal timeout_release_txctrl_regs : std_logic;

  -- ctrl_regs <-> rx_ctrl
  signal ip_rxctrl_regs            : std_logic_vector( ip_addr_w_c-1 downto 0 );
  signal dest_port_rxctrl_regs     : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal source_port_rxctrl_regs   : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal rx_addr_valid_regs_rxctrl : std_logic;

  -- ctrl_regs <-> hibi_transmitter
  signal ack_addr_regs_transmitter     : std_logic_vector( hibi_addr_width_g-1 downto 0 );
  signal rx_addr_regs_transmitter      : std_logic_vector( hibi_addr_width_g-1 downto 0 );
  signal send_tx_ack_regs_transmitter  : std_logic;
  signal send_tx_nack_regs_transmitter : std_logic;
  signal send_rx_ack_regs_transmitter  : std_logic;
  signal send_rx_nack_regs_transmitter : std_logic;

  -- rx_ctrl <-> hibi_transmitter
  signal send_request_rxctrl_transmitter : std_logic;
  signal rx_len_rxctrl_transmitter       : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal ready_for_tx_transmitter_rxctrl : std_logic;
  signal rx_empty_rxctrl_transmitter     : std_logic;
  signal rx_data_rxctrl_transmitter      : std_logic_vector( hibi_data_width_g-1 downto 0 );
  signal rx_re_transmitter_rxctrl        : std_logic;


-------------------------------------------------------------------------------
begin  -- structural
-------------------------------------------------------------------------------

  --
  --          +---------------------------------+----------+
  --          |                                 |          |
  --  (hibi) ---> hibi receiver   -->  tx ctrl ---> udp/ip --> eth
  --          |              \         /        |          |
  --          |               ctrl regs         |          |
  --          |              /        \         |          |
  --  (hibi)<--- hibi transmitter --> rx ctrl  <--- udp/ip <-- eth
  --          |                                 |          |
  --          +---------------------------------+----------+
  -- 


  
  -- Gets configurations and data from hibi. Forwards them to ctrl-reg and tx-ctrl
  hibi_receiver_block : entity work.hibi_receiver
    generic map (
      hibi_comm_width_g => hibi_comm_width_g,
      hibi_addr_width_g => hibi_addr_width_g,
      hibi_data_width_g => hibi_data_width_g
      )
    port map (
      clk               => clk,
      rst_n             => rst_n,

      hibi_comm_in      => hibi_comm_in,
      hibi_data_in      => hibi_data_in,
      hibi_av_in        => hibi_av_in,
      hibi_re_out       => hibi_re_out,
      hibi_empty_in     => hibi_empty_in,

      tx_data_out       => tx_data_receiver_txctrl,
      tx_we_out         => tx_we_receiver_txctrl,
      tx_full_in        => tx_full_txctrl_receiver,
      new_tx_out        => new_tx_receiver_txctrl,
      tx_length_out     => tx_len_receiver_txctrl,
      new_tx_ack_in     => new_tx_ack_txctrl_receiver,
      timeout_out       => timeout_receiver_txctrl,
      timeout_in        => timeout_txctrl_receiver,

      release_lock_out  => release_lock_receiver_regs,
      new_tx_conf_out   => new_tx_conf_receiver_regs,
      new_rx_conf_out   => new_rx_conf_receiver_regs,
      ip_out            => ip_receiver_regs,
      dest_port_out     => dest_port_receiver_regs,
      source_port_out   => source_port_receiver_regs,
      lock_addr_out     => lock_addr_receiver_regs,
      response_addr_out => response_addr_receiver_regs,
      lock_in           => lock_regs_receiver,
      lock_addr_in      => lock_addr_regs_receiver
      );


  -- Stores the configurations
  ctrl_regs_block : entity work.ctrl_regs
    generic map (
      receiver_table_size_g => receiver_table_size_g,
      hibi_addr_width_g     => hibi_addr_width_g
      )
    port map (
      clk                   => clk,
      rst_n                 => rst_n,

      release_lock_in       => release_lock_receiver_regs,
      new_tx_conf_in        => new_tx_conf_receiver_regs,
      new_rx_conf_in        => new_rx_conf_receiver_regs,
      ip_in                 => ip_receiver_regs,
      dest_port_in          => dest_port_receiver_regs,
      source_port_in        => source_port_receiver_regs,
      lock_addr_in          => lock_addr_receiver_regs,
      response_addr_in      => response_addr_receiver_regs,
      lock_out              => lock_regs_receiver,
      lock_addr_out         => lock_addr_regs_receiver,

      tx_ip_out             => ip_regs_txctrl,
      tx_dest_port_out      => dest_port_regs_txctrl,
      tx_source_port_out    => source_port_regs_txctrl,
      timeout_release_in    => timeout_release_txctrl_regs,

      rx_ip_in              => ip_rxctrl_regs,
      rx_dest_port_in       => dest_port_rxctrl_regs,
      rx_source_port_in     => source_port_rxctrl_regs,
      rx_addr_valid_out     => rx_addr_valid_regs_rxctrl,

      ack_addr_out          => ack_addr_regs_transmitter,
      rx_addr_out           => rx_addr_regs_transmitter,
      send_tx_ack_out       => send_tx_ack_regs_transmitter,
      send_tx_nack_out      => send_tx_nack_regs_transmitter,
      send_rx_ack_out       => send_rx_ack_regs_transmitter,
      send_rx_nack_out      => send_rx_nack_regs_transmitter,
      eth_link_up_in        => eth_link_up_in
      );


  -- Forwads data to ucp/ip
  tx_ctrl_block : entity work.tx_ctrl
    generic map (
      multiclk_fifo_depth_g => tx_multiclk_fifo_depth_g,
      frequency_g           => frequency_g
      )
    port map (
      clk                 => clk,
      clk_udp             => clk_udp,
      rst_n               => rst_n,
      tx_data_in          => tx_data_receiver_txctrl,
      tx_we_in            => tx_we_receiver_txctrl,
      tx_full_out         => tx_full_txctrl_receiver,
      tx_data_out         => tx_data_out,
      tx_data_valid_out   => tx_data_valid_out,
      tx_re_in            => tx_re_in,

      new_tx_out          => new_tx_out,
      tx_len_out          => tx_len_out,
      dest_ip_out         => dest_ip_out,
      dest_port_out       => dest_port_out,
      source_port_out     => source_port_out,

      new_tx_in           => new_tx_receiver_txctrl,
      tx_len_in           => tx_len_receiver_txctrl,
      new_tx_ack_out      => new_tx_ack_txctrl_receiver,
      timeout_in          => timeout_receiver_txctrl,
      timeout_to_hr_out   => timeout_txctrl_receiver,

      tx_ip_in            => ip_regs_txctrl,
      tx_dest_port_in     => dest_port_regs_txctrl,
      tx_source_port_in   => source_port_regs_txctrl,
      timeout_release_out => timeout_release_txctrl_regs
      );


  -- Gets data from udp/ip. Forwards it to hibi-transmitter.
  rx_ctrl_block : entity work.rx_ctrl
    generic map (
        rx_multiclk_fifo_depth_g => rx_multiclk_fifo_depth_g,
        tx_fifo_depth_g          => hibi_tx_fifo_depth_g,
        hibi_data_width_g        => hibi_data_width_g,
        frequency_g              => frequency_g
        )
    port map (
        clk              => clk,
        clk_udp          => clk_udp,
        rst_n            => rst_n,

        rx_data_in       => rx_data_in,
        rx_data_valid_in => rx_data_valid_in,
        rx_re_out        => rx_re_out,
        new_rx_in        => new_rx_in,
        rx_len_in        => rx_len_in,
        source_ip_in     => source_ip_in,
        dest_port_in     => dest_port_in,
        source_port_in   => source_port_in,
        rx_erroneous_in  => rx_erroneous_in,
        
        ip_out           => ip_rxctrl_regs,
        dest_port_out    => dest_port_rxctrl_regs,
        source_port_out  => source_port_rxctrl_regs,
        rx_addr_valid_in => rx_addr_valid_regs_rxctrl,

        send_request_out => send_request_rxctrl_transmitter,
        rx_len_out       => rx_len_rxctrl_transmitter,
        ready_for_tx_in  => ready_for_tx_transmitter_rxctrl,
        rx_empty_out     => rx_empty_rxctrl_transmitter,
        rx_data_out      => rx_data_rxctrl_transmitter,
        rx_re_in         => rx_re_transmitter_rxctrl
        );


  -- Gets data from rx-ctrl and writes them to hibi
  hibi_transmitter_block : entity work.hibi_transmitter
    generic map (
        hibi_data_width_g => hibi_data_width_g,
        hibi_addr_width_g => hibi_addr_width_g,
        hibi_comm_width_g => hibi_comm_width_g,
        ack_fifo_depth_g  => ack_fifo_depth_g
        )
    port map (
        clk              => clk,
        rst_n            => rst_n,
        hibi_comm_out    => hibi_comm_out,
        hibi_data_out    => hibi_data_out,
        hibi_av_out      => hibi_av_out,
        hibi_we_out      => hibi_we_out,
        hibi_full_in     => hibi_full_in,

        send_request_in  => send_request_rxctrl_transmitter,
        rx_len_in        => rx_len_rxctrl_transmitter,
        ready_for_tx_out => ready_for_tx_transmitter_rxctrl,
        rx_empty_in      => rx_empty_rxctrl_transmitter,
        rx_data_in       => rx_data_rxctrl_transmitter,
        rx_re_out        => rx_re_transmitter_rxctrl,
        rx_addr_in       => rx_addr_regs_transmitter,
        
        ack_addr_in      => ack_addr_regs_transmitter,
        send_tx_ack_in   => send_tx_ack_regs_transmitter,
        send_tx_nack_in  => send_tx_nack_regs_transmitter,
        send_rx_ack_in   => send_rx_ack_regs_transmitter,
        send_rx_nack_in  => send_rx_nack_regs_transmitter
        );


end structural;
