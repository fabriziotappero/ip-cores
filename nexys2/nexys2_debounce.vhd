------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      NEXYS2 Wrapper: Debounce Device
--!
--! \file
--!      nexys2_debounce.vhd
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

--
--! NEXYS2 Debounce Timer Entity
--

entity eNEXYS2_DEBOUNCE is port (
    clk   : in  std_logic;                      --! Clock
    rst   : in  std_logic;                      --! Reset
    clken : in  std_logic;                      --! Clock Enable
    di    : in  std_logic;                      --! Input
    do    : out std_logic                       --! Output
);
end eNEXYS2_DEBOUNCE;

--
--! NEXYS2 Debounce Timer RTL
--

architecture rtl of eNEXYS2_DEBOUNCE is

    signal   last  : std_logic;                 --! Last input
    signal   count : integer range 0 to 833;    --! Debounce Counter
    constant ms10  : integer := 833;            --! 10 milliseconds (clken=12us)

begin
    --
    --! This process implements a Debounce Timer.
    --

    DEBOUNCE_TIMER : process(clk, rst, di)
    begin
        if rst = '1' then
            do    <= di;
            last  <= di;
            count <= 0;
        elsif rising_edge(clk) then
            if clken = '1' then
                if di = last then
                    if count = 0 then
                        do <= di;
                    else
                        count <= count - 1;
                    end if;
                else
                    last  <= di;
                    count <= ms10;
                end if;
            end if;
        end if;
    end process DEBOUNCE_TIMER;

end rtl;
