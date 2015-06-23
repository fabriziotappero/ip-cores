-------------------------------------------------------------------------------
-- Title      : UDP/IP
-- Project    : 
-------------------------------------------------------------------------------
-- File       : udp_ip.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Last update: 2010-08-18
-------------------------------------------------------------------------------
-- Description: Receives/transmits data from/to an application, inside a UDP/IP
--              packet. Also handles ARP requests.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/09/03  1.0      niemin95        Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.udp_ip_pkg.all;

entity udp_ip is

  generic (
    disable_rx_g  : integer := 0;
    disable_arp_g : integer := 0);

  port (
    clk               : in  std_logic;
    rst_n             : in  std_logic;
    -- to/from application
    new_tx_in         : in  std_logic;
    tx_len_in         : in  std_logic_vector( tx_len_w_c-1 downto 0 );
    target_addr_in    : in  std_logic_vector( ip_addr_w_c-1 downto 0 );
    target_port_in    : in  std_logic_vector( port_w_c-1 downto 0 );
    source_port_in    : in  std_logic_vector( port_w_c-1 downto 0 );
    tx_data_in        : in  std_logic_vector( udp_data_width_c-1 downto 0 );
    tx_data_valid_in  : in  std_logic;
    tx_re_out         : out std_logic;
    new_rx_out        : out std_logic;
    rx_data_valid_out : out std_logic;
    rx_data_out       : out std_logic_vector( udp_data_width_c-1 downto 0 );
    rx_re_in          : in  std_logic;
    rx_erroneous_out  : out std_logic;
    source_addr_out   : out std_logic_vector( ip_addr_w_c-1 downto 0 );
    source_port_out   : out std_logic_vector( port_w_c-1 downto 0 );
    dest_port_out     : out std_logic_vector( port_w_c-1 downto 0 );
    rx_len_out        : out std_logic_vector( tx_len_w_c-1 downto 0 );

    -- Use this when disable_arp_g = 1
    no_arp_target_MAC_in     : in  std_logic_vector( MAC_addr_w_c-1 downto 0 ) := (others => '0');
    
    -- to/from ethernet controller
    tx_data_out       : out std_logic_vector( udp_data_width_c-1 downto 0 );
    tx_data_valid_out : out std_logic;
    tx_re_in          : in  std_logic;
    target_MAC_out    : out std_logic_vector( MAC_addr_w_c-1 downto 0 );
    new_tx_out        : out std_logic;
    tx_len_out        : out std_logic_vector( tx_len_w_c-1 downto 0 );
    tx_frame_type_out : out std_logic_vector( frame_type_w_c-1 downto 0 );
    rx_data_in        : in  std_logic_vector( udp_data_width_c-1 downto 0 );
    rx_data_valid_in  : in  std_logic;
    rx_re_out         : out std_logic;
    new_rx_in         : in  std_logic;
    rx_len_in         : in  std_logic_vector( tx_len_w_c-1 downto 0 );
    rx_frame_type_in  : in  std_logic_vector( frame_type_w_c-1 downto 0 );
    rx_erroneous_in   : in  std_logic;
    rx_error_out      : out std_logic   -- this means system error, not error
                                        -- in data caused by network etc.
    );

end udp_ip;


architecture rtl of udp_ip is

  signal gen_ARP_rep              : std_logic;
  signal gen_ARP_IP               : std_logic_vector( ip_addr_w_c-1 downto 0 );
  signal IP_arpsnd_arp            : std_logic_vector( ip_addr_w_c-1 downto 0 );
  signal MAC_arp_arpsnd           : std_logic_vector( MAC_addr_w_c-1 downto 0 );
  signal ARP_entry_valid          : std_logic;
  signal MAC_request_UDP_arpsnd   : std_logic;
  signal MAC_arpsnd_UDP           : std_logic_vector( MAC_addr_w_c-1 downto 0 );
  signal MAC_valid_arpsnd_UDP     : std_logic;
  signal IP_UDP_arpsnd            : std_logic_vector( ip_addr_w_c-1 downto 0 );
  signal sending_reply_arpsnd_arp : std_logic;
  signal rx_arp_done              : std_logic;
  signal arpsnd_tx_ready          : std_logic;

  -- to and from arpsnd
  signal tx_data_from_arp       : std_logic_vector( udp_data_width_c-1 downto 0 );
  signal tx_data_valid_from_arp : std_logic;
  signal tx_re_to_arp           : std_logic;
  signal tx_target_MAC_from_arp : std_logic_vector( MAC_addr_w_c-1 downto 0 );
  signal tx_len_from_arp        : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal tx_frame_type_from_arp : std_logic_vector( frame_type_w_c-1 downto 0 );
  signal new_tx_from_arp        : std_logic;
  signal rx_data_to_arp       : std_logic_vector( udp_data_width_c-1 downto 0 );
  signal rx_data_valid_to_arp : std_logic;
  signal new_rx_to_arp        : std_logic;
  signal rx_re_from_arp       : std_logic;

  -- to and from udp block
  signal tx_data_from_udp       : std_logic_vector( udp_data_width_c-1 downto 0 );
  signal tx_data_valid_from_udp : std_logic;
  signal tx_re_to_udp           : std_logic;
  signal tx_target_MAC_from_udp : std_logic_vector( MAC_addr_w_c-1 downto 0 );
  signal tx_len_from_udp        : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal tx_frame_type_from_udp : std_logic_vector( frame_type_w_c-1 downto 0 );
  signal new_tx_from_udp        : std_logic;
  signal rx_data_to_udp       : std_logic_vector( udp_data_width_c-1 downto 0 );
  signal rx_data_valid_to_udp : std_logic;
  signal new_rx_to_udp        : std_logic;
  signal rx_re_from_udp       : std_logic;

  -- mux select signals
  signal input_select  : std_logic_vector( 1 downto 0 );
  signal output_select : std_logic_vector( 1 downto 0 );

  -- mux signals
  signal tx_datas       : std_logic_vector( 3*udp_data_width_c-1 downto 0 );
  signal tx_data_valids : std_logic_vector( 2 downto 0 );
  signal tx_target_MACs : std_logic_vector( 2*MAC_addr_w_c-1 downto 0 );
  signal tx_lens        : std_logic_vector( 2*tx_len_w_c-1 downto 0 );
  signal tx_frame_types : std_logic_vector( 2*frame_type_w_c-1 downto 0 );
  signal new_txs        : std_logic_vector( 1 downto 0 );
  signal tx_res         : std_logic_vector( 2 downto 0 );
  signal rx_res         : std_logic_vector( 2 downto 0 );
  signal rx_datas       : std_logic_vector( 3*udp_data_width_c-1 downto 0 );
  signal rx_data_valids : std_logic_vector( 2 downto 0 );
  signal new_rxs        : std_logic_vector( 1 downto 0 );

  signal frame_valid : std_logic;

-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------


  --                    | Eth ctrl |
  --                    ------------
  --                         ||
  --  ---------------------------------------------
  --  |UDP/IP                ||                   |
  --  |               ---------------             |
  --  |              /     MUX       \___         |
  --  |             /_________________\  |        |
  --  |              ||     ||     ||    |        |
  --  |       ----------    ||    -----------     |
  --  |       | ARPSND |----------|   UDP   |     |
  --  |       ----------    ||    -----------     |
  --  |         ||          ||       ||           |
  --  |      --------      data    addresses etc. |
  --  |      | ARP3 |        \\     //            |
  --  |      --------         \\   //             |
  --  |                        \\ //              |
  --  ---------------------------------------------
  --                           || ||
  --                      ---------------
  --                      | application |


  
  -----------------------------------------------------------------------------
  -- *** MUX SIGNALS ***

  -- forming the tx signals for the mux
  tx_datas       <= tx_data_in & tx_data_from_arp & tx_data_from_udp;
  tx_data_valids <= tx_data_valid_in & tx_data_valid_from_arp & tx_data_valid_from_udp;
  tx_target_MACs <= tx_target_MAC_from_arp & tx_target_MAC_from_udp;
  tx_lens        <= tx_len_from_arp & tx_len_from_udp;
  tx_frame_types <= tx_frame_type_from_arp & tx_frame_type_from_udp;
  new_txs        <= new_tx_from_arp & new_tx_from_udp;

  -- tx read enables from the mux
  tx_re_to_udp <= tx_res(0);
  tx_re_to_arp <= tx_res(1);
  tx_re_out    <= tx_res(2);

  -- rx signals

  rx_enabled: if disable_rx_g = 0 generate

    rx_res         <= rx_re_in & rx_re_from_arp & rx_re_from_udp;
    rx_data_to_udp <= rx_datas( udp_data_width_c-1 downto 0 );
    rx_data_to_arp <= rx_datas( 2*udp_data_width_c-1 downto udp_data_width_c );
    rx_data_out    <= rx_datas( 3*udp_data_width_c-1 downto 2*udp_data_width_c );
  
    rx_data_valid_to_udp <= rx_data_valids(0);
    rx_data_valid_to_arp <= rx_data_valids(1);
    rx_data_valid_out    <= rx_data_valids(2);

    new_rx_to_udp <= new_rxs(0);
    new_rx_to_arp <= new_rxs(1);

  end generate rx_enabled;
  
  -- *** /MUX SIGNALS ***
  -----------------------------------------------------------------------------

  -- Input/output select signals can have values from 0 to 2:
  -- 0: UDP
  -- 1: ARP
  -- 2: application
  
  data_mux : entity work.udp_arp_data_mux
    generic map (
      data_width_g       => udp_data_width_c,
      tx_len_w_g         => tx_len_w_c
      )
    port map (
      rx_data_valid_in   => rx_data_valid_in,
      new_rx_in          => new_rx_in,
      rx_data_in         => rx_data_in,
      rx_res_in          => rx_res,
      rx_re_out          => rx_re_out,
      rx_datas_out       => rx_datas,
      rx_data_valids_out => rx_data_valids,
      new_rxs_out        => new_rxs,
      tx_datas_in        => tx_datas,
      tx_data_valids_in  => tx_data_valids,
      tx_target_MACs_in  => tx_target_MACs,
      tx_lens_in         => tx_lens,
      tx_frame_types_in  => tx_frame_types,
      new_txs_in         => new_txs,
      tx_re_in           => tx_re_in,
      tx_data_out        => tx_data_out,
      tx_data_valid_out  => tx_data_valid_out,
      tx_target_MAC_out  => target_MAC_out,
      tx_len_out         => tx_len_out,
      tx_frame_type_out  => tx_frame_type_out,
      new_tx_out         => new_tx_out,
      tx_res_out         => tx_res,
      input_select_in    => input_select,
      output_select_in   => output_select
      );

  frame_valid <= not rx_erroneous_in;

  arp_enabled: if disable_arp_g = 0 generate
    
    arp_block : entity work.ARP
      port map (
        clk               => clk,
        rstn              => rst_n,
        new_frame_in      => new_rx_to_arp,
        new_word_valid_in => rx_data_valid_to_arp,
        frame_re_out      => rx_re_from_arp,
        frame_data_in     => rx_data_to_arp,
        frame_valid_in    => frame_valid,
        frame_len_in      => rx_len_in,
        sending_reply_in  => sending_reply_arpsnd_arp,
        req_IP_in         => IP_arpsnd_arp,
        gen_ARP_rep_out   => gen_ARP_rep,
        gen_ARP_IP_out    => gen_ARP_IP,
        lookup_MAC_out    => MAC_arp_arpsnd,
        valid_entry_out   => ARP_entry_valid,
        done_out          => rx_arp_done
        );
    
    arpsend : entity work.ARPSnd
      port map (
        clk                => clk,
        rstn               => rst_n,
        request_MAC_in     => MAC_request_UDP_arpsnd,
        targer_IP_in       => IP_UDP_arpsnd,
        ARP_entry_valid_in => ARP_entry_valid,
        gen_ARP_reply_in   => gen_ARP_rep,
        gen_ARP_IP_in      => gen_ARP_IP,
        lookup_MAC_in      => MAC_arp_arpsnd,
        lookup_IP_out      => IP_arpsnd_arp,
        sending_reply_out  => sending_reply_arpsnd_arp,
        target_MAC_out     => tx_target_MAC_from_arp,
        requested_MAC_out  => MAC_arpsnd_UDP,
        req_MAC_valid_out  => MAC_valid_arpsnd_UDP,
        gen_frame_out      => new_tx_from_arp,
        frame_type_out     => tx_frame_type_from_arp,
        frame_size_out     => tx_len_from_arp,
        tx_ready_out       => arpsnd_tx_ready,
        wr_data_valid_out  => tx_data_valid_from_arp,
        wr_data_out        => tx_data_from_arp,
        wr_re_in           => tx_re_to_arp
        );

  end generate arp_enabled;

  arp_disabled: if disable_arp_g = 1 generate
    MAC_arpsnd_UDP       <= no_arp_target_MAC_in;
    MAC_valid_arpsnd_UDP <= '1';
    new_tx_from_arp      <= '0';
    arpsnd_tx_ready      <= '1';
  end generate arp_disabled;

  udp_block: entity work.udp
    generic map (
        data_width_g => udp_data_width_c,
        tx_len_w_g   => tx_len_w_c
        )
    port map (
        clk                   => clk,
        rst_n                 => rst_n,
        new_tx_in             => new_tx_in,
        tx_len_in             => tx_len_in,
        target_IP_in          => target_addr_in,
        target_port_in        => target_port_in,
        source_port_in        => source_port_in,
        new_tx_out            => new_tx_from_udp,
        tx_MAC_addr_out       => tx_target_MAC_from_udp,
        tx_len_out            => tx_len_from_udp,
        tx_frame_type_out     => tx_frame_type_from_udp,
        header_data_out       => tx_data_from_udp,
        header_data_valid_out => tx_data_valid_from_udp,
        ethernet_re_in        => tx_re_in,
        new_rx_in             => new_rx_to_udp,
        rx_data_in            => rx_data_to_udp,
        rx_data_valid_in      => rx_data_valid_to_udp,
        rx_len_in             => rx_len_in,
        rx_frame_type_in      => rx_frame_type_in,
        rx_re_out             => rx_re_from_udp,
        rx_erroneous_in       => rx_erroneous_in,
        rx_erroneous_out      => rx_erroneous_out,
        new_rx_out            => new_rx_out,
        rx_len_out            => rx_len_out,
        source_IP_out         => source_addr_out,
        source_port_out       => source_port_out,
        dest_port_out         => dest_port_out,
        application_re_in     => rx_re_in,
        request_MAC_out       => MAC_request_UDP_arpsnd,
        IP_to_arp_out         => IP_UDP_arpsnd,
        requested_MAC_in      => MAC_arpsnd_UDP,
        req_MAC_valid_in      => MAC_valid_arpsnd_UDP,
        rx_arp_ready_in       => rx_arp_done,
        snd_req_from_arp_in   => new_tx_from_arp,
        tx_arp_ready_in       => arpsnd_tx_ready,
        rx_error_out          => rx_error_out,
        input_select_out      => input_select,
        output_select_out     => output_select
        );


end rtl;
