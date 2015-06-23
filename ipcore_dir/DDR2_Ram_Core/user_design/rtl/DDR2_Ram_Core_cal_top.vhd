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
--  /   /        Filename           : DDR2_Ram_Core_cal_to.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module has the instantiations cal_ctl and tap_dly.
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity DDR2_Ram_Core_cal_top is
  port(
    clk                    : in  std_logic;
    clk0dcmlock            : in  std_logic;
    reset                  : in  std_logic;
    tapfordqs              : out std_logic_vector(4 downto 0);
    -- debug signals
    dbg_phase_cnt          : out std_logic_vector(4 downto 0);
    dbg_cnt                : out std_logic_vector(5 downto 0);
    dbg_trans_onedtct      : out std_logic;
    dbg_trans_twodtct      : out std_logic;
    dbg_enb_trans_two_dtct : out std_logic
    );
end DDR2_Ram_Core_cal_top;

architecture arc of DDR2_Ram_Core_cal_top is

  ATTRIBUTE X_CORE_INFO          : STRING;
  ATTRIBUTE CORE_GENERATION_INFO : STRING;

  ATTRIBUTE X_CORE_INFO of arc : ARCHITECTURE  IS "mig_v3_61_ddr2_sp3, Coregen 12.4";
  ATTRIBUTE CORE_GENERATION_INFO of arc : ARCHITECTURE IS "ddr2_sp3,mig_v3_61,{component_name=ddr2_sp3, data_width=16, memory_width=8, clk_width=1, bank_address=2, row_address=13, column_address=10, no_of_cs=1, cke_width=1, registered=0, data_mask=1, mask_enable=1, load_mode_register=0010100110010, ext_load_mode_register=0000000000000, language=VHDL, synthesis_tool=ISE, interface_type=DDR2_SDRAM, no_of_controllers=1}";

  component DDR2_Ram_Core_cal_ctl
    port (
      clk                    : in  std_logic;
      reset                  : in  std_logic;
      flop2                  : in  std_logic_vector(31 downto 0);
      tapfordqs              : out std_logic_vector(4 downto 0);
      dbg_phase_cnt          : out std_logic_vector(4 downto 0);
      dbg_cnt                : out std_logic_vector(5 downto 0);
      dbg_trans_onedtct      : out std_logic;
      dbg_trans_twodtct      : out std_logic;
      dbg_enb_trans_two_dtct : out std_logic
      );
  end component;

  component DDR2_Ram_Core_tap_dly
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      tapin : in  std_logic;
      flop2 : out std_logic_vector(31 downto 0)
      );
  end component;

  signal fpga_rst  : std_logic;
  signal flop2_val : std_logic_vector(31 downto 0);

begin

  fpga_rst <= (not reset) or (not clk0dcmlock);

  cal_ctl0 : DDR2_Ram_Core_cal_ctl
    port map(
      clk                    => clk,
      reset                  => fpga_rst,
      flop2                  => flop2_val,
      tapfordqs              => tapfordqs,
      dbg_phase_cnt          => dbg_phase_cnt,
      dbg_cnt                => dbg_cnt,
      dbg_trans_onedtct      => dbg_trans_onedtct,
      dbg_trans_twodtct      => dbg_trans_twodtct,
      dbg_enb_trans_two_dtct => dbg_enb_trans_two_dtct
      );

  tap_dly0 : DDR2_Ram_Core_tap_dly
    port map (
      clk                    => clk,
      reset                  => fpga_rst,
      tapin		     => clk,
      flop2		     => flop2_val
      );

end arc;
