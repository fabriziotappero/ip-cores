------------------------------------------------------------------
--!
--! PDP8 Processor
--!
--! \brief
--!      CPU Panel Mode Trap (PNLTRP) Register
--!
--! \details
--!      A Panel Trap is one of the many ways to enter Panel Mode.  
--!
--!      If the unit is configured as a HD-6120 and the ION Delay
--!      (ID) Register is cleared and the Interrupt Inhibit (II)
--!      Register is cleared and the unit is not in Panel Mode,
--!      (CTRLFF cleared) then before the next instruction the
--!      unit will execute a Panel Trap by saving the return
--!      address in address 0000 and vectoring to address 7777.
--!      
--!      The PNLTRP register is modified under the following
--!      conditions:
--!      -# the PNLTRP Register is cleared if the unit is
--!         configured as a HD-6120 and the unit is in Panel
--!         Mode (CTRLFF asserted) and a Panel Read Status
--!         (PRS) instruction is executed.
--!      -# the PNLTRP Register is cleared if the unit is
--!         configured as a HD-6120 and the unit is in Panel
--!         Mode (CTRLFF asserted) and a Panel Exit
--!         (PEX) instruction is executed.
--!      -# the PNLTRP Register is set if the unit is
--!         configured as a HD-6120 and the unit is not in Panel
--!         Mode (CTRLFF negated) and a Panel Request 0
--!         (PR0) instruction is executed.
--!      -# the PNLTRP Register is set if the unit is
--!         configured as a HD-6120 and the unit is not in Panel
--!         Mode (CTRLFF negated) and a Panel Request 1
--!         (PR1) instruction is executed.
--!      -# the PNLTRP Register is set if the unit is
--!         configured as a HD-6120 and the unit is not in Panel
--!         Mode (CTRLFF negated) and a Panel Request 2
--!         (PR2) instruction is executed.
--!      -# the PNLTRP Register is set if the unit is
--!         configured as a HD-6120 and the unit is not in Panel
--!         Mode (CTRLFF negated) and a Panel Request 3
--!         (PR3) instruction is executed.
--!
--! \file
--!      pnltrp.vhd
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
use ieee.numeric_std.all;                       --! IEEE Numeric Standard
use work.cpu_types.all;                         --! Types

--
--! CPU Panel Mode Trap (PNLTRP) Register Entity
--

entity ePNLTRP is port (
    sys      : in  sys_t;                       --! Clock/Reset
    pnltrpOP : in  pnltrpop_t;                  --! PNLTRP Operation
    PNLTRP   : out std_logic                    --! PNLTRP Output
);
end ePNLTRP;

--
--! CPU Panel Mode Trap (PNLTRP) Register RTL
--

architecture rtl of ePNLTRP is

    signal pnltrpREG : std_logic;               --! Panel Trap Flip-Flop
    signal pnltrpMUX : std_logic;               --! Panel Trap Flip-Flop Multiplexer
    
begin
  
    --
    -- PNLTRP Multiplexer
    --
  
    with pnltrpOP select
        pnltrpMUX <= pnltrpREG when pnltrpopNOP,
                     '0'       when pnltrpopCLR,
                     '1'       when pnltrpopSET;
    
    --
    --! PNLTRP Register
    --
  
    REG_PNLTRP : process(sys)
    begin
        if sys.rst = '1' then
            pnltrpREG <= '0';
        elsif rising_edge(sys.clk) then
            pnltrpREG <= pnltrpMUX;
        end if;
    end process REG_PNLTRP;

    PNLTRP <= pnltrpREG;
    
end rtl;
