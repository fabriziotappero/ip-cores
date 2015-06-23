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
--  /   /        Filename           : DDR2_Ram_Core_clk_dcm.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     :     This module generates the system clock for controller block
--                    This also generates the recapture clock, clock for the
--                    Refresh counter and also for the data path
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use UNISIM.VCOMPONENTS.all;
entity DDR2_Ram_Core_clk_dcm is
  port(
    input_clk : in  std_logic;
    rst       : in  std_logic;
    clk       : out std_logic;
    clk90     : out std_logic;
    dcm_lock  : out std_logic
    );
end DDR2_Ram_Core_clk_dcm;

architecture arc of DDR2_Ram_Core_clk_dcm is

  signal clk0dcm   : std_logic;
  signal clk90dcm  : std_logic;
  signal clk0_buf  : std_logic;
  signal clk90_buf : std_logic;
  signal gnd       : std_logic;
  signal dcm1_lock : std_logic;

begin

  gnd   <= '0';
  clk   <= clk0_buf;
  clk90 <= clk90_buf;

  DCM_INST1 : DCM
    generic map(
      DLL_FREQUENCY_MODE    => "LOW",
      DUTY_CYCLE_CORRECTION => true
      )
    port map (
      CLKIN    => input_clk,
      CLKFB    => clk0_buf,
      DSSEN    => gnd,
      PSINCDEC => gnd,
      PSEN     => gnd,
      PSCLK    => gnd,
      RST      => rst,
      CLK0     => clk0dcm,
      CLK90    => clk90dcm,
      CLK180   => open,
      CLK270   => open,
      CLK2X    => open,
      CLK2X180 => open,
      CLKDV    => open,
      CLKFX    => open,
      CLKFX180 => open,
      LOCKED   => dcm1_lock,
      PSDONE   => open,
      STATUS   => open
      );

  BUFG_CLK0 : BUFG
    port map (
      O  => clk0_buf,
      I  => clk0dcm
      );

  BUFG_CLK90 : BUFG
    port map (
      O  => clk90_buf,
      I  => clk90dcm
      );

  dcm_lock <= dcm1_lock;

end arc;
