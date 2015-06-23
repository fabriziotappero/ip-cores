-------------------------------------------------------------------------------
-- Title      : Testbench for Rx ctrl block
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_rx_ctrl.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-03-21
-- Platform   : Sim only
-------------------------------------------------------------------------------
-- Description: A couple of hard-coded test cases for ctrl-registers.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/18  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp2hibi_pkg.all;


entity tb_rx_ctrl is
end tb_rx_ctrl;


architecture tb of tb_rx_ctrl is

  constant frequency_c     : integer   := 50000000;
  constant period_c        : time      := 20 ns;
  constant udp_ip_period_c : time      := 40 ns;
  signal   clk             : std_logic := '1';
  signal   clk_udp         : std_logic := '1';
  signal   rst_n           : std_logic := '0';

  constant rx_multiclk_fifo_depth_c : integer := 10;
  constant tx_fifo_depth_c          : integer := 10;
  constant hibi_data_width_c        : integer := 32;

  -- from UDP/IP
  signal rx_data_to_duv        : std_logic_vector(udp_block_data_w_c-1 downto 0) := (others => '0');
  signal rx_data_valid_to_duv  : std_logic                                       := '0';
  signal rx_re_from_duv        : std_logic;
  signal new_rx_to_duv         : std_logic                                       := '0';
  signal rx_len_to_duv         : std_logic_vector(tx_len_w_c-1 downto 0)         := (others => '0');
  signal source_ip_to_duv      : std_logic_vector(ip_addr_w_c-1 downto 0)        := (others => '0');
  signal dest_port_to_duv      : std_logic_vector(udp_port_w_c-1 downto 0)       := (others => '0');
  signal source_port_to_duv    : std_logic_vector(udp_port_w_c-1 downto 0)       := (others => '0');
  signal rx_erroneous_to_duv   : std_logic                                       := '0';

  -- to/from ctrl regs
  signal ip_from_duv           : std_logic_vector(ip_addr_w_c-1 downto 0);
  signal dest_port_from_duv    : std_logic_vector(udp_port_w_c-1 downto 0);
  signal source_port_from_duv  : std_logic_vector(udp_port_w_c-1 downto 0);
  signal rx_addr_valid_to_duv  : std_logic                                       := '0';

  -- to/from hibi_transmitter
  signal send_request_from_duv : std_logic;
  signal ready_for_tx_to_duv   : std_logic                                       := '0';
  signal rx_empty_from_duv     : std_logic;
  signal rx_data_from_duv      : std_logic_vector(hibi_data_width_c-1 downto 0);
  signal rx_re_to_duv          : std_logic                                       := '0';


  -- Testbench's state machines etc.
  type   send_state_type is (idle, sending);
  signal send_state      : send_state_type;
  signal send_data       : std_logic := '0';
  signal send_done       : std_logic;
  signal rx_data_valid_r : std_logic;
  signal current         : integer;

  
  -- Test constants
  constant test_data_amount_c : integer        := 16;  -- #words
  type     test_data_type is array (0 to test_data_amount_c-1) of std_logic_vector(udp_block_data_w_c-1 downto 0);
  constant test_data          : test_data_type :=
    (x"0100", x"0302", x"0504", x"0706", x"0908", x"0b0a", x"0d0c", x"0f0e",
      x"1110", x"1312", x"1514", x"1716", x"1918", x"1b1a", x"1d1c", x"1f1e");

  type test_txs_type is
  record
    source_ip         : std_logic_vector(ip_addr_w_c-1 downto 0);
    source_port       : std_logic_vector(udp_port_w_c-1 downto 0);
    dest_port         : std_logic_vector(udp_port_w_c-1 downto 0);
    rx_addr_valid     : std_logic;
    rx_len            : integer;         -- #bytes
    rx_erroneous      : std_logic;
    delay_before_next : time;
  end record;

  constant num_of_tests_c : integer := 5;
  type     test_txs_array is array (0 to num_of_tests_c-1) of test_txs_type;

  -- test cases:
  -- 0. Normal (not erroneus, rx address valid) 200 bytes long packet
  -- 1. Packet without an receiver (should be dumped)
  -- 2. Erroneous packet (should also be dumped)
  -- 3. Very short (1 byte) transfer with minimal delay
  -- 4. just something following the earlier short one
  constant test_txs : test_txs_array :=
    ((source_ip          => x"01234567",
       source_port       => x"1212",
       dest_port         => x"2121",
       rx_addr_valid     => '1',
       rx_len            => 200,
       rx_erroneous      => '0',
       delay_before_next => 10 * period_c),
     (source_ip          => x"12345678",
       source_port       => x"2323",
       dest_port         => x"3232",
       rx_addr_valid     => '0',
       rx_len            => 40,
       rx_erroneous      => '0',
       delay_before_next => 10 * period_c),
     (source_ip          => x"23456789",
       source_port       => x"3434",
       dest_port         => x"4343",
       rx_addr_valid     => '1',
       rx_len            => 30,
       rx_erroneous      => '1',
       delay_before_next => 10 * period_c),
     (source_ip          => x"3456789a",
       source_port       => x"4545",
       dest_port         => x"5454",
       rx_addr_valid     => '1',
       rx_len            => 1,
       rx_erroneous      => '0',
       delay_before_next => udp_ip_period_c),
     (source_ip          => x"456789ab",
       source_port       => x"5656",
       dest_port         => x"6565",
       rx_addr_valid     => '1',
       rx_len            => 20,
       rx_erroneous      => '0',
       delay_before_next => 10 * period_c)
     );

  signal test_id   : integer;


begin  -- tb


  duv : entity work.rx_ctrl
    generic map (
      rx_multiclk_fifo_depth_g => rx_multiclk_fifo_depth_c,
      tx_fifo_depth_g          => tx_fifo_depth_c,
      hibi_data_width_g        => hibi_data_width_c,
      frequency_g              => frequency_c
      )
    port map (
      clk              => clk,
      clk_udp          => clk_udp,
      rst_n            => rst_n,
      rx_data_in       => rx_data_to_duv,
      rx_data_valid_in => rx_data_valid_to_duv,
      rx_re_out        => rx_re_from_duv,
      new_rx_in        => new_rx_to_duv,
      rx_len_in        => rx_len_to_duv,
      source_ip_in     => source_ip_to_duv,
      dest_port_in     => dest_port_to_duv,
      source_port_in   => source_port_to_duv,
      rx_erroneous_in  => rx_erroneous_to_duv,
      ip_out           => ip_from_duv,
      dest_port_out    => dest_port_from_duv,
      source_port_out  => source_port_from_duv,
      rx_addr_valid_in => rx_addr_valid_to_duv,
      send_request_out => send_request_from_duv,
      ready_for_tx_in  => ready_for_tx_to_duv,
      rx_empty_out     => rx_empty_from_duv,
      rx_data_out      => rx_data_from_duv,
      rx_re_in         => rx_re_to_duv
      );


  -- clk generation:
  clk     <= not clk     after period_c/2;
  clk_udp <= not clk_udp after udp_ip_period_c/2;
  rst_n   <= '1'         after 4*period_c;

  test_id <= current;                   -- ES

  
  -----------------------------------------------------------------------------
  -- Three processes
  --  - main gives commands to others, (behav) process with wait statements
  --  - sender provides stimulues when requested, seq. process
  --  - reader checks response, seq. process
  -----------------------------------------------------------------------------
  
  main_ctrl : process
  begin  -- process main_ctrl

    if rst_n = '0' then
      wait until rst_n = '1';
    end if;

    wait for period_c*4;

    -- Start the test transfers
    for n in 0 to num_of_tests_c-1 loop

      current <= n;

      -- Give parameters to duv
      new_rx_to_duv       <= '1';
      source_ip_to_duv    <= test_txs(n).source_ip;
      source_port_to_duv  <= test_txs(n).source_port;
      dest_port_to_duv    <= test_txs(n).dest_port;
      rx_len_to_duv       <= std_logic_vector(to_unsigned(test_txs(n).rx_len, tx_len_w_c));
      rx_erroneous_to_duv <= test_txs(n).rx_erroneous;

      -- Request other process to provide the data
      send_data <= '1';
      wait for udp_ip_period_c;
      send_data <= '0';

      rx_addr_valid_to_duv <= test_txs(n).rx_addr_valid;

      -- Obsolete check, perhaps?
      if ready_for_tx_to_duv = '0' then
        -- Let this be down for a while. Assertion inside the  reader process
        -- will check that no
        -- send requests are made before this is up
        wait for period_c*30;
        ready_for_tx_to_duv <= '1';
      end if;

      -- Wait until duv starts reading and then clear the params
      if rx_re_from_duv = '0' then
        wait until rx_re_from_duv = '1';
      end if;
      wait for period_c;

      new_rx_to_duv       <= '0';
      source_ip_to_duv    <= (others => 'Z');
      source_port_to_duv  <= (others => 'Z');
      dest_port_to_duv    <= (others => 'Z');
      rx_erroneous_to_duv <= 'Z';


      -- Wait until other process completes
      if send_done = '0' then
        wait until send_done = '1';
      end if;

      wait for test_txs(n).delay_before_next;
      
    end loop;  -- n


    wait for period_c*30;

    report "Simulation ended." severity failure;
    
  end process main_ctrl;

  
  -----------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------
  sender : process (clk_udp, rst_n)
    variable send_cnt : integer := 0;
  begin  -- process sender
    if rst_n = '0' then                 -- asynchronous reset (active low)

      rx_data_to_duv  <= (others => '0');
      rx_data_valid_r <= '0';
      send_state      <= idle;
      send_done       <= '0';

    elsif clk_udp'event and clk_udp = '1' then  -- rising clock edge

      case send_state is
        when idle =>
          -- Wait for other process' request
          
          if send_data = '1' then
            send_state      <= sending;
            send_done       <= '0';
            rx_data_valid_r <= '1';
            rx_data_to_duv  <= test_data(0);
          end if;

        when sending =>
          -- Provide the data to duv
          
          if rx_re_from_duv = '1' and rx_data_valid_r = '1' then
            rx_data_valid_r <= '0';

            if test_txs(current).rx_len - send_cnt*2 <= 2 then
              send_done  <= '1';
              send_cnt   := 0;
              send_state <= idle;

            else
              rx_data_to_duv <= test_data((send_cnt+1) mod test_data_amount_c);
              send_cnt       := send_cnt + 1;

            end if;

          else
            rx_data_valid_r <= '1';
          end if;

        when others => null;
      end case;

    end if;
  end process sender;

  -- this is done to make the valid signal go up at the same time with new_rx
  rx_data_valid_to_duv <= rx_data_valid_r or send_data;


  
  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  reader : process (clk, rst_n)
    variable read_cnt : integer := 0;
  begin  -- process reader
    if rst_n = '0' then                 -- asynchronous reset (active low)

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- Check the handshake
      if send_request_from_duv = '1' then
        assert ready_for_tx_to_duv = '1'
          report "Failure in test: Send request when not ready." severity failure;
        -- reset read_cnt
        read_cnt := 0;
      end if;

      -- Read the data
      if rx_empty_from_duv = '0' then
        rx_re_to_duv <= '1';
      else
        rx_re_to_duv <= '0';
      end if;

      -- Check the data
      if rx_re_to_duv = '1' and rx_empty_from_duv = '0' then
        -- We are reading, check that data is correct
        
        assert test_txs(current).rx_addr_valid = '1' and
          test_txs(current).rx_erroneous = '0'
          report "Failure in test: Rx not dumped." severity failure;

        assert rx_data_from_duv =
          test_data((2*read_cnt+1) mod test_data_amount_c) & test_data((2*read_cnt) mod test_data_amount_c)
          report "Warning: Either invalid data or last word from odd length rx. Check manually!" severity warning;

        read_cnt := read_cnt + 1;
      end if;
      
    end if;
  end process reader;

end tb;
