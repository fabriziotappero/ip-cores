-- Copyright (C) 2012
-- Ashwin A. Mendon
--
-- This file is part of SATA2 core.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.  

----------------------------------------------------------------------------------------
-- ENTITY: crc 
-- Version: 1.0
-- Author:  Ashwin Mendon 
-- Description: This sub-module implements the CRC Circuit for the SATA Protocol
--              The code takes 32-bit data word inputs and calculates the CRC for the stream
--              The generator polynomial used is     
--                      32  26  23  22  16  12  11  10  8   7   5   4   2       
--              G(x) = x + x + x + x + x + x + x + x + x + x + x + x + x + x + 1 
--              The CRC value is initialized to 0x52325032 as defined in the Serial ATA 
--              specification                                                           
-- PORTS: 
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity crc is
  generic(
    CHIPSCOPE             : boolean := false
       );
  port(
    -- Clock and Reset Signals
    clk                   : in  std_logic;
    reset                 : in  std_logic;
    -- ChipScope ILA / Trigger Signals
    --crc_ila_control       : in  std_logic_vector(35 downto 0);
    ---------------------------------------
    -- Signals from/to Sata Link Layer
    crc_en                : in  std_logic; 
    data_in               : in  std_logic_vector(0 to 31);
    data_out              : out std_logic_vector(0 to 31)
      );
end crc;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture BEHAV of crc is

  -------------------------------------------------------------------------------
  -- Constants
  -------------------------------------------------------------------------------
  constant CRC_INIT       : std_logic_vector(0 to 31) := x"52325032";
 
  signal crc              : std_logic_vector (31 downto 0);
  signal crc_next         : std_logic_vector (31 downto 0);
  signal crc_new          : std_logic_vector (31 downto 0);
  signal data_out_ila     : std_logic_vector (31 downto 0);


-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- PROCESS: CRC_PROC
  -- PURPOSE: Registering Signals and Next State
  -----------------------------------------------------------------------------
  CRC_PROC : process (clk)
  begin
    if ((clk'event) and (clk = '1')) then
      if (reset = '1') then
        --Initializing internal signals
        crc            <=  CRC_INIT;
      elsif (crc_en = '1') then
        -- Register all Current Signals to their _next Signals
        crc            <= crc_next;
      else
        crc            <= crc; 
      end if;
    end if;
  end process CRC_PROC ;

 crc_new      <= crc xor data_in; 

 crc_next(31) <= crc_new(31) xor crc_new(30) xor crc_new(29) xor crc_new(28) xor crc_new(27) xor crc_new(25) xor crc_new(24) xor
                     crc_new(23) xor crc_new(15) xor crc_new(11) xor crc_new(9) xor  crc_new(8)  xor crc_new(5);
 crc_next(30) <= crc_new(30) xor crc_new(29) xor crc_new(28) xor crc_new(27) xor crc_new(26) xor crc_new(24) xor crc_new(23) xor
                     crc_new(22) xor crc_new(14) xor crc_new(10) xor crc_new(8) xor  crc_new(7)  xor crc_new(4);
 crc_next(29) <= crc_new(31) xor crc_new(29) xor crc_new(28) xor crc_new(27) xor crc_new(26) xor crc_new(25) xor crc_new(23) xor
                     crc_new(22) xor crc_new(21) xor crc_new(13) xor crc_new(9) xor  crc_new(7)  xor crc_new(6)  xor crc_new(3);
 crc_next(28) <= crc_new(30) xor crc_new(28) xor crc_new(27) xor crc_new(26) xor crc_new(25) xor crc_new(24) xor crc_new(22) xor
                     crc_new(21) xor crc_new(20) xor crc_new(12) xor crc_new(8) xor  crc_new(6)  xor crc_new(5)  xor crc_new(2);
 crc_next(27) <= crc_new(29) xor crc_new(27) xor crc_new(26) xor crc_new(25) xor crc_new(24) xor crc_new(23) xor crc_new(21) xor
                     crc_new(20) xor crc_new(19) xor crc_new(11) xor crc_new(7) xor  crc_new(5)  xor crc_new(4)  xor crc_new(1);
 crc_next(26) <= crc_new(31) xor crc_new(28) xor crc_new(26) xor crc_new(25) xor crc_new(24) xor crc_new(23) xor crc_new(22) xor
                     crc_new(20) xor crc_new(19) xor crc_new(18) xor crc_new(10) xor crc_new(6)  xor crc_new(4)  xor crc_new(3)  xor
                     crc_new(0);
 crc_next(25) <= crc_new(31) xor crc_new(29) xor crc_new(28) xor crc_new(22) xor crc_new(21) xor crc_new(19) xor crc_new(18) xor
                     crc_new(17) xor crc_new(15) xor crc_new(11) xor crc_new(8) xor  crc_new(3)  xor crc_new(2);
 crc_next(24) <= crc_new(30) xor crc_new(28) xor crc_new(27) xor crc_new(21) xor crc_new(20) xor crc_new(18) xor crc_new(17) xor
                     crc_new(16) xor crc_new(14) xor crc_new(10) xor crc_new(7) xor  crc_new(2)  xor crc_new(1);
 crc_next(23) <= crc_new(31) xor crc_new(29) xor crc_new(27) xor crc_new(26) xor crc_new(20) xor crc_new(19) xor crc_new(17) xor
                     crc_new(16) xor crc_new(15) xor crc_new(13) xor crc_new(9) xor  crc_new(6)  xor crc_new(1)  xor crc_new(0);
 crc_next(22) <= crc_new(31) xor crc_new(29) xor crc_new(27) xor crc_new(26) xor crc_new(24) xor crc_new(23) xor crc_new(19) xor
                     crc_new(18) xor crc_new(16) xor crc_new(14) xor crc_new(12) xor crc_new(11) xor crc_new(9)  xor crc_new(0);
 crc_next(21) <= crc_new(31) xor crc_new(29) xor crc_new(27) xor crc_new(26) xor crc_new(24) xor crc_new(22) xor crc_new(18) xor
                     crc_new(17) xor crc_new(13) xor crc_new(10) xor crc_new(9) xor  crc_new(5);
 crc_next(20) <= crc_new(30) xor crc_new(28) xor crc_new(26) xor crc_new(25) xor crc_new(23) xor crc_new(21) xor crc_new(17) xor
                     crc_new(16) xor crc_new(12) xor crc_new(9) xor crc_new(8) xor   crc_new(4);
 crc_next(19) <= crc_new(29) xor crc_new(27) xor crc_new(25) xor crc_new(24) xor crc_new(22) xor crc_new(20) xor crc_new(16) xor
                     crc_new(15) xor crc_new(11) xor crc_new(8) xor crc_new(7) xor   crc_new(3);
 crc_next(18) <= crc_new(31) xor crc_new(28) xor crc_new(26) xor crc_new(24) xor crc_new(23) xor crc_new(21) xor crc_new(19) xor
                     crc_new(15) xor crc_new(14) xor crc_new(10) xor crc_new(7) xor  crc_new(6)  xor crc_new(2);
 crc_next(17) <= crc_new(31) xor crc_new(30) xor crc_new(27) xor crc_new(25) xor crc_new(23) xor crc_new(22) xor crc_new(20) xor
                     crc_new(18) xor crc_new(14) xor crc_new(13) xor crc_new(9) xor  crc_new(6)  xor crc_new(5)  xor crc_new(1);
 crc_next(16) <= crc_new(30) xor crc_new(29) xor crc_new(26) xor crc_new(24) xor crc_new(22) xor crc_new(21) xor crc_new(19) xor
                     crc_new(17) xor crc_new(13) xor crc_new(12) xor crc_new(8) xor  crc_new(5)  xor crc_new(4)  xor crc_new(0);
 crc_next(15) <= crc_new(30) xor crc_new(27) xor crc_new(24) xor crc_new(21) xor crc_new(20) xor crc_new(18) xor crc_new(16) xor
                     crc_new(15) xor crc_new(12) xor crc_new(9) xor crc_new(8) xor   crc_new(7)  xor crc_new(5)  xor crc_new(4)  xor
                     crc_new(3);
 crc_next(14) <= crc_new(29) xor crc_new(26) xor crc_new(23) xor crc_new(20) xor crc_new(19) xor crc_new(17) xor crc_new(15) xor
                     crc_new(14) xor crc_new(11) xor crc_new(8) xor crc_new(7) xor   crc_new(6) xor crc_new(4) xor crc_new(3) xor
                     crc_new(2);
 crc_next(13) <= crc_new(31) xor crc_new(28) xor crc_new(25) xor crc_new(22) xor crc_new(19) xor crc_new(18) xor crc_new(16) xor
                     crc_new(14) xor crc_new(13) xor crc_new(10) xor crc_new(7) xor  crc_new(6) xor crc_new(5) xor crc_new(3) xor
                     crc_new(2) xor crc_new(1);
 crc_next(12) <= crc_new(31) xor crc_new(30) xor crc_new(27) xor crc_new(24) xor crc_new(21) xor crc_new(18) xor crc_new(17) xor
                     crc_new(15) xor crc_new(13) xor crc_new(12) xor crc_new(9) xor  crc_new(6) xor crc_new(5) xor crc_new(4) xor
                     crc_new(2) xor crc_new(1) xor crc_new(0);
 crc_next(11) <= crc_new(31) xor crc_new(28) xor crc_new(27) xor crc_new(26) xor crc_new(25) xor crc_new(24) xor crc_new(20) xor
                     crc_new(17) xor crc_new(16) xor crc_new(15) xor crc_new(14) xor crc_new(12) xor crc_new(9) xor crc_new(4) xor
                     crc_new(3) xor crc_new(1) xor crc_new(0);
 crc_next(10) <= crc_new(31) xor crc_new(29) xor crc_new(28) xor crc_new(26) xor crc_new(19) xor crc_new(16) xor crc_new(14) xor
                     crc_new(13) xor crc_new(9) xor crc_new(5) xor crc_new(3) xor    crc_new(2) xor crc_new(0);
 crc_next(9) <= crc_new(29) xor crc_new(24) xor crc_new(23) xor crc_new(18) xor  crc_new(13) xor crc_new(12) xor crc_new(11) xor
                   crc_new(9)  xor crc_new(5)  xor crc_new(4)  xor crc_new(2)  xor crc_new(1);
 crc_next(8)  <= crc_new(31) xor crc_new(28) xor crc_new(23) xor crc_new(22) xor crc_new(17) xor crc_new(12) xor crc_new(11) xor
                   crc_new(10) xor crc_new(8)  xor crc_new(4)  xor crc_new(3)  xor crc_new(1)  xor crc_new(0);
 crc_next(7)  <= crc_new(29) xor crc_new(28) xor crc_new(25) xor crc_new(24) xor crc_new(23) xor crc_new(22) xor crc_new(21) xor
                   crc_new(16) xor crc_new(15) xor crc_new(10) xor crc_new(8)  xor crc_new(7)  xor crc_new(5) xor crc_new(3) xor
                   crc_new(2)  xor crc_new(0);
 crc_next(6)  <= crc_new(30) xor crc_new(29) xor crc_new(25) xor crc_new(22) xor crc_new(21) xor crc_new(20) xor crc_new(14) xor
                   crc_new(11) xor crc_new(8)  xor crc_new(7) xor crc_new(6) xor crc_new(5) xor crc_new(4) xor crc_new(2) xor
                   crc_new(1);
 crc_next(5)  <= crc_new(29) xor crc_new(28) xor crc_new(24) xor crc_new(21) xor crc_new(20) xor crc_new(19) xor crc_new(13) xor
                   crc_new(10) xor crc_new(7) xor crc_new(6) xor crc_new(5) xor crc_new(4) xor crc_new(3) xor crc_new(1) xor
                   crc_new(0);
 crc_next(4)  <= crc_new(31) xor crc_new(30) xor crc_new(29) xor crc_new(25) xor crc_new(24) xor crc_new(20) xor crc_new(19) xor
                   crc_new(18) xor crc_new(15) xor crc_new(12) xor crc_new(11) xor crc_new(8) xor crc_new(6) xor crc_new(4) xor
                   crc_new(3)  xor crc_new(2)  xor crc_new(0);
 crc_next(3)  <= crc_new(31) xor crc_new(27) xor crc_new(25) xor crc_new(19) xor crc_new(18) xor crc_new(17) xor crc_new(15) xor
                   crc_new(14) xor crc_new(10) xor crc_new(9)  xor crc_new(8) xor crc_new(7) xor crc_new(3) xor crc_new(2) xor
                   crc_new(1);
 crc_next(2)  <= crc_new(31) xor crc_new(30) xor crc_new(26) xor crc_new(24) xor crc_new(18) xor crc_new(17) xor crc_new(16) xor
                   crc_new(14) xor crc_new(13) xor crc_new(9) xor crc_new(8) xor crc_new(7) xor crc_new(6) xor crc_new(2) xor
                   crc_new(1)  xor crc_new(0);
 crc_next(1)  <= crc_new(28) xor crc_new(27) xor crc_new(24) xor crc_new(17) xor crc_new(16) xor crc_new(13) xor crc_new(12) xor
                   crc_new(11) xor crc_new(9)  xor crc_new(7)  xor crc_new(6)  xor crc_new(1)  xor crc_new(0);
 crc_next(0)  <= crc_new(31) xor crc_new(30) xor crc_new(29) xor crc_new(28) xor crc_new(26) xor crc_new(25) xor crc_new(24) xor
                   crc_new(16) xor crc_new(12) xor crc_new(10) xor crc_new(9)  xor crc_new(6)  xor crc_new(0);


 data_out_ila <= crc_next;
 --data_out_ila <= crc;

 -----------------------------------------------------------------------------
 -- ILA Instantiation
 -----------------------------------------------------------------------------
 data_out <= data_out_ila;

  
end BEHAV;


