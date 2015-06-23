--*****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2005, 2006, 2007 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version	    : 3.6.1
--  \   \        Application	    : MIG
--  /   /        Filename           : DDR2_Ram_Core_tap_dly.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     :This module generates a 32 bit tap delay register used by the
--              cal_ctl module to find out the phase transitions.
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;


entity DDR2_Ram_Core_tap_dly is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    tapin : in  std_logic;
    flop2 : out std_logic_vector(31 downto 0)
    );
end DDR2_Ram_Core_tap_dly;

architecture arc_tap_dly of DDR2_Ram_Core_tap_dly is

  signal tap        : std_logic_vector(31 downto 0);
  signal flop1      : std_logic_vector(31 downto 0);
  signal high       : std_logic;
  signal low        : std_logic;
  signal flop2_xnor : std_logic_vector(30 downto 0);
  signal reset_r    : std_logic;

  attribute syn_preserve : boolean;

  attribute syn_preserve of tap   : signal is true;
  attribute syn_preserve of flop1 : signal is true;    


begin

  process(clk)
  begin
    if(clk'event and clk='1') then
      reset_r <= reset;
    end if;
  end process;

  high <= '1';
  low  <= '0';

  l0 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tapin,
      I2 => low,
      I3 => high,
      O  => tap(0)
      );

  l1 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(0),
      I2 => low,
      I3 => high,
      O  => tap(1)
      );
  l2 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(1),
      I2 => low,
      I3 => high,
      O  => tap(2)
      );
  l3 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(2),
      I2 => low,
      I3 => high,
      O  => tap(3)
      );
  l4 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(3),
      I2 => low,
      I3 => high,
      O  => tap(4)
      );
  l5 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(4),
      I2 => low,
      I3 => high,
      O  => tap(5)
      );
  l6 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(5),
      I2 => low,
      I3 => high,
      O  => tap(6)
      );
  l7 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(6),
      I2 => low,
      I3 => high,
      O  => tap(7)
      );
  l8 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(7),
      I2 => low,
      I3 => high,
      O  => tap(8)
      );
  l9 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(8),
      I2 => low,
      I3 => high,
      O  => tap(9)
      );
  l10 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(9),
      I2 => low,
      I3 => high,
      O  => tap(10)
      );
  l11 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(10),
      I2 => low,
      I3 => high,
      O  => tap(11)
      );
  l12 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(11),
      I2 => low,
      I3 => high,
      O  => tap(12)
      );
  l13 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(12),
      I2 => low,
      I3 => high,
      O  => tap(13)
      );
  l14 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(13),
      I2 => low,
      I3 => high,
      O  => tap(14)
      );
  l15 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(14),
      I2 => low,
      I3 => high,
      O  => tap(15)
      );
  l16 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(15),
      I2 => low,
      I3 => high,
      O  => tap(16)
      );
  l17 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(16),
      I2 => low,
      I3 => high,
      O  => tap(17)
      );
  l18 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(17),
      I2 => low,
      I3 => high,
      O  => tap(18)
      );
  l19 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(18),
      I2 => low,
      I3 => high,
      O  => tap(19)
      );
  l20 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(19),
      I2 => low,
      I3 => high,
      O  => tap(20)
      );
  l21 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(20),
      I2 => low,
      I3 => high,
      O  => tap(21)
      );
  l22 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(21),
      I2 => low,
      I3 => high,
      O  => tap(22)
      );
  l23 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(22),
      I2 => low,
      I3 => high,
      O  => tap(23)
      );
  l24 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(23),
      I2 => low,
      I3 => high,
      O  => tap(24)
      );
  l25 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(24),
      I2 => low,
      I3 => high,
      O  => tap(25)
      );
  l26 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(25),
      I2 => low,
      I3 => high,
      O  => tap(26)
      );
  l27 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(26),
      I2 => low,
      I3 => high,
      O  => tap(27)
      );
  l28 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(27),
      I2 => low,
      I3 => high,
      O  => tap(28)
      );
  l29 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(28),
      I2 => low,
      I3 => high,
      O  => tap(29)
      );
  l30 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(29),
      I2 => low,
      I3 => high,
      O  => tap(30)
      );
  l31 : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => high,
      I1 => tap(30),
      I2 => low,
      I3 => high,
      O  => tap(31)
      );

  gen_tap1 : for tap1_i in 0 to 31 generate
    r : FDR port map (
      Q => flop1(tap1_i),
      C => clk,
      D => tap(tap1_i),
      R => reset_r
      );
  end generate;
  
  gen_asgn : for asgn_i in 0 to 30 generate
    flop2_xnor(asgn_i)  <= flop1(asgn_i) xnor flop1(asgn_i+1);
  end generate;

  gen_tap2 : for tap2_i in 0 to 30 generate
    u : FDR port map (
      Q => flop2(tap2_i),
      C => clk,
      D => flop2_xnor(tap2_i),
      R => reset_r
      );
  end generate;
  
  u31 : FDR
    port map (
      Q => flop2(31),
      C => clk,
      D => flop1(31),
      R => reset_r
      );
  
end arc_tap_dly;
