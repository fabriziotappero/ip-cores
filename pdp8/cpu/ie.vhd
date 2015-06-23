------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Interrupt Enable (IE) Register
--!
--!      The IE register is modified under the following
--!      conditions:
--!      -# the IE Register is cleared on entry to an interrupt,
--!         and
--!      -# the IE Register is cleared when the Front Panel CLEAR
--!         switch is asserted, and
--!      -# the IE Register is cleared when the Skip If Interupt
--!         System Is On (SKON) instruction is executed, and
--!      -# the IE Register is cleared when the Interrupt Disable
--!         (IOF) instruction is executed, and
--!      -# the IE Register is set when the Interrupt Enable
--!         (ION) instruction is executed, and
--!
--! \note
--!      Per tribal knowledge, several unimplemented
--!      instructions have the side-effect of performing an
--!      interrupt Enable (ION) instruction which also sets
--!      the IE Register.  These are enumerated in the CPU
--!      VHDL code, but not summarized here.
--!
--! \file
--!      ie.vhd
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
--! CPU Interrupt Enable (IE) Register Entity
--

entity eIE is port (
    sys  : in  sys_t;                           --! Clock/Reset
    ieOP : in  ieOP_t;                          --! IE Operation
    IE   : out std_logic                        --! IE Output
);
end eIE;

--
--! CPU Interrupt Enable (IE) Register RTL
--

architecture rtl of eIE is
    
    signal ieREG   : std_logic;               --! Interrupt Enable Flip-Flop
    signal ieMUX   : std_logic;               --! Interrupt Enable Flip-Flop Multiplexer
    
begin
  
    --
    -- IE Multiplexer
    --

    with ieOP select
        ieMUX <= ieREG when ieopNOP,
                 '0'   when ieopCLR,
                 '1'   when ieopSET;
    
    --
    --! IE Register
    --
  
    REG_IE : process(sys)
    begin
        if sys.rst = '1' then
            ieREG <= '0';
        elsif rising_edge(sys.clk) then
            ieREG <= ieMUX;
        end if;
    end process REG_IE;

    IE <= ieREG;
    
end rtl;
