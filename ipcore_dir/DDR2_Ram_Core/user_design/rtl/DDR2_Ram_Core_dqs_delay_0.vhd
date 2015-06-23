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
--  /   /        Filename           : DDR2_Ram_Core_dqs_delay_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module generate the delay in the dqs signal.
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity DDR2_Ram_Core_dqs_delay is
  port (
    clk_in  : in  std_logic;
    sel_in  : in  std_logic_vector(4 downto 0);
    clk_out : out std_logic
    );
end DDR2_Ram_Core_dqs_delay;

architecture arc_dqs_delay of DDR2_Ram_Core_dqs_delay is

  signal delay1 : std_logic;
  signal delay2 : std_logic;
  signal delay3 : std_logic;
  signal delay4 : std_logic;
  signal delay5 : std_logic;
  signal high   : std_logic;

  attribute syn_preserve  : boolean;
  
  attribute syn_preserve of one   : label is true;
  attribute syn_preserve of two   : label is true;
  attribute syn_preserve of three : label is true;
  attribute syn_preserve of four  : label is true;
  attribute syn_preserve of five  : label is true;
  attribute syn_preserve of six   : label is true;

begin

  high <= '1';

  one : LUT4 generic map (INIT => x"f3c0")
    port map (
      I0  => high,
      I1 => sel_in(4),
      I2 => delay5,
      I3 => clk_in,
      O  => clk_out
      );
  
  two : LUT4 generic map (INIT => x"ee22")
    port map (
      I0 => clk_in,
      I1 => sel_in(2),
      I2 => high,
      I3 => delay3,
      O  => delay4
      );

  three : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => clk_in,
      I1 => sel_in(0),
      I2 => delay1,
      I3 => high,
      O  => delay2
      );

  four : LUT4 generic map (INIT => x"ff00")
    port map (
      I0 => high,
      I1 => high,
      I2 => high,
      I3 => clk_in,
      O  => delay1
      );

  five : LUT4 generic map (INIT => x"f3c0")
    port map (
      I0 => high,
      I1 => sel_in(3),
      I2 => delay4,
      I3 => clk_in,
      O  => delay5
      );

  six : LUT4 generic map (INIT => x"e2e2")
    port map (
      I0 => clk_in,
      I1 => sel_in(1),
      I2 => delay2,
      I3 => high,
      O  => delay3
      );

end arc_dqs_delay;
