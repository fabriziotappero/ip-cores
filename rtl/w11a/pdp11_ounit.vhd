-- $Id: pdp11_ounit.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_ounit - syn
-- Description:    pdp11: arithmetic unit for addresses (ounit)
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.1.1  now numeric_std clean
-- 2010-09-18   300   1.1    renamed from abox
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_ounit is                   -- offset adder for addresses (ounit)
  port (
    DSRC : in slv16;                    -- 'src' data for port A
    DDST : in slv16;                    -- 'dst' data for port A
    DTMP : in slv16;                    -- 'tmp' data for port A
    PC : in slv16;                      -- PC data for port A
    ASEL : in slv2;                     -- selector for port A
    AZERO : in slbit;                   -- force zero for port A
    IREG8 : in slv8;                    -- 'ireg' data for port B
    VMDOUT : in slv16;                  -- virt. memory data for port B
    CONST : in slv9;                    -- sequencer const data for port B
    BSEL : in slv2;                     -- selector for port B
    OPSUB : in slbit;                   -- operation: 0 add, 1 sub
    DOUT : out slv16;                   -- data output
    NZOUT : out slv2                    -- NZ condition codes out
  );
end pdp11_ounit;

architecture syn of pdp11_ounit is

-- --------------------------------------

begin

  process (DSRC, DDST, DTMP, PC, ASEL, AZERO,
           IREG8, VMDOUT, CONST, BSEL, OPSUB)

    variable ma : slv16 := (others=>'0');  -- effective port a data
    variable mb : slv16 := (others=>'0');  -- effective port b data
    variable sum : slv16 := (others=>'0'); -- sum
    variable nzo : slbit := '0';
    
  begin

    if AZERO = '0' then
      case ASEL is
        when c_ounit_asel_dsrc => ma := DSRC;
        when c_ounit_asel_ddst => ma := DDST;
        when c_ounit_asel_dtmp => ma := DTMP;
        when c_ounit_asel_pc   => ma := PC;
        when others => null;
      end case;
    else
      ma := (others=>'0');
    end if;

    case BSEL is
      when c_ounit_bsel_ireg6  => mb := "000000000" & IREG8(5 downto 0) & "0"; 
      when c_ounit_bsel_ireg8  => mb := IREG8(7) & IREG8(7) & IREG8(7) &
                                       IREG8(7) & IREG8(7) & IREG8(7) &
                                       IREG8(7) & IREG8 & "0";   
      when c_ounit_bsel_vmdout => mb := VMDOUT;
      when c_ounit_bsel_const  => mb := "0000000" & CONST;
      when others => null;
    end case;

    if OPSUB = '0' then
      sum := slv(unsigned(ma) + unsigned(mb));
    else
      sum := slv(unsigned(ma) - unsigned(mb));
    end if;

    nzo := '0';
    if unsigned(sum) = 0 then
        nzo := '1';
    else
        nzo := '0';
    end if;
            
    DOUT <= sum;
    NZOUT(1) <= sum(15);
    NZOUT(0) <= nzo;
    
  end process;
  
end syn;
