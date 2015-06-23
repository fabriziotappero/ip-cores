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
--  /   /        Filename           : DDR2_Ram_Core_data_write0.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : Data write operation performed through the pipelines in this
--               module.
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
use work.DDR2_Ram_Core_parameters_0.all;

entity DDR2_Ram_Core_data_write_0 is
  port(
    user_input_data    : in  std_logic_vector((2*DATA_WIDTH-1) downto 0);
    user_data_mask     : in  std_logic_vector((2*DATA_MASK_WIDTH-1) downto 0);
    clk90              : in  std_logic;
    write_enable       : in  std_logic;
    write_en_val       : out std_logic;
    data_mask_f        : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    data_mask_r        : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    write_data_falling : out std_logic_vector((DATA_WIDTH-1) downto 0);
    write_data_rising  : out std_logic_vector((DATA_WIDTH-1) downto 0)
    );
end DDR2_Ram_Core_data_write_0;

architecture arc of DDR2_Ram_Core_data_write_0 is


  signal write_en_P1       : std_logic;  -- write enable Pipeline stage
  signal write_data0       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data1       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data2       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data3       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data4       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal write_data_m0     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m1     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m2     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m3     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m4     : std_logic_vector ((2*DATA_MASK_WIDTH-1) downto 0);

  signal write_data90       : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data90_1     : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data90_2     : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data_m90     : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m90_1   : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m90_2   : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);

  signal write_data270     : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data270_1   : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal write_data270_2   : std_logic_vector((DATA_WIDTH-1) downto 0);

  signal write_data_m270   : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m270_1 : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);
  signal write_data_m270_2 : std_logic_vector ((DATA_MASK_WIDTH-1) downto 0);

  

  attribute syn_preserve : boolean;
  attribute syn_preserve of write_data0 : signal is true;
  attribute syn_preserve of write_data1 : signal is true;
  attribute syn_preserve of write_data2 : signal is true;
  attribute syn_preserve of write_data3 : signal is true;
  attribute syn_preserve of write_data4 : signal is true;

  attribute syn_preserve of write_data_m0 : signal is true;
  attribute syn_preserve of write_data_m1 : signal is true;
  attribute syn_preserve of write_data_m2 : signal is true;
  attribute syn_preserve of write_data_m3 : signal is true;
  attribute syn_preserve of write_data_m4 : signal is true;

  attribute syn_preserve of write_data90   : signal is true;
  attribute syn_preserve of write_data90_1 : signal is true;
  attribute syn_preserve of write_data90_2 : signal  is true;

  attribute syn_preserve of write_data270   : signal is true;
  attribute syn_preserve of write_data270_1 : signal is true;
  attribute syn_preserve of write_data270_2 : signal is true;

begin

  write_data0   <= user_input_data;
  write_data_m0 <= user_data_mask;

  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      write_data1   <= write_data0;
      write_data_m1 <= write_data_m0;
      write_data2   <= write_data1;
      write_data_m2 <= write_data_m1;
      write_data3   <= write_data2;
      write_data_m3 <= write_data_m2;
      write_data4   <= write_data3;
      write_data_m4 <= write_data_m3;
    end if;
  end process;

  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      write_data90        <= write_data4((DATA_WIDTH-1) downto 0); 
      write_data_m90      <= write_data_m4((DATA_MASK_WIDTH-1) downto 0);
      write_data90_1     <= write_data90;
      write_data_m90_1   <= write_data_m90;
      write_data90_2      <= write_data90_1;
      write_data_m90_2 <= write_data_m90_1;

    end if;
  end process;


  process(clk90)
  begin
    if clk90'event and clk90 = '0' then
      write_data270     <= write_data4((DATA_WIDTH*2-1) downto DATA_WIDTH);
      write_data_m270   <= write_data_m4((DATA_MASK_WIDTH*2-1) downto DATA_MASK_WIDTH);
      write_data270_1 <= write_data270;
      write_data270_2   <= write_data270_1;
      write_data_m270_1 <= write_data_m270;
      write_data_m270_2 <= write_data_m270_1;

    end if;
  end process;

  write_data_rising  <= write_data270_2;
  write_data_falling <= write_data90_2;
  data_mask_r        <= write_data_m270_2;
  data_mask_f        <= write_data_m90_2; 

-- write enable for data path
  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      write_en_P1 <= write_enable;
    end if;
  end process;

-- write enable for data path
  process(clk90)
  begin
    if clk90'event and clk90 = '0' then
      write_en_val <= write_en_P1;
    end if;
  end process;

end arc;
