-------------------------------------------------------------------------------
--
-- T8x49 ROM
--
-- $Id: t49_rom-struct-c.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

configuration t49_rom_struct_c0 of t49_rom is

  for struct

    for rom_b: rom_t49
      use configuration work.rom_t49_rtl_c0;
    end for;

  end for;

end t49_rom_struct_c0;
