
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class application
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        07/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! This example application fills a fifo with constand values and a 32 bit counter
--! value. The DMA core will take care of the data and writes it into PC memory
--! according to the DMA descriptors.
--! 
--! @detail
--! We are discarding any DMA data sent by the PC, otherwise a second fifo could be connected to these ports: <br>
--! fifo_din <br>
--! fifo_we <br>
--! fifo_full <br>
--!
--!-----------------------------------------------------------------------------
--! @TODO
--!  
--!
--! ------------------------------------------------------------------------------
--! Virtex7 PCIe Gen3 DMA Core
--! 
--! \copyright GNU LGPL License
--! Copyright (c) Nikhef, Amsterdam, All rights reserved. <br>
--! This library is free software; you can redistribute it and/or
--! modify it under the terms of the GNU Lesser General Public
--! License as published by the Free Software Foundation; either
--! version 3.0 of the License, or (at your option) any later version.
--! This library is distributed in the hope that it will be useful,
--! but WITHOUT ANY WARRANTY; without even the implied warranty of
--! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--! Lesser General Public License for more details.<br>
--! You should have received a copy of the GNU Lesser General Public
--! License along with this library.
--! 
-- 
--! @brief ieee 



library ieee, UNISIM, work;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use work.pcie_package.all;

entity application is
  generic(
    NUMBER_OF_INTERRUPTS : integer := 8);
  port (
    appreg_clk           : in     std_logic;
    fifo_din             : in     std_logic_vector(255 downto 0);
    fifo_dout            : out    std_logic_vector(255 downto 0);
    fifo_empty           : out    std_logic;
    fifo_full            : out    std_logic;
    fifo_rd_clk          : in     std_logic;
    fifo_re              : in     std_logic;
    fifo_we              : in     std_logic;
    fifo_wr_clk          : in     std_logic;
    flush_fifo           : in     std_logic;
    interrupt_call       : out    std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 4);
    leds                 : out    std_logic_vector(7 downto 0);
    pll_locked           : in     std_logic;
    register_map_control : in     register_map_control_type; --! contains all read/write registers that control the application. The record members are described in pcie_package.vhd
    register_map_monitor : out    register_map_monitor_type; --! contains all status (read only) signals from the application. The record members are described in pcie_package.vhd
    reset_hard           : in     std_logic;
    reset_soft           : in     std_logic);
end entity application;



architecture rtl of application is

COMPONENT fifo_256x256
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;
ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
ATTRIBUTE SYN_BLACK_BOX OF fifo_256x256 : COMPONENT IS TRUE;
ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
ATTRIBUTE BLACK_BOX_PAD_PIN OF fifo_256x256 : COMPONENT IS "clk,rst,din[255:0],wr_en,rd_en,dout[255:0],full,empty";

  signal register_map_monitor_s  :  register_map_monitor_type;
  signal register_map_control_s  :  register_map_control_type;
  attribute dont_touch : string;
  --attribute dont_touch of register_map_monitor_s : signal is "true";
  attribute dont_touch of register_map_control_s : signal is "true";
  
  signal s_fifo_we: std_logic;
  signal s_fifo_full: std_logic;
  signal s_fifo_din: std_logic_vector(255 downto 0);
  signal cnt: std_logic_vector(31 downto 0);
  
  signal reset: std_logic;
  signal s_flush_fifo: std_logic;
  
begin

  reset <= reset_hard or reset_soft;

  register_map_monitor   <= register_map_monitor_s;
  register_map_monitor_s.PLL_LOCK(0) <= pll_locked;
  register_map_control_s <= register_map_control;

  leds <= register_map_control_s.STATUS_LEDS(7 downto 0);
  

  fifo_full <= '0';
  
  s_flush_fifo <= flush_fifo or reset;
  
  --! 
  --! Instantiation of the fifo (PCIe => PC)
  fifo0 : fifo_256x256
  PORT MAP (
    clk => fifo_rd_clk,
    rst => s_flush_fifo,
    -- Towards DMA core
    rd_en => fifo_re,
    dout => fifo_dout,
    empty => fifo_empty,
    -- Application signals
    wr_en => s_fifo_we,
    din => s_fifo_din,
    full => s_fifo_full
    
  );
  
  --! Write the fifo if it's not full
  s_fifo_we <= not s_fifo_full;
  --! Add some constants and mix it with the counter value.
  s_fifo_din <= x"DEADBEEF"&cnt&x"00001111"&cnt&x"22223333"&cnt&x"44445555"&cnt;
  
  --! write fifo with a counter and a constant at 250MHz
  process(fifo_rd_clk, reset)
  begin
    if(reset = '1') then
      cnt <= (others => '0');
    elsif (rising_edge(fifo_rd_clk)) then
      if(s_fifo_full = '0') then
        -- Make a 32 bit counter, it will be mixed with some constants and written into the fifo.
        cnt <= cnt + 1;
      else
        cnt <= cnt;
      end if;
    end if;
  end process;
  
  g0: if(NUMBER_OF_INTERRUPTS>4) generate
    interrupt_call(4 downto 4) <= register_map_control_s.INT_TEST_2;
    g1: if(NUMBER_OF_INTERRUPTS>5) generate
      interrupt_call(5 downto 5) <= register_map_control_s.INT_TEST_3;
      interrupt_call(NUMBER_OF_INTERRUPTS-1 downto 6) <= (others => '0');
    end generate;
  end generate;
  
  
  
  
  
end architecture rtl ; -- of application

