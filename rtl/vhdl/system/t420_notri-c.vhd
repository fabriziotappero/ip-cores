-------------------------------------------------------------------------------
--
-- T420/421 controller toplevel without tri-states.
--
-- $Id: t420_notri-c.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

configuration t420_notri_struct_c0 of t420_notri is

  for struct

    for core_b: t400_core
      use configuration work.t400_core_struct_c0;
    end for;

    for pmem_b: t420_rom
      use configuration work.t420_rom_struct_c0;
    end for;

    for dmem_b: generic_ram_ena
      use configuration work.generic_ram_ena_rtl_c0;
    end for;

    for por_b: t400_por
      use configuration work.t400_por_rtl_c0;
    end for;

  end for;

end t420_notri_struct_c0;
