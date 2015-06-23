------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Greater Than Flag (GTF) Register
--!
--! \details
--!      The Greater Than Flag has several uses.
--!
--!      The GTF Register is modified under the following
--!      conditions:
--!      -# the GTF Register is set to 0 when the CLEAR switch
--!         on the Front Panel is asserted, and
--!      -# the GTF Register is set to 0 when the Clear All Flags
--!         (CAF) instruction is executed, and
--!      -# the GTF Register is set to 0 when EAE Mode B and the
--!         Switch from B to A (SWBA) instruction is executed, and
--!      -# the GTF Register is set to 0 when EAE Mode A before
--!         any EAE Mode A instruction is executed, and
--!      -# the GTF Register is set to 0 when the Clear All Flags
--!         (CAF) instruction is executed, and
--!      -# the GTF Register set to the contents of the AC(1)
--!         when executing a Restore Flags (RTF) instruction, and
--!      -# the GTF Register set if signed(MQ) >= signed(AC),
--!         otherwise cleared after executing a Subtract AC
--!         from MQ (SAM) instruction, and
--!      -# the GTF Register is set in EAE Mode B if a '1'
--!         is shifted out of the LSB during a Arithmetic
--!         Shift Right (ASR) instruction.
--!      -# the GTF Register is set in EAE Mode B if a '1'
--!         is shifted out of the LSB during a Logical
--!         Shift Right (LSR) instruction.
--! 
--! \file
--!      gtf.vhd
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
--! CPU Greater Than Flag (GTF) Register Entity
--

entity eGTF is port (
    sys   : in  sys_t;                          --! Clock/Reset
    gtfOP : in  gtfOP_t;                        --! GTF Operation
    AC    : in  data_t;                         --! AC Register
    GTF   : out std_logic                       --! GTF Output
);
end eGTF;

--
--! CPU Greater Than Flag (GTF) Register RTL
--

architecture rtl of eGTF is

    signal gtfREG : std_logic;                  -- Greater Than Flag
    signal gtfMUX : std_logic;                  -- Greater Than Flag Multiplexer
    
begin
  
    --
    -- GTF Multiplexer
    --

    with gtfOP select
        gtfMUX <= gtfREG when gtfopNOP,
                  '0'    when gtfopCLR,
                  '1'    when gtfopSET,
                  AC(1)  when gtfopAC1;
        
    --
    --! GTF Register
    --
  
    REG_GTF : process(sys)
    begin
        if sys.rst = '1' then
            gtfREG <= '0';
        elsif rising_edge(sys.clk) then
            gtfREG <= gtfMUX;
        end if;
    end process REG_GTF;

    GTF <= gtfREG;
    
end rtl;
