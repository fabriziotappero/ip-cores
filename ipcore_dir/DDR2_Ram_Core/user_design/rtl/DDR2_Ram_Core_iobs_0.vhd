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
--  /   /        Filename           : DDR2_Ram_Core_iobs_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module has the instantiations infrastructure_iobs,
--                data_path_iobs and controller_iobs modules.
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.DDR2_Ram_Core_parameters_0.all;


library UNISIM;
use UNISIM.VCOMPONENTS.all;


entity DDR2_Ram_Core_iobs_0 is
  port(
    clk                : in    std_logic;
    clk90              : in    std_logic;
    ddr_rasb_cntrl     : in    std_logic;
    ddr_casb_cntrl     : in    std_logic;
    ddr_web_cntrl      : in    std_logic;
    ddr_cke_cntrl      : in    std_logic;
    ddr_csb_cntrl      : in    std_logic;
    ddr_address_cntrl  : in    std_logic_vector((ROW_ADDRESS -1) downto 0);
    ddr_ba_cntrl       : in    std_logic_vector((BANK_ADDRESS -1) downto 0);
    ddr_odt_cntrl      : in std_logic;
    rst_dqs_div_int    : in std_logic;
    dqs_reset          : in std_logic;
    dqs_enable         : in std_logic;
    ddr_dqs            : inout std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    ddr_dqs_n         : inout std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
 
    ddr_dq             : inout std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_falling : in    std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_rising  : in    std_logic_vector((DATA_WIDTH-1) downto 0);
    write_en_val       : in    std_logic;
    data_mask_f        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    data_mask_r        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    ddr_odt            : out   std_logic;
    ddr2_ck            : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
    ddr2_ck_n          : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
    ddr_rasb           : out   std_logic;
    ddr_casb           : out   std_logic;
    ddr_web            : out   std_logic;
    ddr_ba             : out   std_logic_vector((BANK_ADDRESS -1) downto 0);
    ddr_address        : out   std_logic_vector((ROW_ADDRESS -1) downto 0);
    ddr_cke            : out   std_logic;
    ddr_csb            : out   std_logic;
    rst_dqs_div        : out   std_logic;
    rst_dqs_div_in     : in    std_logic;
    rst_dqs_div_out    : out   std_logic;
    dqs_int_delay_in   : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    ddr_dm             : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    dq                 : out   std_logic_vector((DATA_WIDTH-1) downto 0)
    );
end DDR2_Ram_Core_iobs_0;


architecture arc of DDR2_Ram_Core_iobs_0 is

  ATTRIBUTE X_CORE_INFO          : STRING;
  ATTRIBUTE CORE_GENERATION_INFO : STRING;

  ATTRIBUTE X_CORE_INFO of arc : ARCHITECTURE  IS "mig_v3_61_ddr2_sp3, Coregen 12.4";
  ATTRIBUTE CORE_GENERATION_INFO of arc : ARCHITECTURE IS "ddr2_sp3,mig_v3_61,{component_name=ddr2_sp3, data_width=16, memory_width=8, clk_width=1, bank_address=2, row_address=13, column_address=10, no_of_cs=1, cke_width=1, registered=0, data_mask=1, mask_enable=1, load_mode_register=0010100110010, ext_load_mode_register=0000000000000, language=VHDL, synthesis_tool=ISE, interface_type=DDR2_SDRAM, no_of_controllers=1}";

  component DDR2_Ram_Core_infrastructure_iobs_0
    port(
      ddr2_ck   : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
      ddr2_ck_n : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
      clk0  : in std_logic
      );
  end component;

  component DDR2_Ram_Core_controller_iobs_0
    port(
      clk0              : in  std_logic;
      ddr_rasb_cntrl    : in  std_logic;
      ddr_casb_cntrl    : in  std_logic;
      ddr_web_cntrl     : in  std_logic;
      ddr_cke_cntrl     : in  std_logic;
      ddr_csb_cntrl     : in  std_logic;
      ddr_address_cntrl : in  std_logic_vector((ROW_ADDRESS -1) downto 0);
      ddr_ba_cntrl      : in  std_logic_vector((BANK_ADDRESS -1) downto 0);
      ddr_odt_cntrl     : in  std_logic;
      rst_dqs_div_int   : in  std_logic;
      ddr_rasb          : out std_logic;
      ddr_casb          : out std_logic;
      ddr_web           : out std_logic;
      ddr_ba            : out std_logic_vector((BANK_ADDRESS -1) downto 0);
      ddr_address       : out std_logic_vector((ROW_ADDRESS -1) downto 0);
      ddr_cke           : out std_logic;
      ddr_csb           : out std_logic;
      ddr_ODT           : out std_logic;
      rst_dqs_div       : out std_logic;
      rst_dqs_div_in    : in  std_logic;
      rst_dqs_div_out   : out std_logic
      );
  end component;

  component DDR2_Ram_Core_data_path_iobs_0
    port(
      clk                : in    std_logic;
      clk90              : in    std_logic;
      dqs_reset          : in    std_logic;
      dqs_enable         : in    std_logic;
      ddr_dq             : inout std_logic_vector((DATA_WIDTH-1) downto 0);
      ddr_dqs            : inout std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    ddr_dqs_n         : inout std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
 
      write_data_falling : in    std_logic_vector((DATA_WIDTH-1) downto 0);
      write_data_rising  : in    std_logic_vector((DATA_WIDTH-1) downto 0);
      write_en_val       : in    std_logic;
      data_mask_f        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
      data_mask_r        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
      dqs_int_delay_in   : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
      ddr_dm             : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
      ddr_dq_val         : out   std_logic_vector((DATA_WIDTH-1) downto 0)
      );
  end component;

begin

  infrastructure_iobs0 : DDR2_Ram_Core_infrastructure_iobs_0
    port map (
      clk0      => clk,
      ddr2_ck   => ddr2_ck,
      ddr2_ck_n => ddr2_ck_n
      );

  controller_iobs0 : DDR2_Ram_Core_controller_iobs_0
    port map (
      clk0              => clk,
      ddr_rasb_cntrl    => ddr_rasb_cntrl,
      ddr_casb_cntrl    => ddr_casb_cntrl,
      ddr_web_cntrl     => ddr_web_cntrl,
      ddr_cke_cntrl     => ddr_cke_cntrl,
      ddr_csb_cntrl     => ddr_csb_cntrl,
      ddr_odt_cntrl     => ddr_odt_cntrl,
      ddr_address_cntrl => ddr_address_cntrl((ROW_ADDRESS -1) downto 0),
      ddr_ba_cntrl      => ddr_ba_cntrl((BANK_ADDRESS -1) downto 0),
      rst_dqs_div_int   => rst_dqs_div_int,
      ddr_rasb          => ddr_rasb,
      ddr_casb          => ddr_casb,
      ddr_web           => ddr_web,
      ddr_ba            => ddr_ba((BANK_ADDRESS -1) downto 0),
      ddr_address       => ddr_address((ROW_ADDRESS -1) downto 0),
      ddr_cke           => ddr_cke,
      ddr_csb           => ddr_csb,
      ddr_odt           => ddr_odt,
      rst_dqs_div       => rst_dqs_div,
      rst_dqs_div_in    => rst_dqs_div_in,
      rst_dqs_div_out   => rst_dqs_div_out
      );

  datapath_iobs0 : DDR2_Ram_Core_data_path_iobs_0
    port map (
      clk                => clk,
      clk90              => clk90,
      dqs_reset          => dqs_reset,
      dqs_enable         => dqs_enable,
      ddr_dqs            => ddr_dqs,
    ddr_dqs_n         => ddr_dqs_n,
      ddr_dq             => ddr_dq,
      write_data_falling => write_data_falling,
      write_data_rising  => write_data_rising,
      write_en_val       => write_en_val,
      data_mask_f        => data_mask_f,
      data_mask_r        => data_mask_r,
      dqs_int_delay_in   => dqs_int_delay_in,
      ddr_dm             => ddr_dm,
      ddr_dq_val         => dq
    );

end arc;
