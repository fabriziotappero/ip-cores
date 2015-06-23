------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU User Flag (UF) KM8x Time Share Register
--!
--! \details
--!      The KM8x Time Share facility allows certain of the PDP8
--!      operations to be virtualized by trapping the execution of
--!      specific instructions to an interrupt.
--!     
--!      The UF register is modified under the following
--!      conditions:
--!      -# UF is cleared when the instruction trap occurs, or
--!      -# UF is set to the contents of the UB register when a JMS
--!         instruction is executed, or
--!      -# UF is set to the contents of the UB register when a JMP
--!         instruction is executed.
--!
--!      When the UF is set and KM8E Time Sharing is enabled, all
--!      IOTs, the HLT instruction, and Switch Register input
--!      instructions trap to a User Mode Interrupt when executed
--!      otherwise the execute normally.
--!
--! \file
--!      uf.vhd
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
--! CPU User Flag (UF) KM8x Time Share Register Entity
--

entity eUF is
    port (
        sys  : in  sys_t;                       --! Clock/Reset
        ufOP : in  ufOP_t;                      --! UF Operation
        UB   : in  std_logic;                   --! UB Register
        UF   : out std_logic                    --! UF Output
    );
end eUF;

--
--! CPU User Flag (UF) KM8x Time Share Register RTL
--

architecture rtl of eUF is

    signal ufREG : std_logic;                   --! User Flag Register
    signal ufMUX : std_logic;                   --! User Flag Multiplexer
    
begin
  
    --
    -- UF Multiplexer
    --

    with ufOP select
        ufMUX <= ufREG when ufopNOP,            --! UF <- UF
                 '0'   when ufopCLR,            --! UF <- '0'
                 '1'   when ufopSET,            --! UF <- '1'
                  UB   when ufopUB;             --! UF <- UB

    --
    --! UF Register
    --
  
    REG_UF : process(sys)
    begin
        if sys.rst = '1' then
            ufREG <= '0';
        elsif rising_edge(sys.clk) then
            ufREG <= ufMUX;
        end if;
    end process REG_UF;

    UF <= ufREG;
    
end rtl;


