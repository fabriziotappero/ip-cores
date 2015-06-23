------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Control Panel Mode (CTRLFF) Register
--!
--! \details
--!      When the CTRLFF is asserted the unit is in HD6120 Panel
--!      Mode.
--!
--!      CTRLFF is asserted when:
--!      -#  A Control Panel Request Interrupt is acknowledged.
--!      -#  A Panel Request 0 (PR0) Instruction is executed
--!          which causes a Control Panel TRAP (i.e., the
--!          PNLTRP Register is asserted).
--!      -#  A Panel Request 1 (PR1) Instruction is executed
--!          which causes a Control Panel TRAP (i.e., the
--!          PNLTRP Register is asserted).
--!      -#  A Panel Request 2 (PR2) Instruction is executed
--!          which causes a Control Panel TRAP (i.e., the
--!          PNLTRP Register is asserted).
--!      -#  A Panel Request 3 (PR3) Instruction is executed
--!          which causes a Control Panel TRAP (i.e., the
--!          PNLTRP Register is asserted).
--!
--!      CTRLFF is negated when:
--!      -#  A JMP instruction is executed after a PEX instruction
--!          is executed (i.e., the PEX Register is asserted).
--!      -#  A JMS instruction is executed after a PEX instruction
--!          is executed (i.e., the PEX Register is asserted).
--!      -#  A RTN instruction is executed after a PEX instruction
--!          is executed (i.e., the PEX Register is asserted).
--!
--!      When the unit is in HD6120 Control Panel Mode, it is
--!      operating in a mode that is not strictly PDP8 compatible.
--!      In fact, HD6120 Control Panel Mode can be used to
--!      virtualize a PDP8.  In HD6120 Control Panel mode,
--!      several new OPCODES are available, and several PDP8
--!      OPCODES are redefined.
--!
--!      Also in HD6120 mode, a whole new 32K word address space
--!      becomes available for use.
--!
--! \file
--!      ctrlff.vhd
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
--! CPU Control Panel Mode Flip-Flop (CTRLFF) Entity
--

entity eCTRLFF is port (
    sys      : in  sys_t;                       --! Clock/Reset
    ctrlffop : in  ctrlffop_t;                  --! CTRLFF Operation
    CTRLFF   : out std_logic                    --! CTRLFF Output
);
end eCTRLFF;

--
--! CPU Control Panel Mode Flip-Flop (CTRLFF) RTL
--

architecture rtl of eCTRLFF is

    signal ctrlffREG : std_logic;               --! Control Panel Flip-Flop
    signal ctrlffMUX : std_logic;               --! Control Panel Flip-Flop Multiplexer
    
begin
  
    --
    -- CTRLFF Multiplexer
    --

    with ctrlffop select
        ctrlffmux <= ctrlffREG when ctrlffopNOP, -- CTRLFF <- CTRLFF
                     '0'       when ctrlffopCLR, -- CTRLFF <- '0'
                     '1'       when ctrlffopSET; -- CTRLFF <- '1'
    
    --
    --! CTRLFF Register
    --
  
    REG_CTRLFF : process(sys)
    begin
        if sys.rst = '1' then
            ctrlffREG <= '0';
        elsif rising_edge(sys.clk) then
            ctrlffREG <= ctrlffMUX;
        end if;
    end process REG_CTRLFF;

    CTRLFF <= ctrlffREG;
    
end rtl;
