-- $Id: gray_cnt_5.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    gray_cnt_5 - syn
-- Description:    5 bit Gray code counter (ROM based)
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version    Comment
-- 2007-12-26   106   1.0      Initial version 
-- 
-- Some synthesis results:
-- - 2007-12-27 ise 8.2.03 for xc3s1000-ft256-4:
--   LUT Flop   clock(xst est.)
--     9    5   302MHz/ 3.31ns
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity gray_cnt_5 is                    -- 5 bit gray code counter (ROM based)
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv5                     -- data out
  );
end entity gray_cnt_5;


architecture syn of gray_cnt_5 is

  signal R_DATA : slv5 := (others=>'0');
  signal N_DATA : slv5 := (others=>'0');

  -- Note: in xst 8.2.03 fsm_extract="no" is needed. Otherwise an fsm
  --       is inferred, using 'Johnson' encoding. DATA will be deduced
  --       in a combinatorial logic, and will thus have very likely some
  --       glitches at the clock transitions, rendering the whole Gray
  --       coding useless.
  
  attribute fsm_extract : string;
  attribute fsm_extract of R_DATA : signal is "no";
  attribute rom_style : string;
  attribute rom_style of N_DATA : signal is "distributed";

begin

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_DATA <= (others=>'0');        
      elsif CE = '1' then
        R_DATA <= N_DATA;
      end if;
    end if;
  end process proc_regs;
    
  proc_next: process (R_DATA)
  begin

    N_DATA <= (others=>'0');
    case R_DATA is
      when "00000" => N_DATA <= "00001";    --  0
      when "00001" => N_DATA <= "00011";    --  1
      when "00011" => N_DATA <= "00010";    --  2
      when "00010" => N_DATA <= "00110";    --  3
      when "00110" => N_DATA <= "00111";    --  4
      when "00111" => N_DATA <= "00101";    --  5
      when "00101" => N_DATA <= "00100";    --  6
      when "00100" => N_DATA <= "01100";    --  7
      when "01100" => N_DATA <= "01101";    --  8
      when "01101" => N_DATA <= "01111";    --  9
      when "01111" => N_DATA <= "01110";    -- 10
      when "01110" => N_DATA <= "01010";    -- 11
      when "01010" => N_DATA <= "01011";    -- 12
      when "01011" => N_DATA <= "01001";    -- 13
      when "01001" => N_DATA <= "01000";    -- 14
      when "01000" => N_DATA <= "11000";    -- 15
      when "11000" => N_DATA <= "11001";    -- 16
      when "11001" => N_DATA <= "11011";    -- 17
      when "11011" => N_DATA <= "11010";    -- 18
      when "11010" => N_DATA <= "11110";    -- 19
      when "11110" => N_DATA <= "11111";    -- 20
      when "11111" => N_DATA <= "11101";    -- 21
      when "11101" => N_DATA <= "11100";    -- 22
      when "11100" => N_DATA <= "10100";    -- 23
      when "10100" => N_DATA <= "10101";    -- 24
      when "10101" => N_DATA <= "10111";    -- 25
      when "10111" => N_DATA <= "10110";    -- 26
      when "10110" => N_DATA <= "10010";    -- 27
      when "10010" => N_DATA <= "10011";    -- 28
      when "10011" => N_DATA <= "10001";    -- 29
      when "10001" => N_DATA <= "10000";    -- 30
      when "10000" => N_DATA <= "00000";    -- 31
      when others => null;
    end case;
  end process proc_next;

  DATA <= R_DATA;

end syn;

