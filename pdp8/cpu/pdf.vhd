------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Panel Data Flag (PDF) Register
--!
--! \details
--!      The Panel Data Flag (PDF) Register controls whether
--!      indirect data memory accesses by the Control Panel AND,
--!      TAD, ISZ or DCA instructions reference Panel Memory or
--!      Main Memory.
--!
--!      If the PDF Register is set, indirect data memory
--!      references as described above access Panel Memory
--!      (LXPAR asserted).  If the PDF Register is cleared,
--!      indirect data memory references as described above
--!      access Main Memory (LXMAR asserted).
--!
--!      The PDF Register is modified under the following
--!      conditions:
--!      -# the PDF Register is cleared on entry to the Panel
--!         Mode Interrupt, and
--!      -# the PDF Register is cleared if the unit is
--!         configured as a HD-6120 and the unit is in Panel
--!         Mode (CTRLFF asserted) and a Clear Panel Data Flag
--!         (CPD) instruction is executed.
--!      -# the PDF Register is set if the unit is
--!         configured as a HD-6120 and the unit is in Panel
--!         Mode (CTRLFF asserted) and a Set Panel Data Flag
--!         (SPD) instruction is executed.
--!
--! \file
--!      pdf.vhd
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
--! CPU Panel Data Flag (PDF) Register Entity
--

entity ePDF is port (
    sys   : in  sys_t;                          --! Clock/Reset
    pdfOP : in  pdfOP_t;                        --! PDF Operation
    PDF   : out std_logic                       --! PDF Output
);
end ePDF;

--
--! CPU Panel Data Flag (PDF) Register RTL
--

architecture rtl of ePDF is

    signal pdfREG : std_logic;                  --! Panel Data Flag
    signal pdfMUX : std_logic;                  --! Panel Data Flag Multiplexer
    
begin
  
    --
    -- PDF Multiplexer
    --
  
    with pdfOP select
        pdfMUX <= pdfREG when pdfopNOP,
                  '0'    when pdfopCLR,
                  '1'    when pdfopSET;
  
    --
    --! PDF Register
    --
  
    REG_PDF : process(sys)
    begin
        if sys.rst = '1' then
            pdfREG <= '0';
        elsif rising_edge(sys.clk) then
            pdfREG <= pdfMUX;
        end if;
    end process REG_PDF;

    PDF <= pdfREG;
    
end rtl;
