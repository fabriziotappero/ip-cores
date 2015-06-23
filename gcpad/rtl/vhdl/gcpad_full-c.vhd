-------------------------------------------------------------------------------
--
-- GCpad controller core
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- $Id: gcpad_full-c.vhd 41 2009-04-01 19:58:04Z arniml $
--
-------------------------------------------------------------------------------

configuration gcpad_full_struct_c0 of gcpad_full is

  for struct
    for ctrl_b : gcpad_ctrl
      use configuration work.gcpad_ctrl_rtl_c0;
    end for;

    for tx_b : gcpad_tx
      use configuration work.gcpad_tx_rtl_c0;
    end for;

    for rx_b : gcpad_rx
      use configuration work.gcpad_rx_rtl_c0;
    end for;
  end for;

end gcpad_full_struct_c0;
