-- $Id: byte2cdata.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2007-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    byte2cdata - syn
-- Description:    Byte stream to 9 bit comma,data converter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-10-17   596   2.0    re-write, commas now 2 byte sequences
-- 2011-11-19   427   1.0.2  now numeric_std clean
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-08-27    76   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.comlib.all;

entity byte2cdata is                    -- byte stream -> 9bit comma,data
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv8;                       -- input data
    ENA : in slbit;                     -- input data enable
    ERR : in slbit;                     -- input data error
    BUSY : out slbit;                   -- input data busy
    DO : out slv9;                      -- output data; bit 8 = comma flag
    VAL : out slbit;                    -- output data valid
    HOLD : in slbit                     -- output data hold
  );
end byte2cdata;


architecture syn of byte2cdata is

  type regs_type is record
    data : slv9;                        -- data
    dataval : slbit;                    -- data valid
    edpend : slbit;                     -- edata pending
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),                      -- data
    '0','0'                             -- dataval,edpend
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

begin

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;        
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, DI, ENA, ERR, HOLD)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable idata : slv9 := (others=>'0');
    variable iesc :  slbit := '0';
    variable ibusy : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    -- data path logic
    idata := '1' & "00000" & "100";   -- clobber
    iesc  := '0';
    
    if r.edpend = '1' then
      if DI(c_cdata_edf_pref) = c_cdata_ed_pref and
         (not DI(c_cdata_edf_eci)) = DI(c_cdata_edf_ec) then
        case DI(c_cdata_edf_ec) is
          when c_cdata_ec_xon =>
            idata := '0' & c_cdata_xon;
          when c_cdata_ec_xoff =>
            idata := '0' & c_cdata_xoff;
          when c_cdata_ec_fill =>
            idata := '0' & c_cdata_fill;
          when c_cdata_ec_esc =>
            idata := '0' & c_cdata_escape;
          when others => 
            idata := '1' &  "00000" & DI(c_cdata_edf_ec);
        end case;
      end if;
    else
      idata := '0' & DI;
      if DI = c_cdata_escape then
        iesc := '1';
      end if;
    end if;

    -- control path logic
    ibusy := '1';
    if HOLD = '0' then
      ibusy     := '0';
      n.dataval := '0';
      n.data    := idata;
      if ENA = '1' then
        if r.edpend = '0' then
          if iesc = '0' then
            n.dataval := '1';
          else
            n.edpend  := '1';
          end if;
        else
          n.dataval := '1';
          n.edpend  := '0';
        end if;
      elsif ERR = '1' then
        n.dataval := '1';
      end if;
    end if;    

    N_REGS <= n;

    DO   <= r.data;
    VAL  <= r.dataval;
    BUSY <= ibusy;
    
  end process proc_next;


end syn;
