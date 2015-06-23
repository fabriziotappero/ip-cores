-- $Id: cdata2byte.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    cdata2byte - syn
-- Description:    9 bit comma,data to Byte stream converter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-10-12   596   2.0    re-write, commas now 2 byte sequences
-- 2011-11-19   427   1.0.2  now numeric_std clean
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-30    62   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.comlib.all;

entity cdata2byte is                    -- 9bit comma,data -> byte stream
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ESCXON : in slbit;                  -- enable xon/xoff escaping
    ESCFILL : in slbit;                 -- enable fill escaping
    DI : in slv9;                       -- input data; bit 8 = comma flag
    ENA : in slbit;                     -- input data enable
    BUSY : out slbit;                   -- input data busy    
    DO : out slv8;                      -- output data
    VAL : out slbit;                    -- output data valid
    HOLD : in slbit                     -- output data hold
  );
end cdata2byte;


architecture syn of cdata2byte is

  type regs_type is record
    data : slv8;                        -- data
    ecode : slv3;                       -- ecode
    dataval : slbit;                    -- data valid
    ecodeval : slbit;                   -- ecode valid
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),                      -- data
    (others=>'0'),                      -- ecode
    '0','0'                             -- dataval,ecodeval
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

  proc_next: process (R_REGS, DI, ENA, HOLD, ESCXON, ESCFILL)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable idata  : slv8 := (others=>'0');
    variable iecode : slv3 := (others=>'0');
    variable iesc   : slbit := '0';
    variable ibusy  : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    -- data path logic
    iesc   := '0';
    iecode := '0' & DI(1 downto 0);
    if DI(8) = '1' then
      iesc   := '1';
    else
      case DI(7 downto 0) is
        when c_cdata_xon =>
          if ESCXON = '1' then
            iesc   := '1';
            iecode := c_cdata_ec_xon;
          end if;
        when c_cdata_xoff =>
          if ESCXON = '1' then
            iesc   := '1';
            iecode := c_cdata_ec_xoff;
          end if;
        when c_cdata_fill =>
          if ESCFILL = '1' then
            iesc   := '1';
            iecode := c_cdata_ec_fill;
          end if;
        when c_cdata_escape =>
          iesc   := '1';
          iecode := c_cdata_ec_esc;
        when others => null;
      end case;
    end if;

    if iesc = '0' then
      idata := DI(7 downto 0);
    else
      idata := c_cdata_escape;
    end if;

    -- control path logic
    ibusy := '1';
    if HOLD = '0' then
      n.dataval := '0';
      if r.ecodeval = '1' then
        n.data(c_cdata_edf_pref) := c_cdata_ed_pref;
        n.data(c_cdata_edf_eci)  := not r.ecode;
        n.data(c_cdata_edf_ec )  := r.ecode;
        n.dataval  := '1';
        n.ecodeval := '0';
      else
        ibusy := '0';
        if ENA = '1' then
          n.data     := idata;
          n.dataval  := '1';
          n.ecode    := iecode;
          n.ecodeval := iesc;
        end if;
      end if;
    end if;

    N_REGS <= n;

    DO   <= r.data;
    VAL  <= r.dataval;
    BUSY <= ibusy;
    
  end process proc_next;

end syn;
