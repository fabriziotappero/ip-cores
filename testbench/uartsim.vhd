------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      UART Sim Testbench
--!
--! \details
--!      Test Bench.
--!
--! \file
--!      uartsim.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2012 Rob Doyle
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
use ieee.numeric_std.all;                     --! IEEE Numeric Standard
use std.textio.all;                             --! TEXTIO
use ieee.std_logic_textio.all;                  --! IEEE Std Logic TextIO

--
--! UARTSIM Test Entity
--

entity eUARTSIM is port (
    rst      : in  std_logic;                   --! Reset
    bitTIME  : in  time;                        --! baud rate
    TXD      : out std_logic                    --! TXD
);
end eUARTSIM;

--
--! UARTSIM Test Bench Behav
--

architecture behav of eUARTSIM is

  --constant msg  : string := "EX RKA0:ADVENT.LD";
    constant msg  : string := "RUN RKA0:K12MIT.SV";
    constant quit : string := "EXIT";
    
    --
    --! This procedure simulates a UART transmitter
    --
    
    procedure tx(constant s : in string; signal TXD : out std_logic) is
        variable cmd    : string(msg'left to msg'right+1);
        variable txDATA : std_logic_vector(0 to 7);
        variable val    : integer range 0 to 255;
        
    begin

        cmd := s & CR;
        
        for i in 1 to cmd'right loop
            
            val := character'pos(cmd(i));
            txDATA := std_logic_vector(to_unsigned( val, 8 ));
            
            TXD <= '0';
            wait for bitTIME;
            TXD <= txDATA(7);
            wait for bitTIME;
            TXD <= txDATA(6);
            wait for bitTIME;
            TXD <= txDATA(5);
            wait for bitTIME;
            TXD <= txDATA(4);
            wait for bitTIME;
            TXD <= txDATA(3);
            wait for bitTIME;
            TXD <= txDATA(2);
            wait for bitTIME;
            TXD <= txDATA(1);
            wait for bitTIME;
            TXD <= txDATA(0);
            wait for bitTIME;
            TXD <= '1';
            wait for bitTIME*5;
        end loop;
    end tx;

    --
    --! Send UART Data to PDP8
    --
    
begin

    process
    begin
        TXD <= '1';
        wait for 5000 us;
        tx(msg, TXD);
        wait for 37000 us;
        tx(quit, TXD);
        wait for 100000 ms;
    end process;
  
end behav;
