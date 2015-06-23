-------------------------------------------------------------------------------
-- Title      : Genereic synchronous Dual port memory
-- Project    : Memory Cores
-------------------------------------------------------------------------------
-- File        : DPMEM2CLK.VHD
-- Author      : Jamil Khatib  <khatib@ieee.org>
-- Organization: OpenIPCore Project
-- Created     : 2000/03/29
-- Last update : 2000/03/29
-- Platform    : 
-- Simulators  : Modelsim 5.2EE / Windows98 & Xilinx modelsim 5.3a XE
-- Synthesizers: Leonardo / WindowsNT & Xilinx webfitter
-- Target      : Flex10KE
-- Dependency  : 
-------------------------------------------------------------------------------
-- Description: Genereic synchronous Dual port memory
--                        : Seperate read and write clocks
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
-- Version              :   1.0
-- Date             :   29th Mar 2000
-- Modifier     :   Jamil Khatib (khatib@ieee.org)
-- Desccription :       Created
--
-------------------------------------------------------------------------------


library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 

-------------------------------------------------------------------------------
-- Synchronous Dual Port Memory
-------------------------------------------------------------------------------
entity Dpmem2clk is
  
  generic (
    ADD_WIDTH         :     integer   := 4;  -- Address width
    WIDTH             :     integer   := 8;  -- Word Width
    coretype          :     integer   := 0);  -- memory bulding block type
  
  port (
    Wclk              : in  std_logic;  -- write clock
    Wen               : in  std_logic;  -- Write Enable
    Wadd              : in  std_logic_vector(ADD_WIDTH -1 downto 0);  -- Write Address
    Datain            : in  std_logic_vector(WIDTH -1 downto 0);  -- Input Data
    Rclk              : in  std_logic;  -- Read clock
    Ren               : in  std_logic;  -- Read Enable
    Radd              : in  std_logic_vector(ADD_WIDTH -1 downto 0);  -- Read Address
    Dataout           : out std_logic_vector(WIDTH -1 downto 0));  -- Output data
  
end Dpmem2clk; 

architecture dpmem_arch of Dpmem2clk is
  
  type DATA_ARRAY is array (integer range <>) of std_logic_vector(WIDTH -1 downto 0); 
                                        -- Memory Type
  signal   data       :     DATA_ARRAY(0 to (2**ADD_WIDTH) -1);  -- Local data
  constant IDELOUTPUT :     std_logic := 'Z';  -- IDEL state output
  
begin  -- dpmem_arch
  
  -- purpose: Read process
  -- type   : sequential
  -- inputs : Rclk
  -- outputs: 
  ReProc              :     process (Rclk)
  begin  -- process ReProc
    
    if Rclk'event and Rclk = '1' then   -- rising clock edge
      if Ren = '1' then
        Dataout                       <= data(conv_integer(Radd)); 
      else
        Dataout                       <= (others => IDELOUTPUT); 
      end if; 
      
    end if; 
  end process ReProc; 
  
  -- purpose: Write process
  -- type   : sequential
  -- inputs : Wclk
  -- outputs: 
  WrProc              :     process (Wclk)
  begin  -- process WrProc
    
    if Wclk'event and Wclk = '1' then   -- rising clock edge
      if Wen = '1' then
        
        data(conv_integer(Wadd))      <= Datain; 
      end if; 
      
    end if; 
  end process WrProc; 
  
end dpmem_arch; 







