-------------------------------------------------------------------------------
--
-- T8x49 ROM
-- Wrapper for ROM model from the LPM library.
--
-- $Id: t49_rom-lpm-c.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2006 Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

configuration t49_rom_lpm_c0 of t49_rom is

  for lpm

    for rom_b: lpm_rom
      use configuration work.lpm_rom_c0;
    end for;

  end for;

end t49_rom_lpm_c0;
