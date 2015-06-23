--*****************************************************************************
-- (c) Copyright 2005 - 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and 
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version	    : 3.6.1
--  \   \        Application	    : MIG
--  /   /        Filename           : DDR2_Ram_Core_cal_ctl.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     : This module generates the select lines for the LUT delay
--               circuit that generate the required delay for the DQS with
--               respect to the DQ. It calculates the dealy of a LUT dynalically
--               by finding the number of LUTs in a clock phase.
--*****************************************************************************

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use UNISIM.VCOMPONENTS.all;

entity DDR2_Ram_Core_cal_ctl is
  port (
    clk                    : in  std_logic;
    reset                  : in  std_logic;
    flop2                  : in  std_logic_vector(31 downto 0);
    tapfordqs              : out std_logic_vector(4 downto 0);
    -- debug signals
    dbg_phase_cnt          : out std_logic_vector(4 downto 0);
    dbg_cnt                : out std_logic_vector(5 downto 0);
    dbg_trans_onedtct      : out std_logic;
    dbg_trans_twodtct      : out std_logic;
    dbg_enb_trans_two_dtct : out std_logic
    );
end DDR2_Ram_Core_cal_ctl;

architecture arc_cal_ctl of DDR2_Ram_Core_cal_ctl is

  signal cnt                : std_logic_vector(5 downto 0);
  signal cnt1               : std_logic_vector(5 downto 0);
  signal trans_onedtct      : std_logic;
  signal trans_twodtct      : std_logic;
  signal phase_cnt          : std_logic_vector(4 downto 0);
  signal tap_dly_reg        : std_logic_vector(31 downto 0);
  signal enb_trans_two_dtct : std_logic;
  signal tapfordqs_val      : std_logic_vector(4 downto 0);
  signal cnt_val            : integer;
  signal reset_r            : std_logic;

  constant tap1        : std_logic_vector(4 downto 0) := "01111";
  constant tap2        : std_logic_vector(4 downto 0) := "10111";
  constant tap3        : std_logic_vector(4 downto 0) := "11011";
  constant tap4        : std_logic_vector(4 downto 0) := "11101";
  constant tap5        : std_logic_vector(4 downto 0) := "11110";
  constant tap6        : std_logic_vector(4 downto 0) := "11111";
  constant default_tap : std_logic_vector(4 downto 0) := "11101";

  attribute syn_keep : boolean;
  attribute syn_keep of cnt                : signal is true;
  attribute syn_keep of cnt1               : signal is true;
  attribute syn_keep of trans_onedtct      : signal is true;
  attribute syn_keep of trans_twodtct      : signal is true;
  attribute syn_keep of tap_dly_reg        : signal is true;
  attribute syn_keep of enb_trans_two_dtct : signal is true;
  attribute syn_keep of phase_cnt          : signal is true;
  attribute syn_keep of tapfordqs_val      : signal is true;

begin

  dbg_phase_cnt          <= phase_cnt;
  dbg_cnt                <= cnt1;
  dbg_trans_onedtct      <= trans_onedtct;
  dbg_trans_twodtct      <= trans_twodtct;
  dbg_enb_trans_two_dtct <= enb_trans_two_dtct;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      reset_r <= reset;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      tapfordqs <= tapfordqs_val;
    end if;
  end process;

-----------For Successive Transition-------------------

  process(clk)
  begin
    if (clk'event and clk = '1') then
      if(reset_r = '1') then
        enb_trans_two_dtct <= '0';
      elsif(phase_cnt >= "00001") then
        enb_trans_two_dtct <= '1';
      else
        enb_trans_two_dtct <= '0';
      end if;
    end if;
  end process;

  process (clk)
  begin
    if(clk'event and clk = '1') then
      if(reset_r = '1') then
        tap_dly_reg <= "00000000000000000000000000000000";
      elsif(cnt(5) = '1') then
        tap_dly_reg <= flop2;
      else
        tap_dly_reg <= tap_dly_reg;
      end if;
    end if;
  end process;

--------Free Running Counter For Counting 32 States ----------------------
------- Two parallel counters are used to fix the timing ------------------

  process (clk)
  begin
    if(clk'event and clk = '1') then
      if(reset_r = '1' or cnt(5) = '1') then
        cnt(5 downto 0) <= "000000";
      else
        cnt(5 downto 0) <= cnt(5 downto 0) + "000001";
      end if;
    end if;
  end process;


  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(reset_r = '1' or cnt1(5) = '1') then
        cnt1(5 downto 0) <= "000000";
      else
        cnt1(5 downto 0) <= cnt1(5 downto 0) + "000001";
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if(reset_r = '1' or cnt(5) = '1') then
        phase_cnt <= "00000";
      elsif (trans_onedtct = '1' and trans_twodtct = '0') then
        phase_cnt <= phase_cnt + "00001";
      else
        phase_cnt <= phase_cnt;
      end if;
    end if;
  end process;

----------- Checking For The First Transition ------------------

  process (clk)
  begin
    if clk'event and clk = '1' then
      if (reset_r = '1' or cnt(5) = '1') then
        trans_onedtct <= '0';
        trans_twodtct <= '0';
      elsif (cnt(4 downto 0) = "00000" and tap_dly_reg(0) = '1') then
        trans_onedtct <= '1';
        trans_twodtct <= '0';
      elsif (tap_dly_reg(cnt_val) = '1' and trans_twodtct = '0') then
        if(trans_onedtct = '1' and enb_trans_two_dtct = '1') then
          trans_twodtct <= '1';
        else
          trans_onedtct <= '1';
        end if;
      end if;
    end if;
  end process;

  cnt_val <= conv_integer(cnt(4 downto 0));

  -- Tap values for Left/Right banks
  process (clk)
  begin
    if clk'event and clk = '1' then
      if(reset_r = '1') then
        tapfordqs_val <= default_tap;
      elsif(cnt1(4) = '1' and cnt1(3) = '1' and cnt1(2) = '1' and cnt1(1) = '1'
        and cnt1(0) = '1') then
        if ((trans_onedtct = '0') or (trans_twodtct = '0')
			or (phase_cnt > "01100")) then
          tapfordqs_val <= tap6;
        elsif (phase_cnt > "01001") then
          tapfordqs_val <= tap4;
        elsif (phase_cnt > "00111") then
          tapfordqs_val <= tap3;
        elsif (phase_cnt > "00100") then
          tapfordqs_val <= tap2;
        else
          tapfordqs_val <= tap1;
        end if;
      else
        tapfordqs_val <= tapfordqs_val;
      end if;
    end if;
  end process;

end arc_cal_ctl;
