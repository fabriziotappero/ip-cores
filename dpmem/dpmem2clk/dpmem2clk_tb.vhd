-------------------------------------------------------------------------------
-- Title      : dpmem Test Bench
-- Project    : Memory Cores/FIFO
-------------------------------------------------------------------------------
-- File        : DPMEM2CLK_TB.VHD
-- Author      : Jamil Khatib  <khatib@ieee.org>
-- Organization: OpenIPCore Project
-- Created     : 2000/03/19
-- Last update : 2000/03/19
-- Platform    : 
-- Simulators  : Modelsim 5.2EE / Windows98
-- Synthesizers: 
-- Target      :
-- Dependency  : It uses VHDL 93 file syntax
-------------------------------------------------------------------------------
-- Description: Dual port memory Test bench
-------------------------------------------------------------------------------
-- Copyright (c) 2000 Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it under the terms of the Openip General Public
-- License as it is going to be published by the OpenIPCore Organization and
-- any coming versions of this license.
-- You can check the draft license at
-- http://www.openip.org/oc/license.html

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number : 1
-- Version              :   0.1
-- Date             :   19th Mar 2000
-- Modifier     :   Jamil Khatib (khatib@ieee.org)
-- Desccription :       Created
--
-------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_1164.all; 
use ieee.STD_LOGIC_UNSIGNED.all; 

use std.textio.all; 

entity dpmem2clk_tb is
  -- Generic declarations of the tested unit
  generic(
    WIDTH                                    :       integer   := 8; 
    ADD_WIDTH                                :       integer   := 4; 
    RCLKTIME                                 :       time      := 100 ns; 
    WCLKTIME                                 :       time      := 90 ns; 
    OUTPUTDELAY                              :       time      := 40 ns  -- output delay after teh rising edge
                                        -- of the clock
    ); 
end dpmem2clk_tb; 


library ieee; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_1164.all; 
use ieee.STD_LOGIC_UNSIGNED.all; 

library synopsys; 
use synopsys.arithmetic.all; 

architecture behavior of dpmem2clk_tb is
  
  constant                    MAX_STATES     :       integer   := 16; 
  
  component dpmem2clk
    
    generic (
      ADD_WIDTH                              :       integer   := ADD_WIDTH;  -- Address width
      WIDTH                                  :       integer   := WIDTH;  -- Word Width
      coretype                               :       integer   := 0);  -- memory bulding block type
    
    port (
      Wclk                                   : in    std_logic;  -- write clock
      Wen                                    : in    std_logic;  -- Write Enable
      Wadd                                   : in    std_logic_vector(ADD_WIDTH -1 downto 0);  -- Write Address
      Datain                                 : in    std_logic_vector(WIDTH -1 downto 0);  -- Input Data
      Rclk                                   : in    std_logic;  -- Read clock
      Ren                                    : in    std_logic;  -- Read Enable
      Radd                                   : in    std_logic_vector(ADD_WIDTH -1 downto 0);  -- Read Address
      Dataout                                : out   std_logic_vector(WIDTH -1 downto 0));  -- Output data
    
  end component; 
  
  type TABLE_typ is array (0 to MAX_STATES - 1 ) of std_logic_vector( 1 downto 0); 
  
  signal                      TABLE          :       TABLE_typ; 
  
  
  
  --INITs the table
  procedure init_table(signal L_TABLE        : inout TABLE_typ
                       ) is
  begin
    L_TABLE                                                    <= (
      "00",                             --nn
      "10",                             --wn
      "10",                             --wn
      "11",                             --wr
      "11",                             --wr
      "01",                             --nr
      "01",                             --nr
      "01",                             --nr
      "10",                             --wn
      "11",                             --wr
      "10",                             --wn
      "01",                             --nr
      "01",                             --nr
      "01",                             --nr
      "11",                             --wr
      "00"                              --nn
      ); 
    
  end; 
  
  
  
  signal                      wclk_tb        :       std_logic := '0'; 
  signal                      wen_tb         :       std_logic; 
  signal                      wadd_tb        :       std_logic_vector( ADD_WIDTH-1 downto 0); 
  signal                      datain_tb      :       std_logic_vector(WIDTH -1 downto 0); 
  signal                      rclk_tb        :       std_logic := '0'; 
  signal                      ren_tb         :       std_logic; 
  signal                      radd_tb        :       std_logic_vector(ADD_WIDTH -1 downto 0); 
  signal                      dataout_tb     :       std_logic_vector(WIDTH -1 downto 0); 
  signal                      dataout_tb_syn :       std_logic_vector(WIDTH -1 downto 0); 
  signal                      reset          :       std_logic; 
  
  
  
begin
  
-- Reset generation
  reset                                                        <= transport '0'                               after 0 ns, 
                                                                  '1'                                         after 10 ns; 
  
-- Clock generation
  rclk_tb                                                      <= not rclk_tb                                 after RCLKTIME/2; 
  wclk_tb                                                      <= not wclk_tb                                 after WCLKTIME/2; 
  
-- UUT componenet 
  uut                                        :       dpmem2clk
    generic map
    (
      ADD_WIDTH => ADD_WIDTH, 
      WIDTH     => WIDTH, 
      coretype  => 0
      )
    
    port map (
      
      Wclk      => wclk_tb, 
      Wen       => wen_tb, 
      Wadd      => wadd_tb, 
      Datain    => datain_tb, 
      Rclk      => rclk_tb, 
      Ren       => ren_tb, 
      Radd      => radd_tb, 
      Dataout   => dataout_tb
      
      ); 
  
  
  uut_syn                                    :       dpmem2clk
    port map (
      
      Wclk      => wclk_tb, 
      Wen       => wen_tb, 
      Wadd      => wadd_tb, 
      Datain    => datain_tb, 
      Rclk      => rclk_tb, 
      Ren       => ren_tb, 
      Radd      => radd_tb, 
      Dataout   => dataout_tb_syn
      
      ); 
  
  
-- Read process 
  read_proc                                  :       process(rclk_tb, reset)
    variable                  count          :       integer; 
    variable                  readcount      :       integer   := 0; 
  begin
    if reset = '0' then
      init_table(TABLE); 
      
    elsif rclk_tb'event and rclk_tb = '1' then
      
      
      count                                                    := count +1; 
      
      if count > (MAX_STATES-1) or count < 0 then
        count                                                  := 0; 
      end if; 
      
      ren_tb                                                   <= TABLE(readcount)(0)                         after OUTPUTDELAY; 
      readcount                                                := readcount +1; 
      
      
      if readcount > ((2**ADD_WIDTH)-1) or readcount < 0 then
        readcount                                              := 0; 
      end if; 
    end if; 
    
    radd_tb                                                    <= conv_std_logic_vector(readcount, ADD_WIDTH) after OUTPUTDELAY; 
    
  end process read_proc; 
  
  
-- Write process 
  write_proc                                 :       process(wclk_tb, reset)
    variable                  count          :       integer; 
    variable                  writecount     :       integer   := 0; 
    variable                  dataincount    :       integer   := 0; 
  begin
    
    if wclk_tb'event and wclk_tb = '1' then
      
      
      count                                                    := count +1; 
      
      if count > (MAX_STATES-1) or count < 0 then
        count                                                  := 0; 
        
      end if; 
      
      writecount                                               := writecount +1; 
      
      
      if writecount > ((2**ADD_WIDTH)-1) or writecount < 0 then
        writecount                                             := 0; 
      end if; 
      
      wadd_tb                                                  <= conv_std_logic_vector(writecount, ADD_WIDTH); 
      
      wen_tb                                                   <= TABLE(writecount)(1)                        after OUTPUTDELAY; 
      
      dataincount                                              := dataincount +1; 
      
      if dataincount > (WIDTH-1) or dataincount < 0 then
        dataincount                                            := 0; 
      end if; 
      
      datain_tb                                                <= conv_std_logic_vector(dataincount, WIDTH)   after OUTPUTDELAY; 
      
    end if; 
  end process write_proc; 
  
  
end; 


-- Test bench Configuration
configuration TESTBENCH_FOR_DPMEM of dpmem2clk_tb is
  for behavior
    for UUT                                  :       dpmem2clk
      use entity work.dpmem2clk(dpmem_arch); 
    end for; 
    
    for UUT_syn                              :       dpmem2clk
      use entity work.dpmem2clk(STRUCTURE); 
    end for; 
    
  end for; 
end TESTBENCH_FOR_DPMEM; 
