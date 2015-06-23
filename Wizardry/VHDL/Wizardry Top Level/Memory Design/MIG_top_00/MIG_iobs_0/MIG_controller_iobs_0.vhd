-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_controller_iobs_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Puts the memory control signals like address, bank address, row
--              address strobe, column address strobe, write enable and clock
--              enable in the IOBs.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_controller_iobs_0 is
  port (
    ctrl_ddr_address : in  std_logic_vector((ROW_ADDRESS - 1) downto 0);
    ctrl_ddr_ba      : in  std_logic_vector((BANK_ADDRESS - 1) downto 0);
    ctrl_ddr_ras_l   : in  std_logic;
    ctrl_ddr_cas_l   : in  std_logic;
    ctrl_ddr_we_l    : in  std_logic;
    ctrl_ddr_cs_l    : in  std_logic;
    ctrl_ddr_cke     : in  std_logic;
    ddr_address      : out std_logic_vector((ROW_ADDRESS - 1) downto 0);
    ddr_ba           : out std_logic_vector((BANK_ADDRESS - 1) downto 0);
    ddr_ras_l        : out std_logic;
    ddr_cas_l        : out std_logic;
    ddr_we_l         : out std_logic;
    ddr_cke          : out std_logic;
    ddr_cs_l         : out std_logic
    );
end MIG_controller_iobs_0;

architecture arch of MIG_controller_iobs_0 is
  attribute syn_useioff : boolean ;

begin

  r0 : OBUF
    port map(
      I => ctrl_ddr_ras_l,
      O => ddr_ras_l
      );

  r1 : OBUF
    port map(
      I => ctrl_ddr_cas_l,
      O => ddr_cas_l
      );

  r2 : OBUF
    port map(
      I => ctrl_ddr_we_l,
      O => ddr_we_l
      );


  OBUF_cs0 : OBUF
    port map(
      I => ctrl_ddr_cs_l,
      O => ddr_cs_l
      );


  OBUF_cke0 : OBUF
    port map(
      I => ctrl_ddr_cke,
      O => ddr_cke
      );


  gen_row: for row_i in 0 to ROW_ADDRESS-1 generate
    attribute syn_useioff of obuf_r : label is true;
  begin
    obuf_r: OBUF
    port map(
          I => ctrl_ddr_address(row_i),
          O => ddr_address(row_i)
          );
  end generate;

  gen_bank: for bank_i in 0 to BANK_ADDRESS-1 generate
    attribute syn_useioff of obuf_bank : label is true;
  begin
    obuf_bank: OBUF
    port map(
          I => ctrl_ddr_ba(bank_i),
          O => ddr_ba(bank_i)
          );
  end generate;

end arch;
