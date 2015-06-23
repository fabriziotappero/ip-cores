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
--  /   /        Filename           : DDR2_Ram_Core_data_read_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : ram8d modules are instantiated for Read data FIFOs. ram8d is
--               each 8 bits or 4 bits depending on number data bits per strobe.
--               Each strobe  will have two instances, one for rising edge data
--               and one for falling edge data.
--*****************************************************************************
library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.DDR2_Ram_Core_parameters_0.all;

entity DDR2_Ram_Core_data_read_0 is
  port(
    clk90             : in  std_logic;
    reset90           : in  std_logic;
    ddr_dq_in         : in  std_logic_vector((DATA_WIDTH-1) downto 0);
    fifo_0_wr_en      : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_1_wr_en      : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    fifo_0_wr_addr    : in std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
    fifo_1_wr_addr    : in std_logic_vector((4*DATA_STROBE_WIDTH)-1 downto 0);
    dqs_delayed_col0  : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    dqs_delayed_col1  : in std_logic_vector((DATA_STROBE_WIDTH-1) downto 0);
    read_fifo_rden    : in  std_logic;
    user_output_data  : out std_logic_vector((2*DATA_WIDTH-1) downto 0);
    u_data_val        : out std_logic
    );
end DDR2_Ram_Core_data_read_0;

architecture arc of DDR2_Ram_Core_data_read_0 is

  component DDR2_Ram_Core_rd_gray_cntr
    port (
      clk90    : in  std_logic;
      reset90  : in  std_logic;
      cnt_en   : in  std_logic;
      rgc_gcnt : out std_logic_vector(3 downto 0)
      );
  end component;

  component DDR2_Ram_Core_ram8d_0 is
    port (
      DOUT  : out std_logic_vector((DATABITSPERSTROBE -1) downto 0);
      WADDR : in  std_logic_vector(3 downto 0);
      DIN   : in  std_logic_vector((DATABITSPERSTROBE -1) downto 0);
      RADDR : in  std_logic_vector(3 downto 0);
      WCLK0 : in  std_logic;
      WCLK1 : in  std_logic;
      WE    : in  std_logic
      );
  end component;

  signal fifo0_rd_addr        : std_logic_vector(3 downto 0);
  signal fifo1_rd_addr        : std_logic_vector(3 downto 0);

  signal first_sdr_data       : std_logic_vector((2*DATA_WIDTH-1) downto 0);
  signal reset90_r          : std_logic;
  signal fifo0_rd_addr_r      : std_logic_vector((4*DATA_STROBE_WIDTH-1) downto 0);
  signal fifo1_rd_addr_r      : std_logic_vector((4*DATA_STROBE_WIDTH-1) downto 0);
  signal fifo_0_data_out      : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal fifo_1_data_out      : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal fifo_0_data_out_r    : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal fifo_1_data_out_r    : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal dqs_delayed_col0_n   : std_logic_vector((DATA_STROBE_WIDTH -1) downto 0);
  signal dqs_delayed_col1_n   : std_logic_vector((DATA_STROBE_WIDTH -1) downto 0);

  signal read_fifo_rden_90r1 : std_logic;
  signal read_fifo_rden_90r2 : std_logic;
  signal read_fifo_rden_90r3 : std_logic;
  signal read_fifo_rden_90r4 : std_logic;
  signal read_fifo_rden_90r5 : std_logic;
  signal read_fifo_rden_90r6 : std_logic;

  attribute syn_preserve : boolean;

  attribute syn_preserve of fifo0_rd_addr_r  : signal is true;
  attribute syn_preserve of fifo1_rd_addr_r  : signal is true;

begin

  process(clk90)
  begin
    if(clk90'event and clk90='1') then
      reset90_r <= reset90;
    end if;
  end process;

  gen_asgn : for asgn_i in 0 to DATA_STROBE_WIDTH-1 generate
    dqs_delayed_col0_n(asgn_i) <= not dqs_delayed_col0(asgn_i);
    dqs_delayed_col1_n(asgn_i) <= not dqs_delayed_col1(asgn_i);
  end generate;
  
  user_output_data  <= first_sdr_data;
  u_data_val        <= read_fifo_rden_90r6; 

 -- Read fifo read enable signal phase is changed from 180 to 90 clock domain 

  process (clk90)
  begin
    if (rising_edge(clk90)) then
      if reset90_r = '1' then
        read_fifo_rden_90r1 <= '0';
        read_fifo_rden_90r2 <= '0';
        read_fifo_rden_90r3 <= '0';
        read_fifo_rden_90r4 <= '0';
        read_fifo_rden_90r5 <= '0';
        read_fifo_rden_90r6<= '0';
      else
        read_fifo_rden_90r1 <= read_fifo_rden;
        read_fifo_rden_90r2 <= read_fifo_rden_90r1;
        read_fifo_rden_90r3 <= read_fifo_rden_90r2;
        read_fifo_rden_90r4 <= read_fifo_rden_90r3;
        read_fifo_rden_90r5 <= read_fifo_rden_90r4;
        read_fifo_rden_90r6 <= read_fifo_rden_90r5;
      end if;
    end if;
  end process;


  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      fifo_0_data_out_r <= fifo_0_data_out;
      fifo_1_data_out_r <= fifo_1_data_out;
    end if;
  end process;

  gen_addr : for addr_i in 0 to DATA_STROBE_WIDTH-1 generate
    process(clk90)
    begin
      if clk90'event and clk90 = '1' then
        fifo0_rd_addr_r((addr_i*4-1)+ 4 downto addr_i*4) <= fifo0_rd_addr;
        fifo1_rd_addr_r((addr_i*4-1)+ 4 downto addr_i*4) <= fifo1_rd_addr;
      end if;
    end process;
  end generate;

  process(clk90)
  begin
    if clk90'event and clk90 = '1' then
      if reset90_r = '1' then
        first_sdr_data       <= (others => '0');
      elsif (read_fifo_rden_90r5 = '1') then
        first_sdr_data <= (fifo_0_data_out_r & fifo_1_data_out_r);
      else
        first_sdr_data <= first_sdr_data;
      end if;
    end if;
  end process;

------------------------------------------------------------------------------
-- fifo0_rd_addr and fifo1_rd_addr counters ( gray counters )
-------------------------------------------------------------------------------

  fifo0_rd_addr_inst : DDR2_Ram_Core_rd_gray_cntr
    port map (
      clk90    => clk90,
      reset90  => reset90,
      cnt_en   => read_fifo_rden_90r3,
      rgc_gcnt => fifo0_rd_addr
      );
  fifo1_rd_addr_inst : DDR2_Ram_Core_rd_gray_cntr
    port map (
      clk90    => clk90,
      reset90  => reset90,
      cnt_en   => read_fifo_rden_90r3,
      rgc_gcnt => fifo1_rd_addr
      );

-------------------------------------------------------------------------------
-- ram8d instantiations
-------------------------------------------------------------------------------

  gen_strobe: for strobe_i in 0 to DATA_STROBE_WIDTH-1 generate
    strobe : DDR2_Ram_Core_ram8d_0
      Port Map (
        dout  => fifo_0_data_out((strobe_i*DATABITSPERSTROBE-1)+ DATABITSPERSTROBE downto strobe_i*DATABITSPERSTROBE),
        waddr => fifo_0_wr_addr((strobe_i*4-1)+4 downto strobe_i*4),
        din   => ddr_dq_in((strobe_i*DATABITSPERSTROBE-1)+ DATABITSPERSTROBE downto strobe_i*DATABITSPERSTROBE),
        raddr => fifo0_rd_addr_r((strobe_i*4-1)+4 downto strobe_i*4),
        wclk0 => dqs_delayed_col0(strobe_i),
        wclk1 => dqs_delayed_col1(strobe_i),
        we    => fifo_0_wr_en(strobe_i)
        );
    strobe_n : DDR2_Ram_Core_ram8d_0
      Port Map (
        dout  => fifo_1_data_out((strobe_i*DATABITSPERSTROBE-1)+ DATABITSPERSTROBE downto strobe_i*DATABITSPERSTROBE),
        waddr => fifo_1_wr_addr((strobe_i*4-1)+4 downto strobe_i*4),
        din   => ddr_dq_in((strobe_i*DATABITSPERSTROBE-1)+ DATABITSPERSTROBE downto strobe_i*DATABITSPERSTROBE),
        raddr => fifo1_rd_addr_r((strobe_i*4-1)+4 downto strobe_i*4),
        wclk0 => dqs_delayed_col0_n(strobe_i),
        wclk1 => dqs_delayed_col1_n(strobe_i),
        we    => fifo_1_wr_en(strobe_i)
        );
  end generate;

end arc;
