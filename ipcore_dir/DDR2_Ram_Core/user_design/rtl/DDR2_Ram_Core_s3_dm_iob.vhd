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
--  /   /        Filename           : DDR2_Ram_Core_s3_dm_iob.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module instantiates DDR IOB output flip-flops, and an
--               output buffer for the data mask bits.
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity DDR2_Ram_Core_s3_dm_iob is
  port (
    ddr_dm       : out std_logic;   --Data mask output
    mask_falling : in std_logic;    --Mask output on falling edge
    mask_rising  : in std_logic;    --Mask output on rising edge
    clk90        : in std_logic
    );
end DDR2_Ram_Core_s3_dm_iob;

architecture arc of DDR2_Ram_Core_s3_dm_iob is

--***********************************************************************\
-- Internal signal declaration
--***********************************************************************/

  signal mask_o : std_logic;
  signal gnd    : std_logic;
  signal vcc    : std_logic;
  signal clk270 : std_logic;
begin

  gnd    <= '0';
  vcc    <= '1';
  clk270 <= not clk90;

-- Data Mask Output during a write command

  DDR_DM0_OUT : FDDRRSE
    port map (
      Q  => mask_o,
      C0 => clk270,
      C1 => clk90,
      CE => vcc,
      D0 => mask_rising,
      D1 => mask_falling,
      R  => gnd,
      S  => gnd
      );

  DM1_OBUF : OBUF
    port map (
      I => mask_o,
      O => ddr_dm
      );
  
end arc;
