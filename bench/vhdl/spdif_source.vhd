----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Generates a SPDIF signal with given sampling rate.           ----
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
---- Copyright (C) 2004 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.3  2004/07/11 16:20:16  gedra
-- Improved test bench.
--
-- Revision 1.2  2004/06/06 15:45:24  gedra
-- Cleaned up lint warnings.
--
-- Revision 1.1  2004/06/03 17:45:18  gedra
-- SPDIF signal generator.
--
--

library ieee;
use ieee.std_logic_1164.all;

entity spdif_source is
   generic (FREQ : natural);            -- Sampling frequency in Hz
   port (                               -- Bitrate is 64x sampling frequency
      reset : in  std_logic;
      spdif : out std_logic);           -- Output bi-phase encoded signal
end spdif_source;

architecture behav of spdif_source is

   constant X_Preamble : std_logic_vector(7 downto 0) := "11100010";
   constant Y_Preamble : std_logic_vector(7 downto 0) := "11100100";
   constant Z_Preamble : std_logic_vector(7 downto 0) := "11101000";
   signal clk, ispdif  : std_logic;
   signal fcnt         : natural range 0 to 191;  -- frame counter
   signal bcnt         : natural range 0 to 63;   -- subframe bit counter
   signal pcnt         : natural range 0 to 63;   -- parity counter
   signal toggle       : integer range 0 to 1;
   -- Channel A: sinewave with frequency=Freq/12
   type sine16 is array (0 to 15) of std_logic_vector(15 downto 0);
   signal channel_a : sine16 := ((x"8000"), (x"b0fb"), (x"da82"), (x"f641"),
                                 (x"ffff"), (x"f641"), (x"da82"), (x"b0fb"),
                                 (x"8000"), (x"4f04"), (x"257d"), (x"09be"),
                                 (x"0000"), (x"09be"), (x"257d"), (x"4f04"));
   -- channel B: sinewave with frequency=Freq/24
   type sine8 is array (0 to 7) of std_logic_vector(15 downto 0);
   signal channel_b : sine8 := ((x"8000"), (x"da82"), (x"ffff"), (x"da82"),
                                (x"8000"), (x"257d"), (x"0000"), (x"257d"));
   signal channel_status : std_logic_vector(0 to 191);

begin

   spdif          <= ispdif;
   channel_status <= (others => '0');

-- Generate SPDIF signal 
   SGEN : process (clk, reset)
   begin
      if reset = '1' then
         fcnt   <= 184;  -- start just before block to shorten simulation
         bcnt   <= 0;
         toggle <= 0;
         ispdif <= '0';
         pcnt   <= 0;
      elsif rising_edge(clk) then
         if toggle = 1 then
            -- frame counter: 0 to 191
            if fcnt < 191 then
               if bcnt = 63 then
                  fcnt <= fcnt + 1;
               end if;
            else
               fcnt <= 0;
            end if;
            -- subframe bit counter: 0 to 63
            if bcnt < 63 then
               bcnt <= bcnt + 1;
            else
               bcnt <= 0;
            end if;
         end if;
         if toggle = 0 then
            toggle <= 1;
         else
            toggle <= 0;
         end if;
         -- subframe generation
         if fcnt = 0 and bcnt < 4 then
            ispdif <= Z_Preamble(7 - 2* bcnt - toggle);
         elsif fcnt > 0 and bcnt < 4 then
            ispdif <= X_Preamble(7 - 2 * bcnt - toggle);
         elsif bcnt > 31 and bcnt < 36 then
            ispdif <= Y_Preamble(71 - 2 * bcnt - toggle);
         end if;
         -- aux data, and 4 LSB are zero
         if (bcnt > 3 and bcnt < 12) or (bcnt > 35 and bcnt < 44) then
            if toggle = 0 then
               ispdif <= not ispdif;
            end if;
         end if;
         -- chanmel A data
         if (bcnt > 11) and (bcnt < 28) then
            if channel_a(fcnt mod 16)(bcnt - 12) = '0' then
               if toggle = 0 then
                  ispdif <= not ispdif;
               end if;
            else
               ispdif <= not ispdif;
               if toggle = 0 then
                  pcnt <= pcnt + 1;
               end if;
            end if;
         end if;
         -- channel B data
         if (bcnt > 43) and (bcnt < 60) then
            if channel_b(fcnt mod 8)(bcnt - 44) = '0' then
               if toggle = 0 then
                  ispdif <= not ispdif;
               end if;
            else
               ispdif <= not ispdif;
               if toggle = 0 then
                  pcnt <= pcnt + 1;
               end if;
            end if;
         end if;
         -- validity bit always 0
         if bcnt = 28 or bcnt = 60 then
            if toggle = 0 then
               ispdif <= not ispdif;
            end if;
         end if;
         -- user data always 0
         if bcnt = 29 or bcnt = 61 then
            if toggle = 0 then
               ispdif <= not ispdif;
            end if;
         end if;
         -- channel status bit
         if bcnt = 30 or bcnt = 62 then
            if channel_status(fcnt) = '0' then
               if toggle = 0 then
                  ispdif <= not ispdif;
               end if;
            else
               ispdif <= not ispdif;
               if toggle = 0 then
                  pcnt <= pcnt + 1;
               end if;
            end if;
         end if;
         -- parity bit, even parity
         if bcnt = 0 or bcnt = 32 then
            pcnt <= 0;
         end if;
         if bcnt = 31 or bcnt = 63 then
            if (pcnt mod 2) = 1 then
               ispdif <= not ispdif;
            else
               if toggle = 0 then
                  ispdif <= not ispdif;
               end if;
            end if;
         end if;
      end if;
   end process SGEN;

-- Clock process, generate a clock based on the desired sampling frequency    
   CLKG : process
      variable t1 : time := 1.0e12/real(FREQ*256) * 1 ps;
   begin
      clk <= '0';
      wait for t1;
      clk <= '1';
      wait for t1;
   end process CLKG;
   
end behav;
