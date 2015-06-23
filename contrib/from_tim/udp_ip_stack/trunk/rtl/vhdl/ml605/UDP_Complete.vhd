----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:51:18 06/11/2011 
-- Design Name: 
-- Module Name:    UDP_Complete - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - separated RX and TX clocks
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;

entity UDP_Complete is
  generic (
    CLOCK_FREQ      : integer := 125000000;  -- freq of data_in_clk -- needed to timout cntr
    ARP_TIMEOUT     : integer := 60;    -- ARP response timeout (s)
    ARP_MAX_PKT_TMO : integer := 5;     -- # wrong nwk pkts received before set error
    MAX_ARP_ENTRIES : integer := 255    -- max entries in the ARP store
    );
  port (
    -- UDP TX signals
    udp_tx_start          : in  std_logic;  -- indicates req to tx UDP
    udp_txi               : in  udp_tx_type;                   -- UDP tx cxns
    udp_tx_result         : out std_logic_vector (1 downto 0);  -- tx status (changes during transmission)
    udp_tx_data_out_ready : out std_logic;  -- indicates udp_tx is ready to take data
    -- UDP RX signals
    udp_rx_start          : out std_logic;  -- indicates receipt of udp header
    udp_rxo               : out udp_rx_type;
    -- IP RX signals
    ip_rx_hdr             : out ipv4_rx_header_type;
    -- system signals
    clk_in_p              : in  std_logic;  -- 200MHz clock input from board
    clk_in_n              : in  std_logic;
    clk_out               : out std_logic;
    reset                 : in  std_logic;
    our_ip_address        : in  std_logic_vector (31 downto 0);
    our_mac_address       : in  std_logic_vector (47 downto 0);
    control               : in  udp_control_type;
    -- status signals
    arp_pkt_count         : out std_logic_vector(7 downto 0);  -- count of arp pkts received
    ip_pkt_count          : out std_logic_vector(7 downto 0);  -- number of IP pkts received for us
    -- GMII Interface
    phy_resetn            : out std_logic;
    gmii_txd              : out std_logic_vector(7 downto 0);
    gmii_tx_en            : out std_logic;
    gmii_tx_er            : out std_logic;
    gmii_tx_clk           : out std_logic;
    gmii_rxd              : in  std_logic_vector(7 downto 0);
    gmii_rx_dv            : in  std_logic;
    gmii_rx_er            : in  std_logic;
    gmii_rx_clk           : in  std_logic;
    gmii_col              : in  std_logic;
    gmii_crs              : in  std_logic;
    mii_tx_clk            : in  std_logic
    );
end UDP_Complete;




architecture structural of UDP_Complete is

  ------------------------------------------------------------------------------
  -- Component Declaration for UDP complete no mac
  ------------------------------------------------------------------------------

  component UDP_Complete_nomac
    generic (
      CLOCK_FREQ      : integer := 125000000;  -- freq of data_in_clk -- needed to timout cntr
      ARP_TIMEOUT     : integer := 60;  -- ARP response timeout (s)
      ARP_MAX_PKT_TMO : integer := 5;   -- # wrong nwk pkts received before set error
      MAX_ARP_ENTRIES : integer := 255  -- max entries in the ARP store
      );
    port (
      -- UDP TX signals
      udp_tx_start          : in  std_logic;  -- indicates req to tx UDP
      udp_txi               : in  udp_tx_type;                   -- UDP tx cxns
      udp_tx_result         : out std_logic_vector (1 downto 0);  -- tx status (changes during transmission)
      udp_tx_data_out_ready : out std_logic;  -- indicates udp_tx is ready to take data
      -- UDP RX signals
      udp_rx_start          : out std_logic;  -- indicates receipt of udp header
      udp_rxo               : out udp_rx_type;
      -- IP RX signals
      ip_rx_hdr             : out ipv4_rx_header_type;
      -- system signals
      rx_clk                : in  std_logic;
      tx_clk                : in  std_logic;
      reset                 : in  std_logic;
      our_ip_address        : in  std_logic_vector (31 downto 0);
      our_mac_address       : in  std_logic_vector (47 downto 0);
      control               : in  udp_control_type;
      -- status signals
      arp_pkt_count         : out std_logic_vector(7 downto 0);  -- count of arp pkts received
      ip_pkt_count          : out std_logic_vector(7 downto 0);  -- number of IP pkts received for us
      -- MAC Transmitter
      mac_tx_tdata          : out std_logic_vector(7 downto 0);  -- data byte to tx
      mac_tx_tvalid         : out std_logic;  -- tdata is valid
      mac_tx_tready         : in  std_logic;  -- mac is ready to accept data
      mac_tx_tfirst         : out std_logic;  -- indicates first byte of frame
      mac_tx_tlast          : out std_logic;  -- indicates last byte of frame
      -- MAC Receiver
      mac_rx_tdata          : in  std_logic_vector(7 downto 0);  -- data byte received
      mac_rx_tvalid         : in  std_logic;  -- indicates tdata is valid
      mac_rx_tready         : out std_logic;  -- tells mac that we are ready to take data
      mac_rx_tlast          : in  std_logic   -- indicates last byte of the trame
      );
  end component;


  ------------------------------------------------------------------------------
  -- Component Declaration for the MAC layer
  ------------------------------------------------------------------------------
  component mac_v2_2
-- component xv6mac_straight
    port (
      -- System controls
      ------------------
      glbl_rst  : in std_logic;         -- asynchronous reset
      mac_reset : in std_logic;         -- reset mac layer
      clk_in_p  : in std_logic;         -- 200MHz clock input from board
      clk_in_n  : in std_logic;

      -- MAC Transmitter (AXI-S) Interface
      ---------------------------------------------
      mac_tx_clock  : out std_logic;                     -- data sampled on rising edge
      mac_tx_tdata  : in  std_logic_vector(7 downto 0);  -- data byte to tx
      mac_tx_tvalid : in  std_logic;                     -- tdata is valid
      mac_tx_tready : out std_logic;                     -- mac is ready to accept data
      mac_tx_tlast  : in  std_logic;                     -- indicates last byte of frame

      -- MAC Receiver (AXI-S) Interface
      ------------------------------------------
      mac_rx_clock  : out std_logic;    -- data valid on rising edge
      mac_rx_tdata  : out std_logic_vector(7 downto 0);  -- data byte received
      mac_rx_tvalid : out std_logic;    -- indicates tdata is valid
      mac_rx_tready : in  std_logic;    -- tells mac that we are ready to take data
      mac_rx_tlast  : out std_logic;    -- indicates last byte of the trame

      -- GMII Interface
      -----------------     
      phy_resetn  : out std_logic;
      gmii_txd    : out std_logic_vector(7 downto 0);
      gmii_tx_en  : out std_logic;
      gmii_tx_er  : out std_logic;
      gmii_tx_clk : out std_logic;
      gmii_rxd    : in  std_logic_vector(7 downto 0);
      gmii_rx_dv  : in  std_logic;
      gmii_rx_er  : in  std_logic;
      gmii_rx_clk : in  std_logic;
      gmii_col    : in  std_logic;
      gmii_crs    : in  std_logic;
      mii_tx_clk  : in  std_logic
      );
  end component;


  ---------------------------
  -- Signals
  ---------------------------

  -- MAC RX bus
  signal mac_rx_clock       : std_logic;
  signal mac_rx_tdata       : std_logic_vector (7 downto 0);
  signal mac_rx_tvalid      : std_logic;
  signal mac_rx_tready      : std_logic;
  signal mac_rx_tlast       : std_logic;
  -- MAC TX bus
  signal mac_tx_clock       : std_logic;
  signal mac_tx_tdata       : std_logic_vector (7 downto 0);
  signal mac_tx_tvalid      : std_logic;
  signal mac_tx_tready      : std_logic;
  signal mac_tx_tlast       : std_logic;
  -- control signals
  signal mac_tx_tready_int  : std_logic;
  signal mac_tx_granted_int : std_logic;


begin


  process (mac_tx_clock)
  begin
    -- output followers
    clk_out <= mac_tx_clock;
  end process;

  ------------------------------------------------------------------------------
  -- Instantiate the UDP layer
  ------------------------------------------------------------------------------

  udp_block : UDP_Complete_nomac
    generic map (
      CLOCK_FREQ      => CLOCK_FREQ,
      ARP_TIMEOUT     => ARP_TIMEOUT,
      ARP_MAX_PKT_TMO => ARP_MAX_PKT_TMO,
      MAX_ARP_ENTRIES => MAX_ARP_ENTRIES
      )
    port map (
      -- UDP TX signals
      udp_tx_start          => udp_tx_start,
      udp_txi               => udp_txi,
      udp_tx_result         => udp_tx_result,
      udp_tx_data_out_ready => udp_tx_data_out_ready,
      -- UDP RX signals
      udp_rx_start          => udp_rx_start,
      udp_rxo               => udp_rxo,
      -- IP RX signals
      ip_rx_hdr             => ip_rx_hdr,
      -- system signals
      rx_clk                => mac_rx_clock,
      tx_clk                => mac_tx_clock,
      reset                 => reset,
      our_ip_address        => our_ip_address,
      our_mac_address       => our_mac_address,
      -- status signals
      arp_pkt_count         => arp_pkt_count,
      ip_pkt_count          => ip_pkt_count,
      control               => control,
      -- MAC Transmitter
      mac_tx_tready         => mac_tx_tready_int,
      mac_tx_tvalid         => mac_tx_tvalid,
      mac_tx_tfirst         => open,
      mac_tx_tlast          => mac_tx_tlast,
      mac_tx_tdata          => mac_tx_tdata,
      -- MAC Receiver
      mac_rx_tdata          => mac_rx_tdata,
      mac_rx_tvalid         => mac_rx_tvalid,
      mac_rx_tready         => mac_rx_tready,
      mac_rx_tlast          => mac_rx_tlast
      );


  ------------------------------------------------------------------------------
  -- Instantiate the MAC layer
  ------------------------------------------------------------------------------
  mac_block : mac_v2_2
--      mac_block : xv6mac_straight
    port map(
      -- System controls
      ------------------
      glbl_rst  => reset,
      mac_reset => '0',
      clk_in_p  => clk_in_p,
      clk_in_n  => clk_in_n,

      -- MAC Transmitter (AXI-S) Interface
      ---------------------------------------------
      mac_tx_clock  => mac_tx_clock,
      mac_tx_tdata  => mac_tx_tdata,
      mac_tx_tvalid => mac_tx_tvalid,
      mac_tx_tready => mac_tx_tready_int,
      mac_tx_tlast  => mac_tx_tlast,

      -- MAC Receiver (AXI-S) Interface
      ------------------------------------------
      mac_rx_clock  => mac_rx_clock,
      mac_rx_tdata  => mac_rx_tdata,
      mac_rx_tvalid => mac_rx_tvalid,
      mac_rx_tready => mac_rx_tready,
      mac_rx_tlast  => mac_rx_tlast,

      -- GMII Interface
      -----------------     
      phy_resetn  => phy_resetn,
      gmii_txd    => gmii_txd,
      gmii_tx_en  => gmii_tx_en,
      gmii_tx_er  => gmii_tx_er,
      gmii_tx_clk => gmii_tx_clk,
      gmii_rxd    => gmii_rxd,
      gmii_rx_dv  => gmii_rx_dv,
      gmii_rx_er  => gmii_rx_er,
      gmii_rx_clk => gmii_rx_clk,
      gmii_col    => gmii_col,
      gmii_crs    => gmii_crs,
      mii_tx_clk  => mii_tx_clk
      );


end structural;


