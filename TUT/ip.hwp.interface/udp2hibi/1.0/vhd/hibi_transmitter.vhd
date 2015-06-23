-------------------------------------------------------------------------------
-- Title      : Hibi transmitter
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : hibi_transmitter.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-03-23
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Takes care of transmitting packets via HIBI.
--              Gets data from rx ctrl (which gets them from udp/ip).
--              Checks parameters fromc ctrl-registers and gives data to hibi
--              transmitter.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/21  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.udp2hibi_pkg.all;


entity hibi_transmitter is

  generic (
    hibi_data_width_g : integer := 32;
    hibi_addr_width_g : integer := 32;
    hibi_comm_width_g : integer := 5;
    ack_fifo_depth_g  : integer := 5
    );

  port (
    clk              : in  std_logic;
    rst_n            : in  std_logic;

    -- to/from HIBI
    hibi_comm_out    : out std_logic_vector( hibi_comm_width_g-1 downto 0 );
    hibi_data_out    : out std_logic_vector( hibi_data_width_g-1 downto 0 );
    hibi_av_out      : out std_logic;
    hibi_we_out      : out std_logic;
    hibi_full_in     : in  std_logic;

    -- from/to rx_ctrl
    send_request_in  : in  std_logic;
    rx_len_in        : in  std_logic_vector( tx_len_w_c-1 downto 0 );
    ready_for_tx_out : out std_logic;
    rx_empty_in      : in  std_logic;
    rx_data_in       : in  std_logic_vector( hibi_data_width_g-1 downto 0 );
    rx_re_out        : out std_logic;

    -- from ctrl_regs
    rx_addr_in       : in  std_logic_vector( hibi_addr_width_g-1 downto 0 );
    ack_addr_in      : in  std_logic_vector( hibi_addr_width_g-1 downto 0 );
    send_tx_ack_in   : in  std_logic;
    send_tx_nack_in  : in  std_logic;
    send_rx_ack_in   : in  std_logic;
    send_rx_nack_in  : in  std_logic
    );

end hibi_transmitter;


architecture rtl of hibi_transmitter is

  -- FSM
  type state_type is (normal, send_ack_addr, send_ack, send_data_addr, send_rx_header);
  signal state_r : state_type;

  signal data_from_rx_ctrl : std_logic_vector(hibi_data_width_g-1 downto 0);  -- obsolete?
  signal re_to_rx_ctrl     : std_logic;  -- obsolete?
  
  signal re_we_r           : std_logic;
  signal target_addr_r     : std_logic_vector(hibi_addr_width_g-1 downto 0);


  -- fifo is used to store ack requests
  -- ** WARNING! **
  -- The fifo is not infinite (really?), so if some agent decides to send e.g.
  -- 100 tx conf packets in a row, the fifo will simply discard ack/nack
  -- requests that don't fit in.
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

  signal requests_to_ack_fifo  : std_logic_vector(3 downto 0);
  signal data_to_ack_fifo      : std_logic_vector(hibi_addr_width_g+4-1 downto 0);
  signal we_to_ack_fifo        : std_logic;
  signal ack_fifo_re_r         : std_logic;
  signal data_from_ack_fifo    : std_logic_vector(hibi_addr_width_g+4-1 downto 0);
  signal ack_data              : std_logic_vector(3 downto 0);
  signal ack_addr              : std_logic_vector(hibi_addr_width_g-1 downto 0);
  signal empty_from_ack_fifo   : std_logic;
  signal which_ack_r           : std_logic_vector(3 downto 0);
  signal target_addr_valid_r   : std_logic;
  signal connect_data_in_out_r : std_logic;

  -- Registers for HIBI
  signal hibi_data_r           : std_logic_vector(hibi_data_width_g-1 downto 0);
  signal hibi_we_r             : std_logic;
  signal new_rx_r              : std_logic;
  signal rx_len_r              : std_logic_vector(tx_len_w_c-1 downto 0);

  constant hibi_data_comm_c : std_logic_vector( hibi_comm_width_g-1 downto 0 ) := "00010"; --
  -- command 2 = write
  
-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  hibi_comm_out <= hibi_data_comm_c;

  
  requests_to_ack_fifo <= send_tx_ack_in & send_tx_nack_in &
                          send_rx_ack_in & send_rx_nack_in;

  data_to_ack_fifo <= requests_to_ack_fifo & ack_addr_in;
  we_to_ack_fifo   <= send_tx_ack_in or send_tx_nack_in or send_rx_ack_in or send_rx_nack_in;
  
  ack_fifo: fifo
    generic map (
        data_width_g => hibi_addr_width_g+4,
        depth_g      => ack_fifo_depth_g
        )
    port map (
        clk       => clk,
        rst_n     => rst_n,

        data_in   => data_to_ack_fifo,
        we_in     => we_to_ack_fifo,
        full_out  => open,
        one_p_out => open,

        re_in     => ack_fifo_re_r,
        data_out  => data_from_ack_fifo,
        empty_out => empty_from_ack_fifo,
        one_d_out => open
        );

  ack_data <= data_from_ack_fifo( hibi_addr_width_g+4-1 downto hibi_addr_width_g );
  ack_addr <= data_from_ack_fifo( hibi_addr_width_g-1 downto 0 );


  -----------------------------------------------------------------------------
  -- switch output between hibi_data_r and rx_data_in
  -----------------------------------------------------------------------------
  output_mux: process (connect_data_in_out_r, rx_data_in, hibi_data_r,
                       re_we_r, rx_empty_in, hibi_we_r)
  begin  -- process output_mux
    if connect_data_in_out_r = '1' then
      hibi_data_out <= rx_data_in;
      hibi_we_out   <= re_we_r and (not rx_empty_in);
    else
      hibi_data_out <= hibi_data_r;
      hibi_we_out   <= hibi_we_r;
    end if;
  end process output_mux;

  rx_re_out <= re_we_r and (not hibi_full_in);



  -----------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------
  main: process (clk, rst_n)
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      state_r       <= normal;
      ack_fifo_re_r <= '0';
      re_we_r       <= '0';
      target_addr_r <= (others => '0');
      which_ack_r   <= (others => '0');

      target_addr_valid_r   <= '0';
      connect_data_in_out_r <= '0';

      hibi_we_r   <= '0';
      hibi_data_r <= (others => '0');
      new_rx_r    <= '0';
      rx_len_r    <= (others => '0');

      hibi_av_out      <= '0';
      ready_for_tx_out <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- default values
      ready_for_tx_out <= '0';
      ack_fifo_re_r    <= '0';
      hibi_we_r        <= '0';
      hibi_av_out      <= '0';
      re_we_r          <= '0';
      connect_data_in_out_r <= '0';


      -- state machine
      case state_r is

        -----------------------------------------------------------------------
        when normal =>
          -- normal state means that we are either idle or in the middle of
          -- sending data. We don't have to know which case it is, we just
          -- send all the data we get to the address stored in target_addr_r.
          -- We are ready for new transfers when we are in this state and both,
          -- tx_fifo and ack fifo are empty.

          if rx_empty_in = '1' and empty_from_ack_fifo = '1' and send_request_in = '0' then
            ready_for_tx_out <= '1';
          end if;

          -- if rx_ctrl requests a new transmission
          if send_request_in = '1' then
            target_addr_r <= rx_addr_in;
            state_r       <= send_data_addr;
            rx_len_r      <= rx_len_in;
            new_rx_r      <= '1';

            hibi_av_out <= '1';
            hibi_we_r   <= '1';
            hibi_data_r <= rx_addr_in;

          -- else if there is new (n)ack to be sent
          elsif empty_from_ack_fifo = '0' then
            which_ack_r   <= ack_data;
            ack_fifo_re_r <= '1';
            -- target address for data is no longer in hibi wrapper's register
            target_addr_valid_r <= '0';
          
            hibi_av_out <= '1';
            hibi_data_r <= ack_addr;
            hibi_we_r   <= '1';
            state_r     <= send_ack_addr;
            
          -- else if there is data to be sent and room where to send it
          elsif rx_empty_in = '0' and hibi_full_in = '0' then

            -- if we have sent an ack/nack in the middle of the transfer, we
            -- have to resend the target address
            if target_addr_valid_r = '0' then
              hibi_av_out <= '1';
              hibi_we_r   <= '1';
              hibi_data_r <= target_addr_r;
              state_r <= send_data_addr;
            else
              -- address is valid, just keep on sending data
              re_we_r <= '1';
              connect_data_in_out_r <= '1';
            end if;
          end if;

          
        -----------------------------------------------------------------------
        when send_ack_addr =>

          hibi_we_r <= '1';
          
          if hibi_full_in = '0' then

            if which_ack_r(3) = '1' or which_ack_r(1) = '1' then
              -- it's an ack
              hibi_data_r( id_hi_idx_c downto id_lo_idx_c ) <= ack_header_id_c;
            else
              -- a nack
              hibi_data_r( id_hi_idx_c downto id_lo_idx_c ) <= nack_header_id_c;
            end if;
            if which_ack_r(3) = '1' or which_ack_r(2) = '1' then
              -- it's tx (n)ack
              hibi_data_r( id_lo_idx_c-1 ) <= '1';
            else
              -- rx (n)ack
              hibi_data_r( id_lo_idx_c-1 ) <= '0';
            end if;

            hibi_data_r( id_lo_idx_c-2 downto 0 ) <= (others => '0');
            
            state_r <= send_ack;

          else
            hibi_av_out <= '1';
          end if;

        -----------------------------------------------------------------------
        when send_ack =>
          -- ack is currently being sent. Decide what to do next.

          if hibi_full_in = '0' then
            if empty_from_ack_fifo = '1' and rx_empty_in = '1' then
              -- no more acks and no data, start waiting in normal state
              state_r <= normal;
              
            elsif empty_from_ack_fifo = '0' then
              -- another ack, send it
              which_ack_r   <= ack_data;
              ack_fifo_re_r <= '1';
              
              hibi_av_out <= '1';
              hibi_data_r <= ack_addr;
              hibi_we_r   <= '1';
              state_r     <= send_ack_addr;
              
            else
              -- there's data to be sent, resend the address
              hibi_av_out <= '1';
              hibi_we_r   <= '1';
              hibi_data_r <= target_addr_r;
              state_r <= send_data_addr;
            end if;
          else
            hibi_we_r <= '1';
          end if;


        -----------------------------------------------------------------------
        when send_data_addr =>
          -- send receiver address, and after that either send a new rx header
          -- or continue the old rx

          if hibi_full_in = '0' then
            if new_rx_r = '1' then
              -- new rx, send header
              hibi_we_r                                                <= '1';
              hibi_data_r                                              <= (others => '0');
              hibi_data_r(id_hi_idx_c downto id_lo_idx_c)              <= rx_data_header_id_c;
              hibi_data_r(id_lo_idx_c-1 downto id_lo_idx_c-tx_len_w_c) <= rx_len_r;
              state_r                                                  <= send_rx_header;
              new_rx_r                                                 <= '0';
              
            else
              state_r <= normal;
              -- if possible, start sending
              if rx_empty_in = '0' and hibi_full_in = '0' then
                re_we_r <= '1';
                connect_data_in_out_r <= '1';
              end if;
            end if;
            
            target_addr_valid_r <= '1';
          else
            hibi_av_out <= '1';
            hibi_we_r   <= '1';
          end if;


        -----------------------------------------------------------------------
        when send_rx_header =>
          -- new rx starting, send the header

          if hibi_full_in = '0' then
            state_r <= normal;
            -- if possible, start sending
            if rx_empty_in = '0' and hibi_full_in = '0' then
              re_we_r <= '1';
              connect_data_in_out_r <= '1';
            end if;
          else
            hibi_we_r <= '1';
          end if;

          
        when others => null;
      end case;

      
    end if;
  end process main;
  
  

end rtl;
