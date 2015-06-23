-- $Id: pdp11_lunit.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2006-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_lunit - syn
-- Description:    pdp11: logic unit for data (lunit)
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-10   581   1.1.2  use c_cc_f_*
-- 2011-11-18   427   1.1.1  now numeric_std clean
-- 2010-09-18   300   1.1    renamed from lbox
-- 2008-03-30   131   1.0.2  BUGFIX: SXT clears V condition code
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_lunit is                   -- logic unit for data (lunit)
  port (
    DSRC : in slv16;                    -- 'src' data in
    DDST : in slv16;                    -- 'dst' data in
    CCIN : in slv4;                     -- condition codes in
    FUNC : in slv4;                     -- function
    BYTOP : in slbit;                   -- byte operation
    DOUT : out slv16;                   -- data output
    CCOUT : out slv4                    -- condition codes out
  );
end pdp11_lunit;

architecture syn of pdp11_lunit is

-- --------------------------------------

begin

  process (DSRC, DDST, CCIN, FUNC, BYTOP)
    variable iout : slv16 := (others=>'0');
    variable inzstd : slbit := '0';
    variable ino : slbit := '0';
    variable izo : slbit := '0';
    variable ivo : slbit := '0';
    variable ico : slbit := '0';

    alias DSRC_L : slv8 is DSRC(7 downto 0);
    alias DSRC_H : slv8 is DSRC(15 downto 8);
    alias DDST_L : slv8 is DDST(7 downto 0);
    alias DDST_H : slv8 is DDST(15 downto 8);
    alias NI : slbit is CCIN(c_cc_f_n);
    alias ZI : slbit is CCIN(c_cc_f_z);
    alias VI : slbit is CCIN(c_cc_f_v);
    alias CI : slbit is CCIN(c_cc_f_c);
    alias iout_l : slv8 is iout(7 downto 0);
    alias iout_h : slv8 is iout(15 downto 8);

  begin

    iout := (others=>'0');
    inzstd := '1';                      -- use standard logic by default
    ino := '0';
    izo := '0';
    ivo := '0';
    ico := '0';

--
-- the decoding of FUNC is done "manually" to get a structure based on
-- a 8->1 pattern. This matches the opcode structure and seems most
-- efficient.
--
    
    if FUNC(3) = '0' then
      if BYTOP = '0' then

        case FUNC(2 downto 0) is
          when "000" =>                 -- ASR
            iout := DDST(15) & DDST(15 downto 1);
            ico := DDST(0);
            ivo := iout(15) xor ico;

          when "001"  =>                -- ASL
            iout := DDST(14 downto 0) & '0';
            ico := DDST(15);
            ivo := iout(15) xor ico;

          when "010" =>                 -- ROR
            iout := CI & DDST(15 downto 1);
            ico := DDST(0);
            ivo := iout(15) xor ico;

          when "011"  =>                -- ROL
            iout := DDST(14 downto 0) & CI;
            ico := DDST(15);
            ivo := iout(15) xor ico;

          when "100" =>                 -- BIS
            iout := DDST or DSRC;
            ico := CI;

          when "101" =>                 -- BIC
            iout := DDST and not DSRC;
            ico := CI;

          when "110" =>                 -- BIT
            iout := DDST and DSRC;
            ico := CI;

          when "111" =>                 -- MOV
            iout := DSRC;
            ico := CI;
          when others => null;
        end case;

      else

        case FUNC(2 downto 0) is
          when "000" =>                 -- ASRB
            iout_l := DDST_L(7) & DDST_L(7 downto 1);
            ico := DDST_L(0);
            ivo := iout_l(7) xor ico;

          when "001"  =>                -- ASLB
            iout_l := DDST(6 downto 0) & '0';
            ico := DDST(7);
            ivo := iout_l(7) xor ico;

          when "010" =>                 -- RORB
            iout_l := CI & DDST_L(7 downto 1);
            ico := DDST_L(0);
            ivo := iout_l(7) xor ico;

          when "011"  =>                -- ROLB
            iout_l := DDST_L(6 downto 0) & CI;
            ico := DDST_L(7);
            ivo := iout_l(7) xor ico;

          when "100" =>                 -- BISB
            iout_l := DDST_L or DSRC_L;
            ico := CI;

          when "101" =>                 -- BICB
            iout_l := DDST_L and not DSRC_L;
            ico := CI;

          when "110" =>                 -- BITB
            iout_l := DDST_L and DSRC_L;
            ico := CI;

          when "111" =>                 -- MOVB
            iout_l := DSRC_L;
            iout_h := (others=>DSRC_L(7));
            ico := CI;
          when others => null;
        end case;
      end if;

    else
      case FUNC(2 downto 0) is
        when "000" =>                   -- SXT
          iout := (others=>NI);
          inzstd := '0';
          ino := NI;
          izo := not NI;
          ivo := '0';
          ico := CI;
          
        when "001" =>                   -- SWAP
          iout := DDST_L & DDST_H;
          inzstd := '0';
          ino := iout(7);
          if unsigned(iout(7 downto 0)) = 0 then
            izo := '1';
          else
            izo := '0';
          end if;

        when "010" =>                   -- XOR
          iout := DDST xor DSRC;
          ico := CI;

        when others => null;

      end case;
    end if;
    
    DOUT <= iout;

    if inzstd = '1' then
      if BYTOP = '1' then
        ino := iout(7);
        if unsigned(iout(7 downto 0)) = 0 then
          izo := '1';
        else
          izo := '0';
        end if;
      else
        ino := iout(15);
        if unsigned(iout) = 0 then
          izo := '1';
        else
          izo := '0';
        end if;        
      end if;
    end if;

    CCOUT(3) <= ino;
    CCOUT(2) <= izo;
    CCOUT(1) <= ivo;
    CCOUT(0) <= ico;
    
  end process;
  
end syn;
