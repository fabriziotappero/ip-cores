--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:35:50 05/31/2011
-- Design Name:   
-- Module Name:   C:/Users/pjf/Documents/projects/fpga/xilinx/Network/arp1/arp_tb.vhd
-- Project Name:  arp1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: arp
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - Added tests for ARP timeout
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arp_types.all;

entity arpv2_tb is
end arpv2_tb;

architecture behavior of arpv2_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component arpv2
    generic (
      no_default_gateway : boolean := true;
      CLOCK_FREQ      : integer := 125000000;  -- freq of data_in_clk -- needed to timout cntr
      ARP_TIMEOUT     : integer := 60;  -- ARP response timeout (s)
      MAX_ARP_ENTRIES : integer := 255  -- max entries in the arp store
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
      nwk_gateway     : in  std_logic_vector (31 downto 0);  -- IP address of default gateway
      nwk_mask        : in  std_logic_vector (31 downto 0);  -- Net mask
      control         : in  arp_control_type;
      req_count       : out std_logic_vector(7 downto 0)    -- count of arp pkts received
      );
  end component;


  --Inputs
  signal clk             : std_logic                     := '0';
  signal reset           : std_logic                     := '0';
  signal data_in         : std_logic_vector(7 downto 0)  := (others => '0');
  signal data_in_valid   : std_logic                     := '0';
  signal data_in_last    : std_logic                     := '0';
  signal our_mac_address : std_logic_vector(47 downto 0) := (others => '0');
  signal our_ip_address  : std_logic_vector(31 downto 0) := (others => '0');
  signal nwk_gateway     : std_logic_vector(31 downto 0) := (others => '0');
  signal nwk_mask        : std_logic_vector(31 downto 0) := (others => '0');
  signal data_out_ready  : std_logic;
  signal data_out_valid  : std_logic;
  signal data_out_first  : std_logic;
  signal data_out_last   : std_logic;
  signal data_out        : std_logic_vector (7 downto 0);
  signal req_count       : std_logic_vector(7 downto 0);
  signal arp_req_req     : arp_req_req_type;
  signal arp_req_rslt    : arp_req_rslt_type;
  signal mac_tx_req      : std_logic;
  signal mac_tx_granted  : std_logic;
  signal control         : arp_control_type;

  constant no_default_gateway : boolean := false;

  -- Clock period definitions
  constant clk_period : time := 8 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : arpv2
    generic map (
      no_default_gateway => no_default_gateway,
      CLOCK_FREQ  => 10,                -- artificially low count to enable pragmatic testing
      ARP_TIMEOUT => 20
      )
    port map (
      -- lookup request mappings
      arp_req_req     => arp_req_req,
      arp_req_rslt    => arp_req_rslt,
      -- rx mappings
      data_in_clk     => clk,
      reset           => reset,
      data_in         => data_in,
      data_in_valid   => data_in_valid,
      data_in_last    => data_in_last,
      -- tx mappings
      mac_tx_req      => mac_tx_req,
      mac_tx_granted  => mac_tx_granted,
      data_out_clk    => clk,
      data_out_ready  => data_out_ready,
      data_out_valid  => data_out_valid,
      data_out_first  => data_out_first,
      data_out_last   => data_out_last,
      data_out        => data_out,
      -- system mappings
      our_mac_address => our_mac_address,
      our_ip_address  => our_ip_address,
      nwk_gateway     => nwk_gateway,
      nwk_mask        => nwk_mask,
      control         => control,
      req_count       => req_count
      );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    our_ip_address      <= x"c0a80509";  -- 192.168.5.9
    nwk_mask            <= x"FFFFFF00";
    nwk_gateway         <= x"c0a80501";  -- 192.168.5.9
    our_mac_address     <= x"002320212223";
    mac_tx_granted      <= '1';          -- FIXME 0
    control.clear_cache <= '0';

    reset <= '1';
    wait for clk_period*10;
    reset <= '0';
    wait for clk_period*5;

    assert mac_tx_req = '0' report "mac_tx_req asserted on reset";

    wait until clk = '1';
    
    -- insert stimulus here
    arp_req_req.lookup_req <= '0';
    arp_req_req.ip         <= (others => '0');
    data_out_ready         <= '1';

    report "T1:  Send an ARP request: who has 192.168.5.9? Tell 192.168.5.1";
    data_in_valid <= '1';
    -- dst MAC (bc)
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    -- src MAC
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"18"; wait for clk_period;
    data_in       <= x"29"; wait for clk_period;
    data_in       <= x"26"; wait for clk_period;
    data_in       <= x"7c"; wait for clk_period;
    -- type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"06"; wait for clk_period;
    -- HW type
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Protocol type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    -- HW size
    data_in       <= x"06"; wait for clk_period;
    -- protocol size
    data_in       <= x"04"; wait for clk_period;
    -- Opcode
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Sender MAC
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"18"; wait for clk_period;
    data_in       <= x"29"; wait for clk_period;
    data_in       <= x"26"; wait for clk_period;
    data_in       <= x"7c"; wait for clk_period;
    -- Sender IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Target MAC
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    -- Target IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"09"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '1';
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '0';
    data_in_valid <= '0';

    report "T1:  Expect that we send an 'I have 192.168.5.9' msg";

    -- check tx arbitration signals

    report "T1: waiting for tx req";
    wait until mac_tx_req = '1';

    -- ready to tx
    data_out_ready <= '1';
    mac_tx_granted <= '1';
    report "T1: waiting for data_out_valid";
    wait until data_out_valid = '1';
    report "T1: got data_out_valid";
    wait for clk_period*10;
    data_out_ready <= '0';
    wait for clk_period*2;
    data_out_ready <= '1';
    wait for clk_period*12;
    assert data_out = x"02" report "T1: expected opcode = 02 for reply 'I have'";
    -- expect our mac 00 23 20 21 22 23
    wait for clk_period;
    assert data_out = x"00" report "T1: incorrect our mac.0";
    wait for clk_period;
    assert data_out = x"23" report "T1: incorrect our mac.1";
    wait for clk_period;
    assert data_out = x"20" report "T1: incorrect our mac.2";
    wait for clk_period;
    assert data_out = x"21" report "T1: incorrect our mac.3";
    wait for clk_period;
    assert data_out = x"22" report "T1: incorrect our mac.4";
    wait for clk_period;
    assert data_out = x"23" report "T1: incorrect our mac.5";
    -- expect our IP c0 a8 05 05
    wait for clk_period;
    assert data_out = x"c0" report "T1: incorrect our IP.0";
    wait for clk_period;
    assert data_out = x"a8" report "T1: incorrect our IP.1";
    wait for clk_period;
    assert data_out = x"05" report "T1: incorrect our IP.2";
    wait for clk_period;
    assert data_out = x"09" report "T1: incorrect our IP.3";

    -- expect target mac 00 23 18 29 26 7c
    wait for clk_period;
    assert data_out = x"00" report "T1: incorrect target mac.0";
    wait for clk_period;
    assert data_out = x"23" report "T1: incorrect target mac.1";
    wait for clk_period;
    assert data_out = x"18" report "T1: incorrect target mac.2";
    wait for clk_period;
    assert data_out = x"29" report "T1: incorrect target mac.3";
    wait for clk_period;
    assert data_out = x"26" report "T1: incorrect target mac.4";
    wait for clk_period;
    assert data_out = x"7c" report "T1: incorrect target mac.5";
    -- expect target IP c0 a8 05 01
    wait for clk_period;
    assert data_out = x"c0" report "T1: incorrect target IP.0";
    wait for clk_period;
    assert data_out = x"a8" report "T1: incorrect target IP.1";
    wait for clk_period;
    assert data_out = x"05" report "T1: incorrect target IP.2";
    assert data_out_last = '0' report "T1: data out last incorrectly set on target IP.2 byte";
    wait for clk_period;
    assert data_out = x"01" report "T1: incorrect target IP.3";
    assert data_out_last = '1' report "T1: data out last should be set";

    wait for clk_period*10;

    report "T2: Send another ARP request: who has 192.168.5.8? Tell 192.168.5.1, holding off transmitter";
    data_out_ready <= '0';
    data_in_valid  <= '1';
    -- dst MAC (bc)
    data_in        <= x"ff"; wait for clk_period;
    data_in        <= x"ff"; wait for clk_period;
    data_in        <= x"ff"; wait for clk_period;
    data_in        <= x"ff"; wait for clk_period;
    data_in        <= x"ff"; wait for clk_period;
    data_in        <= x"ff"; wait for clk_period;
    -- src MAC
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"23"; wait for clk_period;
    data_in        <= x"18"; wait for clk_period;
    data_in        <= x"29"; wait for clk_period;
    data_in        <= x"26"; wait for clk_period;
    data_in        <= x"7c"; wait for clk_period;
    -- type
    data_in        <= x"08"; wait for clk_period;
    data_in        <= x"06"; wait for clk_period;
    -- HW type
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"01"; wait for clk_period;
    -- Protocol type
    data_in        <= x"08"; wait for clk_period;
    data_in        <= x"00"; wait for clk_period;
    -- HW size
    data_in        <= x"06"; wait for clk_period;
    -- protocol size
    data_in        <= x"04"; wait for clk_period;
    -- Opcode
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"01"; wait for clk_period;
    -- Sender MAC
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"23"; wait for clk_period;
    data_in        <= x"18"; wait for clk_period;
    data_in        <= x"29"; wait for clk_period;
    data_in        <= x"26"; wait for clk_period;
    data_in        <= x"7c"; wait for clk_period;
    -- Sender IP
    data_in        <= x"c0"; wait for clk_period;
    data_in        <= x"a8"; wait for clk_period;
    data_in        <= x"05"; wait for clk_period;
    data_in        <= x"01"; wait for clk_period;
    -- Target MAC
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"00"; wait for clk_period;
    -- Target IP
    data_in        <= x"c0"; wait for clk_period;
    data_in        <= x"a8"; wait for clk_period;
    data_in        <= x"05"; wait for clk_period;
    data_in        <= x"09"; wait for clk_period;
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"00"; wait for clk_period;
    data_in        <= x"00"; wait for clk_period;
    data_in_last   <= '1';
    data_in        <= x"00"; wait for clk_period;
    data_in_last   <= '0';
    data_in_valid  <= '0';

    -- ready to tx
    wait for clk_period*10;
    data_out_ready <= '1';

    wait for clk_period*50;

    report "T3: Send a request for the IP that is already in the store";
    arp_req_req.ip         <= x"c0a80501";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    arp_req_req.lookup_req <= '0';
    report "T3: wait for reply from store";
    wait until arp_req_rslt.got_mac = '1' or arp_req_rslt.got_err = '1';
    assert arp_req_rslt.got_mac = '1' report "T3: expected got mac";
    assert arp_req_rslt.got_err = '0' report "T3: expected got err = 0";
    assert arp_req_rslt.mac = x"00231829267c" report "T3: wrong mac value";
    wait for clk_period*2;

    -- the entry that was in the store should now be in the cache - check it
    report "T4: Send a request for the IP that is already in the cache";
    arp_req_req.ip         <= x"c0a80501";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    arp_req_req.lookup_req <= '0';
    assert arp_req_rslt.got_mac = '1' report "T4: expected got mac";
    assert arp_req_rslt.got_err = '0' report "T4: expected got err = 0";
    assert arp_req_rslt.mac = x"00231829267c" report "T4: wrong mac value";

    wait for clk_period*50;

    report "T5 - Send a request for the IP that is not cached or in the store";
    arp_req_req.ip         <= x"c0a80503";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    arp_req_req.lookup_req <= '0';
    report "T5: waiting for data_out_valid";
    wait until data_out_valid = '1';
    report "T5: got data_out_valid";
    wait for clk_period*10;
    data_out_ready         <= '0';
    wait for clk_period*2;
    data_out_ready         <= '1';
    wait for clk_period*12;
    assert data_out = x"01" report "T5: expected opcode = 01 for request 'who has'";
    -- expect our mac 00 23 20 21 22 23
    wait for clk_period;
    assert data_out = x"00" report "T5: incorrect our mac.0";
    wait for clk_period;
    assert data_out = x"23" report "T5: incorrect our mac.1";
    wait for clk_period;
    assert data_out = x"20" report "T5: incorrect our mac.2";
    wait for clk_period;
    assert data_out = x"21" report "T5: incorrect our mac.3";
    wait for clk_period;
    assert data_out = x"22" report "T5: incorrect our mac.4";
    wait for clk_period;
    assert data_out = x"23" report "T5: incorrect our mac.5";
    -- expect our IP c0 a8 05 05
    wait for clk_period;
    assert data_out = x"c0" report "T5: incorrect our IP.0";
    wait for clk_period;
    assert data_out = x"a8" report "T5: incorrect our IP.1";
    wait for clk_period;
    assert data_out = x"05" report "T5: incorrect our IP.2";
    wait for clk_period;
    assert data_out = x"09" report "T5: incorrect our IP.3";

    -- expect empty target mac 
    wait for clk_period;
    assert data_out = x"ff" report "T5: incorrect target mac.0";
    wait for clk_period;
    assert data_out = x"ff" report "T5: incorrect target mac.1";
    wait for clk_period;
    assert data_out = x"ff" report "T5: incorrect target mac.2";
    wait for clk_period;
    assert data_out = x"ff" report "T5: incorrect target mac.3";
    wait for clk_period;
    assert data_out = x"ff" report "T5: incorrect target mac.4";
    wait for clk_period;
    assert data_out = x"ff" report "T5: incorrect target mac.5";
    -- expect target IP c0 a8 05 01
    wait for clk_period;
    assert data_out = x"c0" report "T5: incorrect target IP.0";
    wait for clk_period;
    assert data_out = x"a8" report "T5: incorrect target IP.1";
    wait for clk_period;
    assert data_out = x"05" report "T5: incorrect target IP.2";
    assert data_out_last = '0' report "T5: data out last incorrectly set on target IP.2 byte";
    wait for clk_period;
    assert data_out = x"03" report "T5: incorrect target IP.3";
    assert data_out_last = '1' report "T5: data out last should be set";

    wait for clk_period*10;

    -- Send the reply
    data_out_ready <= '1';

    report "T5.2: Send an ARP reply: 192.168.5.3 has mac 02:12:03:23:04:54";
    data_in_valid <= '1';
    -- dst MAC (bc)
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    -- src MAC
    data_in       <= x"02"; wait for clk_period;
    data_in       <= x"12"; wait for clk_period;
    data_in       <= x"03"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"04"; wait for clk_period;
    data_in       <= x"54"; wait for clk_period;
    -- type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"06"; wait for clk_period;
    -- HW type
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Protocol type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    -- HW size
    data_in       <= x"06"; wait for clk_period;
    -- protocol size
    data_in       <= x"04"; wait for clk_period;
    -- Opcode
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"02"; wait for clk_period;
    -- Sender MAC
    data_in       <= x"02"; wait for clk_period;
    data_in       <= x"12"; wait for clk_period;
    data_in       <= x"03"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"04"; wait for clk_period;
    data_in       <= x"54"; wait for clk_period;
    -- Sender IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"03"; wait for clk_period;
    -- Target MAC
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"20"; wait for clk_period;
    data_in       <= x"21"; wait for clk_period;
    data_in       <= x"22"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    -- Target IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"09"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    assert arp_req_rslt.got_mac = '1' report "T5.2: expected got mac";
    assert arp_req_rslt.got_err = '0' report "T5.2: expected got err = 0";
    assert arp_req_rslt.mac = x"021203230454" report "T5.2: wrong mac value";
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '1';
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '0';
    data_in_valid <= '0';
    wait for clk_period*4;

    report "T6: check that both these IPs remain in the store";
    arp_req_req.ip         <= x"c0a80501";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    arp_req_req.lookup_req <= '0';
    wait for clk_period;
    report "T6.1: wait for reply from store";
    wait until arp_req_rslt.got_mac = '1' or arp_req_rslt.got_err = '1';
    assert arp_req_rslt.got_mac = '1' report "T6.1: expected got mac";
    assert arp_req_rslt.got_err = '0' report "T6.1: expected got err = 0";
    assert arp_req_rslt.mac = x"00231829267c" report "T6.1: wrong mac value";
    wait for clk_period*2;

    arp_req_req.ip         <= x"c0a80503";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    arp_req_req.lookup_req <= '0';
    wait for clk_period;
    report "T6.2: wait for reply from store";
    wait until arp_req_rslt.got_mac = '1' or arp_req_rslt.got_err = '1';
    assert arp_req_rslt.got_mac = '1' report "T6.2: expected got mac";
    assert arp_req_rslt.got_err = '0' report "T6.2: expected got err = 0";
    assert arp_req_rslt.mac = x"021203230454" report "T6.2: wrong mac value";
    wait for clk_period*2;

    report "T7 - test that receipt of wrong I Have does not satisfy a current req";
    arp_req_req.ip         <= x"c0a8050e";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    arp_req_req.lookup_req <= '0';
    report "T7: waiting for data_out_valid";
    wait until data_out_valid = '1';
    report "T7: got data_out_valid";
    wait for clk_period*10;
    data_out_ready         <= '0';
    wait for clk_period*2;
    data_out_ready         <= '1';
    wait for clk_period*12;
    assert data_out = x"01" report "T7: expected opcode = 01 for request 'who has'";
    -- expect our mac 00 23 20 21 22 23
    wait for clk_period;
    assert data_out = x"00" report "T7: incorrect our mac.0";
    wait for clk_period;
    assert data_out = x"23" report "T7: incorrect our mac.1";
    wait for clk_period;
    assert data_out = x"20" report "T7: incorrect our mac.2";
    wait for clk_period;
    assert data_out = x"21" report "T7: incorrect our mac.3";
    wait for clk_period;
    assert data_out = x"22" report "T7: incorrect our mac.4";
    wait for clk_period;
    assert data_out = x"23" report "T7: incorrect our mac.5";
    -- expect our IP c0 a8 05 05
    wait for clk_period;
    assert data_out = x"c0" report "T7: incorrect our IP.0";
    wait for clk_period;
    assert data_out = x"a8" report "T7: incorrect our IP.1";
    wait for clk_period;
    assert data_out = x"05" report "T7: incorrect our IP.2";
    wait for clk_period;
    assert data_out = x"09" report "T7: incorrect our IP.3";

    -- expect empty target mac
    wait for clk_period;
    assert data_out = x"ff" report "T7: incorrect target mac.0";
    wait for clk_period;
    assert data_out = x"ff" report "T7: incorrect target mac.1";
    wait for clk_period;
    assert data_out = x"ff" report "T7: incorrect target mac.2";
    wait for clk_period;
    assert data_out = x"ff" report "T7: incorrect target mac.3";
    wait for clk_period;
    assert data_out = x"ff" report "T7: incorrect target mac.4";
    wait for clk_period;
    assert data_out = x"ff" report "T7: incorrect target mac.5";
    -- expect target IP c0 a8 05 0e
    wait for clk_period;
    assert data_out = x"c0" report "T7: incorrect target IP.0";
    wait for clk_period;
    assert data_out = x"a8" report "T7: incorrect target IP.1";
    wait for clk_period;
    assert data_out = x"05" report "T7: incorrect target IP.2";
    assert data_out_last = '0' report "T7: data out last incorrectly set on target IP.2 byte";
    wait for clk_period;
    assert data_out = x"0e" report "T7: incorrect target IP.3";
    assert data_out_last = '1' report "T7: data out last should be set";

    wait for clk_period*10;

    -- Send the reply
    data_out_ready <= '1';

    report "T7.2: Send an arbitrary unwanted ARP reply: 192.168.5.143 has mac 57:12:34:19:23:9a";
    data_in_valid <= '1';
    -- dst MAC (bc)
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    -- src MAC
    data_in       <= x"57"; wait for clk_period;
    data_in       <= x"12"; wait for clk_period;
    data_in       <= x"34"; wait for clk_period;
    data_in       <= x"19"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"9a"; wait for clk_period;
    -- type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"06"; wait for clk_period;
    -- HW type
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Protocol type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    -- HW size
    data_in       <= x"06"; wait for clk_period;
    -- protocol size
    data_in       <= x"04"; wait for clk_period;
    -- Opcode
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"02"; wait for clk_period;
    -- Sender MAC
    data_in       <= x"57"; wait for clk_period;
    data_in       <= x"12"; wait for clk_period;
    data_in       <= x"34"; wait for clk_period;
    data_in       <= x"19"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"9a"; wait for clk_period;
    -- Sender IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"25"; wait for clk_period;
    data_in       <= x"93"; wait for clk_period;
    -- Target MAC
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"20"; wait for clk_period;
    data_in       <= x"21"; wait for clk_period;
    data_in       <= x"22"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    -- Target IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"09"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '1';
    data_in       <= x"00"; wait for clk_period;
    assert arp_req_rslt.got_mac = '0' report "T7.2: expected got mac = 0";
    assert arp_req_rslt.got_err = '0' report "T7.2: expected got err = 0";
    data_in_last  <= '0';
    data_in_valid <= '0';
    wait for clk_period*4;

    -- Send the reply
    data_out_ready <= '1';

    report "T7.3: Send a wanted ARP reply: 192.168.5.e has mac 76:34:98:55:aa:37";
    data_in_valid <= '1';
    -- dst MAC (bc)
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    -- src MAC
    data_in       <= x"76"; wait for clk_period;
    data_in       <= x"34"; wait for clk_period;
    data_in       <= x"98"; wait for clk_period;
    data_in       <= x"55"; wait for clk_period;
    data_in       <= x"aa"; wait for clk_period;
    data_in       <= x"37"; wait for clk_period;
    -- type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"06"; wait for clk_period;
    -- HW type
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Protocol type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    -- HW size
    data_in       <= x"06"; wait for clk_period;
    -- protocol size
    data_in       <= x"04"; wait for clk_period;
    -- Opcode
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"02"; wait for clk_period;
    -- Sender MAC
    data_in       <= x"76"; wait for clk_period;
    data_in       <= x"34"; wait for clk_period;
    data_in       <= x"98"; wait for clk_period;
    data_in       <= x"55"; wait for clk_period;
    data_in       <= x"aa"; wait for clk_period;
    data_in       <= x"37"; wait for clk_period;
    -- Sender IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"0e"; wait for clk_period;
    -- Target MAC
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"20"; wait for clk_period;
    data_in       <= x"21"; wait for clk_period;
    data_in       <= x"22"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    -- Target IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"09"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    assert arp_req_rslt.got_mac = '1' report "T7.3: expected got mac";
    assert arp_req_rslt.got_err = '0' report "T7.3: expected got err = 0";
    assert arp_req_rslt.mac = x"76349855aa37" report "T7.3: wrong mac value";
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '1';
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '0';
    data_in_valid <= '0';
    wait for clk_period*4;


    report "T8: Request 192.168.5.4 (not cached), dont send a reply and wait for timeout";
    arp_req_req.ip         <= x"c0a80504";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    arp_req_req.lookup_req <= '0';
    wait for clk_period*20;
    assert mac_tx_req = '1' report "T8: should be requesting TX channel";
    wait for clk_period*220;
    assert arp_req_rslt.got_mac = '0' report "T8: should not have got mac";
    assert arp_req_rslt.got_err = '1' report "T8: should have got err";

    report "T9: Request 192.168.5.7 (not cached= and Send an ARP reply: 192.168.5.7 has mac 02:15:03:23:04:54";
    arp_req_req.ip         <= x"c0a80507";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    assert arp_req_rslt.got_mac = '0' report "T9: should not yet have mac";
    assert arp_req_rslt.got_err = '0' report "T9: should not have got err";

    arp_req_req.lookup_req <= '0';
    wait for clk_period*20;
    assert mac_tx_req = '1' report "T9: should be requesting TX channel";
    wait for clk_period*50;
    -- Send the reply
    data_out_ready         <= '1';

    data_in_valid <= '1';
    -- dst MAC (bc)
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    -- src MAC
    data_in       <= x"02"; wait for clk_period;
    data_in       <= x"15"; wait for clk_period;
    data_in       <= x"03"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"04"; wait for clk_period;
    data_in       <= x"54"; wait for clk_period;
    -- type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"06"; wait for clk_period;
    -- HW type
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Protocol type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    -- HW size
    data_in       <= x"06"; wait for clk_period;
    -- protocol size
    data_in       <= x"04"; wait for clk_period;
    -- Opcode
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"02"; wait for clk_period;
    -- Sender MAC
    data_in       <= x"02"; wait for clk_period;
    data_in       <= x"15"; wait for clk_period;
    data_in       <= x"03"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"04"; wait for clk_period;
    data_in       <= x"54"; wait for clk_period;
    -- Sender IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"07"; wait for clk_period;
    -- Target MAC
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"20"; wait for clk_period;
    data_in       <= x"21"; wait for clk_period;
    data_in       <= x"22"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    -- Target IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"09"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '1';
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '0';
    data_in_valid <= '0';
    wait for clk_period;
    assert arp_req_rslt.got_mac = '1' report "T9: should have got mac";
    assert arp_req_rslt.mac = x"021503230454" report "T9: incorrect mac";
    assert arp_req_rslt.got_err = '0' report "T9: should not have got err";
    wait for clk_period*10;

    report "T10: Request 192.168.5.7 again an expect it to be in the cache";
    arp_req_req.ip         <= x"c0a80507";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    assert arp_req_rslt.got_mac = '1' report "T10: should have mac";
    assert arp_req_rslt.got_err = '0' report "T10: should not have got err";

    arp_req_req.lookup_req <= '0';
    wait for clk_period*20;
    
--
    wait until clk = '1';
    report "T11 - Send a request for the IP that is not on the local network";
    arp_req_req.ip         <= x"0a000003";  --c0a80501
    arp_req_req.lookup_req <= '1';
    wait until clk = '1';               --for clk_period
    arp_req_req.lookup_req <= '0';
    report "T11: wait for reply from store";
    wait until arp_req_rslt.got_mac = '1' or arp_req_rslt.got_err = '1';
    assert arp_req_rslt.got_mac = '1' report "T11: expected got mac";
    assert arp_req_rslt.got_err = '0' report "T11: expected got err = 0";
    assert arp_req_rslt.mac = x"00231829267c" report "T11: wrong mac value";-- severity failure;
    wait for clk_period*2;    
--

    report "T12: Clear the cache, Request 192.168.5.7 again an expect a 'who has' to be sent";
    control.clear_cache <= '1';
    wait for clk_period;
    control.clear_cache <= '0';
    wait for clk_period;

    arp_req_req.ip         <= x"c0a80507";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    assert arp_req_rslt.got_mac = '0' report "T12: should not yet have mac";
    assert arp_req_rslt.got_err = '0' report "T12: should not have got err";

    arp_req_req.lookup_req <= '0';
    wait for clk_period*20;


    assert mac_tx_req = '1' report "T12: should be requesting TX channel";
    wait for clk_period*50;
    -- Send the reply
    data_out_ready <= '1';

    data_in_valid <= '1';
    -- dst MAC (bc)
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    -- src MAC
    data_in       <= x"02"; wait for clk_period;
    data_in       <= x"15"; wait for clk_period;
    data_in       <= x"03"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"04"; wait for clk_period;
    data_in       <= x"54"; wait for clk_period;
    -- type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"06"; wait for clk_period;
    -- HW type
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Protocol type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    -- HW size
    data_in       <= x"06"; wait for clk_period;
    -- protocol size
    data_in       <= x"04"; wait for clk_period;
    -- Opcode
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"02"; wait for clk_period;
    -- Sender MAC
    data_in       <= x"02"; wait for clk_period;
    data_in       <= x"15"; wait for clk_period;
    data_in       <= x"03"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"55"; wait for clk_period;
    data_in       <= x"54"; wait for clk_period;
    -- Sender IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"07"; wait for clk_period;
    -- Target MAC
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"20"; wait for clk_period;
    data_in       <= x"21"; wait for clk_period;
    data_in       <= x"22"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    -- Target IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"09"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '1';
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '0';
    data_in_valid <= '0';
    wait for clk_period;
    assert arp_req_rslt.got_mac = '1' report "T12: should have got mac";
    assert arp_req_rslt.mac = x"021503235554" report "T12: incorrect mac";
    assert arp_req_rslt.got_err = '0' report "T12: should not have got err";
    wait for clk_period*10;

--    
    report "T13 - Send a request for the IP that is not on the local network";
    arp_req_req.ip         <= x"0a000003";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    arp_req_req.lookup_req <= '0';
    report "T13: waiting for data_out_valid";
    wait until data_out_valid = '1';
    report "T13: got data_out_valid";
    wait for clk_period*10;
    data_out_ready         <= '0';
    wait for clk_period*2;
    data_out_ready         <= '1';
    wait for clk_period*12;
    assert data_out = x"01" report "T13: expected opcode = 01 for request 'who has'";
    -- expect our mac 00 23 20 21 22 23
    wait for clk_period;
    assert data_out = x"00" report "T13: incorrect our mac.0";
    wait for clk_period;
    assert data_out = x"23" report "T13: incorrect our mac.1";
    wait for clk_period;
    assert data_out = x"20" report "T13: incorrect our mac.2";
    wait for clk_period;
    assert data_out = x"21" report "T13: incorrect our mac.3";
    wait for clk_period;
    assert data_out = x"22" report "T13: incorrect our mac.4";
    wait for clk_period;
    assert data_out = x"23" report "T13: incorrect our mac.5";
    -- expect our IP c0 a8 05 05
    wait for clk_period;
    assert data_out = x"c0" report "T13: incorrect our IP.0";
    wait for clk_period;
    assert data_out = x"a8" report "T13: incorrect our IP.1";
    wait for clk_period;
    assert data_out = x"05" report "T13: incorrect our IP.2";
    wait for clk_period;
    assert data_out = x"09" report "T13: incorrect our IP.3";

    -- expect empty target mac 
    wait for clk_period;
    assert data_out = x"ff" report "T13: incorrect target mac.0";
    wait for clk_period;
    assert data_out = x"ff" report "T13: incorrect target mac.1";
    wait for clk_period;
    assert data_out = x"ff" report "T13: incorrect target mac.2";
    wait for clk_period;
    assert data_out = x"ff" report "T13: incorrect target mac.3";
    wait for clk_period;
    assert data_out = x"ff" report "T13: incorrect target mac.4";
    wait for clk_period;
    assert data_out = x"ff" report "T13: incorrect target mac.5";
    -- expect target IP c0 a8 05 01
    wait for clk_period;
    assert data_out = x"c0" report "T13: incorrect target IP.0";
    wait for clk_period;
    assert data_out = x"a8" report "T13: incorrect target IP.1";
    wait for clk_period;
    assert data_out = x"05" report "T13: incorrect target IP.2";
    assert data_out_last = '0' report "T13: data out last incorrectly set on target IP.2 byte";
    wait for clk_period;
    assert data_out = x"01" report "T13: incorrect target IP.3";
    assert data_out_last = '1' report "T13: data out last should be set";

    wait for clk_period*10;

    -- Send the reply
    data_out_ready <= '1';

    report "T13.2: Send an ARP reply: 192.168.5.1 has mac 02:12:03:23:04:54";
    data_in_valid <= '1';
    -- dst MAC (bc)
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    data_in       <= x"ff"; wait for clk_period;
    -- src MAC
    data_in       <= x"02"; wait for clk_period;
    data_in       <= x"12"; wait for clk_period;
    data_in       <= x"03"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"04"; wait for clk_period;
    data_in       <= x"54"; wait for clk_period;
    -- type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"06"; wait for clk_period;
    -- HW type
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Protocol type
    data_in       <= x"08"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    -- HW size
    data_in       <= x"06"; wait for clk_period;
    -- protocol size
    data_in       <= x"04"; wait for clk_period;
    -- Opcode
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"02"; wait for clk_period;
    -- Sender MAC
    data_in       <= x"02"; wait for clk_period;
    data_in       <= x"12"; wait for clk_period;
    data_in       <= x"03"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"04"; wait for clk_period;
    data_in       <= x"54"; wait for clk_period;
    -- Sender IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"01"; wait for clk_period;
    -- Target MAC
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    data_in       <= x"20"; wait for clk_period;
    data_in       <= x"21"; wait for clk_period;
    data_in       <= x"22"; wait for clk_period;
    data_in       <= x"23"; wait for clk_period;
    -- Target IP
    data_in       <= x"c0"; wait for clk_period;
    data_in       <= x"a8"; wait for clk_period;
    data_in       <= x"05"; wait for clk_period;
    data_in       <= x"09"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    data_in       <= x"00"; wait for clk_period;
    assert arp_req_rslt.got_mac = '1' report "T13.2: expected got mac";
    assert arp_req_rslt.got_err = '0' report "T13.2: expected got err = 0";
    assert arp_req_rslt.mac = x"021203230454" report "T13.2: wrong mac value";
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '1';
    data_in       <= x"00"; wait for clk_period;
    data_in_last  <= '0';
    data_in_valid <= '0';
    wait for clk_period*4;

    report "T14 - Send a request for an other IP that is not on the local network";
    arp_req_req.ip         <= x"0a000204";
    arp_req_req.lookup_req <= '1';
    wait for clk_period;
    arp_req_req.lookup_req <= '0';
    report "T14: reply should be from cache";
--    wait until arp_req_rslt.got_mac = '1' or arp_req_rslt.got_err = '1';
    assert arp_req_rslt.got_mac = '1' report "T14: expected got mac";
    assert arp_req_rslt.got_err = '0' report "T14: expected got err = 0";
    assert arp_req_rslt.mac = x"021203230454" report "T14: wrong mac value";
    wait for clk_period*2;    
--    
    

    report "--- end of tests ---";
    wait;
  end process;

end;
