--
--      Package File Template
--
--      Purpose: This package defines supplemental types, subtypes, 
--               constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--
-- Revision 0.02 - Added type definitions (store and network) for arpv2

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package arp_types is


  -- arp lookup types
  
  type arp_req_req_type is
  record
    lookup_req : std_logic;             -- set high when wanting mac adr for the requested IP
    ip         : std_logic_vector (31 downto 0);
  end record;

  type arp_req_rslt_type is
  record
    got_mac : std_logic;                -- indicates that we got the mac
    mac     : std_logic_vector (47 downto 0);
    got_err : std_logic;                -- indicates that we got an error (prob a timeout)
  end record;

  type arp_entry_t is record
    ip  : std_logic_vector (31 downto 0);
    mac : std_logic_vector (47 downto 0);
  end record;

  type arp_control_type is
  record
    clear_cache : std_logic;
  end record;

  -- arp store types

  type arp_store_rslt_t is (IDLE, BUSY, SEARCHING, FOUND, NOT_FOUND);

  type arp_store_rdrequest_t is
  record
    req : std_logic;                      -- request to lookup
    ip  : std_logic_vector(31 downto 0);  -- contains ip to lookup
  end record;

  type arp_store_wrrequest_t is
  record
    req   : std_logic;                  -- request to store
    entry : arp_entry_t;                -- ip,mac to store
  end record;

  type arp_store_result_t is
  record
    status : arp_store_rslt_t;          -- status of the request
    entry  : arp_entry_t;               -- contains ip,mac if found
  end record;

  -- arp network types

  type arp_nwk_rslt_t is (IDLE, REQUESTING, RECEIVED, error);

  type arp_nwk_request_t is
  record
    req : std_logic;                      -- request to resolve IP addr
    ip  : std_logic_vector(31 downto 0);  -- IP to request
  end record;

  type arp_nwk_result_t is
  record
    status : arp_nwk_rslt_t;            -- status of request
    entry  : arp_entry_t;               -- the result
  end record;
  
  
end arp_types;
