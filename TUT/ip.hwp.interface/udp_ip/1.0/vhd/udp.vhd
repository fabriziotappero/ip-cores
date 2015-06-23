-------------------------------------------------------------------------------
-- Title      : UDP/IP header handling
-- Project    : 
-------------------------------------------------------------------------------
-- File       : udp.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Company    : 
-- Last update: 2010/01/06
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Adds and removes UDP and IP headers to data
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/09/16  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp_ip_pkg.all;


entity udp is

  generic (
    data_width_g : integer := 16;
    tx_len_w_g   : integer := 11);

  port (
    clk                   : in  std_logic;
    rst_n                 : in  std_logic;
    -- from application to udp
    new_tx_in             : in  std_logic;
    tx_len_in             : in  std_logic_vector( tx_len_w_g-1 downto 0 );
    target_IP_in          : in  std_logic_vector( ip_addr_w_c-1 downto 0 );
    target_port_in        : in  std_logic_vector( port_w_c-1 downto 0 );
    source_port_in        : in  std_logic_vector( port_w_c-1 downto 0 );
    -- from udp to eth
    new_tx_out            : out std_logic;
    tx_MAC_addr_out       : out std_logic_vector( MAC_addr_w_c-1 downto 0 );
    tx_len_out            : out std_logic_vector( tx_len_w_g-1 downto 0 );
    tx_frame_type_out     : out std_logic_vector( frame_type_w_c-1 downto 0 );
    header_data_out       : out std_logic_vector( data_width_g-1 downto 0 );
    header_data_valid_out : out std_logic;
    ethernet_re_in        : in  std_logic;
    new_rx_in             : in  std_logic;
    rx_data_in            : in  std_logic_vector( data_width_g-1 downto 0 );
    rx_data_valid_in      : in  std_logic;
    rx_len_in             : in  std_logic_vector( tx_len_w_g-1 downto 0 );
    rx_frame_type_in      : in  std_logic_vector( frame_type_w_c-1 downto 0 );
    rx_re_out             : out std_logic;
    rx_erroneous_in       : in  std_logic;
    -- from udp to application
    rx_erroneous_out      : out std_logic;
    new_rx_out            : out std_logic;
    rx_len_out            : out std_logic_vector( tx_len_w_g-1 downto 0 );
    source_IP_out         : out std_logic_vector( ip_addr_w_c-1 downto 0 );
    source_port_out       : out std_logic_vector( port_w_c-1 downto 0 );
    dest_port_out         : out std_logic_vector( port_w_c-1 downto 0 );
    application_re_in     : in  std_logic;
    -- from udp to arpsnd
    request_MAC_out       : out std_logic;
    IP_to_arp_out         : out std_logic_vector( ip_addr_w_c-1 downto 0 );
    requested_MAC_in      : in  std_logic_vector( MAC_addr_w_c-1 downto 0 );
    req_MAC_valid_in      : in  std_logic;
    rx_arp_ready_in       : in  std_logic;
    snd_req_from_arp_in   : in  std_logic;
    tx_arp_ready_in       : in  std_logic;
    -- other control signals
    rx_error_out          : out std_logic;
    input_select_out      : out std_logic_vector( 1 downto 0 );
    output_select_out     : out std_logic_vector( 1 downto 0 )
    );

end udp;


architecture rtl of udp is

  type tx_state_type is (tx_idle, write_IP_headers, write_UDP_headers, relay_tx_data, tx_arp);
  type rx_state_type is (rx_idle, read_IP_headers, read_UDP_headers, relay_rx_data,
                         rx_arp, rx_discard, rx_error);
  type IP_header_state_type is (version_IHL_DS, IP_length, ID, flags_offset, TTL_protocol,
                                header_checksum, source_addr1, source_addr2,
                                dest_addr1, dest_addr2, discard);
  type UDP_header_state_type is (source_port, dest_port, UDP_length, UDP_checksum);

  signal rx_state_r     : rx_state_type;
  signal tx_state_r     : tx_state_type;
  signal tx_IP_state_r  : IP_header_state_type;
  signal tx_UDP_state_r : UDP_header_state_type;
  signal rx_IP_state_r  : IP_header_state_type;
  signal rx_UDP_state_r : UDP_header_state_type;


  signal rx_len_r        : integer range 0 to 2**tx_len_w_g-1;
  signal rx_re_r         : std_logic;

  signal discard_rx_r : std_logic;

  signal tx_len_r      : integer range 0 to 2**tx_len_w_g-1;
  signal target_port_r : std_logic_vector( port_w_c-1 downto 0 );
  signal source_port_r : std_logic_vector( port_w_c-1 downto 0 );
  signal target_addr_r : std_logic_vector( ip_addr_w_c-1 downto 0 );

  signal ip_checksum : std_logic_vector( ip_checksum_w_c-1 downto 0 );

  signal discard_xtra_bytes_r : std_logic;
  signal num_xtra_bytes_r : integer range 0 to 63;

  constant IP_header_words_c : integer := 5;  -- 32bit words
  constant UDP_header_length_c : integer := 8;  -- bytes

  -- precounted part of IP checksum, including field version_IHL_DS, ID,
  -- flags_offset and TTL_protocol
  constant pre_counted_part_of_checksum_c : std_logic_vector( ip_checksum_w_c-1 downto 0 )
    := "0100101000010001";

  signal tx_len_for_checksum : std_logic_vector( 15 downto 0 );
  
-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  -- *********************************************************************************
  -- REMEMBER!! rx_data_in(15 downto 8) = LSByte and rx_data_in(7 downto 0) = MSByte!!
  -- Same goes for the tx_data_out too!
  -- *********************************************************************************
  

-------------------------------------------------------------------------------
  rx_re_out <= rx_re_r;
  
  rx_process : process (clk, rst_n)

    variable incoming_len_v : integer range 0 to 2**tx_len_w_g-1;
    
  begin  -- process rx_process
    if rst_n = '0' then                 -- asynchronous reset (active low)

      rx_state_r <= rx_idle;
      rx_IP_state_r <= version_IHL_DS;
      rx_UDP_state_r <= source_port;

      rx_re_r               <= '0';
      rx_erroneous_out      <= '0';
      new_rx_out            <= '0';
      rx_len_out            <= (others => '0');
      source_IP_out         <= (others => '0');
      source_port_out       <= (others => '0');
      dest_port_out         <= (others => '0');
      discard_rx_r          <= '0';
      discard_xtra_bytes_r  <= '0';
      num_xtra_bytes_r      <= 0;

      input_select_out <= (others => '0');

      rx_error_out <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      case rx_state_r is
        when rx_idle =>

          new_rx_out       <= '0';
          rx_len_out       <= (others => '0');
          source_IP_out    <= (others => '0');
          source_port_out  <= (others => '0');
          dest_port_out    <= (others => '0');
          rx_erroneous_out <= '0';

          discard_rx_r         <= '0';
          discard_xtra_bytes_r <= '0';
          num_xtra_bytes_r     <= 0;

          if new_rx_in = '1' then

            if rx_frame_type_in = ARP_frame_type_c then
              -- arp packet goes straight to arp
              rx_state_r <= rx_arp;
              
            elsif rx_frame_type_in = IP_frame_type_c then
              -- data transfer coming, start reading the headers
              rx_state_r <= read_IP_headers;
              rx_IP_state_r <= version_IHL_DS;
              
              rx_len_r <= to_integer( unsigned( rx_len_in ));
              rx_erroneous_out <= rx_erroneous_in;

            else
              -- whoaa, unknown protocol, discard
              rx_len_r <= to_integer( unsigned( rx_len_in ));
              rx_state_r <= rx_discard;
              
            end if;
          end if;

        when read_IP_headers =>

          if rx_data_valid_in = '1' and rx_re_r = '0' then
            rx_re_r <= '1';
          end if;
          
          if rx_data_valid_in = '1' and rx_re_r = '1' then
            rx_re_r <= '0';

            -------------------------------------------------------------------
            -- sub FSM handling the different fields of tx
            case rx_IP_state_r is
              when version_IHL_DS =>

                -- 0_____________4_______________8_________________________16
                -- |   version   | header length | Differentiated Services |

                -- only thing we are interested of is the header length
                -- if there's options-fields (over 5 32bit words in the header)
                -- we simply discard this transmission
                if to_integer( unsigned( rx_data_in(3 downto 0) )) /= IP_header_words_c then
                  discard_rx_r <= '1';
                end if;
                
                rx_IP_state_r <= IP_length;

              when IP_length =>

                -- total length of the packet, including header and the data.
                incoming_len_v := to_integer( unsigned( rx_data_in(7 downto 0 ) & rx_data_in( 15 downto 8 ) ));

                -- +1, because when reading two bytes at a time, we don't need
                -- to read any xtra if rx_len = incoming_len_v + 1
                if rx_len_r > incoming_len_v + 1 then
                  -- amount of data is less than ethernet minimum frame size (64 bytes)
                  -- we have to discard the extra bytes after data has been relayed.
                  discard_xtra_bytes_r <= '1';

                  -- getting rid of the last bit, because with odd lengths one
                  -- of the xtra bytes is already read out with the last databyte
                  num_xtra_bytes_r <= (( rx_len_r - incoming_len_v ) / 2 ) * 2;
                  
                elsif rx_len_r /= incoming_len_v and rx_len_r /= incoming_len_v + 1 then
                  -- there's something wrong
                  rx_state_r <= rx_error;
                end if;

                rx_len_r <= incoming_len_v;
                rx_IP_state_r <= ID;

              when ID =>
                -- we don't care about this field
                rx_IP_state_r <= flags_offset;
              when flags_offset =>
                -- we don't care about the flags or the offset either
                rx_IP_state_r <= TTL_protocol;

              when TTL_protocol =>

                -- 0______________8______________16
                -- | Time To Live |   Protocol   |
                
                -- check that the protocol is UDP and TTL /= 0,
                -- otherwise discard this transmission
                if to_integer( unsigned( rx_data_in( 7 downto 0 ) )) = 0 or
                  rx_data_in( 15 downto 8 ) /= UDP_protocol_c
                then
                  discard_rx_r <= '1';
                end if;
                rx_IP_state_r <= header_checksum;

              when header_checksum =>

                -- checksum check not implemented yet, maybe some day...
                rx_IP_state_r <= source_addr1;

              when source_addr1 =>

                source_IP_out( 31 downto 24 ) <= rx_data_in( 7 downto 0 );
                source_IP_out( 23 downto 16 ) <= rx_data_in( 15 downto 8 );
                rx_IP_state_r <= source_addr2;

              when source_addr2 =>

                source_IP_out( 15 downto 8 ) <= rx_data_in( 7 downto 0 );
                source_IP_out( 7 downto 0 )  <= rx_data_in( 15 downto 8 );
                rx_IP_state_r <= dest_addr1;

              when dest_addr1 =>

                -- just check that the addr matches
                if rx_data_in( 7 downto 0 ) /= own_ip_c( 31 downto 24 ) or
                  rx_data_in( 15 downto 8 ) /= own_ip_c( 23 downto 16 )
                then
                  -- some multicast messages contain a certain IP, so we might
                  -- get packets with wrong address
                  discard_rx_r <= '1';
                end if;
                rx_IP_state_r <= dest_addr2;

              when dest_addr2 =>

                if (rx_data_in( 7 downto 0 ) /= own_ip_c( 15 downto 8 ) or
                  rx_data_in( 15 downto 8 ) /= own_ip_c( 7 downto 0 ))
                  or discard_rx_r = '1'
                then
                  -- if message is to be discarded, go and discard it, otherwise
                  -- start reading UDP headers
                  rx_IP_state_r <= discard;
                  -- there might also be extra bytes to discard, so add them to
                  -- the length and remove IP header length
                  rx_len_r <= rx_len_r + num_xtra_bytes_r - ( IP_header_words_c*4 );
                  
                else
                  rx_state_r     <= read_UDP_headers;
                  rx_UDP_state_r <= source_port;
                  rx_IP_state_r  <= version_IHL_DS;

                  -- remove IP header length
                  rx_len_r <= rx_len_r - ( IP_header_words_c * 4 );
                end if;

                
                

              when discard =>

                -- just pretend to be reading
                if rx_len_r <= 2 then
                  -- all done
                  rx_len_r <= 0;
                  rx_IP_state_r <= version_IHL_DS;
                  rx_state_r <= rx_idle;
                else
                  rx_len_r <= rx_len_r - 2;
                end if;
                
              when others => null;
            end case;
            -- /rx_IP_state_r
            -------------------------------------------------------------------            
          end if;


          
        when read_UDP_headers =>

          if rx_data_valid_in = '1' and rx_re_r = '0' then
            rx_re_r <= '1';
          end if;
          
          if rx_data_valid_in = '1' and rx_re_r = '1' then
            rx_re_r <= '0';

            -- FSM to read the UDP header
            -------------------------------------------------------------------
            case rx_UDP_state_r is
              when source_port =>

                source_port_out( 15 downto 8 ) <= rx_data_in( 7 downto 0 );
                source_port_out( 7 downto 0 )  <= rx_data_in( 15 downto 8 );
                rx_UDP_state_r <= dest_port;

              when dest_port =>

                dest_port_out( 15 downto 8 ) <= rx_data_in( 7 downto 0 );
                dest_port_out( 7 downto 0 )  <= rx_data_in( 15 downto 8 );
                rx_UDP_state_r <= UDP_length;

              when UDP_length =>

                -- check that the length field is correct
                if rx_len_r /=
                  to_integer( unsigned( rx_data_in(7 downto 0 ) & rx_data_in( 15 downto 8 ) ))
                then
                  rx_state_r <= rx_error;
                end if;
                rx_UDP_state_r <= UDP_checksum;

              when UDP_checksum =>

                -- umm, it's propably correct...
                -- give rx_data to application
                input_select_out <= "10";
                rx_state_r <= relay_rx_data;
                -- notify application about new tx
                new_rx_out <= '1';
                rx_len_out <= std_logic_vector( to_unsigned( rx_len_r -
                                                             UDP_header_length_c,
                                                             tx_len_w_g ));
                
                
                rx_UDP_state_r <= source_port;
                rx_len_r <= rx_len_r - UDP_header_length_c;
                
              when others => null;
            end case;
            -- /rx_UDP_state_r
            -------------------------------------------------------------------
          end if;

          
        when relay_rx_data =>

          -- monitor application_re
          if application_re_in = '1' and rx_data_valid_in = '1' then

            new_rx_out <= '0';
            
            if rx_len_r <= 2 then
              -- all received
              input_select_out <= "00";

              -- if there is extra bytes
              if discard_xtra_bytes_r = '1' then
                
                rx_state_r           <= rx_discard;
                rx_len_r             <= num_xtra_bytes_r;
                discard_xtra_bytes_r <= '0';
                num_xtra_bytes_r     <= 0;
                
              else
                rx_state_r <= rx_idle;
                rx_len_r   <= 0;
              end if;
              
            else
              rx_len_r <= rx_len_r - 2;
            end if;
          end if;


        when rx_arp =>

          -- give turn to arp until it says it's ready
          input_select_out <= "01";
          if rx_arp_ready_in = '1' then
            input_select_out <= "00";
            rx_state_r <= rx_idle;
          end if;

          
        when rx_discard =>
          -- we come here, if the frame type of ethernet frame is something
          -- else than ARP or IP or if there is extra bytes in the frame (less
          -- data than minimum ethernet frame size)
          
          if rx_data_valid_in = '1' and rx_re_r = '0' then
            rx_re_r <= '1';
          end if;
          
          if rx_data_valid_in = '1' and rx_re_r = '1' then
            rx_re_r <= '0';

            -- just pretend to be reading
            if rx_len_r <= 2 then
              -- all done
              rx_len_r <= 0;
              rx_state_r <= rx_idle;
            else
              rx_len_r <= rx_len_r - 2;
            end if;
          end if;
          
        when rx_error =>

          -- shit just hit the fan
          rx_error_out <= '1';
          
        when others => null;
      end case;

    end if;
  end process rx_process;
-------------------------------------------------------------------------------

  tx_len_for_checksum <= std_logic_vector( to_unsigned( tx_len_r, 16 ));
  
  -- IP checksum computation
  checksum_adder: entity work.ip_checksum
    generic map (
        pre_counted_part_g => pre_counted_part_of_checksum_c
        )
    port map (
        total_length_field_in => tx_len_for_checksum,
        source_addr_field_in  => own_ip_c,
        dest_addr_field_in    => target_addr_r,
        header_checksum_out   => ip_checksum
        );

-------------------------------------------------------------------------------
  

  tx_process: process (clk, rst_n)

    variable tx_len_v : integer range 0 to 2**tx_len_w_g-1;
    variable tx_len_slv_v : std_logic_vector( 15 downto 0 );
    
  begin  -- process tx_process
    if rst_n = '0' then                 -- asynchronous reset (active low)

      tx_state_r <= tx_idle;
      tx_IP_state_r <= version_IHL_DS;
      tx_UDP_state_r <= source_port;
      
      output_select_out <= (others => '0');
      tx_len_r <= 0;
      target_addr_r <= (others => '0');
      target_port_r <= (others => '0');
      source_port_r <= (others => '0');

      request_MAC_out       <= '0';
      IP_to_arp_out         <= (others => '0');
      new_tx_out            <= '0';
      tx_MAC_addr_out       <= (others => '0');
      tx_len_out            <= (others => '0');
      tx_frame_type_out     <= (others => '0');
      header_data_out       <= (others => '0');
      header_data_valid_out <= '0';
      
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      case tx_state_r is
        when tx_idle =>

          -- if arp want's to send, give it the output
          if snd_req_from_arp_in = '1' then
            tx_state_r <= tx_arp;

          elsif new_tx_in = '1' then

            if req_MAC_valid_in = '1' then
              -- MAC found from the ARP table, start sending
              tx_state_r <= write_IP_headers;
              -- write first word here already (version_IHL_DS)
              -- first the version, IPv4
              header_data_out( 7 downto 4 ) <= "0100";
              -- then header length in words
              header_data_out( 3 downto 0 ) <= std_logic_vector( to_unsigned( IP_header_words_c, 4 ));
              -- then Differentiated Services (just zeros)
              header_data_out( 15 downto 8 ) <= (others => '0');
              
              header_data_valid_out <= '1';

              tx_len_v   := to_integer( unsigned( tx_len_in )) +
                            IP_header_words_c*4 + UDP_header_length_c;
              tx_len_r   <= tx_len_v;
              tx_len_out <= std_logic_vector( to_unsigned( tx_len_v, tx_len_w_g ));
              new_tx_out <= '1';
              tx_frame_type_out <= IP_frame_type_c;
              
              source_port_r    <= source_port_in;
              target_port_r    <= target_port_in;
              target_addr_r    <= target_IP_in;
              tx_MAC_addr_out  <= requested_MAC_in;

              request_MAC_out <= '0';

            else
              -- We must get the MAC address before we can start sending
              request_MAC_out <= '1';
              IP_to_arp_out   <= target_IP_in;
            end if;
          end if;


        when write_IP_headers =>

          if ethernet_re_in = '1' then
            -- the data of the next state is written during the previous one
            case tx_IP_state_r is
              when version_IHL_DS =>
                
                new_tx_out <= '0';
                tx_IP_state_r <= IP_length;

                -- remember, data goes in as 2 bytes, not as single 16-bit word
                tx_len_slv_v := std_logic_vector( to_unsigned( tx_len_r, 16 ));
                header_data_out <= tx_len_slv_v( 7 downto 0 ) & tx_len_slv_v( 15 downto 8 );

              when IP_length =>
                tx_IP_state_r <= ID;
                header_data_out <= (others => '0');

              when ID =>
                tx_IP_state_r <= flags_offset;
                header_data_out <= (others => '0');

              when flags_offset =>

                tx_IP_state_r <= TTL_protocol;
                -- this block is made for direct communication, not router
                -- networks, so 1 to TTL field should do. Still, just in case,
                -- we'll put there a 5.
                header_data_out( 7 downto 0 )  <= "00000101";
                -- protocol is UDP
                header_data_out( 15 downto 8 ) <= UDP_protocol_c;

              when TTL_protocol =>
                tx_IP_state_r <= header_checksum;
                header_data_out <= ip_checksum( 7 downto 0 ) & ip_checksum( 15 downto 8 );

              when header_checksum =>
                tx_IP_state_r <= source_addr1;
                header_data_out <= own_ip_c( 23 downto 16 ) & own_ip_c( 31 downto 24 );

              when source_addr1 =>
                tx_IP_state_r <= source_addr2;
                header_data_out <= own_ip_c( 7 downto 0 ) & own_ip_c( 15 downto 8 );

              when source_addr2 =>
                tx_IP_state_r <= dest_addr1;
                header_data_out <= target_addr_r( 23 downto 16 ) & target_addr_r( 31 downto 24 );

              when dest_addr1 =>
                tx_IP_state_r <= dest_addr2;
                header_data_out <= target_addr_r( 7 downto 0 ) & target_addr_r( 15 downto 8 );

              when dest_addr2 =>
                -- all written, move on to write the UDP addr
                tx_state_r <= write_UDP_headers;
                tx_IP_state_r <= version_IHL_DS;
                -- first UDP data
                header_data_out <= source_port_r( 7 downto 0 ) & source_port_r( 15 downto 8 );
              
              when others => null;
            end case;
          end if;
          

        when write_UDP_headers =>

          if ethernet_re_in = '1' then

            case tx_UDP_state_r is
              when source_port =>
                
                tx_UDP_state_r <= dest_port;
                header_data_out <= target_port_r( 7 downto 0 ) & target_port_r( 15 downto 8 );

              when dest_port =>
                
                tx_UDP_state_r <= UDP_length;
                tx_len_slv_v := std_logic_vector( to_unsigned( tx_len_r -
                                                               IP_header_words_c*4, 16 ));
                header_data_out <= tx_len_slv_v( 7 downto 0 ) & tx_len_slv_v( 15 downto 8 );

              when UDP_length =>
                tx_UDP_state_r <= UDP_checksum;
                -- not used
                header_data_out <= (others => '0');

              when UDP_checksum =>

                -- all done, start relaying the data
                header_data_valid_out <= '0';
                header_data_out       <= (others => '0');
                tx_UDP_state_r        <= source_port;
                tx_state_r            <= relay_tx_data;
                output_select_out     <= "10";
                -- remove headers from length
                tx_len_r <= tx_len_r - IP_header_words_c*4 - UDP_header_length_c;
                
              when others => null;
            end case;
          end if;


        when relay_tx_data =>

          -- count the amount of sent data and go back to idle after all is sent
          if ethernet_re_in = '1' then

            if tx_len_r <= 2 then
              -- all sent
              tx_len_r          <= 0;
              tx_state_r        <= tx_idle;
              output_select_out <= "00";

            else
              tx_len_r <= tx_len_r - 2;
            end if;
          end if;

          
        when tx_arp =>

          -- give output to arp
          output_select_out <= "01";

          -- wait until it's idle again
          if tx_arp_ready_in = '1' then
            output_select_out <= "00";
            tx_state_r <= tx_idle;
          end if;
          
        when others => null;
      end case;
            
    end if;
  end process tx_process;

  

end rtl;
