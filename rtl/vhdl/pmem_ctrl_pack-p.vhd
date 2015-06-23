-------------------------------------------------------------------------------
--
-- $Id: pmem_ctrl_pack-p.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

package t48_pmem_ctrl_pack is

  -----------------------------------------------------------------------------
  -- Address Type Identifier
  -----------------------------------------------------------------------------
  type pmem_addr_ident_t is (PM_PC,
                             PM_PAGE,
                             PM_PAGE3);

end t48_pmem_ctrl_pack;
