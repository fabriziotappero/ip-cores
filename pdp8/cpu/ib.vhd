------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Instruction Buffer (IB) Memory Extension Register
--!
--! \details
--!      The Instruction Buffer Register (IB) is temporary
--!      storage for the Instruction Field (IF/INF) Register.
--!
--!      The IF register is not directly modifiable.  The only
--!      way to modify the IF register is to modify the IB
--!      Register and execute a Jump (JMP), Jump Subroutine
--!      (JMS), Return 1 (RTN1), or a Return 2 (RTN2)
--!      Instruction.  This mechanism synchronizes the IF
--!      update to the program context change.
--!      
--!      The IB register is modified under the following
--!      conditions:
--!      -# the IB Register is set to 0 (Memory Field 0) on
--!         entry to an interrupt, and
--!      -# the IB Register is set to 0 (Memory Field 0) when
--!         the CLEAR switch on the Front Panel is asserted, and
--!      -# the IB Register set to the contents of the AC(6:8)
--!         when executing a Restore Flags (RTF) instruction, and
--!      -# the IB Register set to 'n' (Memory Field 'n') when
--!         executing a Change Data Field (CIFn) instruction, and
--!      -# the IB Register set to 'n' (Memory Field 'n') when
--!         executing a Change Data and Instruction Field (CDIn)
--!         instruction, and
--!      -# the IB Register set to the contents of the Save Flags
--!         Register, SF(1:3), when executing a Restore Memory
--!         Field (RMF) instruction.
--!
--! \file
--!      ib.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011 Rob Doyle
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
use work.cpu_types.all;                         --! Types

--
--! CPU Instruction Buffer (IB) Memory Extension Register Entity
--

entity eIB is port (
    sys  : in  sys_t;                           --! Clock/Reset
    ibOP : in  ibop_t;                          --! IB Op
    SF   : in  sf_t;                            --! SF
    AC   : in  data_t;                          --! AC Input
    IR   : in  data_t;                          --! IR Input
    IB   : out field_t                          --! IB Output
);
end eIB;

--
--! CPU Instruction Buffer (IB) Memory Extension Register RTL
--

architecture rtl of eIB is

    signal ibREG : field_t;                     --! Instruction Buffer
    signal ibMUX : field_t;                     --! Instruction Buffer Multiplexer
    
begin

    --
    -- IB Multiplexer
    -- 

    with ibOP select
        ibMUX <= ibREG      when ibopNOP,
                 "000"      when ibopCLR,
                 AC(6 to 8) when ibopAC6to8,
                 IR(6 to 8) when ibopIR6to8,
                 SF(1 to 3) when ibopSF1to3;
      
    --
    --! IB Register
    --
  
    REG_IB : process(sys)
    begin
        if sys.rst = '1' then
            ibREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            ibREG <= ibMUX;
        end if;
    end process REG_IB;

    IB <= ibREG;
    
end rtl;
