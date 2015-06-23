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
--  /   /        Filename           : DDR2_Ram_Core_infrastructure_iobs_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module has the FDDRRSE instantiations to the clocks.
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.DDR2_Ram_Core_parameters_0.all;

entity DDR2_Ram_Core_infrastructure_iobs_0 is
  port(
    ddr2_ck   : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
    ddr2_ck_n : out  std_logic_vector((CLK_WIDTH-1)  downto 0);
    clk0      : in std_logic
    );
end DDR2_Ram_Core_infrastructure_iobs_0;

architecture arc of DDR2_Ram_Core_infrastructure_iobs_0 is

    signal ddr2_clk_q     : std_logic;
  signal vcc    : std_logic;
  signal gnd    : std_logic;
  signal clk180 : std_logic;

---- **************************************************
---- iob attributes for instantiated FDDRRSE components
---- **************************************************
begin

  gnd    <= '0';
  vcc    <= '1';
  clk180 <= not clk0;
  
--- ***********************************
---- This includes instantiation of the output DDR flip flop
---- for ddr clk's and dimm clk's
---- ***********************************************************

  
  
   
 U_clk_i : FDDRRSE 
  port map (
    Q => ddr2_clk_q,
    C0 => clk0,
    C1 => clk180,
    CE => vcc,
    D0 => vcc,
    D1 => gnd,
    R => gnd,
    S => gnd 
    );


  

---- ******************************************
---- Ouput BUffers for ddr clk's and dimm clk's
---- ******************************************

  
  
    
r_inst : OBUFDS 
	  port map (
        I  => ddr2_clk_q,
        O  => ddr2_ck(0),
        OB => ddr2_ck_n(0)
		);


  

end arc;
