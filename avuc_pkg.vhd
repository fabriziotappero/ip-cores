---------------------------------------------------------------------------------------
-- Copyright 2008 by Fernando Blanco <ferblanco@anagramix.com>
-- Description: Package for AVUC
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package avuc_pkg is

    -- Possible states for avuc:
    constant AVUC_STATE_RUNNING  : std_logic := '0'; 
    constant AVUC_STATE_STOPPED  : std_logic := '1'; 

end package avuc_pkg;
