-------------------------------------------------------------------------------
-- Title      : IP checksum counter
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ip_checksum.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Company    : 
-- Last update: 2009/09/29
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Counts 1's complement checksum for IP header
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/09/29  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp_ip_pkg.all;

entity ip_checksum is

  generic (
    -- this comes from the protocol, flags etc. field that are currently constants
    pre_counted_part_g : std_logic_vector( ip_checksum_w_c-1 downto 0 ) := (others => '0')
    );

  port (
    total_length_field_in : in  std_logic_vector( 15 downto 0 );
    source_addr_field_in  : in  std_logic_vector( ip_addr_w_c-1 downto 0 );
    dest_addr_field_in    : in  std_logic_vector( ip_addr_w_c-1 downto 0 );
    header_checksum_out   : out std_logic_vector( ip_checksum_w_c-1 downto 0 )
    );

end ip_checksum;


architecture rtl of ip_checksum is

  -- currently we have 5 additions, which means that the overflowing part of
  -- the additions can be at most 3-bits wide
  constant middle_sum_w_c : integer := ip_checksum_w_c + 3;
  signal   middle_sum_int : integer range 0 to 2**middle_sum_w_c-1;
  signal   middle_sum_slv : std_logic_vector( middle_sum_w_c-1 downto 0 );

  subtype addend_integer is integer range 0 to 2**ip_checksum_w_c-1;
  signal length_int           : addend_integer;
  signal source_addr_high_int : addend_integer;
  signal source_addr_low_int  : addend_integer;
  signal dest_addr_high_int   : addend_integer;
  signal dest_addr_low_int    : addend_integer;

-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  middle_sum_slv <= std_logic_vector( to_unsigned( middle_sum_int, middle_sum_w_c ));

  length_int           <= to_integer( unsigned( total_length_field_in ));
  source_addr_high_int <= to_integer( unsigned( source_addr_field_in( ip_addr_w_c-1 downto 16 ) ));
  source_addr_low_int  <= to_integer( unsigned( source_addr_field_in( 15 downto 0 ) ));
  dest_addr_high_int   <= to_integer( unsigned( dest_addr_field_in( ip_addr_w_c-1 downto 16 ) ));
  dest_addr_low_int    <= to_integer( unsigned( dest_addr_field_in( 15 downto 0 ) ));

  
  count_checksum : process (length_int, source_addr_high_int, source_addr_low_int,
                            dest_addr_high_int, dest_addr_low_int, middle_sum_slv)
    
    variable middle_sum_v : std_logic_vector( ip_checksum_w_c downto 0 );
    variable final_sum_v : integer range 0 to 2**ip_checksum_w_c - 1;
    variable final_checksum_v : std_logic_vector( ip_checksum_w_c-1 downto 0 );
    
  begin  -- process count_checksum

    middle_sum_int <= to_integer( unsigned( pre_counted_part_g ))+
                      length_int + source_addr_high_int + source_addr_low_int +
                      dest_addr_high_int + dest_addr_low_int;

    middle_sum_v :=
      std_logic_vector( to_unsigned(
        to_integer( unsigned( middle_sum_slv( ip_checksum_w_c-1 downto 0 ) )) +
        to_integer( unsigned( middle_sum_slv( middle_sum_w_c-1 downto ip_checksum_w_c ) )),
        ip_checksum_w_c+1 ));

    final_sum_v := to_integer( unsigned( middle_sum_v( ip_checksum_w_c-1 downto 0 ) )) +
                   to_integer( unsigned( middle_sum_v( ip_checksum_w_c downto ip_checksum_w_c ) ));

    final_checksum_v := not std_logic_vector( to_unsigned( final_sum_v, ip_checksum_w_c ));

    header_checksum_out <= final_checksum_v;

  end process count_checksum;


end rtl;
