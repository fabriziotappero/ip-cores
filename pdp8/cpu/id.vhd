------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU ION Delay (ID) Register
--!
--! \details
--!      The ION Delay (ID) register delays the effect of the ION
--!      instruction until the instruction after the ION
--!      instruction has executed.   This will allow a return
--!      from interrupt to be executed before the next interrupt
--!      request is serviced.
--!
--!      The ID register is set by the ION IOT instruction.
--!
--!      If the ID register is set during the state that checks
--!      for interupt activity, the interrupt will not occur.
--!
--!      After the interrupt check, the ION Register is cleared.
--!      Any deferred interrupts will be processed before the
--!      next instruction.
--!
--! \file
--!      id.vhd
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
--! CPU ION Delay (ID) Register Entity
--

entity eID is port (
    sys  : in  sys_t;                           --! Clock/Reset
    idOP : in  idOP_t;                          --! ID Operation
    ID   : out std_logic                        --! ID Output
);
end eID;

--
--! CPU ION Delay (ID) Register RTL
--

architecture rtl of eID is

    signal idREG : std_logic;                   -- ION Delay Register
    signal idMUX : std_logic;                   -- ION Delay Register Multiplexer
    
begin
  
    --
    -- ID Multiplexer
    --
    
    with idOP select
        idMUX <= idREG when idopNOP,
                 '0'   when idopCLR,
                 '1'   when idopSET;
    
    --
    --! ID Register
    --
  
    REG_ID : process(sys)
    begin
        if sys.rst = '1' then
            idREG <= '0';
        elsif rising_edge(sys.clk) then
            idREG <= idMUX;
        end if;
    end process REG_ID;

    ID <= idREG;
    
end rtl;
