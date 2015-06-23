-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_data_tap_inc.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: The tap logic for calibration of the memory data with respect
--              to FPGA clock is provided here. According to the edge detection
--              or not the taps in the IDELAY element of the Virtex4 devices
--              are either increased or decreased.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_data_tap_inc is
  port(
    clk                  : in  std_logic;
    reset                : in  std_logic;
    data_dlyinc          : out std_logic;
    data_dlyce           : out std_logic;
    data_dlyrst          : out std_logic;
    data_tap_sel_done    : out std_logic;
    dqs_sel_done         : in  std_logic;
    valid_data_tap_count : in  std_logic;
    data_tap_count       : in  std_logic_vector(5 downto 0)
    );
end MIG_data_tap_inc;

architecture arch of MIG_data_tap_inc is

  signal data_dlyinc_clk0       : std_logic;
  signal data_dlyce_clk0        : std_logic;
  signal data_dlyrst_clk0       : std_logic;
  signal data_tap_inc_counter   : std_logic_vector(5 downto 0) := "000000";
  signal data_tap_sel_clk       : std_logic;
  signal data_tap_sel_r1        : std_logic;
  signal dqs_sel_done_r         : std_logic;
  signal valid_data_tap_count_r : std_logic;
  signal rst_r                  : std_logic;

begin

  data_tap_sel_done <= data_tap_sel_r1;
  data_dlyinc       <= data_dlyinc_clk0;
  data_dlyce        <= data_dlyce_clk0;
  data_dlyrst       <= data_dlyrst_clk0;


  process(clk)
  begin
    if(clk'event and clk = '1') then
      rst_r <= reset;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        data_tap_sel_clk <= '0';
      elsif(data_tap_inc_counter = "000001") then
        data_tap_sel_clk <= '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        data_tap_sel_r1 <= '0';
      else
        data_tap_sel_r1 <= data_tap_sel_clk;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        dqs_sel_done_r <= '0';
      elsif(dqs_sel_done = '1') then
        dqs_sel_done_r <= '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        valid_data_tap_count_r <= '0';
      else
        valid_data_tap_count_r <= valid_data_tap_count;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1' or dqs_sel_done_r = '0') then
        data_dlyinc_clk0     <= '0';
        data_dlyce_clk0      <= '0';
        data_dlyrst_clk0     <= '1';
        data_tap_inc_counter <= "000000";
      elsif(valid_data_tap_count_r = '1') then
        data_dlyinc_clk0     <= '0';
        data_dlyce_clk0      <= '0';
        data_dlyrst_clk0     <= '0';
        data_tap_inc_counter <= data_tap_count;
      elsif(data_tap_inc_counter /= "000000") then  -- Data IDELAY incremented
        data_dlyinc_clk0     <= '1';
        data_dlyce_clk0      <= '1';
        data_dlyrst_clk0     <= '0';
        data_tap_inc_counter <= data_tap_inc_counter - '1';
      else                              -- Data IDELAY no change mode
        data_dlyinc_clk0     <= '0';
        data_dlyce_clk0      <= '0';
        data_dlyrst_clk0     <= '0';
        data_tap_inc_counter <= "000000";
      end if;
    end if;
  end process;

end arch;
