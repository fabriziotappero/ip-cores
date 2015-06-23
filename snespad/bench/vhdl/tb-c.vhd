-------------------------------------------------------------------------------
--
-- Testbench for the
-- SNESpad controller core
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- $Id: tb-c.vhd 41 2009-04-01 19:58:04Z arniml $
--
-------------------------------------------------------------------------------

configuration tb_behav_c0 of tb is

  for behav
    for dut : snespad
      use configuration work.snespad_struct_c0;
    end for;
  end for;

end tb_behav_c0;
