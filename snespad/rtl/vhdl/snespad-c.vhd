-------------------------------------------------------------------------------
--
-- SNESpad controller core
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- $Id: snespad-c.vhd 41 2009-04-01 19:58:04Z arniml $
--
-------------------------------------------------------------------------------

configuration snespad_struct_c0 of snespad is

  for struct
    for ctrl_b : snespad_ctrl
      use configuration work.snespad_ctrl_rtl_c0;
    end for;

    for pads
      for pad_b : snespad_pad
        use configuration work.snespad_pad_rtl_c0;
      end for;
    end for;
  end for;

end snespad_struct_c0;
