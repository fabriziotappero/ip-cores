-------------------------------------------------------------------------------
--
-- T400 Microcontroller Core
--
-- $Id: t400_core-c.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

configuration t400_core_struct_c0 of t400_core is

  for struct

    for clkgen_b: t400_clkgen
      use configuration work.t400_clkgen_rtl_c0;
    end for;

    for reset_b: t400_reset
      use configuration work.t400_reset_rtl_c0;
    end for;

    for pmem_ctrl_b: t400_pmem_ctrl
      use configuration work.t400_pmem_ctrl_rtl_c0;
    end for;

    for dmem_ctrl_b: t400_dmem_ctrl
      use configuration work.t400_dmem_ctrl_rtl_c0;
    end for;

    for decoder_b: t400_decoder
      use configuration work.t400_decoder_rtl_c0;
    end for;

    for skip_b: t400_skip
      use configuration work.t400_skip_rtl_c0;
    end for;

    for alu_b: t400_alu
      use configuration work.t400_alu_rtl_c0;
    end for;

    for stack_b: t400_stack
      use configuration work.t400_stack_rtl_c0;
    end for;

    for io_l_b: t400_io_l
      use configuration work.t400_io_l_rtl_c0;
    end for;

    for io_d_b: t400_io_d
      use configuration work.t400_io_d_rtl_c0;
    end for;

    for io_g_b: t400_io_g
      use configuration work.t400_io_g_rtl_c0;
    end for;

    for use_in
      for io_in_b: t400_io_in
        use configuration work.t400_io_in_rtl_c0;
      end for;
    end for;

    for sio_b: t400_sio
      use configuration work.t400_sio_rtl_c0;
    end for;

    for use_tim
      for timer_b: t400_timer
        use configuration work.t400_timer_rtl_c0;
      end for;
    end for;

  end for;

end t400_core_struct_c0;
