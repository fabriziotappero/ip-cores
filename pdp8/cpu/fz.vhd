------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Force Zero (FZ) Register
--!
--! \details
--!      The Force Zero (FZ) Register is defined in the HD-6120
--!      documentation.  Its functionality is mostly not
--!      implemented.
--!
--! \todo
--!      The FZ Register is not implemented.
--!
--! \file
--!      fz.vhd
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
use work.cpu_types.all;                        --! Types

--
--! CPU Force Zero (FZ) Register Entity
--

entity eFZ is port (
    sys  : in  sys_t;                           --! Clock/Reset
    fzOP : in  fzOP_t;                          --! FZ Operation
    FZ   : out std_logic                        --! FZ Output
);
end eFZ;

--
--! CPU Force Zero (FZ) Register RTL
--

architecture rtl of eFZ is

    signal fzREG : std_logic;                   -- Force Zero Flag
    signal fzMUX : std_logic;                   -- Force Zero Flag Multiplexer
    
begin
  
    --
    -- FZ Multiplexer
    --

    with fzOP select
         fzMUX <= fzREG when fzopNOP,           -- FZ <- FZ
                  '0'   when fzopCLR,           -- FZ <- '0'
                  '1'   when fzopSET;           -- FZ <- '1'
    
    --
    --! FZ Register
    --
  
    REG_FZ : process(sys)
    begin
        if sys.rst = '1' then
            fzREG <= '0';
        elsif rising_edge(sys.clk) then
            fzREG <= fzMUX;
        end if;
    end process REG_FZ;

    FZ <= fzREG;
    
end rtl;
