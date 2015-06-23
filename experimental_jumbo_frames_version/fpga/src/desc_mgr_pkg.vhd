library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library work;
use work.pkt_ack_pkg.all;

package desc_mgr_pkg is

  constant LOG2_N_OF_PKTS    : integer := 4;
  constant N_OF_PKTS         : integer := 2**LOG2_N_OF_PKTS;
  constant LOG2_NWRDS_IN_PKT : integer := 10;
  constant NWRDS_IN_PKT      : integer := 1024;
  constant N_OF_SETS         : integer := 65536;

  -- Commands
  constant FCMD_START : integer := 1;
  constant FCMD_STOP  : integer := 2;
  constant FCMD_ACK   : integer := 3;
  constant FCMD_NACK  : integer := 4;
  constant FCMD_RESET : integer := 5;

end desc_mgr_pkg;

