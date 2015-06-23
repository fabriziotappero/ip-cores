--------------------------------------------------------------------------------
-- Object        : Package work.package_esoc_configuration
-- Last modified : Thu Oct 10 12:38:17 2013.
--------------------------------------------------------------------------------



library ieee, std;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------------------------------------
-- Package declaration: ESoC Configuration items
---------------------------------------------------------------------------------------------------------------
package package_esoc_configuration is
-- Manufacturer and device ID
constant  esoc_id: std_logic_vector(31 downto 0):= X"71022" & X"001";

-- Version information (version.release)
constant  esoc_version: integer                 := 1;
constant  esoc_release: integer                 := 0;

-- Mode of operation
type esoc_modes is (normal, simulation);
constant esoc_mode: esoc_modes                  := simulation;

-- Boot from ROM
type esoc_brom_modes is (disabled, enabled);
constant esoc_brom_mode: esoc_brom_modes        := disabled;

-- Port count configuration (maximum is 16)
constant  esoc_port_count: integer              := 8;

---------------------------------------------------------------------------------------------------------------
-- Package declaration: ESoC Address Mapping
---------------------------------------------------------------------------------------------------------------
-- Address mapping
constant  esoc_base                             : integer := 0;                         -- Boundaries of eSoc memory
constant  esoc_size                             : integer := 65280;

constant  esoc_testbench_base                   : integer := 65280;                     -- Base address = 0xFF00
constant  esoc_testbench_size                   : integer := 8;

constant  esoc_search_engine_base               : integer := 34832;                     -- Base address = 0x8810
constant  esoc_search_engine_size               : integer := 8;

constant  esoc_bus_arbiter_base                 : integer := 34816;                     -- Base address = 0x8808 for ID 1
constant  esoc_bus_arbiter_size                 : integer := 8;                         -- Base address = 0x8800 for ID 0

constant  esoc_control_base                     : integer := 32768;                     -- Base address = 0x8000
constant  esoc_control_size                     : integer := 8;

constant  esoc_port_mac_base                    : integer := 0;                         -- Base address = port_base + port_nr * port_base_offset
constant  esoc_port_mac_size                    : integer := 256;
constant  esoc_port_mal_base                    : integer := 384;
constant  esoc_port_mal_size                    : integer := 8;
constant  esoc_port_proc_base                   : integer := 400;
constant  esoc_port_proc_size                   : integer := 16;
constant  esoc_port_base_offset                 : integer := 2048;

---------------------------------------------------------------------------------------------------------------
-- Package declaration: ESoC Design items
---------------------------------------------------------------------------------------------------------------
-- Configuration of clock and clock enables 
constant clk_control_freq                       : integer := 50000000;
constant clk_data_freq                          : integer := 125000000;
constant clk_search_freq                        : integer := 100000000;

constant clk_search_en_div_1s                   : integer := clk_search_freq/1;         -- 1s enable    --> 100MHz / 1Hz
constant clk_search_en_div_1s_sim               : integer := clk_search_freq/100000;    -- 10us enable  --> 100MHz / 100kHz

-- Number of metastability flip flops
constant  esoc_meta_ffs                         : integer := 2;

-- Ethernet Packet Known Values
constant  esoc_ethernet_uc_mc_bc                : integer := 40;                        -- if bit 40 of the DA is 0 it is a uni cast else a multicast or even broadcast
constant  esoc_ethernet_vlan_type               : std_logic_vector(15 downto 0) := X"8100";
constant  esoc_ethernet_vlan_qos                : std_logic_vector(11 downto 0) := X"000";
constant  esoc_ethernet_ipv4_type               : std_logic_vector(15 downto 0) := X"0800";
constant  esoc_ethernet_ipv6_type                : std_logic_vector(15 downto 0) := X"8808";

-- Entity ESoC Port Mal[Inbound] to ESoC Port Processor[Search]
-- Record stored in Header Fifo format (start positions)
constant  esoc_inbound_header_dmac_hi           : integer := 80;                        -- Position of destination MAC in header fifo entry, length is 48 bits
constant  esoc_inbound_header_dmac_lo           : integer := 64;                        -- Position of destination and source MAC in header fifo entry, length is 48 bits
constant  esoc_inbound_header_smac_hi           : integer := 48;                        -- Position of destination and source MAC in header fifo entry, length is 48 bits
constant  esoc_inbound_header_smac_lo           : integer := 16;                        -- Position of source MAC in header fifo entry, length is 48 bits
constant  esoc_inbound_header_vlan              : integer := 4;                         -- Position of vlan ID in header fifo entry, length is 12 bits
constant  esoc_inbound_header_unused3_flag      : integer := 3;                         -- Position of ... flag in header fifo entry, length is 1 bit
constant  esoc_inbound_header_unused2_flag      : integer := 2;                         -- Position of ... flag in header fifo entry, length is 1 bit
constant  esoc_inbound_header_unused1_flag      : integer := 1;                         -- Position of ... flag in header fifo entry, length is 1 bit
constant  esoc_inbound_header_vlan_flag         : integer := 0;                         -- Position of vlan tagged packet flag in header fifo entry, length is 1 bit

-- Entity ESoC Port Mal[Inbound] to ESoC Port Processor[Inbound Control]
-- Record stored in Info Fifo format (start positions)
constant  esoc_inbound_info_length              : integer := 20;                        -- Position of packet length in info fifo entry
constant  esoc_inbound_info_length_size         : integer := 12;                        -- Size of packet length in info fifo entry
constant  esoc_inbound_info_vlan_tci            : integer := 4;                         -- Position of vlan tag in info fifo entry, length is 16 bits
constant  esoc_inbound_info_unused3_flag        : integer := 3;                         -- Position of ... flag in info fifo entry, length is 1 bit
constant  esoc_inbound_info_unused2_flag        : integer := 2;                         -- Position of ... flag in info fifo entry, length is 1 bit
constant  esoc_inbound_info_unused1_flag        : integer := 1;                         -- Position of ... flag in info fifo entry, length is 1 bit
constant  esoc_inbound_info_vlan_flag           : integer := 0;                         -- Position of vlan tagged packet flag in info fifo entry, length is 1 bit

-- Entity ESoC Port Processor[Outbound Control] to ESoC Port Mal[Outbound]
-- Record stored in Info Fifo format (start positions)
constant  esoc_outbound_info_length             : integer := 4;                         -- Position of packet length in info fifo entry
constant  esoc_outbound_info_length_size        : integer := 12;                        -- Size of packet length in info fifo entry
constant  esoc_outbound_info_unused3_flag       : integer := 3;                         -- Position of ... flag in info fifo entry, length is 1 bit
constant  esoc_outbound_info_unused2_flag       : integer := 2;                         -- Position of ... flag in info fifo entry, length is 1 bit
constant  esoc_outbound_info_vlan_flag          : integer := 1;                         -- Position of vlan tagged packet flag in info fifo entry, length is 1 bit
constant  esoc_outbound_info_error_flag         : integer := 0;                         -- Position of error flag in info fifo entry, length is 1 bit

-- Entity ESoC Port Processor[Inbound Control] to ESoC Port Processor[Outbound Control]
-- Record prepended for each packet transferred over data bus (start positions)
constant  esoc_dbus_packet_info_sport          : integer := 32;                         -- Position of ESoC source port in prependeded packet info DWORD, length is 4 bits
constant  esoc_dbus_packet_info_length         : integer := 20;                         -- Position of packet length in prependeded packet info DWORD
constant  esoc_dbus_packet_info_length_size    : integer := 12;                         -- Size of packet length in prependeded packet info DWORD
constant  esoc_dbus_packet_info_vlan_tci       : integer := 4;                          -- Position of vlan tag in prependeded packet info DWORD, length is 16 bits
constant  esoc_dbus_packet_info_unused3_flag   : integer := 3;                          -- Position of ... flag in prependeded packet info DWORD, length is 1 bit
constant  esoc_dbus_packet_info_unused2_flag   : integer := 2;                          -- Position of ... flag in prependeded packet info DWORD, length is 1 bit
constant  esoc_dbus_packet_info_unused1_flag   : integer := 1;                          -- Position of ... flag in prependeded packet info DWORD, length is 1 bit
constant  esoc_dbus_packet_info_vlan_flag      : integer := 0;                          -- Position of vlan tagged packet flag in prependeded packet info DWORD, length is 1 bit

-- Entity ESoC Port Processor[Search] to ESoC Search Engine
-- Record transferred over search bus (start positions)
constant  esoc_search_bus_sport  : integer := 48;                                       -- Position of ESoC source port, length is 16 bits
constant  esoc_search_bus_vlan   : integer := 48;                                       -- Position of VLAN ID in table entry, length is 12 bit
constant  esoc_search_bus_mac    : integer := 0;                                        -- Position of MAC address in table entry, length is 48 bit

-- Entity ESoC Search Engine configuration
constant  esoc_search_engine_col_depth         : integer := 7;                          -- Depth of collision buffer in number of entries, valid values 0 up to 7, results in a depth of 0 to 7 additional entries. 
constant  esoc_search_engine_hash_delay        : integer := 1;                          -- Hash delay is determined by XOR tree and RAM latency (=1 clock)

-- Entity ESoC Search Engine
-- Record in MAC/VLAN Learning table
constant  esoc_search_entry_valid             : integer := 79;                         -- Position of entry valid flag in table entry, length is 1 bit
constant  esoc_search_entry_aging            : integer := 78;                         -- Position of update flag for aging protocol in table entry, length is 1 bit
constant  esoc_search_entry_unused2           : integer := 77;                         -- 
constant  esoc_search_entry_unused1           : integer := 76;                         -- 
constant  esoc_search_entry_destination       : integer := 60;                         -- Position of destination ports in table entry, length is 16 bit
constant  esoc_search_entry_vlan              : integer := 48;                         -- Position of VLAN ID in table entry, length is 12 bit
constant  esoc_search_entry_mac               : integer := 0;                          -- Position of MAC address in table entry, length is 48 bit

end package_esoc_configuration;

---------------------------------------------------------------------------------------------------------------
-- Package definitions
---------------------------------------------------------------------------------------------------------------
package body package_esoc_configuration is

end package_esoc_configuration;









