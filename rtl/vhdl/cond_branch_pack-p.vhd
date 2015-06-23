-------------------------------------------------------------------------------
--
-- $Id: cond_branch_pack-p.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package t48_cond_branch_pack is

  -----------------------------------------------------------------------------
  -- The branch conditions.
  -----------------------------------------------------------------------------
  type branch_conditions_t is (COND_ON_BIT, COND_Z,
                               COND_C,
                               COND_F0, COND_F1,
                               COND_INT,
                               COND_T0, COND_T1,
                               COND_TF);

  subtype comp_value_t is std_logic_vector(2 downto 0);

end t48_cond_branch_pack;
