-------------------------------------------------------------------------------
--
-- SD/MMC Bootloader
--
-- $Id: tb-c.vhd 77 2009-04-01 19:53:14Z arniml $
--
-------------------------------------------------------------------------------

configuration tb_behav_c0 of tb is

  for behav

    for tb_elem_full_b : tb_elem
      use configuration work.tb_elem_behav_full;
    end for;

    for tb_elem_mmc_b : tb_elem
      use configuration work.tb_elem_behav_mmc;
    end for;

    for tb_elem_sd_b : tb_elem
      use configuration work.tb_elem_behav_sd;
    end for;

    for tb_elem_minimal_b : tb_elem
      use configuration work.tb_elem_behav_minimal;
    end for;

  end for;

end tb_behav_c0;
