-------------------------------------------------------------------------------
--
-- $Id: t8243_comp_pack-p.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package t8243_comp_pack is

  component t8243_core
    generic (
      clk_fall_level_g : integer := 0
    );
    port (
      -- System Interface -----------------------------------------------------
      clk_i         : in  std_logic;
      clk_rise_en_i : in  std_logic;
      clk_fall_en_i : in  std_logic;
      reset_n_i     : in  std_logic;
      -- Control Interface ----------------------------------------------------
      cs_n_i        : in  std_logic;
      prog_n_i      : in  std_logic;
      -- Port 2 Interface -----------------------------------------------------
      p2_i          : in  std_logic_vector(3 downto 0);
      p2_o          : out std_logic_vector(3 downto 0);
      p2_en_o       : out std_logic;
      -- Port 4 Interface -----------------------------------------------------
      p4_i          : in  std_logic_vector(3 downto 0);
      p4_o          : out std_logic_vector(3 downto 0);
      p4_en_o       : out std_logic;
      -- Port 5 Interface -----------------------------------------------------
      p5_i          : in  std_logic_vector(3 downto 0);
      p5_o          : out std_logic_vector(3 downto 0);
      p5_en_o       : out std_logic;
      -- Port 6 Interface -----------------------------------------------------
      p6_i          : in  std_logic_vector(3 downto 0);
      p6_o          : out std_logic_vector(3 downto 0);
      p6_en_o       : out std_logic;
      -- Port 7 Interface -----------------------------------------------------
      p7_i          : in  std_logic_vector(3 downto 0);
      p7_o          : out std_logic_vector(3 downto 0);
      p7_en_o       : out std_logic
    );
  end component;

  component t8243_sync_notri
    port (
      -- System Interface -----------------------------------------------------
      clk_i     : in  std_logic;
      clk_en_i  : in  std_logic;
      reset_n_i : in  std_logic;
      -- Control Interface ----------------------------------------------------
      cs_n_i    : in  std_logic;
      prog_n_i  : in  std_logic;
      -- Port 2 Interface -----------------------------------------------------
      p2_i      : in  std_logic_vector(3 downto 0);
      p2_o      : out std_logic_vector(3 downto 0);
      p2_en_o   : out std_logic;
      -- Port 4 Interface -----------------------------------------------------
      p4_i      : in  std_logic_vector(3 downto 0);
      p4_o      : out std_logic_vector(3 downto 0);
      p4_en_o   : out std_logic;
      -- Port 5 Interface -----------------------------------------------------
      p5_i      : in  std_logic_vector(3 downto 0);
      p5_o      : out std_logic_vector(3 downto 0);
      p5_en_o   : out std_logic;
      -- Port 6 Interface -----------------------------------------------------
      p6_i      : in  std_logic_vector(3 downto 0);
      p6_o      : out std_logic_vector(3 downto 0);
      p6_en_o   : out std_logic;
      -- Port 7 Interface -----------------------------------------------------
      p7_i      : in  std_logic_vector(3 downto 0);
      p7_o      : out std_logic_vector(3 downto 0);
      p7_en_o   : out std_logic
    );
  end component;

  component t8243_async_notri
    port (
      -- System Interface -----------------------------------------------------
      reset_n_i : in  std_logic;
      -- Control Interface ----------------------------------------------------
      cs_n_i    : in  std_logic;
      prog_n_i  : in  std_logic;
      -- Port 2 Interface -----------------------------------------------------
      p2_i      : in  std_logic_vector(3 downto 0);
      p2_o      : out std_logic_vector(3 downto 0);
      p2_en_o   : out std_logic;
      -- Port 4 Interface -----------------------------------------------------
      p4_i      : in  std_logic_vector(3 downto 0);
      p4_o      : out std_logic_vector(3 downto 0);
      p4_en_o   : out std_logic;
      -- Port 5 Interface -----------------------------------------------------
      p5_i      : in  std_logic_vector(3 downto 0);
      p5_o      : out std_logic_vector(3 downto 0);
      p5_en_o   : out std_logic;
      -- Port 6 Interface -----------------------------------------------------
      p6_i      : in  std_logic_vector(3 downto 0);
      p6_o      : out std_logic_vector(3 downto 0);
      p6_en_o   : out std_logic;
      -- Port 7 Interface -----------------------------------------------------
      p7_i      : in  std_logic_vector(3 downto 0);
      p7_o      : out std_logic_vector(3 downto 0);
      p7_en_o   : out std_logic
    );
  end component;

  component t8243
    port (
      -- Control Interface ----------------------------------------------------
      cs_n_i   : in    std_logic;
      prog_n_i : in    std_logic;
      -- Port 2 Interface -----------------------------------------------------
      p2_b     : inout std_logic_vector(3 downto 0);
      -- Port 4 Interface -----------------------------------------------------
      p4_b     : inout std_logic_vector(3 downto 0);
      -- Port 5 Interface -----------------------------------------------------
      p5_b     : inout std_logic_vector(3 downto 0);
      -- Port 6 Interface -----------------------------------------------------
      p6_b     : inout std_logic_vector(3 downto 0);
      -- Port 7 Interface -----------------------------------------------------
      p7_b     : inout std_logic_vector(3 downto 0)
    );
  end component;

end;
