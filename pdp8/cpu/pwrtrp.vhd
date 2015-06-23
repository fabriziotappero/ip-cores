------------------------------------------------------------------
--!
--! PDP8 Processor
--!
--! \brief
--!      CPU Power-On Trap (PWRTRP) Register
--!
--! \details
--!      The Power-On Trap (PWRTRP) Register is association with
--!      the STARTUP input is used to control the startup
--!      operation of the CPU.
--!
--!      The PWRTRP Register is defined in the HD-6120
--!      documentation.
--!
--!      When the unit is configured as a HD-6120, the PWRTRP
--!      Register will be set to the state of STARTUP input
--!      when the reset input is negated.
--!
--!      If the PWRTRP register is set, the unit will boot
--!      to the Normal Mode Boot Vector (Address 0000).
--!      Otherwise the unit will boot to the Panel Mode
--!      Boot Vector (Address 7777)
--!
--! \todo
--!      Probably don't need this register.  Delete it.
--!      Just initialize the PC dependant on the STARTUP
--!      input to 0000 or 7777.
--!
--! \file
--!      pwrtrp.vhd
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
--! CPU Power-On Trap (PWRTRP) Register Entity
--

entity ePWRTRP is port (
    sys      : in  sys_t;                       --! Clock/Reset
    pwrtrpOP : in  pwrtrpop_t;                 	--! PWRTRP Operation
    PWRTRP   : out std_logic                    --! PWRTRP Output
);
end ePWRTRP;

--
--! CPU Power-On Trap (PWRTRP) Register RTL
--

architecture rtl of ePWRTRP is

    signal pwrtrpREG : std_logic;               --! Power On Trap Flip-Flop
    signal pwrtrpMUX : std_logic;               --! Power On Trap Flip-Flop Multiplexer
    
begin
  
    --
    -- PWRTRP Multiplexer
    --
  
    with pwrtrpOP select
        pwrtrpMUX <= pwrtrpREG when pwrtrpopNOP,
                    '0'        when pwrtrpopCLR,
                    '1'        when pwrtrpopSET;
    
    --
    --! PWRTRP Register
    --
  
    REG_PWRTRP : process(sys)
    begin
        if sys.rst = '1' then
            pwrtrpREG <= '0';
        elsif rising_edge(sys.clk) then
            pwrtrpREG <= pwrtrpMUX;
        end if;
    end process REG_PWRTRP;

    PWRTRP <= pwrtrpREG;
    
end rtl;
