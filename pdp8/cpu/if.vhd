------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Instruction Field (IF/INF) Memory Extension Register
--!
--! \details
--!      The Instruction Field (IF) Register is a Memory Extension
--!      Register that is used to supply the Extended Memory
--!      Address (EMA/XMA) during Instruction Fetches and non-
--!      indirect data operations.
--!
--!      The IF register is modified under the following
--!      conditions:
--!      -# the IF Register is set to 0 (Memory Field 0) on
--!         entry to an interrupt, and
--!      -# the IF Register is set to 0 (Memory Field 0) when
--!         the CLEAR switch on the Front Panel is asserted, and
--!      -# the IF Register set to the contents of the Front
--!         Panel Data Switch Register, SR(6:10), when the
--!         EXTD switch is asserted, and
--!      -# the IF Register is set to the contents of the
--!         Instruction Buffer Register (IB) after any indirect
--!         data operations when executing an Jump to Subroutine
--!         (JMS) instruction.
--!      -# the IF Register is set to the contents of the
--!         Instruction Buffer Register (IB) after any indirect
--!         data operations when executing an Jump (JMP)
--!         instruction.
--!      -# the IF Register is set to the contents of the
--!         Instruction Buffer Register (IB) when executing a
--!         Return (RTN1 or RTN2) instruction.
--!
--! \file
--!      if.vhd
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
--! CPU Instruction Field (IF/INF) Memory Extension Register Entity
--

entity eIF is port (
    sys  : in  sys_t;                           --! Clock/Reset
    ifOP : in  ifOP_t;                          --! IF Op
    IB   : in  field_t;                         --! IB Input
    SR   : in  data_t;                          --! SR Input
    INF  : out field_t                          --! IF Output
);
end eIF;

--
--! CPU Instruction Field (IF/INF) Memory Extension Register RTL
--

architecture rtl of eIF is

    signal ifREG : field_t;                     --! Instruction Field
    signal ifMUX : field_t;                     --! Instruction Field Multiplexer
    
begin

    --
    -- IF Multiplexer
    -- 

    with ifOP select
        ifMUX <= ifREG      when ifopNOP,
                 "000"      when ifopCLR,
                 IB         when ifopIB,
                 SR(6 to 8) when ifopSR6to8;
    
    --
    --! IF Register
    --
  
    REG_IF : process(sys)
    begin
        if sys.rst = '1' then
            ifREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            ifREG <= ifMUX;
        end if;
    end process REG_IF;

    INF <= ifREG;
    
end rtl;
