-------------------------------------------------------------------------------
--
-- SD/MMC Bootloader
--
-- $Id: chip-full-c.vhd 77 2009-04-01 19:53:14Z arniml $
--
-------------------------------------------------------------------------------

configuration chip_full_c0 of chip is

  for full

    for spi_boot_b : spi_boot
      use configuration work.spi_boot_rtl_c0;
    end for;

  end for;

end chip_full_c0;
