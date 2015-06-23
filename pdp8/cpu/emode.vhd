------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Extended Arithmetic Mode A (EMODE) Register
--!
--! \file
--!      emode.vhd
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
--! CPU Extended Arithmetic Mode A (EMODE) Register Entity
--

entity eEMODE is port (
    sys     : in  sys_t;                        --! Clock/Reset
    emodeOP : in  emodeOP_t;                    --! emode Operation
    EMODE   : out std_logic                     --! emode Output
);
end eEMODE;

--
--! CPU Extended Arithmetic Mode A (EMODE) Register RTL
--

architecture rtl of eEMODE is

    signal emodeREG : std_logic;                --! EAE Mode Flip-Flop
    signal emodeMUX : std_logic;                --! EAE Mode Multiplexer
    
begin
  
    --
    -- EMODE Multiplexer
    --

    with emodeop select
        emodeMUX <= emodeREG when emodeopNOP,   -- EMODE <- EMODE
                    '0'      when emodeopCLR,   -- EMODE <- '0'
                    '1'      when emodeopSET;   -- EMODE <- '1'
    
    --
    --! EMODE Register
    --
  
    REG_EMODE : process(sys)
    begin
        if sys.rst = '1' then
            emodeREG <= '0';
        elsif rising_edge(sys.clk) then
            emodeREG <= emodeMUX;
        end if;
    end process REG_EMODE;

    EMODE <= emodeREG;
    
end rtl;
