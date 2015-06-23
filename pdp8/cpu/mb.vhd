------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Memory Buffer (MB) Register
--!
--! \details
--!      The Memory Buffer (MB) Register contains the data to be
--!      asserted onto the Data Bus during a write operation.
--!
--! \file
--!      mb.vhd
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
--! CPU Memory Buffer (MB) Register Entity
--

entity eMB is port (
    sys  : in  sys_t;                           --! Clock/Reset
    mbOP : in  mbOP_t;                          --! MB Operation
    AC   : in  data_t;                          --! AC Register
    MA   : in  addr_t;                          --! MA Register
    MD   : in  data_t;                          --! MD Register
    MQ   : in  data_t;                          --! MQ Register
    PC   : in  addr_t;                          --! PC Register
    SR   : in  data_t;                          --! SR Register
    MB   : out data_t                           --! MB Output
);
end eMB;

--
--! CPU Memory Buffer (MB) Register RTL
--

architecture rtl of eMB is

    signal mbREG : data_t;                      --! Memory Buffer Register
    signal addMUX1 : addr_t;                    --! Adder Mux #1
    signal addMUX2 : addr_t;                    --! Adder Mux #2

begin

    --
    -- Adder input #1 mux.
    -- This synthesizes into a ROM
    --
    
    with mbOP select
        addMUX1 <= o"0000" when mbopNOP,        -- MB <- MB
                   o"0000" when mbopAC,         -- MB <- AC
                   o"0000" when mbopMA,         -- MB <- MA
                   o"0000" when mbopMD,         -- MB <- MD
                   o"0000" when mbopMQ,         -- MB <- MQ
                   o"0000" when mbopPC,         -- MB <- PC
                   o"0000" when mbopSR,         -- MB <- SR
                   o"0001" when mbopMDP1,       -- MB <- MD + 1
                   o"0001" when mbopPCP1;       -- MB <- PC + 1
        
    --
    -- Adder input #2 mux.
    --
    
    with mbOP select
        addMUX2 <= mbREG   when mbopNOP,        -- MB <- MB
                   AC      when mbopAC,         -- MB <- AC
                   MA      when mbopMA,         -- MB <- MA
                   MD      when mbopMD,         -- MB <- MD
                   MQ      when mbopMQ,         -- MB <- MQ
                   PC      when mbopPC,         -- MB <- PC
                   SR      when mbopSR,         -- MB <- SR
                   MD      when mbopMDP1,       -- MB <- MD + 1
                   PC      when mbopPCP1;       -- MB <- PC + 1
     
    --
    --! MB Register
    --
  
    REG_MB : process(sys)
    begin
        if sys.rst = '1' then
            mbREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            mbREG <= std_logic_vector(unsigned(addMUX2) + unsigned(addMUX1));
        end if;
    end process REG_MB;

    MB <= mbREG;
    
end rtl;
