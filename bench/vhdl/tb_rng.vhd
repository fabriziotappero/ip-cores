----------------------------------------------------------------------
----                                                              ----
---- Testbench for Rand number generator library.                 ----
----                                                              ----
---- This file is part of the Random Number Generator project     ----
---- http://www.opencores.org/cores/rng_lib/                      ----
----                                                              ----
---- Description                                                  ----
---- The test bench will generate 10000 random numbers from each  ----
---- distribution and do a simple plot of the distributions.      ----
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
-- Revision 1.1  2004/09/28 15:12:52  gedra
-- Test bench for random numbers.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.rng_lib.all;

entity tb_rng is

end tb_rng;

architecture behav of tb_rng is

   constant BIN_COUNT   : integer := 15;
   constant PLOT_HEIGHT : real    := 40.0;
   constant RAND_COUNT  : integer := 10000;

   type rand_array is array (0 to RAND_COUNT - 1) of real;  -- array used for plot
   type bin_array is array (0 to BIN_COUNT - 1) of integer;

-- Plot a distribution of the numbers that are between lo,hi values
   impure function plot_dist (numbs : rand_array; lo, hi : real) return integer is
      variable bins             : bin_array;
      variable bin_size, height : real;
      variable idx, max         : integer;
      variable bar              : line;
   begin
      -- reset bins
      for i in 0 to BIN_COUNT - 1 loop
         bins(i) := 0;
      end loop;
      -- sort numbers into bins
      bin_size := (hi - lo) / real(BIN_COUNT);
      for i in 0 to RAND_COUNT - 1 loop
         if numbs(i) > lo and numbs(i) < hi then
            idx := integer(((numbs(i) - lo) / bin_size) - 0.5);
            if idx > BIN_COUNT - 1 then
               idx := BIN_COUNT - 1;
            elsif idx < 0 then
               idx := 0;
            end if;
            bins(idx) := bins(idx) + 1;
         end if;
      end loop;
      -- find largest bin
      max := 0;
      for i in 0 to BIN_COUNT - 1 loop
         if bins(i) > max then
            max := bins(i);
         end if;
      end loop;
      -- plot bins
      for i in 0 to BIN_COUNT - 1 loop
         height := PLOT_HEIGHT * real(bins(i)) / real(max);
         for j in 1 to integer(height) loop
            write(bar, string'("*"));
         end loop;
         writeline(OUTPUT, bar);
      end loop;
      return 0;
   end plot_dist;
   
begin

   p1 : process
      variable r_uni, r_gauss, r_exp : rand_var;
      variable r_poisson             : rand_var;
      variable txt                   : line;
      variable a                     : integer;
      variable numbs                 : rand_array;
   begin
      -- Test the uniform distribution
      r_uni := init_uniform(0, 0, 0, 0.0, 10.0);     -- range 0 to 10
      t1 : for i in 0 to RAND_COUNT - 1 loop
         r_uni    := rand(r_uni);
         numbs(i) := r_uni.rnd;
      end loop t1;
      write(txt, string'("Uniform distribution:"));
      writeline(OUTPUT, txt);
      a       := plot_dist (numbs, 0.0, 10.0);
      -- Test the gaussian distribution
      r_gauss := init_gaussian(0, 0, 0, 0.0, 10.0);  -- mean=0, stdev=10
      t2 : for i in 0 to RAND_COUNT - 1 loop
         r_gauss  := rand(r_gauss);
         numbs(i) := r_gauss.rnd;
      end loop t2;
      write(txt, string'("Gaussian distribution:"));
      writeline(OUTPUT, txt);
      a     := plot_dist (numbs, -20.0, 20.0);
      -- Test the exponential distribution
      r_exp := init_exponential(0, 0, 0, 10.0);      -- mean=10
      t3 : for i in 0 to RAND_COUNT - 1 loop
         r_exp    := rand(r_exp);
         numbs(i) := r_exp.rnd;
      end loop t3;
      write(txt, string'("Exponential distribution:"));
      writeline(OUTPUT, txt);
      a := plot_dist (numbs, 0.0, 20.0);

      wait for 1 ns;

      report "End of simulation! (ignore this failure)"
         severity failure;
      wait;
   end process p1;
   
end behav;
