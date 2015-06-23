-- $Id: pdp11_aunit.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    pdp11_aunit - syn
-- Description:    pdp11: arithmetic unit for data (aunit)
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-10   581   1.1.1  use c_cc_f_*
-- 2010-09-18   300   1.1    renamed from abox
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

-- arithmetic unit for data, usage:
--   ADD:  SRC +  DST + 0   (dst+src)
--   SUB: ~SRC +  DST + 1   (dst-src)
--   ADC:    0 +  DST + CI  (dst+ci)
--   SBC:   ~0 +  DST + ~CI (dst-ci)
--   CMP:  SRC + ~DST + 1   (src-dst)
--   COM:    0 + ~DST + 0   (~dst)
--   NEG:    0 + ~DST + 1   (-dst)
--   INC:    0 +  DST + 1   (dst+1)
--   DEC:   ~0 +  DST + 0   (dst-1)
--   CLR:    0 +    0 + 0   (0)
--   SOB:  SRC +   ~0 + 0   (src-1)

entity pdp11_aunit is                   -- arithmetic unit for data (aunit)
  port (
    DSRC : in slv16;                    -- 'src' data in
    DDST : in slv16;                    -- 'dst' data in
    CI : in slbit;                      -- carry flag in
    SRCMOD : in slv2;                   -- src modifier mode
    DSTMOD : in slv2;                   -- dst modifier mode
    CIMOD : in slv2;                    -- ci modifier mode
    CC1OP : in slbit;                   -- use cc modes (1 op instruction)
    CCMODE : in slv3;                   -- cc mode
    BYTOP : in slbit;                   -- byte operation
    DOUT : out slv16;                   -- data output
    CCOUT : out slv4                    -- condition codes out
  );
end pdp11_aunit;

architecture syn of pdp11_aunit is

-- --------------------------------------

begin

  process (DSRC, DDST, CI, CIMOD, CC1OP, CCMODE, SRCMOD, DSTMOD, BYTOP)

    variable msrc : slv16 := (others=>'0');  -- effective src data
    variable mdst : slv16 := (others=>'0');  -- effective dst data
    variable mci : slbit := '0';             -- effective ci
    variable sum : slv16 := (others=>'0');   -- sum
    variable co8 : slbit := '0';             -- co 8 bit
    variable co16 : slbit := '0';            -- co 16 bit

    variable nno : slbit := '0';             -- local no
    variable nzo : slbit := '0';             -- local zo
    variable nvo : slbit := '0';             -- local vo
    variable nco : slbit := '0';             -- local co

    variable src_msb : slbit := '0';    -- msb from src (bit 15 or 7)
    variable dst_msb : slbit := '0';    -- msb from dst (bit 15 or 7)
    variable sum_msb : slbit := '0';    -- msb from sum (bit 15 or 7)

    alias NO : slbit is CCOUT(c_cc_f_n);
    alias ZO : slbit is CCOUT(c_cc_f_z);
    alias VO : slbit is CCOUT(c_cc_f_v);
    alias CO : slbit is CCOUT(c_cc_f_c);
      
    -- procedure do_add8_ci_co: 8 bit adder with carry in and carry out
    --   implemented following the recommended pattern for XST ISE V8.1
    
    procedure do_add8_ci_co (
      variable a : in slv8;             -- input a
      variable b : in slv8;             -- input b
      variable ci : in slbit;           -- carry in
      variable sum : out slv8;          -- sum out
      variable co : out slbit           -- carry out
    ) is
      
      variable tmp: slv9;

    begin

      tmp := conv_std_logic_vector((conv_integer(a) + conv_integer(b) +
                                    conv_integer(ci)),9);
      sum := tmp(7 downto 0);
      co := tmp(8);
      
    end procedure do_add8_ci_co;    

  begin

    case SRCMOD is
      when c_aunit_mod_pass => msrc := DSRC;
      when c_aunit_mod_inv  => msrc := not DSRC;
      when c_aunit_mod_zero => msrc := (others=>'0');
      when c_aunit_mod_one  => msrc := (others=>'1');
      when others => null;
    end case;

    case DSTMOD is
      when c_aunit_mod_pass => mdst := DDST;
      when c_aunit_mod_inv  => mdst := not DDST;
      when c_aunit_mod_zero => mdst := (others=>'0');
      when c_aunit_mod_one  => mdst := (others=>'1');
      when others => null;
    end case;

    case CIMOD is
      when c_aunit_mod_pass => mci := CI;
      when c_aunit_mod_inv  => mci := not CI;
      when c_aunit_mod_zero => mci := '0';
      when c_aunit_mod_one  => mci := '1';
      when others => null;
    end case;

    do_add8_ci_co(msrc(7 downto 0), mdst(7 downto 0), mci,
                  sum(7 downto 0), co8);
    do_add8_ci_co(msrc(15 downto 8), mdst(15 downto 8), co8,
                  sum(15 downto 8), co16);

    DOUT <= sum;

-- V ('overflow) bit set if
--   ADD : both operants of same sign but has result opposite sign
--   SUB : both operants of opposide sign and sign source equals sign result
--   CMP : both operants of opposide sign and sign dest. equals sign result
    
    nno := '0';
    nzo := '0';
    nvo := '0';
    nco := '0';

    if BYTOP = '1' then
      nno := sum(7);
      if unsigned(sum(7 downto 0)) = 0 then
        nzo := '1';
      else
        nzo := '0';
      end if;
      nco := co8;

      src_msb := DSRC(7);
      dst_msb := DDST(7);
      sum_msb := sum(7);
      
    else        
      nno := sum(15);
      if unsigned(sum) = 0 then
        nzo := '1';
      else
        nzo := '0';
      end if;
      nco := co16;

      src_msb := DSRC(15);
      dst_msb := DDST(15);
      sum_msb := sum(15);
    end if;

    -- the logic for 2 operand V+C is ugly. It is reverse engineered from
    -- the MOD's the operation type.
    
    if CC1OP = '0' then                 -- 2 operand cases
      if unsigned(CIMOD) = unsigned(c_aunit_mod_zero) then   -- case ADD
        nvo := not(src_msb xor dst_msb) and (src_msb xor sum_msb);
      else
        if unsigned(SRCMOD) = unsigned(c_aunit_mod_inv) then -- case SUB 
          nvo := (src_msb xor dst_msb) and not (src_msb xor sum_msb);
        else                                                -- case CMP
          nvo := (src_msb xor dst_msb) and not (dst_msb xor sum_msb);
        end if;
        nco := not nco;                 -- invert C for SUB and CMP
      end if;
      
    else                                -- 1 operand cases
      case CCMODE is
        when c_aunit_ccmode_clr|c_aunit_ccmode_tst =>
          nvo := '0';                     -- force v=0 for tst and clr
          nco := '0';                     -- force c=0 for tst and clr
        
        when c_aunit_ccmode_com =>
          nvo := '0';                     -- force v=0 for com
          nco := '1';                     -- force c=1 for com
        
        when c_aunit_ccmode_inc =>
          nvo := sum_msb and not dst_msb;
          nco := CI;                      -- C not affected for INC

        when c_aunit_ccmode_dec =>
          nvo := not sum_msb and dst_msb;
          nco := CI;                      -- C not affected for DEC

        when c_aunit_ccmode_neg =>
          nvo := sum_msb and dst_msb;
          nco := not nzo;
        
        when c_aunit_ccmode_adc =>
          nvo := sum_msb and not dst_msb;

        when c_aunit_ccmode_sbc =>
          nvo := not sum_msb and dst_msb;
          nco := not nco;

        when others => null;
      end case;      
    end if;
      
    NO <= nno;
    ZO <= nzo;
    VO <= nvo;
    CO <= nco;
    
  end process;
  
end syn;
