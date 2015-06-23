-- $Id: pdp11_dspmux.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_dspmux - syn
-- Description:    pdp11: hio dsp mux
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-22   650   1.0    Initial version 
-- 2015-02-21   649   0.1    First draft
------------------------------------------------------------------------------
-- selects display data
--   4 Digit Displays
--     SEL(1:0)  00  ABCLKDIV
--               01  DM_STAT_DP.pc
--               10  DISPREG 
--               11  DM_STAT_DP.dsrc
--
--  8 Digit Displays
--     SEL(1)   select DSP(7:4)
--                0  ABCLKDIV
--                1  DM_STAT_DP.pc
--     SEL(0)   select DSP(7:4)
--                0  DISPREG
--                1  DM_STAT_DP.dsrc
--                

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_dspmux is               -- hio dsp mux
  generic (
    DCWIDTH : positive := 2);           -- digit counter width (2 or 3)
  port (
    SEL : in slv2;                      -- select
    ABCLKDIV : in slv16;                -- serport clock divider
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    DISPREG : in slv16;                 -- display register
    DSP_DAT : out slv(4*(2**DCWIDTH)-1 downto 0)   -- display data
  );
end pdp11_dspmux;

architecture syn of pdp11_dspmux is

  subtype  dspdat_msb is integer range 4*(2**DCWIDTH)-1 downto 4*(2**DCWIDTH)-16;
  subtype  dspdat_lsb is integer range 15 downto 0;
  
begin

  assert DCWIDTH=2 or DCWIDTH=3 
    report "assert(DCWIDTH=2 or DCWIDTH=3): unsupported DCWIDTH"
    severity failure;

  proc_mux: process (SEL, ABCLKDIV, DM_STAT_DP, DISPREG)
    variable idat : slv(4*(2**DCWIDTH)-1 downto 0) := (others=>'0');
  begin
    idat := (others=>'0');

    if DCWIDTH = 2 then

      case SEL is
        when "00" => 
          idat(dspdat_lsb) := ABCLKDIV;
        when "01" => 
          idat(dspdat_lsb) := DM_STAT_DP.pc;
        when "10" =>
          idat(dspdat_lsb) := DISPREG;
        when "11" => 
          idat(dspdat_lsb) := DM_STAT_DP.dsrc;
        when others => null;
      end case;

    else

      if SEL(1) = '0' then
        idat(dspdat_msb) := ABCLKDIV;
      else
        idat(dspdat_msb) := DM_STAT_DP.pc;
      end if;

      if SEL(0) = '0' then
        idat(dspdat_lsb) := DISPREG;
      else
        idat(dspdat_lsb) := DM_STAT_DP.dsrc;
      end if;
      
    end if;
    
    DSP_DAT <= idat;
    
  end process proc_mux;

end syn;
