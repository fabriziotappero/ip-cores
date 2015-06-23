------------------------------------------------------------------
--!
--! PDP8 Processor
--!
--! \brief
--!      CPU Panel Exit Delay (PEX) Register
--!
--! \file
--!      pex.vhd
--!
--! \details
--!      The Panel Exit Delay (PEX) Register is set by the PEX
--!      instruction.   When a JMP, JMS, RET1, or RET2 instruction
--!      is executed with the PEX Register set, the CPU will exit
--!      panel mode.  The PEX Register is cleared by the JMP, JMS,
--!      RET1, or RET2 instruction.
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2011, 2012 Rob Doyle
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
--! CPU Panel Exit Delay (PEX) Register Entity
--

entity ePEX is port (
    sys   : in  sys_t;                          --! Clock/Reset
    pexOP : in  pexOP_t;                        --! PEX Operation
    PEX   : out std_logic                       --! PEX Output
);
end ePEX;

--
--! CPU Panel Exit Delay (PEX) Register RTL
--

architecture rtl of ePEX is

    signal pexREG : std_logic;                  --! Panel Exit Delay Register
    signal pexMUX : std_logic;                  --! Panel Exit Delay Register Multiplexer
    
begin
  
    --
    -- PEX Multiplexer
    --
  
    with pexOP select
        pexMUX <= pexREG when pexopNOP,
                  '0'    when pexopCLR,
                  '1'    when pexopSET;
    --
    --! PEX Register
    --
  
    REG_PEX : process(sys)
    begin
        if sys.rst = '1' then
            pexREG <= '0';
        elsif rising_edge(sys.clk) then
            pexREG <= pexMUX;
        end if;
    end process REG_PEX;

    PEX <= pexREG;
    
end rtl;
