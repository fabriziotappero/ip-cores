----------------------------------------------------------------------
----                                                              ----
---- Ultimate CRC.                                                ----
----                                                              ----
---- This file is part of the ultimate CRC projectt               ----
---- http://www.opencores.org/cores/ultimate_crc/                 ----
----                                                              ----
---- Description                                                  ----
---- CRC generator/checker, serial implementation.                ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Geir Drange, gedra@opencores.org                           ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2005 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU General          ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.0 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU General Public License for more details.----
----                                                              ----
---- You should have received a copy of the GNU General           ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/gpl.txt                     ----
----                                                              ----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.2  2005/05/09 19:26:58  gedra
-- Moved match signal into clock enable
--
-- Revision 1.1  2005/05/07 12:47:47  gedra
-- Serial implementation.
--
--
--

library ieee;
use ieee.std_logic_1164.all;

entity ucrc_ser is
   generic (
      POLYNOMIAL : std_logic_vector;
      INIT_VALUE : std_logic_vector;
      SYNC_RESET : integer range 0 to 1 := 0);  -- use synchronous reset
   port (
      clk_i   : in  std_logic;          -- clock
      rst_i   : in  std_logic;          -- init CRC
      clken_i : in  std_logic;          -- clock enable
      data_i  : in  std_logic;          -- data input
      flush_i : in  std_logic;          -- flush crc
      match_o : out std_logic;          -- CRC match flag
      crc_o   : out std_logic_vector(POLYNOMIAL'length - 1 downto 0));  -- CRC output
end ucrc_ser;

architecture rtl of ucrc_ser is

   constant msb         : integer                        := POLYNOMIAL'length - 1;
   constant init_msb    : integer                        := INIT_VALUE'length - 1;
   constant p           : std_logic_vector(msb downto 0) := POLYNOMIAL;
   signal din, crc_msb  : std_logic_vector(msb downto 1);
   signal crc, zero, fb : std_logic_vector(msb downto 0);
   signal arst, srst    : std_logic;
   
begin

-- Parameter checking: Invalid generics will abort simulation/synthesis
   PCHK : if msb /= init_msb generate
      process
      begin
         report "POLYNOMIAL and INIT_VALUE vectors must be equal length!"
            severity failure;
         wait;
      end process;
   end generate PCHK;

   PCHK2 : if (msb < 3) or (msb > 31) generate
      process
      begin
         report "POLYNOMIAL must be of order 4 to 32!"
            severity failure;
         wait;
      end process;
   end generate PCHK2;

   PCHK3 : if p(0) /= '1' generate      -- LSB must be 1
      process
      begin
         report "POLYNOMIAL must have lsb set to 1!"
            severity failure;
         wait;
      end process;
   end generate PCHK3;

   zero  <= (others => '0');
   crc_o <= crc;

-- Create vectors of data input and MSB of CRC
   DI : for i in 1 to msb generate
      din(i)     <= data_i;
      crc_msb(i) <= crc(msb);
   end generate DI;

-- Feedback signals
   fb(0)            <= data_i xor crc(msb);
   fb(msb downto 1) <= crc(msb-1 downto 0) xor ((din xor crc_msb) and p(msb downto 1));

-- Reset signal
   SR : if SYNC_RESET = 1 generate
      srst <= rst_i;
      arst <= '0';
   end generate SR;
   AR : if SYNC_RESET = 0 generate
      srst <= '0';
      arst <= rst_i;
   end generate AR;

-- CRC process
   CRCP : process (clk_i, arst)
   begin
      if arst = '1' then                -- async. reset
         crc     <= INIT_VALUE;
         match_o <= '0';
      elsif rising_edge(clk_i) then
         if srst = '1' then             -- sync. reset
            crc     <= INIT_VALUE;
            match_o <= '0';
         else
            if clken_i = '1' then
               -- CRC generation
               if flush_i = '1' then
                  crc(0)            <= '0';
                  crc(msb downto 1) <= crc(msb - 1 downto 0);
               else
                  crc <= fb;
               end if;
               -- CRC match checker (if data plus CRC is clocked in without errors,
               -- the CRC register ends up with all zeroes)
               if fb = zero then
                  match_o <= '1';
               else
                  match_o <= '0';
               end if;
            end if;
         end if;
      end if;
   end process;
   
end rtl;

