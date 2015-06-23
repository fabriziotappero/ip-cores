------------------------------------------------------------------
--!
--! PDP- Processor
--!
--! \brief
--!      CPU Interrupt Inhibit (II) Register
--!
--! \details
--!      The Interrupt Inhibit (II) Register is set whenever there
--!      is an instruction executed that could change the
--!      Instruction Field (IF) Register.  These include CIF, CDI,
--!      RMF, RTF, CAF, CUF, SUF.  The II Register is cleared when
--!      the next JMP, JMS, RTN1, or RTN2 instruction is executed.
--! 
--!      This prevents an interrupt from occuring between the CIF
--!     (or like) instruction and the return (or like) instruction.
--!
--! \file
--!      ii.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2011, 2010 Rob Doyle
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
--! CPU Interrupt Inhibit (II) Register Entity
--

entity eII is port (
    sys  : in  sys_t;                           --! Clock/Reset
    iiOP : in  iiop_t;                          --! II Operation
    II   : out std_logic                        --! II Output
);
end eII;

--
--! CPU Interrupt Inhibit (II) Register RTL
--

architecture rtl of eII is

    signal iiREG : std_logic;                   --! Interrupt Inhibit Flip-Flop
    signal iiMUX : std_logic;                   --! Interrupt Inhibit Flip-Flop Multiplexer
    
begin
  
    --
    -- II Multiplexer
    --
    
    with iiOP select
        iiMUX <= iiREG when iiopNOP,
                 '0'   when iiopCLR,
                 '1'   when iiopSET;

    --
    --! II Register
    --
  
    REG_II : process(sys)
    begin
        if sys.rst = '1' then
            iiREG <= '0';
        elsif rising_edge(sys.clk) then
            iiREG <= iiMUX;
        end if;
    end process REG_II;

    II <= iiREG;
    
end rtl;
