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
-- Copyright 2005, 2006, 2007, 2008 Xilinx, Inc.
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
--  /   /        Filename           : DDR2_Ram_Core_s3_dq_iob.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module instantiate DDR IOB output flip-flops, an
--               output buffer with registered tri-state, and an input buffer
--               for a single data/dq bit. The DDR IOB output flip-flops
--               are used to forward data to memory during a write.
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use UNISIM.VCOMPONENTS.all;

entity DDR2_Ram_Core_s3_dq_iob is
  port (
    ddr_dq_inout       : inout std_logic;  --Bi-directional SDRAM data bus
    write_data_falling : in    std_logic;  --Transmit data, output on falling edge
    write_data_rising  : in    std_logic;  --Transmit data, output on rising edge
    read_data_in       : out   std_logic;  -- Received data
    clk90              : in    std_logic;  --Clock 90
    write_en_val       : in    std_logic
    );
end DDR2_Ram_Core_s3_dq_iob;

architecture arc of DDR2_Ram_Core_s3_dq_iob is

--***********************************************************************\
-- Internal signal declaration
--***********************************************************************/
  signal ddr_en   : std_logic;          -- Tri-state enable signal
  signal ddr_dq_q : std_logic;          -- Data output intermediate signal
  signal gnd      : std_logic;
  signal clock_en : std_logic;
  signal enable_b : std_logic;
  signal clk270   : std_logic;

  attribute iob         : string;
  attribute syn_useioff : boolean;

  attribute iob of DQ_T         : label is "FORCE";
  attribute syn_useioff of DQ_T : label is true;

begin
  
  clk270   <= not clk90;
  gnd      <= '0';
  enable_b <= not write_en_val;
  clock_en <= '1';

-- Transmission data path

  DDR_OUT : FDDRRSE
    port map (
      Q  => ddr_dq_q,
      C0 => clk270,
      C1 => clk90,
      CE => clock_en,
      D0 => write_data_rising,
      D1 => write_data_falling,
      R  => gnd,
      S  => gnd
      );

  DQ_T : FD
    port map (
      D => enable_b,
      C => clk270,
      Q => ddr_en
      );

  DQ_OBUFT : OBUFT
    port map (
      I => ddr_dq_q,
      T => ddr_en,
      O => ddr_dq_inout
      );

-- Receive data path

  DQ_IBUF : IBUF
    port map(
      I => ddr_dq_inout,
      O => read_data_in
      );

end arc;
