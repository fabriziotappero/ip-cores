-------------------------------------------------------------------------------
-- Title      : Testbench with real hibi
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : tb_hibi_test.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-03-23
-- Platform   : Sim only
-------------------------------------------------------------------------------
-- Description: -
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/28  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp2hibi_pkg.all;


entity tb_hibi_test is
  port (
    tx_cnt : out integer;
    rx_cnt : out integer);
end tb_hibi_test;


architecture tb of tb_hibi_test is

  constant frequency_c     : integer   := 50000000;
  constant period_c        : time      := 20 ns;
  constant udp_ip_period_c : time      := 40 ns;
  signal   clk             : std_logic := '1';
  signal   clk_udp         : std_logic := '1';
  signal   rst_n           : std_logic := '0';

  constant hibi_data_width_c : integer := 32;
  constant hibi_comm_width_c : integer := 3;
  constant hibi_addr_width_c : integer := 32;

  constant receiver_table_size_c    : integer := 4;
  constant tx_multiclk_fifo_depth_c : integer := 10;
  constant rx_multiclk_fifo_depth_c : integer := 10;
  constant hibi_tx_fifo_depth_c     : integer := 10;
  constant ack_fifo_depth_c         : integer := 4;

  signal test_data_to_hibi   : std_logic_vector( hibi_data_width_c-1 downto 0 ) := (others => '0');
  signal test_we_to_hibi     : std_logic := '0';
  signal test_av_to_hibi     : std_logic := '0';
  signal test_comm_to_hibi   : std_logic_vector( hibi_comm_width_c-1 downto 0 ) := (others => '0');
  signal test_full_from_hibi : std_logic;

  signal test_data_from_hibi  : std_logic_vector( hibi_data_width_c-1 downto 0 );
  signal test_empty_from_hibi : std_logic;
  signal test_av_from_hibi    : std_logic;
  signal test_comm_from_hibi  : std_logic_vector( hibi_comm_width_c-1 downto 0 );
  signal test_re_to_hibi      : std_logic := '0';

  signal data_hibi_udp2hibi  : std_logic_vector( hibi_data_width_c-1 downto 0 );
  signal empty_hibi_udp2hibi : std_logic;
  signal av_hibi_udp2hibi    : std_logic;
  signal comm_hibi_udp2hibi  : std_logic_vector( hibi_comm_width_c-1 downto 0 );
  signal re_udp2hibi_hibi    : std_logic;

  signal data_udp2hibi_hibi : std_logic_vector( hibi_data_width_c-1 downto 0 );
  signal we_udp2hibi_hibi   : std_logic;
  signal av_udp2hibi_hibi   : std_logic;
  signal comm_udp2hibi_hibi : std_logic_vector( hibi_comm_width_c-1 downto 0 );
  signal full_hibi_udp2hibi : std_logic;

  signal data_to_hibi   : std_logic_vector( 2* hibi_data_width_c-1 downto 0 );
  signal we_to_hibi     : std_logic_vector( 1 downto 0 );
  signal av_to_hibi     : std_logic_vector( 1 downto 0 );
  signal comm_to_hibi   : std_logic_vector( 2* hibi_comm_width_c-1 downto 0 );
  signal full_from_hibi : std_logic_vector( 1 downto 0 );

  signal data_from_hibi  : std_logic_vector( 2* hibi_data_width_c-1 downto 0 );
  signal empty_from_hibi : std_logic_vector( 1 downto 0 );
  signal av_from_hibi    : std_logic_vector( 1 downto 0 );
  signal re_to_hibi      : std_logic_vector( 1 downto 0 );
  signal comm_from_hibi  : std_logic_vector( 2* hibi_comm_width_c-1 downto 0 );


  signal tx_data_from_udp2hibi       : std_logic_vector( udp_block_data_w_c-1 downto 0 );
  signal tx_data_valid_from_udp2hibi : std_logic;
  signal tx_re_to_udp2hibi           : std_logic := '0';
  signal new_tx_from_udp2hibi        : std_logic;
  signal tx_len_from_udp2hibi        : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal dest_ip_from_udp2hibi       : std_logic_vector( ip_addr_w_c-1 downto 0 );
  signal dest_port_from_udp2hibi     : std_logic_vector( udp_port_w_c-1 downto 0 );
  signal source_port_from_udp2hibi   : std_logic_vector( udp_port_w_c-1 downto 0 );

  signal rx_data_to_udp2hibi       : std_logic_vector( udp_block_data_w_c-1 downto 0 ) := (others => '0');
  signal rx_data_valid_to_udp2hibi : std_logic := '0';
  signal rx_re_from_udp2hibi       : std_logic;
  signal new_rx_to_udp2hibi        : std_logic := '0';
  signal rx_len_to_udp2hibi        : std_logic_vector( tx_len_w_c-1 downto 0 ) := (others => '0');
  signal source_ip_to_udp2hibi     : std_logic_vector( ip_addr_w_c-1 downto 0 ) := (others => '0');
  signal dest_port_to_udp2hibi     : std_logic_vector( udp_port_w_c-1 downto 0 ) := (others => '0');
  signal source_port_to_udp2hibi   : std_logic_vector( udp_port_w_c-1 downto 0 ) := (others => '0');
  signal rx_erroneous_to_udp2hibi  : std_logic := '0';


  -- test data ----------------------------------------------------------------

  constant test_len_bytes_c : integer := 1303;
  constant data_amount_c : integer := 16;
  type test_data_type is array (0 to data_amount_c-1) of std_logic_vector( hibi_data_width_c-1 downto 0 );
  constant test_data : test_data_type :=
    ( x"03020100", x"07060504", x"0b0a0908", x"0f0e0d0c",
      x"13121110", x"17161514", x"1b1a1918", x"1f1e1d1c",
      x"23222120", x"27262524", x"2b2a2928", x"2f2e2d2c",
      x"33323130", x"37363534", x"3b3a3938", x"3f3e3d3c" );

  type tx_conf_type is array (0 to 4) of std_logic_vector( hibi_data_width_c-1 downto 0 );
  constant tx_conf : tx_conf_type :=
    ( x"01000000", x"00001234", x"acdcabba", x"11112222", x"03000000" );
  constant rx_conf : tx_conf_type :=
    ( x"01000000", x"30000000", x"acdcabba", x"22221111", x"03000000" );

  constant simulation_timeout_c : integer := 5000;
  signal timeout_cnt_r : integer;

-------------------------------------------------------------------------------
begin  -- tb
-------------------------------------------------------------------------------

  av_to_hibi   <= test_av_to_hibi & av_udp2hibi_hibi;
  data_to_hibi <= test_data_to_hibi & data_udp2hibi_hibi;
  we_to_hibi   <= test_we_to_hibi & we_udp2hibi_hibi;
  re_to_hibi   <= test_re_to_hibi & re_udp2hibi_hibi;
  
  test_full_from_hibi  <= full_from_hibi(1);
  full_hibi_udp2hibi   <= full_from_hibi(0);
  test_av_from_hibi    <= av_from_hibi(1);
  av_hibi_udp2hibi     <= av_from_hibi(0);
  test_data_from_hibi  <= data_from_hibi( 2*hibi_data_width_c-1 downto hibi_data_width_c );
  data_hibi_udp2hibi   <= data_from_hibi( hibi_data_width_c-1 downto 0 );
  test_empty_from_hibi <= empty_from_hibi(1);
  empty_hibi_udp2hibi  <= empty_from_hibi(0);
  
--  hibi_bus : entity work.hibiv2
  hibi_bus : entity work.hibi_segment_v3
    generic map (
      use_monitor_g   => 0,
      data_width_g    => hibi_data_width_c,
      n_agents_g      => 2,
      n_segments_g    => 1,
      rel_ip_freq_g   => 1,
      rel_noc_freq_g  => 1
      )
    port map (
      clk_ip          => clk,
      clk_noc         => clk,
      rst_n           => rst_n,
      av_in           => av_to_hibi,
      data_in         => data_to_hibi,
      we_in           => we_to_hibi,
      full_out        => full_from_hibi,
      one_p_out       => open,
      av_out          => av_from_hibi,
      data_out        => data_from_hibi,
      re_in           => re_to_hibi,
      empty_out       => empty_from_hibi,
      one_d_out       => open,
      mon_UART_rx_in  => '1',
      mon_UART_tx_out => open,
      mon_command_in  => (others => '0')
      );


  udp2hibi_block : entity work.udp2hibi
    generic map (
      receiver_table_size_g    => receiver_table_size_c,
      ack_fifo_depth_g         => ack_fifo_depth_c,
      tx_multiclk_fifo_depth_g => tx_multiclk_fifo_depth_c,
      rx_multiclk_fifo_depth_g => rx_multiclk_fifo_depth_c,
      hibi_tx_fifo_depth_g     => hibi_tx_fifo_depth_c,
      hibi_data_width_g        => hibi_data_width_c,
      hibi_addr_width_g        => hibi_addr_width_c,
      hibi_comm_width_g        => hibi_comm_width_c,
      frequency_g              => frequency_c
      )
    port map (
      clk                      => clk,
      clk_udp                  => clk_udp,
      rst_n                    => rst_n,
      hibi_comm_in             => comm_hibi_udp2hibi,
      hibi_data_in             => data_hibi_udp2hibi,
      hibi_av_in               => av_hibi_udp2hibi,
      hibi_empty_in            => empty_hibi_udp2hibi,
      hibi_re_out              => re_udp2hibi_hibi,
      hibi_comm_out            => comm_udp2hibi_hibi,
      hibi_data_out            => data_udp2hibi_hibi,
      hibi_av_out              => av_udp2hibi_hibi,
      hibi_we_out              => we_udp2hibi_hibi,
      hibi_full_in             => full_hibi_udp2hibi,
      tx_data_out              => tx_data_from_udp2hibi,
      tx_data_valid_out        => tx_data_valid_from_udp2hibi,
      tx_re_in                 => tx_re_to_udp2hibi,
      new_tx_out               => new_tx_from_udp2hibi,
      tx_len_out               => tx_len_from_udp2hibi,
      dest_ip_out              => dest_ip_from_udp2hibi,
      dest_port_out            => dest_port_from_udp2hibi,
      source_port_out          => source_port_from_udp2hibi,
      rx_data_in               => rx_data_to_udp2hibi,
      rx_data_valid_in         => rx_data_valid_to_udp2hibi,
      rx_re_out                => rx_re_from_udp2hibi,
      new_rx_in                => new_rx_to_udp2hibi,
      rx_len_in                => rx_len_to_udp2hibi,
      source_ip_in             => source_ip_to_udp2hibi,
      dest_port_in             => dest_port_to_udp2hibi,
      source_port_in           => source_port_to_udp2hibi,
      rx_erroneous_in          => rx_erroneous_to_udp2hibi
      );


  -- clk generation
  clk <= not clk after period_c/2;
  clk_udp <= not clk_udp after udp_ip_period_c/2;
  rst_n <= '1' after period_c*4;

  -- *******
  -- test ip has address 0x03000000
  -- udp2hibi has address 0x01000000
  
  test_ip: process
  begin  -- process test_ip

    if rst_n = '0' then
      wait until rst_n = '1';
    end if;

    wait for period_c*4;

    -- send tx_conf, rx_conf and finally data

    ---------------------------------------------------------------------------
    -- tx_conf
    for n in 0 to 4 loop
      
      if n = 0 then
        test_av_to_hibi <= '1';
      else
        test_av_to_hibi <= '0';
      end if;
      
      test_we_to_hibi <= '1';
      test_data_to_hibi <= tx_conf(n);

      wait for period_c;
      if test_full_from_hibi = '1' then
        wait until test_full_from_hibi = '0';
        wait for period_c;
      end if;
      
    end loop;  -- n
    test_we_to_hibi <= '0';

    -- wait for the ack
    wait until test_empty_from_hibi = '0';
    test_re_to_hibi <= '1';
    wait for period_c*2;
    -- now the ack should be read
    assert test_data_from_hibi = x"58000000" report "Invalid tx ack from udp2hibi." severity failure;
    wait for period_c;
    assert test_empty_from_hibi = '1' report "Still not empty after tx ack?" severity failure;
    test_re_to_hibi <= '0';
    wait for period_c*2;
    

    ---------------------------------------------------------------------------
    -- rx_conf
    for n in 0 to 4 loop
      
      if n = 0 then
        test_av_to_hibi <= '1';
      else
        test_av_to_hibi <= '0';
      end if;
      
      test_we_to_hibi <= '1';
      test_data_to_hibi <= rx_conf(n);

      wait for period_c;
      if test_full_from_hibi = '1' then
        wait until test_full_from_hibi = '0';
        wait for period_c;
      end if;
      
    end loop;  -- n
    test_we_to_hibi <= '0';

    wait for period_c*4;

    -- wait for the ack
    wait until test_empty_from_hibi = '0';
    test_re_to_hibi <= '1';
    wait for period_c*2;
    -- now the ack should be read
    assert test_data_from_hibi = x"50000000" report "Invalid rx ack from udp2hibi." severity failure;
    wait for period_c;
    assert test_empty_from_hibi = '1' report "Still not empty after rx ack?" severity failure;
    test_re_to_hibi <= '0';
    wait for period_c*2;

    ---------------------------------------------------------------------------
    -- data, but first the address and data header
    test_av_to_hibi <= '1';
    test_we_to_hibi <= '1';
    test_data_to_hibi <= x"01000000";
    if test_full_from_hibi = '1' then
      wait until test_full_from_hibi = '0';
    end if;
    wait for period_c;

    test_av_to_hibi <= '0';
    test_data_to_hibi <= x"1" & std_logic_vector( to_unsigned( test_len_bytes_c, tx_len_w_c ))
                         & "00000000000000000";
    if test_full_from_hibi = '1' then
      wait until test_full_from_hibi = '0';
    end if;
    wait for period_c;

    -- now the data
    for n in 0 to (test_len_bytes_c+3)/4-1 loop
      tx_cnt <= n;
      test_data_to_hibi <= test_data(n mod data_amount_c);
      wait for period_c;
      if test_full_from_hibi = '1' then
        wait until test_full_from_hibi = '0';
        wait for period_c;
      end if;
    end loop;  -- n

    test_we_to_hibi <= '0';
    ---------------------------------------------------------------------------

    -- now wait for the data to come back
    wait until test_empty_from_hibi = '0';
    test_re_to_hibi <= '1';
    wait for period_c;

    -- read out the rx_header
    if test_empty_from_hibi = '1' then
      wait until test_empty_from_hibi = '0';
    end if;
    wait for period_c;

    assert test_data_from_hibi( 31 downto 17 ) = x"4"
      & std_logic_vector( to_unsigned( test_len_bytes_c, tx_len_w_c ))
      report "Invalid rx header for test ip." severity failure;

    -- read the data
    for n in 0 to (test_len_bytes_c+3)/4-1 loop
      wait for period_c;
      if test_empty_from_hibi = '1' then
        wait until test_empty_from_hibi = '0';
        wait for period_c;
      end if;

      -- ignore addresses
      if test_av_from_hibi = '1' then
        wait for period_c;
        if test_empty_from_hibi = '1' then
          wait until test_empty_from_hibi = '0';
          wait for period_c;
        end if;
      end if;
      
      assert test_data_from_hibi = test_data(n mod data_amount_c)
        report "Invalid return data to test process." severity failure;
    end loop;  -- n
    test_re_to_hibi <= '0';

    wait for period_c*10;
    report "Simulation ended." severity failure;
    
  end process test_ip;

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  udp_ip: process
    variable tx_len_int : integer;
  begin  -- process udp_ip

    wait until new_tx_from_udp2hibi = '1';
    if clk_udp = '0' then
      wait until clk_udp = '1';
    end if;
    
    wait for udp_ip_period_c;

    tx_len_int := to_integer( unsigned( tx_len_from_udp2hibi ));
    
    assert
      dest_ip_from_udp2hibi = x"acdcabba" and
      dest_port_from_udp2hibi = x"1111" and
      source_port_from_udp2hibi = x"2222" and
      tx_len_int = test_len_bytes_c
      report "Invalid tx info from udp2hibi." severity failure;
    
    assert tx_data_valid_from_udp2hibi = '1' report "Tx data not valid??" severity failure;

    -- read data
    tx_re_to_udp2hibi <= '1';
    for n in 0 to (test_len_bytes_c+1)/2-1 loop
      if tx_data_valid_from_udp2hibi = '0' then
        wait until tx_data_valid_from_udp2hibi = '1';
      end if;
      wait for udp_ip_period_c;
      assert
        ( n mod 2 = 0 and
          tx_data_from_udp2hibi = test_data((n/2) mod data_amount_c)(15 downto 0) ) or
        ( n mod 2 = 1 and
          tx_data_from_udp2hibi = test_data((n/2) mod data_amount_c)(31 downto 16) )
        report "Invalid data from udp2hibi." severity failure;
    end loop;  -- n

    -- wait for a while, and send data back
    wait for udp_ip_period_c*10;

    new_rx_to_udp2hibi <= '1';
    source_ip_to_udp2hibi <= x"acdcabba";
    dest_port_to_udp2hibi <= x"2222";
    source_port_to_udp2hibi <= x"1111";
    rx_erroneous_to_udp2hibi <= '0';
    rx_len_to_udp2hibi <= std_logic_vector( to_unsigned( test_len_bytes_c, tx_len_w_c ));
    rx_data_to_udp2hibi <= test_data(0)(15 downto 0);
    rx_data_valid_to_udp2hibi <= '1';

    wait until rx_re_from_udp2hibi = '1';
    if clk_udp = '0' then
      wait until clk_udp = '1';
    else
      wait for udp_ip_period_c;
    end if;

    new_rx_to_udp2hibi <= '0';

    for n in 1 to (test_len_bytes_c+1)/2-1 loop
      rx_cnt <= n;
      if n mod 2 = 0 then
        rx_data_to_udp2hibi <= test_data((n/2) mod data_amount_c)(15 downto 0);
      else
        rx_data_to_udp2hibi <= test_data((n/2) mod data_amount_c)(31 downto 16);
      end if;
      wait for udp_ip_period_c;
      if rx_re_from_udp2hibi = '0' then
        wait until rx_re_from_udp2hibi = '1';
        wait for udp_ip_period_c;
      end if;
    end loop;  -- n
    rx_data_valid_to_udp2hibi <= '0';

    -- wait forever
    wait;
    
  end process udp_ip;

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  timeout_proc: process (clk, rst_n)
  begin  -- process timeout_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      timeout_cnt_r <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      assert timeout_cnt_r < simulation_timeout_c report "Timeout! Something went wrong..." severity failure;
      timeout_cnt_r <= timeout_cnt_r + 1;
    end if;
  end process timeout_proc;

end tb;
