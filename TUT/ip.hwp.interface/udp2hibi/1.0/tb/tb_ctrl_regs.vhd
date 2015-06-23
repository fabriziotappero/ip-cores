-------------------------------------------------------------------------------
-- Title      : testbench for the allmighty ctrl_regs block
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : tb_ctrl_regs.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Last update: 2012-03-22
-- Platform   : Sim only
-------------------------------------------------------------------------------
-- Description: A couple of hard-coded test cases for ctrl-registers.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/08  1.0      niemin95        Created
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;                    -- es

use work.udp2hibi_pkg.all;



entity tb_ctrl_regs is
end tb_ctrl_regs;


architecture tb of tb_ctrl_regs is

  constant period_c : time      := 20 ns;
  signal   clk      : std_logic := '1';
  signal   rst_n    : std_logic := '0';

  signal test_id   : integer;
  signal test_name : string(1 to 6) :=" reset";
  
  constant hibi_addr_width_c     : integer := 32;
  constant receiver_table_size_c : integer := 2;


  -- to hibi_receiver
  signal release_lock_to_duv     : std_logic                                      := '0';
  signal new_tx_conf_to_duv      : std_logic                                      := '0';
  signal new_rx_conf_to_duv      : std_logic                                      := '0';
  signal ip_to_duv               : std_logic_vector(ip_addr_w_c-1 downto 0)       := (others => '0');
  signal dest_port_to_duv        : std_logic_vector(udp_port_w_c-1 downto 0)      := (others => '0');
  signal source_port_to_duv      : std_logic_vector(udp_port_w_c-1 downto 0)      := (others => '0');
  signal lock_addr_to_duv        : std_logic_vector(hibi_addr_width_c-1 downto 0) := (others => '0');
  signal response_addr_to_duv    : std_logic_vector(hibi_addr_width_c-1 downto 0) := (others => '0');
  signal lock_from_duv           : std_logic;
  signal lock_addr_from_duv      : std_logic_vector(hibi_addr_width_c-1 downto 0);
  -- to tx_ctrl
  signal tx_ip_from_duv          : std_logic_vector(ip_addr_w_c-1 downto 0);
  signal tx_dest_port_from_duv   : std_logic_vector(udp_port_w_c-1 downto 0);
  signal tx_source_port_from_duv : std_logic_vector(udp_port_w_c-1 downto 0);
  signal timeout_release_to_duv  : std_logic                                      := '0';
  -- from rx_ctrl
  signal rx_ip_to_duv            : std_logic_vector(ip_addr_w_c-1 downto 0)       := (others => '0');
  signal rx_dest_port_to_duv     : std_logic_vector(udp_port_w_c-1 downto 0)      := (others => '0');
  signal rx_source_port_to_duv   : std_logic_vector(udp_port_w_c-1 downto 0)      := (others => '0');
  signal rx_addr_valid_from_duv  : std_logic;
  -- to hibi_transmitter
  signal ack_addr_from_duv       : std_logic_vector(hibi_addr_width_c-1 downto 0);
  signal rx_addr_from_duv        : std_logic_vector(hibi_addr_width_c-1 downto 0);
  signal send_tx_ack_from_duv    : std_logic;
  signal send_tx_nack_from_duv   : std_logic;
  signal send_rx_ack_from_duv    : std_logic;
  signal send_rx_nack_from_duv   : std_logic;


  -- test values:
  constant test_ip1_c          : std_logic_vector(ip_addr_w_c-1 downto 0)       := x"01234567";
  constant test_ip2_c          : std_logic_vector(ip_addr_w_c-1 downto 0)       := x"98765432";
  constant test_dest_port1_c   : std_logic_vector(udp_port_w_c-1 downto 0)      := x"0123";
  constant test_dest_port2_c   : std_logic_vector(udp_port_w_c-1 downto 0)      := x"4567";
  constant test_dest_port3_c   : std_logic_vector(udp_port_w_c-1 downto 0)      := x"8743";
  constant test_source_port1_c : std_logic_vector(udp_port_w_c-1 downto 0)      := x"2345";
  constant test_source_port2_c : std_logic_vector(udp_port_w_c-1 downto 0)      := x"5432";
  constant test_lock_addr1_c   : std_logic_vector(hibi_addr_width_c-1 downto 0) := x"fedcba98";
  constant test_lock_addr2_c   : std_logic_vector(hibi_addr_width_c-1 downto 0) := x"89abcdef";
  constant test_resp_addr1_c   : std_logic_vector(hibi_addr_width_c-1 downto 0) := x"1f2e3d4c";
  constant test_resp_addr2_c   : std_logic_vector(hibi_addr_width_c-1 downto 0) := x"f1e2d3c4";
  constant test_resp_addr3_c   : std_logic_vector(hibi_addr_width_c-1 downto 0) := x"12fe34dc";


-------------------------------------------------------------------------------
begin  -- tb
-------------------------------------------------------------------------------

  duv : entity work.ctrl_regs
    generic map (
      receiver_table_size_g => receiver_table_size_c,
      hibi_addr_width_g     => hibi_addr_width_c
      )
    port map (
      clk                => clk,
      rst_n              => rst_n,
      -- from hibi_receiver
      release_lock_in    => release_lock_to_duv,
      new_tx_conf_in     => new_tx_conf_to_duv,
      new_rx_conf_in     => new_rx_conf_to_duv,
      ip_in              => ip_to_duv,
      dest_port_in       => dest_port_to_duv,
      source_port_in     => source_port_to_duv,
      lock_addr_in       => lock_addr_to_duv,
      response_addr_in   => response_addr_to_duv,
      lock_out           => lock_from_duv,
      lock_addr_out      => lock_addr_from_duv,

      -- to tx_ctrl
      tx_ip_out          => tx_ip_from_duv,
      tx_dest_port_out   => tx_dest_port_from_duv,
      tx_source_port_out => tx_source_port_from_duv,
      timeout_release_in => timeout_release_to_duv,

      -- from rx_ctrl
      rx_ip_in           => rx_ip_to_duv,
      rx_dest_port_in    => rx_dest_port_to_duv,
      rx_source_port_in  => rx_source_port_to_duv,
      rx_addr_valid_out  => rx_addr_valid_from_duv,

      -- to hibi_transmitter
      ack_addr_out       => ack_addr_from_duv,
      rx_addr_out        => rx_addr_from_duv,
      send_tx_ack_out    => send_tx_ack_from_duv,
      send_tx_nack_out   => send_tx_nack_from_duv,
      send_rx_ack_out    => send_rx_ack_from_duv,
      send_rx_nack_out   => send_rx_nack_from_duv,

      -- from toplevel
      eth_link_up_in     => '1'
      );


  
  clk   <= not clk after period_c/2;
  rst_n <= '1'     after 4*period_c;


  tester: process

  begin  -- process

    if rst_n = '0' then
      wait until rst_n = '1';
    end if;
    test_id   <= 0;
    test_name <= "  alku";

    wait for period_c*4;

    -- start testing, cases:

    -- 1. new tx conf
    -- 2. new rx_conf
    -- 3. new tx conf from other sender (should result in nack)
    -- 4. new tx conf from same sender (should update tx info)
    -- 5. release
    -- 6. so many new rx_confs that there is finally too much (should result in
    -- nack)
    -- 7. change rx info, and make sure rx addr is valid
    -- 8. new tx conf, and after that, timeout from tx_ctrl (should release lock)

    ---------------------------------------------------------------------------

    -- 1. new tx conf
    test_id              <= test_id +1;
    test_name            <= "tx  ok";
    ip_to_duv            <= test_ip1_c;
    dest_port_to_duv     <= test_dest_port1_c;
    source_port_to_duv   <= test_source_port1_c;
    lock_addr_to_duv     <= test_lock_addr1_c;
    response_addr_to_duv <= test_resp_addr1_c;
    new_tx_conf_to_duv   <= '1';

    wait for period_c;
    -- clear inputs
    new_tx_conf_to_duv <= '0';

    -- wait until values update
    wait for period_c;

    -- check correct values
    assert
      lock_from_duv = '1' and
      lock_addr_from_duv = test_lock_addr1_c and
      tx_ip_from_duv = test_ip1_c and
      tx_dest_port_from_duv = test_dest_port1_c and
      tx_source_port_from_duv = test_source_port1_c
      report "Failure in test 1: invalid tx info." severity failure;
    assert
      ack_addr_from_duv = test_resp_addr1_c and
      send_tx_ack_from_duv = '1'
      report "Failure in test 1: Ack not sent." severity failure;

    wait for period_c*10;


    ---------------------------------------------------------------------------
    -- 2. new rx_conf
    test_id              <= test_id +1;
    test_name            <= "rx  ok";
    ip_to_duv            <= test_ip2_c;
    dest_port_to_duv     <= x"FFFF";
    source_port_to_duv   <= test_source_port2_c;
    lock_addr_to_duv     <= test_lock_addr2_c;
    response_addr_to_duv <= test_resp_addr2_c;
    new_rx_conf_to_duv   <= '1';

    wait for period_c;
    -- clear inputs
    new_rx_conf_to_duv <= '0';

    -- wait until values update
    wait for period_c;

    -- check correct values
    assert
      ack_addr_from_duv = test_resp_addr2_c and
      send_rx_ack_from_duv = '1'
      report "Failure in test 2: Ack not sent." severity failure;

    wait for period_c*10;


    ---------------------------------------------------------------------------
    -- 3. new tx conf from other sender (should result in nack)
    -- most test values set in the last stage are fine for this test too
    test_id              <= test_id +1;
    test_name            <= "txnack";
    dest_port_to_duv     <= test_dest_port2_c;
    response_addr_to_duv <= test_resp_addr3_c;
    new_tx_conf_to_duv   <= '1';
    wait for period_c;
    new_tx_conf_to_duv   <= '0';
    wait for period_c;

    assert
      ack_addr_from_duv = test_resp_addr3_c and
      send_tx_nack_from_duv = '1'
      report "Failure in test 3: Nack not sent." severity failure;

    wait for period_c*10;


    ---------------------------------------------------------------------------
    -- 4. new tx conf from same sender (should update tx info)
    -- again, most of the old values (values with number 2) are good
    test_id              <= test_id +1;
    test_name            <= "tx  ok";
    lock_addr_to_duv     <= test_lock_addr1_c;
    response_addr_to_duv <= test_resp_addr1_c;
    new_tx_conf_to_duv   <= '1';
    wait for period_c;
    new_tx_conf_to_duv   <= '0';
    wait for period_c;

    assert
      lock_from_duv = '1' and
      lock_addr_from_duv = test_lock_addr1_c and
      tx_ip_from_duv = test_ip2_c and
      tx_dest_port_from_duv = test_dest_port2_c and
      tx_source_port_from_duv = test_source_port2_c
      report "Failure in test 4: invalid tx info." severity failure;
    assert
      ack_addr_from_duv = test_resp_addr1_c and
      send_tx_ack_from_duv = '1'
      report "Failure in test 4: Ack not sent." severity failure;

    wait for period_c*10;


    ---------------------------------------------------------------------------
    -- 5. release
    test_id             <= test_id +1;
    test_name            <= "releas";
    release_lock_to_duv <= '1';
    wait for period_c;
    release_lock_to_duv <= '0';
    wait for period_c;

    assert lock_from_duv = '0' report "Failure in test 5: Lock was not removed." severity failure;

    wait for period_c*10;


    ---------------------------------------------------------------------------
    -- 6. so many new rx_confs that there is finally too much (should result in
    -- nack)
    -- there is one already, add two more (receiver_table_size_c should be 2)
    test_id              <= test_id +1;
    test_name            <= "rxnack";
    ip_to_duv            <= test_ip1_c;
    dest_port_to_duv     <= test_dest_port1_c;
    source_port_to_duv   <= test_source_port1_c;
    lock_addr_to_duv     <= test_lock_addr1_c;
    response_addr_to_duv <= test_resp_addr1_c;
    new_rx_conf_to_duv   <= '1';

    wait for period_c;
    -- clear input
    new_rx_conf_to_duv <= '0';

    -- wait for a while, check the ack, and add another one
    wait for period_c;
    assert
      ack_addr_from_duv = test_resp_addr1_c and
      send_rx_ack_from_duv = '1'
      report "Failure in test 6: Ack not sent." severity failure;

    wait for period_c*3;

    -- same values will do for the next conf, just change the reply addr
    response_addr_to_duv <= test_resp_addr3_c;
    new_rx_conf_to_duv   <= '1';
    wait for period_c;
    new_rx_conf_to_duv   <= '0';
    wait for period_c;

    assert
      ack_addr_from_duv = test_resp_addr3_c and
      send_rx_nack_from_duv = '1'
      report "Failure in test 6: Nack not sent." severity failure;

    wait for period_c*10;


    ---------------------------------------------------------------------------
    -- 7. change rx info, and make sure rx addr is valid
    -- check both entries and then a false entry
    test_id               <= test_id +1;
    test_name            <= "rx fif";
    rx_ip_to_duv          <= test_ip2_c;
    rx_source_port_to_duv <= test_source_port2_c;
    -- test that the joker value (x"FFFF") works by giving some random port
    rx_dest_port_to_duv   <= test_dest_port3_c;
    wait for period_c*2;

    assert
      rx_addr_from_duv = test_resp_addr2_c and
      rx_addr_valid_from_duv = '1'
      report "Failure in test 7.1: Invalid address from duv." severity failure;

    wait for period_c*2;

    -- and the other entry:
    rx_ip_to_duv          <= test_ip1_c;
    rx_source_port_to_duv <= test_source_port1_c;
    rx_dest_port_to_duv   <= test_dest_port1_c;
    wait for period_c*2;

    assert
      rx_addr_from_duv = test_resp_addr1_c and
      rx_addr_valid_from_duv = '1'
      report "Failure in test 7.2: Ivalid address from duv." severity failure;

    wait for period_c*2;

    -- the false entry
    rx_source_port_to_duv <= test_source_port2_c;
    wait for period_c*2;

    assert
      rx_addr_valid_from_duv = '0'
      report "Failure in test 7.3: Address should be invalid." severity failure;

    
    wait for period_c*10;


    ---------------------------------------------------------------------------
    -- 8. new tx conf, and after that, timeout from tx_ctrl (should release lock)
    -- use whatever values there are, they don't matter
    test_id            <= test_id +1;
    test_name            <= "tx tim";
    new_tx_conf_to_duv <= '1';
    wait for period_c;
    new_tx_conf_to_duv <= '0';
    wait for period_c;

    assert lock_from_duv = '1' report "Failure in test 8: Block not locked." severity failure;

    wait for period_c*5;
    -- timeout!
    timeout_release_to_duv <= '1';
    wait for period_c;
    timeout_release_to_duv <= '0';
    wait for period_c;

    assert lock_from_duv = '0' report "Failure in test 8: Timeout didn't remove the lock." severity failure;


    ---------------------------------------------------------------------------
    wait for period_c*20;
    report "Simulation done." severity failure;

  end process tester;
end tb;
