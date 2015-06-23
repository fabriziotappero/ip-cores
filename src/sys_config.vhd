library ieee;
use ieee.std_logic_1164.all;
library work;
package sys_config is
  constant SORT_DEBUG              : boolean :=false;
  constant SYS_NLEVELS             : integer :=5;
  constant DATA_REC_SORT_KEY_WIDTH : integer :=8;
  constant DATA_REC_PAYLOAD_WIDTH  : integer :=4;
end sys_config;
