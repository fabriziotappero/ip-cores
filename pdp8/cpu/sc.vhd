------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Step Counter (SC) Register
--!
--! \details
--!      The Step Count (SC) Register is used to control the
--!      number of shifts to perform on EAE LSR, ASR, and SHL
--!      instruction.  It is also used by the NMI instruction.
--!
--! \file
--!      sc.vhd
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
--! CPU Step Counter (SC) Register Entity
--

entity eeSC is port (
    sys  : in  sys_t;                           --! Clock/Reset
    scOP : in  scOP_t;                          --! SC Operation
    AC   : in  data_t;                          --! AC register
    MD   : in  data_t;                          --! MD register
    SC   : out sc_t                             --! SC Output
);
end eeSC;

--
--! CPU Step Counter (SC) RegisterC RTL
--

architecture rtl of eeSC is

    signal scREG : sc_t;                        --! Step Counter
    signal scMUX : sc_t;                        --! Step Counter Multiplexer
    
begin
  
    --
    -- SC Multiplexer
    --

    with scOP select
        scMUX <= scREG                                       when scopNOP,
                 "00000"                                     when scopCLR,
                 "11111"                                     when scopSET,
                 "01100"                                     when scop12,
                 AC(7 to 11)                                 when scopAC7to11,
                 MD(7 to 11)                                 when scopMD7to11,
                 not(MD(7 to 11))                            when scopNOTMD7to11,
                 std_logic_vector(unsigned(scREG) + 1)       when scopINC,
                 std_logic_vector(unsigned(scREG) - 1)       when scopDEC,
                 std_logic_vector(unsigned(MD(7 to 11)) + 1) when scopMDP1;
  
    --
    --! SC Register
    --
  
    REG_SC : process(sys)
    begin
        if sys.rst = '1' then
            scREG <= "00000";
        elsif rising_edge(sys.clk) then
            scREG <= scMUX;
        end if;
    end process REG_SC;

    SC <= scREG;
    
end rtl;
