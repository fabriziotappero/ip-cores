----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:43:16 06/04/2011 
-- Design Name: 
-- Module Name:    IP_complete_nomac - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Implements complete IP stack with ARP (but no MAC)
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - separated RX and TX clocks
-- Revision 0.03 - Added mac_tx_tfirst
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;
use work.arp;
use work.arpv2;

entity IP_complete_nomac is
  generic (
    use_arpv2 : boolean := true;        -- use ARP with multipule entries. for signel entry, set
                                        -- to false
    no_default_gateway : boolean := false;  -- set to false if communicating with devices accessed
                                           -- through a "default gateway or router"
    CLOCK_FREQ      : integer := 125000000;  -- freq of data_in_clk -- needed to timout cntr
    ARP_TIMEOUT     : integer := 60;    -- ARP response timeout (s)
    ARP_MAX_PKT_TMO : integer := 5;     -- # wrong nwk pkts received before set error
    MAX_ARP_ENTRIES : integer := 255    -- max entries in the ARP store
    );
  port (
    -- IP Layer signals
    ip_tx_start          : in  std_logic;
    ip_tx                : in  ipv4_tx_type;                  -- IP tx cxns
    ip_tx_result         : out std_logic_vector (1 downto 0);  -- tx status (changes during transmission)
    ip_tx_data_out_ready : out std_logic;  -- indicates IP TX is ready to take data
    ip_rx_start          : out std_logic;  -- indicates receipt of ip frame.
    ip_rx                : out ipv4_rx_type;
    -- system signals
    rx_clk               : in  std_logic;
    tx_clk               : in  std_logic;
    reset                : in  std_logic;
    our_ip_address       : in  std_logic_vector (31 downto 0);
    our_mac_address      : in  std_logic_vector (47 downto 0);
    control              : in  ip_control_type;
    -- status signals
    arp_pkt_count        : out std_logic_vector(7 downto 0);  -- count of arp pkts received
    ip_pkt_count         : out std_logic_vector(7 downto 0);  -- number of IP pkts received for us
    -- MAC Transmitter
    mac_tx_tdata         : out std_logic_vector(7 downto 0);  -- data byte to tx
    mac_tx_tvalid        : out std_logic;  -- tdata is valid
    mac_tx_tready        : in  std_logic;  -- mac is ready to accept data
    mac_tx_tfirst        : out std_logic;  -- indicates first byte of frame
    mac_tx_tlast         : out std_logic;  -- indicates last byte of frame
    -- MAC Receiver
    mac_rx_tdata         : in  std_logic_vector(7 downto 0);  -- data byte received
    mac_rx_tvalid        : in  std_logic;  -- indicates tdata is valid
    mac_rx_tready        : out std_logic;  -- tells mac that we are ready to take data
    mac_rx_tlast         : in  std_logic   -- indicates last byte of the trame
    );
end IP_complete_nomac;


architecture structural of IP_complete_nomac is

  component IPv4
    port(
      -- IP Layer signals
      ip_tx_start          : in  std_logic;
      ip_tx                : in  ipv4_tx_type;                  -- IP tx cxns
      ip_tx_result         : out std_logic_vector (1 downto 0);  -- tx status (changes during transmission)
      ip_tx_data_out_ready : out std_logic;  -- indicates IP TX is ready to take data
      ip_rx_start          : out std_logic;  -- indicates receipt of ip frame.
      ip_rx                : out ipv4_rx_type;
      -- system control signals
      rx_clk               : in  std_logic;
      tx_clk               : in  std_logic;
      reset                : in  std_logic;
      our_ip_address       : in  std_logic_vector (31 downto 0);
      our_mac_address      : in  std_logic_vector (47 downto 0);
      -- system status signals
      rx_pkt_count         : out std_logic_vector(7 downto 0);  -- number of IP pkts received for us
      -- ARP lookup signals
      arp_req_req          : out arp_req_req_type;
      arp_req_rslt         : in  arp_req_rslt_type;
      -- MAC layer RX signals
      mac_data_in          : in  std_logic_vector (7 downto 0);  -- ethernet frame (from dst mac addr through to last byte of frame)
      mac_data_in_valid    : in  std_logic;  -- indicates data_in valid on clock
      mac_data_in_last     : in  std_logic;  -- indicates last data in frame
      -- MAC layer TX signals
      mac_tx_req           : out std_logic;  -- indicates that ip wants access to channel (stays up for as long as tx)
      mac_tx_granted       : in  std_logic;  -- indicates that access to channel has been granted            
      mac_data_out_ready   : in  std_logic;  -- indicates system ready to consume data
      mac_data_out_valid   : out std_logic;  -- indicates data out is valid
      mac_data_out_first   : out std_logic;  -- with data out valid indicates the first byte of a frame
      mac_data_out_last    : out std_logic;  -- with data out valid indicates the last byte of a frame
      mac_data_out         : out std_logic_vector (7 downto 0)  -- ethernet frame (from dst mac addr through to last byte of frame)      
      );
  end component;

  component arp
    generic (
      CLOCK_FREQ      : integer := 125000000;  -- freq of data_in_clk -- needed to timout cntr
      ARP_TIMEOUT     : integer := 60;  -- ARP response timeout (s)
      ARP_MAX_PKT_TMO : integer := 1;  -- (added for compatibility with arpv2. this value not used in this impl)
      MAX_ARP_ENTRIES : integer := 1  -- (added for compatibility with arpv2. this value not used in this impl)
      );
    port (
      -- lookup request signals
      arp_req_req     : in  arp_req_req_type;
      arp_req_rslt    : out arp_req_rslt_type;
      -- MAC layer RX signals
      data_in_clk     : in  std_logic;
      reset           : in  std_logic;
      data_in         : in  std_logic_vector (7 downto 0);  -- ethernet frame (from dst mac addr through to last byte of frame)
      data_in_valid   : in  std_logic;  -- indicates data_in valid on clock
      data_in_last    : in  std_logic;  -- indicates last data in frame
      -- MAC layer TX signals
      mac_tx_req      : out std_logic;  -- indicates that ip wants access to channel (stays up for as long as tx)
      mac_tx_granted  : in  std_logic;  -- indicates that access to channel has been granted            
      data_out_clk    : in  std_logic;
      data_out_ready  : in  std_logic;  -- indicates system ready to consume data
      data_out_valid  : out std_logic;  -- indicates data out is valid
      data_out_first  : out std_logic;  -- with data out valid indicates the first byte of a frame
      data_out_last   : out std_logic;  -- with data out valid indicates the last byte of a frame
      data_out        : out std_logic_vector (7 downto 0);  -- ethernet frame (from dst mac addr through to last byte of frame)
      -- system signals
      our_mac_address : in  std_logic_vector (47 downto 0);
      our_ip_address  : in  std_logic_vector (31 downto 0);
      control         : in  arp_control_type;
      req_count       : out std_logic_vector(7 downto 0)    -- count of arp pkts received
      );
  end component;

  component tx_arbitrator
    port(
      clk   : in std_logic;
      reset : in std_logic;

      req_1   : in  std_logic;
      grant_1 : out std_logic;
      data_1  : in  std_logic_vector(7 downto 0);  -- data byte to tx
      valid_1 : in  std_logic;                     -- tdata is valid
      first_1 : in  std_logic;                     -- indicates first byte of frame
      last_1  : in  std_logic;                     -- indicates last byte of frame

      req_2   : in  std_logic;
      grant_2 : out std_logic;
      data_2  : in  std_logic_vector(7 downto 0);  -- data byte to tx
      valid_2 : in  std_logic;                     -- tdata is valid
      first_2 : in  std_logic;                     -- indicates first byte of frame
      last_2  : in  std_logic;                     -- indicates last byte of frame

      data  : out std_logic_vector(7 downto 0);  -- data byte to tx
      valid : out std_logic;                     -- tdata is valid
      first : out std_logic;                     -- indicates first byte of frame
      last  : out std_logic                      -- indicates last byte of frame
      );         
  end component;


  -------------------
  -- Configuration
  --
  -- Enable one of the following to specify which
  -- implementation of the ARP layer to use
  -------------------


--      for arp_layer : arp use entity work.arp;                        -- single slot arbitrator
--  for arp_layer : arp use entity work.arpv2;  -- multislot arbitrator



  ---------------------------
  -- Signals
  ---------------------------

  -- ARP REQUEST
  signal arp_req_req_int    : arp_req_req_type;
  signal arp_req_rslt_int   : arp_req_rslt_type;
  -- MAC arbitration busses
  signal ip_mac_req         : std_logic;
  signal ip_mac_grant       : std_logic;
  signal ip_mac_data_out    : std_logic_vector (7 downto 0);
  signal ip_mac_valid       : std_logic;
  signal ip_mac_first       : std_logic;
  signal ip_mac_last        : std_logic;
  signal arp_mac_req        : std_logic;
  signal arp_mac_grant      : std_logic;
  signal arp_mac_data_out   : std_logic_vector (7 downto 0);
  signal arp_mac_valid      : std_logic;
  signal arp_mac_first      : std_logic;
  signal arp_mac_last       : std_logic;
  -- MAC RX bus
  signal mac_rx_tready_int  : std_logic;
  -- MAC TX bus
  signal mac_tx_tdata_int   : std_logic_vector (7 downto 0);
  signal mac_tx_tvalid_int  : std_logic;
  signal mac_tx_tfirst_int  : std_logic;
  signal mac_tx_tlast_int   : std_logic;
  -- control signals
  signal mac_tx_granted_int : std_logic;

begin

  mac_rx_tready_int <= '1';             -- enable the mac receiver

  -- set followers
  mac_tx_tdata  <= mac_tx_tdata_int;
  mac_tx_tvalid <= mac_tx_tvalid_int;
  mac_tx_tfirst <= mac_tx_tfirst_int;
  mac_tx_tlast  <= mac_tx_tlast_int;

  mac_rx_tready <= mac_rx_tready_int;

  ------------------------------------------------------------------------------
  -- Instantiate the IP layer
  ------------------------------------------------------------------------------

  IP_layer : IPv4 port map
    (
      ip_tx_start          => ip_tx_start,
      ip_tx                => ip_tx,
      ip_tx_result         => ip_tx_result,
      ip_tx_data_out_ready => ip_tx_data_out_ready,
      ip_rx_start          => ip_rx_start,
      ip_rx                => ip_rx,
      rx_clk               => rx_clk,
      tx_clk               => tx_clk,
      reset                => reset,
      our_ip_address       => our_ip_address,
      our_mac_address      => our_mac_address,
      rx_pkt_count         => ip_pkt_count,
      arp_req_req          => arp_req_req_int,
      arp_req_rslt         => arp_req_rslt_int,
      mac_tx_req           => ip_mac_req,
      mac_tx_granted       => ip_mac_grant,
      mac_data_out_ready   => mac_tx_tready,
      mac_data_out_valid   => ip_mac_valid,
      mac_data_out_first   => ip_mac_first,
      mac_data_out_last    => ip_mac_last,
      mac_data_out         => ip_mac_data_out,
      mac_data_in          => mac_rx_tdata,
      mac_data_in_valid    => mac_rx_tvalid,
      mac_data_in_last     => mac_rx_tlast
      );

  ------------------------------------------------------------------------------
  -- Instantiate the ARP layer
  ------------------------------------------------------------------------------
  signle_entry_arp: if (not use_arpv2) generate
    arp_layer : entity work.arp
      generic map (
        CLOCK_FREQ      => CLOCK_FREQ,
        ARP_TIMEOUT     => ARP_TIMEOUT,
        ARP_MAX_PKT_TMO => ARP_MAX_PKT_TMO,
        MAX_ARP_ENTRIES => MAX_ARP_ENTRIES
        )
      port map(
        -- request signals
        arp_req_req     => arp_req_req_int,
        arp_req_rslt    => arp_req_rslt_int,
        -- rx signals
        data_in_clk     => rx_clk,
        reset           => reset,
        data_in         => mac_rx_tdata,
        data_in_valid   => mac_rx_tvalid,
        data_in_last    => mac_rx_tlast,
        -- tx signals
        mac_tx_req      => arp_mac_req,
        mac_tx_granted  => arp_mac_grant,
        data_out_clk    => tx_clk,
        data_out_ready  => mac_tx_tready,
        data_out_valid  => arp_mac_valid,
        data_out_first  => arp_mac_first,
        data_out_last   => arp_mac_last,
        data_out        => arp_mac_data_out,
        -- system signals
        our_mac_address => our_mac_address,
        our_ip_address  => our_ip_address,
        control         => control.arp_controls,
        req_count       => arp_pkt_count
        );    
  end generate signle_entry_arp;

  multi_entry_arp: if (use_arpv2) generate
    arp_layer : entity work.arpv2
      generic map (
        no_default_gateway => no_default_gateway,
        CLOCK_FREQ      => CLOCK_FREQ,
        ARP_TIMEOUT     => ARP_TIMEOUT,
        ARP_MAX_PKT_TMO => ARP_MAX_PKT_TMO,
        MAX_ARP_ENTRIES => MAX_ARP_ENTRIES
        )
      port map(
        -- request signals
        arp_req_req     => arp_req_req_int,
        arp_req_rslt    => arp_req_rslt_int,
        -- rx signals
        data_in_clk     => rx_clk,
        reset           => reset,
        data_in         => mac_rx_tdata,
        data_in_valid   => mac_rx_tvalid,
        data_in_last    => mac_rx_tlast,
        -- tx signals
        mac_tx_req      => arp_mac_req,
        mac_tx_granted  => arp_mac_grant,
        data_out_clk    => tx_clk,
        data_out_ready  => mac_tx_tready,
        data_out_valid  => arp_mac_valid,
        data_out_first  => arp_mac_first,
        data_out_last   => arp_mac_last,
        data_out        => arp_mac_data_out,
        -- system signals
        our_mac_address => our_mac_address,
        our_ip_address  => our_ip_address,
        control         => control.arp_controls,
        req_count       => arp_pkt_count
        );    
  end generate multi_entry_arp;

  ------------------------------------------------------------------------------
  -- Instantiate the TX Arbitrator 
  ------------------------------------------------------------------------------
  mac_tx_arb : tx_arbitrator
    port map(
      clk   => tx_clk,
      reset => reset,

      req_1   => ip_mac_req,
      grant_1 => ip_mac_grant,
      data_1  => ip_mac_data_out,
      valid_1 => ip_mac_valid,
      first_1 => ip_mac_first,
      last_1  => ip_mac_last,

      req_2   => arp_mac_req,
      grant_2 => arp_mac_grant,
      data_2  => arp_mac_data_out,
      valid_2 => arp_mac_valid,
      first_2 => arp_mac_first,
      last_2  => arp_mac_last,

      data  => mac_tx_tdata_int,
      valid => mac_tx_tvalid_int,
      first => mac_tx_tfirst_int,
      last  => mac_tx_tlast_int
      );

end structural;



