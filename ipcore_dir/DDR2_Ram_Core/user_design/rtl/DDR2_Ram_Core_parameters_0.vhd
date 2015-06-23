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
-- /___/  \  /   Vendor		    : Xilinx
-- \   \   \/    Version	    : 3.6.1
--  \   \        Application	    : MIG
--  /   /        Filename	    : DDR2_Ram_Core_parameters_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created	    : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module has the parameters used in the design
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use UNISIM.VCOMPONENTS.all;

package  DDR2_Ram_Core_parameters_0  is

-- The reset polarity is set to active low by default. 
-- You can change this by editing the parameter RESET_ACTIVE_LOW.
-- Please do not change any of the other parameters directly by editing the RTL. 
-- All other changes should be done through the GUI.

constant   DATA_WIDTH                                : INTEGER   :=  16;
constant   DATA_STROBE_WIDTH                         : INTEGER   :=  2;
constant   DATA_MASK_WIDTH                           : INTEGER   :=  2;
constant   CLK_WIDTH                                 : INTEGER   :=  1;
constant   CKE_WIDTH                                 : INTEGER   :=  1;
constant   ROW_ADDRESS                               : INTEGER   :=  13;
constant   MEMORY_WIDTH                              : INTEGER   :=  8;
constant   REGISTERED                                : INTEGER   :=  0;
constant   DATABITSPERSTROBE                         : INTEGER   :=  8;
constant   RESET_PORT                                : INTEGER   :=  0;
constant   MASK_ENABLE                               : INTEGER   :=  1;
constant   USE_DM_PORT                               : INTEGER   :=  1;
constant   COLUMN_ADDRESS                            : INTEGER   :=  10;
constant   BANK_ADDRESS                              : INTEGER   :=  2;
constant   DEBUG_EN                                  : INTEGER   :=  0;
constant   CLK_TYPE                                  : string    :=  "SINGLE_ENDED";
constant   LOAD_MODE_REGISTER                        : std_logic_vector(12 downto 0) := "0010100110010";

constant   EXT_LOAD_MODE_REGISTER                    : std_logic_vector(12 downto 0) := "0000000000000";

constant   RESET_ACTIVE_LOW                         : std_logic := '1';
constant   RAS_COUNT_VALUE                           : std_logic_vector(4 downto 0) := "00101";
constant   RP_COUNT_VALUE                             : std_logic_vector(2 downto 0) := "001";
constant   RFC_COUNT_VALUE                            : std_logic_vector(7 downto 0) := "00001101";
constant   TWR_COUNT_VALUE                            : std_logic_vector(2 downto 0) := "010";
constant   MAX_REF_WIDTH                                   : INTEGER   :=  10;
constant   MAX_REF_CNT                     : std_logic_vector(9 downto 0) := "1111100111";

end DDR2_Ram_Core_parameters_0  ;
