-------------------------------------------------------------------------------
-- Title      : Testbench for tx ctrl
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : tb_tx_ctrl.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Last update: 2012-03-21
-- Platform   : Sim only
-------------------------------------------------------------------------------
-- Description: A couple of hard-coded test cases for ctrl-registers.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/14  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp2hibi_pkg.all;


entity tb_tx_ctrl is
end tb_tx_ctrl;


architecture tb of tb_tx_ctrl is

  constant period_c              : time    := 20 ns;  -- 20 ns= 50 MHz
  constant frequency_c           : integer := 50_000_000;
  constant udp_ip_period_c       : time    := 40 ns;  -- 40ns = 25MHz
  constant multiclk_fifo_depth_c : integer := 10;

  signal clk            : std_logic := '1';
  signal clk_udp_to_duv : std_logic := '1';
  signal rst_n          : std_logic := '0';


  
  -- Send running numbers to constant IP-addr and port
  signal test_len : integer;            -- in bytes
  type test_data_type is array (0 to 19) of std_logic_vector(15 downto 0);
  constant test_data_c : test_data_type := (
    x"0100", x"0302", x"0504", x"0706", x"0908", x"0b0a", x"0d0c", x"0f0e", x"1110", x"1312",
    x"2120", x"2322", x"2524", x"2726", x"2928", x"2b2a", x"2d2c", x"2f2e", x"3130", x"3332");
  constant test_ip_c          : std_logic_vector(ip_addr_w_c-1 downto 0)  := x"01234567";
  constant test_dest_port_c   : std_logic_vector(udp_port_w_c-1 downto 0) := x"fefe";
  constant test_source_port_c : std_logic_vector(udp_port_w_c-1 downto 0) := x"cbcb";

  
  --
  -- Data and parameters to DUV
  --  data from receiver (=tb), goes to multiclk fifo inside duv
  signal tx_data_to_duv           : std_logic_vector(udp_block_data_w_c-1 downto 0) := (others => '0');
  signal tx_we_to_duv             : std_logic                                       := '0';
  signal tx_full_from_duv         : std_logic;
  --  parameters from hibi_receiver (=tb)
  signal new_tx_to_duv            : std_logic                                       := '0';
  signal tx_len_to_duv            : std_logic_vector(tx_len_w_c-1 downto 0)         := (others => '0');
  signal new_tx_ack_from_duv      : std_logic;
  signal timeout_to_duv           : std_logic_vector(timeout_w_c-1 downto 0)        := (others => '0');
  --  parameters from ctrl regs (=tb)
  signal tx_ip_to_duv             : std_logic_vector(ip_addr_w_c-1 downto 0)        := (others => '0');
  signal tx_dest_port_to_duv      : std_logic_vector(udp_port_w_c-1 downto 0)       := (others => '0');
  signal tx_source_port_to_duv    : std_logic_vector(udp_port_w_c-1 downto 0)       := (others => '0');
  signal timeout_release_from_duv : std_logic;


  --
  -- Data and parameters from DUV
  --  data to udp/ip, comes from multclk fifo inside duv
  signal tx_data_from_duv       : std_logic_vector(udp_block_data_w_c-1 downto 0);
  signal tx_data_valid_from_duv : std_logic;
  signal tx_re_to_duv           : std_logic := '0';
  --  parameters to udp/ip
  signal new_tx_from_duv        : std_logic;
  signal tx_len_from_duv        : std_logic_vector(tx_len_w_c-1 downto 0);
  signal dest_ip_from_duv       : std_logic_vector(ip_addr_w_c-1 downto 0);
  signal dest_port_from_duv     : std_logic_vector(udp_port_w_c-1 downto 0);
  signal source_port_from_duv   : std_logic_vector(udp_port_w_c-1 downto 0);


  
  signal locked : std_logic := '0';

  -- Signals used for communication between processes and 2 state machines
  signal write_data  : std_logic := '0';  -- request write to start
  signal write_done  : std_logic;
  type   write_state_type is (idle, writing);
  signal write_state : write_state_type;

  signal read_data  : std_logic := '0';  -- request read to start
  signal read_done  : std_logic;
  type   read_state_type is (rx_idle, reading);
  signal read_state : read_state_type;


  
  -- For timeout testing
  signal   do_timeout          : std_logic := '0';  -- test timeout or not?
  constant last_correct_word_c : integer   := 5;    -- #words before stopping
  constant test_timeout_c      : integer   := 50;   -- #cycles that DUV waits

  -- Tb should finish within certain #cycles, otherwise it is stuck
  constant tb_timeout_value_c : integer := 10_000;  -- #cycles
  signal   timeout_cnt        : integer;


  -------------------------------------------------------------------------------
begin  -- tb
  -------------------------------------------------------------------------------


  -- clk and reset generation
  rst_n          <= '1'                after 4*period_c;
  clk            <= not clk            after period_c/2;
  clk_udp_to_duv <= not clk_udp_to_duv after udp_ip_period_c/2;


  
  duv : entity work.tx_ctrl
    generic map (
      frequency_g           => frequency_c,
      multiclk_fifo_depth_g => multiclk_fifo_depth_c
      )
    port map (

      clk               => clk,
      clk_udp           => clk_udp_to_duv,
      rst_n             => rst_n,
      -- for multiclk fifo
      tx_data_in        => tx_data_to_duv,
      tx_we_in          => tx_we_to_duv,
      tx_full_out       => tx_full_from_duv,
      -- from multiclk fifo to udp/ip
      tx_data_out       => tx_data_from_duv,
      tx_data_valid_out => tx_data_valid_from_duv,
      tx_re_in          => tx_re_to_duv,
      -- other signals to udp/ip
      new_tx_out        => new_tx_from_duv,
      tx_len_out        => tx_len_from_duv,
      dest_ip_out       => dest_ip_from_duv,
      dest_port_out     => dest_port_from_duv,
      source_port_out   => source_port_from_duv,
      -- signals to and from hibi_receiver
      new_tx_in         => new_tx_to_duv,
      tx_len_in         => tx_len_to_duv,
      new_tx_ack_out    => new_tx_ack_from_duv,
      timeout_in        => timeout_to_duv,

      -- signals to and from ctrl regs
      tx_ip_in            => tx_ip_to_duv,
      tx_dest_port_in     => tx_dest_port_to_duv,
      tx_source_port_in   => tx_source_port_to_duv,
      timeout_release_out => timeout_release_from_duv
      );


  -------------------------------------------------------------------------------
  -- This process models hibi receiver and ctrl regs
  -------------------------------------------------------------------------------
  main : process
  begin  -- process

    if rst_n = '0' then
      wait until rst_n = '1';
    end if;

    wait for period_c*4;


    tx_ip_to_duv          <= test_ip_c;
    tx_dest_port_to_duv   <= test_dest_port_c;
    tx_source_port_to_duv <= test_source_port_c;

    -- Perform multiple tests with different test_len
    for k in 1 to 40 loop

      test_len <= k;
      wait for period_c;

      for n in 0 to 1 loop



        -- Cause timeout at the second round on purpose, when len is long enough
        if n = 1 and k > 2*last_correct_word_c + 2 then
          do_timeout <= '1';
        end if;

        

        
        -- Ask the other test process to start writing, wait that it starts,
        -- and give parameters
        write_data <= '1';
        wait for period_c*2;

        new_tx_to_duv  <= '1';
        tx_len_to_duv  <= std_logic_vector(to_unsigned(test_len, tx_len_w_c));
        timeout_to_duv <= std_logic_vector(to_unsigned(test_timeout_c, timeout_w_c));

        wait for period_c;
        write_data <= '0';


        -- Wait that DUV acknowledges the data
        if new_tx_ack_from_duv = '0' then
          wait until new_tx_ack_from_duv = '1';
        end if;
        wait for period_c;

        new_tx_to_duv <= '0';
        wait for period_c;


        
        -- Check that outputs to udp/ip are correct
        assert
          new_tx_from_duv = '1'
          and to_integer(unsigned(tx_len_from_duv)) = test_len
          and dest_ip_from_duv = test_ip_c
          and source_port_from_duv = test_source_port_c
          and dest_port_from_duv = test_dest_port_c
          report "Failure in test : Invalid tx info to UDP/IP." severity failure;

        
        -- Ask reading process to start
        read_data <= '1';
        -- longer wait because of slower clk in udp
        wait for period_c*3;
        read_data <= '0';


        if write_done = '0' then
          wait until write_done = '1';
        end if;


        -- Test timeout
        if do_timeout = '1' then
          wait for (test_timeout_c + 1) * period_c;
          -- now it should happen
          wait for period_c;
          -- now timeout_release_from_duv should be up
          assert timeout_release_from_duv = '1'
            report "No timeout release from duv." severity failure;
          assert tx_full_from_duv = '1'
            report "Full signal not lifted after timeout." severity failure;
        end if;


        if read_done = '0' then
          wait until read_done = '1';
        end if;
        

      end loop;  -- n

      do_timeout <= '0';
      wait for period_c*30;
    end loop;  -- k

    wait for period_c*30;

    report "Simulation ended." severity failure;

  end process main;

  -----------------------------------------------------------------------------
  -- This process models hibi receiver. Writes test_len words to DUV.
  -----------------------------------------------------------------------------
  writer : process (clk, rst_n)
    variable write_cnt : integer := 0;
  begin  -- process writer
    if rst_n = '0' then                 -- asynchronous reset (active low)

      tx_data_to_duv <= (others => '0');
      tx_we_to_duv   <= '0';
      write_state    <= idle;
      write_done     <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      case write_state is
        when idle =>
          tx_we_to_duv <= '0';
          
          -- Start writing when main process asks that
          if write_data = '1' then
            write_state <= writing;
            write_done  <= '0';
          end if;

        when writing =>

          if tx_full_from_duv = '0' then

            if write_cnt = test_len/2 + (test_len mod 2) then
              -- All has been written
              write_done   <= '1';
              write_cnt    := 0;
              write_state  <= idle;
              tx_we_to_duv <= '0';

            else
              -- Write two bytes at a time
              tx_data_to_duv <= test_data_c(write_cnt);
              tx_we_to_duv   <= '1';
              write_cnt      := write_cnt + 1;

              -- Occasionally, stop writing after few words.  Check elsewhere that
              -- DUV does correct timeout operation
              if do_timeout = '1' and write_cnt = last_correct_word_c + 1 then
                write_done  <= '1';
                write_state <= idle;
                write_cnt   := 0;
              end if;
            end if;
          end if;

        when others => null;
      end case;

    end if;
  end process writer;




  
  -----------------------------------------------------------------------------
  -- This models UDP/IP
  -----------------------------------------------------------------------------
  reader : process (clk_udp_to_duv, rst_n)
    variable read_cnt : integer;
  begin  -- process reader
    if rst_n = '0' then                 -- asynchronous reset (active low)
      read_state <= rx_idle;
      read_done  <= '0';
      read_cnt   := 0;
      
    elsif clk_udp_to_duv'event and clk_udp_to_duv = '1' then
                                        -- rising clock edge

      case read_state is

        
        when rx_idle =>
          tx_re_to_duv <= '0';
          
          -- Start writing when main process asks that
          if read_data = '1' then
            read_state <= reading;
            read_done  <= '0';
          end if;

        when reading =>

          if tx_data_valid_from_duv = '1' then
            tx_re_to_duv <= '1';
          else
            tx_re_to_duv <= '0';
          end if;

          if tx_re_to_duv = '1' and tx_data_valid_from_duv = '1' then

            -- Check that data is valid
            if do_timeout = '1' and read_cnt > last_correct_word_c then
              assert tx_data_from_duv = x"0000"
                report "Invalid data from duv after timeout!" severity failure;
            else
              assert tx_data_from_duv = test_data_c(read_cnt)
                report "Invalid data from duv during normal action!" severity failure;
            end if;

            read_cnt := read_cnt + 1;
            
            if read_cnt = test_len/2 + (test_len mod 2) then
              -- All has been read
              read_state <= rx_idle;
              read_done  <= '1';
              read_cnt   := 0;
            end if;

          end if;
          
        when others => null;
      end case;
      
    end if;
  end process reader;



  -----------------------------------------------------------------------------
  -- Make sure that the testbench doesn't get stuck forever
  -----------------------------------------------------------------------------
  tb_timeout : process (clk, rst_n)

  begin  -- process tb_timeout
    if rst_n = '0' then                 -- asynchronous reset (active low)
      timeout_cnt <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if timeout_cnt = tb_timeout_value_c then
        report "Testbench timeout, something has failed!" severity failure;
      else
        timeout_cnt <= timeout_cnt + 1;
      end if;
    end if;
  end process tb_timeout;



end tb;
