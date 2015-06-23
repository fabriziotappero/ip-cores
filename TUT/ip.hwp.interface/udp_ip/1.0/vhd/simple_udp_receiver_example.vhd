-------------------------------------------------------------------------------
-- Title      : Simple UDP receiver example
-- Project    : 
-------------------------------------------------------------------------------
-- File       : simple_udp_receiver_example.vhd
-- Author     :   <alhonena@AHVEN>
-- Company    : 
-- Created    : 2011-09-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Connect this to UDP/IP CTRL. Receives packets and blinks a led
-- every time a packet is received.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-09-28  1.0      alhonena	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_udp_receiver_example is
  
  generic (
    data_width_g : integer := 16       -- 16 for DM9000A. 32 for LAN91C111
    );

  port (
    clk               : in  std_logic;  -- 25 MHz, synchronous with UDP/IP ctrl.
    rst_n             : in  std_logic;

    -- TX
    new_tx_out         : out  std_logic;
    tx_len_out         : out  std_logic_vector( 10 downto 0 );
    target_addr_out    : out  std_logic_vector( 31 downto 0 );
    -- Use this with target_addr_in when disable_arp_g = 1:
    no_arp_target_MAC_out     : out  std_logic_vector( 47 downto 0 ) := (others => '0');
    target_port_out    : out  std_logic_vector( 15 downto 0 );
    source_port_out    : out  std_logic_vector( 15 downto 0 );
    tx_data_out        : out  std_logic_vector( data_width_g-1 downto 0 );
    tx_data_valid_out  : out  std_logic;
    tx_re_in         : in std_logic;

    -- RX
    new_rx_in        : in std_logic;
    rx_data_valid_in : in std_logic;
    rx_data_in       : in std_logic_vector( data_width_g-1 downto 0 );
    rx_re_out        : out  std_logic;
    rx_erroneous_in  : in std_logic;
    source_addr_in   : in std_logic_vector( 31 downto 0 );
    source_port_in   : in std_logic_vector( 15 downto 0 );
    dest_port_in     : in std_logic_vector( 15 downto 0 );
    rx_len_in        : in std_logic_vector( 10 downto 0 );
    rx_error_in      : in std_logic;   -- this means system error, not error
                                        -- in data caused by network etc.
    -- Status:
    link_up_in       : in std_logic;
    fatal_error_in   : in std_logic;  -- Something wrong with DM9000A.

    -- Example application outputs:
    link_up_out      : out std_logic;
    led_out          : out std_logic

    );

end simple_udp_receiver_example;

architecture rtl of simple_udp_receiver_example is

  type state_t is (wait_init, wait_new_rx, read_packet, pkt_read);
  signal state_r : state_t;
  signal byte_cnt_r : integer range 0 to 1600;
  signal pkt_cnt_r : unsigned(31 downto 0);
  signal led_r : std_logic;
  signal rx_re_r : std_logic;
  
begin  -- rtl

  assert data_width_g = 16 or data_width_g = 32 report "Data width 16 or 32 supported." severity failure;

  led_out <= led_r;
  link_up_out <= link_up_in;

  rx_re_out <= rx_re_r;
  
  flooder: process (clk, rst_n)
  begin  -- process flooder
    if rst_n = '0' then                 -- asynchronous reset (active low)
      state_r <= wait_init;
      pkt_cnt_r <= (others => '0');
      rx_re_r <= '0';
      led_r <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- DEFAULT:
      rx_re_r <= '0'; 

      case state_r is

        when wait_init =>

          if link_up_in = '1' then
            state_r <= wait_new_rx;
          end if;

        when wait_new_rx =>
          if new_rx_in = '1' then
            -- You can read source_addr_in, source_port_in, dest_port_in here if you need them.
            -- E.g., if you want to receive from a particular PC for a custom protocol, it is
            -- recommended that you ignore unwanted packets (coming from a wrong address or with
            -- a wrong port) by reading all bytes (as shown here).

            -- You need to take care that you read all bytes, hence the counter.
            byte_cnt_r <= to_integer(unsigned(rx_len_in));

            -- You could read the first word already here but we are not in a hurry so we
            -- use just one state to read every word.

            state_r <= read_packet;

            -- Change the LED status:
            led_r <= not led_r;

            -- Count the packets just for fun:
            pkt_cnt_r <= pkt_cnt_r + to_unsigned(1, 32);
          end if;

        when read_packet =>
          if rx_data_valid_in = '1' and rx_re_r = '0' then  -- note the condition, otherwise the data is read twice.
            rx_re_r <= '1';           -- acknowledge the read.
            -- read the data here from rx_data_in if needed.
            -- Note that the endianness is "swapped", the first byte on the wire is
            -- in rx_data_in(7 downto 0).

            -- Note that byte_cnt_r here shows how many bytes we had left
            -- before this read operation. Stop reading if this is the last operation.
            if data_width_g = 16 then
              if byte_cnt_r = 1 or byte_cnt_r = 2 then
                state_r <= wait_new_rx;
              else
                byte_cnt_r <= byte_cnt_r - 2;
              end if;
            else -- data_width_g = 32
              if byte_cnt_r = 1 or byte_cnt_r = 2 or byte_cnt_r = 3 or byte_cnt_r = 4 then
                state_r <= wait_new_rx;
              else
                byte_cnt_r <= byte_cnt_r - 4;
              end if;              
            end if;

          end if;
          
        when others => null;
      end case;
    end if;
  end process flooder;



end rtl;
