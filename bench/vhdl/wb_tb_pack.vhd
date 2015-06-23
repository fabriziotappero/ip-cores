----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Wishbone testbench funtions.                                 ----
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
-- Revision 1.7  2005/05/08 13:15:30  gedra
-- Added procedure for vector checking.
--
-- Revision 1.6  2004/07/19 16:57:17  gedra
-- Improved test bench package.
--
-- Revision 1.5  2004/07/15 17:43:53  gedra
-- Added string type casting to make ModelSim happy.
--
-- Revision 1.4  2004/07/12 17:06:08  gedra
-- Test bench update.
--
-- Revision 1.3  2004/07/11 16:20:16  gedra
-- Improved test bench.
--
-- Revision 1.2  2004/06/26 14:11:39  gedra
-- Converter to numeric_std and added hex functions
--
-- Revision 1.1  2004/06/24 19:26:02  gedra
-- Wishbone bus utilities.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package wb_tb_pack is

   constant WRITE_TIMEOUT : integer := 20;  -- Max cycles to wait during write
   constant READ_TIMEOUT  : integer := 20;  -- Max cycles to wait during read
   constant TIME_WIDTH    : integer := 15;  -- Number of chars for time field

   shared variable errors   : integer := 0;  -- error counter during simulation
   shared variable rd_tout  : integer;  -- read timeout flag used by check()
   shared variable no_print : integer := 0;  -- no print during check()

   function int_2_hex (value : natural; width : natural) return string;
   function slv_2_hex (value : std_logic_vector) return string;
   
   procedure wb_write (
      constant ADDRESS : in  natural;
      constant DATA    : in  natural;
      signal wb_adr_o  : out std_logic_vector;
      signal wb_dat_o  : out std_logic_vector;
      signal wb_cyc_o  : out std_logic;
      signal wb_sel_o  : out std_logic;
      signal wb_we_o   : out std_logic;
      signal wb_clk_i  : in  std_logic;
      signal wb_ack_i  : in  std_logic);

   procedure wb_read (
      constant ADDRESS   : in  natural;
      variable read_data : out std_logic_vector;
      signal wb_adr_o    : out std_logic_vector;
      signal wb_dat_i    : in  std_logic_vector;
      signal wb_cyc_o    : out std_logic;
      signal wb_sel_o    : out std_logic;
      signal wb_we_o     : out std_logic;
      signal wb_clk_i    : in  std_logic;
      signal wb_ack_i    : in  std_logic);

   procedure wb_check (
      constant ADDRESS  : in  natural;
      constant EXP_DATA : in  natural;
      signal wb_adr_o   : out std_logic_vector;
      signal wb_dat_i   : in  std_logic_vector;
      signal wb_cyc_o   : out std_logic;
      signal wb_sel_o   : out std_logic;
      signal wb_we_o    : out std_logic;
      signal wb_clk_i   : in  std_logic;
      signal wb_ack_i   : in  std_logic);

   procedure message (
      constant MSG : in string);        -- message to be printed

   procedure wait_for_event (
      constant MSG     : in string;      -- message
      constant TIMEOUT : in time;        -- timeout
      signal trigger   : in std_logic);  -- trigger expression

   procedure signal_check (
      constant MSG   : in string;       -- signal name
      constant VALUE : in std_logic;    -- expected value
      signal sig     : in std_logic);   -- signal to check

   procedure sim_report (
      constant MSG : in string);

   procedure vector_check (
      constant MSG   : in string;             -- signal name
      constant VALUE : in std_logic_vector;   -- expected value
      signal sig     : in std_logic_vector);  -- vector to check

end wb_tb_pack;

package body wb_tb_pack is

-- convert natural to hex format. Number of digits must be specified
   function int_2_hex (value : natural; width : natural) return string is
      variable tmp     : string(1 to width + 2);
      variable digit   : integer range 0 to 15;
      variable invalue : integer;
      variable pos     : integer;
   begin
      tmp(1 to 2) := "0x";
      invalue     := value;
      FL : for i in 1 to width loop
         digit   := invalue mod 16;
         invalue := invalue / 16;
         pos     := 3 + width - i;
         case digit is
            when 0      => tmp(pos) := '0';
            when 1      => tmp(pos) := '1';
            when 2      => tmp(pos) := '2';
            when 3      => tmp(pos) := '3';
            when 4      => tmp(pos) := '4';
            when 5      => tmp(pos) := '5';
            when 6      => tmp(pos) := '6';
            when 7      => tmp(pos) := '7';
            when 8      => tmp(pos) := '8';
            when 9      => tmp(pos) := '9';
            when 10     => tmp(pos) := 'a';
            when 11     => tmp(pos) := 'b';
            when 12     => tmp(pos) := 'c';
            when 13     => tmp(pos) := 'd';
            when 14     => tmp(pos) := 'e';
            when 15     => tmp(pos) := 'f';
            when others => tmp(pos) := '?';
         end case;
      end loop FL;
      return(tmp);
   end int_2_hex;

   -- Convert std_logic_vector to hex format. 
   function slv_2_hex (value : std_logic_vector) return string is
      variable tmp           : string(1 to value'length + 2);
      variable subdigit      : std_logic_vector(3 downto 0);
      variable digits, pos   : integer;
      variable actual_length : integer;
      variable ext_val       : std_logic_vector(value'length + 3 downto 0);
   begin
      tmp(1 to 2)                                   := "0x";
      ext_val(value'length - 1 downto 0)            := value;
      ext_val(value'length + 3 downto value'length) := (others => '0');
      -- pad with zero's if length is not a factor of 4
      if value'length mod 4 /= 0 then
         actual_length := value'length + 4 - (value'length mod 4);
      else
         actual_length := value'length;
      end if;
      digits := actual_length / 4;
      -- convert 4 and 4 bits into hex digits
      F1 : for i in digits downto 1 loop
         subdigit(3 downto 0) := ext_val(i * 4 - 1 downto i * 4 - 4);
         pos                  := 3 + digits - i;
         case subdigit is
            when "0000" => tmp(pos) := '0';
            when "0001" => tmp(pos) := '1';
            when "0010" => tmp(pos) := '2';
            when "0011" => tmp(pos) := '3';
            when "0100" => tmp(pos) := '4';
            when "0101" => tmp(pos) := '5';
            when "0110" => tmp(pos) := '6';
            when "0111" => tmp(pos) := '7';
            when "1000" => tmp(pos) := '8';
            when "1001" => tmp(pos) := '9';
            when "1010" => tmp(pos) := 'a';
            when "1011" => tmp(pos) := 'b';
            when "1100" => tmp(pos) := 'c';
            when "1101" => tmp(pos) := 'd';
            when "1110" => tmp(pos) := 'e';
            when "1111" => tmp(pos) := 'f';
            when others => tmp(pos) := '?';
         end case;
      end loop F1;
      return(tmp(1 to 2 + digits));
   end slv_2_hex;

-- Classic Wishbone write cycle
   procedure wb_write (
      constant ADDRESS : in  natural;
      constant DATA    : in  natural;
      signal wb_adr_o  : out std_logic_vector;
      signal wb_dat_o  : out std_logic_vector;
      signal wb_cyc_o  : out std_logic;
      signal wb_sel_o  : out std_logic;
      signal wb_we_o   : out std_logic;
      signal wb_clk_i  : in  std_logic;
      signal wb_ack_i  : in  std_logic) is
      variable txt                  : line;
      variable adr_width, dat_width : natural;
      constant WEAK_BUS             : std_logic_vector(wb_adr_o'range) := (others => 'W');
      constant LOW_BUS              : std_logic_vector(wb_dat_o'range) := (others => 'L');
   begin
      -- determine best width for number printout
      if wb_adr_o'length < 9 then
         adr_width := 2;
      elsif wb_adr_o'length < 17 and wb_adr_o'length > 8 then
         adr_width := 4;
      else
         adr_width := 6;
      end if;
      if wb_dat_o'length < 9 then
         dat_width := 2;
      elsif wb_dat_o'length < 17 and wb_dat_o'length > 8 then
         dat_width := 4;
      else
         dat_width := 8;
      end if;
      -- start cycle on positive edge
      wait until rising_edge(wb_clk_i);
      write(txt, string'("@"));
      write(txt, now, right, TIME_WIDTH);
      write(txt, string'(" Wrote "));
      write(txt, int_2_hex(DATA, dat_width));
      write(txt, string'(" to addr. "));
      write(txt, int_2_hex(ADDRESS, adr_width));
      wb_adr_o <= std_logic_vector(to_unsigned(ADDRESS, wb_adr_o'length));
      wb_dat_o <= std_logic_vector(to_unsigned(DATA, wb_dat_o'length));
      wb_we_o  <= '1';
      wb_cyc_o <= '1';
      wb_sel_o <= '1';
      -- wait for acknowledge
      wait until rising_edge(wb_clk_i);
      if wb_ack_i /= '1' then
         for i in 1 to WRITE_TIMEOUT loop
            wait until rising_edge(wb_clk_i);
            exit when wb_ack_i = '1';
            if (i = WRITE_TIMEOUT) then
               --write(txt, string'("- @ "));
               --write(txt, now, right, DEFAULT_TIMEWIDTH, DEFAULT_TIMEBASE);
               write (txt, string'("Warning: No acknowledge recevied!"));
            end if;
         end loop;
      end if;
      -- release bus
      wb_adr_o <= WEAK_BUS;
      wb_dat_o <= LOW_BUS;
      wb_we_o  <= 'L';
      wb_cyc_o <= 'L';
      wb_sel_o <= 'L';
      writeline(OUTPUT, txt);
   end;

-- Classic Wishbone read cycle
   procedure wb_read (
      constant ADDRESS   : in  natural;
      variable read_data : out std_logic_vector;
      signal wb_adr_o    : out std_logic_vector;
      signal wb_dat_i    : in  std_logic_vector;
      signal wb_cyc_o    : out std_logic;
      signal wb_sel_o    : out std_logic;
      signal wb_we_o     : out std_logic;
      signal wb_clk_i    : in  std_logic;
      signal wb_ack_i    : in  std_logic) is
      variable txt                  : line;
      variable adr_width, dat_width : natural;
      constant WEAK_BUS             : std_logic_vector(wb_adr_o'range) := (others => 'W');
   begin
      -- determine best width for number printout
      if wb_adr_o'length < 9 then
         adr_width := 2;
      elsif wb_adr_o'length < 17 and wb_adr_o'length > 8 then
         adr_width := 4;
      else
         adr_width := 6;
      end if;
      if wb_dat_i'length < 9 then
         dat_width := 2;
      elsif wb_dat_i'length < 17 and wb_dat_i'length > 8 then
         dat_width := 4;
      else
         dat_width := 8;
      end if;
      -- start cycle on positive edge
      wait until rising_edge(wb_clk_i);
      write(txt, string'("@"));
      write(txt, now, right, TIME_WIDTH);
      wb_adr_o <= std_logic_vector(to_unsigned(ADDRESS, wb_adr_o'length));
      wb_we_o  <= '0';
      wb_cyc_o <= '1';
      wb_sel_o <= '1';
      -- wait for acknowledge 
      wait until rising_edge(wb_clk_i);
      rd_tout  := 0;
      if wb_ack_i /= '1' then
         for i in 1 to READ_TIMEOUT loop
            wait until rising_edge(wb_clk_i);
            exit when wb_ack_i = '1';
            if (i = READ_TIMEOUT) then
               write (txt, string'("Warning: WB_read timeout!"));
               if no_print = 0 then
                  writeline(OUTPUT, txt);
               end if;
               rd_tout := 1;
               errors  := errors + 1;
            end if;
         end loop;
      end if;
      read_data := wb_dat_i;
      if rd_tout = 0 then
         write(txt, string'(" Read "));
         write(txt, slv_2_hex(wb_dat_i));
         write(txt, string'(" from addr. "));
         write(txt, int_2_hex(ADDRESS, adr_width));
         if no_print = 0 then
            writeline(OUTPUT, txt);
         end if;
      end if;
      -- release bus
      wb_adr_o <= WEAK_BUS;
      wb_we_o  <= 'L';
      wb_cyc_o <= 'L';
      wb_sel_o <= 'L';
   end;

-- Check: A read operation followed by a data compare
   procedure wb_check (
      constant ADDRESS  : in  natural;
      constant EXP_DATA : in  natural;
      signal wb_adr_o   : out std_logic_vector;
      signal wb_dat_i   : in  std_logic_vector;
      signal wb_cyc_o   : out std_logic;
      signal wb_sel_o   : out std_logic;
      signal wb_we_o    : out std_logic;
      signal wb_clk_i   : in  std_logic;
      signal wb_ack_i   : in  std_logic) is
      variable txt                  : line;
      variable tout                 : integer;
      variable adr_width, dat_width : natural;
      constant WEAK_BUS             : std_logic_vector(wb_adr_o'range) := (others => 'W');
      variable read_data            : std_logic_vector(wb_dat_i'left downto 0);
   begin
      no_print := 1;                    --  stop read() from printing message
      wb_read (ADDRESS, read_data, wb_adr_o, wb_dat_i, wb_cyc_o, wb_sel_o,
               wb_we_o, wb_clk_i, wb_ack_i);
      no_print := 0;
      -- determine best width for number printout
      if wb_adr_o'length < 9 then
         adr_width := 2;
      elsif wb_adr_o'length < 17 and wb_adr_o'length > 8 then
         adr_width := 4;
      else
         adr_width := 6;
      end if;
      if wb_dat_i'length < 9 then
         dat_width := 2;
      elsif wb_dat_i'length < 17 and wb_dat_i'length > 8 then
         dat_width := 4;
      else
         dat_width := 8;
      end if;
      write(txt, string'("@"));
      write(txt, now, right, TIME_WIDTH);

      if rd_tout = 0 then
         if read_data = std_logic_vector(to_unsigned(EXP_DATA, wb_dat_i'length)) then
            write(txt, string'(" Check "));
            write(txt, slv_2_hex(wb_dat_i));
            write(txt, string'(" at addr. "));
            write(txt, int_2_hex(ADDRESS, adr_width));
            write(txt, string'(" - OK!"));
         else
            write(txt, string'(" Check failed at addr. "));
            write(txt, int_2_hex(ADDRESS, adr_width));
            write(txt, string'("! Got "));
            write(txt, slv_2_hex(wb_dat_i));
            write(txt, string'(", expected "));
            write(txt, int_2_hex(EXP_DATA, dat_width));
            errors := errors + 1;
         end if;
         writeline(OUTPUT, txt);
      else
         write(txt, string'(" Read timeout from addr. "));
         write(txt, int_2_hex(ADDRESS, adr_width));
         write(txt, string'(" during check!"));
         writeline(OUTPUT, txt);
      end if;
   end;

-- display a message with time stamp
   procedure message (
      constant MSG : in string) is
      variable txt : line;
   begin
      write(txt, string'("@"));
      write(txt, now, right, TIME_WIDTH);
      write(txt, string'(" -- ") & MSG);
      writeline(OUTPUT, txt);
   end;

-- wait for event to happen, with timeout
   procedure wait_for_event (
      constant MSG     : in string;        -- message
      constant TIMEOUT : in time;          -- timeout
      signal trigger   : in std_logic) is  -- trigger signal
      variable txt : line;
      variable t1  : time;
   begin
      t1 := now;
      wait on trigger for timeout;
      write(txt, string'("@"));
      write(txt, now, right, TIME_WIDTH);
      write(txt, string'(" "));
      write(txt, MSG);
      if now - t1 >= TIMEOUT then
         write(txt, string'(" - Timed out!"));
         errors := errors + 1;
      else
         write(txt, string'(" - OK!"));
      end if;
      writeline(OUTPUT, txt);
   end;

-- check signal value
   procedure signal_check (
      constant MSG   : in string;        -- signal name
      constant VALUE : in std_logic;     -- expected value
      signal sig     : in std_logic) is  -- signal to check
      variable txt : line;
   begin
      write(txt, string'("@"));
      write(txt, now, right, TIME_WIDTH);
      write(txt, string'(" "));
      write(txt, MSG);
      write(txt, string'(" "));
      if sig = VALUE then
         write(txt, string'("verified to be "));
      else
         write(txt, string'("has incorrect value! Expected "));
         errors := errors + 1;
      end if;
      if VALUE = '1' then
         write(txt, string'("1!"));
      else
         write(txt, string'("0!"));
      end if;
      writeline(OUTPUT, txt);
   end;

-- Report number of errors encountered during simulation
   procedure sim_report (
      constant MSG : in string) is
      variable txt : line;
   begin
      write(txt, string'("@"));
      write(txt, now, right, TIME_WIDTH);
      write(txt, string'(" Simulation completed with "));
      write(txt, errors);
      write(txt, string'(" errors!"));
      writeline(OUTPUT, txt);
   end;

-- check vector value
   procedure vector_check (
      constant MSG   : in string;               -- signal name
      constant VALUE : in std_logic_vector;     -- expected value
      signal sig     : in std_logic_vector) is  -- signal to check
      variable txt : line;
   begin
      write(txt, string'("@"));
      write(txt, now, right, TIME_WIDTH);
      write(txt, string'(" "));
      write(txt, MSG);
      write(txt, string'(" "));
      if sig = VALUE then
         write(txt, string'("verified to be "));
      else
         write(txt, string'("has incorrect value! Expected "));
         write(txt, slv_2_hex(VALUE));
         write(txt, string'(", but got "));
         errors := errors + 1;
      end if;
      write(txt, slv_2_hex(sig));
      writeline(OUTPUT, txt);
   end;
   
end wb_tb_pack;

