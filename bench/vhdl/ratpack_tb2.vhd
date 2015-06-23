--------------------------------------------------------------------------------
-- Filename: ratpack_tb2.vhd
-- Purpose : A testbench for "ratpack" generating the Farey series' up to order 
--           12.
-- Author  : Nikolaos Kavvadias <nikolaos.kavvadias@gmail.com>
-- Date    : 14-May-2010
-- Version : 0.1
-- Revision: 0.0.0 (2010/05/14)
--           Initial version.
-- License : Copyright (C) 2010 by Nikolaos Kavvadias 
--           This program is free software. You can redistribute it and/or 
--           modify it under the terms of the GNU Lesser General Public License, 
--           either version 3 of the License, or (at your option) any later 
--           version. See COPYING.
--
--------------------------------------------------------------------------------

library STD;
use STD.textio.all;
use WORK.ratpack.all;


entity ratpack_tb is
end ratpack_tb;


architecture tb_arch of ratpack_tb is
  -------------------------------------------------------
  -- Declare results file
  -------------------------------------------------------
  file ResultsFile: text open write_mode is
  "ratpack_results.txt";
  -------------------------------------------------------
  -- Constant declarations
  -------------------------------------------------------
  constant CLK_PERIOD : time := 10 ns;
begin

  -- Compute the Farey sequences F1 to F12.
  -- The Farey sequence Fn for any positive integer n is the set of irreducible 
  -- rational numbers a/b with 0<=a<=b<=n  and (a,b)=1 arranged in increasing 
  -- order. 
  FAREY_SERIES: process
    variable a, b, c, d, k, n : integer;
    variable ta, tb, tc, td : integer;
    variable r : rational := RAT_ZERO;
    variable BufLine: line;
  begin
    for n in 1 to 12 loop
      write(Bufline, string'(" F"));
      write(Bufline, n);
      write(Bufline, string'("= "));
      -- Initialize a, b, c, d for computing the ascending Farey sequence
      a := 0;
      b := 1;
      c := 1;
      d := n;     
      -- Print r = a/b
      r := to_rational(a, b);
      write(Bufline, r(numer));
      write(Bufline, string'("/"));
      write(Bufline, r(denom));
      write(Bufline, string'(" "));      
      wait for CLK_PERIOD;      
      -- Compute the subsequent terms of the Farey sequence
      while (c < n) loop
        k := (n + b) / d;
        ta := a;
        tb := b;
        tc := c;
        td := d;
        a := tc;
        b := td;
        c := k * tc - ta;
        d := k * td - tb;
        c := k * tc - ta;
        -- Print r = a/b
        r := to_rational(a, b);
        write(Bufline, r(numer));
        write(Bufline, string'("/"));
        write(Bufline, r(denom));
        write(Bufline, string'(" "));            
        wait for CLK_PERIOD;
      end loop;
      writeline(ResultsFile, Bufline);
    end loop;
    wait for CLK_PERIOD;
  end process FAREY_SERIES;
  
end tb_arch;
