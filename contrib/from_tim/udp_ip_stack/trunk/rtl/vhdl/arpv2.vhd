----------------------------------------------------------------------------------
-- Company: 
-- Engineer:            Peter Fall
-- 
-- Create Date:    12:00:04 05/31/2011 
-- Design Name: 
-- Module Name:    arpv2 - Structural 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:
--              handle simple IP lookup in 1-deep cache and arp store
--              request cache fill through ARP protocol if required
--              Handle ARP protocol
--              Respond to ARP requests and replies
--              Ignore pkts that are not ARP
--              Ignore pkts that are not addressed to us
--
--              structural decomposition includes
--                      arp TX block            - encoding of ARP protocol
--                      arp RX block            - decoding of ARP protocol
--                      arp REQ block           - sequencing requests for resolution
--                      arp STORE block - storing address resolution entries (indexed by IP addr)
--                      arp sync block          - sync between master RX clock and TX clock domains
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.arp_types.all;

entity arpv2 is
  generic (
    no_default_gateway : boolean := true;  -- set to false if communicating with devices accessed
                                            -- though a "default gateway or router"
    CLOCK_FREQ      : integer := 125000000;  -- freq of data_in_clk -- needed to timout cntr
    ARP_TIMEOUT     : integer := 60;    -- ARP response timeout (s)
    ARP_MAX_PKT_TMO : integer := 5;     -- # wrong nwk pkts received before set error
    MAX_ARP_ENTRIES : integer := 255    -- max entries in the arp store
    );
  port (
    -- lookup request signals
    arp_req_req     : in  arp_req_req_type;
    arp_req_rslt    : out arp_req_rslt_type;
    -- MAC layer RX signals
    data_in_clk     : in  std_logic;
    reset           : in  std_logic;
    data_in         : in  std_logic_vector (7 downto 0);  -- ethernet frame (from dst mac addr through to last byte of frame)
    data_in_valid   : in  std_logic;    -- indicates data_in valid on clock
    data_in_last    : in  std_logic;    -- indicates last data in frame
    -- MAC layer TX signals
    mac_tx_req      : out std_logic;  -- indicates that ip wants access to channel (stays up for as long as tx)
    mac_tx_granted  : in  std_logic;  -- indicates that access to channel has been granted            
    data_out_clk    : in  std_logic;
    data_out_ready  : in  std_logic;    -- indicates system ready to consume data
    data_out_valid  : out std_logic;    -- indicates data out is valid
    data_out_first  : out std_logic;  -- with data out valid indicates the first byte of a frame
    data_out_last   : out std_logic;  -- with data out valid indicates the last byte of a frame
    data_out        : out std_logic_vector (7 downto 0);  -- ethernet frame (from dst mac addr through to last byte of frame)
    -- system signals
    our_mac_address : in  std_logic_vector (47 downto 0);
    our_ip_address  : in  std_logic_vector (31 downto 0);
    nwk_gateway     : in  std_logic_vector (31 downto 0) := (others => '0');  -- IP address of default gateway
    nwk_mask        : in  std_logic_vector (31 downto 0) := (others => '0');  -- Net mask
    control         : in  arp_control_type;
    req_count       : out std_logic_vector(7 downto 0)    -- count of arp pkts received
    );
end arpv2;

architecture structural of arpv2 is

  component arp_req
    generic (
      no_default_gateway : boolean := true;
      CLOCK_FREQ      : integer := 125000000;  -- freq of data_in_clk -- needed to timout cntr
      ARP_TIMEOUT     : integer := 60;  -- ARP response timeout (s)
      ARP_MAX_PKT_TMO : integer := 5    -- # wrong nwk pkts received before set error
      );
    port (
      -- lookup request signals
      arp_req_req      : in  arp_req_req_type;   -- request for a translation from IP to MAC
      arp_req_rslt     : out arp_req_rslt_type;  -- the result
      -- external arp store signals
      arp_store_req    : out arp_store_rdrequest_t;          -- requesting a lookup or store
      arp_store_result : in  arp_store_result_t;             -- the result
      -- network request signals
      arp_nwk_req      : out arp_nwk_request_t;  -- requesting resolution via the network
      arp_nwk_result   : in  arp_nwk_result_t;   -- the result
      -- system signals
      clear_cache      : in  std_logic;          -- clear the internal cache
      nwk_gateway      : in  std_logic_vector(31 downto 0);  -- IP address of default gateway
      nwk_mask         : in  std_logic_vector(31 downto 0);  -- Net mask
      clk              : in  std_logic;
      reset            : in  std_logic
      );
  end component;

  component arp_tx
    port(
      -- control signals
      send_I_have     : in  std_logic;  -- pulse will be latched
      arp_entry       : in  arp_entry_t;  -- arp target for I_have req (will be latched)
      send_who_has    : in  std_logic;  -- pulse will be latched
      ip_entry        : in  std_logic_vector (31 downto 0);  -- ip target for who_has req (will be latched)
      -- MAC layer TX signals
      mac_tx_req      : out std_logic;  -- indicates that ip wants access to channel (stays up for as long as tx)
      mac_tx_granted  : in  std_logic;  -- indicates that access to channel has been granted            
      data_out_ready  : in  std_logic;  -- indicates system ready to consume data
      data_out_valid  : out std_logic;  -- indicates data out is valid
      data_out_first  : out std_logic;  -- with data out valid indicates the first byte of a frame
      data_out_last   : out std_logic;  -- with data out valid indicates the last byte of a frame
      data_out        : out std_logic_vector (7 downto 0);  -- ethernet frame (from dst mac addr through to last byte of frame)
      -- system signals
      our_mac_address : in  std_logic_vector (47 downto 0);
      our_ip_address  : in  std_logic_vector (31 downto 0);
      tx_clk          : in  std_logic;
      reset           : in  std_logic
      );
  end component;

  component arp_rx
    port(
      -- MAC layer RX signals
      data_in               : in  std_logic_vector (7 downto 0);  -- ethernet frame (from dst mac addr through to last byte of frame)
      data_in_valid         : in  std_logic;    -- indicates data_in valid on clock
      data_in_last          : in  std_logic;    -- indicates last data in frame
      -- ARP output signals
      recv_who_has          : out std_logic;    -- pulse will be latched
      arp_entry_for_who_has : out arp_entry_t;  -- target for who_has msg (Iie, who to reply to)
      recv_I_have           : out std_logic;    -- pulse will be latched
      arp_entry_for_I_have  : out arp_entry_t;  -- arp target for I_have msg
      -- control and status signals
      req_count             : out std_logic_vector(7 downto 0);   -- count of arp pkts received
      -- system signals
      our_ip_address        : in  std_logic_vector (31 downto 0);
      rx_clk                : in  std_logic;
      reset                 : in  std_logic
      );
  end component;


  component arp_store_br
    generic (
      MAX_ARP_ENTRIES : integer := 255          -- max entries in the store
      );
    port (
      -- read signals
      read_req    : in  arp_store_rdrequest_t;  -- requesting a lookup or store
      read_result : out arp_store_result_t;     -- the result
      -- write signals
      write_req   : in  arp_store_wrrequest_t;  -- requesting a lookup or store
      -- control and status signals
      clear_store : in  std_logic;              -- erase all entries
      entry_count : out unsigned(7 downto 0);   -- how many entries currently in store
      -- system signals
      clk         : in  std_logic;
      reset       : in  std_logic
      );
  end component;

  component arp_sync
    port (
      -- REQ to TX
      arp_nwk_req           : in  arp_nwk_request_t;  -- request for a translation from IP to MAC
      send_who_has          : out std_logic;
      ip_entry              : out std_logic_vector (31 downto 0);
      -- RX to TX
      recv_who_has          : in  std_logic;          -- this is for us, we will respond
      arp_entry_for_who_has : in  arp_entry_t;
      send_I_have           : out std_logic;
      arp_entry             : out arp_entry_t;
      -- RX to REQ
      I_have_received       : in  std_logic;
      nwk_result_status     : out arp_nwk_rslt_t;
      -- System Signals
      rx_clk                : in  std_logic;
      tx_clk                : in  std_logic;
      reset                 : in  std_logic
      );
  end component;


  -- interconnect REQ -> ARP_TX
  signal arp_nwk_req_int : arp_nwk_request_t;  -- tx req from REQ

  signal send_I_have_int  : std_logic;
  signal arp_entry_int    : arp_entry_t;
  signal send_who_has_int : std_logic;
  signal ip_entry_int     : std_logic_vector (31 downto 0);

  -- interconnect REQ <-> ARP_STORE
  signal arp_store_req_int    : arp_store_rdrequest_t;  -- lookup request
  signal arp_store_result_int : arp_store_result_t;     -- lookup result

  -- interconnect ARP_RX -> REQ
  signal nwk_result_status_int : arp_nwk_rslt_t;  -- response from a TX req

  -- interconnect ARP_RX -> ARP_STORE
  signal recv_I_have_int          : std_logic;  -- path to store new arp entry
  signal arp_entry_for_I_have_int : arp_entry_t;

  -- interconnect ARP_RX -> ARP_TX
  signal recv_who_has_int          : std_logic;    -- path for reply when we can anser
  signal arp_entry_for_who_has_int : arp_entry_t;  -- target for who_has msg (ie, who to reply to)
  

begin


  req : arp_req
    generic map (
      no_default_gateway => no_default_gateway,
      CLOCK_FREQ      => CLOCK_FREQ,
      ARP_TIMEOUT     => ARP_TIMEOUT,
      ARP_MAX_PKT_TMO => ARP_MAX_PKT_TMO
      )
    port map (
      -- lookup request signals
      arp_req_req           => arp_req_req,
      arp_req_rslt          => arp_req_rslt,
      -- external arp store signals
      arp_store_req         => arp_store_req_int,
      arp_store_result      => arp_store_result_int,
      -- network request signals
      arp_nwk_req           => arp_nwk_req_int,
      arp_nwk_result.status => nwk_result_status_int,
      arp_nwk_result.entry  => arp_entry_for_I_have_int,
      -- system signals
      clear_cache           => control.clear_cache,
      nwk_gateway           => nwk_gateway,
      nwk_mask              => nwk_mask,
      clk                   => data_in_clk,
      reset                 => reset
      );

  sync : arp_sync port map (
    -- REQ to TX
    arp_nwk_req           => arp_nwk_req_int,
    send_who_has          => send_who_has_int,
    ip_entry              => ip_entry_int,
    -- RX to TX
    recv_who_has          => recv_who_has_int,
    arp_entry_for_who_has => arp_entry_for_who_has_int,
    send_I_have           => send_I_have_int,
    arp_entry             => arp_entry_int,
    -- RX to REQ
    I_have_received       => recv_I_have_int,
    nwk_result_status     => nwk_result_status_int,
    -- system
    rx_clk                => data_in_clk,
    tx_clk                => data_out_clk,
    reset                 => reset
    );

  tx : arp_tx port map (
    -- control signals
    send_I_have     => send_I_have_int,
    arp_entry       => arp_entry_int,
    send_who_has    => send_who_has_int,
    ip_entry        => ip_entry_int,
    -- MAC layer TX signals
    mac_tx_req      => mac_tx_req,
    mac_tx_granted  => mac_tx_granted,
    data_out_ready  => data_out_ready,
    data_out_valid  => data_out_valid,
    data_out_first  => data_out_first,
    data_out_last   => data_out_last,
    data_out        => data_out,
    -- system signals
    our_ip_address  => our_ip_address,
    our_mac_address => our_mac_address,
    tx_clk          => data_out_clk,
    reset           => reset
    );

  rx : arp_rx port map (
    -- MAC layer RX signals
    data_in               => data_in,
    data_in_valid         => data_in_valid,
    data_in_last          => data_in_last,
    -- ARP output signals
    recv_who_has          => recv_who_has_int,
    arp_entry_for_who_has => arp_entry_for_who_has_int,
    recv_I_have           => recv_I_have_int,
    arp_entry_for_I_have  => arp_entry_for_I_have_int,
    -- control and status signals
    req_count             => req_count,
    -- system signals
    our_ip_address        => our_ip_address,
    rx_clk                => data_in_clk,
    reset                 => reset
    );

  store : arp_store_br
    generic map (
      MAX_ARP_ENTRIES => MAX_ARP_ENTRIES
      )
    port map (
      -- read signals
      read_req        => arp_store_req_int,
      read_result     => arp_store_result_int,
      -- write signals
      write_req.req   => recv_I_have_int,
      write_req.entry => arp_entry_for_I_have_int,
      -- control and status signals
      clear_store     => control.clear_cache,
      entry_count     => open,
      -- system signals
      clk             => data_in_clk,
      reset           => reset
      );


end structural;

