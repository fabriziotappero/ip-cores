-------------------------------------------------------------------------------
-- Title      : DM9kA controller, read module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DM9kA_read_module.vhd
-- Author     : Jussi Nieminen
-- Company    : TUT
-- Last update: 2012-04-04
-------------------------------------------------------------------------------
-- Description: Handles the reading of rx data DM9kA -> application
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/09/02  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.DM9kA_ctrl_pkg.all;


entity DM9kA_read_module is

  port (
    clk                     : in  std_logic;
    rst_n                   : in  std_logic;
    -- from interrupt handler
    rx_waiting_in           : in  std_logic;

    -- from/to comm module
    rx_data_in              : in  std_logic_vector(data_width_c-1 downto 0);
    rx_data_valid_in        : in  std_logic;
    rx_re_out               : out std_logic;
    reg_addr_out            : out std_logic_vector(7 downto 0);
    config_data_out         : out std_logic_vector(7 downto 0);
    read_not_write_out      : out std_logic;
    config_valid_out        : out std_logic;
    data_from_comm_in       : in  std_logic_vector(data_width_c-1 downto 0);
    data_from_comm_valid_in : in  std_logic;
    comm_busy_in            : in  std_logic;
    comm_req_out            : out std_logic;
    comm_grant_in           : in  std_logic;

    -- from/to upper level
    rx_data_out             : out std_logic_vector(data_width_c-1 downto 0);
    rx_data_valid_out       : out std_logic;
    rx_re_in                : in  std_logic;
    new_rx_out              : out std_logic;
    rx_len_out              : out std_logic_vector(tx_len_w_c-1 downto 0);
    frame_type_out          : out std_logic_vector(15 downto 0);
    rx_erroneous_out        : out std_logic;
    fatal_error_out         : out std_logic  -- worse than some network error
    );

end DM9kA_read_module;


architecture rtl of DM9kA_read_module is

  type read_state_type is (wait_rx, peek_first_byte, delay, prepare_comm,
                           check_first_byte, check_status, get_length,
                           strip_header, relay_data, strip_checksum1,
                           strip_checksum2, check_next, clear_interrupt, fatal_error);
  signal state_r : read_state_type;

  signal comm_req_r  : std_logic;
  signal rx_re_r     : std_logic;
  signal rx_status_r : std_logic_vector(7 downto 0);

  signal rx_len_r          : integer range 0 to 2**tx_len_w_c-1;
  signal delay_done_r      : std_logic;
  signal header_cnt_r      : integer range 0 to 6;
  signal clear_interrupt_r : std_logic;

-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  --
  -- Combinatorial process
  --
  mux : process (rx_data_in, rx_data_valid_in, rx_re_in, rx_re_r, state_r)
  begin  -- process mux

    if state_r = relay_data then
      
      rx_data_out       <= rx_data_in;
      rx_data_valid_out <= rx_data_valid_in;
      rx_re_out         <= rx_re_in;

    else
      rx_data_out       <= (others => '0');
      rx_data_valid_out <= '0';
      rx_re_out         <= rx_re_r;
      
    end if;
  end process mux;

  comm_req_out <= comm_req_r;


  --
  -- Sequential process for state machine
  --
  main : process (clk, rst_n)

    variable rx_len_v : integer range 0 to 2**tx_len_w_c-1;
    
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      state_r           <= wait_rx;
      comm_req_r        <= '0';
      rx_status_r       <= (others => '0');
      rx_len_r          <= 0;
      clear_interrupt_r <= '0';

      reg_addr_out       <= (others => '0');
      config_data_out    <= (others => '0');
      config_valid_out   <= '0';
      read_not_write_out <= '0';
      rx_re_r            <= '0';
      rx_len_out         <= (others => '0');
      new_rx_out         <= '0';
      rx_erroneous_out   <= '0';
      fatal_error_out    <= '0';
      frame_type_out     <= (others => '0');
      header_cnt_r       <= 0;


    elsif clk'event and clk = '1' then  -- rising clock edge

      case state_r is
        
        when wait_rx =>

          rx_erroneous_out <= '0';

          -- notification from int handler
          if rx_waiting_in = '1' then
            -- ask for a turn
            comm_req_r <= '1';
          end if;

          if comm_req_r = '1' and comm_grant_in = '1' then
            -- our turn
            state_r <= peek_first_byte;
          end if;


        when peek_first_byte =>

          -- this is just a dummy read, returned value is rubbish for some
          -- reason... 
          reg_addr_out       <= rx_peek_reg_c;
          read_not_write_out <= '1';
          config_valid_out   <= '1';

          if comm_busy_in = '1' then
            config_valid_out <= '0';
            if data_from_comm_valid_in = '1' then
              state_r <= delay;
            end if;
          end if;


        when delay =>

          -- the chip needs a bit time after reading from rx_peek_reg_c
          if delay_done_r = '1' then
            delay_done_r <= '0';
            if clear_interrupt_r = '1' then
              state_r <= clear_interrupt;
            else
              state_r <= prepare_comm;
            end if;
          else
            delay_done_r <= '1';
          end if;


        when clear_interrupt =>

          -- Clearing interrupt flag. This is done only if we have already
          -- received one transmission, and find out that there is another when
          -- in check_next state.
          reg_addr_out       <= ISR_c;
          read_not_write_out <= '0';
          config_valid_out   <= '1';
          -- rx received interrupt flag (index 0) is cleared by writing 1 to it
          config_data_out    <= (0 => '1', others => '0');

          if comm_busy_in = '1' then
            config_valid_out  <= '0';
            clear_interrupt_r <= '0';
          end if;

          if comm_busy_in = '0' and clear_interrupt_r = '0' then
            state_r <= prepare_comm;
          end if;
          
          
        when prepare_comm =>

          -- set rx_data_reg
          reg_addr_out       <= rx_data_reg_c;
          read_not_write_out <= '1';
          config_valid_out   <= '1';

          if comm_busy_in = '1' then
            state_r <= check_first_byte;
          end if;


        when check_first_byte =>

          -- the first byte must be either x"01" (rx really waiting) or
          -- x"00" (no rx waiting). Any other value means that something
          -- has gone terribly wrong. This state should only be entered when
          -- there is something to read (after rx interrupt or when there is
          -- two or more rx:s waiting), so also the x"00" value is invalid.
          
          if rx_data_valid_in = '1' then
            rx_re_r <= '1';
          end if;

          if rx_data_valid_in = '1' and rx_re_r = '1' then
            rx_re_r <= '0';

            -- status is the upper byte
            rx_status_r <= rx_data_in(data_width_c-1 downto 8);

            -- the first byte:
            if rx_data_in(7 downto 0) = x"01" then
              -- everything's ok
              state_r <= check_status;
            else
              -- nothing's ok
              state_r <= fatal_error;
            end if;
          end if;


        when check_status =>

          -- if there's non-zero bits, (excluding the multicast frame bit)
          -- something has gone wrong.
          if (rx_status_r and "10111111") /= x"00" then
            rx_erroneous_out <= '1';
          end if;

          state_r <= get_length;


        when get_length =>

          if rx_data_valid_in = '1' then
            rx_re_r <= '1';
          end if;

          if rx_data_valid_in = '1' and rx_re_r = '1' then
            rx_re_r <= '0';

            -- rx length doesn't include the header nor the checksum
            rx_len_v   := to_integer(unsigned(rx_data_in)) - eth_header_len_c - eth_checksum_len_c;
            rx_len_r   <= rx_len_v;
            rx_len_out <= std_logic_vector(to_unsigned(rx_len_v, tx_len_w_c));
            state_r    <= strip_header;
          end if;


        when strip_header =>
          -- the data contains MAC addresses and frame type, so we must
          -- get those before relaying the data.

          if rx_data_valid_in = '1' then
            rx_re_r <= '1';
          end if;

          if rx_data_valid_in = '1' and rx_re_r = '1' then
            rx_re_r <= '0';

            if header_cnt_r = 6 then
              -- write out the frame type
              frame_type_out(15 downto 8) <= rx_data_in(7 downto 0);
              frame_type_out(7 downto 0)  <= rx_data_in(15 downto 8);
              new_rx_out                  <= '1';
              state_r                     <= relay_data;
              header_cnt_r                <= 0;
            else
              -- do nothing with the MAC addresses
              header_cnt_r <= header_cnt_r + 1;
            end if;
            
          end if;
          
          

        when relay_data =>

          if rx_re_in = '1' and rx_data_valid_in = '1' then
            new_rx_out <= '0';

            -- upper level reads two bytes
            if rx_len_r <= 2 then
              -- those are the last two
              rx_len_r <= 0;
              state_r  <= strip_checksum1;
            else
              rx_len_r <= rx_len_r - 2;
            end if;
          end if;


        when strip_checksum1 =>

          if rx_data_valid_in = '1' then
            rx_re_r <= '1';
          end if;

          if rx_data_valid_in = '1' and rx_re_r = '1' then
            rx_re_r <= '0';
            state_r <= strip_checksum2;
          end if;

          
        when strip_checksum2 =>

          if rx_data_valid_in = '1' then
            -- config_valid_out must drop early enough to prevent unwanted reading
            config_valid_out <= '0';
            rx_re_r          <= '1';
          end if;

          if rx_data_valid_in = '1' and rx_re_r = '1' then
            rx_re_r <= '0';
            state_r <= check_next;
          end if;
          

        when check_next =>


          -- make sure that there's no other rx:s waiting
          reg_addr_out       <= rx_peek_reg_c;
          read_not_write_out <= '1';
          config_valid_out   <= '1';

          if comm_busy_in = '1' then
            config_valid_out <= '0';

            if data_from_comm_valid_in = '1' then

              if data_from_comm_in(7 downto 0) = x"01" then
                -- there really is a new rx coming, so we must clear the
                -- interrupt (so that we don't get an invalid rx_waiting signal
                -- afterwards)
                state_r           <= delay;
                clear_interrupt_r <= '1';
              elsif data_from_comm_in(7 downto 0) = x"00" then
                -- nothing incoming
                state_r    <= wait_rx;
                comm_req_r <= '0';
              else
                state_r <= fatal_error;
              end if;
            end if;
          end if;
          

        when fatal_error =>
          fatal_error_out <= '1';
        when others => null;
      end case;

    end if;
  end process main;

end rtl;
