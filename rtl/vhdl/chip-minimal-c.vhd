-------------------------------------------------------------------------------
--
-- SD/MMC Bootloader
--
-- $Id: chip-minimal-c.vhd 77 2009-04-01 19:53:14Z arniml $
--
-------------------------------------------------------------------------------

configuration chip_minimal_c0 of chip is

  for minimal

    for spi_boot_b : spi_boot
      use configuration work.spi_boot_rtl_c0;
    end for;

  end for;

end chip_minimal_c0;
