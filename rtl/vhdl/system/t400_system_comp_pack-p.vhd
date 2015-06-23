-------------------------------------------------------------------------------
--
-- $Id: t400_system_comp_pack-p.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t400_opt_pack.all;

package t400_system_comp_pack is

  component t410_notri
    generic (
      opt_ck_div_g         : integer := t400_opt_ck_div_16_c;
      opt_cko_g            : integer := t400_opt_cko_crystal_c;
      opt_l_out_type_7_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_6_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_5_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_4_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_so_output_type_g : integer := t400_opt_out_type_std_c;
      opt_sk_output_type_g : integer := t400_opt_out_type_std_c
    );
    port (
      ck_i      : in  std_logic;
      ck_en_i   : in  std_logic;
      reset_n_i : in  std_logic;
      cko_i     : in  std_logic;
      io_l_i    : in  std_logic_vector(7 downto 0);
      io_l_o    : out std_logic_vector(7 downto 0);
      io_l_en_o : out std_logic_vector(7 downto 0);
      io_d_o    : out std_logic_vector(3 downto 0);
      io_d_en_o : out std_logic_vector(3 downto 0);
      io_g_i    : in  std_logic_vector(3 downto 0);
      io_g_o    : out std_logic_vector(3 downto 0);
      io_g_en_o : out std_logic_vector(3 downto 0);
      si_i      : in  std_logic;
      so_o      : out std_logic;
      so_en_o   : out std_logic;
      sk_o      : out std_logic;
      sk_en_o   : out std_logic
    );
  end component;

  component t410
    generic (
      opt_ck_div_g         : integer := t400_opt_ck_div_16_c;
      opt_l_out_type_7_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_6_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_5_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_4_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_so_output_type_g : integer := t400_opt_out_type_std_c;
      opt_sk_output_type_g : integer := t400_opt_out_type_std_c
    );
    port (
      ck_i      : in    std_logic;
      ck_en_i   : in    std_logic;
      reset_n_i : in    std_logic;
      io_l_b    : inout std_logic_vector(7 downto 0);
      io_d_o    : out   std_logic_vector(3 downto 0);
      io_g_b    : inout std_logic_vector(3 downto 0);
      si_i      : in    std_logic;
      so_o      : out   std_logic;
      sk_o      : out   std_logic
    );
  end component;

  component t411
    generic (
      opt_ck_div_g         : integer := t400_opt_ck_div_16_c;
      opt_l_out_type_7_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_6_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_5_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_4_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_so_output_type_g : integer := t400_opt_out_type_std_c;
      opt_sk_output_type_g : integer := t400_opt_out_type_std_c
    );
    port (
      ck_i      : in    std_logic;
      ck_en_i   : in    std_logic;
      reset_n_i : in    std_logic;
      si_i      : in    std_logic;
      so_o      : out   std_logic;
      sk_o      : out   std_logic;
      io_l_b    : inout std_logic_vector(7 downto 0);
      io_d_o    : out   std_logic_vector(1 downto 0);
      io_g_b    : inout std_logic_vector(2 downto 0)
    );
  end component;

  component t420_notri
    generic (
      opt_type_g           : integer := t400_opt_type_420_c;
      opt_ck_div_g         : integer := t400_opt_ck_div_16_c;
      opt_cko_g            : integer := t400_opt_cko_crystal_c;
      opt_l_out_type_7_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_6_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_5_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_4_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_microbus_g       : integer := t400_opt_no_microbus_c;
      opt_d_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_so_output_type_g : integer := t400_opt_out_type_std_c;
      opt_sk_output_type_g : integer := t400_opt_out_type_std_c
    );
    port (
      ck_i      : in  std_logic;
      ck_en_i   : in  std_logic;
      reset_n_i : in  std_logic;
      cko_i     : in  std_logic;
      io_l_i    : in  std_logic_vector(7 downto 0);
      io_l_o    : out std_logic_vector(7 downto 0);
      io_l_en_o : out std_logic_vector(7 downto 0);
      io_d_o    : out std_logic_vector(3 downto 0);
      io_d_en_o : out std_logic_vector(3 downto 0);
      io_g_i    : in  std_logic_vector(3 downto 0);
      io_g_o    : out std_logic_vector(3 downto 0);
      io_g_en_o : out std_logic_vector(3 downto 0);
      io_in_i   : in  std_logic_vector(3 downto 0);
      si_i      : in  std_logic;
      so_o      : out std_logic;
      so_en_o   : out std_logic;
      sk_o      : out std_logic;
      sk_en_o   : out std_logic
    );
  end component;

  component t420
    generic (
      opt_ck_div_g         : integer := t400_opt_ck_div_16_c;
      opt_cko_g            : integer := t400_opt_cko_crystal_c;
      opt_l_out_type_7_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_6_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_5_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_4_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_microbus_g       : integer := t400_opt_no_microbus_c;
      opt_d_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_so_output_type_g : integer := t400_opt_out_type_std_c;
      opt_sk_output_type_g : integer := t400_opt_out_type_std_c
    );
    port (
      ck_i      : in    std_logic;
      ck_en_i   : in    std_logic;
      reset_n_i : in    std_logic;
      cko_i     : in    std_logic;
      io_l_b    : inout std_logic_vector(7 downto 0);
      io_d_o    : out   std_logic_vector(3 downto 0);
      io_g_b    : inout std_logic_vector(3 downto 0);
      io_in_i   : in    std_logic_vector(3 downto 0);
      si_i      : in    std_logic;
      so_o      : out   std_logic;
      sk_o      : out   std_logic
    );
  end component;

  component t421
    generic (
      opt_ck_div_g         : integer := t400_opt_ck_div_8_c;
      opt_cko_g            : integer := t400_opt_cko_crystal_c;
      opt_l_out_type_7_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_6_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_5_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_4_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_l_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_d_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_3_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_2_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_1_g   : integer := t400_opt_out_type_std_c;
      opt_g_out_type_0_g   : integer := t400_opt_out_type_std_c;
      opt_so_output_type_g : integer := t400_opt_out_type_std_c;
      opt_sk_output_type_g : integer := t400_opt_out_type_std_c
    );
    port (
      ck_i      : in    std_logic;
      ck_en_i   : in    std_logic;
      reset_n_i : in    std_logic;
      cko_i     : in    std_logic;
      io_l_b    : inout std_logic_vector(7 downto 0);
      io_d_o    : out   std_logic_vector(3 downto 0);
      io_g_b    : inout std_logic_vector(3 downto 0);
      si_i      : in    std_logic;
      so_o      : out   std_logic;
      sk_o      : out   std_logic
    );
  end component;

end t400_system_comp_pack;
