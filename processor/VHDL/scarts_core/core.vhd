-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

entity scarts_core is
  generic (
    CONF : scarts_conf_type);
  port (
    clk   : in  std_ulogic;
    sysrst : in  std_ulogic;
    hold  : in  std_ulogic;

    iramo_rdata       : in INSTR;
    irami_wdata       : out INSTR;
    irami_waddr       : out std_logic_vector(CONF.instr_ram_size-1 downto 0);
    irami_wen         : out std_ulogic;
    irami_raddr       : out std_logic_vector(CONF.instr_ram_size-1 downto 0);

    regfi_wdata       : out std_logic_vector(CONF.word_size-1 downto 0);
    regfi_waddr       : out std_logic_vector(REGADDR_W-1 downto 0);
    regfi_wen         : out std_ulogic;
    regfi_raddr1      : out std_logic_vector(REGADDR_W-1 downto 0);
    regfi_raddr2      : out std_logic_vector(REGADDR_W-1 downto 0);
    regfo_rdata1      : in  std_logic_vector(CONF.word_size-1 downto 0);
    regfo_rdata2      : in  std_logic_vector(CONF.word_size-1 downto 0);

    corei_interruptin : in  std_logic_vector(15 downto 0);
    corei_extdata     : in  std_logic_vector(CONF.word_size-1 downto 0);
    coreo_extwr       : out std_ulogic;
    coreo_signedac    : out std_ulogic;
    coreo_extaddr     : out std_logic_vector(CONF.word_size-1 downto 0);
    coreo_extdata     : out std_logic_vector(CONF.word_size-1 downto 0);
    coreo_memaccess   : out MEMACCESSTYPE;
    coreo_memen       : out std_ulogic;
    coreo_illop       : out std_ulogic;

    bromi_addr        : out std_logic_vector(CONF.word_size-1 downto 0);
    bromo_data        : in  INSTR;

    vecti_data_in     : out std_logic_vector(CONF.word_size-1 downto 0);
    vecti_interruptnr : out std_logic_vector(EXCADDR_W-2 downto 0);
    vecti_trapnr      : out std_logic_vector(EXCADDR_W-1 downto 0);
    vecti_wrvecnr     : out std_logic_vector(EXCADDR_W-1 downto 0);
    vecti_intcmd      : out std_ulogic;
    vecti_wrvecen     : out std_ulogic;
    vecto_data_out    : in  std_logic_vector(CONF.word_size-1 downto 0);

    sysci_staen       : out std_ulogic;
    sysci_stactrl     : out STACTRL;
    sysci_staflag     : out std_logic_vector(ALUFLAG_W-1 downto 0);
    sysci_interruptin : out std_logic_vector(15 downto 0);
    sysci_fptrwnew    : out std_logic_vector(CONF.word_size-1 downto 0);
    sysci_fptrxnew    : out std_logic_vector(CONF.word_size-1 downto 0);
    sysci_fptrynew    : out std_logic_vector(CONF.word_size-1 downto 0);
    sysci_fptrznew    : out std_logic_vector(CONF.word_size-1 downto 0);
                      
    sysco_condflag    : in  std_ulogic;
    sysco_carryflag   : in  std_ulogic;
    sysco_interruptnr : in  std_logic_vector(EXCADDR_W-2 downto 0);
    sysco_intcmd      : in  std_ulogic;
    sysco_fptrw       : in  std_logic_vector(CONF.word_size-1 downto 0);
    sysco_fptrx       : in  std_logic_vector(CONF.word_size-1 downto 0);
    sysco_fptry       : in  std_logic_vector(CONF.word_size-1 downto 0);
    sysco_fptrz       : in  std_logic_vector(CONF.word_size-1 downto 0);

    progo_instrsrc    : in  std_ulogic;
    progo_prupdate    : in  std_ulogic;
    progo_praddr      : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
    progo_prdata      : in  INSTR);
end scarts_core;

architecture behaviour of scarts_core is

constant WORD_W : natural := CONF.word_size;

subtype WORD is std_logic_vector(WORD_W-1 downto 0);

constant ZEROVALUE : WORD := (others => '0');

type fetch_stage_reg_type is record
  pcnt        : WORD;
  jmpdest     : WORD;
  jmpexe      : std_ulogic;
end record;

type decode_reg_type is record
  illop       : std_ulogic;
  regfwr      : std_ulogic;
  vectabwr    : std_ulogic;
  memen       : std_ulogic;
  memaccess   : MEMACCESSTYPE;
  memwr       : std_ulogic;
  staen       : std_ulogic;
  stactrl     : STACTRL;
  trap        : std_ulogic;
  jmpexe      : std_ulogic;
  jmpctrl     : JMPCTRL;
  aluctrl     : ALUCTRL;
  fptrupdate  : std_ulogic;
end record;

type decode_fix_reg_type is record
  imm         : WORD;
  signedac    : std_ulogic;
  negdata2    : std_ulogic;
  carry       : CARRYCTRL;
  useimm      : std_ulogic;
  usepc       : std_ulogic;
  fptr        : std_ulogic;
end record;

type decode_stage_reg_type is record
  dec         : decode_reg_type;
  decfix      : decode_fix_reg_type;
  pcnt        : WORD;
  vectabaddr  : std_logic_vector(EXCADDR_W-1 downto 0);
  regfaddr1   : REGADDR;
  regfaddr2   : REGADDR;
  fptrsel     : std_logic_vector(1 downto 0);
  fptrinc     : std_ulogic;
  alusrc1     : ALUSRCCTRL;
  alusrc2     : ALUSRCCTRL;
  condop1     : std_ulogic;
  condop2     : std_ulogic;
  condition   : std_ulogic;
  normalop    : std_ulogic;
end record;

type execute_stage_reg_type is record
  result      : WORD;
  regfwr      : std_ulogic;
  vectabaddr  : std_logic_vector(EXCADDR_W-1 downto 0);
  vectabwr    : std_ulogic;
  regfaddr    : REGADDR;
  wbsrc       : WBSRCCTRL;
end record;

type writeb_stage_reg_type is record
  result      : WORD;
end record;

type reg_type is record
  f   : fetch_stage_reg_type;
  d   : decode_stage_reg_type;
  e   : execute_stage_reg_type;
  w   : writeb_stage_reg_type;
end record;

--
-- for 16-bit version
--
function my_sll1 (vec : WORD;
                  cnt : std_logic_vector(3 downto 0))
                  return WORD is
variable result : WORD;
begin
  result := vec;
  for i in 0 to 3 loop
    if cnt(i) = '1' then
      result := result(result'high-2**i downto 0) & ZEROVALUE(2**i downto 1);
    end if;
  end loop;
  return result;
end;

--
-- for 32-bit version
--
function my_sll2 (vec : WORD;
                  cnt : std_logic_vector(4 downto 0))
                  return WORD is
variable result : WORD;
begin
  result := vec;
  for i in 0 to 4 loop
    if cnt(i) = '1' then
      result := result(result'high-2**i downto 0) & ZEROVALUE(2**i downto 1);
    end if;
  end loop;
  return result;
end;

--
-- for 16-bit version
--
function my_sr1 (vec : WORD;
                 cnt : std_logic_vector(3 downto 0);
                 fillbit : std_ulogic)
                 return WORD is
variable result : WORD;
variable fillvec : std_logic_vector(15 downto 0);
begin
  result := vec;
  fillvec := (others => fillbit);
  for i in 0 to 3 loop
    if cnt(i) = '1' then
      result := fillvec(2**i downto 1) & result(result'high downto 2**i);
    end if;
  end loop;
  return result;
end;

--
-- for 32-bit version
--
function my_sr2 (vec : WORD;
                 cnt : std_logic_vector(4 downto 0);
                 fillbit : std_ulogic)
                 return WORD is
variable result : WORD;
variable fillvec : std_logic_vector(31 downto 0);
begin
  result := vec;
  fillvec := (others => fillbit);
  for i in 0 to 4 loop
    if cnt(i) = '1' then
      result := fillvec(2**i downto 1) & result(WORD_W-1 downto 2**i);
    end if;
  end loop;
  return result;
end;

--
-- program counter
--
function pc (jmpexe : std_ulogic;
             jmpaddr, pc :WORD)
             return WORD is
variable instraddr : WORD;
begin
  if jmpexe = JMP_EXE then
    instraddr := jmpaddr;
  else
    instraddr := std_logic_vector(unsigned(pc) + 1);
  end if;
  return(instraddr);
end;


procedure decode (instr : INSTR;
                  decfix : out decode_fix_reg_type;
                  decvar : out decode_reg_type) is
variable v : decode_reg_type;
variable f : decode_fix_reg_type;
begin
  f.imm       := (others => '0');
  v.aluctrl   := ALU_NOP;
  v.illop     := not ILLOP;
  v.regfwr    := not REGF_WR;
  v.vectabwr  := not VECTAB_WR;
  v.memen     := not MEM_EN;
  v.memaccess := MEM_DISABLE;
  v.memwr     := not MEM_WR;
  v.staen     := not STA_EN;
  v.stactrl   := SET_FLAG;
  v.jmpexe    := not JMP_EXE;
  v.jmpctrl   := NO_SAVE;
  v.trap      := not TRAP_ACT;
  f.signedac  := not SIGNED_AC;
  f.fptr      := '0';
  v.fptrupdate := '0';
  f.useimm    := '0';
  f.usepc     := '0';
  f.negdata2  := '0';
  f.carry     := CARRY_IN;
  
  
  case instr(15 downto 12) is
    when "0000" =>
      -- LDLI
      v.regfwr := REGF_WR;
      f.imm := (others => instr(11));
      f.imm(7 downto 0) := instr(11 downto 4);
      v.aluctrl := ALU_BYPR2;
      f.useimm    := '1';
    when "0001" =>
      -- LDHI
      v.regfwr := REGF_WR;
      if CONF.word_size = 32 then
        f.imm := (others => instr(11));
      end if;
      f.imm(15 downto 8) := instr(11 downto 4);
      f.imm(7 downto 0) := (others => '0');
      v.aluctrl := ALU_LDHI;
      f.useimm    := '1';
    when "0010" =>
      -- LDLIU
      v.regfwr := REGF_WR;
      f.imm(15 downto 8) := (others => '0');
      f.imm(7 downto 0) := instr(11 downto 4);
      v.aluctrl := ALU_LDLIU;
      f.useimm    := '1';
    when "0011" =>
      if (instr(11) = '0') then
        -- CMPI_LT
        f.imm := (others => instr(10));
        f.imm(6 downto 0) := instr(10 downto 4);
        v.aluctrl := ALU_CMPLT;
        v.staen := STA_EN;
        v.stactrl := SET_COND;
        f.useimm    := '1';
        f.carry := CARRY_ONE;
        f.negdata2 := '1';
      else
        -- CMPI_GT
        f.imm := (others => instr(10));
        f.imm(6 downto 0) := instr(10 downto 4);
        v.aluctrl := ALU_CMPGT;
        v.staen := STA_EN;
        v.stactrl := SET_COND;
        f.useimm    := '1';
        f.carry := CARRY_ONE;
        f.negdata2 := '1';
      end if;
    when "0100" =>
      -- LDFP_INC/DEC
      v.fptrupdate := '1';
      v.memen := MEM_EN;
      v.regfwr := REGF_WR;
      f.imm := (others => instr(8));
      f.imm(4 downto 0) := instr(8 downto 4);
      f.fptr := '1';
      if CONF.word_size = 32 then
        v.memaccess := WORD_A;
      else
        v.memaccess := HWORD_A;
      end if;
    when "0101" =>
      -- STFP_INC/DEC
      v.fptrupdate := '1';
      v.memwr := MEM_WR;
      f.imm := (others => instr(8));
      f.imm(4 downto 0) := instr(8 downto 4);
      f.fptr := '1';
      if CONF.word_size = 32 then
        v.memaccess := WORD_A;
      else
        v.memaccess := HWORD_A;
      end if;
    when "0110" =>
      -- LDFP
      v.memen := MEM_EN;
      v.regfwr := REGF_WR;
      f.imm := (others => instr(9));
      f.imm(5 downto 0) := instr(9 downto 4);
      f.fptr := '1';
      if CONF.word_size = 32 then
        v.memaccess := WORD_A;
      else
        v.memaccess := HWORD_A;
      end if;
    when "0111" =>
      -- STFP
      v.memwr := MEM_WR;
      f.imm := (others => instr(9));
      f.imm(5 downto 0) := instr(9 downto 4);
      f.fptr := '1';
      if CONF.word_size = 32 then
        v.memaccess := WORD_A;
      else
        v.memaccess := HWORD_A;
      end if;
    when "1011" =>
      case instr(11 downto 8) is
        when "0000" =>
          -- CMP_EQ
          v.aluctrl := ALU_CMPEQ;
          v.staen := STA_EN;
          v.stactrl := SET_COND;
          f.carry := CARRY_ONE;
          f.negdata2 := '1';
        when "0001" =>
          -- CMP_LT
          v.aluctrl := ALU_CMPLT;
          v.staen := STA_EN;
          v.stactrl := SET_COND;
          f.carry := CARRY_ONE;
          f.negdata2 := '1';
        when "0010" =>
          -- CMP_GT
          v.aluctrl := ALU_CMPGT;
          v.staen := STA_EN;
          v.stactrl := SET_COND;
          f.carry := CARRY_ONE;
          f.negdata2 := '1';
       when "0011" =>
          -- CMPU_LT
          v.aluctrl := ALU_CMPULT;
          v.staen := STA_EN;
          v.stactrl := SET_COND;
          f.carry := CARRY_ONE;
          f.negdata2 := '1';
        when "0100" =>
          -- CMPU_GT
          v.aluctrl := ALU_CMPUGT;
          v.staen := STA_EN;
          v.stactrl := SET_COND;
          f.carry := CARRY_ONE;
          f.negdata2 := '1';
        when "0110" | "0111" =>
          -- BTEST
          v.aluctrl := ALU_AND;
          f.imm(to_integer(unsigned(instr(CONF.word_size/16+6 downto 4)))) := '1';
          v.staen := STA_EN;
          v.stactrl := SET_COND;
          f.useimm    := '1';
        when "1000" | "1001" | "1010" | "1011" |
                "1100" | "1101" | "1110" | "1111" =>
          -- CMPI_EQ
          f.imm := (others => instr(10));
          f.imm(6 downto 0) := instr(10 downto 4);
          v.aluctrl := ALU_CMPEQ;
          v.staen := STA_EN;
          v.stactrl := SET_COND;
          f.useimm    := '1';
          f.carry := CARRY_ONE;
          f.negdata2 := '1';
        when others => 
          v.illop := ILLOP;
      end case;
    when "1000" | "1001" | "1010" =>
      case instr(11 downto 9) is
        when "000" =>
          -- SL
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_SL;
          v.staen := STA_EN;
          f.imm(3 downto 0) := instr(7 downto 4);
          if (instr(8) = '1') then
            f.useimm    := '1';
          end if;       
        when "001" =>
          -- SR
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_SR;
          v.staen := STA_EN;
          f.imm(3 downto 0) := instr(7 downto 4);
          if (instr(8) = '1') then
            f.useimm    := '1';
          end if;       
        when "010" =>
          -- BSET
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_OR;
          f.imm(to_integer(unsigned(instr(CONF.word_size/16+6 downto 4)))) := '1';
          v.staen := STA_EN;
          f.useimm    := '1';
        when "011" =>
          -- BCLR
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_AND;
          f.imm := (others => '1');
          f.imm(to_integer(unsigned(instr(CONF.word_size/16+6 downto 4)))) := '0';
          v.staen := STA_EN;
          f.useimm    := '1';
        when "100" | "101" =>
          -- ADDI
          v.regfwr := REGF_WR;
          f.imm := (others => instr(9));
          f.imm(5 downto 0) := instr(9 downto 4);
          v.aluctrl := ALU_ADD;
          v.staen := STA_EN;
          f.useimm    := '1';
          f.carry := CARRY_ZERO;
        when "110" | "111" =>
          -- JMPI
          v.jmpexe := JMP_EXE;
          f.imm := (others => instr(9));
          f.imm(9 downto 0) := instr(9 downto 0);
          v.aluctrl := ALU_ADD;
          f.useimm  := '1';
          f.usepc   := '1';
          f.carry := CARRY_ZERO;
        when others => null;
      end case;
    when "1100" | "1101" | "1110" =>
      case instr(11 downto 8) is
        when "0000" =>
          -- MOV
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_BYPR2;
        when "0001" =>
          -- ADD
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_ADD;
          v.staen := STA_EN;
          f.carry := CARRY_ZERO;
        when "0010" =>
          -- ADDC
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_ADD;
          v.staen := STA_EN;
          f.carry := CARRY_IN;
        when "0011" =>
          -- SUB
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_SUB;
          v.staen := STA_EN;
          f.carry := CARRY_ONE;
          f.negdata2 := '1';
        when "0100" =>
          -- SUBC
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_SUB;
          v.staen := STA_EN;
          f.carry := CARRY_NOT;
          f.negdata2 := '1';
        when "0101" =>
          -- AND
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_AND;
          v.staen := STA_EN;
        when "0110" =>
          -- OR
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_OR;
          v.staen := STA_EN;
        when "0111" =>
          -- EOR
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_EOR;
          v.staen := STA_EN;
        when "1000" =>
          -- SRA
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_SRA;
          v.staen := STA_EN;
        when "1001" =>
          -- SRA
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_SRA;
          v.staen := STA_EN;
          f.imm(3 downto 0) := instr(7 downto 4);
          f.useimm    := '1';
        when "1010" =>
          -- RRC
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_RRC;
          v.staen := STA_EN;
        when "1011" =>
          -- TRAP
          v.jmpexe := JMP_EXE;
          v.aluctrl := ALU_BYPEXC;
          v.jmpctrl := SAVE_EXC;
          v.staen := STA_EN;
          v.stactrl := SAVE_SR;
          v.regfwr := REGF_WR;
          v.trap := TRAP_ACT;
        when "1100" =>
          -- NOT
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_NOT;
          v.staen := STA_EN;
        when "1101" =>
          -- NEG
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_NEG;
          v.staen := STA_EN;
        when "1110" =>
          -- JSR
          v.regfwr := REGF_WR;
          v.aluctrl := ALU_BYPR1;
          v.jmpexe := JMP_EXE;
          v.jmpctrl := SAVE_JMP;
        when "1111" =>
          -- JMP
          v.jmpexe := JMP_EXE;
          v.aluctrl := ALU_BYPR1;
          v.jmpctrl := NO_SAVE;
        when others => null;
      end case;
    when "1111" =>
      case instr(11 downto 8) is
        when "0000" =>
          -- LDW
          if CONF.word_size = 32 then
            v.memen := MEM_EN;
            v.regfwr := REGF_WR;
            v.memaccess := WORD_A;
          else
            v.illop := ILLOP;
          end if;
        when "0001" =>
          -- LDH
            v.memen := MEM_EN;
            v.regfwr := REGF_WR;
            v.memaccess := HWORD_A;
            f.signedac := SIGNED_AC;
        when "0010" =>
          -- LDHU
          if CONF.word_size = 32 then
            v.memen := MEM_EN;
            v.regfwr := REGF_WR;
            v.memaccess := HWORD_A;
          else
            v.illop := ILLOP;
          end if;
        when "0011" =>
          -- LDB
            v.memen := MEM_EN;
            v.regfwr := REGF_WR;
            f.signedac := SIGNED_AC;
            v.memaccess := BYTE_A;
        when "0100" =>
          -- LDBU
            v.memen := MEM_EN;
            v.regfwr := REGF_WR;
            v.memaccess := BYTE_A;
        when "0101" =>
          -- STW
          if CONF.word_size = 32 then
            v.memwr := MEM_WR;
            v.memaccess := WORD_A;
          else
            v.illop := ILLOP;
          end if;
        when "0110" =>
          -- STH
            v.memwr := MEM_WR;
            v.memaccess := HWORD_A;
        when "0111" =>
          -- STB
            v.memwr := MEM_WR;
            v.memaccess := BYTE_A;
        when "1000" =>
          -- RTS
          v.jmpexe := JMP_EXE;
          v.aluctrl := ALU_BYPR1;
        when "1001" =>
          -- RTE
          v.jmpexe := JMP_EXE;
          v.aluctrl := ALU_BYPR1;
          v.staen := STA_EN;
          v.stactrl := REST_SR;
        when "1010" | "1011" =>
          -- LDVEC
          v.aluctrl := ALU_BYPEXC;
          v.regfwr := REGF_WR;
        when "1100" | "1101" =>
          -- STVEC
          v.vectabwr := VECTAB_WR;
          v.aluctrl := ALU_BYPR1;
       when "1110" =>
          -- NOP
          null;
        when "1111" =>
          -- ILLOP
          v.illop := ILLOP;
        when others => null;
      end case;
    when others => null;
  end case;
  decfix := f;
  decvar := v;
end;

procedure alu (data1, data2 : WORD;
               excvec : WORD;
               aluctrl : ALUCTRL;
               carryin : std_ulogic;
               staflag : out ALUFLAG;
               result : out WORD) is
variable op1, op2, fulladderresult : std_logic_vector(WORD_W downto 0);
variable vcarryin : std_logic_vector(0 downto 0);
variable vcarryout : std_ulogic;
variable vresult, adderresult : WORD;
begin
  vresult := (others => '0');
  staflag := (others => '0');
  
  op1(WORD_W) := '0';
  op1(WORD_W-1 downto 0) := data1;
  op2(WORD_W) := '0';
  op2(WORD_W-1 downto 0) := data2;
  vcarryin(0) := carryin;
  fulladderresult := std_logic_vector(unsigned(op1) + unsigned(op2) + unsigned(vcarryin));
  vcarryout := fulladderresult(WORD_W);
  adderresult := fulladderresult(WORD_W-1 downto 0);
  
  case aluctrl is
    when ALU_NOP =>
      null;
    
    when ALU_LDLIU =>
      vresult(WORD_W-1 downto 8) := data1(WORD_W-1 downto 8);
      vresult(7 downto 0) := data2(7 downto 0);
    
    when ALU_LDHI =>
      vresult(WORD_W-1 downto 8) := data2(WORD_W-1 downto 8);
      vresult(7 downto 0) := data1(7 downto 0);
    
    when ALU_AND =>
      vresult := data1 and data2;
      if vresult /= ZEROVALUE then
        staflag(COND) := '1';
      end if;
    
    when ALU_OR =>
      vresult := data1 or data2;
    
    when ALU_EOR =>
      vresult := data1 xor data2;
    
    when ALU_ADD =>
      vresult := adderresult;
      staflag(CARRY) := vcarryout;
    
    when ALU_SUB =>
      vresult := adderresult;
      staflag(CARRY) := not vcarryout;
    
    when ALU_CMPEQ =>
      if adderresult = ZEROVALUE then
        staflag(COND) := '1';
      end if;
    
    when ALU_CMPUGT =>
      if adderresult /= ZEROVALUE then
        staflag(COND) := vcarryout;
      end if;
    
    when ALU_CMPULT =>
      staflag(COND) := not vcarryout;
    
    when ALU_CMPGT =>
      if data1(WORD_W-1) /= data2(WORD_W-1) then
        if adderresult = ZEROVALUE then
          staflag(COND) := adderresult(WORD_W-1);
        else
          staflag(COND) := not adderresult(WORD_W-1);
        end if;
      else
        staflag(COND) := not data1(WORD_W-1);
      end if;
    
    when ALU_CMPLT =>
      if data1(WORD_W-1) /= data2(WORD_W-1) then
          staflag(COND) := adderresult(WORD_W-1);
      else
        staflag(COND) :=  data1(WORD_W-1);
      end if;
    
    when ALU_NOT =>
      vresult := not data1;
    
    when ALU_NEG =>
      vresult := std_logic_vector(unsigned(not data1) + 1);
    
    when ALU_SL =>
      if CONF.word_size = 16 then
        vresult := my_sll1(data1, data2(3 downto 0));
      else
        vresult := my_sll2(data1, data2(4 downto 0));
      end if;
      staflag(CARRY) := data1(WORD_W-1);
    
    when ALU_SR =>
      if CONF.word_size = 16 then
        vresult := my_sr1(data1, data2(3 downto 0),'0');
       else
        vresult := my_sr2(data1, data2(4 downto 0),'0');
      end if;
      staflag(CARRY) := data1(0);
    
    when ALU_SRA =>
      if CONF.word_size = 16 then
        vresult := my_sr1(data1, data2(3 downto 0),data1(WORD_W-1));
       else
        vresult := my_sr2(data1, data2(4 downto 0),data1(WORD_W-1));
      end if;
      staflag(CARRY) := data1(0);
    
    when ALU_RRC =>
      vresult(WORD_W-2 downto 0) := data1(WORD_W-1 downto 1);
      vresult(WORD_W-1) := carryin;
      staflag(CARRY)  := data1(0);
    
    when ALU_BYPR1 =>
      vresult := data1;
    
    when ALU_BYPR2 =>
      vresult := data2;
    
    when ALU_BYPEXC =>
      vresult := excvec;
    
    when others => null;
  end case;
  
  if vresult = ZEROVALUE then
    staflag(ZERO) := '1';
  end if;
  
  if data1(WORD_W-1) = data2(WORD_W-1) then
    staflag(OVER) := vresult(WORD_W-1) xor data1(WORD_W-1);
  end if;
  
  staflag(NEG) := vresult(WORD_W-1);
  
  result := vresult;
end;

--
-- Tests if it is a conditional instruction
--
function eval_cond (condop1   : std_ulogic;
                    condop2   : std_ulogic;
                    condition : std_ulogic;
                    condflag  : std_ulogic
                   ) return std_ulogic is
variable notinstrexe : std_ulogic;
begin
  notinstrexe := '0';
  if (condop1 = COND_INSTR) and (condop2 = '0') then
    notinstrexe := condition xor condflag;
  end if;
  return notinstrexe;
end;

signal r_next : reg_type;
signal r : reg_type := (
    f => (
      pcnt    => (others =>'1'),
      jmpdest => (others =>'0'),
      jmpexe  => '0'
      ),
    d => (
      dec => (
        aluctrl   => ALU_NOP,
        illop     => '0',
        regfwr    => '0',
        vectabwr  => '0',
        memen     => '0',
        memaccess => MEM_DISABLE,
        memwr     => '0',
        staen     => '0',
        stactrl   => SET_FLAG,
        jmpexe    => '0',
        jmpctrl   => NO_SAVE,
        trap      => '0',
        fptrupdate => '0'
        ),
      decfix => (
        imm    => (others => '0'),
        signedac  => '0',
        fptr      => '0',
        useimm    => '0',
        usepc     => '0',
        negdata2  => '0',
        carry     => CARRY_IN
        ),
      fptrsel       => (others =>'0'),
      fptrinc       => '0',
      pcnt          => (others =>'0'),
      vectabaddr    => (others =>'0'),
      regfaddr1     => (others =>'0'),
      regfaddr2     => (others =>'0'),
      alusrc1       => REGF_SRC,
      alusrc2       => REGF_SRC,
      condop1       => '0',
      condop2       => '0',
      condition     => '0',
      normalop      => '0'
      ),
    e => (
      result   => (others =>'0'),
      regfwr   => '0',
      vectabwr => '0',
      regfaddr => (others =>'0'),
      wbsrc    => ALU_SRC,
      vectabaddr    => (others =>'0')
      ),
    w => (
    result   => (others =>'0')
    )
);

signal s_wbresult : WORD;
signal s_condregfwr, s_condjmpexe, s_condstaen : std_ulogic;
constant INST_ADDR_NULL : std_logic_vector (WORD_W-1 downto CONF.bootrom_base_address) := (others => '0');

begin


  comb : process(r, corei_interruptin, corei_extdata, bromo_data, regfo_rdata1, regfo_rdata2, iramo_rdata, vecto_data_out,
                 sysco_condflag, sysco_carryflag, sysco_interruptnr, sysco_intcmd, sysco_fptrw, sysco_fptrx,      
                 sysco_fptry, sysco_fptrz, s_wbresult,
                 progo_instrsrc, progo_prupdate, progo_praddr, progo_prdata,
                 s_condregfwr, s_condjmpexe, s_condstaen)
    
    variable v : reg_type;
    variable decinstr : INSTR := (others => '0');
    variable exedata1, exedata2 : WORD := (others => '0');
    variable v_aludata2 : WORD := (others => '0');
    variable regfdata1, regfdata2 : WORD := (others => '0');
    variable staflag : ALUFLAG := (others => '0');
    variable notinstrexe : std_ulogic := '0';
    variable decbuffer : decode_reg_type;
    variable regfiaddr : REGADDR := (others => '0');
    variable v_fptr : WORD := (others => '0');
    variable v_carry : std_ulogic := '0';

  begin
    v := r;
    exedata2 := (others => '0');
    -- fetch stage
    v.f.jmpexe := s_condjmpexe;
    v.f.pcnt := pc(r.f.jmpexe, r.f.jmpdest, r.f.pcnt);
    -- fetch output
    irami_raddr <= v.f.pcnt(CONF.instr_ram_size-1 downto 0);
    bromi_addr(WORD_W-1 downto CONF.bootrom_base_address) 
    	<= std_logic_vector(UNSIGNED(v.f.pcnt(WORD_W-1 downto CONF.bootrom_base_address)) - 1);
--    bromi_addr(CONF.bootrom_base_address) <= not v.f.pcnt(CONF.bootrom_base_address);
    bromi_addr(CONF.bootrom_base_address-1 downto 0) <= v.f.pcnt(CONF.bootrom_base_address-1 downto 0);

    --
    -- fetch stage end
    --
    -- decode stage begin
    --

    -- decode input
    if r.f.jmpexe = JMP_EXE then
      decinstr := NOP;
    else
      --
      -- decides if instructions are taken from bootrom or instruction-RAM
      --

--      MWA: the BOOTROM shall be mapped permanently into the address space.
--      this way, the instruction src selection bit of the programmer module
--      becomes obsolete (the instruction source is determined solely by the
--      program counter value)

--      if GDB_MODE_C = 1 then
        if r.f.pcnt(WORD_W-1 downto CONF.bootrom_base_address) /= INST_ADDR_NULL then
          decinstr := bromo_data;
        else
          decinstr := iramo_rdata;
        end if;  
--      else -- Not GDB-mode
--        if progo_instrsrc = BROM_SEL then
--          decinstr := bromo_data;
--        else
--          decinstr := iramo_rdata;
--        end if;
--      end if;
    end if;
    
    -- decode stage
    decode(decinstr, v.d.decfix, decbuffer);
    
    v.d.dec.aluctrl   := ALU_NOP;
    v.d.dec.illop     := not ILLOP;
    v.d.dec.regfwr    := not REGF_WR;
    v.d.dec.vectabwr  := not VECTAB_WR;
    v.d.dec.memen     := not MEM_EN;
    v.d.dec.memaccess := MEM_DISABLE ;
    v.d.dec.memwr     := not MEM_WR;
    v.d.dec.staen     := not STA_EN;
    v.d.dec.jmpexe    := not JMP_EXE;
    v.d.dec.trap      := not TRAP_ACT;
    v.d.dec.fptrupdate := '0';
    v.d.fptrsel       := decinstr(11 downto 10);
    v.d.fptrinc       := decinstr(9);
    v.d.regfaddr1     := decinstr(3 downto 0);
    v.d.regfaddr2     := decinstr(7 downto 4);
    v.d.vectabaddr    := decinstr(8 downto 4);
    v.d.condop1       := decinstr(15);
    v.d.condop2       := decinstr(13);
    v.d.condition     := decinstr(12);
    --
    -- if a jump is in action, save destination address
    -- as program counter.
    -- Important if an interrupt occurs during jump
    --
    if r.f.jmpexe=JMP_EXE then
      v.d.pcnt        := r.f.jmpdest;
    else
      v.d.pcnt        := r.f.pcnt;
    end if;
      
    
    v.d.normalop := '0';
    if sysco_intcmd = EXC_ACT then
      -- interrupt
      if r.d.dec.stactrl = SAVE_SR then
        v.d.dec.staen := not STA_EN;
      else
        v.d.dec.staen := STA_EN;
      end if;
      v.d.dec.stactrl := SAVE_SR;
      v.d.dec.regfwr := REGF_WR;
      v.d.dec.jmpexe := JMP_EXE;
      v.d.dec.jmpctrl := SAVE_EXC;
      v.d.dec.aluctrl := ALU_BYPEXC;
    elsif s_condjmpexe = JMP_EXE then
      -- jump is executed
      -- default assignments are used
      null;
    else
      -- normal instruction
      v.d.dec := decbuffer;
      v.d.normalop := '1';
    end if;
    
    
    v.d.alusrc1 := REGF_SRC;
    v.d.alusrc2 := REGF_SRC;
    
    -- decide forwarding for source-register 1
    if v.d.decfix.usepc = '1' then
      v.d.alusrc1 := DEC_SRC;
    elsif (v.d.regfaddr1 = r.d.regfaddr1) and (s_condregfwr = REGF_WR) then
      v.d.alusrc1 := EXE_SRC;
    elsif (v.d.regfaddr1 = r.e.regfaddr) and (r.e.regfwr = REGF_WR) then
      v.d.alusrc1 := WB_SRC;
    end if;
    
    -- decide forwarding for source-register 2
    if v.d.decfix.useimm = '1' then
      v.d.alusrc2 := DEC_SRC;
    elsif (v.d.regfaddr2 = r.d.regfaddr1) and (s_condregfwr = REGF_WR) then
      v.d.alusrc2 := EXE_SRC;
    elsif (v.d.regfaddr2 = r.e.regfaddr) and (r.e.regfwr = REGF_WR) then
      v.d.alusrc2 := WB_SRC;
    end if;
    
    -- decode output
    regfi_raddr1 <= v.d.regfaddr1;
    regfi_raddr2 <= v.d.regfaddr2;
    
    --
    -- decode stage end
    
    -- execute stage begin
    --
    
    -- execute input
    regfdata1 := regfo_rdata1;
    regfdata2 := regfo_rdata2;
    
    -- execute stage
    coreo_illop <= r.d.dec.illop;
    
    notinstrexe := '0';
    if r.d.normalop = '1' then
      notinstrexe := eval_cond(r.d.condop1, r.d.condop2, r.d.condition, sysco_condflag);
    end if;
    
    if notinstrexe = '1' then
      s_condregfwr <= not REGF_WR;
      s_condjmpexe <= not JMP_EXE;
      s_condstaen <= not STA_EN;
    else
      s_condregfwr <= r.d.dec.regfwr;
      s_condjmpexe <= r.d.dec.jmpexe;
      s_condstaen <= r.d.dec.staen;
    end if;
    
    v.e.regfwr := s_condregfwr;
    v.e.vectabwr := r.d.dec.vectabwr;
    v.e.vectabaddr := r.d.vectabaddr;
--    v.e.memen := r.d.dec.memen;
    
    case r.d.alusrc1 is
      when REGF_SRC =>
        exedata1 := regfdata1;
      when EXE_SRC =>
        exedata1 := s_wbresult;
      when WB_SRC =>
        exedata1 := r.w.result;
      when DEC_SRC =>
        exedata1 := r.d.pcnt;
      when others => null;
    end case;
    
    case r.d.alusrc2 is
      when REGF_SRC =>
        exedata2 := regfdata2;
      when EXE_SRC =>
        exedata2 := s_wbresult;
      when WB_SRC =>
        exedata2 := r.w.result;
      when DEC_SRC =>
        exedata2 := r.d.decfix.imm;
      when others => null;
    end case;
    
    case r.d.decfix.carry is
      when CARRY_IN =>
        v_carry := sysco_carryflag;
      when CARRY_NOT =>
        v_carry := not sysco_carryflag;
      when CARRY_ZERO =>
        v_carry := '0';
      when CARRY_ONE =>
        v_carry := '1';
      when others => null;
    end case;
    
    if r.d.decfix.negdata2 = '1' then
      v_aludata2 := not exedata2;
    else
      v_aludata2 := exedata2;
    end if;
    
    alu(exedata1, v_aludata2, vecto_data_out, r.d.dec.aluctrl, v_carry, staflag, v.e.result);
    v.f.jmpdest := v.e.result;

    v.e.regfaddr := (others => '0');
    case r.d.dec.jmpctrl is
      when SAVE_JMP =>
        -- normal jump => save program counter of fetch stage
        v.e.result := r.f.pcnt;
        v.e.regfaddr := std_logic_vector(to_unsigned(SUBRETREG,REGADDR_W));
      when SAVE_EXC =>
        if r.d.dec.trap = not TRAP_ACT then
            if r.f.jmpexe=JMP_EXE then
              -- if jump is in progress => save destination address
              v.e.result            := r.f.jmpdest;
            else
              -- normal operation => save program counter of discarded instruction
              v.e.result            := r.d.pcnt;
            end if;
          v.e.regfaddr := std_logic_vector(to_unsigned(EXCRETREG,REGADDR_W));
        else
          v.e.result:= r.f.pcnt;
          v.e.regfaddr := std_logic_vector(to_unsigned(EXCRETREG,REGADDR_W));
        end if;
      when NO_SAVE =>
        -- jump without return
        v.e.result := v.e.result;
        v.e.regfaddr := r.d.regfaddr1;
      when others =>
        null;
    end case;
    --frame pointer
    v_fptr := (others => '0');
    sysci_fptrwnew <= sysco_fptrw;
    sysci_fptrxnew <= sysco_fptrx;
    sysci_fptrynew <= sysco_fptry;
    sysci_fptrznew <= sysco_fptrz;
    case r.d.fptrsel is
      when "00" =>
          v_fptr := sysco_fptrw;
        if r.d.dec.fptrupdate = '1' then
          if r.d.fptrinc = '0' then
            sysci_fptrwnew(WORD_W-1 downto CONF.word_size/16) <= std_logic_vector(unsigned(sysco_fptrw(WORD_W-1 downto CONF.word_size/16)) + 1);
          else
            sysci_fptrwnew(WORD_W-1 downto CONF.word_size/16) <= std_logic_vector(unsigned(sysco_fptrw(WORD_W-1 downto CONF.word_size/16)) - 1);
          end if;
        end if;
      when "01" =>
          v_fptr := sysco_fptrx;
        if r.d.dec.fptrupdate = '1' then
          if r.d.fptrinc = '0' then
            sysci_fptrxnew(WORD_W-1 downto CONF.word_size/16) <= std_logic_vector(unsigned(sysco_fptrx(WORD_W-1 downto CONF.word_size/16)) + 1);
          else
            sysci_fptrxnew(WORD_W-1 downto CONF.word_size/16) <= std_logic_vector(unsigned(sysco_fptrx(WORD_W-1 downto CONF.word_size/16)) - 1);
          end if;
        end if;
      when "10" =>
          v_fptr := sysco_fptry;
        if r.d.dec.fptrupdate = '1' then
          if r.d.fptrinc = '0' then
            sysci_fptrynew(WORD_W-1 downto CONF.word_size/16) <= std_logic_vector(unsigned(sysco_fptry(WORD_W-1 downto CONF.word_size/16)) + 1);
          else
            sysci_fptrynew(WORD_W-1 downto CONF.word_size/16) <= std_logic_vector(unsigned(sysco_fptry(WORD_W-1 downto CONF.word_size/16)) - 1);
          end if;
        end if;
      when "11" =>
          v_fptr := sysco_fptrz;
        if r.d.dec.fptrupdate = '1' then
          if r.d.fptrinc = '0' then
            sysci_fptrznew(WORD_W-1 downto CONF.word_size/16) <= std_logic_vector(unsigned(sysco_fptrz(WORD_W-1 downto CONF.word_size/16)) + 1);
          else
            sysci_fptrznew(WORD_W-1 downto CONF.word_size/16) <= std_logic_vector(unsigned(sysco_fptrz(WORD_W-1 downto CONF.word_size/16)) - 1);
          end if;
        end if;
      when others => null;
    end case;
    v_fptr(WORD_W-1 downto CONF.word_size/16) := std_logic_vector(unsigned(v_fptr(WORD_W-1 downto CONF.word_size/16)) + unsigned(r.d.decfix.imm(WORD_W-CONF.word_size/16-1 downto 0)));
    if r.d.decfix.fptr = '1' then
      exedata2 := v_fptr;
    end if;
    
    -- execute output
    sysci_staflag <= staflag;
    sysci_staen <= s_condstaen;
    sysci_stactrl <= r.d.dec.stactrl;
    
    coreo_extwr <= r.d.dec.memwr;
    coreo_memaccess <= r.d.dec.memaccess;
    coreo_memen <= r.d.dec.memen;

    coreo_signedac <= r.d.decfix.signedac;
    coreo_extaddr <= exedata2;
    coreo_extdata <= exedata1;

    if r.d.dec.memen = MEM_EN then
      v.e.wbsrc := MEM_SRC;
    else
      v.e.wbsrc := ALU_SRC;
    end if;

    --
    -- execute stage end
    --
    -- write back stage begin
    --

    -- decides if memory access or normal operation
    s_wbresult <= (others => '0');
    case r.e.wbsrc is
      when ALU_SRC =>
        s_wbresult <= r.e.result;
      when MEM_SRC =>
        s_wbresult <= corei_extdata;
      when others => null;
    end case;
    
    v.w.result := s_wbresult;
    
    -- writeb output
    regfi_wdata <= s_wbresult;
    regfi_waddr <= r.e.regfaddr;
    regfi_wen   <= r.e.regfwr;
    
    sysci_interruptin <= corei_interruptin;
    
    vecti_intcmd <= sysco_intcmd;
    vecti_interruptnr <= sysco_interruptnr;
    vecti_trapnr <= decinstr(8 downto 4);
    vecti_wrvecnr <= r.e.vectabaddr;
    vecti_data_in <= r.e.result;
    vecti_wrvecen <= r.e.vectabwr;
    
    
    irami_wdata <= progo_prdata;
    irami_waddr <= progo_praddr(CONF.instr_ram_size-1 downto 0);
    irami_wen <= progo_prupdate;
    
        
    r_next <= v;
  end process;

  
  reg : process(clk)--, sysrst)
  begin
    
    if rising_edge(clk) then
      if sysrst = RST_ACT then

--        MWA: the execution shall always start at the BOOTROM
    
--        if GDB_MODE_C = 1 then
          --  Start execution at adress 0x0 in Boot-Rom
          --  Boot rom is mapped to 2**CONF.bootrom_base_address
          r.f.pcnt(WORD_W-1 downto CONF.bootrom_base_address) <= (others =>'0');
          r.f.pcnt(CONF.bootrom_base_address-1 downto 0) <= (others =>'1');
--        else
--          r.f.pcnt    <= (others =>'1');
--        end if;
        r.f.jmpdest <= (others =>'0');
        r.f.jmpexe  <= '0';
        
        r.d.dec.aluctrl   <= ALU_NOP;
        r.d.dec.illop     <= '0';
        r.d.dec.regfwr    <= '0';
        r.d.dec.vectabwr  <= '0';
        r.d.dec.memen     <= '0';
        r.d.dec.memaccess <= MEM_DISABLE;
        r.d.dec.memwr     <= '0';
        r.d.dec.staen     <= '0';
        r.d.dec.stactrl   <= SET_FLAG;
        r.d.dec.jmpexe    <= '0';
        r.d.dec.jmpctrl   <= NO_SAVE;
        r.d.dec.trap      <= '0';
        r.d.dec.fptrupdate   <= '0';
        r.d.decfix.imm    <= (others => '0');
        r.d.decfix.signedac  <= '0';
        r.d.decfix.fptr      <= '0';
        r.d.decfix.useimm    <= '0';
        r.d.decfix.usepc     <= '0';
        r.d.decfix.negdata2  <= '0';
        r.d.decfix.carry     <= CARRY_IN;
        r.d.fptrsel       <= (others =>'0');
        r.d.fptrinc       <= '0';
        r.d.pcnt          <= (others =>'0');
        r.d.vectabaddr    <= (others =>'0');
        r.d.regfaddr1     <= (others =>'0');
        r.d.regfaddr2     <= (others =>'0');
        r.d.alusrc1       <= REGF_SRC;
        r.d.alusrc2       <= REGF_SRC;
        r.d.condop1       <= '0';
        r.d.condop2       <= '0';
        r.d.condition     <= '0';
        r.d.normalop      <= '0';
        
        r.e.result   <= (others =>'0');
        r.e.regfwr   <= '0';
        r.e.vectabwr <= '0';
--        r.e.regfaddr <= (others =>'0');
        r.e.wbsrc    <= ALU_SRC;
--        r.e.vectabaddr    <= (others =>'0');
        
  	    r.w.result   <= (others =>'0');
  	    
      else
        if (hold = not HOLD_ACT) then
          r <= r_next;
        end if;
      end if;
    end if;
  end process;


end behaviour;
