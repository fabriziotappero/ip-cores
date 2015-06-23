



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	iu
-- File:	iu.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	LEON integer unit. Consists of 5 pipline stages: fetch,
--		decode, execute, memory and write-back. Each stage is
--		implemented in a separate process.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.conv_integer;
use work.leon_target.all;
use work.leon_config.all;
use work.mmuconfig.all;
use work.sparcv8.all;
use work.leon_iface.all;
use work.macro.all;
use work.tech_map.all;
use work.multlib.all;

entity iu is
port (
    rst    : in  std_logic;
    clk    : in  clk_type;		
    holdn  : in  std_logic;		
    ici    : out icache_in_type;		-- icache input
    ico    : in  icache_out_type;		-- icache output
    dci    : out dcache_in_type;		-- dcache input
    dco    : in  dcache_out_type;		-- dcache output
    fpui   : out fpu_in_type;			-- FPU input
    fpuo   : in  fpu_out_type;			-- FPU output
    iui    : in  iu_in_type;			-- system input
    iuo    : out iu_out_type;			-- system output
    rfi    : out rf_in_type;			-- register-file input
    rfo    : in rf_out_type;			-- register-file output
    cpi    : out cp_in_type;			-- CP input
    cpo    : in  cp_out_type;			-- CP output
    fpi    : out cp_in_type;			-- FP input
    fpo    : in  cp_out_type			-- FP output
);
end;

architecture rtl of iu is

-- pipeline_control type is defined in package iface

type fetch_stage_inputs is record
  branch         : std_logic;			   -- select branch address
  jump           : std_logic;			   -- select jump address
  exception      : std_logic;			   -- select exception address
  hold_pc        : std_logic;			   -- hold PC (multi-cycle inst.)
  branch_address : std_logic_vector(31 downto PCLOW);  --  branch address
  jump_address   : std_logic_vector(31 downto PCLOW);    --  jump address
  trap_address   : std_logic_vector(31 downto PCLOW);    --  trap address
end record;

type fetch_stage_registers is record
  pc      : std_logic_vector(31 downto PCLOW);  --  program counter
  branch  : std_logic;			    -- branch indicator
end record;

type decode_stage_type is record
  inst    : std_logic_vector(31 downto 0);  -- instruction
  pc      : std_logic_vector(31 downto PCLOW);  -- program counter
  mexc    : std_logic;			    -- memory exception (fetch)
  annul   : std_logic;			    -- instruction annul bit
  cnt     : std_logic_vector(1 downto 0);   -- cycle number (multi-cycle inst)
  mulcnt  : std_logic_vector(4 downto 0);   -- cycle number (multiplier)
  pv      : std_logic;			    -- PC valid flag
  cwp     : std_logic_vector(NWINLOG2-1 downto 0);	-- current window pointer
  step    : std_logic;			    -- single step
end record;

type execute_stage_type is record
  write_cwp, write_icc, write_reg, write_y, rst_mey : std_logic;
  cwp : std_logic_vector(NWINLOG2-1 downto 0);	-- current window pointer
  icc : std_logic_vector(3 downto 0);		-- integer condition codes
  alu_cin : std_logic;				-- ALU carry-in
  ymsb   : std_logic;				-- MULSCC Y(msb)
  rs1data : std_logic_vector(31 downto 0);	-- source operand 1
  rs2data : std_logic_vector(31 downto 0);	-- source operand 2
  aluop  : std_logic_vector(2 downto 0);  	-- Alu operation
  alusel : std_logic_vector(1 downto 0);  	-- Alu result select
  aluadd : std_logic;				-- add/sub select
  mulstep : std_logic;				-- MULSCC
  mulinsn : std_logic;				-- SMUL/UMUL
  ldbp1, ldbp2 : std_logic;		-- load bypass enable
  ctrl : pipeline_control_type;
  result  : std_logic_vector(31 downto 0);    -- data forward from execute stage
  micc    : std_logic_vector(3 downto 0);     -- icc for multiply insn
  licc    : std_logic_vector(3 downto 0);     -- icc to me stage
end record;

type memory_stage_type is record
  inull : std_logic;
  signed : std_logic;				-- signed load
  addr_misal : std_logic;			-- misaligned address
  write_cwp, write_icc, write_reg, write_y : std_logic;
  cwp : std_logic_vector(NWINLOG2-1 downto 0);
  icc : std_logic_vector(3 downto 0);
  result : std_logic_vector(31 downto 0);
  bpresult : std_logic_vector(31 downto 0);	-- result for bypass to de & me
  y : std_logic_vector(31 downto 0);		-- pipeline Y register
  my : std_logic_vector(31 downto 0);		-- me stage Y feedback
  memory_load : std_logic;
  mulinsn : std_logic;				-- SMUL/UMUL
  ld_size      : std_logic_vector(1 downto 0);   -- memory load size
  ctrl : pipeline_control_type;
  jmpl_rett : std_logic;
  irqen : std_logic;
  ipend : std_logic;
  werr  : std_logic;				-- store error
  su    : std_logic;				-- supervisor mode
end record;

type write_stage_type is record
  write_cwp, write_icc, write_reg : std_logic;
  cwp : std_logic_vector(NWINLOG2-1 downto 0);
  icc : std_logic_vector(3 downto 0);
  result : std_logic_vector(31 downto 0);
  y : std_logic_vector(31 downto 0);
  asr18 : std_logic_vector(31 downto 0);
  annul_all : std_logic;
  trapping : std_logic;
  error : std_logic;
  nerror : std_logic;
  mexc : std_logic;
  intack : std_logic;
  tpcsel           : std_logic_vector(1 downto 0); -- Trap pc select
  dsutrap : std_logic;		-- debug unit trap (optional)
  ctrl : pipeline_control_type;

end record;

type special_register_type is record
  cwp    : std_logic_vector(NWINLOG2-1 downto 0); -- current window pointer
  icc    : std_logic_vector(3 downto 0);	  -- integer condition codes
  tt     : std_logic_vector(7 downto 0);	  -- trap type
  tba    : std_logic_vector(19 downto 0);	  -- trap base address
  wim    : std_logic_vector(NWINDOWS-1 downto 0); -- window invalid mask
  pil    : std_logic_vector(3 downto 0);	  -- processor interrupt level
  ec     : std_logic;			  	  -- enable CP 
  ef     : std_logic;			  	  -- enable FP 
  ps     : std_logic;			  	  -- previous supervisor flag
  s      : std_logic;			  	  -- supervisor flag
  et     : std_logic;			  	  -- enable traps
end record;

type fsr_type is record
  cexc   : std_logic_vector(4 downto 0); -- current exceptions
  aexc   : std_logic_vector(4 downto 0); -- accrued exceptions
  fcc    : std_logic_vector(1 downto 0); -- FPU condition codes
  ftt    : std_logic_vector(2 downto 0); -- FPU trap type
  tem    : std_logic_vector(4 downto 0); -- trap enable mask
  rd     : std_logic_vector(1 downto 0); -- rounding mode
end record;

type fpu_ctrl1_type is record
  fpop   : std_logic_vector(1 downto 0); -- FPOP type 
  dsz    : std_logic;		 -- destination size (0=single, 1=double)
  ldfsr  : std_logic;		 -- LDFSR in progress
end record;

type fpu_ctrl2_type is record
  fpop   : std_logic_vector(1 downto 0);
  dsz    : std_logic;
  fcc    : std_logic_vector(1 downto 0);
  cexc   : std_logic_vector(4 downto 0);	-- current FPU excetion bits
  ldfsr  : std_logic;
end record;

type fpu_reg_type is record
  fsr    : fsr_type;
  fpop   : std_logic;
  reset  : std_logic;
  rstdel : std_logic_vector(1 downto 0);
  fpbusy : std_logic;
  fpld   : std_logic;
  fpexc  : std_logic;
  op1h   : std_logic_vector(31 downto 0);
  ex     : fpu_ctrl1_type;
  me, wr : fpu_ctrl2_type;
end record;

constant WPALEN : integer := 30;
type watchpoint_register is record
  addr    : std_logic_vector(WPALEN+1 downto 2);  -- watchpoint address
  mask    : std_logic_vector(WPALEN+1 downto 2);  -- watchpoint mask
  exec    : std_logic;			    -- trap on instruction
  load    : std_logic;			    -- trap on load
  store   : std_logic;			    -- trap on store
end record;

type watchpoint_registers is array (0 to 3) of watchpoint_register;

type dsu_registers is record
  pc      : std_logic_vector(31 downto PCLOW);  --  program counter
  dmode   : std_logic;				--  debug mode active
  dmode2  : std_logic;				--  debug mode active (delayed)
  dstate  : std_logic;				--  debug state
  tt      : std_logic_vector(7 downto 0);	--  trap type
  error   : std_logic;			    -- trap would cause error
  dsuen   : std_logic;			    
end record;

component div
port (
    rst     : in  std_logic;
    clk     : in  clk_type;
    holdn   : in  std_logic;
    divi    : in  div_in_type;
    divo    : out div_out_type
);
end component;

component mul
port (
    rst     : in  std_logic;
    clk     : in  clk_type;
    holdn   : in  std_logic;
    muli    : in  mul_in_type;
    mulo    : out mul_out_type
);
end component;

-- registers

constant FASTADD : boolean := false;
constant PILOPT : boolean := FASTDECODE;
constant Zero32: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal fecomb   : fetch_stage_inputs;
signal fe, fein : fetch_stage_registers;
signal de, dein : decode_stage_type;
signal ex, exin : execute_stage_type;
signal me, mein : memory_stage_type;
signal wr, wrin : write_stage_type;
signal sregsin, sregs : special_register_type;
signal dciin : dcache_in_type;
signal fpu_reg, fpu_regin : fpu_reg_type;
signal tr, trin : watchpoint_registers;
signal dsur, dsurin : dsu_registers;
signal muli : mul_in_type;			-- multiplier input
signal mulo : mul_out_type;			-- muliplier output
signal divi : div_in_type;			-- divider input
signal divo : div_out_type;			-- divider output
signal sum32, add32in1, add32in2 : std_logic_vector(31 downto 0);
signal add32cin : std_logic;

begin

-------------------------------------------------------------------------------
-- Instruction fetch stage
-------------------------------------------------------------------------------

  fetch_stage : process(fecomb, fe, rst, de, mein)
  variable v : fetch_stage_registers;
  variable npc : std_logic_vector(31 downto PCLOW);
  begin

    v := fe;

-- pc generation

    npc := fe.pc;
    if (rst = '0') then
      v.pc := (others => '0'); v.branch := '0';
    elsif fecomb.exception = '1' then	-- exception
      v.branch := '1'; v.pc := fecomb.trap_address;
      npc := v.pc;
    elsif (not mein.inull and fecomb.hold_pc) = '1' then
      v.pc := fe.pc; v.branch := fe.branch;
    elsif fecomb.jump = '1' then
      v.pc := fecomb.jump_address; v.branch := '1';
      npc := v.pc;
    elsif fecomb.branch = '1' then
      v.pc := fecomb.branch_address; v.branch := '1';
      npc := v.pc;
    else
      v.branch := '0';
-- pragma translate_off
      if not is_x(fe.pc) then
-- pragma translate_on
       v.pc(31 downto 2) := fe.pc(31 downto 2) + 1;    -- Address incrementer
-- pragma translate_off
      else
        v.pc := (others => 'X');
      end if;
-- pragma translate_on
      npc := v.pc;
    end if;

-- drive register inputs

    fein <= v;

-- drive some icache inputs

--    ici.rpc(31 downto PCLOW) <= v.pc(31 downto PCLOW);
    ici.rpc(31 downto PCLOW) <= npc;
    ici.fpc(31 downto PCLOW) <= fe.pc(31 downto PCLOW);
    ici.dpc(31 downto PCLOW) <= de.pc(31 downto PCLOW);
    ici.fbranch <= fe.branch;
    ici.rbranch <= v.branch;

  end process;

-------------------------------------------------------------------------------
-- Instruction decode stage
-------------------------------------------------------------------------------


  decode_stage : process(rst, fe, de, ex, me, mein, wrin, wr, sregs, ico, rfo,
		         sregsin, fpo, cpo, dco, holdn, fpu_reg, mulo, divo, tr,
			 iui, dsur)

  variable rfenable1, rfenable2 : std_logic;	-- regfile enable strobes
  variable op     : std_logic_vector(1 downto 0);
  variable op2    : std_logic_vector(2 downto 0);
  variable op3    : std_logic_vector(5 downto 0);
  variable opf    : std_logic_vector(8 downto 0);
  variable cond   : std_logic_vector(3 downto 0);
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable write_cwp, write_icc, write_reg, write_y : std_logic;
  variable cnt     : std_logic_vector(1 downto 0);	-- cycle number
  variable cwp_new : std_logic_vector(NWINLOG2-1 downto 0);
  variable icc, br_icc : std_logic_vector(3 downto 0);
  variable alu_cin : std_logic;
  variable immediate_data : std_logic_vector(31 downto 0);
  variable n, z, v, c : std_logic;  -- temporary condition codes
  variable i : std_logic;           -- immidiate data bit
  variable su : std_logic;           -- local supervisor bit;
  variable et : std_logic;           -- local enable trap bit
  variable inull, annul, annul_current : std_logic;
  variable branch, annul_next, bres, branch_true: std_logic;
  variable aluop  : std_logic_vector(2 downto 0);
  variable alusel : std_logic_vector(1 downto 0); 
  variable aluadd : std_logic;         
  variable mulstep : std_logic;          
  variable mulinsn : std_logic;          
  variable y0 : std_logic;          
  variable branch_address : std_logic_vector(31 downto PCLOW);
  variable rs1data, rs2data : std_logic_vector(31 downto 0);
  variable operand2_select : std_logic;
  variable read_addr1, read_addr2, chkrd : std_logic_vector(RABITS-1 downto 0);
  variable hold_pc : std_logic;		-- Hold PC during multi-cycle ops
  variable pv : std_logic;		-- PC valid
  variable ldlock, ldcheck1, ldcheck2, ldcheck3 : std_logic; -- load interlock
  variable ldchkex, ldchkme : std_logic;  	-- load interlock for ex and me
  variable illegal_inst : std_logic;  	-- illegal instruction
  variable privileged_inst : std_logic;  	-- privileged instruction trap
  variable cp_disabled  : std_logic;  	-- CP disable trap
  variable fp_disabled  : std_logic;  	-- FP disable trap
  variable watchpoint_exc  : std_logic;  	-- watchpoint trap
  variable winovf_exception : std_logic;  	-- window overflow trap
  variable winunf_exception : std_logic;  	-- window underflow trap
  variable ticc_exception : std_logic;  	-- TICC trap
  variable fp_exception : std_logic;  	-- STDFQ trap 
  variable ctrl : pipeline_control_type;
  variable ldbp1, ldbp2 : std_logic;		-- load bypass enable
  variable mulcnt  : std_logic_vector(4 downto 0);   -- multiply cycle number
  variable ymsb : std_logic;		-- next msb of Y during MUL
  variable rst_mey : std_logic;		-- reset me stage Y register
  variable fpld, fpst, fpop : std_logic;	-- FPU instructions
  variable fpmov  : std_logic;		-- FPU instructions
  variable fbres, fbranch_true : std_logic;	-- FBCC branch result
  variable cbres, cbranch_true : std_logic;	-- CBCC branch result
  variable fcc : std_logic_vector(1 downto 0);   -- FPU condition codes
  variable ccc : std_logic_vector(1 downto 0);   -- CP condition codes
  variable cwpmax : std_logic_vector(4 downto 0); 
  variable bicc_hold, icc_check : std_logic;
  variable fsr_ld, fsr_ld_check, fsr_check, fsr_lock : std_logic;
  variable fpexin : fpu_ctrl1_type;
  variable rs1mod : std_logic;
  variable step : std_logic;
  variable divstart,mulstart : std_logic;	-- start multiply or divide
  variable cpldlock, fpldlock, annul_current_cp : std_logic;
  constant RDOPT : boolean := FASTDECODE;-- optimise dest reg address generation
  constant RS1OPT : boolean := FASTDECODE;-- optimise src1 reg address generation

  function regdec(cwp, regin : std_logic_vector; fp : std_logic) 
  	return std_logic_vector is
  variable reg : std_logic_vector(4 downto 0);
  variable ra : std_logic_vector(RABITS -1 downto 0);
  begin
    reg := regin; ra(4 downto 0) := reg;
    if (FPIFTYPE = serial) and (fp = '1') then
      ra(RABITS -1 downto 5) := F0ADDR(RABITS-5 downto 1);
    elsif reg(4 downto 3) = "00" then ra(RABITS -1 downto 4) := R0ADDR;
    else
-- pragma translate_off
      if not (is_x(cwp & ra(4))) then
-- pragma translate_on
        ra(NWINLOG2+3 downto 4) := (cwp + ra(4));
	if CWPOPT then ra(RABITS-1) := '0';
	elsif ra(RABITS-1 downto 4) = R0ADDR then
	  ra(RABITS-1 downto 4) := (others => '0');
	end if;
-- pragma translate_off
      end if;
-- pragma translate_on
    end if;
    return(ra);
  end;

begin

-- instruction bit-field decoding

    op    := de.inst(31 downto 30);
    op2   := de.inst(24 downto 22);
    op3   := de.inst(24 downto 19);
    opf   := de.inst(13 downto 5);
    cond  := de.inst(28 downto 25);
    annul := de.inst(29);
    rs1   := de.inst(18 downto 14);
    rs2   := de.inst(4 downto 0);
    rd    := de.inst(29 downto 25);
    i     := de.inst(13);

-- common initialisation

    ctrl.annul := de.annul; ctrl.cnt := de.cnt; ctrl.pv := de.pv; pv := '1';
    cnt := "00"; ctrl.tt := "000000"; ctrl.ld := '0'; ctrl.rett := '0';
    ctrl.pc := de.pc; ctrl.inst := de.inst; mulcnt := de.mulcnt;
    write_y := '0'; fpld := '0'; fpst := '0'; fpop := '0';
    fp_exception := '0'; fpmov := '0'; step := '0';
    fpexin.fpop := "00"; fpexin.dsz := '0'; fpexin.ldfsr := '0';

    winovf_exception := '0'; winunf_exception := '0';
    write_cwp := '0'; cwp_new := de.cwp; rs1mod := '0';
    rfenable1 := '0'; rfenable2 := '0'; 

-- detect RETT instruction in the pipeline and set the local psr.su and psr.et

    if ((ex.ctrl.rett and not ex.ctrl.annul) or (me.ctrl.rett and not me.ctrl.annul) or 
        (wr.ctrl.rett and not wr.ctrl.annul)) = '1' 
    then 
      su := sregs.ps; et := '1';
    else 
      su := sregs.s; et := sregs.et;
    end if;

-- Check for illegal and privileged instructions

    illegal_inst := '0'; privileged_inst := '0'; cp_disabled := '0'; 
    fp_disabled := '0';
    case op is
    when CALL => null;
    when FMT2 =>
      case op2 is
      when SETHI | BICC => null;
      when FBFCC => 
	if FPEN then fp_disabled := not sregs.ef;
	else fp_disabled := '1'; end if;
      when CBCCC =>
	if (not CPEN) or (sregs.ec = '0') then cp_disabled := '1'; end if;
      when others => illegal_inst := '1';
      end case;
    when FMT3 =>
      case op3 is
      when IAND | ANDCC | ANDN | ANDNCC | IOR | ORCC | ORN | ORNCC | IXOR |
        XORCC | IXNOR | XNORCC | ISLL | ISRL | ISRA | MULSCC | IADD | ADDX |
	ADDCC | ADDXCC | TADDCC | TADDCCTV | ISUB | SUBX | SUBCC | SUBXCC |
	TSUBCC | TSUBCCTV  | FLUSH | JMPL | TICC | SAVE | RESTORE | RDY => null;
      when UMAC | SMAC => 
	if not MACEN then illegal_inst := '1'; end if;
      when UMUL | SMUL | UMULCC | SMULCC => 
	if MULTIPLIER = none then illegal_inst := '1'; end if;
      when UDIV | SDIV | UDIVCC | SDIVCC => 
	if DIVIDER = none then illegal_inst := '1'; end if;
      when RETT => illegal_inst := et; privileged_inst := not su;
      when RDPSR | RDTBR | RDWIM => privileged_inst := not su;
      when WRY  => 

	if not ((rd = "00000") or ((rd = "10010") and MACEN) or 
               ((rd(4 downto 3) = "11") and (WATCHPOINTS > 0))) 
	then 

	  illegal_inst := '1';
	end if;
      when WRPSR => 
	privileged_inst := not su; 
      when WRWIM | WRTBR  => privileged_inst := not su;
      when FPOP1 | FPOP2 => 
	if FPEN then fp_disabled := not sregs.ef; fpop := '1';
	else fp_disabled := '1'; fpop := '0'; end if;
      when CPOP1 | CPOP2 =>
	if (not CPEN) or (sregs.ec = '0') then cp_disabled := '1'; end if;
      when others => illegal_inst := '1';
      end case;
    when others =>	-- LDST
      case op3 is
      when LDD | ISTD => illegal_inst := rd(0);	-- trap if odd destination register
      when LD | LDUB | LDSTUB | LDUH | LDSB | LDSH | ST | STB | STH | SWAP =>
	null;
      when LDDA | STDA =>
	illegal_inst := i or rd(0); privileged_inst := not su;
      when LDA | LDUBA| LDSTUBA | LDUHA | LDSBA | LDSHA | STA | STBA | STHA |
	   SWAPA => 
	illegal_inst := i; privileged_inst := not su;
      when LDDF | STDF | LDF | LDFSR | STF | STFSR => 
	if FPEN then fp_disabled := not sregs.ef;
	else fp_disabled := '1'; end if;
      when STDFQ => 
	privileged_inst := not su; 
	if (not FPEN) or (sregs.ef = '0') then fp_disabled := '1'; end if;
      when STDCQ => 
	privileged_inst := not su;
	if (not CPEN) or (sregs.ec = '0') then cp_disabled := '1'; end if;
      when LDC | LDCSR | LDDC | STC | STCSR | STDC => 
	if (not CPEN) or (sregs.ec = '0') then cp_disabled := '1'; end if;
      when others => illegal_inst := '1';
      end case;
    end case;

-- branch address adder

    branch_address := (others => '0');
    if op = CALL then branch_address(31 downto 2) := de.inst(29 downto 0);
    else branch_address(31 downto 2) := de.inst(21) & de.inst(21) & de.inst(21) & 
            de.inst(21) & de.inst(21) & de.inst(21) & de.inst(21) & 
            de.inst(21) & de.inst(21 downto 0);
    end if;

-- pragma translate_off
    if not (is_x(branch_address) or is_x(de.pc)) then
-- pragma translate_on
      branch_address := branch_address + de.pc;	-- address adder (branch)
-- pragma translate_off
    else
      branch_address := (others => 'X');
    end if;
-- pragma translate_on

    fecomb.branch_address <= branch_address;

-- ICC pipeline and forwarding

    if (me.write_icc and not me.ctrl.annul) = '1' then icc := wrin.icc;
    elsif (wr.write_icc and not wr.ctrl.annul) = '1' then icc := wr.icc;
    else icc := sregs.icc; end if;

    br_icc := icc;

    if ((ex.write_icc and not ex.ctrl.annul) = '1') then
      icc := ex.icc;
      if not ICC_HOLD then br_icc := icc; end if;
    end if;

    write_icc := '0'; alu_cin := '0';

    case op is
    when FMT3 =>
      case op3 is
      when SUBCC | TSUBCC | TSUBCCTV => 
	write_icc := '1';
      when ADDCC | ANDCC | ORCC | XORCC | ANDNCC | ORNCC | XNORCC | MULSCC |
           TADDCC | TADDCCTV => 
	write_icc := '1';
      when UMULCC | SMULCC =>
	if MULTIPLIER = iterative then
	  if de.cnt /= "11" then write_icc := '1'; end if;
	end if;
	if MULTIPLIER = m32x32 then write_icc := '1'; end if;
      when ADDX | SUBX => 
	alu_cin := icc(0);
      when  ADDXCC | SUBXCC => 
	write_icc := '1'; alu_cin := icc(0);
      when others => null;
      end case;
    when others => null;
    end case;

    exin.write_icc <= write_icc; exin.alu_cin <= alu_cin;

-- BICC/TICC evaluation

    n := br_icc(3); z := br_icc(2); v := br_icc(1); c := br_icc(0);
    case cond(2 downto 0) is
    when "000" => bres := '0';				-- bn, ba
    when "001" => bres := z;      			-- be, bne
    when "010" => bres := z or (n xor v);             	-- ble, bg
    when "011" => bres := n xor v; 	            	-- bl, bge
    when "100" => bres := c or z;   	           	-- blue, bgu
    when "101" => bres := c;		              	-- bcs, bcc 
    when "110" => bres := n;		              	-- bneg, bpos
    when others => bres := v;		              	-- bvs. bvc   
    end case;
    branch_true := cond(3) xor bres;

-- FBFCC evaluation

    if FPEN then
      if FPIFTYPE = serial then
        if (fpu_reg.me.fpop = "10") and (me.ctrl.annul = '0') then 
	  fcc := fpu_reg.me.fcc;
        elsif (fpu_reg.wr.fpop = "10") and (wr.ctrl.annul = '0') then 
	  fcc := fpu_reg.wr.fcc;
        else fcc := fpu_reg.fsr.fcc; end if;
      else fcc := fpo.cc; end if;
      case cond(2 downto 0) is
      when "000" => fbres := '0';			-- fba, fbn
      when "001" => fbres := fcc(1) or fcc(0);
      when "010" => fbres := fcc(1) xor fcc(0);
      when "011" => fbres := fcc(0);
      when "100" => fbres := (not fcc(1)) and fcc(0);
      when "101" => fbres := fcc(1);
      when "110" => fbres := fcc(1) and not fcc(0);
      when others => fbres := fcc(1) and fcc(0);
      end case;
      fbranch_true := cond(3) xor fbres;

-- decode some FPU instruction types
      case opf is
      when FMOVS | FABSS | FNEGS => fpmov := '1';
      when FITOD | FSTOD | FSQRTD | FADDD | FSUBD | FMULD | FDIVD => 
	fpexin.dsz := '1';
      when others => null;
      end case;
    end if;

-- CBCCC evaluation

    if CPEN then
      ccc := cpo.cc;
      case cond(2 downto 0) is
      when "000" => cbres := '0';
      when "001" => cbres := ccc(1) or ccc(0);
      when "010" => cbres := ccc(1) xor ccc(0);
      when "011" => cbres := ccc(0);
      when "100" => cbres := (not ccc(1)) and ccc(0);
      when "101" => cbres := ccc(1);
      when "110" => cbres := ccc(1) and not ccc(0);
      when others => cbres := ccc(1) and ccc(0);
      end case;
      cbranch_true := cond(3) xor cbres;
    end if;

-- Alu operation generation

    aluop := ALU_NOP; alusel := ALU_RES_MISC; aluadd := '1'; 
    mulstep := '0'; mulinsn := '0';
    case op is
    when FMT2 =>
      case op2 is
      when SETHI => aluop := ALU_PASS2;
      when others =>
      end case;
    when FMT3 =>
      case op3 is
      when IADD | ADDX | ADDCC | ADDXCC | TADDCC | TADDCCTV | SAVE | RESTORE |
	   TICC | JMPL | RETT  => alusel := ALU_RES_ADD;
      when ISUB | SUBX | SUBCC | SUBXCC | TSUBCC | TSUBCCTV  => 
	alusel := ALU_RES_ADD; aluadd := '0';
      when MULSCC => alusel := ALU_RES_ADD; mulstep := '1';
      when UMUL | UMULCC => 
	if MULTIPLIER = iterative then
          case de.cnt is
	  when "00" => aluop := ALU_XOR; alusel := ALU_RES_MISC;
	  when "01" | "10" => alusel := ALU_RES_ADD; mulinsn := '1';
	  when others => alusel := ALU_RES_ADD;
	  end case;
	end if;
	if MULTIPLIER > iterative then mulinsn := '1'; end if;
      when SMUL | SMULCC => 
	if MULTIPLIER = iterative then
          case de.cnt is
	  when "00" => aluop := ALU_XOR; alusel := ALU_RES_MISC;
	  when "01" | "10" => alusel := ALU_RES_ADD; mulinsn := '1';
	  when others => alusel := ALU_RES_ADD; aluadd := '0';
	  end case;
	end if;
	if MULTIPLIER > iterative then mulinsn := '1'; end if;
      when UMAC | SMAC => 
	if MACEN then mulinsn := '1'; end if;
      when UDIV | UDIVCC | SDIV | SDIVCC => 
	if DIVIDER /= none then aluop := ALU_DIV; alusel := ALU_RES_LOGIC; end if;
      when IAND | ANDCC => aluop := ALU_AND; alusel := ALU_RES_LOGIC;
      when ANDN | ANDNCC => aluop := ALU_ANDN; alusel := ALU_RES_LOGIC;
      when IOR | ORCC  => aluop := ALU_OR; alusel := ALU_RES_LOGIC;
      when ORN | ORNCC  => aluop := ALU_ORN; alusel := ALU_RES_LOGIC;
      when IXNOR | XNORCC  => aluop := ALU_XNOR; alusel := ALU_RES_LOGIC;
      when XORCC | IXOR | WRPSR | WRWIM | WRTBR | WRY  => 
	aluop := ALU_XOR; alusel := ALU_RES_LOGIC;
      when RDPSR | RDTBR | RDWIM => aluop := ALU_PASS2;
      when RDY => aluop := ALU_RDY;
      when ISLL => aluop := ALU_SLL; alusel := ALU_RES_SHIFT;
      when ISRL => aluop := ALU_SRL; alusel := ALU_RES_SHIFT;
      when ISRA => aluop := ALU_SRA; alusel := ALU_RES_SHIFT;
      when FPOP1 | FPOP2 =>
	if ((FPIFTYPE = serial) and FPEN) then
          if de.cnt /= "00" then 
	    if opf(1) = '1' then rs1(0) := '1'; rs2(0) := '1'; end if;
	    if fpexin.dsz = '1' then rd(0) := '1'; end if;
	  end if;
	  if op3 = FPOP1 then fpexin.fpop := "01"; else fpexin.fpop := "10"; end if;
	  if fpmov = '1' then aluop := ALU_FOP; fpexin.fpop := "11";
	  else aluop := ALU_PASS2; end if;
	end if;
      when others =>
      end case;
    when others =>	-- LDST
      case de.cnt is
      when "00" =>
        alusel := ALU_RES_ADD;
	if FPEN then fpld := (op3(5) and not op3(2));
	else fpld := '0'; end if;
      when "01" =>
	if (op3(2) and not op3(3)) = '1' then  -- ST
	  rs1 := rd; rs1mod := '1';
	end if;
	case op3 is
	when LDD | LDDA | LDDC =>
          rd(0) := '1'; alusel := ALU_RES_ADD;
	when LDDF => 
          rd(0) := '1'; alusel := ALU_RES_ADD;
	  if FPEN then fpld := '1'; end if;
	when STFSR => if ((FPIFTYPE = serial) and FPEN) then aluop := ALU_FSR; end if;
	when SWAP | SWAPA | LDSTUB | LDSTUBA =>
          alusel := ALU_RES_ADD;
	when STF | STDF =>
	  if ((FPIFTYPE = serial) and FPEN) then
            aluop := ALU_PASS1; fpst := '1'; 
	  end if;
	when others =>
          aluop := ALU_PASS1;
	  if op3(2) = '1' then  -- ST
	    if op3(1 downto 0) = "01" then	-- store byte
	      aluop := ALU_STB;
	    elsif op3(1 downto 0) = "10" then	-- store halfword
	      aluop := ALU_STH;
	    end if;
          end if;
        end case;
      when "10" =>
        aluop := ALU_PASS1;
	rs1 := rd;  rs1mod := '1';
        if op3(2) = '1' then  -- ST
          if (op3(3) and not op3(1))= '1' then aluop := ALU_ONES;  -- LDSTUB/A
          elsif op3(3 downto 0) = "0111" then
	    rs1(0) := '1';  -- STD/F/A
	    if ((FPIFTYPE = serial) and FPEN) and (op3(5) = '1') then fpst := '1'; end if;
          end if;
        end if;
      when others =>
      end case;

    end case;

    exin.aluop <= aluop; exin.alusel <= alusel; exin.aluadd <= aluadd;
    exin.mulstep <= mulstep; exin.mulinsn <= mulinsn;

-- Alu operand select

    operand2_select := ALU_SIMM;

    case op is
    when FMT2 =>
      case op2 is
      when SETHI => operand2_select := ALU_SIMM;
      when others => operand2_select := ALU_RS2;
      end case;
    when FMT3 =>
      case op3 is
      when RDWIM | RDPSR | RDTBR => operand2_select := ALU_SIMM;
      when FPOP1 | FPOP2 => if ((FPIFTYPE = serial) and FPEN) then operand2_select := ALU_RS2; end if;
      when others =>
        if (de.inst(13) = '1') then operand2_select := ALU_SIMM;
	else operand2_select := ALU_RS2; end if;
      end case;
    when LDST => 
      if (de.inst(13) = '1') then operand2_select := ALU_SIMM;
      else operand2_select := ALU_RS2; end if;
    when others => operand2_select := ALU_RS2;
    end case;


-- CWP generation, pipelinig and forwarding
-- Also check for window underflow/overflow conditions

    if (op = FMT3) and ((op3 = RETT) or (op3 = RESTORE) or (op3 = SAVE)) then
      write_cwp := '1';
      if (op3 = SAVE) then
-- pragma translate_off
        if not is_x(de.cwp) then
-- pragma translate_on
	  if (not CWPOPT) and (de.cwp = CWPMIN) then cwp_new := CWPMAX;
          else cwp_new := de.cwp - 1 ; end if;
-- pragma translate_off
	end if;
-- pragma translate_on
      else
-- pragma translate_off
        if not is_x(de.cwp) then
-- pragma translate_on
	  if (not CWPOPT) and (de.cwp = CWPMAX) then cwp_new := CWPMIN;
          else cwp_new := de.cwp + 1; end if;
-- pragma translate_off
        end if;
-- pragma translate_on
      end if;

      if sregs.wim(conv_integer('0' & cwp_new)) = '1' then
	if op3 = SAVE then winovf_exception := '1';
	else winunf_exception := '1'; end if;
      end if;
    end if;
  
    exin.write_cwp <= write_cwp;
    exin.cwp <= cwp_new;

-- Immediate data generation

    immediate_data := (others => '0');
    case op is
    when FMT2 =>
      immediate_data := de.inst(21 downto 0) & "0000000000";
    when FMT3 =>
      case op3 is
      when RDPSR => immediate_data(31 downto 5) := std_logic_vector(IMPL) &
        std_logic_vector(VER) & icc & "000000" & sregs.ec & sregs.ef & 
	sregs.pil & su & sregs.ps & et;
	immediate_data(NWINLOG2-1 downto 0) := de.cwp;
      when RDTBR => immediate_data(31 downto 4) := sregs.tba & sregs.tt;
      when RDWIM => immediate_data(NWINDOWS-1 downto 0) := sregs.wim;
      when others =>
        immediate_data := de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) &
            de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) &
            de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) &
            de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) &
            de.inst(12 downto 0);
      end case;
    when others =>	-- LDST
      immediate_data := de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) &
          de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) &
          de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) &
          de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) & de.inst(12) &
          de.inst(12 downto 0);
    end case;

-- register read address generation

    if RS1OPT then
      if rs1mod = '1' then 
        read_addr1 := regdec(de.cwp, de.inst(29 downto 26) & rs1(0), (fpst or fpop)); 
      else
        read_addr1 := regdec(de.cwp, de.inst(18 downto 15) & rs1(0), (fpst or fpop)); 
      end if;
    else
      read_addr1 := regdec(de.cwp, rs1, (fpst or fpop)); 
    end if;
    read_addr2 := regdec(de.cwp, rs2, fpop); 


-- register write address generation

    write_reg := '0'; fsr_ld := '0';

    case op is
    when CALL =>
        write_reg := '1'; rd := "01111";    -- CALL saves PC in r[15] (%o7)
    when FMT2 => 
        if (op2 = SETHI) then write_reg := '1'; end if;
    when FMT3 =>
        case op3 is
	when UMUL | SMUL | UMULCC | SMULCC => 
	  if MULTIPLIER = none then write_reg := '1'; end if;
	  if MULTIPLIER = m32x32 then write_reg := '1'; end if;
	  if MULTIPLIER = iterative then
	    if de.cnt = "10" then write_reg := '1'; end if;
	  end if;
	when UDIV | SDIV | UDIVCC | SDIVCC => 
	  if DIVIDER /= none then write_reg := '0'; else write_reg := '1'; end if;
        when RETT | WRPSR | WRY | WRWIM | WRTBR | TICC | FLUSH => null;
	when FPOP1 | FPOP2 => null;
	when CPOP1 | CPOP2 => null;
        when others => write_reg := '1';
        end case;
      when LDST =>
        ctrl.ld := not op3(2);
        if (op3(2) = '0') and 
	  not ((CPEN or (FPIFTYPE = parallel)) and (op3(5) = '1')) 
        then write_reg := '1'; end if;
        case op3 is
        when SWAP | SWAPA | LDSTUB | LDSTUBA =>
	  if de.cnt = "00" then write_reg := '1'; end if;
	when LDFSR => if ((FPIFTYPE = serial) and FPEN) then write_reg := '0';  fsr_ld := '1'; end if;
        when others => null;
        end case;
      when others => null;
    end case;

    if (rd = "00000") and not (((FPIFTYPE = serial) and FPEN) and (fpld = '1')) then
      write_reg := '0';
    end if;

    ctrl.rd := regdec(cwp_new, rd, (fpld or fpop)); 
    if RDOPT then chkrd := regdec(de.cwp, rd, (fpld or fpop)); 
    else chkrd := ctrl.rd; end if;

-- LD/BICC/TICC delay interlock generation

    ldcheck1 := '0'; ldcheck2 := '0'; ldcheck3 := '0'; ldlock := '0';
    ldchkex := '1'; ldchkme := '1'; bicc_hold := '0'; icc_check := '0';
    fsr_check := '0'; fsr_ld_check := '0'; fsr_lock := '0';

    if (de.annul = '0') then
      case op is
      when FMT2 =>
	if (op2 = BICC) and (cond(2 downto 0) /= "000") then 
	  icc_check := '1';
	end if;
      when FMT3 =>
        ldcheck1 := '1'; ldcheck2 := not i;
        case op3 is
	when TICC =>
	  if (cond(2 downto 0) /= "000") then icc_check := '1'; end if;
        when RDY | RDWIM | RDTBR => 
          ldcheck1 := '0'; ldcheck2 := '0';
        when RDPSR => 
          ldcheck1 := '0'; ldcheck2 := '0'; 
	  if MULTIPLIER = m32x32 then icc_check := '1'; end if;
	when ADDX | ADDXCC | SUBX | SUBXCC =>
	  if MULTIPLIER = m32x32 then icc_check := '1'; end if;
	when UMUL | SMUL | UMULCC | SMULCC =>
	  if MULTIPLIER = iterative then
            ldcheck1 := '0'; ldcheck2 := '0';
	    if (de.cnt = "00") then ldcheck1 := '1'; end if;
            if (de.cnt = "01") then ldcheck2 := not i; end if;
	  end if;
	when FPOP1 | FPOP2 =>
	  if ((FPIFTYPE = serial) and FPEN) then
            ldcheck1 := '0'; ldcheck2 := '0';
	    case opf is
	    when FITOS | FITOD | FSTOI | FDTOI | FSTOD | FDTOS | FMOVS |
	         FNEGS | FABSS | FSQRTS | FSQRTD =>
              ldcheck2 := '1';
	    when others => ldcheck1 := '1'; ldcheck2 := '1';
	    end case;
	    if de.cnt /= "00" then ldchkex := '0'; end if;
	    fsr_ld_check := '1';
	  end if;
        when others => 
        end case;
      when LDST =>
        ldcheck1 := '1'; ldchkex := '0';
	case de.cnt is
	when "00" => -- check store data dependency if 2-cycle load delay
          if (LDDELAY = 2) and (op3(2) = '1') and not (((FPIFTYPE = serial) and FPEN) and (op3 = STFSR)) 
	  then ldcheck3 := '1'; end if; 
          ldcheck2 := not i; ldchkex := '1';
	when "01" => ldcheck2 := not i;
	when others => ldchkme := '0';
        end case;
	if ((FPIFTYPE = serial) and FPEN) and ((op3 = LDFSR) or (op3 = STFSR)) then 
	  fsr_check := '1';
	  if (op3 = STFSR) then fsr_ld_check := '1'; end if;
	end if;
      when others => null;
      end case;
    end if;

-- MAC has two-cycle latency, check for data-dependecies
    if MACEN then
      if ((ex.mulinsn and ex.ctrl.inst(24) and ldchkex and not ex.ctrl.annul) = '1') and
        (((ldcheck1 = '1') and (ex.ctrl.rd = read_addr1)) or
         ((ldcheck2 = '1') and (ex.ctrl.rd = read_addr2)) or
         ((ldcheck3 = '1') and (ex.ctrl.rd = chkrd)))
      then ldlock := '1'; end if;
    end if;

    if MACEN or (MULTIPLIER = m32x32) then
      bicc_hold := icc_check and ex.write_icc and ex.mulinsn and not ex.ctrl.annul;
    end if;
    if ICC_HOLD then
      bicc_hold := bicc_hold or (icc_check and ex.write_icc and not ex.ctrl.annul);
    end if;

    if ((ex.ctrl.ld and ex.write_reg and ldchkex and not ex.ctrl.annul) = '1') and
        (((ldcheck1 = '1') and (ex.ctrl.rd = read_addr1)) or
         ((ldcheck2 = '1') and (ex.ctrl.rd = read_addr2)) or
         ((ldcheck3 = '1') and (ex.ctrl.rd = chkrd)))
    then ldlock := '1'; end if;

    if ((me.ctrl.ld and me.write_reg and ldchkme and not me.ctrl.annul) = '1') and
      ((LDDELAY = 2) or ((fsr_ld_check and not fsr_check) = '1')) and
         (((ldcheck1 = '1') and (me.ctrl.rd = read_addr1)) or
          ((ldcheck2 = '1') and (me.ctrl.rd = read_addr2)))
    then ldlock := '1'; end if;

    if ((FPIFTYPE = serial) and FPEN) then
      if (fsr_check = '1') then
        fsr_lock := ((xorv(fpu_reg.ex.fpop) and not ex.ctrl.annul) or 
		     (xorv(fpu_reg.me.fpop) and not me.ctrl.annul) or
                     (xorv(fpu_reg.wr.fpop) and not wr.ctrl.annul));
      end if;
      if fsr_ld_check = '1' then
	fsr_lock := fsr_lock or (fpu_reg.ex.ldfsr and not ex.ctrl.annul)
	                     or (fpu_reg.me.ldfsr and not me.ctrl.annul)
	                     or (fpu_reg.wr.ldfsr and not wr.ctrl.annul);
      end if;
    end if;

    ldlock := ldlock or bicc_hold or fsr_lock; 
    cpldlock := ldlock; fpldlock := ldlock;
    if CPEN then 
      if FPIFTYPE = parallel then cpldlock := cpldlock or fpo.ldlock; end if;
      ldlock := ldlock or cpo.ldlock; 
    end if;
    if FPIFTYPE = parallel then 
      if CPEN then fpldlock := fpldlock or cpo.ldlock; end if;
      ldlock := ldlock or fpo.ldlock;
    end if;

-- data forwarding detection. Forward data if destination and source
-- registers are equal and destination register will be written.

    rs1data := rfo.data1(31 downto 0); ldbp1 := '0'; 
    if (rs1 = "00000") and not (((FPIFTYPE = serial) and FPEN) and ((fpop or fpst) = '1')) then
      rs1data := (others => '0');
    elsif ldcheck1 = '1' then
      if ((ex.write_reg and ldchkex and not ex.ctrl.annul) = '1') and 
	  (read_addr1 = ex.ctrl.rd) 
      then
        rs1data := ex.result;
      else
	if ((me.write_reg and ldchkme and not me.ctrl.annul) = '1') and (read_addr1 = me.ctrl.rd) then
          rs1data := mein.bpresult;
          if LDDELAY = 1 then ldbp1 := me.ctrl.ld; end if;
        elsif ((wr.write_reg and not wr.ctrl.annul) = '1') and (read_addr1 = wr.ctrl.rd) then
          rs1data := wr.result; 
        else rfenable1 := '1'; end if;
      end if;
    end if;

    rs2data := rfo.data2(31 downto 0); ldbp2 := '0'; 
    if (operand2_select = ALU_SIMM) then
      rs2data := immediate_data;
    elsif (rs2 = "00000") and not (((FPIFTYPE = serial) and FPEN) and (fpop = '1')) then
      rs2data := (others => '0');
    elsif ldcheck2 = '1' then
      if ((ex.write_reg and ldchkex and not ex.ctrl.annul) = '1') and (read_addr2 = ex.ctrl.rd) then
        rs2data := ex.result;
      else
	if ((me.write_reg and ldchkme and not me.ctrl.annul) = '1') and (read_addr2 = me.ctrl.rd) then
          rs2data := mein.bpresult;
          if LDDELAY = 1 then ldbp2 := me.ctrl.ld; end if;
        elsif ((wr.write_reg and not wr.ctrl.annul) = '1') and (read_addr2 = wr.ctrl.rd) then
          rs2data := wr.result;
        else rfenable2 := '1'; end if;
      end if;
    end if;

-- multiply operand generation

    if (ex.write_y and not ex.ctrl.annul) = '1' then
      y0 := mein.y(0);
    elsif (me.write_y and not (me.ctrl.annul or me.ctrl.trap)) = '1' then
      y0 := me.my(0);
    else
      y0 := wr.y(0);
    end if;

    ymsb := '-';

-- mul/div unit

    divi.y   <= (wr.y(31) and op3(0)) & wr.y;
    divstart := '0'; mulstart := '0';
    case op is
    when FMT3 =>
      case op3 is
      when MULSCC =>
	ymsb := rs1data(0); rs1data := (icc(3) xor icc(1)) & rs1data(31 downto 1);
        if y0 = '0' then 
	  rs2data := (others => '0'); rfenable2 := '0'; ldbp2 := '0';
	end if;
      when UMUL | SMUL | UMULCC | SMULCC =>
	if MULTIPLIER = iterative then
	  case de.cnt is
	  when "00" => 
	    rs2data := (others => '0'); ymsb := rs1data(0); rfenable2 := '0';
	  when "01" | "10" =>
	    ymsb := ex.result(0);
            rs1data := (ex.micc(3) xor ex.micc(1)) & ex.result(31 downto 1);
            if (mein.y(0) = '0') or (de.cnt = "10") then
	      rs2data := (others => '0'); ldbp2 := '0'; rfenable2 := '0';
	    end if;
	  when others => 
            if (op3 = UMUL) or (op3 = UMULCC) then
	      rs2data := ex.result; rfenable2 := '1';
	      if rfo.data2(31) = '0' then
		rs1data := (others => '0');
	      end if;
	    else
	      rs1data := ex.result; rfenable1 := '1';
	      if rfo.data1(31) = '0' then
		rs2data := (others => '0'); rfenable2 := '0';
	      end if;
	    end if;
	  end case;
	end if;
      when others => null;
      end case;
    when others => null;
    end case;

    exin.ldbp1 <= ldbp1; exin.ldbp2 <= ldbp2;

-- PC generation

    branch := '0'; annul_next := '0'; annul_current := '0';
    inull := not Rst; hold_pc := '0'; ticc_exception := '0';
    fpop := '0'; fpld := '0';
    if ((ldlock or de.annul) = '0') then
      case op is
      when CALL =>
        branch := '1';
	if mein.inull = '1' then 
	  hold_pc := '1'; annul_current := '1';
	end if;
      when FMT2 =>
        if (op2 = BICC) or (FPEN and (op2 = FBFCC)) or (CPEN and (op2 = CBCCC)) then
          if (FPEN and (op2 = FBFCC)) then 
	    branch := fbranch_true;
	    if (FPIFTYPE = parallel) and (fpo.ccv /= '1') then 
	      hold_pc := '1'; annul_current := '1';
	    end if;
          elsif (CPEN and (op2 = CBCCC)) then 
	    branch := cbranch_true;
	    if cpo.ccv /= '1' then hold_pc := '1'; annul_current := '1'; end if;
	  else branch := branch_true; end if;
	  if hold_pc = '0' then
  	    if (branch = '1') then
              if (cond = BA) and (annul = '1') then annul_next := '1'; end if;
            else annul_next := annul; end if;
	    if mein.inull = '1' then -- contention with JMPL
	      hold_pc := '1'; annul_current := '1'; annul_next := '0';
	    end if;
	  end if;
        end if;
      when FMT3 =>
        case op3 is
	when FPOP1 | FPOP2 =>
	  if ((FPIFTYPE = serial) and FPEN) then
            case de.cnt is
            when "00" =>
	      if (opf(1) or fpexin.dsz) = '1' then 
		hold_pc := '1'; pv := '0'; cnt := "01";
	      end if;
	      if (opf(1) or fpmov) = '0' then fpop := holdn; end if;
	      if op3 = FPOP1 then write_reg := not (opf(1) and not fpexin.dsz); end if;
            when others =>
	      if op3 = FPOP1 then write_reg := '1'; end if;
	      fpop := opf(1) and holdn; cnt := "00";
	    end case;
	  end if;
        when UMUL | SMUL | UMULCC | SMULCC =>
	  if MULTIPLIER = iterative then
            case de.cnt is
            when "00" =>
 	      cnt := "01"; hold_pc := '1'; mulcnt := (others => '0'); pv := '0';
            when "01" =>
 	      hold_pc := '1'; pv := '0'; cnt := "01"; mulcnt := mulcnt + 1;
 	      if (de.mulcnt = "11111") then cnt := "10"; end if;
            when "10" =>
 	      cnt := "11"; pv := '0'; hold_pc := '1';
            when "11" =>
 	      cnt := "00"; 
            when others => null;
	    end case;
	  end if;
	  if (MULTIPLIER > iterative) and (MULTIPLIER /= m32x32) then
            case de.cnt is
            when "00" =>
 	      cnt := "01"; hold_pc := '1'; mulcnt := (others => '0'); pv := '0';
	      mulstart := '1';
            when "01" =>
 	      if mulo.ready = '1' then cnt := "00"; 
              else cnt := "01"; pv := '0'; hold_pc := '1'; end if;
            when others => null;
	    end case;
	  end if;
        when UDIV | SDIV | UDIVCC | SDIVCC =>
	  if DIVIDER /= none then
            case de.cnt is
            when "00" =>
 	      cnt := "01"; hold_pc := '1'; mulcnt := (others => '0'); pv := '0';
	      divstart := '1';
            when "01" =>
 	      if divo.ready = '1' then cnt := "00"; 
              else cnt := "01"; pv := '0'; hold_pc := '1'; end if;
            when others => null;
	    end case;
	  end if;
        when TICC =>
	  if branch_true = '1' then ticc_exception := '1'; end if;
        when RETT =>
          ctrl.rett := '1'; su := sregs.ps; 
        when others => null;
        end case;
      when LDST =>
        case de.cnt is
        when "00" =>
          if (op3(2) = '1') or (op3(1 downto 0) = "11") then -- ST/LDST/SWAP/LDD
 	    cnt := "01"; hold_pc := '1'; pv := '0';
          end if;
        when "01" =>
          if (op3(2 downto 0) = "111") or (op3(3 downto 0) = "1101") or
             ((CPEN or FPEN) and ((op3(5) & op3(2 downto 0)) = "1110"))
	  then	-- LDD/STD/LDSTUB/SWAP
 	    cnt := "10"; pv := '0'; hold_pc := '1';
	  else
 	    cnt := "00";
          end if;
        when "10" =>
 	  cnt := "00";
        when others => null;
	end case;
      when others => null;
      end case;
    end if;

    muli.start  <= mulstart;
    divi.start  <= divstart;

-- instruction watchpoints

    watchpoint_exc := '0';
    for i in 0 to WATCHPOINTS-1 loop
      if ((tr(i).exec and not de.annul) = '1') then
         if (((tr(i).addr xor de.pc(31 downto 2)) and tr(i).mask) = Zero32(31 downto 2)) then
           watchpoint_exc := '1';
	 end if;
      end if;
    end loop;

    if DEBUG_UNIT then
      if  ((iui.debug.dsuen and iui.debug.bwatch and not de.annul) = '1') then
        watchpoint_exc := de.pv and (watchpoint_exc or iui.debug.dbreak or de.step);
      end if;
    end if;

--  prioritise traps

    ctrl.trap := de.mexc or privileged_inst or illegal_inst or fp_disabled or
	cp_disabled or ticc_exception or winunf_exception or
	winovf_exception or fp_exception or watchpoint_exc;

    if de.mexc = '1' then ctrl.tt := IAEX_TT;
    elsif privileged_inst = '1' then ctrl.tt := PRIV_TT; 
    elsif illegal_inst = '1' then ctrl.tt := IINST_TT;
    elsif fp_disabled = '1' then ctrl.tt := FPDIS_TT;
    elsif cp_disabled = '1' then ctrl.tt := CPDIS_TT;
    elsif watchpoint_exc = '1' then ctrl.tt := WATCH_TT;
    elsif winovf_exception = '1' then ctrl.tt := WINOF_TT;
    elsif winunf_exception = '1' then ctrl.tt := WINUF_TT;
    elsif fp_exception = '1' then ctrl.tt := FPEXC_TT;
    elsif ticc_exception = '1' then ctrl.tt := TICC_TT;
    end if;


    hold_pc := (hold_pc or ldlock) and not wr.annul_all;

    if hold_pc = '1' then dein.pc <= de.pc;
    else dein.pc <= fe.pc; end if;

    annul_current_cp := annul_current;
    annul_current := (annul_current or ldlock or wr.annul_all);
    ctrl.annul := de.annul or wr.annul_all or annul_current;
    pv := pv and not ((mein.inull and not hold_pc) or wr.annul_all);
    annul_next := (mein.inull and not hold_pc) or annul_next or wr.annul_all
                  or (ldlock and de.annul);                                    
    if (annul_next = '1') or (rst = '0') then
      cnt := (others => '0'); mulcnt := (others => '0');
    end if;

    if DEBUG_UNIT then
      step := iui.debug.step and pv and not de.annul;
    end if;
    fecomb.hold_pc <= hold_pc;
    fecomb.branch <= branch;
    dein.annul <= annul_next;
    dein.cnt <= cnt;
    dein.mulcnt <= mulcnt;
    dein.step <= step;
    dein.pv <= pv;
    -- pv means that the corresponding pc can be save on a trap
    ctrl.pv := de.pv and 
		not ((de.annul and not de.pv) or wr.annul_all or annul_current);
    inull := inull or mein.inull or hold_pc or wr.annul_all;

    ici.nullify <= inull;
    ici.su <= su;
    exin.ctrl <= ctrl;
    exin.write_reg <= write_reg;

-- latch next cwp

    if wr.trapping = '1' then
      dein.cwp <= sregsin.cwp;
    elsif (write_cwp and not ctrl.annul) = '1' then
      dein.cwp <= cwp_new;
    elsif (ex.write_cwp and not ex.ctrl.annul) = '1' then
      dein.cwp <= ex.cwp;
    elsif (me.write_cwp and not me.ctrl.annul) = '1' then
      dein.cwp <= me.cwp;
    elsif (wr.write_cwp and not wr.ctrl.annul) = '1' then
      dein.cwp <= wr.cwp;
    else
      dein.cwp <= sregs.cwp;
    end if;


-- y-register write select and forwarding

    rst_mey := '0';

    case op is
    when FMT3 =>
      case op3 is
      when MULSCC => write_y := '1';
      when WRY => if rd = "00000" then write_y := '1'; end if;
      when  UMAC | SMAC  =>
	if MACEN then write_y := '1'; end if;
      when  UMUL | SMUL | UMULCC | SMULCC =>
	if MULTIPLIER = iterative then
          if de.cnt = "00" then rst_mey := '1'; end if;
	  if de.cnt = "11" then write_y := '1'; end if;
	end if;
	if MULTIPLIER = m32x32 then write_y := '1'; end if;
      when others => null;
      end case;
    when others => null;
    end case;

-- debug unit diagnostic regfile read
    if DEBUG_UNIT and (dsur.dmode and iui.debug.denable) = '1' then
      read_addr1 := iui.debug.daddr(RABITS+1 downto 2); rfenable1 := '1';
    end if;

    exin.write_y <= write_y;
    exin.rst_mey <= rst_mey;
    exin.rs1data <= rs1data;
    exin.rs2data <= rs2data;
    exin.ymsb <= ymsb;
    rfi.rd1addr <= read_addr1; rfi.rd2addr <= read_addr2;

-- CP/FPU interface

    if (FPIFTYPE = serial) then
      fpu_regin.fpop <= fpop and (not fpu_reg.fpld) and not ctrl.annul;
      fpexin.ldfsr := fsr_ld;
      fpu_regin.ex <= fpexin;
    end if;

    if CPEN then
      cpi.dannul <= annul_current_cp or cpldlock or wr.annul_all or de.annul;
      cpi.dtrap  <= ctrl.trap;
    end if;

    if FPIFTYPE = parallel then
      fpi.dannul <= annul_current_cp or fpldlock or wr.annul_all or de.annul;
      fpi.dtrap  <= ctrl.trap;
      fpi.fdata  <= ico.data;
      fpi.frdy <= (not ico.mds) or (holdn and not hold_pc);            
    end if;


    if RF_LOWPOW = false then rfenable1 := '1'; rfenable2 := '1';  end if;
    rfi.ren1 <= rfenable1; rfi.ren2 <= rfenable2;

  end process;

-------------------------------------------------------------------------------
-- execute stage
-------------------------------------------------------------------------------


  execute_stage : process(rst, de, ex, me, wr, wrin, sregs, fpu_reg, fpu_regin, 
			  fpo, cpo, fpuo, mulo, divo, tr, iui, dsur, sum32)

  variable op     : std_logic_vector(1 downto 0);
  variable op3    : std_logic_vector(5 downto 0);
  variable opf    : std_logic_vector(8 downto 0);
  variable rs1    : std_logic_vector(4 downto 0);
  variable inull, jump, link_pc : std_logic;
  variable dcache_write : std_logic;	-- Load or store cycle
  variable memory_load : std_logic;
  variable signed           : std_logic;
  variable enaddr           : std_logic;
  variable force_a2         : std_logic;     -- force A(2) in second LDD cycle
  variable addr_misal       : std_logic;     -- misaligned address (JMPL/RETT)
  variable ld_size          : std_logic_vector(1 downto 0); -- Load size
  variable read             : std_logic;
  variable su      : std_logic;			-- Local supervisor bit
  variable asi              : std_logic_vector(7 downto 0); -- Local ASI
  variable ctrl : pipeline_control_type;
  variable res, y : std_logic_vector(31 downto 0);
  variable icc, licc, micc : std_logic_vector(3 downto 0);
  variable addout : std_logic_vector(31 downto 0);
  variable shiftout : std_logic_vector(31 downto 0);
  variable logicout : std_logic_vector(31 downto 0);
  variable miscout : std_logic_vector(31 downto 0);
  variable edata : std_logic_vector(31 downto 0);
  variable aluresult : std_logic_vector(31 downto 0);
  variable eaddress : std_logic_vector(31 downto 0);
  variable nexty : std_logic_vector(31 downto 0);
  variable aluin1, aluin2 : std_logic_vector(31 downto 0);
  variable shiftin : std_logic_vector(63 downto 0);
  variable shiftcnt : std_logic_vector(4 downto 0);
  variable ymsb : std_logic;		-- next msb of Y during MUL
  variable write_reg, write_icc, write_y : std_logic;
  variable lock : std_logic;
  variable dsu_cache : std_logic;
  variable fpmein : fpu_ctrl2_type;
  variable mulop1, mulop2 : std_logic_vector(32 downto 0);
  variable wpi : integer range 0 to 3;  -- watchpoint index
  variable addin2 : std_logic_vector(31 downto 0);
  variable cin : std_logic;

  begin

-- op-code decoding

    op    := ex.ctrl.inst(31 downto 30);
    op3   := ex.ctrl.inst(24 downto 19);
    opf   := ex.ctrl.inst(13 downto 5);
    rs1   := ex.ctrl.inst(18 downto 14);

-- common initialisation

    ctrl := ex.ctrl; memory_load := '0';
    ctrl.annul := ctrl.annul or wr.annul_all;
    read := not op3(2);
    dcache_write := '0'; enaddr := '0'; wpi := 0;
    ld_size := LDWORD; signed := '0'; addr_misal := '0'; lock := '0';
    write_reg := ex.write_reg;
    write_icc := ex.write_icc;
    write_y := ex.write_y;
    fpmein.fpop := fpu_reg.ex.fpop;
    fpmein.dsz := fpu_reg.ex.dsz;
    fpmein.ldfsr := fpu_reg.ex.ldfsr;
    fpmein.cexc := fpuo.excep(4 downto 0);
    fpmein.fcc := fpuo.ConditionCodes;
    muli.mac <= op3(5);
    dsu_cache := '0';

-- load/store size decoding

    case op is
    when LDST =>
      case op3 is
      when LDUB | LDUBA => ld_size := LDBYTE;
      when LDSTUB | LDSTUBA => ld_size := LDBYTE; lock := '1';
      when LDUH | LDUHA => ld_size := LDHALF;
      when LDSB | LDSBA => ld_size := LDBYTE; signed := '1';
      when LDSH | LDSHA => ld_size := LDHALF; signed := '1';
      when LD | LDA | LDF | LDC => ld_size := LDWORD;
      when SWAP | SWAPA => ld_size := LDWORD; lock := '1';
      when LDD | LDDA | LDDF | LDDC => ld_size := LDDBL;
      when STB | STBA => ld_size := LDBYTE;
      when STH | STHA => ld_size := LDHALF;
      when ST | STA | STF => ld_size := LDWORD;
      when ISTD | STDA => ld_size := LDDBL;
      when STDF | STDFQ => if FPEN then ld_size := LDDBL; end if;
      when STDC | STDCQ => if CPEN then ld_size := LDDBL; end if;
      when others => null;
      end case;
    when others => null;
    end case;

    link_pc := '0'; jump:= '0'; inull :='0'; force_a2 := '0';

-- load/store control decoding

    if (ctrl.annul = '0') then
      case op is
      when CALL =>
        link_pc := '1';
      when FMT3 =>
        case op3 is
        when JMPL =>
          jump := '1'; link_pc := '1'; 
	  inull := me.ctrl.annul or not me.jmpl_rett;
        when RETT =>
          jump := '1'; inull := me.ctrl.annul or not me.jmpl_rett;
        when others => null;
        end case;
      when LDST =>
	if (ctrl.trap or (wrin.ctrl.trap and not wrin.ctrl.annul)) = '0' then
          case ex.ctrl.cnt is
	  when "00" =>
            memory_load := op3(3) or not op3(2);	-- LD/LDST/SWAP
	    read := memory_load; enaddr := '1';
          when "01" =>
            memory_load := not op3(2);	-- LDD
	    enaddr := memory_load; 
	    force_a2 := memory_load;
            if op3(3 downto 2) = "01" then		-- ST/STD
	      dcache_write := '1';
            end if;
            if op3(3 downto 2) = "11" then		-- LDST/SWAP
	      enaddr := '1';
            end if;
          when "10" => 					-- STD/LDST/SWAP
            dcache_write := '1';
          when others => null;
	  end case;
	end if;
      when others => null;
      end case;
    end if;

-- supervisor bit generation

    if ((wr.ctrl.rett and not wr.ctrl.annul) = '1') then su := sregs.ps;
    else su := sregs.s; end if;
    if su = '1' then asi := "00001011"; else asi := "00001010"; end if;
    if (op3(4) = '1') and ((op3(5) = '0') or not CPEN) then
      asi := ex.ctrl.inst(12 downto 5);
    end if;


-- load data bypass in case (LDDELAY = 1)

    aluin1 := ex.rs1data; aluin2 := ex.rs2data; ymsb := ex.ymsb;

    if LDDELAY = 1 then
      if ex.ldbp1 = '1' then aluin1 := wr.result; ymsb := wr.result(0); end if;
      if ex.ldbp2 = '1' then aluin2 := wr.result; end if;
    end if;

-- bypassed operands to multiplier

    muli.signed <= op3(0); divi.signed <= op3(0);
    mulop1 := (aluin1(31) and op3(0))  & aluin1;
    mulop2 := (aluin2(31) and op3(0))  & aluin2;
    if (ex.mulinsn = '0') and not INFER_MULT then  -- try to minimise power
      mulop1 := (others => '0'); mulop2 := (others => '0');
    end if;
    muli.op1 <= mulop1; muli.op2 <= mulop2;

    divi.op1 <= (aluin1(31) and op3(0)) & aluin1;
    divi.op2 <= (aluin2(31) and op3(0)) & aluin2;

-- ALU add/sub

    icc := "0000";

-- pragma translate_off
    if not (is_x(aluin1) or is_x(aluin2)) then
-- pragma translate_on
      cin := ex.alu_cin; addin2 := aluin2;
      if ex.aluadd = '0' then
      addin2 := not aluin2; cin := not cin;
      end if;
--      addout := aluin1 + addin2 + cin;
      if FASTADD then addout := sum32;
      else
        if ex.aluadd = '0' then addout := aluin1 - aluin2 - ex.alu_cin;
        else addout := aluin1 + aluin2 + ex.alu_cin; end if;
      end if;
-- pragma translate_off
    end if;
-- pragma translate_on

    add32in1 <= aluin1;
    add32in2 <= addin2;
    add32cin <= cin;

-- fast address adders if enabled

    if FASTJUMP then
-- pragma translate_off
      if not (is_x(aluin1) or is_x(aluin2)) then
-- pragma translate_on
        fecomb.jump_address <= aluin1(31 downto PCLOW) + aluin2(31 downto PCLOW);
	if (aluin1(1 downto 0) + aluin2(1 downto 0)) = "00" then
	  addr_misal := '0';
	else
	  addr_misal := '1';
	end if;
-- pragma translate_off
      else
        fecomb.jump_address <= (others => 'X');
      end if;
-- pragma translate_on
    else
      fecomb.jump_address(31 downto PCLOW) <= addout(31 downto PCLOW);
      if addout(1 downto 0) = "00" then
	addr_misal := '0';
      else
	addr_misal := '1';
      end if;
    end if;

    res := (others => '-');

-- alu ops which set icc

    case ex.aluop is
    when ALU_OR    => logicout := aluin1 or aluin2;
    when ALU_ORN   => logicout := aluin1 or not aluin2;
    when ALU_AND   => logicout := aluin1 and aluin2;
    when ALU_ANDN  => logicout := aluin1 and not aluin2;
    when ALU_XOR   => logicout := aluin1 xor aluin2;
    when ALU_XNOR  => logicout := aluin1 xor not aluin2;
    when ALU_DIV   => 
      if DIVIDER /= none then logicout := aluin2;
      else logicout := (others => '-'); end if;
    when others    => logicout := (others => '-');
    end case;

-- generate condition codes

    if (ex.alusel(1) = '0') then
      res := addout;
      if ex.aluadd = '0' then
        icc(0) := ((not aluin1(31)) and aluin2(31)) or 	-- Carry
		 (addout(31) and ((not aluin1(31)) or aluin2(31)));
        icc(1) := (aluin1(31) and (not aluin2(31)) and not addout(31)) or 	-- Overflow
                 (addout(31) and (not aluin1(31)) and aluin2(31));
      else
        icc(0) := (aluin1(31) and aluin2(31)) or 	-- Carry
		 ((not addout(31)) and (aluin1(31) or aluin2(31)));
        icc(1) := (aluin1(31) and aluin2(31) and not addout(31)) or 	-- Overflow
		 (addout(31) and (not aluin1(31)) and (not aluin2(31)));
      end if;
    else
      res := logicout;
      icc(1 downto 0) := "00";
    end if;

    if res = zero32 then	-- Zero
      icc(2) := '1';
    else
      icc(2) := '0';
    end if;
    icc(3) := res(31);		-- Negative

-- select Y

    if (me.write_y and not (me.ctrl.annul or me.ctrl.trap)) = '1' 
    then y := me.my; else y := wr.y; end if;

-- alu ops which dont set icc

    miscout := (others => '-'); edata := (others => '-');
    case ex.aluop is
    when ALU_STB   => edata := aluin1(7 downto 0) & aluin1(7 downto 0) &
			     aluin1(7 downto 0) & aluin1(7 downto 0);
		      miscout := edata;
    when ALU_STH   => edata := aluin1(15 downto 0) & aluin1(15 downto 0);
		      miscout := edata;
    when ALU_PASS1 => miscout := aluin1; edata := aluin1;
    when ALU_PASS2 => miscout := aluin2;
    when ALU_ONES  => miscout := (others => '1'); edata := (others => '1');
    when ALU_RDY  => 
      miscout := y; 

      if (WATCHPOINTS > 0) and (rs1(4 downto 3) = "11") then
	wpi := conv_integer(unsigned(rs1(2 downto 1)));
	if rs1(0) = '0' then miscout := tr(wpi).addr & '0' & tr(wpi).exec;
	else miscout := tr(wpi).mask & tr(wpi).load & tr(wpi).store; end if;
      end if;
    when ALU_FSR  => 
      if ((FPIFTYPE = serial) and FPEN) then
        edata := fpu_reg.fsr.rd & "00" & fpu_reg.fsr.tem & "000" & 
	std_logic_vector(FPUVER) & fpu_reg.fsr.ftt & "00" & fpu_reg.fsr.fcc &
	fpu_reg.fsr.aexc & fpu_reg.fsr.cexc;
	miscout := edata;
      end if;
    when ALU_FOP   => 
      if ((FPIFTYPE = serial) and FPEN) then
	miscout := aluin2;
	case opf(3 downto 2) is
	when "01" => miscout(31) := not miscout(31);
	when "10" => miscout(31) := '0';
	when others => null;
	end case;
      end if;
    when others => null;
    end case;

-- shifter

    shiftin := zero32 & aluin1;
    shiftcnt := aluin2(4 downto 0);

    if ex.aluop = ALU_SLL then
      shiftin(31 downto 0) := zero32;
      shiftin(63 downto 31) := '0' & aluin1;
      shiftcnt := not shiftcnt;
    elsif ex.aluop = ALU_SRA then
      if aluin1(31) = '1' then
	shiftin(63 downto 32) := (others => '1');
      else
	shiftin(63 downto 32) := zero32;
      end if;
    end if;
    if shiftcnt (4) = '1' then
      shiftin(47 downto 0) := shiftin(63 downto 16);
    end if;
    if shiftcnt (3) = '1' then
      shiftin(39 downto 0) := shiftin(47 downto 8);
    end if;
    if shiftcnt (2) = '1' then
      shiftin(35 downto 0) := shiftin(39 downto 4);
    end if;
    if shiftcnt (1) = '1' then
      shiftin(33 downto 0) := shiftin(35 downto 2);
    end if;
    if shiftcnt (0) = '1' then
      shiftin(31 downto 0) := shiftin(32 downto 1);
    end if;
    shiftout := shiftin(31 downto 0);

-- generate overflow for tagged add/sub

    case op is 
    when FMT3 =>
      case op3 is
      when TADDCC | TADDCCTV | TSUBCC | TSUBCCTV =>
        icc(1) := aluin1(0) or aluin1(1) or aluin2(0) or aluin2(1) or icc(1);
      when others => null;
      end case;
    when others => null;
    end case;

-- select alu output

    aluresult := (others => '0');
    if link_pc = '1' then
      aluresult := ex.ctrl.pc(31 downto 2) & "00";  -- save PC during jmpl
    else
      case ex.alusel is
      when ALU_RES_ADD => aluresult := addout;
      when ALU_RES_SHIFT => aluresult := shiftout;
      when ALU_RES_LOGIC => aluresult := logicout;
      when others => aluresult := miscout;
      end case;
    end if;

    ex.icc <= icc;

-- FPU interface

    if ((FPIFTYPE = serial) and FPEN) then
-- pragma translate_off
      if is_x(aluin1) then aluin1 := (others => '0'); end if;
      if is_x(aluin2) then aluin2 := (others => '0'); end if;
      if is_x(de.inst(19) & de.inst(13 downto 5)) then
        fpui.FpInst <= (others => '0');
      else
-- pragma translate_on
        fpui.FpInst <= de.inst(19) & de.inst(13 downto 5);
-- pragma translate_off
      end if;
      if is_x(fpu_reg.fsr.rd) then fpui.RoundingMode <= (others => '0');
      else 
-- pragma translate_on
        fpui.RoundingMode <= fpu_reg.fsr.rd;
-- pragma translate_off
      end if;
-- pragma translate_on
      if (ex.ctrl.cnt = "00") or (opf(1) = '0') then
        fpui.fprf_dout1 <= aluin1 & aluin1;
        fpui.fprf_dout2 <= aluin2 & aluin2;
      else
        fpui.fprf_dout1 <= fpu_reg.op1h & aluin1;
        fpui.fprf_dout2 <= me.result & aluin2;
      end if;
      fpu_regin.op1h <= aluin1;
      if fpu_reg.ex.fpop = "01" and (ex.write_reg = '1') then
        if fpu_reg.ex.dsz = '1' then
	  if (ex.ctrl.cnt /= "00") then
            aluresult := fpuo.FracResult(34 downto 3);
	  end if;
        else
          aluresult := fpuo.SignResult & fpuo.ExpResult(7 downto 0) & 
                  fpuo.FracResult(54 downto 32);
        end if;
      end if;
      fpu_regin.me <= fpmein;
    end if;

    if (MULTIPLIER = m32x32) and (ex.mulinsn = '1') then
      aluresult := mulo.result(31 downto 0);
    end if;
    if MACEN then
      if ex.aluop = ALU_RDY then
	if rs1 = "10010" then
	  if ((me.mulinsn and me.ctrl.inst(24)) = '1') then
	    aluresult := mulo.result(31 downto 0);
	  else aluresult := wr.asr18; end if;
	else
	  if ((me.mulinsn and me.ctrl.inst(24)) = '1') then
	    aluresult := mulo.result(63 downto 32);
          end if;
        end if;
      end if;
     end if;
      
    ex.result <= aluresult;

-- generate Y

    micc := icc;
    licc := icc;

    nexty := y;
    if ex.mulstep = '1' then
      nexty := ymsb & y(31 downto 1);
    elsif (ex.mulinsn = '1') and (MULTIPLIER = iterative) then
        case ex.ctrl.cnt is
        when "00" => nexty := y;
        when "01" => nexty := ymsb & me.y(31 downto 1);
        when "10" =>
	  aluresult := ymsb & me.y(31 downto 1); 
	  licc(3) := ymsb; licc(1 downto 0) := "00";
	  if aluresult = zero32 then 
	    licc(2) := '1'; else licc(2) := '0';
	  end if;
	  nexty := me.y;
        when others => null;
        end case;
    elsif ((ex.rst_mey or ex.write_y) = '1') and (MULTIPLIER = iterative) then
      if ex.ctrl.cnt = "11" then nexty := addout;
      else nexty := logicout; end if;
    elsif ex.write_y = '1' then
      nexty := logicout; 
    end if;

    if (MULTIPLIER = iterative) then
      micc(3) := icc(3) and not ex.rst_mey;
      micc(1) := icc(1) and not ex.rst_mey;
    end if;

-- data address generation

    eaddress := miscout;
    if ex.alusel = ALU_RES_ADD then 
      addout(2) := addout(2) or force_a2; eaddress := addout;
    end if;

    if CPEN and (op = LDST) and ((op3(5 downto 4) & op3(2)) = "111") and
      (ex.ctrl.cnt /= "00")
    then
      dci.edata <= cpo.data;	-- store co-processor
      aluresult := cpo.data;
    elsif (FPIFTYPE = parallel) and (op = LDST) and 
	((op3(5 downto 4) & op3(2)) = "101") and (ex.ctrl.cnt /= "00")
    then
      dci.edata <= fpo.data;	-- store fpu co-processor
      aluresult := fpo.data;
    else 
      dci.edata <= edata;
      aluresult(2) := aluresult(2) or force_a2;
    end if;

    if (MULTIPLIER > iterative) and (MULTIPLIER /= m32x32) then
      write_reg := write_reg or mulo.ready;
      write_y   := write_y or mulo.ready;
      write_icc := write_icc or (mulo.ready and op3(4));
    end if;
    if DIVIDER /= none then
      write_reg := write_reg or divo.ready;
      write_icc := write_icc or (divo.ready and op3(4));
    end if;

-- debug unit cache access
    if DEBUG_UNIT then 
      if dsur.dmode = '1' then
	dcache_write := '0'; read := '1'; dsu_cache := '0';
        if (iui.debug.denable and iui.debug.daddr(20)) = '1' then
          enaddr := '1';
          asi(4 downto 0) := iui.debug.daddr(17) & "11" & iui.debug.daddr(19 downto 18);
          if M_EN and iui.debug.daddr(21) = '1' then
            -- ASI_ICTX "10101" 0x90300000-0x90340000
            -- ASI_DCTX "10100" 0x90380000-0x903c0000
            asi(4 downto 0) := "1010" & not (iui.debug.daddr(19)); 
          end if;
          dsu_cache := '1'; ld_size := LDWORD;
          if iui.debug.dwrite = '1' then
	    dcache_write := '1'; read := '0';
          end if;
	  if (dsur.dsuen and iui.debug.dwrite) = '1' then aluresult := iui.debug.ddata;
	  else aluresult(21 downto 2) := iui.debug.daddr; end if;
        end if;
      end if;
    end if;

    mein.y <= nexty;
    dciin.enaddr <= enaddr;
    dciin.read <= read;
    dciin.write <= dcache_write;
    dciin.asi <= asi;
    dciin.lock <= lock;
    dci.eenaddr <= enaddr;
    dci.eaddress <= eaddress;
    dci.dsuen <= dsur.dsuen;
    dci.esu <= su;

    fecomb.jump <= jump;
    
    ex.micc <= micc;
    mein.inull <= inull;
    mein.icc <= licc;
    mein.memory_load <= memory_load;
    mein.ld_size <= ld_size;
    mein.signed <= signed;
    mein.addr_misal <= addr_misal;

    mein.result <= aluresult;
    mein.write_reg <= write_reg;
    mein.write_icc <= write_icc;
    mein.write_y <= write_y;
    mein.ctrl <= ctrl;
    mein.su <= su;

  end process;

-------------------------------------------------------------------------------
-- memory stage
-------------------------------------------------------------------------------


  memory_stage : process(ex, me, wr, sregs, sregsin, iui, dco, fpuo, fpu_reg,
			cpo, fpo, rst, holdn, mulo, divo, tr, dsur)

  variable op    : std_logic_vector(1 downto 0);
  variable op2   : std_logic_vector(2 downto 0);
  variable op3   : std_logic_vector(5 downto 0);
  variable rd,rs1: std_logic_vector(4 downto 0);
  variable ctrl  : pipeline_control_type;
  variable nullify : std_logic;
  variable iflush : std_logic;
  variable ipend : std_logic;
  variable write_cwp : std_logic;
  variable cwp   : std_logic_vector(NWINLOG2-1 downto 0);
  variable cwpx  : std_logic_vector(5 downto NWINLOG2);
  variable result   : std_logic_vector(31 downto 0);
  variable write_reg : std_logic;
  variable icc : std_logic_vector(3 downto 0);
  variable werr  : std_logic;
  variable fpexc : std_logic;
  variable opf    : std_logic_vector(8 downto 0);
  variable fpwrin : fpu_ctrl2_type;
  variable jmpl_rett : std_logic;
  variable pil    : std_logic_vector(3 downto 0);
  variable irqen : std_logic;
  variable dsutrap : std_logic;
  variable y, asr18     : std_logic_vector(31 downto 0);
  variable trv : watchpoint_registers;
  variable wpi : integer range 0 to 3;  -- watchpoint index

  begin

-- common initialisation

    op    := me.ctrl.inst(31 downto 30);
    op2   := me.ctrl.inst(24 downto 22);
    op3   := me.ctrl.inst(24 downto 19);
    opf   := me.ctrl.inst(13 downto 5);
    rd    := me.ctrl.inst(29 downto 25);
    rs1   := me.ctrl.inst(18 downto 14);
    ctrl  := me.ctrl;
    ctrl.annul := ctrl.annul or wr.annul_all;
    nullify := ctrl.annul;
    iflush := '0';
    cwp := me.cwp; write_cwp := me.write_cwp;
    result := me.result;
    write_reg := me.write_reg;
    icc := me.icc;
    fpwrin := fpu_reg.me;
    jmpl_rett := '0';
    werr := (me.werr or dco.werr) and rst;
    y := me.y; asr18 := wr.asr18;
    trv := tr; wpi := 0; dsutrap := '0';
    cwpx := me.result(5 downto NWINLOG2); cwpx(5) := '0';

-- external interrupt handling

    -- disable interrupts for one  clock after a WRPSR, since a 
    -- WRPSR should affect ET and PIL without delay (SPARC V8 ISP, p.183)
    irqen := me.irqen and sregs.et; pil := sregs.pil;
    if (iui.irl = "1111") or (iui.irl > pil) then ipend := irqen;
    else ipend := '0'; end if;
    if (ctrl.annul = '0') and (ctrl.pv = '1') then
      if (werr and holdn) = '1' then
	ctrl.trap := '1'; ctrl.tt := DSEX_TT; werr := '0';
        if op = LDST then nullify := '1'; end if;
      elsif (irqen and not me.ctrl.trap) = '1' then

        if ipend = '1' then

	  ctrl.trap := '1'; ctrl.tt := "01" & iui.irl;
          if op = LDST then nullify := '1'; end if;
        end if;
      end if;
    end if;

    iuo.ipend <= me.ipend;

-- some trap generation

    irqen := '1';
    if ((ctrl.annul or ctrl.trap) /= '1') then
      case op is
      when FMT2 =>
        case op2 is
        when FBFCC => 
          if (FPIFTYPE = parallel) and (fpo.exc = '1') 
          then ctrl.trap := '1'; ctrl.tt := FPEXC_TT; end if;
        when CBCCC =>
    	  if CPEN and (cpo.exc = '1') 
    	  then ctrl.trap := '1'; ctrl.tt := CPEXC_TT; end if;
        when others => null;
        end case;
      when FMT3 =>
        case op3 is
	when WRY => 
	  if MACEN and (rd = "10010") then asr18 := me.result; end if;
	  for i in 0 to WATCHPOINTS-1 loop
	    if rd(4 downto 1) = std_logic_vector(conv_unsigned(12+i, 4)) then
	      if rd(0) = '0' then
	        trv(i).addr := me.result(31 downto 2); 
		trv(i).exec := me.result(0);
	      else
	        trv(i).mask := me.result(31 downto 2);
	        trv(i).load := me.result(1); trv(i).store := me.result(0);
	      end if;
	    end if;
	  end loop;
	when WRPSR =>
	  if (orv(cwpx) = '1') then
	    ctrl.trap := '1'; ctrl.tt := IINST_TT;
	  else cwp := me.result(NWINLOG2-1 downto 0); write_cwp := '1'; end if;
	when UDIV | SDIV =>
    	  if (DIVIDER /= none) then 
	    if icc(2) = '1' then ctrl.trap := '1'; ctrl.tt := DIV_TT; end if;
          end if;
	when UDIVCC | SDIVCC =>
    	  if (DIVIDER /= none) then 
	    if icc(2) = '1' then ctrl.trap := '1'; ctrl.tt := DIV_TT; end if;
          end if;
	when JMPL | RETT =>
--	  jmpl_rett := '1';
	  if me.addr_misal = '1' then 
	    ctrl.trap := '1'; ctrl.tt := UNALA_TT;
	  end if;
        when TADDCCTV | TSUBCCTV =>
	  if me.icc(1) = '1' then ctrl.trap := '1'; ctrl.tt := TAG_TT; end if;
	when FLUSH => iflush := '1';
	when FPOP1 | FPOP2 =>
          if (FPIFTYPE = parallel) and (fpo.exc = '1') 
          then ctrl.trap := '1'; ctrl.tt := FPEXC_TT; end if;
	when CPOP1 | CPOP2 =>
    	  if CPEN and (cpo.exc = '1') 
    	  then ctrl.trap := '1'; ctrl.tt := CPEXC_TT; end if;
        when others => null;
        end case;
      when LDST =>
        if ctrl.cnt = "00" then
          case op3 is
	  when LDDF | STDF | STDFQ =>
	    if FPEN then
	      if FPEN and (me.result(2 downto 0) /= "000") then
	        ctrl.trap := '1'; ctrl.tt := UNALA_TT; nullify := '1';
              elsif ((FPIFTYPE = parallel) and ((fpo.exc and ctrl.pv) = '1')) 
                   or ((FPIFTYPE = serial) and (op3 = STDFQ) and (ctrl.pv = '1'))
              then ctrl.trap := '1'; ctrl.tt := FPEXC_TT; nullify := '1'; end if;
	    end if;
	  when LDDC | STDC | STDCQ =>
	    if CPEN and (me.result(2 downto 0) /= "000") then
	      ctrl.trap := '1'; ctrl.tt := UNALA_TT; nullify := '1';
    	    elsif CPEN and ((cpo.exc and ctrl.pv) = '1') 
    	    then ctrl.trap := '1'; ctrl.tt := CPEXC_TT; nullify := '1'; end if;
	  when LDD | ISTD | LDDA | STDA =>
	    if me.result(2 downto 0) /= "000" then
	      ctrl.trap := '1'; ctrl.tt := UNALA_TT; nullify := '1';
	    end if;
 	  when LDF | LDFSR | STFSR | STF =>
	    if FPEN and (me.result(1 downto 0) /= "00") then
	      ctrl.trap := '1'; ctrl.tt := UNALA_TT; nullify := '1';
            elsif (FPIFTYPE = parallel) and ((fpo.exc and ctrl.pv) = '1') 
            then ctrl.trap := '1'; ctrl.tt := FPEXC_TT; nullify := '1'; end if;
 	  when LDC | LDCSR | STCSR | STC =>
	    if CPEN and (me.result(1 downto 0) /= "00") then
	      ctrl.trap := '1'; ctrl.tt := UNALA_TT; nullify := '1';
    	    elsif CPEN and ((cpo.exc and ctrl.pv) = '1') 
    	    then ctrl.trap := '1'; ctrl.tt := CPEXC_TT; nullify := '1'; end if;
 	  when LD | LDA | ST | STA | SWAP | SWAPA =>
	    if me.result(1 downto 0) /= "00" then
	      ctrl.trap := '1'; ctrl.tt := UNALA_TT; nullify := '1';
	    end if;
          when LDUH | LDUHA | LDSH | LDSHA | STH | STHA =>
	    if me.result(0) /= '0' then
	      ctrl.trap := '1'; ctrl.tt := UNALA_TT; nullify := '1';
	    end if;
          when others => null;
          end case;
	  for i in 0 to WATCHPOINTS-1 loop
	    if ((((tr(i).load and not op3(2)) or (tr(i).store and op3(2))) = '1') and
               (((tr(i).addr xor me.result(31 downto 2)) and tr(i).mask) = Zero32(31 downto 2)))
               or (DEBUG_UNIT and ((iui.debug.dsuen and iui.debug.bwatch and iui.debug.dbreak) = '1'))
            then
	      ctrl.trap := '1'; ctrl.tt := WATCH_TT; nullify := '1';
	    end if;
	  end loop;
	end if;
      when others => null;
      end case;
    end if;

-- get result from multiplier and divider

    case op is
    when FMT3 =>
      case op3 is
	when JMPL | RETT =>
	  jmpl_rett := '1';
	when UMUL | SMUL =>
    	  if (MULTIPLIER > iterative) then 
            if (MULTIPLIER /= m32x32) then 
	      result := mulo.result(31 downto 0);
	    end if;
            y := mulo.result(63 downto 32);
          end if;
	when UMULCC | SMULCC =>
    	  if (MULTIPLIER > iterative) then 
            if (MULTIPLIER /= m32x32) then 
              result := mulo.result(31 downto 0); icc := mulo.icc;
	    else
              icc := me.result(31) & "000";
	      if me.result = Zero32 then icc(2) := '1'; end if;
	    end if;
            y := mulo.result(63 downto 32);
          end if;
	when UMAC | SMAC =>
	  if MACEN then
	    result := mulo.result(31 downto 0);
	    asr18  := mulo.result(31 downto 0);
            y := mulo.result(63 downto 32);
	  end if;
	when UDIV | SDIV =>
    	  if (DIVIDER /= none) then 
            result := divo.result(31 downto 0);
          end if;
	when UDIVCC | SDIVCC =>
    	  if (DIVIDER /= none) then 
            result := divo.result(31 downto 0); icc := divo.icc;
          end if;
	when WRPSR => irqen := '0'; 
      when others => null;
      end case;
    when others => null;
    end case;

    mein.irqen <= irqen;

-- FPU MSW data store

    fpexc := '0';
    if ((FPIFTYPE = serial) and FPEN) then
      if (xorv(fpu_reg.me.fpop) = '1') then
        if (me.ctrl.cnt = "00") and
           ((fpu_reg.me.dsz or me.ctrl.inst(6)) = '1') 
	then 
          fpwrin.fcc  := fpuo.ConditionCodes;
          fpwrin.cexc := fpuo.Excep(4 downto 0);
        end if;
        if ((ctrl.annul or ctrl.trap) /= '1') then
          if ((fpu_reg.me.dsz and me.write_reg) = '1') and 
	     (me.ctrl.cnt = "00") 
	  then
            result := fpuo.SignResult & fpuo.ExpResult & 
                      fpuo.FracResult(54 downto 35);
          end if;
          if ((fpu_reg.fsr.tem and fpwrin.cexc) /= "00000" ) then
            fpexc := '1'; 
            if ((fpu_reg.me.dsz or me.ctrl.inst(6)) = '1') and 
	     (me.ctrl.cnt = "00") 
	    then fpexc := '0'; write_reg := '0';
	    else ctrl.trap := '1'; end if;
          end if;
        end if;
      end if;
      fpu_regin.fpexc <= fpexc;
      fpu_regin.wr <= fpwrin;
    end if;

    mein.bpresult <= result; -- FPU bypass

-- load data from cache

    if (me.memory_load or not dco.mds) = '1' then result := dco.data; end if;

-- Y register

    if  (me.write_y = '0') or (me.ctrl.annul = '1') then y := wr.y; end if;
    me.my <= y;  -- fast Y feedback
    if ((ctrl.annul or ctrl.trap) = '1') then y := wr.y; end if;

    if MACEN and ((ctrl.annul or ctrl.trap) = '1') then
      asr18 := wr.asr18;
    end if;

    if DEBUG_UNIT then
      if (iui.debug.dwrite and iui.debug.denable) = '1' then
	if iui.debug.daddr(20 downto 19) = "01" then
	  if iui.debug.daddr(7 downto 2) = "000000" then
            y := iui.debug.ddata;
          end if;
        end if;
      end if;
    end if;

    wrin.y <= y;



-- debug unit ASR write access

    if DEBUG_UNIT and 
       ((dsur.dmode and iui.debug.dwrite and iui.debug.denable) = '1') and
	 (iui.debug.daddr(20 downto 19) = "01") 
    then
      case iui.debug.daddr(7 downto 2) is
      when "010010" =>					-- %ASR18
	asr18 := iui.debug.ddata; 
      when others =>					-- %ASR24 - 31
        if (WATCHPOINTS > 0) and (iui.debug.daddr(7 downto 5) = "011") then
	  wpi := conv_integer(unsigned(iui.debug.daddr(4 downto 3)));
	  if iui.debug.daddr(2) = '0' then 
	    trv(wpi).addr := iui.debug.ddata(31 downto 2); 
	    trv(wpi).exec := iui.debug.ddata(0);
	  else
	    trv(wpi).mask := iui.debug.ddata(31 downto 2);
	    trv(wpi).load := iui.debug.ddata(1); 
	    trv(wpi).store := iui.debug.ddata(0);
	  end if;
	end if;
      end case;
    end if;

-- debug unit trap generation + diagnostic write data
    if DEBUG_UNIT and (iui.debug.dsuen = '1') and 
	(ctrl.annul = '0') and (ctrl.pv = '1') and (ctrl.trap = '1') and
	  ((iui.debug.btrapa = '1') or 
	  ((iui.debug.btrape = '1') and not ((ctrl.tt = PRIV_TT) or 
	    (ctrl.tt = FPDIS_TT) or (ctrl.tt = WINOF_TT) or
            (ctrl.tt = WINUF_TT) or (ctrl.tt(5 downto 4) = "01") or
	    (ctrl.tt = TICC_TT))) or 
	   ((iui.debug.bwatch = '1') and (ctrl.tt = WATCH_TT)) or
	   ((iui.debug.bsoft = '1') and (ctrl.tt = TICC_TT) and 
		(me.result(6 downto 0) = "0000001")))
    then dsutrap := '1'; end if;
    if DEBUG_UNIT and (dsur.dmode = '1') then result := iui.debug.ddata; end if;

    if rst = '0' then
      for i in 0 to WATCHPOINTS-1 loop
	trv(i).exec := '0'; trv(i).load := '0'; trv(i).store := '0';
      end loop;
    end if;

    mein.werr <= werr;
    mein.ipend <= ipend;
    wrin.result <= result; 
    wrin.icc <= icc; 
    me.jmpl_rett <= jmpl_rett;

    wrin.cwp <= cwp; wrin.write_cwp <= write_cwp;
    wrin.ctrl <= ctrl;
    wrin.write_reg <= write_reg;
    wrin.asr18 <= asr18;
    ici.flush <= iflush;
    dci.flush <= iflush;
    dci.nullify <= nullify;
    dci.maddress <= me.result;
    dci.msu <= me.su;
    trin <= trv;
    wrin.dsutrap <= dsutrap;

  end process;

-------------------------------------------------------------------------------
-- write stage
-------------------------------------------------------------------------------


  write_stage : process(rst, holdn, wr, sregs, fe, de, ex, me, fpu_reg, iui, dsur)

  variable op     : std_logic_vector(1 downto 0);
  variable op3    : std_logic_vector(5 downto 0);
  variable rd     : std_logic_vector(4 downto 0);
  variable rd_address : std_logic_vector(RABITS-1 downto 0);
  variable write_reg : std_logic;
  variable annul_all : std_logic;
  variable cwp : std_logic_vector(NWINLOG2-1 downto 0);
  variable icc : std_logic_vector(3 downto 0);
  variable tt     : std_logic_vector(7 downto 0);
  variable tba    : std_logic_vector(19 downto 0);
  variable wim    : std_logic_vector(NWINDOWS-1 downto 0);
  variable pil    : std_logic_vector(3 downto 0);
  variable ec, ef, ps, s, et : std_logic;
  variable exception : std_logic;
  variable trapping : std_logic;
  variable save_pc : std_logic;
  variable error : std_logic;
  variable intack : std_logic;
  variable tpcsel    : std_logic_vector(1 downto 0);
  variable npc : std_logic_vector(31 downto PCLOW); 
  variable trap_address : std_logic_vector(31 downto PCLOW);    --  trap address
  variable wrdata : std_logic_vector(RDBITS-1 downto 0);
  variable newtt, vectt : std_logic_vector(7 downto 0);
  variable vfsr : fsr_type;
  variable write_icc : std_logic;
  variable cpexack : std_logic;
  variable fpexack : std_logic;
  variable dsutrap : std_logic;
  variable vdsu : dsu_registers;
  variable fp_dwrite, fp_dwrite_fsr : std_logic;


  begin

-- common initialisation

    op    := wr.ctrl.inst(31 downto 30);
    op3   := wr.ctrl.inst(24 downto 19);
    rd    := wr.ctrl.inst(29 downto 25);

    rd_address := wr.ctrl.rd; write_reg := '0'; write_icc := wr.write_icc;

    annul_all := '0'; exception := '0';
    trapping := wr.trapping; tpcsel := "00";
    save_pc := '0'; error := wr.error; intack := '0'; 
    newtt := (others => '-'); vectt := (others => '-'); vdsu := dsur;
    vdsu.dsuen := iui.debug.denable; cpexack := '0'; fpexack := '0';
    vdsu.dmode2 := dsur.dmode2 and wr.ctrl.annul; dsutrap := '0';
    vfsr := fpu_reg.fsr;
    fp_dwrite := '0'; fp_dwrite_fsr := '0';    


-- special registers write handling

    icc := sregs.icc; cwp := sregs.cwp; ef := sregs.ef; ec := sregs.ec;
    pil := sregs.pil; s := sregs.s; ps := sregs.ps; et := sregs.et; 
    tba := sregs.tba; tt := sregs.tt; wim := sregs.wim;

    if (wr.ctrl.annul or wr.ctrl.trap) /= '1' then
      if wr.write_cwp = '1' then
        cwp := wr.cwp;
      end if;
      write_reg := wr.write_reg;
      case op is
      when FMT3 =>
        case op3 is
        when WRY =>

        when WRPSR =>
          cwp := wr.result(NWINLOG2-1 downto 0);
          icc := wr.result(23 downto 20);
          ec  := wr.result(13);
          ef  := wr.result(12);
          pil := wr.result(11 downto 8);
          s   := wr.result(7);
          ps  := wr.result(6);
          et  := wr.result(5);
        when WRWIM =>
          wim := wr.result(NWINDOWS-1 downto 0);
        when WRTBR =>
          tba := wr.result(31 downto 12);
        when RETT =>
          s := ps;
          et := '1';

        when FPOP1 | FPOP2 =>
	  if ((FPIFTYPE = serial) and FPEN) then

	      if (wr.write_reg = '1') and ((wr.ctrl.cnt = "00") or
	        ((wr.ctrl.cnt = "01") and (fpu_reg.wr.dsz = '0'))) 
	      then
	        vfsr.ftt  := (others => '0');
	        vfsr.cexc := fpu_reg.wr.cexc;
	        vfsr.aexc := fpu_reg.wr.cexc or fpu_reg.fsr.aexc;
	      end if;
	      if (op3 = FPOP2) and 
	          not ((wr.ctrl.inst(6) = '1') and (wr.ctrl.cnt = "00")) then 
		vfsr.fcc := fpu_reg.wr.fcc; 
	        vfsr.ftt  := (others => '0');
	        vfsr.cexc := fpu_reg.wr.cexc;
	        vfsr.aexc := fpu_reg.wr.cexc or fpu_reg.fsr.aexc;
	      end if;

	  end if;
        when others => null;
        end case;
      when LDST =>
        case op3 is
        when STFSR =>
	  if ((FPIFTYPE = serial) and FPEN) then
	    vfsr.ftt := (others => '0');
	  end if;
        when LDFSR =>
	  if ((FPIFTYPE = serial) and FPEN) then
	    vfsr.cexc := wr.result(4 downto 0);
	    vfsr.aexc := wr.result(9 downto 5);
	    vfsr.fcc  := wr.result(11 downto 10);
	    vfsr.tem  := wr.result(27 downto 23);
	    vfsr.rd   := wr.result(31 downto 30);
	  end if;

        when others => null;
        end case;
      when others => null;
      end case;
      if write_icc = '1' then icc := wr.icc; end if;
    end if;

-- trap handling

    -- nPC selection
    if me.ctrl.pv = '1' then tpcsel := "00";
    elsif ex.ctrl.pv = '1' then tpcsel := "01";
    elsif de.pv = '1' then tpcsel := "10";
    else tpcsel := "11"; end if;
    case wr.tpcsel is
    when "00" => npc := wr.ctrl.pc(31 downto PCLOW);
    when "01" => npc := me.ctrl.pc(31 downto PCLOW);
    when "10" => npc := ex.ctrl.pc(31 downto PCLOW);
    when others => npc := de.pc(31 downto PCLOW);
    end case;

    -- standard trap handling
    if DEBUG_UNIT and 
	((wr.mexc and (iui.debug.btrape or iui.debug.btrapa)) = '1') 
    then dsutrap := '1'; end if;
    if wr.mexc = '1' then newtt := "00" & DAEX_TT;
    elsif ((FPIFTYPE = serial) and FPEN) and (fpu_reg.fpexc = '1') then
      newtt := "00" & FPEXC_TT; vfsr.ftt := FPIEEE_ERR;
    elsif ((FPIFTYPE = serial) and FPEN) and (wr.ctrl.tt = FPEXC_TT) then 
      newtt := "00" & FPEXC_TT; vfsr.ftt := FPSEQ_ERR; 
    elsif wr.ctrl.tt = TICC_TT then newtt := '1' & wr.result(6 downto 0);
    else newtt := "00" & wr.ctrl.tt; end if;

    if ((wr.ctrl.trap and not wr.ctrl.annul) = '1')  
       or ((wr.mexc or trapping) = '1')
    then

      vdsu.pc := wr.ctrl.pc;
      if DEBUG_UNIT and 
         (iui.debug.dsuen = '1') and ((wr.ctrl.annul or dsur.dmode) = '0') and 
	  (((wr.dsutrap or dsutrap) = '1') or ((iui.debug.berror and not sregs.et) = '1'))
      then
        annul_all := '1'; vdsu.tt := newtt; vdsu.dmode := '1';
	write_reg := '0'; 
        if (sregs.et = '0') and not 
	    (((iui.debug.dbreak = '1') and (newtt = ("00" & WATCH_TT))) or
	     ((iui.debug.bsoft = '1') and (newtt = ("10000001"))))
	then vdsu.error := '1'; else vdsu.error := '0'; end if;
      elsif trapping = '0' then			-- first trap cycle
        annul_all := '1'; trapping := '1'; ps := s; s := '1';
	exception := '1'; et := '0';
        if sregs.et = '0' then 
          if not NOHALT then error := '1'; end if;
          if ((op = FMT3) and (op3 = RETT)) then tt := newtt; end if;
          vectt := (others => '0');
        else
          write_reg := '1'; save_pc := '1'; tt := newtt; vectt := newtt;
	end if;
	if CPEN and (tt = ("00" & CPEXC_TT)) then cpexack := '1'; end if;
	if (FPIFTYPE = parallel) and (tt = ("00" & FPEXC_TT)) then fpexack := '1'; end if;
-- pragma translate_off
        if not is_x(cwp) then
-- pragma translate_on
	  rd_address := (others => '0');
	  rd_address (NWINLOG2 + 3 downto 0) := cwp & "0001";
-- pragma translate_off
	end if;
-- pragma translate_on

      elsif trapping = '1' then			-- second trap cycle
        if error = '1' then
	  annul_all := '1'; trapping := '1';
	  if DEBUG_UNIT and (iui.debug.dbreak = '1') then 
	    vdsu.dmode := '1';
	  end if;
	else
          trapping := '0';
	  if sregs.tt(5 downto 4) = "01" then intack := '1'; end if;
          write_reg := '1'; save_pc := '1';
-- pragma translate_off
          if not is_x(cwp) then
-- pragma translate_on
	    rd_address := (others => '0');
	    rd_address (NWINLOG2 + 3 downto 0) := cwp & "0010";
-- pragma translate_off
	  end if;
-- pragma translate_on
-- pragma translate_off
        if not is_x(cwp) then
-- pragma translate_on
	  if (not CWPOPT) and (cwp = CWPMIN) then cwp := CWPMAX;
	  else cwp := cwp - 1; end if;
-- pragma translate_off
	end if;
-- pragma translate_on
	end if;
      end if;
    end if;

    trap_address(31 downto 4) := sregs.tba & vectt; 
    trap_address(3 downto PCLOW) := (others => '0');

-- debug mode
  
    if DEBUG_UNIT then
      iuo.debug.dbreak <= iui.debug.dbreak;
--      iuo.debug.dbreak <= iui.debug.dsuen and iui.debug.dbreak;
      if iui.debug.rerror = '1' then trapping := '0'; error := '0'; end if;
      if (dsur.dmode = '1') then
        if dsur.dstate = '0' then
	  annul_all := '1'; trap_address := dsur.pc; exception := '1';
	  vdsu.pc := npc; vdsu.dstate := '1'; 
        else
	  annul_all := '1'; trap_address := fe.pc; exception := '1'; 
	  if (iui.debug.dsuen and iui.debug.dbreak) = '0' then
	    annul_all := '0'; vdsu.dmode := '0'; vdsu.dstate := '0'; 
	    trap_address := dsur.pc;
	  end if;
	  if (iui.debug.dwrite and iui.debug.denable) = '1' then
	    if iui.debug.daddr(20 downto 19) = "00" then 	-- write regfile
	      write_reg := dsur.dsuen;
	      rd_address := iui.debug.daddr(RABITS+1 downto 2);
              if (FPIFTYPE = parallel) and FPEN then	     
                if iui.debug.daddr(17 downto 16) = "11" then 
                  fp_dwrite := dsur.dsuen;		     
                  write_reg := '0';			     
                end if;					     
              end if;                            
	    elsif iui.debug.daddr(20 downto 19) = "01" then -- write special registers
	      case iui.debug.daddr(7 downto 2) is
	      when "000001" =>				-- PSR
          	cwp := iui.debug.ddata(NWINLOG2-1 downto 0);
          	icc := iui.debug.ddata(23 downto 20);
          	ec  := iui.debug.ddata(13);
          	ef  := iui.debug.ddata(12);
          	pil := iui.debug.ddata(11 downto 8);
          	s   := iui.debug.ddata(7);
          	ps  := iui.debug.ddata(6);
          	et  := iui.debug.ddata(5);
	      when "000010" =>				-- WIM
          	wim := iui.debug.ddata(NWINDOWS-1 downto 0);
	      when "000011" => tba := iui.debug.ddata(31 downto 12); -- TBR
	      when "000100" => trap_address := iui.debug.ddata(31 downto PCLOW); -- PC
	      when "000101" => vdsu.pc := iui.debug.ddata(31 downto PCLOW); -- NPC
	      when "000110" => 				-- FSR
                if (FPIFTYPE = serial) and FPEN then                 
                  vfsr.cexc := iui.debug.ddata(4 downto 0);
                  vfsr.aexc := iui.debug.ddata(9 downto 5);
                  vfsr.fcc  := iui.debug.ddata(11 downto 10);
                  vfsr.tem  := iui.debug.ddata(27 downto 23);
                  vfsr.rd   := iui.debug.ddata(31 downto 30);
                elsif (FPIFTYPE = parallel) and FPEN then
                  fp_dwrite_fsr := '1';
                end if;
	      when others =>
	      end case;
	    end if;
	  end if;
        end if;
      else	-- break-in in during error mode
        if (iui.debug.dbreak and error) = '1' then vdsu.dmode := '1'; end if;
      end if;
      vdsu.dmode2 := vdsu.dmode or vdsu.dmode2;
      iuo.debug.error <= wr.error;
    end if;

    write_reg := write_reg and holdn;
    if save_pc = '1' then wrdata(31 downto 0) := npc(31 downto 2) & "00";
    else wrdata(31 downto 0) := wr.result; end if;

    if DEBUGPORT then
      iuo.debug.tt <= tt;
      iuo.debug.trap <= trapping;
      iuo.debug.result <= wrdata(31 downto 0);
      iuo.debug.wr     <= wr.ctrl;
      iuo.debug.dmode  <= vdsu.dstate;
      iuo.debug.dmode2 <= dsur.dmode2;
      iuo.debug.vdmode <= vdsu.dmode;
      iuo.debug.psrtt  <= sregs.tt;
      iuo.debug.psrpil <= sregs.pil;

      iuo.debug.write_reg <= write_reg;

    end if;

-- reset handling

    if rst = '0' then
      et := '0'; s := '1'; annul_all := '1';
      trapping := '0'; save_pc := '0'; exception := '0'; error := '0';
      vdsu.dmode := '0'; vdsu.dstate := '0'; vdsu.error := '0';

    end if;

    if not FPEN then ef := '0'; end if;
    if not CPEN then ec := '0'; end if;

    if CPEN then
      cpi.exack  <= cpexack;
      cpi.dcnt   <= de.cnt;
      cpi.dinst  <= de.inst;
      cpi.ex     <= ex.ctrl;
      cpi.me     <= me.ctrl;
      cpi.wr     <= wr.ctrl; 
      cpi.flush  <= annul_all;
      cpi.lddata <= wr.result;
    end if;

    if (FPIFTYPE = parallel) then
      fpi.exack  <= fpexack;
      fpi.dcnt   <= de.cnt;
      fpi.dinst  <= de.inst;
      fpi.ex     <= ex.ctrl;
      fpi.me     <= me.ctrl;
      fpi.wr     <= wr.ctrl; 
      fpi.flush  <= annul_all;
      fpi.lddata <= wr.result;
      fpi.debug.daddr <= iui.debug.daddr(6 downto 2);
      fpi.debug.dwrite_fsr <= fp_dwrite_fsr;
      fpi.debug.denable <= iui.debug.denable and dsur.dmode;
      fpi.debug.dwrite <= fp_dwrite;
      fpi.debug.ddata <= iui.debug.ddata;
    end if;

    iuo.error <= wr.nerror;
    iuo.intack <= wr.intack and holdn;
    iuo.irqvec <= sregs.tt(3 downto 0);
    wr.annul_all <= annul_all;
    wrin.trapping <= trapping;
    wrin.tpcsel <= tpcsel;
    wrin.error <= error;
    wrin.nerror <= not error;
    wrin.intack <= intack;
    sregsin.cwp <= cwp;
    sregsin.icc <= icc;
    sregsin.ec  <= ec;
    sregsin.ef  <= ef;
    sregsin.pil <= pil;
    sregsin.s   <= s;
    sregsin.ps  <= ps;
    sregsin.et  <= et;
    sregsin.wim <= wim;
    sregsin.tba <= tba;
    sregsin.tt  <= tt;
    rfi.wraddr <= rd_address;
    rfi.wrdata <= wrdata;
    rfi.wren <= write_reg;
    fecomb.exception <= exception;
    fecomb.trap_address <= trap_address;
    fpu_regin.fsr  <= vfsr;
    muli.flush <= wr.annul_all;
    divi.flush <= wr.annul_all;
    muli.y     <= wr.y(7 downto 0);
    muli.asr18 <= wr.asr18;
    dsurin <= vdsu;

  end process;

-- optional multiplier

  mgen : if MULTIPLIER > iterative generate
    mul0 : mul port map (rst, clk, holdn, muli, mulo);
  end generate;

-- optional divider

  dgen : if DIVIDER /= none generate
    div0 : div port map (rst, clk, holdn, divi, divo);
  end generate;

-- missed instruction and data registers

  instmux : process(dein, ico, de, fecomb)
  begin
    if (ico.mds and fecomb.hold_pc) = '1' then
      dein.inst <= de.inst;
      dein.mexc <= de.mexc;
    else
      dein.inst <= ico.data;
      dein.mexc <= ico.exception;
    end if;
  end process;

-- debug unit diagnostic read

  dsuread : if DEBUG_UNIT generate
    dsrd : process(iui, wr, sregs, tr, fe, dsur, fpu_reg, rfo, dco)
    variable rdata : std_logic_vector(31 downto 0);
    variable cwp : std_logic_vector(4 downto 0);
    variable wpi : integer;
    variable fp_dread_fsr : std_logic;	        
    begin
      rdata := (others => '0'); wpi := 0; cwp := (others => '0');
      fp_dread_fsr := '0';      
	case iui.debug.daddr(20 downto 19) is
	when "00" => 
	  rdata := rfo.data1(31 downto 0);
          if (FPIFTYPE = parallel) and FPEN then	     
            if iui.debug.daddr(17 downto 16) = "11" then     
              rdata := fpo.data;			     
            end if;					     
          end if;					               
	when "01" =>
	  case iui.debug.daddr(7 downto 2) is
	  when "000000" => rdata := wr.y; 		-- Y
	  when "000001" => cwp(NWINLOG2-1 downto 0) := sregs.cwp;
	    rdata := std_logic_vector(IMPL) & std_logic_vector(VER) &
	    sregs.icc & "000000" & sregs.ec & sregs.ef & sregs.pil & sregs.s
	    & sregs.ps & sregs.et & cwp;
	  when "000010" => rdata(NWINDOWS-1 downto 0) := sregs.wim; -- WIM
	  when "000011" => rdata := sregs.tba & sregs.tt & "0000"; -- TBR
	  when "000100" => rdata(31 downto PCLOW) := fe.pc;	-- PC
	  when "000101" => rdata(31 downto PCLOW) := dsur.pc;	-- NPC
	  when "000110" =>
    	    if ((FPIFTYPE = serial) and FPEN) then
	      rdata := fpu_reg.fsr.rd & "00" & 
	      fpu_reg.fsr.tem & "000" & std_logic_vector(FPUVER) & 
	      fpu_reg.fsr.ftt & "00" & fpu_reg.fsr.fcc & fpu_reg.fsr.aexc & 
	      fpu_reg.fsr.cexc;
            elsif ((FPIFTYPE = parallel) and FPEN) then	     
              fp_dread_fsr := '1';			     
              rdata := fpo.data;			                   
	    end if;
	  when "000111" => rdata(12 downto 4) := dsur.error & dsur.tt;	-- DSU TT 

	  when others =>
            if (WATCHPOINTS > 0) and (iui.debug.daddr(7 downto 5) = "011") then
	      wpi := conv_integer(unsigned(iui.debug.daddr(4 downto 3)));
	      if iui.debug.daddr(2) = '0' then 
	        rdata := tr(wpi).addr & '0' & tr(wpi).exec;
	      else rdata := tr(wpi).mask & tr(wpi).load & tr(wpi).store; end if;
	    end if;
	  end case;
	when others =>
	  rdata := dco.dsudata;
	end case;
      iuo.debug.ddata <= rdata;
      fpi.debug.dread_fsr <= fp_dread_fsr;            
    end process;
  end generate;



    iregs : process (clk)
    begin
      if rising_edge(clk) then
        if (holdn or (not ico.mds)) = '1' then
          de.inst <= dein.inst;
          de.mexc <= dein.mexc;
        end if;
      end if;
    end process;
    dregs : process(clk)
    begin
      if rising_edge(clk) then
        if (holdn or (not dco.mds)) = '1' then
	  wr.mexc <= dco.mexc;
          wr.result <= wrin.result;
        end if;
      end if;
    end process;

-- normal registers


  pregs : process (clk)
  begin
    if rising_edge(clk) then
      me.werr <= mein.werr;
      me.ipend <= mein.ipend;
      if (holdn = '1') then

-- fetch stage
      fe <= fein;
-- decode stage
      de.annul <= dein.annul;
      de.cnt <= dein.cnt;
      de.mulcnt <= dein.mulcnt;
      de.cwp <= dein.cwp;
      de.pv <= dein.pv;
      de.pc <= dein.pc;

-- execute stage
      ex.ctrl <= exin.ctrl;
      ex.write_reg <= exin.write_reg;
      ex.write_cwp <= exin.write_cwp;
      ex.cwp <= exin.cwp;
      ex.write_y <= exin.write_y;
      ex.rst_mey <= exin.rst_mey;
      ex.write_icc <= exin.write_icc;
      ex.rs1data <= exin.rs1data;
      ex.rs2data <= exin.rs2data;
      ex.alu_cin <= exin.alu_cin;
      ex.aluop <= exin.aluop;
      ex.alusel <= exin.alusel;
      ex.aluadd <= exin.aluadd;
      ex.mulstep <= exin.mulstep;
      ex.mulinsn <= exin.mulinsn;
      ex.ymsb <= exin.ymsb;
      dci.write <= dciin.write;
      dci.asi <= dciin.asi;
      dci.enaddr <= dciin.enaddr;
      dci.read <= dciin.read;
      dci.lock <= dciin.lock;

-- memory stage
      me.result <= mein.result;
      me.y <= mein.y;
      me.ctrl <= mein.ctrl;
      dci.size <= mein.ld_size;
      me.memory_load <= mein.memory_load;
      dci.signed <= mein.signed;
      me.write_reg <= mein.write_reg;
      me.write_cwp <= ex.write_cwp;
      me.cwp <= ex.cwp;
      me.write_y <= mein.write_y;
      me.write_icc <= mein.write_icc;
      me.icc <= mein.icc;
      me.addr_misal <= mein.addr_misal;
      me.irqen <= mein.irqen;
      me.su <= mein.su;

-- write stage
      wr.y <= wrin.y;
      wr.ctrl <= wrin.ctrl;
      wr.write_reg <= wrin.write_reg;
      wr.write_cwp <= wrin.write_cwp;
      wr.cwp <= wrin.cwp;
      wr.write_icc <= me.write_icc;
      wr.icc <= wrin.icc;
      wr.tpcsel <= wrin.tpcsel;
      wr.trapping <= wrin.trapping;
      wr.error <= wrin.error;
      wr.nerror <= wrin.nerror;
      wr.intack <= wrin.intack;

-- special registers
      sregs.cwp <= sregsin.cwp;
      sregs.icc <= sregsin.icc;
      sregs.tt  <= sregsin.tt;
      sregs.tba <= sregsin.tba;
      sregs.wim  <= sregsin.wim;
      sregs.ec  <= sregsin.ec;
      sregs.ef  <= sregsin.ef;
      sregs.et  <= sregsin.et;
      sregs.ps  <= sregsin.ps;
      sregs.s   <= sregsin.s;
      sregs.pil <= sregsin.pil;
      end if;

-- wathpoint registers
      for i in 0 to WATCHPOINTS-1 loop tr(i) <= trin(i); end loop;
    end if;

-- drive unused watchpoint signals to avoid tri-state buffers
    for i in WATCHPOINTS to 3 loop 
      tr(i).addr <= (others => '0'); tr(i).mask <= (others => '0');
      tr(i).exec <= '0'; tr(i).load <= '0'; tr(i).store <= '0';
    end loop;
  end process;

-- DSU register

  dsr0 : if DEBUG_UNIT generate
    dsuregs : process (clk)
    begin
      if rising_edge(clk) then
        if (holdn = '1') then
	  dsur <= dsurin;
	  wr.dsutrap <= wrin.dsutrap;
          de.step <= dein.step;
        end if;
      end if;
    end process;
  end generate;

-- MAC register

  m0 : if MACEN generate
    mregs : process (clk)
    begin
      if rising_edge(clk) then
        if (holdn = '1') then
	  wr.asr18 <= wrin.asr18;
          me.mulinsn <= ex.mulinsn;
	end if;
      end if;
    end process;
  end generate;

-- register for load bypass control if LDDELAY = 1

  ldbpr0 : if LDDELAY = 1 generate
    lb : process(clk)
    begin
      if rising_edge(clk) then
        if (holdn = '1') then
	  ex.ldbp1 <= exin.ldbp1; ex.ldbp2 <= exin.ldbp2;
        end if;
      end if;
    end process;
  end generate;

-- fpu support registers 

  fg3 : if ((FPIFTYPE = serial) and FPEN) generate
    fpureg : process (clk)
    begin
      if rising_edge(clk) then
        fpu_reg.fpld <= fpu_regin.fpld;
        fpu_reg.fpbusy <= fpu_regin.fpbusy;
        fpu_reg.rstdel <= fpu_regin.rstdel;
        if (holdn = '1') then
          fpu_reg.reset <= fpu_regin.reset;
          fpu_reg.fsr   <= fpu_regin.fsr;
          fpu_reg.fpexc <= fpu_regin.fpexc;
          fpu_reg.op1h  <= fpu_regin.op1h;
          fpu_reg.ex  <= fpu_regin.ex;
          fpu_reg.me  <= fpu_regin.me;
          fpu_reg.wr  <= fpu_regin.wr;
	end if;
      end if;
    end process;
  end generate;


  fg4 : if ((FPIFTYPE = serial) and FPEN) generate
      fpu_regin.reset <= ((fpu_regin.fpop or fpu_reg.fpld or fpu_reg.fpbusy) 
		           and wr.annul_all) or not rst;
      fpu_regin.rstdel <= "11" when (fpu_reg.reset or fpu_regin.reset) = '1'
      else fpu_reg.rstdel - 1 when (fpu_reg.rstdel /= "00")
-- pragma translate_off
	and not (is_x(fpu_reg.rstdel))
-- pragma translate_on
      else fpu_reg.rstdel;
      fpui.fpop <= fpu_regin.fpop;
      fpu_regin.fpld <= fpu_regin.fpop or not rst;
      fpui.reset <= fpu_reg.reset or fpu_regin.reset or fpu_reg.rstdel(1)
		    or fpu_reg.rstdel(0);
      fpu_regin.fpbusy <= fpuo.fpbusy;
      fpui.fpld <= fpu_reg.fpld;
      fpui.fpuholdn <= fpu_reg.reset or fpu_reg.rstdel(1) or fpu_reg.rstdel(0)
			 or (not rst) or not (fpu_reg.fpbusy or fpu_reg.fpld);
  end generate;
  fg5 : if not ((FPIFTYPE = serial) and FPEN) generate
      fpui.fpuholdn <= '1';
  end generate; 




-- debugging support

  debug0 : if DEBUGPORT generate


    iuo.debug.clk    <= clk;

    iuo.debug.rst    <= rst;
    iuo.debug.holdn  <= holdn;
    iuo.debug.ex     <= ex.ctrl;
    iuo.debug.me     <= me.ctrl;
    iuo.debug.mresult<= me.result;
    iuo.debug.diagrdy<= ico.diagrdy;
    iuo.debug.fpdbg <= fpo.debug;

  end generate;

  fadder : if FASTADD generate
    add0 : add32 port map (add32in1, add32in2, add32cin, sum32, open);
  end generate;

end;
