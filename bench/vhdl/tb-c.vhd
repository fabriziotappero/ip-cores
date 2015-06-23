-------------------------------------------------------------------------------
--
-- The testbench for t48_core.
--
-- $Id: tb-c.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

configuration tb_behav_c0 of tb is

  for behav

    for rom_internal_2k : lpm_rom
      use configuration work.lpm_rom_c0;
    end for;

    for rom_external_2k : lpm_rom
      use configuration work.lpm_rom_c0;
    end for;

    for ram_256 : generic_ram_ena
      use configuration work.generic_ram_ena_rtl_c0;
    end for;

    for ext_ram_b : generic_ram_ena
      use configuration work.generic_ram_ena_rtl_c0;
    end for;

    for t48_core_b : t48_core
      use configuration work.t48_core_struct_c0;
    end for;

    for if_timing_b : if_timing
      use configuration work.if_timing_behav_c0;
    end for;

  end for;

end tb_behav_c0;
