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
--  /   /        Filename           : DDR2_Ram_Core_infrastructure_top.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module has instantiations clk_dcm,cal_top and generate
--               reset signals to the design
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use work.DDR2_Ram_Core_parameters_0.all;

entity DDR2_Ram_Core_infrastructure_top is
  port(
    reset_in_n             : in  std_logic;
    sys_clk                : in  std_logic;
    sys_clkb               : in  std_logic;
    sys_clk_in             : in  std_logic;
    delay_sel_val1_val     : out std_logic_vector(4 downto 0);
    sys_rst_val            : out std_logic;
    sys_rst90_val          : out std_logic;
    clk_int_val            : out std_logic;
    clk90_int_val          : out std_logic;
    sys_rst180_val         : out std_logic;
    wait_200us             : out std_logic;
    -- debug signals
    dbg_phase_cnt          : out std_logic_vector(4 downto 0);
    dbg_cnt                : out std_logic_vector(5 downto 0);
    dbg_trans_onedtct      : out std_logic;
    dbg_trans_twodtct      : out std_logic;
    dbg_enb_trans_two_dtct : out std_logic
    );

end DDR2_Ram_Core_infrastructure_top;

architecture arc of DDR2_Ram_Core_infrastructure_top is

  component DDR2_Ram_Core_clk_dcm
    port(
      input_clk : in  std_logic;
      rst       : in  std_logic;
      clk       : out std_logic;
      clk90     : out std_logic;
      dcm_lock  : out std_logic
      );
  end component;

  component DDR2_Ram_Core_cal_top
    port (
      clk                    : in  std_logic;
      clk0dcmlock            : in  std_logic;
      reset                  : in  std_logic;
      tapfordqs              : out std_logic_vector(4 downto 0);
      dbg_phase_cnt          : out std_logic_vector(4 downto 0);
      dbg_cnt                : out std_logic_vector(5 downto 0);
      dbg_trans_onedtct      : out std_logic;
      dbg_trans_twodtct      : out std_logic;
      dbg_enb_trans_two_dtct : out std_logic
      );
  end component;

  signal user_rst       : std_logic;
  signal user_cal_rst   : std_logic;
  signal clk_int        : std_logic;
  signal clk90_int      : std_logic;
  signal dcm_lock       : std_logic;
  signal sys_rst_o      : std_logic;
  signal sys_rst_1      : std_logic := '1';
  signal sys_rst        : std_logic;
  signal sys_rst90_o    : std_logic;
  signal sys_rst90_1    : std_logic := '1';
  signal sys_rst90      : std_logic;
  signal sys_rst180_o   : std_logic;
  signal sys_rst180_1   : std_logic := '1';
  signal sys_rst180     : std_logic;
  signal delay_sel_val1 : std_logic_vector(4 downto 0);
  signal clk_int_val1   : std_logic;
  signal clk_int_val2   : std_logic;
  signal clk90_int_val1 : std_logic;
  signal clk90_int_val2 : std_logic;
  signal wait_200us_i   : std_logic;
  signal wait_200us_int : std_logic;
  signal wait_clk90     : std_logic;
  signal wait_clk270    : std_logic;
  signal counter200     : std_logic_vector(15 downto 0);
  signal sys_clk_ibuf   : std_logic;

begin

  DIFF_ENDED_CLKS_INST : if(CLK_TYPE = "DIFFERENTIAL") generate
  begin
    SYS_CLK_INST : IBUFGDS_LVDS_25
      port map(
        I  => sys_clk,
        IB => sys_clkb,
        O  => sys_clk_ibuf
        );
  end generate;

  SINGLE_ENDED_CLKS_INST : if(CLK_TYPE = "SINGLE_ENDED") generate
  begin
    SYS_CLK_INST : IBUFG
      port map(
        I  => sys_clk_in,
        O  => sys_clk_ibuf
        );
  end generate;

  clk_int_val        <= clk_int;
  clk90_int_val      <= clk90_int;
  sys_rst_val        <= sys_rst;
  sys_rst90_val      <= sys_rst90;
  sys_rst180_val     <= sys_rst180;
  delay_sel_val1_val <= delay_sel_val1;


-- To remove delta delays in the clock signals observed during simulation
-- ,Following signals are used

  clk_int_val1   <= clk_int;
  clk90_int_val1 <= clk90_int;
  clk_int_val2   <= clk_int_val1;
  clk90_int_val2 <= clk90_int_val1;
  user_rst       <= not reset_in_n when RESET_ACTIVE_LOW = '1' else reset_in_n;
  user_cal_rst   <= reset_in_n     when RESET_ACTIVE_LOW = '1' else not reset_in_n;

  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '1' then
      if user_rst = '1' or dcm_lock = '0' then
        wait_200us_i   <= '1';
        counter200     <= (others => '0');
      else
        if( counter200 < 33400) then
          wait_200us_i <= '1';
          counter200   <= counter200 + 1;
        else
          counter200   <= counter200;
          wait_200us_i <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '1' then
      wait_200us <= wait_200us_i;
    end if;
  end process;

  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '1' then
      wait_200us_int <= wait_200us_i;
    end if;
  end process;

  process(clk90_int_val2)
  begin
    if clk90_int_val2'event and clk90_int_val2 = '0' then
      if user_rst = '1' or dcm_lock = '0' then
        wait_clk270 <= '1';
      else
        wait_clk270 <= wait_200us_int;
      end if;
    end if;
  end process;

  process(clk90_int_val2)
  begin
    if clk90_int_val2'event and clk90_int_val2 = '1' then
      wait_clk90 <= wait_clk270;
    end if;
  end process;

  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '1' then
      if user_rst = '1' or dcm_lock = '0' or wait_200us_int = '1' then
        sys_rst_o <= '1';
        sys_rst_1 <= '1';
        sys_rst   <= '1';
      else
        sys_rst_o <= '0';
        sys_rst_1 <= sys_rst_o;
        sys_rst   <= sys_rst_1;
      end if;
    end if;
  end process;

  process(clk90_int_val2)
  begin
    if clk90_int_val2'event and clk90_int_val2 = '1' then
      if user_rst = '1' or dcm_lock = '0' or wait_clk90 = '1' then
        sys_rst90_o <= '1';
        sys_rst90_1 <= '1';
        sys_rst90   <= '1';
      else
        sys_rst90_o <= '0';
        sys_rst90_1 <= sys_rst90_o;
        sys_rst90   <= sys_rst90_1;
      end if;
    end if;
  end process;

  process(clk_int_val2)
  begin
    if clk_int_val2'event and clk_int_val2 = '0' then
      if user_rst = '1' or dcm_lock = '0' or wait_clk270 = '1' then
        sys_rst180_o <= '1';
        sys_rst180_1 <= '1';
        sys_rst180   <= '1';
      else
        sys_rst180_o <= '0';
        sys_rst180_1 <= sys_rst180_o;
        sys_rst180   <= sys_rst180_1;
      end if;
    end if;
  end process;

  clk_dcm0 : DDR2_Ram_Core_clk_dcm
    port map (
      input_clk => sys_clk_ibuf,
      rst       => user_rst,
      clk       => clk_int,
      clk90     => clk90_int,
      dcm_lock  => dcm_lock
      );

  cal_top0 : DDR2_Ram_Core_cal_top
    port map (
      clk                    => clk_int_val2,
      clk0dcmlock            => dcm_lock,
      reset                  => user_cal_rst,
      tapfordqs              => delay_sel_val1,
      dbg_phase_cnt          => dbg_phase_cnt,
      dbg_cnt                => dbg_cnt,
      dbg_trans_onedtct      => dbg_trans_onedtct,
      dbg_trans_twodtct      => dbg_trans_twodtct,
      dbg_enb_trans_two_dtct => dbg_enb_trans_two_dtct
      );

end arc;
