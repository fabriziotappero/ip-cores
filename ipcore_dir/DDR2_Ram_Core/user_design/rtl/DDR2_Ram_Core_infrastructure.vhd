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
--  /   /        Filename           : DDR2_Ram_Core_infrastructure.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     :
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;


entity DDR2_Ram_Core_infrastructure is
  port(
    delay_sel_val1_val : out std_logic_vector(4 downto 0);
    delay_sel_val      : in  std_logic_vector(4 downto 0);
    rst_calib1         : in  std_logic;
    clk_int            : in  std_logic;
    -- debug signals
    dbg_delay_sel      : out std_logic_vector(4 downto 0);
    dbg_rst_calib      : out std_logic
    );
end DDR2_Ram_Core_infrastructure;

architecture arc of DDR2_Ram_Core_infrastructure is
  
  signal delay_sel_val1 : std_logic_vector(4 downto 0);
  signal rst_calib1_r1  : std_logic;
  signal rst_calib1_r2  : std_logic;
  
begin

  delay_sel_val1_val <= delay_sel_val1;
  dbg_delay_sel      <= delay_sel_val1;
  dbg_rst_calib      <= rst_calib1_r2;

  process(clk_int)
  begin
    if clk_int 'event and clk_int = '0' then
      rst_calib1_r1    <= rst_calib1;
    end if;
  end process;

  process(clk_int)
  begin
    if clk_int 'event and clk_int = '1' then
      rst_calib1_r2    <= rst_calib1_r1;
    end if;
  end process;

  process(clk_int)
  begin
    if clk_int 'event and clk_int = '1' then
      if (rst_calib1_r2 = '0') then
        delay_sel_val1 <= delay_sel_val;
      else
        delay_sel_val1 <= delay_sel_val1;
      end if;
    end if;
  end process;

end arc;
