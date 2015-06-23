-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_RAM_D_.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Contains the distributed RAM which stores IOB output data that
--              is read from the memory.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_RAM_D_0 is
  port(
    dpo   : out std_logic_vector(MEMORY_WIDTH - 1 downto 0);
    a0    : in  std_logic;
    a1    : in  std_logic;
    a2    : in  std_logic;
    a3    : in  std_logic;
    d     : in  std_logic_vector(MEMORY_WIDTH - 1 downto 0);
    dpra0 : in  std_logic;
    dpra1 : in  std_logic;
    dpra2 : in  std_logic;
    dpra3 : in  std_logic;
    wclk  : in  std_logic;
    we    : in  std_logic
    );
end MIG_RAM_D_0;

architecture arch of MIG_RAM_D_0 is

begin

  gen_ram_d: for ram_d_i in 0 to MEMORY_WIDTH-1 generate
    RAM16X1D_inst: RAM16X1D
    port map (
          DPO   => dpo(ram_d_i),
          SPO   => open,
          A0    => a0,
          A1    => a1,
          A2    => a2,
          A3    => a3,
          D     => d(ram_d_i),
          DPRA0 => dpra0,
          DPRA1 => dpra1,
          DPRA2 => dpra2,
          DPRA3 => dpra3,
          WCLK  => wclk,
          WE    => we
        );
  end generate;
  

end arch;
