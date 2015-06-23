-------------------------------------------------------------------------------
-- Title      : Simple UDP flood example
-- Project    : 
-------------------------------------------------------------------------------
-- File       : simple_udp_flood_example.vhd
-- Author     :   <alhonena@AHVEN>
-- Company    : 
-- Created    : 2011-09-19
-- Last update: 2012-04-03
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Connect to UDP/IP controller. Creates TX operations as quickly
-- as possible. Sends running numbers.
-- Destination and packet size are configurable by using generics.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-09-19  1.0      alhonena        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_udp_flood_example is
  
  generic (
    data_width_g      : integer                       := 16;    -- 16 bits for DM9000A. 32b for LAN91C111
    packet_len_g      : integer                       := 1000;  -- #bytes, at least 5.
    target_ip_addr_g  : std_logic_vector(31 downto 0) := x"0A_00_00_04";
    target_ip_port_g  : integer                       := 5000;
    source_ip_port_g  : integer                       := 6000;
    disable_arp_g     : integer                       := 0;  -- Disable Address Resolution Protocol.
    -- If you disable ARP, provide also target's MAC address:
    target_MAC_addr_g : std_logic_vector(47 downto 0) := x"0001_02CE_F343"
    -- NOTE!!!! If ARP is enabled, you NEED RX functionality in UDP/IP/Ethernet.
    -- So do not disable it from those blocks if ARP is enabled.
    );

  port (
    clk   : in std_logic;  -- 25 MHz, synchronous with UDP/IP ctrl.
    rst_n : in std_logic;

    -- TX
    new_tx_out            : out std_logic;
    tx_len_out            : out std_logic_vector(10 downto 0);
    target_addr_out       : out std_logic_vector(31 downto 0);
    -- Use this with target_addr_in when disable_arp_g = 1:
    no_arp_target_MAC_out : out std_logic_vector(47 downto 0) := (others => '0');
    target_port_out       : out std_logic_vector(15 downto 0);
    source_port_out       : out std_logic_vector(15 downto 0);
    tx_data_out           : out std_logic_vector(data_width_g-1 downto 0);
    tx_data_valid_out     : out std_logic;
    tx_re_in              : in  std_logic;

    -- RX, this flooder just accepts everything
    new_rx_in        : in  std_logic;
    rx_data_valid_in : in  std_logic;
    rx_data_in       : in  std_logic_vector(data_width_g-1 downto 0);
    rx_re_out        : out std_logic;
    rx_erroneous_in  : in  std_logic;
    source_addr_in   : in  std_logic_vector(31 downto 0);
    source_port_in   : in  std_logic_vector(15 downto 0);
    dest_port_in     : in  std_logic_vector(15 downto 0);
    rx_len_in        : in  std_logic_vector(10 downto 0);
    rx_error_in      : in  std_logic;   -- this means system error, not error
                                        -- in data caused by network etc.
    -- Status:
    link_up_in       : in  std_logic;
    fatal_error_in   : in  std_logic;   -- Something wrong with DM9000A.

    -- Additional user outputs:
    link_up_out : out std_logic

    );

end simple_udp_flood_example;

architecture rtl of simple_udp_flood_example is

  -- State machine is a loop without branching (except self-loops).
  type   state_t is (wait_init, new_packet, fill_packet, pkt_sent);
  signal state_r    : state_t;

  signal byte_cnt_r : integer range 0 to packet_len_g;
  signal pkt_cnt_r  : unsigned(31 downto 0);
  
begin  -- rtl

  assert data_width_g = 16 or data_width_g = 32 report "Data width 16 or 32 supported." severity failure;
  assert packet_len_g > 4 report "Too short packet" severity failure;

  link_up_out <= link_up_in;

  flooder : process (clk, rst_n)
  begin  -- process flooder
    if rst_n = '0' then                 -- asynchronous reset (active low)
      state_r           <= wait_init;
      pkt_cnt_r         <= (others => '0');
      tx_data_valid_out <= '0';
      new_tx_out        <= '0';


      
    elsif clk'event and clk = '1' then  -- rising clock edge


      case state_r is

        when wait_init =>

          if link_up_in = '1' then
            state_r <= new_packet;
          end if;


          
        when new_packet =>
          -- Start a new tx. Provide addresses, ports and packet length based
          -- on generics.
          new_tx_out      <= '1';
          target_addr_out <= target_ip_addr_g;
          target_port_out <= std_logic_vector(to_unsigned(target_ip_port_g, 16));
          source_port_out <= std_logic_vector(to_unsigned(source_ip_port_g, 16));
          if disable_arp_g = 1 then
            no_arp_target_MAC_out <= target_MAC_addr_g;
          end if;

          -- This is important. The packet payload length in BYTES. This is the amount
          -- of the data YOUR application is going to write through tx_data_out. No IP,
          -- no UDP, no ethernet headers included. It's all automatic.
          tx_len_out <= std_logic_vector(to_unsigned(packet_len_g, 11));

          -- You also have to provide the first data word!
          -- Ethernet controllers expect little-endianness for their data bus. We swap the byte order here
          -- so that when you look the bytes in the order they arrived, it looks normal (most significant
          -- byte always first).
          if data_width_g = 16 then
            tx_data_out <= std_logic_vector(pkt_cnt_r(23 downto 16)) & std_logic_vector(pkt_cnt_r(31 downto 24));
          else
            tx_data_out <= std_logic_vector(pkt_cnt_r(7 downto 0)) & std_logic_vector(pkt_cnt_r(15 downto 8)) &
                           std_logic_vector(pkt_cnt_r(23 downto 16)) & std_logic_vector(pkt_cnt_r(31 downto 24));
          end if;

          -- Remember this every time you output data:
          tx_data_valid_out <= '1';
          -- You can also use a FIFO so that tx_data_valid_out <= not empty.

          byte_cnt_r <= packet_len_g - data_width_g/8;  -- count the first word, too.

          -- let's stay in this state until we get an acknowledgement - a read enable operation.
          if tx_re_in = '1' then
            state_r           <= fill_packet;
            tx_data_valid_out <= '0';  -- remember this, otherwise the data is read multiple times. Or, use a FIFO.
          end if;


          
        when fill_packet =>
          -- Provide padding if byte_amount is not divisible by data_width
          
          if (data_width_g = 16 and (byte_cnt_r = 0 or byte_cnt_r = 1)) or
            (data_width_g = 32 and (byte_cnt_r = 0 or byte_cnt_r = 1 or byte_cnt_r = 2 or byte_cnt_r = 3)) then
            state_r <= pkt_sent;
          else

            if data_width_g = 16 and byte_cnt_r = packet_len_g - data_width_g/8 then
              -- The rest of the packet number:
              tx_data_out <= std_logic_vector(pkt_cnt_r(7 downto 0)) & std_logic_vector(pkt_cnt_r(15 downto 8));
            else
              tx_data_out <= (others => '0');  -- just fill the rest of the packet with zeroes.
            end if;

            tx_data_valid_out <= '1';

            if tx_re_in = '1' then
              byte_cnt_r        <= byte_cnt_r - data_width_g/8;  -- go to the next word.
              tx_data_valid_out <= '0';
            end if;
          end if;


          
        when pkt_sent =>
          pkt_cnt_r <= pkt_cnt_r + to_unsigned(1, 32);
          -- Flood more packets.
          state_r   <= new_packet;
          
        when others => null;
      end case;
    end if;
  end process flooder;


  -- Always read incoming RXs in case RX is enabled. Disabling RX is recommended if it is not needed.
  rx_re_out <= '1';

end rtl;
