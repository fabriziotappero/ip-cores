------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Data Field (DF) Memory Extension Register
--!
--! \details
--!      The Data Field (DF) Register is a Memory Extension
--!      Register that is used to supply the Extended Memory
--!      Address (EMA/XMA) during a indirect data operations.
--!
--!      The DF register is modified under the following
--!      conditions:
--!      -# the DF Register is set to 0 (Memory Field 0) on
--!         entry to an interrupt, and
--!      -# the DF Register is set to 0 (Memory Field 0) when
--!         the CLEAR switch on the Front Panel is asserted, and
--!      -# the DF Register set to the contents of the Front
--!         Panel Data Switch Register, SR(9:11), when the
--!         EXTD switch is asserted, and
--!      -# the DF Register set to the contents of the AC(9:11)
--!         when executing a Restore Flags (RTF) instruction, and
--!      -# the DF Register set to 'n' when executing a Change
--!         Data Field (CDFn) instruction, and
--!      -# the DF Register set to 'n' when executing a Change
--!         Data and Instruction Field (CDIn) instruction, and
--!      -# the DF Register set to the contents of the Save Flags
--!         Register, SF(4:6), when executing a Restore Memory
--!         Field (RMF) instruction.
--!
--! \file
--!      df.vhd
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
--! CPU Data Field (DF) Memory Extension Register Entity
--

entity eDF is port (
    sys  : in  sys_t;                           --! Clock/Reset
    dfOP : in  dfOP_t;                          --! DF Op
    AC   : in  data_t;                          --! AC Input
    IR   : in  addr_t;                          --! IR Input
    SF   : in  sf_t;                            --! SF Input
    SR   : in  data_t;                          --! SR Input
    DF   : out field_t                          --! DF Output
);
end eDF;

--
--! CPU Data Field (DF) Memory Extension Register Entity
--

architecture rtl of eDF is

    signal dfREG : field_t;                     --! Data Field
    signal dfMUX : field_t;                     --! Data Field Multiplexer
    
begin

    --
    -- DF Multiplexer
    -- 

    with dfOP select
        dfMUX <= dfREG       when dfopNOP,
                 "000"       when dfopCLR,
                 AC(9 to 11) when dfopAC9to11,
                 IR(6 to  8) when dfopIR6to8,
                 SF(4 to  6) when dfopSF4to6,
                 SR(9 to 11) when dfopSR9to11;
      
    --
    --! DF Register
    --
  
    REG_DF : process(sys)
    begin
        if sys.rst = '1' then
            dfREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            dfREG <= dfMUX;
        end if;
    end process REG_DF;

    DF <= dfREG;
    
end rtl;
