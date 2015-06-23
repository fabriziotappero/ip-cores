-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_infrastructure_iobs_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: The DDR memory clocks are generated here using the differential
--              buffers and the ODDR elemnts in the IOBs.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_infrastructure_iobs_0 is
  port(
    clk      : in  std_logic;
    ddr_ck   : out std_logic_vector((CLK_WIDTH - 1) downto 0);
    ddr_ck_n : out std_logic_vector((CLK_WIDTH - 1) downto 0)
    );
end MIG_infrastructure_iobs_0;

architecture arch of MIG_infrastructure_iobs_0 is


  signal ddr_ck_q   : std_logic_vector((CLK_WIDTH - 1) downto 0);
  signal vcc        : std_logic;
  signal gnd        : std_logic;

begin

  vcc <= '1';
  gnd <= '0';

  gen_ck: for ck_i in 0 to CLK_WIDTH-1 generate
    u_oddr_ck_i : ODDR
      generic map (
        srtype        => "SYNC",
        ddr_clk_edge  => "OPPOSITE_EDGE"
      )
      port map (
        q   => ddr_ck_q(ck_i),
        c   => clk,
        ce  => vcc,
        d1  => gnd,
        d2  => vcc,
        r   => gnd,
        s   => gnd
      );

    u_obuf_ck_i : OBUFDS
      port map (
        i   => ddr_ck_q(ck_i),
        o   => ddr_ck(ck_i),
        ob  => ddr_ck_n(ck_i)
      );
  end generate;

end arch;
