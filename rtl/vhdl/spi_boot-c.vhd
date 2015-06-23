-------------------------------------------------------------------------------
--
-- SD/MMC Bootloader
--
-- $Id: spi_boot-c.vhd 77 2009-04-01 19:53:14Z arniml $
--
-------------------------------------------------------------------------------

configuration spi_boot_rtl_c0 of spi_boot is

  for rtl

    for img_cnt
      for img_cnt_b : spi_counter
        use configuration work.spi_counter_rtl_c0;
      end for;
    end for;

    for mmc_cnt
      for mmc_cnt_b : spi_counter
        use configuration work.spi_counter_rtl_c0;
      end for;
    end for;

  end for;

end spi_boot_rtl_c0;
