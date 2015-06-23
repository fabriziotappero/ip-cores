--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      UART Baud Rate Generator
--!
--! \details
--!      This is a programmable frequency divider that generates
--!      common baud rates.
--!
--! \file
--!      uart_brg.vhd
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

library ieee;                                                   --! IEEE Library
use ieee.std_logic_1164.all;                                    --! IEEE 1164
use work.uart_types.all;                                        --! UART Types
use work.cpu_types.all;                                         --! CPU Types

--
--! UART Serial Interface Baud Rate Generator Entity
--

entity eUART_BRG is port ( 
    sys    : in  sys_t;                                         --! Clock/Reset
    uartBR : in  uartBR_t;                                      --! Baud Rate Select
    clkBR  : out std_logic                                      --! Baud Rate Clock Enable
);
end eUART_BRG;

--
--! UART Serial Interface Baud Rate Generator RTL
--

architecture rtl of eUART_BRG is

    constant clkfreq : integer := 50000000;
    constant clkdiv  : integer := 16;
    
begin    

    --
    --! Programmable Clock Divider.
    --! This process generates a clkBR signal that is suitable for
    --! use as a 16x Baud Rate clock.   Both UART Transmitters and
    --! UART Receivers require this 16x clock.
    --
  
    UART_CLKDIV : process(sys)
       variable count : integer range 0 to 4095;
    begin
        if sys.rst = '1' then
            clkBR <= '0';
            count := 0;
        elsif rising_edge(sys.clk) then
            if count = 0 then
                case uartBR is
                    when uartBR1200 =>      --  1,200 (-0.016%)
                        count := clkfreq/clkdiv/1200;
                    when uartBR2400 =>      --  2,400 (-0.032%)
                        count := clkfreq/clkdiv/2400;
                    when uartBR4800 =>      --  4,800 (-0.032%)
                        count := clkfreq/clkdiv/4800;
                    when uartBR9600 =>      --  9,600 (+0.16%)
                        count := clkfreq/clkdiv/9600;
                    when uartBR19200 =>     -- 19,200 (+0.16%)
                        count := clkfreq/clkdiv/19200;
                    when uartBR38400 =>     -- 38,400 (+0.16%)
                        count := clkfreq/clkdiv/38400;
                    when uartBR57600 =>     -- 57,600 (+0.94%)
                        count := clkfreq/clkdiv/57600;
                    when uartBR115200 =>    -- 115,200 (+1.35%)
                        count := clkfreq/clkdiv/115200;
                    when others =>
                        null;
                end case;
                clkBR <= '1';
            else
               count := count - 1;
               clkBR <= '0';
            end if;
        end if;
    end process UART_CLKDIV;

end rtl;
