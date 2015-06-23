--! @file
--! @brief clock for simulation with selectable frequency and reset with selectable width.

-- (c) jul 2007... Gerhard Hoffmann  opencores@hoffmann-hochfrequenz.de
-- Published under BSD license
-- V1.0  first published version
--
--! @details Solution to an everyday problem.
--! This module produces a clock for a simulation with selectable frequency
--! and a reset signal with selectable width. The duty cycle is 1:1.
--! The reset is active from the beginning and removed synchronously shortly
--! after a rising clock edge.
--! setting verbose to true gives some diagnostics.
--
-- Make sure that your simulator has a time resolution of at least 1 ps.
-- For modelsim, this is set up by the various modelsim.ini files
-- and/or the project file (foobar.mpf)


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity clk_rst is
  generic (
    verbose:         boolean := false;
    clock_frequency: real    := 100.0e6;  -- 100 MHz
    min_resetwidth:  time    := 12 ns     -- minimum resetwidth, is synchronized to clk  
	);
  port (  
    clk: out std_logic;
    rst: out std_logic
  );  
end entity clk_rst;


architecture rtl of clk_rst is


-- The clock frequency is given in Hz in floating point format.
-- compute the equivalent half cycle time.

function frequency2halfcycle(f: real; verbose: boolean) return time is

  variable picoseconds: real; 
  variable retval:      time;
    
begin
  assert f > 1.0e-10 
    report "clk_and_rst.vhd: requested clock frequency is unreasonably low or even negative - danger of 1/0.0"
    severity error;

  picoseconds := (0.5 / f ) / 1.0e-12;
  retval := integer(picoseconds) * 1 ps;

  if verbose then
    report "function frequency2halfcycle() in clk_rst.vhd: picoseconds = " & real'image(picoseconds);
    report "halfcycle = " & time'image(retval);
  end if; 
        
  assert retval > 0 ps 
    report "frequency2halfcycle(): length of halfcycle truncated to 0 ps. "
         & "Set simulator resolution to 1 ps or smaller in modelsim.ini, foobar.mpf or whatever your simulator uses"
    severity error;

  return retval;
end;


signal iclk:      std_logic := '0';  -- entity-internal clk and rst
signal irst:      std_logic := '1';

constant halfcycle: time    := frequency2halfcycle(clock_frequency, verbose);

----------------------------------------------------------------------------------------------------   
begin
   
--
-- generate the internal system clock
  
u_sysclock: process is
begin
   wait for halfcycle;
   iclk <= '1';
   
   wait for halfcycle;
   iclk <= '0';
end process u_sysclock;


--
-- generate internal reset

u_rst: process is
begin
   irst <= '1';
   wait for min_resetwidth;
   wait until rising_edge(iclk);
   irst <= '0';
   wait;    -- forever
end process u_rst;

-- make the local signals public

clk <= iclk;
rst <= irst;

end architecture rtl;

