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
--  /   /        Filename           : DDR2_Ram_Core_wr_gray_cntr.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
-- Device      : Spartan-3/3A/3A-DSP
-- Design Name : DDR2 SDRAM
-- Purpose     :
--*****************************************************************************
-- fifo_wr_addr gray counter with synchronous reset
-- Gray counter is used for FIFO address counter

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use UNISIM.VCOMPONENTS.all;

entity DDR2_Ram_Core_wr_gray_cntr is
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    cnt_en   : in  std_logic;
    wgc_gcnt : out std_logic_vector(3 downto 0)
    );
end DDR2_Ram_Core_wr_gray_cntr;

architecture arc of DDR2_Ram_Core_wr_gray_cntr is

  signal d_in   : std_logic_vector(3 downto 0);
  signal gc_int : std_logic_vector(3 downto 0);

begin

  wgc_gcnt <= gc_int(3 downto 0);

  process(gc_int)
  begin
    case gc_int is
      when "0000" => d_in <= "0001";    --0 > 1
      when "0001" => d_in <= "0011";    --1 > 3
      when "0010" => d_in <= "0110";    --2 > 6
      when "0011" => d_in <= "0010";    --3 > 2
      when "0100" => d_in <= "1100";    --4 > c
      when "0101" => d_in <= "0100";    --5 > 4
      when "0110" => d_in <= "0111";    --6 > 7
      when "0111" => d_in <= "0101";    --7 > 5
      when "1000" => d_in <= "0000";    --8 > 0
      when "1001" => d_in <= "1000";    --9 > 8
      when "1010" => d_in <= "1011";    --a > b
      when "1011" => d_in <= "1001";    --b > 9
      when "1100" => d_in <= "1101";    --c > d
      when "1101" => d_in <= "1111";    --d > f
      when "1110" => d_in <= "1010";    --e > a
      when "1111" => d_in <= "1110";    --f > e
      when others => d_in <= "0001";    --0 > 1
    end case;
  end process;

  bit0 : FDCE
    port map (
      Q   => gc_int(0),
      C   => clk,
      CE  => cnt_en,
      CLR => reset,
      D   => d_in(0)
      );

  bit1 : FDCE
    port map (
      Q   => gc_int(1),
      C   => clk,
      CE  => cnt_en,
      CLR => reset,
      D   => d_in(1)
      );
  
  bit2 : FDCE
    port map (
      Q   => gc_int(2),
      C   => clk,
      CE  => cnt_en,
      CLR => reset,
      D   => d_in(2)
      );

  bit3 : FDCE
    port map (
      Q   => gc_int(3),
      C   => clk,
      CE  => cnt_en,
      CLR => reset,
      D   => d_in(3)
      );

end arc;
