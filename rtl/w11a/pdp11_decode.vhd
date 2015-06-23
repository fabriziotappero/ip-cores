-- $Id: pdp11_decode.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    pdp11_decode - syn
-- Description:    pdp11: instruction decoder
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.0.6  now numeric_std clean
-- 2010-09-18   300   1.0.5  rename (adlm)box->(oalm)unit
-- 2008-11-30   174   1.0.4  BUGFIX: add updt_dstadsrc; set for MFP(I/D)
-- 2008-05-03   143   1.0.3  get fork_srcr,fork_dstr,fork_dsta assign out of if
-- 2008-04-27   139   1.0.2  BUGFIX: mtp now via do_fork_op; is_dsta logic mods
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_decode is                  -- instruction decoder
  port (
    IREG : in slv16;                    -- input instruction word
    STAT : out decode_stat_type         -- status output
  );
end pdp11_decode;

architecture syn of pdp11_decode is

begin

  proc_idecode: process (IREG)

    alias OPCODE : slv4 is IREG(15 downto 12); -- basic opcode (upper 4 bits)
    alias OPPRIM : slv3 is IREG(14 downto 12); -- basic opcode without B bit
    alias OPBYTE : slbit is IREG(15);          -- byte flag of basic opcode
    alias OPEXT1 : slv3 is IREG(11 downto 9);  -- extended opcode, part 1
    alias OPEXT2 : slv3 is IREG(8 downto 6);   -- extended opcode, part 2
    alias OPEXT3 : slv3 is IREG(5 downto 3);   -- extended opcode, part 3
    alias OPEXT4 : slv3 is IREG(2 downto 0);   -- extended opcode, part 4

    alias SRCMODF : slv3 is IREG(11 downto 9); -- src register full mode
    alias DSTMODF : slv3 is IREG(5 downto 3);  -- dst register full mode

    alias SRCMOD : slv2 is IREG(11 downto 10); -- src register mode high
    alias SRCDEF : slbit is IREG(9);           -- src register mode defered
    alias SRCREG : slv3 is IREG(8 downto 6);   -- src register number
    alias DSTMOD : slv2 is IREG(5 downto 4);   -- dst register mode high
    alias DSTDEF : slbit is IREG(3);           -- dst register mode defered
    alias DSTREG : slv3 is IREG(2 downto 0);   -- dst register number

    variable nstat : decode_stat_type;
    
    variable is_srcr : slbit := '0';    -- source is read
    variable is_dstr : slbit := '0';    -- destination is read
    variable is_dstm : slbit := '0';    -- destination is modified
    variable is_dstw : slbit := '0';    -- destination is written

    variable is_srcmode0 : slbit := '0';       -- source is register mode
    variable is_dstmode0notpc : slbit := '0';  -- dest. is register mode, not PC

  begin

    is_srcr := '0';
    is_dstr := '0';
    is_dstm := '0';
    is_dstw := '0';

    is_srcmode0 := '0';
    is_dstmode0notpc := '0';

    nstat.is_dstmode0 := '0';
    nstat.is_srcpc := '0';
    nstat.is_srcpcmode1 := '0';
    nstat.is_dstpc := '0';
    nstat.is_dstw_reg := '0';
    nstat.is_dstw_pc := '0';
    nstat.is_rmwop := '0';
    nstat.is_bytop := '0';
    nstat.is_res := '1';
    nstat.op_rtt := '0';
    nstat.op_mov := '0';
    nstat.trap_vec := "000";
    nstat.force_srcsp := '0';
    nstat.updt_dstadsrc := '0';
    
    nstat.aunit_srcmod := c_aunit_mod_pass;
    nstat.aunit_dstmod := c_aunit_mod_pass;
    nstat.aunit_cimod := c_aunit_mod_pass;
    nstat.aunit_cc1op := '0';
    nstat.aunit_ccmode := IREG(8 downto 6);   -- STATIC
    nstat.lunit_func := (others=>'0');
    nstat.munit_func := (others=>'0');
    nstat.res_sel := c_dpath_res_ounit;
    
    nstat.fork_op := (others=>'0');
    nstat.fork_srcr := (others=>'0');
    nstat.fork_dstr := (others=>'0');
    nstat.fork_dsta := (others=>'0');
    nstat.fork_opg := (others=>'0');
    nstat.fork_opa := (others=>'0');

    nstat.do_fork_op := '0';
    nstat.do_fork_srcr := '0';
    nstat.do_fork_dstr := '0';
    nstat.do_fork_dsta := '0';
    nstat.do_fork_opg := '0';
    
    nstat.do_pref_dec := '0';

    if SRCMODF = "000" then
      is_srcmode0 := '1';
    end if;

    if DSTMODF = "000" then
      nstat.is_dstmode0 := '1';
      if DSTREG /= c_gpr_pc then
        is_dstmode0notpc := '1';
      end if;
    end if;

    if SRCREG = c_gpr_pc then
      nstat.is_srcpc := '1';
      if SRCMODF = "001" then
        nstat.is_srcpcmode1 := '1';
      end if;
    end if;
    
    if DSTREG = c_gpr_pc then
      nstat.is_dstpc := '1';
    end if;

    if OPPRIM = "000" then

      if OPBYTE='0' and OPEXT1="000" then
        
        if OPEXT2="000" and OPEXT3="000" then -- HALT,...,RTT
          nstat.is_res := '0';
          case OPEXT4 is
            
            when "000" =>               -- HALT
              nstat.fork_op := c_fork_op_halt;
              nstat.do_fork_op := '1';
              
            when "001" =>               -- WAIT 
              nstat.fork_op := c_fork_op_wait;
              nstat.do_fork_op := '1';
              
            when "010" =>               -- RTI
              nstat.force_srcsp := '1';
              nstat.fork_op := c_fork_op_rtti;
              nstat.do_fork_op := '1';
                                
            when "011" =>               -- BPT (trap to 14)
              nstat.trap_vec := "011";
              nstat.fork_op := c_fork_op_trap;
              nstat.do_fork_op := '1';
              
            when "100" =>               -- IOT (trap to 20)
              nstat.trap_vec := "100";
              nstat.fork_op := c_fork_op_trap;
              nstat.do_fork_op := '1';
              
            when "101" =>               -- RESET
              nstat.fork_op := c_fork_op_reset;
              nstat.do_fork_op := '1';

            when "110" =>               -- RTT
              nstat.op_rtt := '1';
              nstat.force_srcsp := '1';
              nstat.fork_op := c_fork_op_rtti;
              nstat.do_fork_op := '1';
                                
            when others =>
              nstat.is_res := '1';
                           
          end case;
        end if;

        if OPEXT2 = "001" then          -- JMP 
          nstat.is_res := '0';
          nstat.fork_opa := c_fork_opa_jmp;
          nstat.do_fork_dsta := '1';
        end if;

        if OPEXT2 = "010" then
          if OPEXT3 = "000" then        -- RTS
            nstat.is_res := '0';
            nstat.force_srcsp := '1';
            nstat.fork_op := c_fork_op_rts;
            nstat.do_fork_op := '1';
          end if;
          if OPEXT3 = "011" then        -- SPL
            nstat.is_res := '0';
            nstat.fork_op := c_fork_op_spl;
            nstat.do_fork_op := '1';
          end if;
        end if;
        
        if OPEXT2 = "010" then
          if OPEXT3(2) = '1' then       -- SEx/CLx
            nstat.is_res := '0';
            nstat.fork_op := c_fork_op_mcc;
            nstat.do_fork_op := '1';
            --!!!nstat.do_pref_dec := '1'; --??? ensure ireg_we ....
          end if;
        end if;

        if OPEXT2 = "011" then          -- SWAP 
          nstat.is_res := '0';
          is_dstm := '1';
          nstat.fork_opg := c_fork_opg_gen;
          nstat.do_fork_opg := '1';
          nstat.do_pref_dec := is_dstmode0notpc;
          nstat.lunit_func := c_lunit_func_swap;
          nstat.res_sel := c_dpath_res_lunit;
        end if;
        
      end if; -- OPBYTE='0' and OPEXT1="000"
      
      if OPEXT1(2)='0' and              -- BR class instructions
         ((OPBYTE='0' and OPEXT2(2)='1') or    -- BR
          (OPBYTE='0' and (OPEXT1(0)='1' or OPEXT1(1)='1')) or  -- BNE,..,BLE
         OPBYTE='1')  then                                       -- BPL,..,BCS
        nstat.is_res := '0';
        nstat.fork_op := c_fork_op_br;
        nstat.do_fork_op := '1';
      end if;

      if OPBYTE='0' and OPEXT1="100" then -- JSR
        nstat.is_res := '0';
        nstat.fork_opa := c_fork_opa_jsr;
        nstat.do_fork_dsta := '1';
      end if;
        
      if OPBYTE='1' and OPEXT1="100" then -- EMT, TRAP
        nstat.is_res := '0';
        if OPEXT2(2) = '0' then         -- EMT (trap tp 30)
          nstat.trap_vec := "110";
        else                            -- TRAP (trap to 34)
          nstat.trap_vec := "111";
        end if;
        nstat.fork_op := c_fork_op_trap;
        nstat.do_fork_op := '1';
      end if;
      
      if OPEXT1 = "101" then            -- CLR(B),...,TST(B)
        nstat.is_res := '0';
        nstat.res_sel := c_dpath_res_aunit;
        if OPBYTE = '1' then
          nstat.is_bytop := '1';
        end if;

        nstat.aunit_cc1op := '1';
        
        case OPEXT2 is
          when "000" =>                 -- CLR:    0 +    0 + 0   (0)
            is_dstw := '1';
            nstat.aunit_srcmod := c_aunit_mod_zero;
            nstat.aunit_dstmod := c_aunit_mod_zero;
            nstat.aunit_cimod  := c_aunit_mod_zero;
          when "001" =>                 -- COM:    0 + ~DST + 0   (~dst)
            is_dstm := '1';
            nstat.aunit_srcmod := c_aunit_mod_zero;
            nstat.aunit_dstmod := c_aunit_mod_inv;
            nstat.aunit_cimod  := c_aunit_mod_zero;
          when "010" =>                 -- INC:    0 +  DST + 1   (dst+1)
            is_dstm := '1';
            nstat.aunit_srcmod := c_aunit_mod_zero;
            nstat.aunit_dstmod := c_aunit_mod_pass;
            nstat.aunit_cimod  := c_aunit_mod_one;
          when "011" =>                 -- DEC:   ~0 +  DST + 0   (dst-1)
            is_dstm := '1';
            nstat.aunit_srcmod := c_aunit_mod_one;
            nstat.aunit_dstmod := c_aunit_mod_pass;
            nstat.aunit_cimod  := c_aunit_mod_zero;
          when "100" =>                 -- NEG:    0 + ~DST + 1   (-dst)
            is_dstm := '1';
            nstat.aunit_srcmod := c_aunit_mod_zero;
            nstat.aunit_dstmod := c_aunit_mod_inv;
            nstat.aunit_cimod  := c_aunit_mod_one;
          when "101" =>                 -- ADC:    0 +  DST + CI  (dst+ci)
            is_dstm := '1';
            nstat.aunit_srcmod := c_aunit_mod_zero;
            nstat.aunit_dstmod := c_aunit_mod_pass;
            nstat.aunit_cimod  := c_aunit_mod_pass;
          when "110" =>                 -- SBC:   ~0 +  DST + ~CI (dst-ci)
            is_dstm := '1';
            nstat.aunit_srcmod := c_aunit_mod_one;
            nstat.aunit_dstmod := c_aunit_mod_pass;
            nstat.aunit_cimod  := c_aunit_mod_inv;
          when "111" =>                 -- TST:    0 +  DST + 0   (dst)
            is_dstr := '1';
            nstat.aunit_srcmod := c_aunit_mod_zero;
            nstat.aunit_dstmod := c_aunit_mod_pass;
            nstat.aunit_cimod  := c_aunit_mod_zero;
          when others => null;
        end case;

        nstat.fork_opg := c_fork_opg_gen;
        nstat.do_fork_opg := '1';
        nstat.do_pref_dec := is_dstmode0notpc;

      end if;
      
      if OPEXT1 = "110" then
        if OPEXT2(2) = '0' then         -- ROR(B),...,ASL(B)
          nstat.is_res := '0';
          is_dstm := '1';
          nstat.fork_opg := c_fork_opg_gen;
          nstat.do_fork_opg := '1';
          nstat.do_pref_dec := is_dstmode0notpc;
          if OPBYTE = '1' then
            nstat.is_bytop := '1';
          end if;
          nstat.res_sel := c_dpath_res_lunit;
          case OPEXT2(1 downto 0) is
            when "00" =>                -- ROR
              nstat.lunit_func := c_lunit_func_ror;
            when "01" =>                -- ROL
              nstat.lunit_func := c_lunit_func_rol;
            when "10" =>                -- ASR
              nstat.lunit_func := c_lunit_func_asr;
            when "11" =>                -- ASL
              nstat.lunit_func := c_lunit_func_asl;
            when others => null;
          end case;
        end if;
        
        if OPBYTE='0' and OPEXT2="100" then -- MARK
          nstat.is_res := '0';
          nstat.fork_op := c_fork_op_mark;
          nstat.do_fork_op := '1';
        end if;

        if OPEXT2 = "101" then          -- MFP(I/D)
          nstat.is_res := '0';
          nstat.force_srcsp := '1';
          if DSTREG = c_gpr_sp then       -- is dst reg == sp ?
            nstat.updt_dstadsrc := '1';     -- ensure DSRC update in dsta flow
          end if;
          nstat.res_sel := c_dpath_res_ounit;
          if nstat.is_dstmode0 = '1' then
            nstat.fork_opa := c_fork_opa_mfp_reg;
          else
            nstat.fork_opa := c_fork_opa_mfp_mem;
          end if;
          nstat.do_fork_dsta := '1';
        end if;

        if OPEXT2 = "110" then          -- MTP(I/D)
          nstat.is_res := '0';
          nstat.force_srcsp := '1';
          nstat.res_sel := c_dpath_res_ounit;
          nstat.fork_opa := c_fork_opa_mtp;
          nstat.fork_op  := c_fork_op_mtp;
          nstat.do_fork_op := '1';
        end if;

        if OPBYTE='0' and OPEXT2="111" then -- SXT
          nstat.is_res := '0';
          is_dstw := '1';
          nstat.fork_opg := c_fork_opg_gen;
          nstat.do_fork_opg := '1';
          nstat.do_pref_dec := is_dstmode0notpc;
          nstat.lunit_func := c_lunit_func_sxt;
          nstat.res_sel := c_dpath_res_lunit;
        end if;
      end if;

    end if; -- OPPRIM="000"

    if OPPRIM/="000" and OPPRIM/="111" then
      nstat.is_res := '0';
      case OPPRIM is
        when "001" =>                   -- MOV
          is_srcr := '1';
          is_dstw := '1';
          nstat.op_mov := '1';
          nstat.lunit_func := c_lunit_func_mov;
          nstat.res_sel  := c_dpath_res_lunit;
          nstat.is_bytop := OPBYTE;
        when "010" =>                   -- CMP
          is_srcr := '1';
          is_dstr := '1';
          nstat.res_sel  := c_dpath_res_aunit;
          nstat.aunit_srcmod := c_aunit_mod_pass;
          nstat.aunit_dstmod := c_aunit_mod_inv;
          nstat.aunit_cimod  := c_aunit_mod_one;
          nstat.is_bytop := OPBYTE;
        when "011" =>                   -- BIT
          is_srcr := '1';
          is_dstr := '1';
          nstat.lunit_func := c_lunit_func_bit;
          nstat.res_sel  := c_dpath_res_lunit;
          nstat.is_bytop := OPBYTE;
        when "100" =>                   -- BIC
          is_srcr := '1';
          is_dstm := '1';
          nstat.lunit_func := c_lunit_func_bic;
          nstat.res_sel  := c_dpath_res_lunit;
          nstat.is_bytop := OPBYTE;
        when "101" =>                   -- BIS
          is_srcr := '1';
          is_dstm := '1';
          nstat.lunit_func := c_lunit_func_bis;
          nstat.res_sel  := c_dpath_res_lunit;
          nstat.is_bytop := OPBYTE;
        when "110" =>
          is_srcr := '1';
          is_dstm := '1';
          nstat.res_sel    := c_dpath_res_aunit;
          if OPBYTE = '0' then          -- ADD
            nstat.aunit_srcmod := c_aunit_mod_pass;
            nstat.aunit_dstmod := c_aunit_mod_pass;
            nstat.aunit_cimod  := c_aunit_mod_zero;
          else                          -- SUB
            nstat.aunit_srcmod := c_aunit_mod_inv;
            nstat.aunit_dstmod := c_aunit_mod_pass;
            nstat.aunit_cimod  := c_aunit_mod_one;
          end if;
        when others => null;
      end case;

      nstat.fork_opg := c_fork_opg_gen;
      nstat.do_fork_opg := '1';
      nstat.do_pref_dec := is_srcmode0 and is_dstmode0notpc;

    end if;

    if OPBYTE='0' and OPPRIM="111" then
      case OPEXT1 is
        when "000" =>                   -- MUL
          nstat.is_res := '0';
          is_dstr := '1';
          nstat.munit_func := c_munit_func_mul;
          nstat.res_sel := c_dpath_res_munit;
          nstat.fork_opg := c_fork_opg_mul;
          nstat.do_fork_opg := '1';
        when "001" =>                   -- DIV
          nstat.is_res := '0';          
          is_dstr := '1';
          nstat.munit_func := c_munit_func_div;
          nstat.res_sel := c_dpath_res_munit;
          nstat.fork_opg := c_fork_opg_div;
          nstat.do_fork_opg := '1';
        when "010" =>                   -- ASH
          nstat.is_res := '0';
          is_dstr := '1';
          nstat.munit_func := c_munit_func_ash;
          nstat.res_sel := c_dpath_res_munit;
          nstat.fork_opg := c_fork_opg_ash;
          nstat.do_fork_opg := '1';
        when "011" =>                   -- ASHC
          nstat.is_res := '0';
          is_dstr := '1';
          nstat.munit_func := c_munit_func_ashc;
          nstat.res_sel := c_dpath_res_munit;
          nstat.fork_opg := c_fork_opg_ashc;
          nstat.do_fork_opg := '1';
        when "100" =>                   -- XOR
          nstat.is_res := '0';
          is_dstm := '1';
          nstat.lunit_func := c_lunit_func_xor;
          nstat.res_sel := c_dpath_res_lunit;
          nstat.fork_opg := c_fork_opg_gen;
          nstat.do_fork_opg := '1';
          nstat.do_pref_dec := is_dstmode0notpc;
        when "111" =>                   -- SOB:  SRC +   ~0 + 0   (src-1)
          nstat.is_res := '0';
          nstat.aunit_srcmod := c_aunit_mod_pass;
          nstat.aunit_dstmod := c_aunit_mod_one;
          nstat.aunit_cimod  := c_aunit_mod_zero;
          nstat.res_sel := c_dpath_res_aunit;
          nstat.fork_op := c_fork_op_sob;
          nstat.do_fork_op := '1';
        when others => null;
      end case;      
      
    end if;  

    if OPBYTE='1' and OPPRIM="111" then -- FPU
      nstat.is_res := '1';                    -- ??? FPU not yet handled
    end if; 

    case SRCMOD is
      when "00" => nstat.fork_srcr := c_fork_srcr_def;
      when "01" => nstat.fork_srcr := c_fork_srcr_inc;
      when "10" => nstat.fork_srcr := c_fork_srcr_dec;
      when "11" => nstat.fork_srcr := c_fork_srcr_ind;
      when others => null;
    end case;

    if is_srcr='1' and SRCMODF /="000" then
      nstat.do_fork_srcr := '1';
    end if;

    case DSTMOD is
      when "00" => nstat.fork_dstr := c_fork_dstr_def;
      when "01" => nstat.fork_dstr := c_fork_dstr_inc;
      when "10" => nstat.fork_dstr := c_fork_dstr_dec;
      when "11" => nstat.fork_dstr := c_fork_dstr_ind;
      when others => null;
    end case;

    if (is_dstr or is_dstm)='1' and nstat.is_dstmode0='0' then
      nstat.do_fork_dstr := '1';
    end if;

    if is_dstw='1' and nstat.is_dstmode0='0' then
      case DSTMOD is
        when "00" => nstat.fork_opg := c_fork_opg_wdef;
        when "01" => nstat.fork_opg := c_fork_opg_winc;
        when "10" => nstat.fork_opg := c_fork_opg_wdec;
        when "11" => nstat.fork_opg := c_fork_opg_wind;
        when others => null;
      end case;
    end if;

    if is_dstm='1' and nstat.is_dstmode0='0' then
      nstat.is_rmwop := '1';
    end if;
      
    case DSTMOD is
      when "00" => nstat.fork_dsta := c_fork_dsta_def;
      when "01" => nstat.fork_dsta := c_fork_dsta_inc;
      when "10" => nstat.fork_dsta := c_fork_dsta_dec;
      when "11" => nstat.fork_dsta := c_fork_dsta_ind;
      when others => null;
    end case;

    if (is_dstw or is_dstm)='1' and nstat.is_dstmode0='1' then
      nstat.is_dstw_reg := '1';
      if DSTREG = c_gpr_pc then
        nstat.is_dstw_pc := '1';        --??? hack rename -> is_dstw_pc
      end if;
    end if;
      
    STAT <= nstat;

  end process proc_idecode;
    
end syn;
