-------------------------------------------------------------------------------
--
-- The testbench for t8243 core.
--
-- $Id: tb_t8243-c.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

configuration tb_t8243_behav_c0 of tb_t8243 is

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

    for t8243_sync_notri_b : t8243_sync_notri
      use configuration work.t8243_sync_notri_struct_c0;
    end for;

    for if_timing_b : if_timing
      use configuration work.if_timing_behav_c0;
    end for;

  end for;

end tb_t8243_behav_c0;
