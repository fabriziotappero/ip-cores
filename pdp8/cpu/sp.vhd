------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Stack Pointer (SP) Register
--!
--! \file
--!      sp.vhd
--!
--! \details
--!      The HD-6120 implements two stacks.  The stacks and be
--!      used to push or pop the Program Counter (PC) and/or to
--!      push or pop the Accumulator.   All other processor
--!      state can be pushed or popped using one of these two
--!      stacks.
--!
--!      The Stack Pointers are named SP1 and SP2.  The
--!      stacks grow downward in memory.
--!
--!      The Stack Pointer can be manipulated as follows:
--!      -# SP1 and SP2 are both cleared when the Front Panel
--!         CLEAR switch is asserted, and
--!      -# SPn is decremented after the PC has been stored
--!         during a PPCn instruction, and
--!      -# SPn is decremented after the AC has been stored
--!         during a PACn instruction, and
--!      -# SPn is loaded with the contents of the AC during
--!         a LSPn instruction, and
--!      -# SPn is incremented before the contents of the
--!         memory location pointed to by SPn is loaded
--!         into the PC during a RTNn instruction, and
--!      -# SPn is incremented before the contents of the
--!         memory location pointed to by SPn is loaded
--!         into the AC during a POPn instruction.
--!
--!
--! \note
--!      SP1 and SP2 are identical.  Two instances of this entity
--!      are created to make SP1 and SP2.
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
use work.cpu_types.all;                         --! Types

--
--! CPU Stack Pointer (SP) Register Entity
--

entity eSP is port (
    sys  : in  sys_t;                           --! Clock/Reset
    spop : in  spop_t;                          --! SP Operation
    AC   : in  data_t;                          --! AC register
    SP   : out addr_t                           --! SP Output
);
end eSP;

--
--! CPU Stack Pointer (SP) Register RTL
--

architecture rtl of eSP is

    signal spREG   : addr_t;                    --! Stack Pointer Register
    signal addMUX1 : addr_t;                    --! Adder Mux #1
    signal addMUX2 : addr_t;                    --! Adder Mux #2
    
begin
    
    --
    -- Adder input #1 mux.
    --
    
    with spOP select
        addMUX1 <= o"0000"    when spopNOP,     -- SP <- SP
                   o"0000"    when spopCLR,     -- SP <- o"0000"
                   o"0000"    when spopAC,      -- SP <- AC
                   o"0001"    when spopINC,     -- SP <- SP + 1
                   o"0001"    when spopDEC;     -- SP <- SP - 1
        
    --
    -- Adder input #2 mux.
    --

    with spOP select
        addMUX2 <= spREG      when spopNOP,     -- SP <- SP
                   o"0000"    when spopCLR,     -- SP <- o"0000"
                   AC         when spopAC,      -- SP <- AC
                   spREG      when spopINC,     -- SP <- SP + 1
                   not(spREG) when spopDEC;     -- SP <- SP - 1
    --
    --! SP Register
    --
  
    REG_SP : process(sys)
    begin
        if sys.rst = '1' then
            spREG <= o"0000";
        elsif rising_edge(sys.clk) then
            spREG <= std_logic_vector(unsigned(addMUX2) + unsigned(addMUX1));
        end if;
    end process REG_SP;

    SP <= spREG;
    
end rtl;
