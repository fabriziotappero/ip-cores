------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Instruction Register (IR)
--!
--! \details
--!      The Instruction Register (IR) contains the opcode of the
--!      current instruction.
--!
--! \note
--!      The IR implementation is mostly a waste of a state.  A
--!      state in the state machine could be saved by just
--!      decoding the content of the MD register after an
--!      instruction fetch.
--!
--! \file
--!      ir.vhd
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
--! CPU Instruction Register (IR) Entity
--

entity eIR is port (
    sys   : in  sys_t;                          --! Clock/Reset
    irOP  : in  irOP_t;                         --! IR Operation
    MD    : in  data_t;                         --! MD Input
    IR    : out data_t                          --! IR Output
);
end eIR;

--
--! CPU Instruction Register (IR) RTL
--

architecture rtl of eIR is

    signal irREG : data_t;                      -- Instruction Register
    signal irMUX : data_t;                      -- Instruction Register MUX

begin

    --
    -- IR Multiplexer
    --

    with irOP select
        irMUX <= irREG when iropNOP,
                 MD    when iropMD;
    
    --
    --! IR Register
    --
  
    REG_IR : process(sys)
    begin
        if sys.rst = '1' then
            irREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            irREG <= irMUX;
        end if;
    end process REG_IR;

    IR <= irREG;
    
end rtl;
