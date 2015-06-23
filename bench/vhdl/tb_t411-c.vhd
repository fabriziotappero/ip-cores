-------------------------------------------------------------------------------
--
-- Testbench for the T411 system toplevel.
--
-- $Id: tb_t411-c.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

configuration tb_t411_behav_c0 of tb_t411 is

  for behav

    for t411_b: t411
      use configuration work.t411_struct_c0;
    end for;

    for tb_elems_b: tb_elems
      use configuration work.tb_elems_behav_c0;
    end for;

  end for;

end tb_t411_behav_c0;
