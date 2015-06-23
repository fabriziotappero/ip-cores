------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Multiplier Quotient (MQ) Register
--!
--! \details
--!      The Multiplier Quotient (MQ) Register is used during
--!      certain EAE instructions.   Many times is is just used
--!      as a temporary register.
--!
--!      The MQ register is modified as follows:
--!      -# The MQ reqister is set to 0000 when the Front Panel
--!         CLEAR switch is asserted, and
--!      -# The MQ reqister is set to 0000 when a Clear AC and MQ
--!         (CAM) instruction is executed, and 
--!      -# The MQ reqister is set to 0000 when a CLA SWP
--!         instruction is executed, and 
--!      -# The MQ is loaded with the contents of the AC register
--!         when a MQ Register Load (MQL) instruction is
--!         executed, and
--!      -# The MQ is loaded with the contents of the AC register
--!         when a Swap AC and MQ (SWP) instruction is
--!         executed, and
--!      -# The MQ register is updated during each of the
--!         following EAE instructions:
--!          -# the Double Precision Increment (DPIC)
--!             instruction, or
--!          -# the Double Precision Complement (DCM)
--!             instruction, or
--!          -# the Double Precision Add (DAD) instruction, or
--!          -# the Double Precision Divide (DVI) instruction, or
--!          -# the Double Precision Multiply (MUY) instruction, or
--!          -# the Arithmetic Shift Right (ASR) instruction, or
--!          -# the Logical Shift Right (LSR) instruction, or
--!          -# the Shift Left (SHL) instruction, or
--!
--! \file
--!      mq.vhd
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
--! CPU Multiplier Quotient (MQ) Register Entity
--

entity eMQ is port (
    sys   : in  sys_t;                          --! Clock/Reset
    mqOP  : in  mqop_t;                         --! MQ Operation
    AC    : in  data_t;                         --! AC Register
    MD    : in  data_t;                         --! MD Register
    EAE   : in  eae_t;                          --! EAE Register
    MQ    : out data_t                          --! MQ Output
);
end eMQ;

--
--! CPU Multiplier Quotient (MQ) Register RTL
--

architecture rtl of eMQ is

    signal mqREG   : data_t;                    --! Multiplier Quotient Register
    signal addMUX1 : data_t;                    --! Adder Multiplexer #1 input
    signal addMUX2 : data_t;                    --! Adder Multiplexer #2 input
    signal shl0    : data_t;                    --! MQ <- (MQ << 1) + 0
    signal shl1    : data_t;                    --! MQ <- (MQ << 1) + 1
    signal shr0    : data_t;                    --! MQ <- 0 & (MQ >> 1)
    signal shr1    : data_t;                    --! MQ <- 1 & (MQ >> 1)
    signal eael    : data_t;                    --! EAE (low word)
        
begin

    --
    -- Shifts and Rotates
    --
  
    shl0 <= mqREG(1 to 11) & '0';               -- SHL0 <= (MQ << 1) & '0'
    shl1 <= mqREG(1 to 11) & '1';               -- SHL1 <= (MQ << 1) & '1'
    shr0 <= '0' & mqREG(0 to 10);               -- SHR0 <= '0' & MQ(0 to 10)
    shr1 <= '1' & mqREG(0 to 10);               -- SHR1 <= '1' & MQ(0 to 10)
    eael <= EAE(13 to 24);                      -- EAEL <= EAE(13 to 24)
    
    --
    -- Adder input #1 mux.
    --

    with mqOP select
        addMUX1 <= o"0000" when mqopNOP,        -- MQ <- MQ
                   o"0000" when mqopCLR,        -- MQ <- "0000"
                   o"0000" when mqopSET,        -- MQ <- "7777"
                   o"0000" when mqopSHL0,       -- MQ <- (MQ << 1) & '0'
                   o"0000" when mqopSHL1,       -- MQ <- (MQ << 1) & '1'
                   o"0000" when mqopAC,         -- MQ <- AC
                   o"0000" when mqopMD,         -- MQ <- MD
                   MD      when mqopADDMD,      -- MQ <- MQ + MD
                   o"0001" when mqopACP1,       -- MQ <- AC + 1
                   o"0001" when mqopNEGAC,      -- MQ <- -AC
                   o"0000" when mqopEAE,        -- MQ <- EAE(13 to 24)
                   o"0000" when mqopSHR0,       -- MQ <- '0' & MQ(0 to 10)
                   o"0000" when mqopSHR1;       -- MQ <- '1' & MQ(0 to 10)
        
    --
    -- Adder input #2 mux.
    --

    with mqOP select
        addMUX2 <= mqREG   when mqopNOP,        -- MQ <- MQ
                   o"0000" when mqopCLR,        -- MQ <- "0000"
                   o"7777" when mqopSET,        -- MQ <- "7777"
                   shl0    when mqopSHL0,       -- MQ <- (MQ << 1) + 0
                   shl1    when mqopSHL1,       -- MQ <- (MQ << 1) + 1
                   AC      when mqopAC,         -- MQ <- AC
                   MD      when mqopMD,         -- MQ <- MD
                   mqREG   when mqopADDMD,      -- MQ <- MQ + MD
                   AC      when mqopACP1,       -- MQ <- AC + 1
                   not(AC) when mqopNEGAC,      -- MQ <- -AC
                   eael    when mqopEAE,        -- MQ <- EAE(13 to 24)
                   shr0    when mqopSHR0,       -- MQ <- '0' & MQ(0 to 10)
                   shr1    when mqopSHR1;       -- MQ <- '1' & MQ(0 to 10)

    --
    --! MQ Register
    --
  
    REG_MQ : process(sys)
    begin
        if sys.rst = '1' then
            mqREG <= o"0000";
        elsif rising_edge(sys.clk) then
            mqREG <= std_logic_vector(unsigned(addMUX2) + unsigned(addMUX1));
        end if;
    end process REG_MQ;

    MQ <= mqREG;
    
end rtl;
