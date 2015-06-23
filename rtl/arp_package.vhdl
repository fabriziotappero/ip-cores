-- 
-- author:   Justin Wagner
-- file:     arp_package.vhdl
-- comment:  package for ARP
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package arp_package is 
    type HA_mem_type is array (0 to 5) of std_logic_vector(7 downto 0);
    type PA_mem_type is array (0 to 3) of std_logic_vector(7 downto 0);
    type TYPE_mem_type is array (0 to 1) of std_logic_vector(7 downto 0);

    constant MAC_BDCST_ADDR   : HA_mem_type                   := ((x"FF"),(x"FF"),(x"FF"),(x"FF"),(x"FF"),(x"FF"));
    constant CMP_A_MAC_ADDR   : HA_mem_type                   := ((x"00"),(x"01"),(x"42"),(x"00"),(x"5F"),(x"68"));
    constant CMP_A_IPV4_ADDR  : PA_mem_type                   := ((x"C0"),(x"A8"),(x"01"),(x"01"));
    constant E_TYPE_ARP       : TYPE_mem_type                 := ((x"08"),(x"06"));
    constant H_TYPE_ETH       : TYPE_mem_type                 := ((x"00"),(x"01"));
    constant P_TYPE_IPV4      : TYPE_mem_type                 := ((x"08"),(x"00"));
    constant ARP_OPER_REQ     : TYPE_mem_type                 := ((x"00"),(x"01"));
    constant ARP_OPER_RESP    : TYPE_mem_type                 := ((x"00"),(x"02"));
    constant H_TYPE_ETH_LEN   : std_logic_vector(7 downto 0)  := x"06";
    constant P_TYPE_IPV4_LEN  : std_logic_vector(7 downto 0)  := x"04";
end arp_package;

