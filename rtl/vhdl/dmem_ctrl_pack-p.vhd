-------------------------------------------------------------------------------
--
-- $Id: dmem_ctrl_pack-p.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

package t48_dmem_ctrl_pack is

  -----------------------------------------------------------------------------
  -- Address Type Identifier
  -----------------------------------------------------------------------------
  type dmem_addr_ident_t is (DM_PLAIN,
                             DM_REG,
                             DM_STACK,
                             DM_STACK_HIGH);

end t48_dmem_ctrl_pack;
