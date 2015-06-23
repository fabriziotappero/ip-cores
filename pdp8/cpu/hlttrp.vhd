------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Halt Trap Flip-Flop (HLTTRP)
--!
--! \details
--!      When the Halt Trap Flip-Flop is asserted, the CPU will
--!      HALT at the end of the current instruction.
--!
--!      The HLTTRB register is modified under the following
--!      conditions:
--!      -# the HLTTRP Register is cleared on entry to the HALT
--!         state, and
--!      -# the HLTTRP Register is set when a Halt (HLT)
--!         instruction is executed, and
--!      -# the HLTTRP Register is cleared when the unit is
--!         configured as a HD-6120, and the unit is in Panel
--!         Mode, and the Panel Go (PGO) instruction is
--!         executed.
--!
--! \file
--!      hlttrp.vhd
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
use work.cpu_types.all;                         --! Types

--
--! CPU Halt Trap Flip-Flop (HLTTRP) Entity
--

entity eHLTTRP is port (
    sys      : in  sys_t;                    	--! Clock/Reset
    hlttrpOP : in  hlttrpOP_t;                  --! HLTTRP Operation
    HLTTRP   : out std_logic                    --! HLTTRP Output
);
end eHLTTRP;

--
--! CPU Halt Trap Flip-Flop (HLTTRP) RTL
--

architecture rtl of eHLTTRP is

    signal hlttrpREG : std_logic;               --! Hlttrp Flip-Flop
    signal hlttrpMUX : std_logic;               --! Hlttrp Flip-Flop Multiplexer
    
begin
  
    --
    -- HLTTRP Multiplexer
    --

    with hlttrpOP select
        hlttrpMUX <= hlttrpREG when hlttrpopNOP,
                     '0'      when hlttrpopCLR,
                     '1'      when hlttrpopSET;
    
    --
    --! HLTTRP Register
    --
  
    REG_HLTTRP : process(sys)
    begin
        if sys.rst = '1' then
            hlttrpREG <= '0';
        elsif rising_edge(sys.clk) then
            hlttrpREG <= hlttrpMUX;
        end if;
    end process REG_HLTTRP;

    HLTTRP <= hlttrpREG;
    
end rtl;
