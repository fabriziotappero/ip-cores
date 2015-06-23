----------------------------------------------------------------------
----                                                              ----
---- Rand number generator library.                               ----
----                                                              ----
---- This file is part of the Random Number Generator project     ----
---- http://www.opencores.org/cores/rng_lib/                      ----
----                                                              ----
---- Description                                                  ----
---- This library has function for generation random numbers with ----
---- the following distributions:                                 ----
---- - Uniform (continous)                                        ----
---- - Exponential (continous)                                    ----
---- - Gaussian (continous)                                       ----
----                                                              ----
---- Random numbers are produced with a combination of 3          ----
---- Tausworthe generators which gives very good statistical      ----
---- properties.                                                  ----
----                                                              ----
---- NOTE! These functions will NOT synthesize. They are for test ----
----       bench use only!                                        ----
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
-- Revision 1.1  2004/09/28 15:12:28  gedra
-- Random number library functions.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.math_lib.all;

package rng_lib is

   type distribution is (UNIFORM, GAUSSIAN, EXPONENTIAL);
   type rand_var is record                          -- random variable record
      rnd                 : real;                   -- random number
      rnd_v               : unsigned(31 downto 0);  -- random number vector
      dist                : distribution;           -- distribution type
      y, z                : real;                   -- distribution parameters
      s1, s2, s3          : unsigned(31 downto 0);  -- seeds
      mask1, mask2, mask3 : unsigned(31 downto 0);
      shft1, shft2, shft3 : natural;
   end record;

   function rand (rnd : rand_var) return rand_var;
   function init_uniform(constant a, b, c : natural;
                         constant lo, hi  : real) return rand_var;
   function init_gaussian(constant a, b, c     : natural;
                          constant mean, stdev : real) return rand_var;
   function init_exponential(constant a, b, c : natural;
                             constant mean    : real) return rand_var;

   constant q1 : natural := 13;
   constant q2 : natural := 2;
   constant q3 : natural := 3;
   constant p1 : natural := 12;
   constant p2 : natural := 4;
   constant p3 : natural := 17;
   
end rng_lib;

package body rng_lib is

-- Function to convert 32bit unsigned vector to real
-- Integers only go to 2**31 (VHDL'87), so do it clever
   function unsigned_2_real (constant a : unsigned(31 downto 0)) return real is
      variable r : real;
   begin
      r := 2.0*real(to_integer(a(31 downto 1)));
      if a(0) = '1' then
         r := r + 1.0;
      end if;
      return(r);
   end unsigned_2_real;

-- Generate random number using a combination of 3 tausworthe generators 
-- Source: Pierre L'Ecuyer, "Maximally Equidistributed Combined Tausworthe
-- Generators". Mathematics of Computation, vol.65, no.213(1996), pp203--213.
   function rng (rnd : rand_var) return rand_var is
      variable new_rnd : rand_var;
      variable b       : unsigned(31 downto 0);
   begin
      new_rnd       := rnd;
      b             := ((new_rnd.s1 sll q1) xor new_rnd.s1) srl new_rnd.shft1;
      new_rnd.s1    := ((new_rnd.s1 and new_rnd.mask1) sll p1) xor b;
      b             := ((new_rnd.s2 sll q2) xor new_rnd.s2) srl new_rnd.shft2;
      new_rnd.s2    := ((new_rnd.s2 and new_rnd.mask2) sll p2) xor b;
      b             := ((new_rnd.s3 sll q3) xor new_rnd.s3) srl new_rnd.shft3;
      new_rnd.s3    := ((new_rnd.s3 and new_rnd.mask3) sll p3) xor b;
      new_rnd.rnd_v := new_rnd.s1 xor new_rnd.s2 xor new_rnd.s3;
      -- normalize to range [0,1)
      new_rnd.rnd   := unsigned_2_real(new_rnd.rnd_v) / 65536.0;
      new_rnd.rnd   := new_rnd.rnd / 65536.0;
      return (new_rnd);
   end rng;

-- rand function generates a random variable with different distributions
   function rand (rnd : rand_var) return rand_var is
      variable rnd_out : rand_var;
      variable x, y, z : real;
      variable t       : real := 0.0;
   begin
      case rnd.dist is
         -- Uniform distribution
         when UNIFORM =>
            rnd_out     := rng(rnd);
            rnd_out.rnd := rnd.y + (rnd_out.rnd * (rnd.z - rnd.y));
            -- Gaussian distribution
         when GAUSSIAN =>               -- Box-Mueller method
            z       := 2.0;
            rnd_out := rnd;
            while z > 1.0 or z = 0.0 loop
               -- choose x,y in uniform square (-1,-1) to (+1,+1)
               rnd_out := rng(rnd_out);
               x       := -1.0 + 2.0 * rnd_out.rnd;
               rnd_out := rng(rnd_out);
               y       := -1.0 + 2.0 * rnd_out.rnd;
               z       := (x * x) + (y * y);
            end loop;
            -- Box-Mueller transform
            rnd_out.rnd := rnd_out.y + rnd_out.z * y * sqrt(-2.0 * log(z)/z);
            -- Exponential distribution
         when EXPONENTIAL =>
            rnd_out     := rng(rnd);
            rnd_out.rnd := -rnd_out.y * log(1.0 - rnd_out.rnd);
         when others =>
            report "rand() function encountered an error!"
               severity failure;
      end case;
      return (rnd_out);
   end rand;

-- Initialize seeds, used by all init_ functions
   function gen_seed (constant a, b, c : natural) return rand_var is
      variable seeded : rand_var;
      variable x      : unsigned(31 downto 0) := "11111111111111111111111111111111";
      constant k1     : natural               := 31;
      constant k2     : natural               := 29;
      constant k3     : natural               := 28;
   begin
      seeded.shft1 := k1-p1;
      seeded.shft2 := k2-p2;
      seeded.shft3 := k3-p3;
      seeded.mask1 := x sll (32-k1);
      seeded.mask2 := x sll (32-k2);
      seeded.mask3 := x sll (32-k3);
      seeded.s1    := to_unsigned(390451501, 32);
      seeded.s2    := to_unsigned(613566701, 32);
      seeded.s3    := to_unsigned(858993401, 32);
      if to_unsigned(a, 32) > (to_unsigned(1, 32) sll (32-k1)) then
         seeded.s1 := to_unsigned(a, 32);
      end if;
      if to_unsigned(b, 32) > (to_unsigned(1, 32) sll (32-k2)) then
         seeded.s2 := to_unsigned(b, 32);
      end if;
      if to_unsigned(c, 32) > (to_unsigned(1, 32) sll (32-k3)) then
         seeded.s3 := to_unsigned(c, 32);
      end if;
      return(seeded);
   end gen_seed;

-- Uniform distribution random variable initialization
-- a,b,c are seeds
-- lo,hi is the range for the uniform distribution
   function init_uniform(constant a, b, c : natural;
                         constant lo, hi  : real) return rand_var is
      variable rnd, rout : rand_var;
   begin
      if lo >= hi then
         report "Uniform parameter error: 'hi' must be > 'lo'!"
            severity failure;
      end if;
      rnd      := gen_seed(a, b, c);
      rnd.dist := UNIFORM;
      rnd.y    := lo;
      rnd.z    := hi;
      rout     := rand(rnd);
      return(rout);
   end init_uniform;

-- Gaussian distribution random variable initialization
-- a,b,c are seeds
-- mean,stdev is mean and standard deviation
   function init_gaussian(constant a, b, c     : natural;
                          constant mean, stdev : real) return rand_var is
      variable rnd, rout : rand_var;
   begin
      if stdev = 0.0 then
         report "Gaussian parameter error: 'stdev' must be non-zero!"
            severity failure;
      end if;
      rnd      := gen_seed(a, b, c);
      rnd.dist := GAUSSIAN;
      rnd.y    := mean;
      rnd.z    := stdev;
      rout     := rand(rnd);
      return(rout);
   end init_gaussian;

-- Exponential distribution random variable initialization
-- a,b,c are seeds
-- mean: mean value
   function init_exponential(constant a, b, c : natural;
                             constant mean    : real) return rand_var is
      variable rnd, rout : rand_var;
   begin
      if mean <= 0.0 then
         report "Exponential parameter error: 'mean' must be > 0!"
            severity failure;
      end if;
      rnd      := gen_seed(a, b, c);
      rnd.dist := EXPONENTIAL;
      rnd.y    := mean;
      rout     := rand(rnd);
      return(rout);
   end init_exponential;
   
end rng_lib;
