-------------------------------------------------------------------------------
--
-- T8048 Microcontroller System
--
-- $Id: t8048_notri-c.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

configuration t8048_notri_struct_c0 of t8048_notri is

  for struct

    for rom_1k_b : t48_rom
      use configuration work.t48_rom_lpm_c0;
    end for;

    for ram_64_b : generic_ram_ena
      use configuration work.generic_ram_ena_rtl_c0;
    end for;

    for t48_core_b : t48_core
      use configuration work.t48_core_struct_c0;
    end for;

  end for;

end t8048_notri_struct_c0;
