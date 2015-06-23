-- $Id: gray_cnt_n.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
-- 
------------------------------------------------------------------------------
-- Module Name:    gray_cnt_n - syn
-- Description:    Genric width Gray code counter
--
-- Dependencies:   -
-- Test bench:     tb/tb_debounce_gen
-- Target Devices: generic
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version    Comment
-- 2007-12-26   106   1.0      Initial version 
--
-- Some synthesis results:
-- - 2007-12-27 ise 8.2.03 for xc3s1000-ft256-4:
--   DWIDTH  LUT Flop   clock(xst est.)
--        4    6    5   305MHz/ 3.28ns
--        5    8    6   286MHz/ 2.85ns
--        8   13    9   234MHz/ 4.26ns
--       16   56   17   149MHz/ 6.67ns
--       32   95   33   161MHz/ 6.19ns
--       64  188   68   126MHz/ 7.90ns
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.genlib.all;

entity gray_cnt_n is                    -- n bit gray code counter
  generic (
    DWIDTH : positive := 8);            -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv(DWIDTH-1 downto 0)   -- data out
  );
end entity gray_cnt_n;


architecture syn of gray_cnt_n is

  signal R_AUX : slbit := '1';
  signal R_DATA : slv(DWIDTH-1 downto 0) := (others=>'0');
  signal N_DATA : slv(DWIDTH-1 downto 0) := (others=>'0');

begin
  
  assert DWIDTH>=3
    report "assert(DWIDTH>=3): only 3 bit or larger supported"
    severity failure;

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_AUX  <= '1';
        R_DATA <= (others=>'0');        
      elsif CE = '1' then
        R_AUX  <= not R_AUX;
        R_DATA <= N_DATA;
      end if;
    end if;
  end process proc_regs;
    
  proc_next: process (R_AUX, R_DATA)
    variable r : slv(DWIDTH-1 downto 0) := (others=>'0');
    variable n : slv(DWIDTH-1 downto 0) := (others=>'0');
    variable s : slbit := '0';
  begin

    r := R_DATA;
    n := R_DATA;
    s := '1';
    
    if R_AUX = '1' then
      n(0) := not r(0);
    else
      for i in 1 to DWIDTH-2 loop
        if s='1' and r(i-1)='1' then
          n(i) := not r(i);
        end if;
        s := s and not r(i-1);
      end loop;
      if s = '1' then
        n(DWIDTH-1) := r(DWIDTH-2);
      end if;
    end if;

    N_DATA <= n;
    
  end process proc_next;

  DATA <= R_DATA;

end syn;

