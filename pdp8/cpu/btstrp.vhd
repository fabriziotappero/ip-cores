------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Bootstrap (BTSTRP) Register
--!
--! \details
--!      The Bootstrap Register (BTSTRP) is defined in the HD-6120
--!      documentation.   Its functionality is mostly not
--!      implemented.
--!
--! \todo
--!      The BTSTRP Register is not implemented.
--!
--! \file
--!      btstrp.vhd
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
--! CPU Bootstrap (BTSTRP) Register Entity
--

entity eBTSTRP is port (
    sys      : in  sys_t;                       --! Clock/Reset
    btstrpop : in  btstrpop_t;                  --! BTSTRP Operation
    BTSTRP   : out std_logic                    --! BTSTRP Output
);
end eBTSTRP;

--
--! CPU Bootstrap (BTSTRP) Register RTL
--

architecture rtl of eBTSTRP is

    signal btstrpREG : std_logic;               --! Bootstrap Flip-Flop
    signal btstrpMUX : std_logic;               --! Bootstrap Flip-Flop Multiplexer
    
begin
  
    --
    -- BTSTRP Multiplexer
    --
  
    with btstrpOP select
        btstrpMUX <= btstrpREG when btstrpopNOP,
                     '0'       when btstrpopCLR,
                     '1'       when btstrpopSET;
      
    --
    --! BTSTRP Register
    --
  
    REG_BTSTRP : process(sys)
    begin
        if sys.rst = '1' then
            btstrpREG <= '0';
        elsif rising_edge(sys.clk) then
            btstrpREG <= btstrpMUX;
        end if;
    end process REG_BTSTRP;

    BTSTRP <= btstrpREG;
    
end rtl;
