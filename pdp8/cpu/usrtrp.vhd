------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU User Mode Trap (USRTRP) Register
--!
--! \details
--!      The User Mode Trap is used with the KM8E Time Sharing.
--!
--!      When the User Flag (UF) is set and KM8E Time Sharing is
--!      enabled, all IOTs, the HLT instruction, and Switch
--!      Register input instructions are virtualized by trapping
--!      to a User Mode Interrupt.
--!
--!      The User Mode Trap (USRTRP) register is asserted under
--!      the following conditions:
--!      -# the User Flag (UF) set and KM8E TSS enabled and any
--!         IOT Instruction executed, or
--!      -# the User Flag (UF) set and KM8E TSS enabled and HLT
--!         Instruction executed, or
--!      -# the User Flag (UF) set and KM8E TSS enabled and Switch
--!         Register Instruction (either OSR or LAS) executed.
--!
--!      The User Mode Trap (USRTRP) register is negated under
--!      the following conditions:
--!      -# the front panel Clear Switch asserted, or
--!      -# the Clear All Flags (CAF) instruction is executed, or
--!      -# the Clear User Interrupt Flag (CINT) instruction is
--!         executed.
--!
--! \file
--!      usrtrp.vhd
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
--! CPU User Mode Trap (USRTRP) Register Entity
--

entity eUSRTRP is port (
    sys      : in  sys_t;                       --! Clock/Reset
    usrtrpOP : in  usrtrpOP_t;                  --! USRTRP Operation
    USRTRP   : out std_logic                    --! USRTRP Output
);
end eUSRTRP;

--
--! CPU User Mode Trap (USRTRP) Register RTL
--

architecture rtl of eUSRTRP is

    signal usrtrpREG : std_logic;               --! USRTRP Flag
    signal usrtrpMUX : std_logic;               --! USRTRP Flag Multiplexer
    
begin
  
    --
    -- USRTRP Multiplexer
    --

    with usrtrpOP select
        usrtrpMUX <= usrtrpREG when usrtrpopNOP,
                     '0'       when usrtrpopCLR,
                     '1'       when usrtrpopSET;
    
    --
    --! USRTRP Register
    --
  
    REG_USRTRP : process(sys)
    begin
        if sys.rst = '1' then
            usrtrpREG <= '0';
        elsif rising_edge(sys.clk) then
            usrtrpREG <= usrtrpMUX;
        end if;
    end process REG_USRTRP;

    USRTRP <= usrtrpREG;
    
end rtl;
