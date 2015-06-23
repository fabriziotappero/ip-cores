--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class pcie_package
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
--! This package contains the data types for the PCIe DMA core, as well as some
--! constants, addresses and register types for the application.
--! 
--! 
--! @detail
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

--! @brief ieee



library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

package pcie_package is

  --
  -- PCIe DMA core: AXI-4 Stream interface 
  type axis_type is record
    tdata   : std_logic_vector(255 downto 0);
    tkeep   : std_logic_vector(7 downto 0);
    tlast   : std_logic;
    tvalid  : std_logic;
  end record;

  type axis_r_type is record
    tready: std_logic;
  end record;

  --
  -- PCIe DMA core: descriptors 
  type dma_descriptor_type is record
    start_address   : std_logic_vector(63 downto 0);
    current_address : std_logic_vector(63 downto 0);
    end_address     : std_logic_vector(63 downto 0);
    dword_count     : std_logic_vector(10 downto 0);
    read_not_write  : std_logic;     --1 means this is a read descriptor, 0: write descriptor
    enable          : std_logic;     --descriptor is valid
    wrap_around     : std_logic;     --1 means when end is reached, keep enabled and start over
    evencycle_dma   : std_logic;     --For every time the current_address overflows, this bit toggles
    evencycle_pc    : std_logic;     --For every time the pc pointer overflows, this bit toggles.
    pc_pointer      : std_logic_vector(63 downto 0); --Last address that the PC has read / written. For write: overflow and read until this cycle. 
  end record;

  type dma_descriptors_type is array (natural range <>) of dma_descriptor_type;

  type dma_status_type is record
    descriptor_done: std_logic;  -- means the dma_descriptor in the array above has been handled, the enable field should then be cleared.
  end record;

  type dma_statuses_type is array(natural range <>) of dma_status_type;

  --
  -- PCIe DMA core: Interrupt Vectors 
  type interrupt_vector_type is record
    int_vec_add  : std_logic_vector(63 downto 0);
    int_vec_data : std_logic_vector(31 downto 0);
    int_vec_ctrl : std_logic_vector(31 downto 0);
  end record;

  type interrupt_vectors_type is array (natural range <>) of interrupt_vector_type;  

  -- BAR2 User Application Registers Addresses 
  ------------------------------------------------
  ---- Application specific registers BEGIN 🂱 ----
  ------------------------------------------------
  -- Control Registers
  constant REG_BOARD_ID            : std_logic_vector(19 downto 0) := x"00000";  
  constant REG_STATUS_LEDS         : std_logic_vector(19 downto 0) := x"00010";  
  constant REG_GENERIC_CONSTANTS   : std_logic_vector(19 downto 0) := x"00020";
  -- Monitor Registers
  constant REG_PLL_LOCK            : std_logic_vector(19 downto 0) := x"00300";
  -- Test interrupt registers.
  constant REG_INT_TEST_2          : std_logic_vector(19 downto 0) := x"01060";
  constant REG_INT_TEST_3          : std_logic_vector(19 downto 0) := x"01070";  
  ------------------------------------------------
  ---- Application specific registers END 🂱 ----
  ------------------------------------------------
  
  -- Control: Read/Write User Application Registers (Written by PCIe)
  ------------------------------------------------
  ---- Application specific registers BEGIN 🂱 ----
  ------------------------------------------------  
  type register_map_control_type is record
    STATUS_LEDS      : std_logic_vector(7 downto 0);
    INT_TEST_2       : std_logic_vector(0 downto 0);
    INT_TEST_3       : std_logic_vector(0 downto 0); 
  end record;
  
    ------------------------------------------------
  ---- Application specific registers END   🂱 ----
  ------------------------------------------------

  -- Read/Write User Application Registers Default values (Written by PCIe)
  ------------------------------------------------
  ---- Application specific registers BEGIN 🂱 ----
  ------------------------------------------------
  constant BOARD_ID_C    : std_logic_vector(63 downto 0) := x"0000000000FE71CE";
  constant STATUS_LEDS_C : std_logic_vector(7 downto 0)  := x"AA";
  ------------------------------------------------
  ---- Application specific registers END   🂱 ----
  ------------------------------------------------

  -- Monitor: Read Only User Application Registers (Read by PCIe)
  ------------------------------------------------
  ---- Application specific registers BEGIN 🂱 ----
  ------------------------------------------------
  type register_map_monitor_type is record
    READ_ONLY             : std_logic_vector(0 downto 0);    
    PLL_LOCK              : std_logic_vector(0 downto 0);    
  end record;
  ------------------------------------------------
  ---- Application specific registers END   🂱 ----
  ------------------------------------------------

  
                            
end package pcie_package ;

