-------------------------------------------------------------------------------
-- Title      : Rx control
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : rx_ctrl.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-03-23
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Sub-block of udp2hibi.
--              Receives data from UDP/IP. Gives parameters from ctrl-regs
--              and gives data to hibi_transmitter. Includes both
--              multiclk-fifo and regular fifo and 2 state machines.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2009/12/16  1.0      niemin95        Created
-- 2012-03-23  1.0      ege             Beautifying and commenting.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp2hibi_pkg.all;



entity rx_ctrl is

  generic (
    rx_multiclk_fifo_depth_g : integer := 10;
    tx_fifo_depth_g          : integer := 10;
    hibi_data_width_g        : integer := 32;  -- bits. do not change
    frequency_g              : integer := 50000000
    );

  port (
    clk              : in  std_logic;
    clk_udp          : in  std_logic;
    rst_n            : in  std_logic;
    -- from UDP/IP
    rx_data_in       : in  std_logic_vector(udp_block_data_w_c-1 downto 0);
    rx_data_valid_in : in  std_logic;
    rx_re_out        : out std_logic;
    new_rx_in        : in  std_logic;
    rx_len_in        : in  std_logic_vector(tx_len_w_c-1 downto 0);
    source_ip_in     : in  std_logic_vector(ip_addr_w_c-1 downto 0);
    dest_port_in     : in  std_logic_vector(udp_port_w_c-1 downto 0);
    source_port_in   : in  std_logic_vector(udp_port_w_c-1 downto 0);
    rx_erroneous_in  : in  std_logic;
    -- to/from ctrl regs
    ip_out           : out std_logic_vector(ip_addr_w_c-1 downto 0);
    dest_port_out    : out std_logic_vector(udp_port_w_c-1 downto 0);
    source_port_out  : out std_logic_vector(udp_port_w_c-1 downto 0);
    rx_addr_valid_in : in  std_logic;
    -- to/from hibi_transmitter
    send_request_out : out std_logic;
    rx_len_out       : out std_logic_vector(tx_len_w_c-1 downto 0);
    ready_for_tx_in  : in  std_logic;
    rx_empty_out     : out std_logic;
    rx_data_out      : out std_logic_vector(hibi_data_width_g-1 downto 0);
    rx_re_in         : in  std_logic
    );

end rx_ctrl;


architecture rtl of rx_ctrl is

  component multiclk_fifo
    generic (
      re_freq_g    : integer;
      we_freq_g    : integer;
      depth_g      : integer;
      data_width_g : integer);
    port (
      clk_re    : in  std_logic;
      clk_we    : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;
      re_in     : in  std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic);
  end component;

  component fifo
    generic (
      data_width_g : integer;
      depth_g      : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;
      re_in     : in  std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic);
  end component;

  signal we_to_multiclk_fifo      : std_logic;
  signal data_from_multiclk_fifo  : std_logic_vector(udp_block_data_w_c-1 downto 0);
  signal empty_from_multiclk_fifo : std_logic;
  signal full_from_multiclk_fifo  : std_logic;
  signal re_to_multiclk_fifo      : std_logic;
  signal data_to_tx_fifo          : std_logic_vector(hibi_data_width_g-1 downto 0);
  signal we_to_tx_fifo            : std_logic;
  signal full_from_tx_fifo        : std_logic;
  signal empty_for_tx_we          : std_logic;

  -- Counter that keeps track of how much data there still is to be written to
  -- the tx fifo
  signal tx_data_cnt_r        : integer range 0 to 2**(tx_len_w_c-1)-1;
  signal multiclk_re_r        : std_logic;
  signal lower_half_r         : std_logic_vector(udp_block_data_w_c-1 downto 0);
  signal read_upper_half_r    : std_logic;
  signal udp_re_multiclk_we_r : std_logic;

  -- Fifo glue means the logic between those two fifos...
  -- multclkfifo -> glue -> fifo
  type   fifo_glue_state_type is (idle, working, dumping);
  signal fifo_glue_state_r : fifo_glue_state_type;

  signal activate_fifo_glue_r : std_logic;

  -- rx len will be in halfwords
  signal rx_len_r             : integer range 0 to 2**(tx_len_w_c-1)-1;
  -- this len will be in bytes, and it's just forwarded to hibi transmitter
  signal rx_len_for_ht_r      : std_logic_vector(tx_len_w_c-1 downto 0);


  signal prevent_read_r       : std_logic;
  signal new_rx_old_r         : std_logic;
  signal dump_rx_r            : std_logic;
  signal rx_erroneous_r       : std_logic;

  -- Rx ctrl main state machine
  type   rx_ctrl_state_type is (wait_rx, wait_address, check_address);
  signal rx_ctrl_state_r : rx_ctrl_state_type;

  signal rx_data_valid_old_r : std_logic;

-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  -- 
  --             +-------------------------------------------+  
  --             |                                           |
  --  udp/ip  ------->  multiclk fifo  --> glue  --> fifo  ---> hibi
  --             |  |       /                                |
  --             |  +->  main                                |
  --             |        |                                  |
  --  ctrl regs <---------+                                  |
  --             |                                           |
  --             +-------------------------------------------+  
  -- 


  
  -- This gets data from udp/ip and performs clk domain crossing.
  rx_multiclk_fifo : multiclk_fifo
    generic map (
      re_freq_g    => frequency_g,
      we_freq_g    => udp_block_freq_c,
      depth_g      => rx_multiclk_fifo_depth_g,
      data_width_g => udp_block_data_w_c
      )
    port map (
      clk_re => clk,
      clk_we => clk_udp,
      rst_n  => rst_n,

      data_in   => rx_data_in,
      we_in     => we_to_multiclk_fifo,
      full_out  => full_from_multiclk_fifo,
      one_p_out => open,
      re_in     => re_to_multiclk_fifo,
      data_out  => data_from_multiclk_fifo,
      empty_out => empty_from_multiclk_fifo,
      one_d_out => open
      );


  -- Hibi transmitter reads data from this fifo.
  -- Should be exaclt twice as wide and udp/ip data, i.e. 2*16b = 32b.
  tx_fifo : fifo
    generic map (
      data_width_g => hibi_data_width_g,
      depth_g      => tx_fifo_depth_g
      )
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => data_to_tx_fifo,
      we_in     => we_to_tx_fifo,
      full_out  => full_from_tx_fifo,
      one_p_out => open,

      re_in     => rx_re_in,
      data_out  => rx_data_out,
      empty_out => rx_empty_out,
      one_d_out => open
      );


  -----------------------------------------------------------------------------
  -- ** reading data from udp/ip to multiclk fifo **
  -- udp_re_multiclk_we_r is used to avoid combinatory loop
  -----------------------------------------------------------------------------
  rx_re_out           <= udp_re_multiclk_we_r and (not full_from_multiclk_fifo) and (not prevent_read_r);
  we_to_multiclk_fifo <= udp_re_multiclk_we_r and rx_data_valid_in and (not prevent_read_r);

  rx_read_to_multiclk : process (clk_udp, rst_n)
  begin  -- process rx_read_to_multiclk
    if rst_n = '0' then                 -- asynchronous reset (active low)
      udp_re_multiclk_we_r <= '0';
      rx_data_valid_old_r  <= '0';
    elsif clk_udp'event and clk_udp = '1' then  -- rising clock edge

      -- due to the behaviour of the DM9000A eth chip controller block, the data_valid
      -- goes down after every read. If we don't lower the re right after it,
      -- we are able to read a cycle faster
      rx_data_valid_old_r <= rx_data_valid_in;

      if rx_data_valid_in = '1' or rx_data_valid_old_r = '1' then
        udp_re_multiclk_we_r <= '1';
      else
        udp_re_multiclk_we_r <= '0';
      end if;
    end if;
  end process rx_read_to_multiclk;



  -----------------------------------------------------------------------------
  -- ** reading data from multiclk fifo to tx fifo **
  --
  -- when the tx is of odd length, empty_from_multiclk_fifo is up when we are
  -- supposed to write the last word to tx_fifo
  -----------------------------------------------------------------------------
  for_tx_fifo_we : process (empty_from_multiclk_fifo, tx_data_cnt_r)
  begin  -- process for_tx_fifo_we
    if empty_from_multiclk_fifo = '0' or tx_data_cnt_r = 0 then
      empty_for_tx_we <= '0';
    else
      empty_for_tx_we <= '1';
    end if;
  end process for_tx_fifo_we;

  re_to_multiclk_fifo <= multiclk_re_r and (not (full_from_tx_fifo and read_upper_half_r));
  we_to_tx_fifo       <= read_upper_half_r and (not empty_for_tx_we);

  -- Tx fifo is twice as wide as multiclk, so we need to have a buffer
  data_to_tx_fifo <= data_from_multiclk_fifo & lower_half_r;


  -- This process waits for a command from the main process, and then forwards
  -- tx_len_r of words from multiclk_fifo to tx_fifo. Or dumps the
  -- data i its recevier is not know.
  read_multiclk_write_tx_fifo : process (clk, rst_n)
  begin  -- process read_multiclk_write_tx_fifo
    if rst_n = '0' then                 -- asynchronous reset (active low)
      
      multiclk_re_r     <= '0';
      lower_half_r      <= (others => '0');
      read_upper_half_r <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge


      case fifo_glue_state_r is

        when idle =>

          -- New tx, start to push data forward
          if activate_fifo_glue_r = '1' then
            tx_data_cnt_r     <= rx_len_r;
            read_upper_half_r <= '0';
            fifo_glue_state_r <= working;
            
          elsif dump_rx_r = '1' then
            -- if there is no receiver, just read the tx out of the multiclk
            tx_data_cnt_r     <= rx_len_r;
            fifo_glue_state_r <= dumping;
          end if;


          
        when working =>
          
          if empty_from_multiclk_fifo = '0' and tx_data_cnt_r /= 0 then
            multiclk_re_r <= '1';
          end if;


          if full_from_tx_fifo = '0' and read_upper_half_r = '1'
            and (empty_from_multiclk_fifo = '0' or tx_data_cnt_r = 0)
          then
            -- here we write to the tx fifo
            read_upper_half_r <= '0';

            if tx_data_cnt_r < 2 then
              -- last word is written now
              fifo_glue_state_r <= idle;
              multiclk_re_r     <= '0';
            else
              tx_data_cnt_r <= tx_data_cnt_r-1;
            end if;

          elsif multiclk_re_r = '1' and empty_from_multiclk_fifo = '0' and
            read_upper_half_r = '0'
          then

            -- Write lower half to the tmp buffer
            lower_half_r      <= data_from_multiclk_fifo;
            read_upper_half_r <= '1';
            tx_data_cnt_r     <= tx_data_cnt_r - 1;

            -- prevent reading in case there is another rx waiting right after
            -- this one (shouldn't be though...)
            if tx_data_cnt_r = 1 then
              multiclk_re_r <= '0';
            end if;
          end if;


          
        when dumping =>
          -- No receiver set for this message, so dump it to bit heaven.
          if empty_from_multiclk_fifo = '0' then
            multiclk_re_r <= '1';
          end if;

          if multiclk_re_r = '1' and empty_from_multiclk_fifo = '0' then
            if tx_data_cnt_r = 1 then
              -- last one, get back to idle
              fifo_glue_state_r <= idle;
              multiclk_re_r     <= '0';
            else
              tx_data_cnt_r <= tx_data_cnt_r - 1;
            end if;
          end if;

        when others => null;
      end case;
      
    end if;
  end process read_multiclk_write_tx_fifo;


  -----------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------
  main : process (clk, rst_n)
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      activate_fifo_glue_r <= '0';
      prevent_read_r       <= '0';
      new_rx_old_r         <= '0';
      rx_ctrl_state_r      <= wait_rx;
      rx_erroneous_r       <= '0';
      dump_rx_r            <= '0';
      rx_len_r             <= 0;
      rx_len_for_ht_r      <= (others => '0');

      ip_out           <= (others => '0');
      dest_port_out    <= (others => '0');
      source_port_out  <= (others => '0');
      send_request_out <= '0';
      rx_len_out       <= (others => '0');
      
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- **************************************************************************
      -- * IMPORTANT NOTE ABOUT SYNCHRONIZATION!                                  *
      -- * ... there is no synchronization. Multiclk fifos and thus this whole    *
      -- * block requires clk edges to be synchronized even if frequencies differ * 
      -- * (must be f1 = k*f2, k E Z+). So having two completely asynchronous     *
      -- * clocks will cause metastability. Don't do it.                          *
      -- **************************************************************************

      new_rx_old_r         <= new_rx_in;
      activate_fifo_glue_r <= '0';
      dump_rx_r            <= '0';
      send_request_out     <= '0';

      case rx_ctrl_state_r is

        when wait_rx =>

          if new_rx_in = '1' and new_rx_old_r = '0' then
            -- Rising edge = new transmission coming from the udp/ip.

            -- Store info. Ctrl-regs will handle these in addr translation.
            ip_out          <= source_ip_in;
            dest_port_out   <= dest_port_in;
            source_port_out <= source_port_in;
            rx_erroneous_r  <= rx_erroneous_in;

            -- Convert length in bytes to halfwords (rx_len_r <= rx_len_in/2 + rx_len_in%2)
            rx_len_r <= to_integer(unsigned(rx_len_in(tx_len_w_c-1 downto 1)))
                        + to_integer(unsigned(rx_len_in(0 downto 0)));

            -- We also have to have the length in bytes for the hibi transmitter
            rx_len_for_ht_r <= rx_len_in;

            -- Prevent reading until hibi transmitter ready (or we might
            -- accidentally overrun the current info, if this rx was really short
            -- and there was another following right after it)
            prevent_read_r  <= '1';
            rx_ctrl_state_r <= wait_address;

          end if;

          

        when wait_address =>
          -- Delay state, it takes a cycle for the ctrl regs to update addr status
          rx_ctrl_state_r <= check_address;

          

        when check_address =>
          -- The glue process between the multiclk and tx fifos makes sure
          -- that only one transfer is being sent to the hibi transmitter.
          -- New one can begin, when that process is idle again.
          
          if fifo_glue_state_r = idle then
            if rx_addr_valid_in = '1' and rx_erroneous_r = '0' then
              -- There is a receiver for this one, send it forward to the hibi
              -- transmitter
              if ready_for_tx_in = '1' then
                send_request_out     <= '1';
                activate_fifo_glue_r <= '1';
                prevent_read_r       <= '0';
                rx_len_out           <= rx_len_for_ht_r;
                rx_ctrl_state_r      <= wait_rx;
              end if;

            else
              -- No receiver or erroneous, so dump the whole transmission
              dump_rx_r       <= '1';
              prevent_read_r  <= '0';
              rx_ctrl_state_r <= wait_rx;
            end if;
          end if;
          
        when others => null;
      end case;
    end if;
  end process main;
end rtl;
