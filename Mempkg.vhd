-------------------------------------------------------------------------------
-- Title      : Memory Package
-- Project    : Memory Cores
-------------------------------------------------------------------------------
-- File        : MEMPKG.VHD
-- Author      : Jamil Khatib  <khatib@ieee.org>
-- Organization: OpenIPCore Project
-- Created     : 2000/02/29
-- Last update : 2000/02/29
-- Platform    : 
-- Simulators  : Modelsim 5.2EE / Windows98
-- Synthesizers: Leonardo / WindowsNT
-- Target      : Flex10K
-------------------------------------------------------------------------------
-- Description: Memory Package
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
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   29th Feb 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   2
-- Version         :   0.2
-- Date            :   29th Mar 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Memory components are added.
--
-------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 

package mempkg is

  constant ADD_WIDTH : integer := 8;    -- Address width
  constant WIDTH     : integer := 4;    -- Data width

  function slv_2_int (
    SLV : std_logic_vector )
    return integer; 
  

  component dpmem2clk
    
    generic (
      ADD_WIDTH :     integer := ADD_WIDTH;  -- Address width
      WIDTH     :     integer := WIDTH;  -- Word Width
      coretype  :     integer := 0);    -- memory bulding block type
    
    port (
      Wclk      : in  std_logic;        -- write clock
      Wen       : in  std_logic;        -- Write Enable
      Wadd      : in  std_logic_vector(ADD_WIDTH -1 downto 0);  -- Write Address
      Datain    : in  std_logic_vector(WIDTH -1 downto 0);  -- Input Data
      Rclk      : in  std_logic;        -- Read clock
      Ren       : in  std_logic;        -- Read Enable
      Radd      : in  std_logic_vector(ADD_WIDTH -1 downto 0);  -- Read Address
      Dataout   : out std_logic_vector(WIDTH -1 downto 0));  -- Output data
    
  end component; 
  

  component dpmem
    generic (ADD_WIDTH :     integer := 4; 
             WIDTH     :     integer := 8 ); 
    
    port (clk          : in  std_logic; 
          reset        : in  std_logic; 
          w_add        : in  std_logic_vector(ADD_WIDTH -1 downto 0 ); 
          r_add        : in  std_logic_vector(ADD_WIDTH -1 downto 0 ); 
          data_in      : in  std_logic_vector(WIDTH - 1 downto 0); 
          data_out     : out std_logic_vector(WIDTH - 1 downto 0 ); 
          WR           : in  std_logic; 
          RE           : in  std_logic); 
  end component; 
end mempkg; 

-------------------------------------------------------------------------------

package body mempkg is
  
-------------------------------------------------------------------------------
  function slv_2_int (
    SLV                :     std_logic_vector)  -- std_logic_vector to convert
    return integer is
    
    variable Result    :     integer := 0;  -- conversion result
    
  begin
    for i in SLV'range loop
      Result                         := Result * 2;  -- shift the variable to left
      case SLV(i) is
        when '1' | 'H' => Result     := Result + 1; 
        when '0' | 'L' => Result     := Result + 0; 
        when others    => null; 
      end case; 
    end loop; 
    
    return Result; 
  end; 
-------------------------------------------------------------------------------
  
end mempkg; 

-------------------------------------------------------------------------------
