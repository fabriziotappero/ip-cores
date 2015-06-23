-- $(lic)
-- $(help_generic)
-- $(help_local)

library IEEE;
use IEEE.std_logic_1164.all;
use work.armcoproc.all;

package armcp_comp is

component armcp_sctrl
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  aco_in;
    o       : out aco_out
    );
end component;

end armcp_comp;
