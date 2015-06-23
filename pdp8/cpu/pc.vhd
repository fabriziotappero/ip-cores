-----------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Program Counter (PC) Register
--!
--! \details
--!      The Program Counter (PC) Register contains the address
--!      of the next instruction to be executed.
--!
--!      A block diagram of the PC block is illustrated below.
--!
--! \image
--!      html pc.png "Program Counter Block Diagram"
--!
--!      Of note, the PC contains it's own adder which really
--!      only adds by 0 or 1.  Similarly the PC contains a
--!      couple of constants that are used for PDP8 interrupts,
--!      HD-6120 Panel Traps, etc.
--!
--! \file
--!      pc.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011, 2012 Rob Doyle
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- version 2.1 of the License.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl.txt
--
--------------------------------------------------------------------
--
-- Comments are formatted for doxygen
--

library ieee;                                   --! IEEE Library
use ieee.std_logic_1164.all;                    --! IEEE 1164
use ieee.numeric_std.all;                       --! IEEE Numeric Standard
use work.cpu_types.all;                         --! CPU Types

--
--! CPU Program Counter (PC) Register Entity
--

entity ePC is port (
    sys  : in  sys_t;                           --! Clock/Reset
    pcOP : in  pcOP_t;                          --! PC Operation
    IR   : in  data_t;                          --! Instruction Register
    MA   : in  addr_t;                          --! Memory Address Register
    MB   : in  data_t;                          --! Memory Data Register
    MD   : in  data_t;                          --! Memory Data
    SR   : in  data_t;                          --! Switch Register
    PC   : out addr_t                           --! PC Output
);
end ePC;

--
--! CPU Program Counter (PC) Register RTL
--

architecture rtl of ePC is

    signal pcREG   : addr_t;                    --! Program Counter
    signal addMUX1 : addr_t;                    --! Adder Mux #1
    signal addMUX2 : addr_t;                    --! Adder Mux #2
    signal CP      : addr_t;                    --! Current Page Addr
    signal ZP      : addr_t;                    --! Zero Page Addr
    
begin

    --
    -- Current Page and Zero Page addresses
    --
    
    CP <= MA(0 to 4) & IR(5 to 11);             -- Current Page Addr
    ZP <= "00000"    & IR(5 to 11);             -- Zero Page Addr
    
    --
    -- Adder input #1 mux.
    -- This will synthesize into a 16x12 ROM
    --
    
    with pcOP select
        addMUX1 <= o"0000" when pcopNOP,        -- PC <- PC
                   o"0000" when pcop0000,       -- PC <- "0000"
                   o"0001" when pcop0001,       -- PC <- "0001"
                   o"0000" when pcop7777,       -- PC <- "7777"
                   o"0000" when pcopMA,         -- PC <- MA
                   o"0000" when pcopMB,         -- PC <- MB
                   o"0000" when pcopMD,         -- PC <- MD
                   o"0000" when pcopSR,         -- PC <- SR
                   o"0000" when pcopZP,         -- PC <- "00000"     & IR(5 to 11)
                   o"0000" when pcopCP,         -- PC <- MA(0 to 4)  & IR(5 to 11) 
                   o"0001" when pcopINC,        -- PC <- PC + 1
                   o"0001" when pcopMAP1,       -- PC <- MA + 1
                   o"0001" when pcopMBP1,       -- PC <- MB + 1
                   o"0001" when pcopMDP1,       -- PC <- MD + 1
                   o"0001" when pcopZPP1,       -- PC <- ("00000"    & IR(5 to 11)) + "1"
                   o"0001" when pcopCPP1;       -- PC <- (MA(0 to 4) & IR(5 to 11)) + "1"
        
    --
    -- Adder input #2 mux.
    --

    with pcOP select
        addMUX2 <= pcREG   when pcopNOP,        -- PC <- PC
                   o"0000" when pcop0000,       -- PC <- "0000"
                   o"0000" when pcop0001,       -- PC <- "0001"
                   o"7777" when pcop7777,       -- PC <- "7777"
                   MA      when pcopMA,         -- PC <- MA
                   MB      when pcopMB,         -- PC <- MB
                   MD      when pcopMD,         -- PC <- MD
                   SR      when pcopSR,         -- PC <- SR
                   ZP      when pcopZP,         -- PC <- "00000"     & IR(5 to 11
                   CP      when pcopCP,         -- PC <- MA(0 to 4)  & IR(5 to 11) 
                   pcREG   when pcopINC,        -- PC <- PC + 1
                   MA      when pcopMAP1,       -- PC <- MA + 1
                   MB      when pcopMBP1,       -- PC <- MB + 1
                   MD      when pcopMDP1,       -- PC <- MD + 1
                   ZP      when pcopZPP1,       -- PC <- ("00000"    & IR(5 to 11)) + "1"
                   CP      when pcopCPP1;       -- PC <- (MA(0 to 4) & IR(5 to 11)) + "1"
  
    --
    --! PC Register
    --
  
    REG_PC : process(sys)
    begin
        if sys.rst = '1' then
            pcREG <= o"0000";
        elsif rising_edge(sys.clk) then
            pcREG <= std_logic_vector(unsigned(addMUX2) + unsigned(addMUX1));
        end if;
    end process REG_PC;

    PC <= pcREG;
    
end rtl;
