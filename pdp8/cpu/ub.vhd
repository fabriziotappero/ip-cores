------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU User Buffer (UB) KM8x Time Share Register
--!
--! \details
--!      The User Buffer Register UB) is temporary storage for the
--!      User Flag (UF) register.
--!
--!      The UB register ia modified under the following conditions:
--!      -# set to the contents of AC(5) when the unit
--!         configured for PDP8 (not HD-6120) and a Restore Flags
--!         (RTF) instruction is executed, or
--!      -# set to the contents of SF(0) when a Restore Memory
--!         Field (RMF) instruction is executed, or
--!      -# set when a Set User Flag (SUF) instruction is
--!         executed, or
--!      -# cleared when a Clear User Flag (CUF) instruction is
--!         executed, or
--!      -# cleared when an interrupt occurs.
--!
--!      The UB register is transfered into the UF register under
--!      the following conditions:
--!      -# JMS Instruction executed, or
--!      -# JMP Instruction executed.
--!
--! \file
--!      ub.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009 Rob Doyle
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
use work.cpu_types.all;                         --! Types

--
--! CPU User Buffer (UB) KM8x Time Share Register Entity
--

entity eUB is port (
    sys  : in  sys_t;                           --! Clock/Reset
    ubOP : in  ubOP_t;                          --! UB Operation
    AC5  : in  std_logic;                       --! LAC Regiter
    SF0  : in  std_logic;                       --! SF Register bit 0
    UB   : out std_logic                        --! UB Output
);
end eUB;

--
--! CPU User Buffer (UB) KM8x Time Share Register RTL
--

architecture rtl of eUB is

    signal ubREG : std_logic;                   --! User Buffer Flag
    signal ubMUX : std_logic;                   --! User Buffer Flag Multiplexer
    
begin
  
    --
    -- UB Multiplexer
    --

    with ubOP select
         ubMUX <= ubREG when ubopNOP,
                  '0'   when ubopCLR,
                  '1'   when ubopSET,
                  AC5   when ubopAC5,
                  SF0   when ubopSF;

    --
    --! REG_UB Register
    --
  
    REG_UB : process(sys)
    begin
        if sys.rst = '1' then
            ubREG <= '0';
        elsif rising_edge(sys.clk) then
            ubREG <= ubMUX;
        end if;
    end process REG_UB;

    UB <= ubREG;
    
end rtl;
