-------------------------------------------------------------------------------
-- Title      : Testbench for hibi receiver
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : tb_hibi_receiver.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Last update: 2012-03-23
-- Platform   : Sim only
-------------------------------------------------------------------------------
-- Description: Set of hard-coded directed tests.
-- 
--              There are few (e.g. 3) invalid transfers and DUV might issue
--              a warning from them.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/08  1.0      niemin95        Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp2hibi_pkg.all;

entity tb_hibi_receiver is
end tb_hibi_receiver;

architecture tb of tb_hibi_receiver is

  constant period_c : time      := 20 ns;
  signal   clk      : std_logic := '1';
  signal   rst_n    : std_logic := '0';


  -- Incoming data from HIBI bus
  constant hibi_comm_width_c : integer := 5;  --3;
  constant hibi_addr_width_c : integer := 32;
  constant hibi_data_width_c : integer := 32;

  signal hibi_comm_to_duv       : std_logic_vector(hibi_comm_width_c-1 downto 0) := (others => '0');
  signal hibi_data_to_duv       : std_logic_vector(hibi_data_width_c-1 downto 0) := (others => '0');
  signal hibi_av_to_duv         : std_logic                                      := '0';
  signal hibi_empty_to_duv      : std_logic                                      := '1';
  signal hibi_re_from_duv       : std_logic;


  -- Going from DUV to tx-ctrl
  signal tx_data_from_duv       : std_logic_vector(udp_block_data_w_c-1 downto 0);
  signal tx_we_from_duv         : std_logic;
  signal tx_full_to_duv         : std_logic                                      := '0';
  signal new_tx_from_duv        : std_logic;
  signal tx_length_from_duv     : std_logic_vector(tx_len_w_c-1 downto 0);
  signal new_tx_ack_to_duv      : std_logic                                      := '0';
  signal release_lock_from_duv  : std_logic;
  signal new_tx_conf_from_duv   : std_logic;
  signal new_rx_conf_from_duv   : std_logic;
  signal ip_from_duv            : std_logic_vector(ip_addr_w_c-1 downto 0);
  signal dest_port_from_duv     : std_logic_vector(udp_port_w_c-1 downto 0);
  signal source_port_from_duv   : std_logic_vector(udp_port_w_c-1 downto 0);
  signal lock_addr_from_duv     : std_logic_vector(hibi_addr_width_c-1 downto 0);
  signal response_addr_from_duv : std_logic_vector(hibi_addr_width_c-1 downto 0);
  signal timeout_from_duv       : std_logic_vector(timeout_w_c-1 downto 0);

  -- From ctrl-regs to DUV
  signal lock_to_duv            : std_logic                                      := '0';
  signal lock_addr_to_duv       : std_logic_vector(hibi_addr_width_c-1 downto 0) := (others => '0');

  -- representing ctrl_regs
  signal regs_locked    : std_logic                                      := '0';
  signal regs_lock_addr : std_logic_vector(hibi_addr_width_c-1 downto 0) := (others => '0');

  -- for data going to multiclk_fifo:
  signal fifo_cnt : integer := 0;



  
  -----------------------------------------------------------------------------
  -- Type defs for test data

  type tx_data_type is array (integer range <>) of std_logic_vector(hibi_data_width_c-1 downto 0);
  type tx_info_type is
  record
    addr           : std_logic_vector(hibi_addr_width_c-1 downto 0);  -- addr from hibi
    len            : integer;           -- #hibi words (e.g. 32b)
    data_16bit_len : integer;           -- #16-b words, only in data tx, not in conf
    delay          : time;              -- between incoming hibi transfers
    data           : tx_data_type(0 to 18);  -- incoming data values
  end record;


  
  -----------------------------------------------------------------------------
  -- Test traffic.
  -- Change these values, and perhaps the tx_info_type, to create new tests.
  -- Note that monitor process is hard-coded to match these!

  signal   current_tx   : integer := 0;

  constant num_of_txs_c : integer := 13;
  type     test_txs_type is array (0 to num_of_txs_c-1) of tx_info_type;

  type     test_data_type is array (0 to 5) of std_logic_vector(15 downto 0);
  constant data1_c : test_data_type :=
    (x"0100", x"0302", x"0504", x"0706", x"0908", x"0a0b");


  -- Tx configuration needs 4 words
  -- 0:timeout, 1: dst ip addr
  -- 2: dst udp port & src udp port, 3: hibi addr (for ack/nack)
  -- 
  -- Data transfers starts with word: 0x0001 & tx_len(11b) & zeros.
  -- Release needs one data word that starts with 0x2...

  -- Rx configuration is similar but without timeout. Hibi addr is used
  -- for ack/nack and for the actual data.

  
  constant test_txs_c : test_txs_type := (
    -- 0: tx_conf, this should get regs locked
    (addr  => x"01234567", len => 4, data_16bit_len => 0, delay => 1 us,
      data => (x"00001234", x"acdcabba", x"0101aaaa", x"0082faac", others => (others => '0'))),
    -- 1: another tx_conf, forwarded to ctrl-regs which will ignore it
    (addr  => x"01234568", len => 4, data_16bit_len => 0, delay => 1 us,
      data => (x"00002212", x"abbacd00", x"1010bbbb", x"0080beba", others => (others => '0'))),
    
    -- 2: start a small tx by correct addr (11 bytes)
    (addr  => x"01234567", len => 4, data_16bit_len => 6, delay => 1 us,
      data => (x"1" & "00000001011" & "00000000000000000",
               data1_c(1) & data1_c(0),
               data1_c(3) & data1_c(2),
               data1_c(5) & data1_c(4), others => (others => '0'))),
    -- 3: start another small tx by correct addr (12 bytes)
    (addr                                      => x"01234567", len => 4, data_16bit_len => 6, delay => 1 us,
      data                                     => (x"1" & "00000001100" & "00000000000000000",
               data1_c(1) & data1_c(0),
               data1_c(3) & data1_c(2),
               data1_c(5) & data1_c(4), others => (others => '0'))),
    -- 4: tx with incorrect addr (not locked), 3 bytes, put zeros to last data words since they wont be sent
    (addr                                                  => x"01234568", len => 2, data_16bit_len => 0, delay => 1 us,
      data                                                 => (x"1" & "00000000011" & "00000000000000000",
                                       x"ff020100", others => (others => '0'))),
    -- 5: invalid release (address that was not locked)
    (addr  => x"0123ffff", len => 1, data_16bit_len => 0, delay => 1 us,
      data => (x"2fffffff", others => (others => '0'))),
    -- 6: releasing the correct release
    (addr  => x"01234567", len => 1, data_16bit_len => 0, delay => 1 us,
      data => (x"2fffffff", others => (others => '0'))),


    
    -- 7: new tx_conf with totally new hibi ddr
    (addr  => x"fedcba98", len => 4, data_16bit_len => 0, delay => 1 us,
      data => (x"00001111", x"0a00000a", x"ffffeeee", x"00880280", others => (others => '0'))),
    -- 8: and another conf to the same address, overrides the
    -- previous config(probably?)
    (addr  => x"fedcba98", len => 4, data_16bit_len => 0, delay => 1 us,
      data => (x"00002222", x"0b00000b", x"ddddcccc", x"00880280", others => (others => '0'))),
    
    -- 9: rx conf packet
    (addr  => x"14235867", len => 4, data_16bit_len => 0, delay => 1 us,
      data => (x"30f0f0f0", x"0f00130b", x"33334444", x"00112233", others => (others => '0'))),
    -- 10: invalid tx from some other sender (9 bytes)
    (addr                                                    => x"01010101", len => 4, data_16bit_len => 0, delay => 1 us,
      data                                                   => (x"1" & "00000001001" & "10001100011000001",
               x"03020100", x"07060504", x"ffffff08", others => (others => '0'))),
    -- 11: long tx from the correct sender (72 bytes)
    (addr  => x"fedcba98", len => 19, data_16bit_len => 36, delay => 1 us,
      data => (x"1" & "00001001000" & "10000100011100001",
               data1_c(1) & data1_c(0),  -- 1
               data1_c(3) & data1_c(2),
               data1_c(5) & data1_c(4),
               data1_c(1) & data1_c(0),
               data1_c(3) & data1_c(2),  -- 5
               data1_c(5) & data1_c(4),
               data1_c(1) & data1_c(0),
               data1_c(3) & data1_c(2),
               data1_c(5) & data1_c(4),
               data1_c(1) & data1_c(0),  -- 10
               data1_c(3) & data1_c(2),
               data1_c(5) & data1_c(4),
               data1_c(1) & data1_c(0),
               data1_c(3) & data1_c(2),
               data1_c(5) & data1_c(4),  -- 15
               data1_c(1) & data1_c(0),
               data1_c(3) & data1_c(2),
               data1_c(5) & data1_c(4)   -- 18
               )),
    -- 12: release
    (addr  => x"fedcba98", len => 1, data_16bit_len => 0, delay => 1 us,
      data => (x"20000000", others => (others => '0')))
    );

  -----------------------------------------------------------------------------




-------------------------------------------------------------------------------
begin  -- tb
-------------------------------------------------------------------------------

  -- clock generation and reset
  clk   <= not clk after period_c/2;
  rst_n <= '1'     after 4*period_c;


  --
  -- TB structure 
  --
  -- (proc hibi) --> DUV  ---> (proc ctrl regs)
  --                      +--> (proc tx_ctrl)
  --                   
  -- Moreover, (proc monitor) checks various things




  duv : entity work.hibi_receiver
    generic map (
      hibi_comm_width_g => hibi_comm_width_c,
      hibi_addr_width_g => hibi_addr_width_c,
      hibi_data_width_g => hibi_data_width_c
      )
    port map (
      clk               => clk,
      rst_n             => rst_n,
      hibi_comm_in      => hibi_comm_to_duv,
      hibi_data_in      => hibi_data_to_duv,
      hibi_av_in        => hibi_av_to_duv,
      hibi_re_out       => hibi_re_from_duv,
      hibi_empty_in     => hibi_empty_to_duv,
      
      tx_data_out       => tx_data_from_duv,
      tx_we_out         => tx_we_from_duv,
      tx_full_in        => tx_full_to_duv,
      new_tx_out        => new_tx_from_duv,
      tx_length_out     => tx_length_from_duv,
      new_tx_ack_in     => new_tx_ack_to_duv,
      release_lock_out  => release_lock_from_duv,
      new_tx_conf_out   => new_tx_conf_from_duv,
      new_rx_conf_out   => new_rx_conf_from_duv,

      ip_out            => ip_from_duv,
      dest_port_out     => dest_port_from_duv,
      source_port_out   => source_port_from_duv,
      lock_addr_out     => lock_addr_from_duv,
      response_addr_out => response_addr_from_duv,
      timeout_in        => '0',         -- ES
      timeout_out       => timeout_from_duv,
      lock_in           => lock_to_duv,
      lock_addr_in      => lock_addr_to_duv
      );


  -----------------------------------------------------------------------------
  -- This process sends data to hibi_receiver according to constant table
  -- test_txs_c. The table contents model the data coming from HIBI.
  -----------------------------------------------------------------------------
  hibi : process
  begin  -- process

    if rst_n = '0' then
      wait until rst_n = '1';
    end if;

    wait for 2* period_c;

    -- start transferring
    for n in 0 to num_of_txs_c-1 loop

      current_tx <= n;

      -- Write the address
      hibi_av_to_duv    <= '1';
      hibi_empty_to_duv <= '0';
      hibi_data_to_duv  <= test_txs_c(n).addr;
      wait for period_c;

      if hibi_re_from_duv = '0' then
        wait until hibi_re_from_duv = '1';
        wait for period_c;
      end if;
      hibi_av_to_duv <= '0';

      
      -- Write the data
      for m in 0 to test_txs_c(n).len-1 loop

        hibi_data_to_duv <= test_txs_c(n).data(m);
        wait for period_c;

        if hibi_re_from_duv = '0' then
          wait until hibi_re_from_duv = '1';
          wait for period_c;
        end if;
        
      end loop;  -- m

      hibi_empty_to_duv <= '1';
      -- Wait for some time before the next tx
      wait for test_txs_c(n).delay;
      
    end loop;  -- n

    report "Simulation ended." severity failure;
  end process hibi;


  -----------------------------------------------------------------------------
  -- This process represents ctrl regs where the hibi_receiver stores params.
  -----------------------------------------------------------------------------
  ctrl_regs : process (clk)
  begin  -- process ctrl_regs
    if clk'event and clk = '1' then

      if new_tx_conf_from_duv = '1' and
        (regs_locked = '0' or regs_lock_addr = lock_addr_from_duv)
      then
        regs_locked    <= '1';
        regs_lock_addr <= lock_addr_from_duv;
      end if;

      if release_lock_from_duv = '1' then
        regs_locked    <= '0';
        regs_lock_addr <= (others => '0');
      end if;
      
    end if;
  end process ctrl_regs;
  lock_to_duv      <= regs_locked;
  lock_addr_to_duv <= regs_lock_addr;

  -----------------------------------------------------------------------------
  -- This process presents tx_ctrl where DUV feeds data. Just acknoledges
  -- each new transfer.
  -----------------------------------------------------------------------------
  tx_ctrl : process
  begin  -- process tx_ctrl

    wait for period_c;

    if new_tx_from_duv = '1' then
      wait for period_c;
      new_tx_ack_to_duv <= '1';
      wait for period_c;
      new_tx_ack_to_duv <= '0';
      wait for period_c;
    end if;
    
  end process tx_ctrl;


  -----------------------------------------------------------------------------
  -- Monitoring process, contains all the important asserts
  -----------------------------------------------------------------------------
  monitoring : process (clk)
    variable new_tx_conf_received1 : std_logic := '0';
    variable new_tx_conf_received2 : std_logic := '0';
    variable new_tx_received1      : std_logic := '0';
    variable new_tx_received2      : std_logic := '0';
    variable release_received      : std_logic := '0';
    variable rx_conf_received      : std_logic := '0';
  begin  -- process monitoring
    if clk'event and clk = '1' then

      if release_lock_from_duv = '1' then
        assert regs_locked = '1' report "Trying to release while unlocked!" severity failure;
        assert test_txs_c(current_tx).addr = regs_lock_addr
          report "Trying to release some other's lock!" severity failure;
        
      end if;

      if new_tx_from_duv = '1' then
        assert regs_locked = '1' and regs_lock_addr = test_txs_c(current_tx).addr
          report "Invalid locking while starting tx!" severity failure;
      end if;


      -- multiclk fifo:
      if tx_we_from_duv = '1' then

        -- make sure that data is correct
        assert tx_data_from_duv = data1_c(fifo_cnt mod 6)
          report "Invalid data to multiclk fifo!" severity failure;

        if fifo_cnt = test_txs_c(current_tx).data_16bit_len - 1 then
          fifo_cnt <= 0;
        else
          fifo_cnt <= fifo_cnt + 1;
        end if;
      end if;


      -------------------------------------------------------------------------
      -- special asserts for each tx:
      -- (these depend on the test traffic, not very automagic...)
      -------------------------------------------------------------------------
      case current_tx is
        when 0 =>
          -- Correct tx_conf pkt, so we should get the data at some point
          -- make sure that it's received
          if new_tx_conf_from_duv = '1' then
            new_tx_conf_received1 := '1';

            -- make sure data is correct
            assert ip_from_duv = test_txs_c(current_tx).data(1)
              and dest_port_from_duv = test_txs_c(current_tx).data(2)(31 downto 16)
              and source_port_from_duv = test_txs_c(current_tx).data(2)(15 downto 0)
              and response_addr_from_duv = test_txs_c(current_tx).data(3)
              and lock_addr_from_duv = test_txs_c(current_tx).addr
              report "Invalid data from tx conf!" severity failure;
          end if;

          
        when 1 =>
          -- Make sure we got the conf at the last stage
          assert new_tx_conf_received1 = '1' report "Tx conf #1 not received!" severity failure;

          -- tx_conf from another sender, make sure that the lock_addr doesn't
          -- change (it should be the one from the previous tx)
          assert regs_lock_addr = test_txs_c(0).addr report "Lock address changed when it should not!" severity failure;

          -- make sure we get the second tx conf, even though it shouldn't
          -- cause any activity
          if new_tx_conf_from_duv = '1' then
            new_tx_conf_received2 := '1';
          end if;

          
        when 2 =>
          -- Make sure we got the conf at the last stage
          assert new_tx_conf_received2 = '1' report "Tx conf #2 not received!" severity failure;

          -- new tx, make sure tx_len is correct
          if new_tx_from_duv = '1' then
            assert tx_length_from_duv = test_txs_c(current_tx).data(0)(id_lo_idx_c-1 downto id_lo_idx_c-tx_len_w_c)
              report "Invalid tx length!" severity failure;
            new_tx_received1 := '1';
          end if;


        when 3 =>
          -- Make sure we got the tx
          assert new_tx_received1 = '1' report "Tx #1 not received!" severity failure;

          -- new tx, make sure tx_len is correct
          if new_tx_from_duv = '1' then
            assert tx_length_from_duv = test_txs_c(current_tx).data(0)(id_lo_idx_c-1 downto id_lo_idx_c-tx_len_w_c)
              report "Invalid tx length!" severity failure;
            new_tx_received2 := '1';
          end if;

          -- these can be cleared for later use
          new_tx_conf_received1 := '0';
          new_tx_conf_received2 := '0';

        when 4 =>
          -- Make sure we got the tx
          assert new_tx_received2 = '1' report "Tx #2 not received!" severity failure;

          -- make sure tx attempt to invalid address doesn't get trough
          assert new_tx_from_duv = '0' report "Invalid tx attempt caused a new tx!" severity failure;


        when 5 =>
          -- Invalid release, make sure that release signal stays down
          assert release_lock_from_duv = '0' report "Invalid release!" severity failure;


        when 6 =>
          -- Correct release
          if release_lock_from_duv = '1' then
            release_received := '1';
          end if;


        when 7 =>
          -- Check release
          assert release_received = '1' report "Lock was not released!" severity failure;

          if new_tx_conf_from_duv = '1' then
            new_tx_conf_received1 := '1';
          end if;


        when 8 =>
          assert new_tx_conf_received1 = '1' report "Tx conf not received!" severity failure;

          if new_tx_conf_from_duv = '1' then
            new_tx_conf_received2 := '1';
          end if;

        when 9 =>
          assert new_tx_conf_received2 = '1' report "Tx conf not received!!" severity failure;

          if new_rx_conf_from_duv = '1' then
            rx_conf_received := '1';

            -- make sure it's correct
            assert ip_from_duv = test_txs_c(current_tx).data(1)
              and dest_port_from_duv = test_txs_c(current_tx).data(2)(31 downto 16)
              and source_port_from_duv = test_txs_c(current_tx).data(2)(15 downto 0)
              and response_addr_from_duv = test_txs_c(current_tx).data(3)
              and lock_addr_from_duv = test_txs_c(current_tx).addr
              report "Invalid data from rx conf!" severity failure;
          end if;


        when 10 =>
          assert rx_conf_received = '1' report "No rx conf received!" severity failure;

          -- Make sure no txs are started
          assert new_tx_from_duv = '0' report "Invalid new tx!" severity failure;
          new_tx_received1 := '0';

        when 11 =>

          if new_tx_from_duv = '1' then
            new_tx_received1 := '1';
            assert tx_length_from_duv = test_txs_c(current_tx).data(0)(id_lo_idx_c-1 downto id_lo_idx_c-tx_len_w_c)
              report "Invalid tx length!" severity failure;
          end if;

        when 12 =>
          assert new_tx_received1 = '1' report "Tx #3 was not received!" severity failure;

          -- no check for last release...
        when others => null;
      end case;
      
    end if;
  end process monitoring;
  
end tb;
