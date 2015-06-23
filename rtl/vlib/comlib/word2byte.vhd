-- $Id: word2byte.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    word2byte - syn
-- Description:    1 word -> 2 byte stream converter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 12.1-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-21   432   1.0.1  now numeric_std clean
-- 2011-07-30   400   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity word2byte is                     -- 1 word -> 2 byte stream converter
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv16;                      -- input data (word)
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv8;                      -- output data (byte)
    VAL : out slbit;                    -- read valid
    HOLD : in slbit;                    -- read hold
    ODD : out slbit                     -- odd byte pending
  );
end word2byte;


architecture syn of word2byte is

  type state_type is (
    s_idle,
    s_valw,
    s_valh
  );

  type regs_type is record
    datl : slv8;                        -- lsb data
    dath : slv8;                        -- msb data
    state : state_type;                 -- state
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),
    (others=>'0'),
    s_idle
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

  proc_next: process (R_REGS, DI, ENA, HOLD)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable ival  : slbit := '0';
    variable ibusy : slbit := '0';
    variable iodd  : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    ival  := '0';
    ibusy := '0';
    iodd  := '0';
    
    case r.state is
      
      when s_idle =>
        if ENA = '1' then
          n.datl := DI( 7 downto 0);
          n.dath := DI(15 downto 8);
          n.state := s_valw;
        end if;

      when s_valw =>
        ibusy := '1';
        ival  := '1';
        if HOLD = '0' then
          n.datl := r.dath;
          n.state := s_valh;
        end if;

      when s_valh =>
        ival := '1';
        iodd := '1';
        if HOLD = '0' then
          if ENA = '1' then
            n.datl := DI( 7 downto 0);
            n.dath := DI(15 downto 8);
            n.state := s_valw;
          else
            n.state := s_idle;
          end if;
        else
          ibusy := '1';
        end if;

      when others => null;
    end case;

    N_REGS <= n;

    DO   <= r.datl;
    VAL  <= ival;
    BUSY <= ibusy;
    ODD  <= iodd;
    
  end process proc_next;


end syn;
