-------------------------------------------------------------------------------
--
-- The testbench for t8048 driving a t8243.
--
-- $Id: tb_t8048_t8243-c.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

configuration tb_t8048_t8243_behav_c0 of tb_t8048_t8243 is

  for behav

    for ext_ram_b : generic_ram_ena
      use configuration work.generic_ram_ena_rtl_c0;
    end for;

    for ext_rom_b : lpm_rom
      use configuration work.lpm_rom_c0;
    end for;

    for t8048_b : t8048
      use configuration work.t8048_struct_c0;
    end for;

    for t8243_b : t8243
      use configuration work.t8243_struct_c0;
    end for;

  end for;

end tb_t8048_t8243_behav_c0;
