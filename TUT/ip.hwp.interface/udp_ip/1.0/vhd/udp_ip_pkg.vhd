-- constants and stuff

library ieee;
use ieee.std_logic_1164.all;

package udp_ip_pkg is

  constant udp_data_width_c    : integer := 16;
  constant tx_len_w_c      : integer := 11;
  constant ip_addr_w_c     : integer := 32;
  constant MAC_addr_w_c    : integer := 48;
  constant port_w_c        : integer := 16;
  constant frame_type_w_c  : integer := 16;
  constant ip_checksum_w_c : integer := 16;

  constant ARP_frame_type_c : std_logic_vector( frame_type_w_c-1 downto 0 ) := x"0806";
  constant IP_frame_type_c : std_logic_vector( frame_type_w_c-1 downto 0 ) := x"0800";
  constant UDP_protocol_c : std_logic_vector( 7 downto 0 ) := x"11";
  
  constant own_ip_c : std_logic_vector( ip_addr_w_c-1 downto 0 ) := x"0A00000A";
  constant MAC_addr_c : std_logic_vector( MAC_addr_w_c-1 downto 0 ) := x"ACDCABBACD00";

end udp_ip_pkg;
