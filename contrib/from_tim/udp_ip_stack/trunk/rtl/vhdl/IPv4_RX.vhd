----------------------------------------------------------------------------------
-- Company: 
-- Engineer:            Peter Fall
-- 
-- Create Date:    16:20:42 06/01/2011 
-- Design Name: 
-- Module Name:    IPv4_RX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--              handle simple IP RX
--              doesnt handle reassembly
--              checks and filters for IP protocol
--              checks and filters for IP addr
--              Handle IPv4 protocol
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - Improved error handling
-- Revision 0.03 - Added handling of broadcast address
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;

entity IPv4_RX is
  port (
    -- IP Layer signals
    ip_rx             : out ipv4_rx_type;
    ip_rx_start       : out std_logic;  -- indicates receipt of ip frame.
    -- system signals
    clk               : in  std_logic;  -- same clock used to clock mac data and ip data
    reset             : in  std_logic;
    our_ip_address    : in  std_logic_vector (31 downto 0);
    rx_pkt_count      : out std_logic_vector(7 downto 0);   -- number of IP pkts received for us
    -- MAC layer RX signals
    mac_data_in       : in  std_logic_vector (7 downto 0);  -- ethernet frame (from dst mac addr through to last byte of frame)
    mac_data_in_valid : in  std_logic;  -- indicates data_in valid on clock
    mac_data_in_last  : in  std_logic   -- indicates last data in frame
    );                  
end IPv4_RX;

architecture Behavioral of IPv4_RX is

  type rx_state_type is (IDLE, ETH_HDR, IP_HDR, USER_DATA, WAIT_END, ERR);

  type rx_event_type is (NO_EVENT, DATA);
  type count_mode_type is (RST, INCR, HOLD);
  type settable_count_mode_type is (RST, INCR, SET_VAL, HOLD);
  type set_clr_type is (SET, CLR, HOLD);


  -- state variables
  signal rx_state         : rx_state_type;
  signal rx_count         : unsigned (15 downto 0);
  signal src_ip           : std_logic_vector (31 downto 0);  -- src IP captured from input
  signal dst_ip           : std_logic_vector (23 downto 0);  -- 1st 3 bytes of dst IP captured from input
  signal is_broadcast_reg : std_logic;
  signal protocol         : std_logic_vector (7 downto 0);   -- src protocol captured from input
  signal data_len         : std_logic_vector (15 downto 0);  -- src data length captured from input
  signal ip_rx_start_reg  : std_logic;  -- indicates start of user data
  signal hdr_valid_reg    : std_logic;  -- indicates that hdr data is valid
  signal frame_err_cnt    : unsigned (7 downto 0);  -- number of frame errors
  signal error_code_reg   : std_logic_vector (3 downto 0);
  signal rx_pkt_counter   : unsigned (7 downto 0);  -- number of rx frames received for us

  -- rx control signals
  signal next_rx_state     : rx_state_type;
  signal set_rx_state      : std_logic;
  signal rx_event          : rx_event_type;
  signal rx_count_mode     : settable_count_mode_type;
  signal set_dst_ip3       : std_logic;
  signal set_dst_ip2       : std_logic;
  signal set_dst_ip1       : std_logic;
  signal set_ip3           : std_logic;
  signal set_ip2           : std_logic;
  signal set_ip1           : std_logic;
  signal set_ip0           : std_logic;
  signal set_protocol      : std_logic;
  signal set_len_H         : std_logic;
  signal set_len_L         : std_logic;
  signal set_ip_rx_start   : set_clr_type;
  signal set_hdr_valid     : set_clr_type;
  signal set_frame_err_cnt : count_mode_type;
  signal dataval           : std_logic_vector (7 downto 0);
  signal rx_count_val      : unsigned (15 downto 0);
  signal set_error_code    : std_logic;
  signal error_code_val    : std_logic_vector (3 downto 0);
  signal set_pkt_cnt       : count_mode_type;
  signal set_data_last     : std_logic;
  signal dst_ip_rx         : std_logic_vector (31 downto 0);
  signal set_is_broadcast  : set_clr_type;


-- IP datagram header format
--
--      0          4          8                      16      19             24                    31
--      --------------------------------------------------------------------------------------------
--      | Version  | *Header  |    Service Type      |        Total Length including header        |
--      |   (4)    |  Length  |     (ignored)        |                 (in bytes)                  |
--      --------------------------------------------------------------------------------------------
--      |           Identification                   | Flags |       Fragment Offset               |
--      |                                            |       |      (in 32 bit words)              |
--      --------------------------------------------------------------------------------------------
--      |    Time To Live     |       Protocol       |             Header Checksum                 |
--      |     (ignored)       |                      |                                             |
--      --------------------------------------------------------------------------------------------
--      |                                   Source IP Address                                      |
--      |                                                                                          |
--      --------------------------------------------------------------------------------------------
--      |                                 Destination IP Address                                   |
--      |                                                                                          |
--      --------------------------------------------------------------------------------------------
--      |                          Options (if any - ignored)               |       Padding        |
--      |                                                                   |      (if needed)     |
--      --------------------------------------------------------------------------------------------
--      |                                          Data                                            |
--      |                                                                                          |
--      --------------------------------------------------------------------------------------------
--      |                                          ....                                            |
--      |                                                                                          |
--      --------------------------------------------------------------------------------------------
--
-- * - in 32 bit words 
  
begin

  -----------------------------------------------------------------------
  -- combinatorial process to implement FSM and determine control signals
  -----------------------------------------------------------------------

  rx_combinatorial : process (
    -- input signals
    mac_data_in, mac_data_in_valid, mac_data_in_last, our_ip_address,
    -- state variables
    rx_state, rx_count, src_ip, dst_ip, protocol, data_len, ip_rx_start_reg, hdr_valid_reg,
    frame_err_cnt, error_code_reg, rx_pkt_counter, is_broadcast_reg,
    -- control signals
    next_rx_state, set_rx_state, rx_event, rx_count_mode,
    set_ip3, set_ip2, set_ip1, set_ip0, set_protocol, set_len_H, set_len_L,
    set_dst_ip3, set_dst_ip2, set_dst_ip1,
    set_ip_rx_start, set_hdr_valid, set_frame_err_cnt, dataval, rx_count_val,
    set_error_code, error_code_val, set_pkt_cnt, set_data_last, dst_ip_rx, set_is_broadcast
    )
  begin
    -- set output followers
    ip_rx_start                <= ip_rx_start_reg;
    ip_rx.hdr.is_valid         <= hdr_valid_reg;
    ip_rx.hdr.protocol         <= protocol;
    ip_rx.hdr.data_length      <= data_len;
    ip_rx.hdr.src_ip_addr      <= src_ip;
    ip_rx.hdr.num_frame_errors <= std_logic_vector(frame_err_cnt);
    ip_rx.hdr.last_error_code  <= error_code_reg;
    ip_rx.hdr.is_broadcast     <= is_broadcast_reg;
    rx_pkt_count               <= std_logic_vector(rx_pkt_counter);

    -- transfer data upstream if in user data phase
    if rx_state = USER_DATA then
      ip_rx.data.data_in       <= mac_data_in;
      ip_rx.data.data_in_valid <= mac_data_in_valid;
      ip_rx.data.data_in_last  <= set_data_last;
    else
      ip_rx.data.data_in       <= (others => '0');
      ip_rx.data.data_in_valid <= '0';
      ip_rx.data.data_in_last  <= '0';
    end if;

    -- set signal defaults
    next_rx_state     <= IDLE;
    set_rx_state      <= '0';
    rx_event          <= NO_EVENT;
    rx_count_mode     <= HOLD;
    set_ip3           <= '0';
    set_ip2           <= '0';
    set_ip1           <= '0';
    set_ip0           <= '0';
    set_dst_ip3       <= '0';
    set_dst_ip2       <= '0';
    set_dst_ip1       <= '0';
    set_protocol      <= '0';
    set_len_H         <= '0';
    set_len_L         <= '0';
    set_ip_rx_start   <= HOLD;
    set_hdr_valid     <= HOLD;
    set_frame_err_cnt <= HOLD;
    rx_count_val      <= x"0000";
    set_error_code    <= '0';
    error_code_val    <= RX_EC_NONE;
    set_pkt_cnt       <= HOLD;
    dataval           <= (others => '0');
    set_data_last     <= '0';
    dst_ip_rx         <= (others => '0');
    set_is_broadcast  <= HOLD;

    -- determine event (if any)
    if mac_data_in_valid = '1' then
      rx_event <= DATA;
      dataval  <= mac_data_in;
    end if;

    -- RX FSM
    case rx_state is
      when IDLE =>
        rx_count_mode <= RST;
        case rx_event is
          when NO_EVENT =>              -- (nothing to do)
          when DATA =>
            rx_count_mode <= INCR;
            set_hdr_valid <= CLR;
            next_rx_state <= ETH_HDR;
            set_rx_state  <= '1';
        end case;

      when ETH_HDR =>
        case rx_event is
          when NO_EVENT =>                      -- (nothing to do)
          when DATA =>
            if rx_count = x"000d" then
              rx_count_mode <= RST;
              next_rx_state <= IP_HDR;
              set_rx_state  <= '1';
            else
              rx_count_mode <= INCR;
            end if;
                                                -- handle early frame termination
            if mac_data_in_last = '1' then
              error_code_val    <= RX_EC_ET_ETH;
              set_error_code    <= '1';
              set_frame_err_cnt <= INCR;
              set_ip_rx_start   <= CLR;
              set_data_last     <= '1';
              next_rx_state     <= IDLE;
              set_rx_state      <= '1';
            else
              case rx_count is
                when x"000c" =>
                  if mac_data_in /= x"08" then  -- ignore pkts that are not type=IP
                    next_rx_state <= WAIT_END;
                    set_rx_state  <= '1';
                  end if;
                  
                when x"000d" =>
                  if mac_data_in /= x"00" then  -- ignore pkts that are not type=IP
                    next_rx_state <= WAIT_END;
                    set_rx_state  <= '1';
                  end if;
                  
                when others =>          -- ignore other bytes in eth header
              end case;
            end if;
        end case;

      when IP_HDR =>
        case rx_event is
          when NO_EVENT =>              -- (nothing to do)
          when DATA =>
            if rx_count = x"0013" then
              rx_count_val  <= x"0001";         -- start counter at 1
              rx_count_mode <= SET_VAL;
            else
              rx_count_mode <= INCR;
            end if;
                                        -- handle early frame termination
            if mac_data_in_last = '1' then
              error_code_val    <= RX_EC_ET_IP;
              set_error_code    <= '1';
              set_frame_err_cnt <= INCR;
              set_ip_rx_start   <= CLR;
              set_data_last     <= '1';
              next_rx_state     <= IDLE;
              set_rx_state      <= '1';
            else
              case rx_count is
                when x"0000" =>
                  if mac_data_in /= x"45" then  -- ignore pkts that are not v4 with 5 header words
                    next_rx_state <= WAIT_END;
                    set_rx_state  <= '1';
                  end if;
                  
                when x"0002" => set_len_H <= '1';
                when x"0003" => set_len_L <= '1';

                when x"0006" =>
                  if (mac_data_in(7) = '1') or (mac_data_in (4 downto 0) /= "00000") then
                                        -- ignore pkts that require reassembly (MF=1 or frag offst /= 0)
                    next_rx_state <= WAIT_END;
                    set_rx_state  <= '1';
                  end if;
                  
                when x"0007" =>
                  if mac_data_in /= x"00" then  -- ignore pkts that require reassembly (frag offst /= 0)
                    next_rx_state <= WAIT_END;
                    set_rx_state  <= '1';
                  end if;

                when x"0009" => set_protocol <= '1';

                when x"000c" => set_ip3 <= '1';
                when x"000d" => set_ip2 <= '1';
                when x"000e" => set_ip1 <= '1';
                when x"000f" => set_ip0 <= '1';

                when x"0010" => set_dst_ip3 <= '1';
                  if ((mac_data_in /= our_ip_address(31 downto 24)) and
                      (mac_data_in /= IP_BC_ADDR(31 downto 24)))then  -- ignore pkts that are not addressed to us
                    next_rx_state <= WAIT_END;
                    set_rx_state  <= '1';
                  end if;
                when x"0011" => set_dst_ip2 <= '1';
                  if ((mac_data_in /= our_ip_address(23 downto 16)) and
                      (mac_data_in /= IP_BC_ADDR(23 downto 16)))then  -- ignore pkts that are not addressed to us
                    next_rx_state <= WAIT_END;
                    set_rx_state  <= '1';
                  end if;
                when x"0012" => set_dst_ip1 <= '1';
                  if ((mac_data_in /= our_ip_address(15 downto 8)) and
                      (mac_data_in /= IP_BC_ADDR(15 downto 8)))then  -- ignore pkts that are not addressed to us
                    next_rx_state <= WAIT_END;
                    set_rx_state  <= '1';
                  end if;

                when x"0013" =>
                  if ((mac_data_in /= our_ip_address(7 downto 0)) and
                      (mac_data_in /= IP_BC_ADDR(7 downto 0)))then  -- ignore pkts that are not addressed to us
                    next_rx_state <= WAIT_END;
                    set_rx_state  <= '1';
                  else
                    next_rx_state   <= USER_DATA;
                    set_pkt_cnt     <= INCR;                         -- count another pkt
                    set_rx_state    <= '1';
                    set_ip_rx_start <= SET;
                  end if;

                                        -- now have the dst IP addr
                  dst_ip_rx <= dst_ip & mac_data_in;
                  if dst_ip_rx = IP_BC_ADDR then
                    set_is_broadcast <= SET;
                  else
                    set_is_broadcast <= CLR;
                  end if;
                  set_hdr_valid <= SET;  -- header values are now valid, although the pkt may not be for us                                                                      

                  --if dst_ip_rx = our_ip_address or dst_ip_rx = IP_BC_ADDR then
                  --  next_rx_state   <= USER_DATA;
                  --  set_pkt_cnt     <= INCR;  -- count another pkt received
                  --  set_rx_state    <= '1';
                  --  set_ip_rx_start <= SET;
                  --else
                  --  next_rx_state <= WAIT_END;
                  --  set_rx_state  <= '1';
                  --end if;
                  
                when others =>  -- ignore other bytes in ip header                                                                               
              end case;
            end if;
        end case;
        
      when USER_DATA =>
        case rx_event is
          when NO_EVENT =>              -- (nothing to do)
          when DATA =>
                                        -- note: data gets transfered upstream as part of "output followers" processing
            if rx_count = unsigned(data_len) then
              set_ip_rx_start <= CLR;
              rx_count_mode   <= RST;
              set_data_last   <= '1';
              if mac_data_in_last = '1' then
                next_rx_state   <= IDLE;
                set_ip_rx_start <= CLR;
              else
                next_rx_state <= WAIT_END;
              end if;
              set_rx_state <= '1';
            else
              rx_count_mode <= INCR;
                                        -- check for early frame termination
              if mac_data_in_last = '1' then
                error_code_val    <= RX_EC_ET_USER;
                set_error_code    <= '1';
                set_frame_err_cnt <= INCR;
                set_ip_rx_start   <= CLR;
                next_rx_state     <= IDLE;
                set_rx_state      <= '1';
              end if;
            end if;
        end case;

      when ERR =>
        set_frame_err_cnt <= INCR;
        set_ip_rx_start   <= CLR;
        if mac_data_in_last = '0' then
          set_data_last <= '1';
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
            if mac_data_in_last = '1' then
              set_data_last   <= '1';
              next_rx_state   <= IDLE;
              set_rx_state    <= '1';
              set_ip_rx_start <= CLR;
            end if;
        end case;
        
    end case;
    
  end process;


  -----------------------------------------------------------------------------
  -- sequential process to action control signals and change states and outputs
  -----------------------------------------------------------------------------

  rx_sequential : process (clk)--, reset)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        -- reset state variables
        rx_state         <= IDLE;
        rx_count         <= x"0000";
        src_ip           <= (others => '0');
        dst_ip           <= (others => '0');
        protocol         <= (others => '0');
        data_len         <= (others => '0');
        ip_rx_start_reg  <= '0';
        hdr_valid_reg    <= '0';
        is_broadcast_reg <= '0';
        frame_err_cnt    <= (others => '0');
        error_code_reg   <= RX_EC_NONE;
        rx_pkt_counter   <= x"00";

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

        -- frame error count processing
        case set_frame_err_cnt is
          when RST  => frame_err_cnt <= x"00";
          when INCR => frame_err_cnt <= frame_err_cnt + 1;
          when HOLD => frame_err_cnt <= frame_err_cnt;
        end case;

        -- ip pkt processing
        case set_pkt_cnt is
          when RST  => rx_pkt_counter <= x"00";
          when INCR => rx_pkt_counter <= rx_pkt_counter + 1;
          when HOLD => rx_pkt_counter <= rx_pkt_counter;
        end case;

        -- source ip capture
        if (set_ip3 = '1') then src_ip(31 downto 24) <= dataval; end if;
        if (set_ip2 = '1') then src_ip(23 downto 16) <= dataval; end if;
        if (set_ip1 = '1') then src_ip(15 downto 8)  <= dataval; end if;
        if (set_ip0 = '1') then src_ip(7 downto 0)   <= dataval; end if;

        -- dst ip capture
        if (set_dst_ip3 = '1') then dst_ip(23 downto 16) <= dataval; end if;
        if (set_dst_ip2 = '1') then dst_ip(15 downto 8)  <= dataval; end if;
        if (set_dst_ip1 = '1') then dst_ip(7 downto 0)   <= dataval; end if;

        if (set_protocol = '1') then
          protocol <= dataval;
        else
          protocol <= protocol;
        end if;

        if (set_len_H = '1') then
          data_len (15 downto 8) <= dataval;
          data_len (7 downto 0)  <= x"00";
        elsif (set_len_L = '1') then
                                        -- compute data length, taking into account that we need to subtract the header length
          data_len <= std_logic_vector(unsigned(data_len(15 downto 8) & dataval) - 20);
        else
          data_len <= data_len;
        end if;

        case set_ip_rx_start is
          when SET  => ip_rx_start_reg <= '1';
          when CLR  => ip_rx_start_reg <= '0';
          when HOLD => ip_rx_start_reg <= ip_rx_start_reg;
        end case;

        case set_is_broadcast is
          when SET  => is_broadcast_reg <= '1';
          when CLR  => is_broadcast_reg <= '0';
          when HOLD => is_broadcast_reg <= is_broadcast_reg;
        end case;

        case set_hdr_valid is
          when SET  => hdr_valid_reg <= '1';
          when CLR  => hdr_valid_reg <= '0';
          when HOLD => hdr_valid_reg <= hdr_valid_reg;
        end case;

        -- set error code
        if set_error_code = '1' then
          error_code_reg <= error_code_val;
        else
          error_code_reg <= error_code_reg;
        end if;
      end if;
    end if;
  end process;

end Behavioral;

