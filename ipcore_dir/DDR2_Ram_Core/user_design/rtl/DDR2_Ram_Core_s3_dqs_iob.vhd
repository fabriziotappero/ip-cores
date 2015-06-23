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
--  /   /        Filename           : DDR2_Ram_Core_s3_dqs_iob.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module instantiates DDR IOB output flip-flops, an
--               output buffer with registered tri-state, and an input buffer
--               for a single strobe/dqs bit. The DDR IOB output flip-flops
--               are used to forward strobe to memory during a write. During
--               a read, the output of the IBUF is routed to the internal
--               delay module, dqs_delay.
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity DDR2_Ram_Core_s3_dqs_iob is
  port(
    clk            : in    std_logic;
    ddr_dqs_reset  : in    std_logic;
    ddr_dqs_enable : in    std_logic;
    ddr_dqs        : inout std_logic;
    ddr_dqs_n          : inout std_logic;
    dqs            : out   std_logic);
end DDR2_Ram_Core_s3_dqs_iob;

architecture arc of DDR2_Ram_Core_s3_dqs_iob is


  signal dqs_q            : std_logic;
  signal ddr_dqs_enable1  : std_logic;
  signal vcc              : std_logic;
  signal gnd              : std_logic;
  signal ddr_dqs_enable_b : std_logic;
  signal data1            : std_logic;
  signal clk180           : std_logic;

  attribute IOB               : string;
  attribute syn_useioff       : boolean;
  
  attribute IOB of U1         : label is "FORCE";
  attribute syn_useioff of U1 : label is true;

begin

--******************************************************************************
-- Output DDR generation. This includes instantiation of the output DDR flip flop.
-- Additionally, to keep synthesis tools from register sharing, manually
-- instantiate the output tri-state flip-flop.
--******************************************************************************
  vcc              <= '1';
  gnd              <= '0';
  clk180           <= not clk;
  ddr_dqs_enable_b <= not ddr_dqs_enable;
  data1            <= '0' when ddr_dqs_reset = '1' else
                      '1';

  U1 : FD
    port map (
      D => ddr_dqs_enable_b,
      Q => ddr_dqs_enable1,
      C => clk
      );


  U2 : FDDRRSE
    port map (
      Q    => dqs_q,
      C0 => clk,
      C1 => clk180,
      CE => vcc,
      D0 => data1,
      D1 => gnd,
      R  => gnd,
      S  => gnd
      );



--***********************************************************************
-- IO buffer for dqs signal. Allows for distribution of dqs
-- to the data (DQ) loads.
--***********************************************************************


    U3 : OBUFTDS port map (
            I  => dqs_q,
            T  => ddr_dqs_enable1,
            O  => ddr_dqs,
            OB => ddr_dqs_n
            );

     U4 : IBUFDS  port map(
                   I  => ddr_dqs,
                   IB => ddr_dqs_n,
                   O  => dqs
                   );



end arc;
