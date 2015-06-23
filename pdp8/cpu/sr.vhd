 --------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Switch Register (SR)
--!
--! \details
--!      This supports the notion of a virtualized Switch Register.
--!      When in HD-6120 mode, the Panel Mode can write to the
--!      Switch register using the WSR IOT - this allows Panel
--!      Mode to virualize the Switch Register using a software
--!      command.
--!
--! \file
--!      sr.vhd
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
use work.cpu_types.all;                         --! Types

--
--! CPU Switch Register (SR) Entity
--

entity eSR is port (
    sys   : in  sys_t;                          --! Clock/Reset
    swCPU : in  swCPU_t;                        --! CPU Configuration
    srOP  : in  srOP_t;                         --! SR Operation
    AC    : in  data_t;                         --! AC Register
    SRD   : in  data_t;                         --! Switch Data In
    SR    : out data_t                          --! Switch Register Out
);
end eSR;

--
--! CPU Switch Register (SR) RTL
--

architecture rtl of eSR is
  
    signal srREG : data_t;                      --! Switch Register
    signal srMUX : data_t;                      --! Switch Register Multiplexer
    
begin    

    --
    -- SR Multiplexer
    --
  
    with srOP select
        srMUX <= srREG when sropNOP,
                 AC    when sropAC;
    
    --
    --! SR Register
    --

    REG_SR : process(sys)
    begin
        if sys.rst = '1' then
            srREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            if swCPU = swHD6120 then
                srREG <= srMUX;
            else
                srREG <= SRD;
            end if;
        end if;
    end process REG_SR;

    SR <= srREG;
    
end rtl;
