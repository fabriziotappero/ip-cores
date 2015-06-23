------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------   
-- package:     opcodes
-- File:        opcodes.vhd
-- Author:      Jiri Gaisler
-- Description: Instruction definitions according to the SPARC V8 manual.
------------------------------------------------------------------------------  

library ieee;
use ieee.std_logic_1164.all;

package sparc is

-- op decoding (inst(31 downto 30))

subtype op_type is std_logic_vector(1 downto 0);

constant FMT2     : op_type := "00";
constant CALL     : op_type := "01";
constant FMT3     : op_type := "10";
constant LDST     : op_type := "11";

-- op2 decoding (inst(24 downto 22))

subtype op2_type is std_logic_vector(2 downto 0);

constant UNIMP    : op2_type := "000";
constant BICC     : op2_type := "010";
constant SETHI    : op2_type := "100";
constant FBFCC    : op2_type := "110";
constant CBCCC    : op2_type := "111";

-- op3 decoding (inst(24 downto 19))

subtype op3_type is std_logic_vector(5 downto 0);

constant IADD     : op3_type := "000000";
constant IAND     : op3_type := "000001";
constant IOR      : op3_type := "000010";
constant IXOR     : op3_type := "000011";
constant ISUB     : op3_type := "000100";
constant ANDN     : op3_type := "000101";
constant ORN      : op3_type := "000110";
constant IXNOR    : op3_type := "000111";
constant ADDX     : op3_type := "001000";
constant UMUL     : op3_type := "001010";
constant SMUL     : op3_type := "001011";
constant SUBX     : op3_type := "001100";
constant UDIV     : op3_type := "001110";
constant SDIV     : op3_type := "001111";
constant ADDCC    : op3_type := "010000";
constant ANDCC    : op3_type := "010001";
constant ORCC     : op3_type := "010010";
constant XORCC    : op3_type := "010011";
constant SUBCC    : op3_type := "010100";
constant ANDNCC   : op3_type := "010101";
constant ORNCC    : op3_type := "010110";
constant XNORCC   : op3_type := "010111";
constant ADDXCC   : op3_type := "011000";
constant UMULCC   : op3_type := "011010";
constant SMULCC   : op3_type := "011011";
constant SUBXCC   : op3_type := "011100";
constant UDIVCC   : op3_type := "011110";
constant SDIVCC   : op3_type := "011111";
constant TADDCC   : op3_type := "100000";
constant TSUBCC   : op3_type := "100001";
constant TADDCCTV : op3_type := "100010";
constant TSUBCCTV : op3_type := "100011";
constant MULSCC   : op3_type := "100100";
constant ISLL     : op3_type := "100101";
constant ISRL     : op3_type := "100110";
constant ISRA     : op3_type := "100111";
constant RDY      : op3_type := "101000";
constant RDPSR    : op3_type := "101001";
constant RDWIM    : op3_type := "101010";
constant RDTBR    : op3_type := "101011";
constant WRY      : op3_type := "110000";
constant WRPSR    : op3_type := "110001";
constant WRWIM    : op3_type := "110010";
constant WRTBR    : op3_type := "110011";
constant FPOP1    : op3_type := "110100";
constant FPOP2    : op3_type := "110101";
constant CPOP1    : op3_type := "110110";
constant CPOP2    : op3_type := "110111";
constant JMPL     : op3_type := "111000";
constant TICC     : op3_type := "111010";
constant FLUSH    : op3_type := "111011";
constant RETT     : op3_type := "111001";
constant SAVE     : op3_type := "111100";
constant RESTORE  : op3_type := "111101";
constant UMAC     : op3_type := "111110";
constant SMAC     : op3_type := "111111";

constant LD       : op3_type := "000000";
constant LDUB     : op3_type := "000001";
constant LDUH     : op3_type := "000010";
constant LDD      : op3_type := "000011";
constant LDSB     : op3_type := "001001";
constant LDSH     : op3_type := "001010";
constant LDSTUB   : op3_type := "001101";
constant SWAP     : op3_type := "001111";
constant LDA      : op3_type := "010000";
constant LDUBA    : op3_type := "010001";
constant LDUHA    : op3_type := "010010";
constant LDDA     : op3_type := "010011";
constant LDSBA    : op3_type := "011001";
constant LDSHA    : op3_type := "011010";
constant LDSTUBA  : op3_type := "011101";
constant SWAPA    : op3_type := "011111";
constant LDF      : op3_type := "100000";
constant LDFSR    : op3_type := "100001";
constant LDDF     : op3_type := "100011";
constant LDC      : op3_type := "110000";
constant LDCSR    : op3_type := "110001";
constant LDDC     : op3_type := "110011";
constant ST       : op3_type := "000100";
constant STB      : op3_type := "000101";
constant STH      : op3_type := "000110";
constant ISTD     : op3_type := "000111";
constant STA      : op3_type := "010100";
constant STBA     : op3_type := "010101";
constant STHA     : op3_type := "010110";
constant STDA     : op3_type := "010111";
constant STF      : op3_type := "100100";
constant STFSR    : op3_type := "100101";
constant STDFQ    : op3_type := "100110";
constant STDF     : op3_type := "100111";
constant STC      : op3_type := "110100";
constant STCSR    : op3_type := "110101";
constant STDCQ    : op3_type := "110110";
constant STDC     : op3_type := "110111";

-- bicc decoding (inst(27 downto 25))

constant BA  : std_logic_vector(3 downto 0) := "1000";

-- fpop1 decoding

subtype fpop_type is std_logic_vector(8 downto 0);

constant FITOS    : fpop_type := "011000100";
constant FITOD    : fpop_type := "011001000";
constant FSTOI    : fpop_type := "011010001";
constant FDTOI    : fpop_type := "011010010";
constant FSTOD    : fpop_type := "011001001";
constant FDTOS    : fpop_type := "011000110";
constant FMOVS    : fpop_type := "000000001";
constant FNEGS    : fpop_type := "000000101";
constant FABSS    : fpop_type := "000001001";
constant FSQRTS   : fpop_type := "000101001";
constant FSQRTD   : fpop_type := "000101010";
constant FADDS    : fpop_type := "001000001";
constant FADDD    : fpop_type := "001000010";
constant FSUBS    : fpop_type := "001000101";
constant FSUBD    : fpop_type := "001000110";
constant FMULS    : fpop_type := "001001001";
constant FMULD    : fpop_type := "001001010";
constant FSMULD   : fpop_type := "001101001";
constant FDIVS    : fpop_type := "001001101";
constant FDIVD    : fpop_type := "001001110";

-- fpop2 decoding

constant FCMPS    : fpop_type := "001010001";
constant FCMPD    : fpop_type := "001010010";
constant FCMPES   : fpop_type := "001010101";
constant FCMPED   : fpop_type := "001010110";

-- trap type decoding

subtype trap_type is std_logic_vector(5 downto 0);

constant TT_IAEX   : trap_type := "000001";
constant TT_IINST  : trap_type := "000010";
constant TT_PRIV   : trap_type := "000011";
constant TT_FPDIS  : trap_type := "000100";
constant TT_WINOF  : trap_type := "000101";
constant TT_WINUF  : trap_type := "000110";
constant TT_UNALA  : trap_type := "000111";
constant TT_FPEXC  : trap_type := "001000";
constant TT_DAEX   : trap_type := "001001";
constant TT_TAG    : trap_type := "001010";
constant TT_WATCH  : trap_type := "001011";

constant TT_DSU    : trap_type := "010000";
constant TT_PWD    : trap_type := "010001";

constant TT_RFERR  : trap_type := "100000";
constant TT_IAERR  : trap_type := "100001";
constant TT_CPDIS  : trap_type := "100100";
constant TT_CPEXC  : trap_type := "101000";
constant TT_DIV    : trap_type := "101010";
constant TT_DSEX   : trap_type := "101011";
constant TT_TICC   : trap_type := "111111";

-- Alternate address space identifiers (only 5 lsb bist are used)

subtype asi_type is std_logic_vector(4 downto 0);

constant ASI_SYSR    : asi_type := "00010"; -- 0x02
constant ASI_UINST   : asi_type := "01000"; -- 0x08
constant ASI_SINST   : asi_type := "01001"; -- 0x09
constant ASI_UDATA   : asi_type := "01010"; -- 0x0A
constant ASI_SDATA   : asi_type := "01011"; -- 0x0B
constant ASI_ITAG    : asi_type := "01100"; -- 0x0C
constant ASI_IDATA   : asi_type := "01101"; -- 0x0D
constant ASI_DTAG    : asi_type := "01110"; -- 0x0E
constant ASI_DDATA   : asi_type := "01111"; -- 0x0F
constant ASI_IFLUSH  : asi_type := "10000"; -- 0x10
constant ASI_DFLUSH  : asi_type := "10001"; -- 0x11

constant ASI_FLUSH_PAGE     : std_logic_vector(4 downto 0) := "10000";  -- 0x10 i/dcache flush page
constant ASI_FLUSH_CTX      : std_logic_vector(4 downto 0) := "10011";  -- 0x13 i/dcache flush ctx

constant ASI_DCTX           : std_logic_vector(4 downto 0) := "10100";  -- 0x14 dcache ctx
constant ASI_ICTX           : std_logic_vector(4 downto 0) := "10101";  -- 0x15 icache ctx

constant ASI_MMUFLUSHPROBE  : std_logic_vector(4 downto 0) := "11000";  -- 0x18 i/dtlb flush/(probe)
constant ASI_MMUREGS        : std_logic_vector(4 downto 0) := "11001";  -- 0x19 mmu regs access
constant ASI_MMU_BP         : std_logic_vector(4 downto 0) := "11100";  -- 0x1c mmu Bypass 
constant ASI_MMU_DIAG       : std_logic_vector(4 downto 0) := "11101";  -- 0x1d mmu diagnostic 
--constant ASI_MMU_DSU        : std_logic_vector(4 downto 0) := "11111";  -- 0x1f mmu diagnostic 

constant ASI_MMUSNOOP_DTAG  : std_logic_vector(4 downto 0) := "11110";  -- 0x1e mmusnoop physical dtag 

-- ftt decoding

subtype ftt_type is std_logic_vector(2 downto 0);

constant FPIEEE_ERR  : ftt_type := "001";
constant FPSEQ_ERR   : ftt_type := "100";
constant FPHW_ERR    : ftt_type := "101";

end;



