------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Memory Address (MA) Register
--!
--! \details
--!      The Memory Address (MA) Register provides the address
--!      that is asserted onto the address bus on the subsequent
--!      memory reads or writes.
--!
--! \file
--!      ma.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011, 2012 Rob Doyle
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
--! CPU Memory Address (MA) Register Entity
--

entity eMA is port (
    sys  : in  sys_t;                           --! Clock/Reset
    maOP : in  maOP_t;                          --! MA Operation
    IR   : in  data_t;                          --! Instruction Register
    MB   : in  data_t;                          --! Memory Buffer
    MD   : in  data_t;                          --! Memory Data
    PC   : in  addr_t;                          --! Program Counter
    SP1  : in  addr_t;                          --! Stack Pointer 1
    SP2  : in  addr_t;                          --! Stack Pointer 2
    SR   : in  data_t;                          --! Switch Register
    MA   : out addr_t                           --! MA Output
);
end eMA;

--
--! CPU Memory Address (MA) Register RTL
--

architecture rtl of eMA is

    signal maREG   : addr_t;                    --! Memory Address Register
    signal addMUX1 : addr_t;                    --! Adder Mux #1
    signal addMUX2 : addr_t;                    --! Adder Mux #2
    signal CP      : addr_t;                    --! Current Page Addr
    signal ZP      : addr_t;                    --! Zero Page Addr

begin
  
    --
    -- Current Page and Zero Page addresses
    --
    
    CP <= maREG(0 to 4) & IR(5 to 11);          -- Current Page Addr
    ZP <= "00000"       & IR(5 to 11);          -- Zero Page Addr

    --
    -- Adder input #1 mux.
    -- This synthesizes into a ROM
    --
    
    with maOP select
        addMUX1 <= o"0000" when maopNOP,        -- MA <- MA
                   o"0000" when maop0000,       -- MA <- o"0000"
                   o"0000" when maopIR,         -- MA <- IR
                   o"0000" when maopPC,         -- MA <- PC
                   o"0000" when maopMB,         -- MA <- MB
                   o"0000" when maopMD,         -- MA <- MD
                   o"0000" when maopSP1,        -- MA <- SP1
                   o"0000" when maopSP2,        -- MA <- SP2
                   o"0000" when maopSR,         -- MA <- SR
                   o"0000" when maopZP,         -- MA <- zeroPage & IR(5 to 11)
                   o"0000" when maopCP,         -- MA <- currPage & IR(5 to 11)
                   o"0001" when maopINC,        -- MA <- MA + 1
                   o"0001" when maopPCP1,       -- MA <- PC + 1
                   o"0001" when maopMDP1,       -- MA <- MD + 1
                   o"0001" when maopSP1P1,      -- MA <- SP1 + 1
                   o"0001" when maopSP2P1;      -- MA <- SP2 + 1
        
    --
    -- Adder input #2 mux.
    --
    
    with maOP select
        addMUX2 <= maREG   when maopNOP,        -- MA <- MA
                   o"0000" when maop0000,       -- MA <- o"0000"
                   IR      when maopIR,         -- MA <- IR
                   PC      when maopPC,         -- MA <- PC
                   MB      when maopMB,         -- MA <- MB
                   MD      when maopMD,         -- MA <- MD
                   SP1     when maopSP1,        -- MA <- SP1
                   SP2     when maopSP2,        -- MA <- SP2
                   SR      when maopSR,         -- MA <- SR
                   ZP      when maopZP,         -- MA <- zeroPage & IR(5 to 11)
                   CP      when maopCP,         -- MA <- currPage & IR(5 to 11)
                   maREG   when maopINC,        -- MA <- MA + 1
                   PC      when maopPCP1,       -- MA <- PC + 1
                   MD      when maopMDP1,       -- MA <- MD + 1
                   SP1     when maopSP1P1,      -- MA <- SP1 + 1
                   SP2     when maopSP2P1;      -- MA <- SP2 + 1
      
    --
    --! MA Register
    --
  
    REG_MA : process(sys)
    begin
        if sys.rst = '1' then
            maREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            maREG <= std_logic_vector(unsigned(addMUX2) + unsigned(addMUX1));
        end if;
    end process REG_MA;

    MA <= maREG;
    
end rtl;
