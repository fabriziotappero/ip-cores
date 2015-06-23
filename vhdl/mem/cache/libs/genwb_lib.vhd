-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.memdef.all;
use work.cache_config.all;

-- PREFIX: gwbl_xxx
package genwb_lib is

--        dcache                wb 
-- +-------+ +-------+  +-------+ +-------+
-- |       | |       |->|       | |       |
-- +-------+ +-------+  +-------+ +-------+
-- .       . .       .  .       . .       .              
--                      .         .       .              
--                      +-------+ +-------+          
--                      |       | |       |          
--                      +-------+ +-------+
--                          V         V
--                      +-------+ +-------+          
--                      |       | |       |          
--                      +-------+ +-------+           
--                                
-- .         .       .            
-- +-------+ +-------+             
-- |       | |       |            
-- +-------+ +-------+             

--                      +---------------------+-----------+-----------+----+
-- addr as tag-access : |        TTAG         |   TADDR   | TLINE     | 00 |   
--                      +---------------------+-----------+-----------+----+


type gwbl_entry is record
  addr : std_logic_vector(31 downto 0);
  data : std_logic_vector(31 downto 0);
  burst : std_logic;
  size : lmd_memsize;
  read : std_logic;
  lock : std_logic;                     -- lock until next req
end record;
type gwbl_entry_a is array (natural range <>) of gwbl_entry;

end genwb_lib;

