-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_idelay_ctrl.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Instantaites the IDELAYCTRL primitive of the Virtex4 device
--              which continously calibrates the IDELAY elements in the region
--              in case of varying operating conditions. It takes a 200MHz
--              clock as an input.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_idelay_ctrl is
  port(
    clk200     : in  std_logic;
    reset      : in  std_logic;
    rdy_status : out std_logic
    );
end MIG_idelay_ctrl;

architecture arch of MIG_idelay_ctrl is

begin

  idelayctrl0 : IDELAYCTRL
    port map (
      RDY    => rdy_status,
      REFCLK => clk200,
      RST    => reset
      );

end arch;
