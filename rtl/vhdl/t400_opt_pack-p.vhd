-------------------------------------------------------------------------------
--
-- $Id: t400_opt_pack-p.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

package t400_opt_pack is

  -- Chip type option ---------------------------------------------------------
  constant t400_opt_type_420_c     : integer := 0;
  constant t400_opt_type_421_c     : integer := 1;
  constant t400_opt_type_410_c     : integer := 2;

  -- Clock divider option -----------------------------------------------------
  constant t400_opt_ck_div_32_c    : integer := 3;
  constant t400_opt_ck_div_16_c    : integer := 2;
  constant t400_opt_ck_div_8_c     : integer := 1;
  constant t400_opt_ck_div_4_c     : integer := 0;

  -- CKO pin function option --------------------------------------------------
  constant t400_opt_cko_crystal_c  : integer := 0;
  constant t400_opt_cko_gpi_c      : integer := 1;

  -- Output type option -------------------------------------------------------
  constant t400_opt_out_type_std_c : integer := 0;
  constant t400_opt_out_type_od_c  : integer := 1;
  constant t400_opt_out_type_led_c : integer := 2;
  constant t400_opt_out_type_pp_c  : integer := 3;

  -- Microbus option ----------------------------------------------------------
  constant t400_opt_no_microbus_c  : integer := 0;
  constant t400_opt_microbus_c     : integer := 1;

end t400_opt_pack;
