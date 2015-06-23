-------------------------------------------------------------------------------
--
-- SD/MMC Bootloader
--
-- $Id: tb_rl-c.vhd 77 2009-04-01 19:53:14Z arniml $
--
-------------------------------------------------------------------------------

configuration tb_rl_behav_c0 of tb_rl is

  for behav

    for dut_b : chip
      use configuration work.chip_full_c0;
    end for;

    for card_b : card
      use configuration work.card_behav_c0;
    end for;

    for rl_b : ram_loader
      use configuration work.ram_loader_rtl_c0;
    end for;

  end for;

end tb_rl_behav_c0;
