------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Multiplier Quotient Auxillary Register (MQA)
--!
--! \details
--!      The Multiplier Quotient Auxillary Register (MQA) is a
--!      temporary register used during EAE shift and divide
--!      instructions.
--!
--! \todo
--!      Is the MQA register really necessary?  Can it be
--!      deleted and the instructions be re-written?
--!
--! \file
--!      mqa.vhd
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
--! CPU Auxillary Multiplier Quotient Register (MQA) Entity
--

entity eMQA is port (
    sys   : in  sys_t;                          --! Clock/Reset
    mqaOP : in  mqaop_t;                        --! MQA Operation
    MQ    : in  data_t;                         --! MQ Register
    MQA   : out data_t                          --! MQA Output
);
end eMQA;

--
--! CPU Auxillary Multiplier Quotient Register (MQA) RTL
--

architecture rtl of eMQA is

    signal mqaREG : data_t;                     --! Aux Multiplier Quotient Register
    signal mqaMUX : data_t;                     --! Aux Multiplier Quotient Multiplexer
    
begin

    --
    -- MQ Multiplexer
    --

    with mqaOP select
        mqaMUX <= mqaREG                when mqaopNOP,  -- MQA <- MQ
                  o"0000"               when mqaopCLR,  -- MQA <- "0000"
                  MQ                    when mqaopMQ,   -- MQA <- MQ
                  mqaREG(1 to 11) & '0' when mqaopSHL;  -- MQA <- (MQA << 1)

    --
    --! MQA Register
    --
  
    REG_MQA : process(sys)
    begin
        if sys.rst = '1' then
            mqaREG <= o"0000";
        elsif rising_edge(sys.clk) then
            mqaREG <= mqaMUX;
        end if;
    end process REG_MQA;

    MQA <= mqaREG;
    
end rtl;
