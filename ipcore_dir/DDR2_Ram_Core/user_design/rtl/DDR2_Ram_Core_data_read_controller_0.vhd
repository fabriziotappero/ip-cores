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
--  /   /        Filename           : DDR2_Ram_Core_data_read_controller_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Description : This module has instantiations fifo_0_wr_en, fifo_1_wr_en,
--               dqs_delay and wr_gray_cntr.
--*****************************************************************************
library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.DDR2_Ram_Core_parameters_0.all;

entity DDR2_Ram_Core_data_read_controller_0 is
  port(
    clk                   : in  std_logic;
    reset                 : in  std_logic;
    rst_dqs_div_in        : in  std_logic;
    delay_sel             : in  std_logic_vector(4 downto 0);
    dqs_int_delay_in      : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_0_wr_en_val      : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_1_wr_en_val      : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_0_wr_addr_val    : out std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
    fifo_1_wr_addr_val    : out std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
    dqs_delayed_col0_val  : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    dqs_delayed_col1_val  : out std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    -- debug signals
    vio_out_dqs           : in  std_logic_vector(4 downto 0);
    vio_out_dqs_en        : in  std_logic;
    vio_out_rst_dqs_div   : in  std_logic_vector(4 downto 0);
    vio_out_rst_dqs_div_en: in  std_logic
    );

end DDR2_Ram_Core_data_read_controller_0;

architecture arc of DDR2_Ram_Core_data_read_controller_0 is

  component DDR2_Ram_Core_dqs_delay
    port (
      clk_in  : in  std_logic;
      sel_in  : in  std_logic_vector(4 downto 0);
      clk_out : out std_logic
      );
  end component;

-- wr_gray_cntr is a gray counter with an ASYNC reset for fifo wr_addr
  
  component DDR2_Ram_Core_wr_gray_cntr
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      cnt_en   : in  std_logic;
      wgc_gcnt : out std_logic_vector(3 downto 0)
      );
  end component;

-- fifo_wr_en module generates fifo write enable signal
-- enable is derived from rst_dqs_div signal
  
  component DDR2_Ram_Core_fifo_0_wr_en_0
    port (
      clk             : in  std_logic;
      reset           : in  std_logic;
      din             : in  std_logic;
      rst_dqs_delay_n : out std_logic;
      dout            : out std_logic
      );
  end component;
  
  component DDR2_Ram_Core_fifo_1_wr_en_0
    port (
      clk             : in  std_logic;
      rst_dqs_delay_n : in  std_logic;
      reset           : in  std_logic;
      din             : in  std_logic;
      dout            : out std_logic
      );
  end component;


  signal dqs_delayed_col0    : std_logic_vector((data_strobe_width-1) downto 0);
  signal dqs_delayed_col1    : std_logic_vector((data_strobe_width-1) downto 0);
  signal fifo_0_wr_addr      : std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
  signal fifo_1_wr_addr      : std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);

-- FIFO WRITE ENABLE SIGNALS
  signal fifo_0_wr_en        : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal fifo_1_wr_en        : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  

  signal rst_dqs_div         : std_logic;
  signal reset_r             : std_logic;
  signal rst_dqs_delay_0_n   : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal dqs_delayed_col0_n  : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal dqs_delayed_col1_n  : std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
  signal delay_sel_rst_dqs_div : std_logic_vector(4 downto 0);
  signal delay_sel_dqs         : std_logic_vector(4 downto 0);

  attribute syn_preserve  : boolean;
  attribute buffer_type   : string;
  attribute buffer_type  of  dqs_delayed_col0: signal is "none";
  attribute buffer_type  of  dqs_delayed_col1: signal is "none";

begin

  process(clk)
  begin
    if(clk'event and clk = '1') then
      reset_r <= reset;
    end if;
  end process;


  fifo_0_wr_addr_val   <= fifo_0_wr_addr;
  fifo_1_wr_addr_val   <= fifo_1_wr_addr;
  fifo_0_wr_en_val     <= fifo_0_wr_en;
  fifo_1_wr_en_val     <= fifo_1_wr_en;
  dqs_delayed_col0_val <= dqs_delayed_col0 ;
  dqs_delayed_col1_val <= dqs_delayed_col1 ;

  gen_asgn : for asgn_i in 0 to DATA_STROBE_WIDTH-1 generate
    dqs_delayed_col0_n(asgn_i) <= not dqs_delayed_col0(asgn_i);
    dqs_delayed_col1_n(asgn_i) <= not dqs_delayed_col1(asgn_i);
  end generate;
  
  


  debug_rst_dqs_div_ena : if (DEBUG_EN = 1) generate
    delay_sel_rst_dqs_div <= vio_out_rst_dqs_div(4 downto 0) when  (vio_out_rst_dqs_div_en = '1')
				             else delay_sel;  
  end generate; 

  debug_rst_dqs_div_dis : if (DEBUG_EN = 0) generate
    delay_sel_rst_dqs_div <= delay_sel;  
  end generate; 


-- delayed rst_dqs_div logic

  rst_dqs_div_delayed : DDR2_Ram_Core_dqs_delay
    port map (
      clk_in  => rst_dqs_div_in,
      sel_in  => delay_sel_rst_dqs_div,
      clk_out => rst_dqs_div
      );


  debug_ena : if (DEBUG_EN = 1) generate
    delay_sel_dqs <= vio_out_dqs(4 downto 0) when  (vio_out_dqs_en = '1')
				             else delay_sel;  
  end generate; 

  debug_dis : if (DEBUG_EN = 0) generate
    delay_sel_dqs <= delay_sel;  
  end generate; 


--******************************************************************************
-- DQS Internal Delay Circuit implemented in LUTs
--******************************************************************************
    gen_delay: for dly_i in 0 to DATA_STROBE_WIDTH-1 generate
    attribute syn_preserve of  dqs_delay_col0: label is true;
    attribute syn_preserve of  dqs_delay_col1: label is true;
  begin
 -- Internal Clock Delay circuit placed in the first
   -- column (for falling edge data) adjacent to IOBs
    dqs_delay_col0 : DDR2_Ram_Core_dqs_delay
      port map (
        clk_in  => dqs_int_delay_in(dly_i),
        sel_in  => delay_sel_dqs,
        clk_out => dqs_delayed_col0(dly_i)
       );
  -- Internal Clock Delay circuit placed in the second
  --column (for rising edge data) adjacent to IOBs
    dqs_delay_col1 : DDR2_Ram_Core_dqs_delay
      port map (
        clk_in  => dqs_int_delay_in(dly_i),
        sel_in  => delay_sel_dqs,
        clk_out => dqs_delayed_col1(dly_i)
        );
  end generate;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  gen_wr_en: for wr_en_i in 0 to DATA_STROBE_WIDTH-1 generate
    fifo_0_wr_en_inst: DDR2_Ram_Core_fifo_0_wr_en_0
      port map (
        clk             => dqs_delayed_col1_n (wr_en_i),
        reset           => reset_r,
        din             => rst_dqs_div,
        rst_dqs_delay_n => rst_dqs_delay_0_n(wr_en_i),
        dout            => fifo_0_wr_en(wr_en_i)
        );
    fifo_1_wr_en_inst: DDR2_Ram_Core_fifo_1_wr_en_0
      port map (
        clk             => dqs_delayed_col0(wr_en_i),
        rst_dqs_delay_n => rst_dqs_delay_0_n(wr_en_i),
        reset           => reset_r,
        din             => rst_dqs_div,
        dout            => fifo_1_wr_en(wr_en_i)
        );
  end generate;

-------------------------------------------------------------------------------
-- write pointer gray counter instances
-------------------------------------------------------------------------------

  gen_wr_addr: for wr_addr_i in 0 to DATA_STROBE_WIDTH-1 generate
    fifo_0_wr_addr_inst : DDR2_Ram_Core_wr_gray_cntr
      port map (
        clk      => dqs_delayed_col1(wr_addr_i),
        reset    => reset_r,
        cnt_en   => fifo_0_wr_en(wr_addr_i),
        wgc_gcnt => fifo_0_wr_addr((wr_addr_i*4-1)+4 downto wr_addr_i*4)
        );
    fifo_1_wr_addr_inst : DDR2_Ram_Core_wr_gray_cntr
      port map (
        clk      => dqs_delayed_col0_n(wr_addr_i),
        reset    => reset_r,
        cnt_en   => fifo_1_wr_en(wr_addr_i),
        wgc_gcnt => fifo_1_wr_addr((wr_addr_i*4-1)+4 downto wr_addr_i*4)
        );        
  end generate;

end arc;
