library ieee;
use ieee.std_logic_1164.all;
use work.memdef.all;

-- $(trans-do-not-touch)
-- PREFIX: cfg_xxx
package config is


-- byte order
constant CFG_BO_BUS  : lmd_byteorder  := lmd_big;
constant CFG_BO_PROC : lmd_byteorder  := lmd_big;
constant CFG_BO_INSN : lmd_byteorder  := lmd_little;

end;
