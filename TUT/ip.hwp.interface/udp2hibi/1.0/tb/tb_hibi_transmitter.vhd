-------------------------------------------------------------------------------
-- Title      : Testbench for hibi transmitter
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : tb_hibi_transmitter.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-03-22
-- Platform   : Sim only
-------------------------------------------------------------------------------
-- Description: A couple of hard-coded directed tests and checking.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/21  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp2hibi_pkg.all;


entity tb_hibi_transmitter is
  port (
    read_tmp          : out integer;
    current_test_case : out integer range 0 to 10
    );
end tb_hibi_transmitter;


architecture tb of tb_hibi_transmitter is

  constant hibi_data_width_c : integer := 32;
  constant hibi_addr_width_c : integer := 32;
  constant hibi_comm_width_c : integer := 5;  --3;
  constant ack_fifo_depth_c  : integer := 5;


  
  constant period_c : time      := 20 ns;
  signal   clk      : std_logic := '1';
  signal   rst_n    : std_logic := '0';


  -- to/from rx_ctrl
  signal send_request_to_duv   : std_logic                                      := '0';
  signal rx_len_to_duv         : std_logic_vector(tx_len_w_c-1 downto 0)        := (others => '0');
  signal ready_for_tx_from_duv : std_logic;
  signal rx_empty_to_duv       : std_logic                                      := '1';
  signal rx_data_to_duv        : std_logic_vector(hibi_data_width_c-1 downto 0) := (others => '0');
  signal rx_re_from_duv        : std_logic;
  -- from ctrl_regs
  signal rx_addr_to_duv        : std_logic_vector(hibi_addr_width_c-1 downto 0) := (others => '0');
  signal ack_addr_to_duv       : std_logic_vector(hibi_addr_width_c-1 downto 0) := (others => '0');
  signal send_tx_ack_to_duv    : std_logic                                      := '0';
  signal send_tx_nack_to_duv   : std_logic                                      := '0';
  signal send_rx_ack_to_duv    : std_logic                                      := '0';
  signal send_rx_nack_to_duv   : std_logic                                      := '0';

  
  -- to/from HIBI  
  signal hibi_comm_from_duv    : std_logic_vector(hibi_comm_width_c-1 downto 0);
  signal hibi_data_from_duv    : std_logic_vector(hibi_data_width_c-1 downto 0);
  signal hibi_av_from_duv      : std_logic;
  signal hibi_we_from_duv      : std_logic;
  signal hibi_full_to_duv      : std_logic                                      := '0';


  signal send_en : std_logic := '0';

  --------------------------------------------
  constant test_data_amount_c : integer        := 16;
  type     test_data_type is array (0 to test_data_amount_c-1) of std_logic_vector(hibi_data_width_c-1 downto 0);
  constant test_data          : test_data_type :=
    (x"03020100", x"07060504", x"0b0a0908", x"0f0e0d0c",
      x"13121110", x"17161514", x"1b1a1918", x"1f1e1d1c",
      x"23222120", x"27262524", x"2b2a2928", x"2f2e2d2c",
      x"33323130", x"37363534", x"3b3a3938", x"3f3e3d3c");

  -- HIBI transmitter sends two kinds on data: ack/nack and udp data
  -- The test cases:
  -- 1. tx conf ack
  -- 2. rx conf ack right after previous
  -- 3. new rx
  -- 4. little pause and tx conf nack
  -- 5. more data from the earlier rx
  -- 6. a little pause
  -- 7. more data
  -- 8. new rx
  -- 9. rx conf nack with new data waiting at rx fifo
  -- 10. rx continues

  -- to check the addresses sent
  type     addr_array is array (0 to 7) of std_logic_vector(hibi_addr_width_c-1 downto 0);
  constant addresses_to_check : addr_array :=
    (x"01234567", x"12345678", x"23456789", x"3456789a",
      x"23456789", x"456789ab", x"56789abc", x"456789ab");

  type     rx_len_array is array (0 to 1) of std_logic_vector(tx_len_w_c-1 downto 0);
  -- these don't have to be equal with the data that is send by sender process,
  -- because hibi transmitter just sends this value in header without using it
  -- in any other way
  constant rx_lens : rx_len_array := ("00010011001", "00001100110");

  
  -- empty/full signal is lifted after this amount of reads/writes has
  -- been done:
  constant empty_freq_c : integer := 13;
  constant full_freq_c  : integer := 3;


-------------------------------------------------------------------------------
begin  -- tb
-------------------------------------------------------------------------------

  --
  -- Structure: DUV + 3 processes
  --
  --  main-----------------+
  --   |                   |
  --   v                   V
  --  rx_ctrl --> DUV --> HIBI
  --
  --
  

  duv : entity work.hibi_transmitter
    generic map (
      hibi_data_width_g => hibi_data_width_c,
      hibi_addr_width_g => hibi_addr_width_c,
      hibi_comm_width_g => hibi_comm_width_c,
      ack_fifo_depth_g  => ack_fifo_depth_c
      )
    port map (
      clk              => clk,
      rst_n            => rst_n,
      hibi_comm_out    => hibi_comm_from_duv,
      hibi_data_out    => hibi_data_from_duv,
      hibi_av_out      => hibi_av_from_duv,
      hibi_we_out      => hibi_we_from_duv,
      hibi_full_in     => hibi_full_to_duv,

      send_request_in  => send_request_to_duv,
      rx_len_in        => rx_len_to_duv,
      ready_for_tx_out => ready_for_tx_from_duv,
      rx_empty_in      => rx_empty_to_duv,
      rx_data_in       => rx_data_to_duv,
      rx_re_out        => rx_re_from_duv,
      rx_addr_in       => rx_addr_to_duv,

      ack_addr_in      => ack_addr_to_duv,
      send_tx_ack_in   => send_tx_ack_to_duv,
      send_tx_nack_in  => send_tx_nack_to_duv,
      send_rx_ack_in   => send_rx_ack_to_duv,
      send_rx_nack_in  => send_rx_nack_to_duv
      );


  -- clk generation
  clk   <= not clk after period_c/2;
  rst_n <= '1'     after period_c*4;



  -----------------------------------------------------------------------------
  -- Keeps track of test pahse and request rx-ctrl process to provide more data
  -----------------------------------------------------------------------------
  main : process
  begin  -- process main

    if rst_n = '0' then
      wait until rst_n = '1';
    end if;

    wait for period_c*4;


    -- test cases
    -- 1. tx ack
    -- 2. rx ack right after the tx ack
    -- 3. new rx
    -- 4. little pause and tx nack
    -- 5. more data from the earlier rx
    -- 6. a little pause
    -- 7. more data
    -- 8. new rx
    -- 9. rx nack with new data waiting at rx fifo
    -- 10. rx continues

    -- 1.
    current_test_case  <= 1;
    send_tx_ack_to_duv <= '1';
    ack_addr_to_duv    <= addresses_to_check(0);
    wait for period_c;
    send_tx_ack_to_duv <= '0';
    wait for period_c;
    -- 2.
    current_test_case  <= 2;
    send_rx_ack_to_duv <= '1';
    ack_addr_to_duv    <= addresses_to_check(1);
    wait for period_c;
    send_rx_ack_to_duv <= '0';

    wait for period_c*10;

    -- 3.
    current_test_case <= 3;
    if ready_for_tx_from_duv = '0' then
      wait until ready_for_tx_from_duv = '1';
    end if;
    send_request_to_duv <= '1';
    rx_len_to_duv       <= rx_lens(0);
    rx_addr_to_duv      <= addresses_to_check(2);
    wait for period_c;
    send_request_to_duv <= '0';
    send_en             <= '1';

    -- let data flow for a while...
    wait for period_c*40;

    -- 4.
    current_test_case <= 4;
    send_en           <= '0';
    wait for period_c*5;

    send_tx_nack_to_duv <= '1';
    ack_addr_to_duv     <= addresses_to_check(3);
    wait for period_c;
    send_tx_nack_to_duv <= '0';
    wait for period_c*3;

    -- 5.
    current_test_case <= 5;
    send_en           <= '1';
    wait for period_c*25;

    -- 6.
    current_test_case <= 6;
    send_en           <= '0';
    wait for period_c*10;

    -- 7.
    current_test_case <= 7;
    send_en           <= '1';
    wait for period_c*31;
    send_en           <= '0';
    wait for period_c;

    -- 8.
    current_test_case <= 8;
    if ready_for_tx_from_duv = '0' then
      wait until ready_for_tx_from_duv = '1';
    end if;
    send_request_to_duv <= '1';
    rx_len_to_duv       <= rx_lens(1);
    rx_addr_to_duv      <= addresses_to_check(5);
    wait for period_c;
    send_request_to_duv <= '0';
    send_en             <= '1';

    wait for period_c*11;

    -- 9.
    current_test_case   <= 9;
    send_rx_nack_to_duv <= '1';
    ack_addr_to_duv     <= addresses_to_check(6);
    wait for period_c;
    send_rx_nack_to_duv <= '0';

    -- 10.
    current_test_case <= 10;
    wait for period_c*27;
    send_en           <= '0';


    -- halt
    wait for period_c*20;
    report "Simulation ended." severity failure;
    
  end process main;


  -----------------------------------------------------------------------------
  -- This process mimick the rx-ctrl component which gets data from UDP/IP
  -- and gives it to hibi-transmitter. Enabled by main process.
  -----------------------------------------------------------------------------
  rx_ctrl : process (clk, rst_n)
    variable send_cnt  : integer   := 0;
    variable empty_cnt : integer   := 0;
    variable empty     : std_logic := '0';
  begin  -- process rx_ctrl
    if rst_n = '0' then                 -- asynchronous reset (active low)

    elsif clk'event and clk = '1' then  -- rising clock edge

      if send_en = '1' then

        -- Be empty every once and a while
        if empty = '0' and empty_cnt = empty_freq_c then
          -- Be empty every once and a while
          empty           := '1';
          rx_empty_to_duv <= '1';
          empty_cnt       := 0;
          if rx_re_from_duv = '1' and rx_empty_to_duv = '0' then
            send_cnt       := send_cnt + 1;
            rx_data_to_duv <= test_data(send_cnt mod test_data_amount_c);
          end if;
          
        elsif empty = '1' and rx_empty_to_duv = '1' then
          if empty_cnt = 3 then
            -- stop being empty
            empty     := '0';
            empty_cnt := 0;
            
          else
            empty_cnt := empty_cnt + 1;
          end if;

        else
          rx_empty_to_duv <= '0';
          rx_data_to_duv  <= test_data(send_cnt mod test_data_amount_c);

          if rx_re_from_duv = '1' and rx_empty_to_duv = '0' then
            send_cnt       := send_cnt + 1;
            empty_cnt      := empty_cnt + 1;
            rx_data_to_duv <= test_data(send_cnt mod test_data_amount_c);
          end if;
        end if;

      else
        if rx_re_from_duv = '1' and rx_empty_to_duv = '0' then
          send_cnt  := send_cnt + 1;
          empty_cnt := empty_cnt + 1;
        end if;
        rx_empty_to_duv <= '1';
        rx_data_to_duv  <= (others => 'Z');
      end if;
      
    end if;
  end process rx_ctrl;


  -----------------------------------------------------------------------------
  -- This process mimicks hibi wrapper and check data written by DUV.
  -----------------------------------------------------------------------------
  hibi_wrapper : process (clk, rst_n)
    variable full_cnt      : integer   := 0;
    variable full          : std_logic := '0';
    variable read_cnt      : integer   := 0;
    variable addr_cnt      : integer   := 0;
    variable header_coming : std_logic := '0';
  begin  -- process hibi_wrapper
    if rst_n = '0' then                 -- asynchronous reset (active low)

    elsif clk'event and clk = '1' then  -- rising clock edge

      if hibi_av_from_duv = '1' and hibi_we_from_duv = '1' and hibi_full_to_duv = '0' then

        assert hibi_data_from_duv = addresses_to_check(addr_cnt)
          report "Failure in test: Invalid address." severity failure;

        -- with current test structure, a header follows every time except
        -- after addr 4 and 7
        if addr_cnt = 4 or addr_cnt = 7 then
          addr_cnt := addr_cnt + 1;
        else
          header_coming := '1';
        end if;

      elsif header_coming = '1' and hibi_we_from_duv = '1' and hibi_full_to_duv = '0' then
        -- test cases
        -- 1. tx ack
        -- 2. rx ack right after the tx ack
        -- 3. new rx
        -- 4. little pause and tx nack
        -- 5. more data from the earlier rx
        -- 6. a little pause
        -- 7. more data
        -- 8. new rx
        -- 9. rx nack with new data waiting at rx fifo
        -- 10. rx continues

        case addr_cnt is
          when 0 =>
            -- tx ack
            assert
              hibi_data_from_duv(id_hi_idx_c downto id_lo_idx_c) = ack_header_id_c and
              hibi_data_from_duv(id_lo_idx_c-1) = '1'
              report "Failure in test: Invalid header (tx ack)" severity failure;
          when 1 =>
            -- rx ack
            assert
              hibi_data_from_duv(id_hi_idx_c downto id_lo_idx_c) = ack_header_id_c and
              hibi_data_from_duv(id_lo_idx_c-1) = '0'
              report "Failure in test: Invalid header (rx ack)" severity failure;
          when 2 =>
            -- new rx
            assert
              hibi_data_from_duv(id_hi_idx_c downto id_lo_idx_c) = rx_data_header_id_c and
              hibi_data_from_duv(id_lo_idx_c-1 downto id_lo_idx_c-tx_len_w_c) = rx_lens(0)
              report "Failure in test: Ivalid header (new rx)" severity failure;
          when 3 =>
            -- tx nack
            assert
              hibi_data_from_duv(id_hi_idx_c downto id_lo_idx_c) = nack_header_id_c and
              hibi_data_from_duv(id_lo_idx_c-1) = '1'
              report "Failure in test: Invalid header (tx nack)" severity failure;
          when 5 =>
            -- new rx #2
            assert
              hibi_data_from_duv(id_hi_idx_c downto id_lo_idx_c) = rx_data_header_id_c and
              hibi_data_from_duv(id_lo_idx_c-1 downto id_lo_idx_c-tx_len_w_c) = rx_lens(1)
              report "Failure in test: Invalid header (new rx #2)" severity failure;
          when 6 =>
            -- rx nack
            assert
              hibi_data_from_duv(id_hi_idx_c downto id_lo_idx_c) = nack_header_id_c and
              hibi_data_from_duv(id_lo_idx_c-1) = '0'
              report "Failure in test: Invalid header (rx nack)" severity failure;
          when others => null;
        end case;

        header_coming := '0';
        addr_cnt      := addr_cnt + 1;
        
        
      else
        -- Accept the incoming data. Pretend to be full occasionally.
        
        if full = '0' and full_cnt = full_freq_c then
          -- be full
          full             := '1';
          full_cnt         := 0;
          hibi_full_to_duv <= '1';
        end if;

        if full = '1' and hibi_full_to_duv = '1' then
          if full_cnt = 4 then
            -- stop being full
            full             := '0';
            full_cnt         := 0;
            hibi_full_to_duv <= '0';
          else
            full_cnt := full_cnt + 1;
          end if;

        else
          -- read normally
          
          if hibi_we_from_duv = '1' and hibi_full_to_duv = '0' then
            assert hibi_data_from_duv = test_data(read_cnt mod test_data_amount_c)
              report "Failure in test: Invalid data." severity failure;

            read_cnt := read_cnt + 1;
            read_tmp <= read_cnt;
            full_cnt := full_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process hibi_wrapper;
end tb;
