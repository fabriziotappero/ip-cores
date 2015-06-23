--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:35:58 06/03/2011
-- Design Name:   
-- Module Name:   C:/Users/pjf/Documents/projects/fpga/xilinx/Network/ip1/IPv4_TX_tb.vhd
-- Project Name:  ip1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IPv4_TX
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - Added test for IP broadcast tx
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
use IEEE.NUMERIC_STD.all;
use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;


entity IPv4_TX_tb is
end IPv4_TX_tb;

architecture behavior of IPv4_TX_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component IPv4_TX
    port(
      -- IP Layer signals
      ip_tx_start          : in  std_logic;
      ip_tx                : in  ipv4_tx_type;                   -- IP tx cxns
      ip_tx_result         : out std_logic_vector (1 downto 0);  -- tx status (changes during transmission)
      ip_tx_data_out_ready : out std_logic;  -- indicates IP TX is ready to take data

      -- system signals
      clk                : in  std_logic;  -- same clock used to clock mac data and ip data
      reset              : in  std_logic;
      our_ip_address     : in  std_logic_vector (31 downto 0);
      our_mac_address    : in  std_logic_vector (47 downto 0);
      -- ARP lookup signals
      arp_req_req        : out arp_req_req_type;
      arp_req_rslt       : in  arp_req_rslt_type;
      -- MAC layer TX signals
      mac_tx_req         : out std_logic;  -- indicates that ip wants access to channel (stays up for as long as tx)
      mac_tx_granted     : in  std_logic;  -- indicates that access to channel has been granted            
      mac_data_out_ready : in  std_logic;  -- indicates system ready to consume data
      mac_data_out_valid : out std_logic;  -- indicates data out is valid
      mac_data_out_first : out std_logic;  -- with data out valid indicates the first byte of a frame
      mac_data_out_last  : out std_logic;  -- with data out valid indicates the last byte of a frame
      mac_data_out       : out std_logic_vector (7 downto 0)  -- ethernet frame (from dst mac addr through to last byte of frame)      
      );
  end component;


  --Inputs
  signal ip_tx_start        : std_logic                     := '0';
  signal ip_tx              : ipv4_tx_type;
  signal clk                : std_logic                     := '0';
  signal reset              : std_logic                     := '0';
  signal our_ip_address     : std_logic_vector(31 downto 0) := (others => '0');
  signal our_mac_address    : std_logic_vector(47 downto 0) := (others => '0');
  signal mac_tx_granted     : std_logic                     := '0';
  signal mac_data_out_ready : std_logic                     := '0';
  signal arp_req_rslt       : arp_req_rslt_type;

  --Outputs
  signal ip_tx_result         : std_logic_vector (1 downto 0);  -- tx status (changes during transmission)
  signal ip_tx_data_out_ready : std_logic;  -- indicates IP TX is ready to take data
  signal mac_tx_req           : std_logic;
  signal mac_data_out_valid   : std_logic;
  signal mac_data_out_last    : std_logic;
  signal mac_data_out_first   : std_logic;
  signal mac_data_out         : std_logic_vector(7 downto 0);
  signal arp_req_req          : arp_req_req_type;

  -- Clock period definitions
  constant clk_period : time := 8 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : IPv4_TX port map (
    ip_tx_start          => ip_tx_start,
    ip_tx                => ip_tx,
    ip_tx_result         => ip_tx_result,
    ip_tx_data_out_ready => ip_tx_data_out_ready,
    clk                  => clk,
    reset                => reset,
    our_ip_address       => our_ip_address,
    our_mac_address      => our_mac_address,
    arp_req_req          => arp_req_req,
    arp_req_rslt         => arp_req_rslt,
    mac_tx_req           => mac_tx_req,
    mac_tx_granted       => mac_tx_granted,
    mac_data_out_ready   => mac_data_out_ready,
    mac_data_out_valid   => mac_data_out_valid,
    mac_data_out_first   => mac_data_out_first,
    mac_data_out_last    => mac_data_out_last,
    mac_data_out         => mac_data_out
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
    our_ip_address            <= x"c0a80509";  -- 192.168.5.9
    our_mac_address           <= x"002320212223";
    ip_tx_start               <= '0';
    mac_tx_granted            <= '0';
    mac_data_out_ready        <= '0';
    ip_tx.data.data_out_valid <= '0';
    ip_tx.data.data_out_last  <= '0';
    arp_req_rslt.got_mac      <= '0';
    arp_req_rslt.got_err      <= '0';
    arp_req_rslt.mac          <= (others => '0');

    reset <= '1';
    wait for clk_period*10;
    reset <= '0';
    wait until clk = '1';
    wait for clk_period*5;
    wait until clk = '1';

    -- check reset conditions
    assert arp_req_req.lookup_req = '0' report "arp_req_req.lookup_req not initialised correctly on reset";
    assert ip_tx_result = IPTX_RESULT_NONE report "ip_tx_result not initialised correctly on reset";
    assert ip_tx_data_out_ready = '0' report "ip_tx_data_out_ready not initialised correctly on reset";
    assert mac_tx_req = '0' report "mac_tx_req not initialised correctly on reset";
    assert mac_data_out_valid = '0' report "mac_data_out_valid not initialised correctly on reset";
    assert mac_data_out_last = '0' report "mac_data_out_last not initialised correctly on reset";

    -- insert stimulus here 

    ------------
    -- TEST 1 -- basic functional tx test with some delays for arp and chn access
    ------------

    report "T1: basic functional tx test with some delays for arp and chn access";

    ip_tx.hdr.protocol    <= x"35";
    ip_tx.hdr.data_length <= x"0008";
    ip_tx.hdr.dst_ip_addr <= x"c0123478";
    ip_tx_start           <= '1';
    wait until clk = '1';
    ip_tx_start           <= '0';
    arp_req_rslt.got_mac  <= '0';
    arp_req_rslt.got_err  <= '0';

    wait until clk = '1';
    assert arp_req_req.lookup_req = '1' report "T1: lookup_req not set on tx start";
    assert ip_tx_result = IPTX_RESULT_SENDING report "T1: result should be IPTX_RESULT_SENDING";

    wait for clk_period*10;             -- simulate arp lookup time
    wait until clk = '1';
    arp_req_rslt.mac     <= x"050423271016";
    arp_req_rslt.got_mac <= '1';

    wait until clk = '1';
    wait until clk = '1'; 
    assert arp_req_req.lookup_req = '0' report "T1: lookup_req not clear after setting";
    assert mac_tx_req = '1' report "T1: mac_tx_req not set after getting mac";

    wait for clk_period*10;             -- simulate mac chn access time
    wait until clk = '1';
    mac_tx_granted     <= '1';
    wait until clk = '1'; wait until clk = '1';     mac_data_out_ready <= '1';
    assert mac_data_out_valid = '0' report "T1: mac_data_out_valid asserted too early";

    wait until clk = '1';

    assert ip_tx_data_out_ready = '0' report "T1: IP data out ready asserted too early";
    wait until clk = '1';
    assert mac_data_out_valid = '1' report "T1: mac_data_out_valid not asserted";

    -- wait until in eth hdr
    wait for clk_period*3;
    wait until clk = '1';
    -- go mac not ready for 2 clocks
    mac_data_out_ready <= '0';
    wait until clk = '1'; wait until clk = '1';     wait until clk = '1';
    mac_data_out_ready <= '1';


    wait until ip_tx_data_out_ready = '1';
    wait until clk = '1';

    -- start to tx IP data
    ip_tx.data.data_out_valid <= '1';
    ip_tx.data.data_out       <= x"56"; wait until clk = '1';
    -- delay data in for 1 clk cycle
    ip_tx.data.data_out_valid <= '0';
    ip_tx.data.data_out       <= x"57"; wait until clk = '1';
    ip_tx.data.data_out_valid <= '1'; wait until clk = '1';
    ip_tx.data.data_out       <= x"58"; wait until clk = '1';
    ip_tx.data.data_out       <= x"59";     wait until clk = '1';
--wait for clk_period;

    -- delay mac ready for 2 clk cycles
    mac_data_out_ready  <= '0';
    ip_tx.data.data_out <= x"5a";    wait until clk = '1';
--wait for clk_period;
    assert ip_tx_data_out_ready = '0' report "T1: ip_tx_data_out_ready not cleared when mac not ready";

    ip_tx.data.data_out <= x"5a";     wait until clk = '1';
--wait for clk_period;
    mac_data_out_ready  <= '1';
    wait until ip_tx_data_out_ready = '1';
    wait until clk = '1';
--    wait for clk_period;
    assert ip_tx_data_out_ready = '1' report "T1: ip_tx_data_out_ready not set when mac ready";
    ip_tx.data.data_out <= x"5b"; wait until clk = '1';
    ip_tx.data.data_out <= x"5c"; wait until clk = '1';

    ip_tx.data.data_out      <= x"5d";
    ip_tx.data.data_out_last <= '1';
    wait until clk = '1';
    assert mac_data_out_last = '1' report "T1: mac_datda_out_last not set on last byte";

    ip_tx.data.data_out_valid <= '0';
    ip_tx.data.data_out_last  <= '0';
    wait until clk = '1'; wait until clk = '1'; 
    assert ip_tx_result = IPTX_RESULT_SENT report "T1: result should be IPTX_RESULT_SENT";
    assert mac_tx_req = '0' report "T1: mac_tx_req held on too long after TX";

    mac_tx_granted <= '0';
    wait until clk = '1'; wait until clk = '1'; 
    ------------
    -- TEST 2 -- basic functional tx test with no delays for arp and chn access
    ------------

    report "T2: basic functional tx test with no delays for arp and chn access";

    ip_tx.hdr.protocol    <= x"11";
    ip_tx.hdr.data_length <= x"0006";
    ip_tx.hdr.dst_ip_addr <= x"c0123478";
    ip_tx_start           <= '1';
    wait until clk = '1';
    ip_tx_start           <= '0'; wait until clk = '1';
    arp_req_rslt.got_mac  <= '0';

    assert arp_req_req.lookup_req = '1' report "T2: lookup_req not set on tx start";
    assert ip_tx_result = IPTX_RESULT_SENDING report "T2: result should be IPTX_RESULT_SENDING";

    wait until clk = '1';                -- simulate arp lookup time
    arp_req_rslt.mac     <= x"050423271016";
    arp_req_rslt.got_mac <= '1';

    wait until clk = '1'; wait until clk = '1'; 
    assert arp_req_req.lookup_req = '0' report "T2: lookup_req not clear after setting";
    assert mac_tx_req = '1' report "T2: mac_tx_req not set after getting mac";

    wait until clk = '1';                -- simulate mac chn access time
    mac_tx_granted     <= '1';
    wait until clk = '1'; wait until clk = '1';     mac_data_out_ready <= '1';
    
    assert ip_tx_data_out_ready = '0' report "T2: IP data out ready asserted too early";

    wait until ip_tx_data_out_ready = '1';

    -- start to tx IP data
    ip_tx.data.data_out_valid <= '1';
    ip_tx.data.data_out       <= x"c1"; wait until clk = '1';
    ip_tx.data.data_out       <= x"c2"; wait until clk = '1';
    ip_tx.data.data_out       <= x"c3"; wait until clk = '1';
    ip_tx.data.data_out       <= x"c4"; wait until clk = '1';
    ip_tx.data.data_out       <= x"c5"; wait until clk = '1';

    ip_tx.data.data_out      <= x"c6";
    ip_tx.data.data_out_last <= '1';
    wait until clk = '1';

    assert mac_data_out_last = '1' report "T2: mac_datda_out_last not set on last byte";


    ip_tx.data.data_out_valid <= '0';
    ip_tx.data.data_out_last  <= '0';
    wait until clk = '1'; wait until clk = '1'; 
    assert ip_tx_result = IPTX_RESULT_SENT report "T2: result should be IPTX_RESULT_SENT";
    assert mac_tx_req = '0' report "T2: mac_tx_req held on too long after TX";

    mac_tx_granted <= '0';
    wait until clk = '1'; wait until clk = '1'; 
    ------------
    -- TEST 3 -- tx test for IP broadcast, should be no arp req
    ------------

    report "T3: tx test for IP broadcast, should be no arp req";

    ip_tx.hdr.protocol    <= x"11";
    ip_tx.hdr.data_length <= x"0006";
    ip_tx.hdr.dst_ip_addr <= x"ffffffff";
    ip_tx_start           <= '1';
    wait until clk = '1';
    ip_tx_start           <= '0'; wait until clk = '1';
    arp_req_rslt.got_mac  <= '0';

    assert arp_req_req.lookup_req = '0' report "T3: its trying to do an ARP req tx start";
    assert ip_tx_result = IPTX_RESULT_SENDING report "T3: result should be IPTX_RESULT_SENDING";

    wait until clk = '1';                -- simulate mac chn access time
    mac_tx_granted     <= '1';
    wait until clk = '1'; wait until clk = '1';     mac_data_out_ready <= '1';

    assert ip_tx_data_out_ready = '0' report "T3: IP data out ready asserted too early";

    wait until ip_tx_data_out_ready = '1';

    -- start to tx IP data
    ip_tx.data.data_out_valid <= '1';
    ip_tx.data.data_out       <= x"c1"; wait until clk = '1';
    ip_tx.data.data_out       <= x"c2"; wait until clk = '1';
    ip_tx.data.data_out       <= x"c3"; wait until clk = '1';
    ip_tx.data.data_out       <= x"c4"; wait until clk = '1';
    ip_tx.data.data_out       <= x"c5"; wait until clk = '1';

    ip_tx.data.data_out      <= x"c6";
    ip_tx.data.data_out_last <= '1';
    wait until clk = '1';

    assert mac_data_out_last = '1' report "T3: mac_datda_out_last not set on last byte";


    ip_tx.data.data_out_valid <= '0';
    ip_tx.data.data_out_last  <= '0';
    wait until clk = '1'; wait until clk = '1'; 
    assert ip_tx_result = IPTX_RESULT_SENT report "T3: result should be IPTX_RESULT_SENT";
    assert mac_tx_req = '0' report "T3: mac_tx_req held on too long after TX";

    mac_tx_granted <= '0';
    wait until clk = '1'; wait until clk = '1'; 

    report "--- end of tests ---";

    wait;
  end process;

end;
