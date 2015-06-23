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
--  /   /        Filename           : DDR2_Ram_Core_parameters_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module has the instantiations s3_dq_iob, s3_dqs_iob and
--               s3_dm_iob modules.
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
use work.DDR2_Ram_Core_parameters_0.all;

entity DDR2_Ram_Core_data_path_iobs_0 is
  port(
    clk                : in    std_logic;
    clk90              : in    std_logic;
    dqs_reset          : in    std_logic;
    dqs_enable         : in    std_logic;
    ddr_dqs            : inout std_logic_vector((DATA_STROBE_WIDTH -1) downto 0);
    ddr_dqs_n          : inout std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    ddr_dq             : inout std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_falling : in    std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_rising  : in    std_logic_vector((DATA_WIDTH-1) downto 0);
    write_en_val       : in    std_logic;
    data_mask_f        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    data_mask_r        : in std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    dqs_int_delay_in   : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    ddr_dm             : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    ddr_dq_val         : out   std_logic_vector((DATA_WIDTH-1) downto 0)
    );
end DDR2_Ram_Core_data_path_iobs_0;

architecture arc of DDR2_Ram_Core_data_path_iobs_0 is

  component  DDR2_Ram_Core_s3_dqs_iob
    port(
      clk            : in std_logic;
      ddr_dqs_reset  : in std_logic;
      ddr_dqs_enable : in std_logic;
      ddr_dqs        : inout std_logic;
      ddr_dqs_n      : inout std_logic;
      dqs            : out std_logic
      );
  end component;

  component DDR2_Ram_Core_s3_dq_iob
    port (
      ddr_dq_inout       : inout std_logic;  --Bi-directional SDRAM data bus
      write_data_falling : in    std_logic;  --Transmit data, output on falling edge
      write_data_rising  : in    std_logic;  --Transmit data, output on rising edge
      read_data_in       : out   std_logic;  -- Received data
      clk90              : in    std_logic;
      write_en_val       : in    std_logic
      );
  end component;

component   DDR2_Ram_Core_s3_dm_iob
port (
      ddr_dm       : out std_logic;
      mask_falling : in std_logic;
      mask_rising  : in std_logic;
      clk90        : in std_logic      
	  );
end component;

  signal ddr_dq_in  : std_logic_vector((DATA_WIDTH-1) downto 0);

begin

  ddr_dq_val <= ddr_dq_in;

--***********************************************************************
-- DM IOB instantiations
--***********************************************************************
  MASK_INST : if(MASK_ENABLE = 1) generate
    begin
    gen_dm: for dm_i in 0 to DATA_MASK_WIDTH-1 generate
      s3_dm_iob_inst : DDR2_Ram_Core_s3_dm_iob
      port map (
        ddr_dm       => ddr_dm(dm_i),
        mask_falling => data_mask_f(dm_i),
        mask_rising  => data_mask_r(dm_i),
        clk90        => clk90
        );
  end generate;
  end generate MASK_INST;

--***********************************************************************
--    Read Data Capture Module Instantiations
--***********************************************************************
-- DQS IOB instantiations
--***********************************************************************
  
  gen_dqs: for dqs_i in 0 to DATA_STROBE_WIDTH-1 generate
    s3_dqs_iob_inst : DDR2_Ram_Core_s3_dqs_iob 
      port map (
        clk             => clk,
        ddr_dqs_reset   => dqs_reset,
        ddr_dqs_enable  => dqs_enable,
        ddr_dqs         => ddr_dqs(dqs_i),
        ddr_dqs_n       => ddr_dqs_n(dqs_i),
        dqs             => dqs_int_delay_in(dqs_i)
        );
  end generate;



--******************************************************************************
-- DDR Data bit instantiations
--******************************************************************************

  gen_dq: for dq_i in 0 to DATA_WIDTH-1 generate
    s3_dq_iob_inst : DDR2_Ram_Core_s3_dq_iob
      port map (
        ddr_dq_inout       => ddr_dq(dq_i),
        write_data_falling => write_data_falling(dq_i),
        write_data_rising  => write_data_rising(dq_i),
        read_data_in       => ddr_dq_in(dq_i),
        clk90              => clk90,
        write_en_val       => write_en_val
        );
  end generate;

end arc;
