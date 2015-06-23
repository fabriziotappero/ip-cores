----------------------------------------------------------------------
----                                                              ----
---- Math function library.                                       ----
----                                                              ----
---- This file is part of the Random Number Generator project     ----
---- http://www.opencores.org/cores/rng_lib/                      ----
----                                                              ----
---- Description                                                  ----
---- These math function are copied from the draft version of the ----
---- IEEE MATH_REAL package.                                      ----
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
-- Revision 1.1  2004/09/28 15:02:56  gedra
-- Math functions library.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package math_lib is

   function sqrt(x : real) return real;  -- returns square root
   function ln(x   : real) return real;  -- natural logarithm
   function log(x  : real) return real;  -- base 10 logarithm
   function exp(x  : real) return real;  -- exponential function

   -- Some mathematical constants
   constant MATH_E : real := 2.71828_18284_59045_23536;
   
end math_lib;

package body math_lib is

-- Square root calculation
   function sqrt (x : real) return real is
      -- returns square root of X;  X >= 0
      --
      -- Computes square root using the Newton-Raphson approximation:
      -- F(n+1) = 0.5*[F(n) + x/F(n)];
      --
      
      constant inival       : real := 1.5;
      constant eps          : real := 0.000001;
      constant relative_err : real := eps*X;

      variable oldval : real;
      variable newval : real;

   begin
      -- check validity of argument
      if x < 0.0 then
         report "x < 0 in sqrt(x)"
            severity failure;
         return (0.0);
      end if;

      -- get the square root for special cases
      if x = 0.0 then
         return 0.0;
      else
         if x = 1.0 then
            return 1.0;                 -- return exact value
         end if;
      end if;

      -- get the square root for general cases
      oldval := inival;
      newval := (X/oldval + oldval)/2.0;

      while (abs(newval -oldval) > relative_err) loop
         oldval := newval;
         newval := (X/oldval + oldval)/2.0;
      end loop;

      return newval;
   end sqrt;

-- Natural logarithm calculation
   function ln (x : real) return real is
      -- returns natural logarithm of X; X > 0
      --
      -- This function computes the exponential using the following series:
      --    log(x) = 2[ (x-1)/(x+1) + (((x-1)/(x+1))**3)/3.0 + ...] ; x > 0
      --
      
      constant eps : real := 0.000001;  -- precision criteria

      variable xlocal    : real;        -- following variables are
      variable oldval    : real;        -- used to evaluate the series
      variable xlocalsqr : real;
      variable factor    : real;
      variable count     : integer;
      variable newval    : real;
      
   begin
      -- check validity of argument
      if x <= 0.0 then
         report "x <= 0 in ln(x)"
            severity failure;
         return(real'low);
      end if;

      -- compute value for special cases
      if x = 1.0 then
         return 0.0;
      else
         if x = MATH_E then
            return 1.0;
         end if;
      end if;

      -- compute value for general cases
      xlocal    := (x - 1.0)/(x + 1.0);
      oldval    := xlocal;
      xlocalsqr := xlocal*xlocal;
      factor    := xlocal*xlocalsqr;
      count     := 3;
      newval    := oldval + (factor/real(count));

      while (abs(newval - oldval) > eps) loop
         oldval := newval;
         count  := count +2;
         factor := factor * xlocalsqr;
         newval := oldval + factor/real(count);
      end loop;

      newval := newval * 2.0;
      return newval;
   end ln;

-- Base 10 logarithm calculation
   function log (x : real) return real is
      -- returns logarithm base 10 of x; x > 0
   begin
      -- check validity of argument
      if x <= 0.0 then
         assert false report "x <= 0.0 in log(x)"
            severity error;
         return(real'low);
      end if;

      -- compute the value
      return (ln(x)/2.30258509299);
   end log;

-- Calculate e**x
   function exp (x : real) return real is
      -- returns e**X; where e = MATH_E
      --
      -- This function computes the exponential using the following series:
      --    exp(x) = 1 + x + x**2/2! + x**3/3! + ... ; x > 0
      --
      constant eps : real := 0.000001;  -- precision criteria

      variable reciprocal : boolean := x < 0.0;  -- check sign of argument
      variable xlocal     : real    := abs(x);   -- use positive value
      variable oldval     : real;                -- following variables are
      variable num        : real;                -- used for series evaluation
      variable count      : integer;
      variable denom      : real;
      variable newval     : real;
      
   begin
      -- compute value for special cases
      if x = 0.0 then
         return 1.0;
      else
         if x = 1.0 then
            return MATH_E;
         end if;
      end if;

      -- compute value for general cases
      oldval := 1.0;
      num    := xlocal;
      count  := 1;
      denom  := 1.0;
      newval := oldval + num/denom;

      while (abs(newval - oldval) > eps) loop
         oldval := newval;
         num    := num*xlocal;
         count  := count +1;
         denom  := denom*(real(count));
         newval := oldval + num/denom;
      end loop;

      if reciprocal then
         newval := 1.0/newval;
      end if;

      return newval;
   end exp;

end math_lib;
