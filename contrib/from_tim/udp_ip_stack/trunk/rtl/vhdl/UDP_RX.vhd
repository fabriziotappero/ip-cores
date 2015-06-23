----------------------------------------------------------------------------------
-- Company: 
-- Engineer:            Peter Fall
-- 
-- Create Date:    5 June 2011 
-- Design Name: 
-- Module Name:    UDP_RX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--              handle simple UDP RX
--              doesnt check the checsum
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - Improved error handling
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.axi.all;
use work.ipv4_types.all;

entity UDP_RX is
  port (
    -- UDP Layer signals
    udp_rx_start : out std_logic;       -- indicates receipt of udp header
    udp_rxo      : out udp_rx_type;
    -- system signals
    clk          : in  std_logic;
    reset        : in  std_logic;
    -- IP layer RX signals
    ip_rx_start  : in  std_logic;       -- indicates receipt of ip header
    ip_rx        : in  ipv4_rx_type
    );                  
end UDP_RX;

architecture Behavioral of UDP_RX is

  type rx_state_type is (IDLE, UDP_HDR, USER_DATA, WAIT_END, ERR);

  type rx_event_type is (NO_EVENT, DATA);
  type count_mode_type is (RST, INCR, HOLD);
  type settable_count_mode_type is (RST, INCR, SET_VAL, HOLD);
  type set_clr_type is (SET, CLR, HOLD);


  -- state variables
  signal rx_state         : rx_state_type;
  signal rx_count         : unsigned (15 downto 0);
  signal src_port         : std_logic_vector (15 downto 0);  -- src port captured from input
  signal dst_port         : std_logic_vector (15 downto 0);  -- dst port captured from input
  signal data_len         : std_logic_vector (15 downto 0);  -- user data length captured from input
  signal udp_rx_start_reg : std_logic;  -- indicates start of user data
  signal hdr_valid_reg    : std_logic;  -- indicates that hdr data is valid
  signal src_ip_addr      : std_logic_vector (31 downto 0);  -- captured from IP hdr

  -- rx control signals
  signal next_rx_state    : rx_state_type;
  signal set_rx_state     : std_logic;
  signal rx_event         : rx_event_type;
  signal rx_count_mode    : settable_count_mode_type;
  signal rx_count_val     : unsigned (15 downto 0);
  signal set_sph          : std_logic;
  signal set_spl          : std_logic;
  signal set_dph          : std_logic;
  signal set_dpl          : std_logic;
  signal set_len_H        : std_logic;
  signal set_len_L        : std_logic;
  signal set_udp_rx_start : set_clr_type;
  signal set_hdr_valid    : set_clr_type;
  signal dataval          : std_logic_vector (7 downto 0);
  signal set_pkt_cnt      : count_mode_type;
  signal set_src_ip       : std_logic;
  signal set_data_last    : std_logic;

-- IP datagram header format
--
--      0          4          8                      16      19             24                    31
--      --------------------------------------------------------------------------------------------
--      |              source port number            |              dest port number               |
--      |                                            |                                             |
--      --------------------------------------------------------------------------------------------
--      |                length (bytes)              |                checksum                     |
--      |          (header and data combined)        |                                             |
--      --------------------------------------------------------------------------------------------
--      |                                          Data                                            |
--      |                                                                                          |
--      --------------------------------------------------------------------------------------------
--      |                                          ....                                            |
--      |                                                                                          |
--      --------------------------------------------------------------------------------------------


begin

  -----------------------------------------------------------------------
  -- combinatorial process to implement FSM and determine control signals
  -----------------------------------------------------------------------

  rx_combinatorial : process (
    -- input signals
    ip_rx, ip_rx_start,
    -- state variables
    rx_state, rx_count, src_port, dst_port, data_len, udp_rx_start_reg, hdr_valid_reg, src_ip_addr,
    -- control signals
    next_rx_state, set_rx_state, rx_event, rx_count_mode, rx_count_val,
    set_sph, set_spl, set_dph, set_dpl, set_len_H, set_len_L, set_data_last,
    set_udp_rx_start, set_hdr_valid, dataval, set_pkt_cnt, set_src_ip
    )
  begin
    -- set output followers
    udp_rx_start            <= udp_rx_start_reg;
    udp_rxo.hdr.is_valid    <= hdr_valid_reg;
    udp_rxo.hdr.data_length <= data_len;
    udp_rxo.hdr.src_port    <= src_port;
    udp_rxo.hdr.dst_port    <= dst_port;
    udp_rxo.hdr.src_ip_addr <= src_ip_addr;

    -- transfer data upstream if in user data phase
    if rx_state = USER_DATA then
      udp_rxo.data.data_in       <= ip_rx.data.data_in;
      udp_rxo.data.data_in_valid <= ip_rx.data.data_in_valid;
      udp_rxo.data.data_in_last  <= set_data_last;
    else
      udp_rxo.data.data_in       <= (others => '0');
      udp_rxo.data.data_in_valid <= '0';
      udp_rxo.data.data_in_last  <= '0';
    end if;

    -- set signal defaults
    next_rx_state    <= IDLE;
    set_rx_state     <= '0';
    rx_event         <= NO_EVENT;
    rx_count_mode    <= HOLD;
    set_sph          <= '0';
    set_spl          <= '0';
    set_dph          <= '0';
    set_dpl          <= '0';
    set_len_H        <= '0';
    set_len_L        <= '0';
    set_udp_rx_start <= HOLD;
    set_hdr_valid    <= HOLD;
    dataval          <= (others => '0');
    set_src_ip       <= '0';
    rx_count_val     <= (others => '0');
    set_data_last    <= '0';

    -- determine event (if any)
    if ip_rx.data.data_in_valid = '1' then
      rx_event <= DATA;
      dataval  <= ip_rx.data.data_in;
    end if;

    -- RX FSM
    case rx_state is
      when IDLE =>
        rx_count_mode <= RST;
        case rx_event is
          when NO_EVENT =>              -- (nothing to do)
          when DATA =>
            if ip_rx.hdr.protocol = x"11" then
                                        -- UDP protocol
              rx_count_mode <= INCR;
              set_hdr_valid <= CLR;
              set_src_ip    <= '1';
              set_sph       <= '1';
              next_rx_state <= UDP_HDR;
              set_rx_state  <= '1';
            else
                                        -- non-UDP protocol - ignore this pkt
              set_hdr_valid <= CLR;
              next_rx_state <= WAIT_END;
              set_rx_state  <= '1';
            end if;
        end case;

      when UDP_HDR =>
        case rx_event is
          when NO_EVENT =>              -- (nothing to do)
          when DATA =>
            if rx_count = x"0007" then
              rx_count_mode <= SET_VAL;
              rx_count_val  <= x"0001";
              next_rx_state <= USER_DATA;
              set_rx_state  <= '1';
            else
              rx_count_mode <= INCR;
            end if;
                                        -- handle early frame termination
            if ip_rx.data.data_in_last = '1' then
              next_rx_state <= ERR;
              set_rx_state  <= '1';
            else
              case rx_count is
                when x"0000" => set_sph <= '1';
                when x"0001" => set_spl <= '1';
                when x"0002" => set_dph <= '1';
                when x"0003" => set_dpl <= '1';

                when x"0004" => set_len_H <= '1';
                when x"0005" => set_len_L <= '1'; set_hdr_valid <= SET;  -- header values are now valid, although the pkt may not be for us

                when x"0006" =>                           -- ignore checksum values
                when x"0007" => set_udp_rx_start <= SET;  -- indicate frame received


                when others =>  -- ignore other bytes in udp header                                                                              
              end case;
            end if;
        end case;
        
      when USER_DATA =>
        case rx_event is
          when NO_EVENT =>              -- (nothing to do)
          when DATA =>
                                        -- note: data gets transfered upstream as part of "output followers" processing
            if rx_count = unsigned(data_len) then
              set_udp_rx_start <= CLR;
              rx_count_mode    <= RST;
              set_data_last    <= '1';
              if ip_rx.data.data_in_last = '1' then
                next_rx_state    <= IDLE;
                set_udp_rx_start <= CLR;
              else
                next_rx_state <= WAIT_END;
              end if;
              set_rx_state <= '1';
            else
              rx_count_mode <= INCR;
                                        -- check for early frame termination
                                        -- TODO need to mark frame as errored
              if ip_rx.data.data_in_last = '1' then
                next_rx_state <= IDLE;
                set_rx_state  <= '1';
                set_data_last <= '1';
              end if;
            end if;
        end case;

      when ERR =>
        if ip_rx.data.data_in_last = '0' then
          next_rx_state <= WAIT_END;
          set_rx_state  <= '1';
        else
          next_rx_state <= IDLE;
          set_rx_state  <= '1';
        end if;
        

      when WAIT_END =>
        case rx_event is
          when NO_EVENT =>              -- (nothing to do)
          when DATA =>
            if ip_rx.data.data_in_last = '1' then
              next_rx_state <= IDLE;
              set_rx_state  <= '1';
            end if;
        end case;
        
    end case;
    
  end process;


  -----------------------------------------------------------------------------
  -- sequential process to action control signals and change states and outputs
  -----------------------------------------------------------------------------

  rx_sequential : process (clk, reset)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        -- reset state variables
        rx_state         <= IDLE;
        rx_count         <= x"0000";
        src_port         <= (others => '0');
        dst_port         <= (others => '0');
        data_len         <= (others => '0');
        udp_rx_start_reg <= '0';
        hdr_valid_reg    <= '0';
        src_ip_addr      <= (others => '0');
      else
        -- Next rx_state processing
        if set_rx_state = '1' then
          rx_state <= next_rx_state;
        else
          rx_state <= rx_state;
        end if;

        -- rx_count processing
        case rx_count_mode is
          when RST     => rx_count <= x"0000";
          when INCR    => rx_count <= rx_count + 1;
          when SET_VAL => rx_count <= rx_count_val;
          when HOLD    => rx_count <= rx_count;
        end case;

        -- port number capture
        if (set_sph = '1') then src_port(15 downto 8) <= dataval; end if;
        if (set_spl = '1') then src_port(7 downto 0)  <= dataval; end if;
        if (set_dph = '1') then dst_port(15 downto 8) <= dataval; end if;
        if (set_dpl = '1') then dst_port(7 downto 0)  <= dataval; end if;

        if (set_len_H = '1') then
          data_len (15 downto 8) <= dataval;
          data_len (7 downto 0)  <= x"00";
        elsif (set_len_L = '1') then
                                        -- compute data length, taking into account that we need to subtract the header length
          data_len <= std_logic_vector(unsigned(data_len(15 downto 8) & dataval) - 8);
        else
          data_len <= data_len;
        end if;

        case set_udp_rx_start is
          when SET  => udp_rx_start_reg <= '1';
          when CLR  => udp_rx_start_reg <= '0';
          when HOLD => udp_rx_start_reg <= udp_rx_start_reg;
        end case;

        -- capture src IP address
        if set_src_ip = '1' then
          src_ip_addr <= ip_rx.hdr.src_ip_addr;
        else
          src_ip_addr <= src_ip_addr;
        end if;

        case set_hdr_valid is
          when SET  => hdr_valid_reg <= '1';
          when CLR  => hdr_valid_reg <= '0';
          when HOLD => hdr_valid_reg <= hdr_valid_reg;
        end case;
        
      end if;
    end if;
  end process;

end Behavioral;

