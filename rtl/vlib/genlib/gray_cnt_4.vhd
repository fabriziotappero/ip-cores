-- $Id: gray_cnt_4.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    gray_cnt_4 - syn
-- Description:    4 bit Gray code counter (ROM based)
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
--     4    4   365MHz/ 2.76ns
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity gray_cnt_4 is                    -- 4 bit gray code counter (ROM based)
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv4                     -- data out
  );
end entity gray_cnt_4;


architecture syn of gray_cnt_4 is

  signal R_DATA : slv4 := (others=>'0');
  signal N_DATA : slv4 := (others=>'0');
  
  -- Note: in xst 8.2.03 fsm_extract="no" is needed. Otherwise an fsm is
  --       inferred. For 4 bit the coding was 'Gray', but see remarks in
  --       gray_cnt_5. To be save, disallow fsm inferal, enforce reg+rom.

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
      when "0000" => N_DATA <= "0001";    --  0
      when "0001" => N_DATA <= "0011";    --  1
      when "0011" => N_DATA <= "0010";    --  2
      when "0010" => N_DATA <= "0110";    --  3
      when "0110" => N_DATA <= "0111";    --  4
      when "0111" => N_DATA <= "0101";    --  5
      when "0101" => N_DATA <= "0100";    --  6
      when "0100" => N_DATA <= "1100";    --  7
      when "1100" => N_DATA <= "1101";    --  8
      when "1101" => N_DATA <= "1111";    --  9
      when "1111" => N_DATA <= "1110";    -- 10
      when "1110" => N_DATA <= "1010";    -- 11
      when "1010" => N_DATA <= "1011";    -- 12
      when "1011" => N_DATA <= "1001";    -- 13
      when "1001" => N_DATA <= "1000";    -- 14
      when "1000" => N_DATA <= "0000";    -- 15
      when others => null;
    end case;
  end process proc_next;

  DATA <= R_DATA;

end syn;

