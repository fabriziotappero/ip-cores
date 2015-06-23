--------------------------------------------------------------------------------
-- Filename: ratpack_tb1.vhd
-- Purpose : A simple testbench for "ratpack".
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

library STD, IEEE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
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

  -- Test the basic operators. 
  TEST_OPS: process
    variable a, b, c: rational := RAT_ZERO;
    variable BufLine: line;
  begin
    a := to_rational(5, 12);
    b := to_rational(2, 3);
    wait for CLK_PERIOD;
    -- Test rational addition
    c := a + b;    
    write(Bufline, a(numer));
    write(Bufline, string'("/"));
    write(Bufline, a(denom));
    write(Bufline, string'(" + "));            
    write(Bufline, b(numer));
    write(Bufline, string'("/"));
    write(Bufline, b(denom));
    write(Bufline, string'(" = "));
    write(Bufline, c(numer));
    write(Bufline, string'("/"));
    write(Bufline, c(denom));
    writeline(ResultsFile, Bufline);
    wait for CLK_PERIOD;
    -- Test rational subtraction
    c := a - b;    
    write(Bufline, a(numer));
    write(Bufline, string'("/"));
    write(Bufline, a(denom));
    write(Bufline, string'(" - "));            
    write(Bufline, b(numer));
    write(Bufline, string'("/"));
    write(Bufline, b(denom));
    write(Bufline, string'(" = "));
    write(Bufline, c(numer));
    write(Bufline, string'("/"));
    write(Bufline, c(denom));
    writeline(ResultsFile, Bufline);
    wait for CLK_PERIOD;
    -- Test rational multiplication
    c := a * b;    
    write(Bufline, a(numer));
    write(Bufline, string'("/"));
    write(Bufline, a(denom));
    write(Bufline, string'(" * "));            
    write(Bufline, b(numer));
    write(Bufline, string'("/"));
    write(Bufline, b(denom));
    write(Bufline, string'(" = "));
    write(Bufline, c(numer));
    write(Bufline, string'("/"));
    write(Bufline, c(denom));
    writeline(ResultsFile, Bufline);
    wait for CLK_PERIOD;
    -- Test rational division
    c := a / b;    
    write(Bufline, a(numer));
    write(Bufline, string'("/"));
    write(Bufline, a(denom));
    write(Bufline, string'(" : "));            
    write(Bufline, b(numer));
    write(Bufline, string'("/"));
    write(Bufline, b(denom));
    write(Bufline, string'(" = "));
    write(Bufline, c(numer));
    write(Bufline, string'("/"));
    write(Bufline, c(denom));
    writeline(ResultsFile, Bufline);
    wait for CLK_PERIOD;
    -- Test mediant
    c := mediant(a, b);
    write(Bufline, string'("mediant("));    
    write(Bufline, a(numer));
    write(Bufline, string'("/"));
    write(Bufline, a(denom));
    write(Bufline, string'(" , "));            
    write(Bufline, b(numer));
    write(Bufline, string'("/"));
    write(Bufline, b(denom));
    write(Bufline, string'(") = "));
    write(Bufline, c(numer));
    write(Bufline, string'("/"));
    write(Bufline, c(denom));
    writeline(ResultsFile, Bufline);
    wait for CLK_PERIOD;
  end process TEST_OPS;
  
end tb_arch;
