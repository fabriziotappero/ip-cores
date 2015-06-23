------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Extended Memory (XMA) Register
--!
--! \file
--!      xma.vhd
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
--! CPU Extended Memory (XMA) Register Entity
--

entity eXMA is
    port (
        sys   : in  sys_t;                      --! Clock/Reset
        xmaOP : in  xmaOP_t;                    --! XMA Operation
        swCPU : in  swCPU_t;                    --! CPU Configuration
        DF    : in  field_t;                    --! DF register
        INF   : in  field_t;                    --! INF register
        IB    : in  field_t;                    --! IB register
        XMA   : out field_t                     --! XMA Output
    );
end eXMA;

--
--! CPU Extended Memory (XMA) Register RTL
--

architecture rtl of eXMA is

    signal xmaREG : field_t;                    --! XMA Register
    signal xmaMUX : field_t;                    --! XMA Multiplexer
    
begin
  
    --
    -- XMA Multiplexer
    --

    with xmaOP select
        xmaMUX <= xmaREG when xmaopNOP,         -- XMA <- XMA
                  "000"  when xmaopCLR,         -- XMA <- "000"
                  DF     when xmaopDF,          -- XMA <- DF
                  INF    when xmaopIF,          -- XMA <- IF
                  IB     when xmaopIB;          -- XMA <- IB
    --
    --! XMA Register
    --
  
    REG_XMA : process(sys)
    begin
        if sys.rst = '1' then
            xmaREG <= "000";
        elsif rising_edge(sys.clk) then
            if swCPU = swHD6120 then
                xmaREG <= "000";
            else
                xmaREG <= xmaMUX;
            end if;
        end if;
    end process REG_XMA;

    XMA <= xmaREG;
    
end rtl;
