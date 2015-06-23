



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
-- Entity: 	fp
-- File:	fp.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	Parallel floating-point and co-processor interface
-- The interface allows one execution unit
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.sparcv8.all;
use work.tech_map.all;
use work.fpulib.all;

-- pragma translate_off
use STD.TEXTIO.all;
use work.debug.all;
-- pragma translate_on

entity fp1eu is
port (
    rst    : in  std_logic;			-- Reset
    clk    : in  clk_type;
    holdn  : in  std_logic;			-- pipeline hold
    xholdn : in  std_logic;			-- pipeline hold
    cpi    : in  cp_in_type;
    cpo    : out cp_out_type
  );
end;

architecture rtl of fp1eu is

type cpins_type is (none, cpop, load, store);

type pl_ctrl is record		-- pipeline control record
  cpins    : cpins_type;	-- CP instruction
  rreg1    : std_logic;		-- using rs1
  rreg2    : std_logic;		-- using rs1
  rs1d     : std_logic;		-- rs1 is double (64-bit)
  rs2d     : std_logic;		-- rs2 is double (64-bit)
  wreg     : std_logic;		-- write CP regfile
  rdd      : std_logic;		-- rd is double (64-bit)
  wrcc     : std_logic;		-- write CP condition codes
  acsr     : std_logic;		-- access CP control register
end record;

type unit_status_type is (free, started, ready);
type unit_ctrl is record	-- execution unit control record
  status   : unit_status_type;		    -- unit status
  rs1      : std_logic_vector (4 downto 0); -- destination register
  rs2      : std_logic_vector (4 downto 0); -- destination register
  rd       : std_logic_vector (4 downto 0); -- destination register
  rreg1    : std_logic;		-- using rs1
  rreg2    : std_logic;		-- using rs1
  rs1d     : std_logic;		-- rs1 is double (64-bit)
  rs2d     : std_logic;		-- rs2 is double (64-bit)
  wreg     : std_logic;		-- will write CP regfile
  rdd      : std_logic;		-- rd is double (64-bit)
  wbok     : std_logic;		-- ok to write result
  wrcc     : std_logic;		-- will write CP condition codes
  rst      : std_logic;		-- reset register
  pc       : std_logic_vector (31 downto PCLOW); -- program counter
  inst     : std_logic_vector (31 downto 0); -- instruction
end record;

type csr_type is record	-- CP status register
  cc       : std_logic_vector (1 downto 0); -- condition codes
  aexc     : std_logic_vector (4 downto 0); -- exception codes
  cexc     : std_logic_vector (4 downto 0); -- exception codes
  tem      : std_logic_vector (4 downto 0); -- trap enable mask
  rd       : std_logic_vector (1 downto 0); -- rounding mode
  tt       : std_logic_vector (2 downto 0); -- trap type
end record;

type execstate is (nominal, excpend, exception);
type reg_type is record	-- registers clocked with pipeline
  start    : std_logic;		-- start EU
end record;

type regx_type is record	-- registers clocked continuously
  res      : std_logic_vector (63 downto 0); -- write stage result
  waddr    : std_logic_vector (3 downto 0); -- write stage dest
  wren     : std_logic_vector (1 downto 0); -- write stage regfile write enable
  csr      : csr_type;                       -- co-processor status register
  start    : std_logic;		-- start EU
  starty   : std_logic;		-- start EU
  startx   : std_logic;		-- start EU
  holdn    : std_logic;
  wbok     : std_logic;		-- ok to write result
  state    : execstate;		-- FP/CP state
end record;

signal vcc, gnd, wb, snnotdb, fp_ctl_scan_out : std_logic;
signal rfi1, rfi2 : rf_cp_in_type;
signal rfo1, rfo2 : rf_cp_out_type;
signal ex, exin, me, mein, wr, wrin : pl_ctrl;
signal r, rin  : reg_type;
signal rx, rxin  : regx_type;
signal eui : cp_unit_in_type;
signal euo : cp_unit_out_type;
signal eu, euin : unit_ctrl;

function ldcheck (rdin : std_logic_vector; ldd : std_logic; eu : unit_ctrl) 
  return std_logic is
variable lock : std_logic;
variable rd : std_logic_vector(4 downto 0);
begin
  lock := '0'; rd := rdin;
  if (eu.status > free) then
    if (eu.rdd = '0') then
      if ((eu.wreg = '1') and (rd = eu.rd)) or
	 ((eu.rreg1 = '1') and (rd = eu.rs1)) or
	 ((eu.rreg2 = '1') and (rd = eu.rs2))
      then lock := '1'; end if;
      if (ldd = '1') then
	if ((eu.wreg = '1')  and ((rd(4 downto 1) & '1') = eu.rd)) or
	   ((eu.rreg1 = '1') and ((rd(4 downto 1) & '1') = eu.rs1)) or
	   ((eu.rreg2 = '1') and ((rd(4 downto 1) & '1') = eu.rs2))
	then lock := '1'; end if;
      end if;
    else
      if ((eu.wreg = '1')  and (rd(4 downto 1) = eu.rd(4 downto 1))) or
	 ((eu.rreg1 = '1') and (rd(4 downto 1) = eu.rs1(4 downto 1))) or
	 ((eu.rreg2 = '1') and (rd(4 downto 1) = eu.rs2(4 downto 1)))
      then lock := '1'; end if;
    end if;
  end if;
  return(lock);
end;
function stcheck (rdin : std_logic_vector; std : std_logic; eu : unit_ctrl) 
  return std_logic is
variable lock : std_logic;
variable rd : std_logic_vector(4 downto 0);
begin
  lock := '0'; rd := rdin;
  if (eu.status > free) then
    if (eu.rdd = '0') then
      if ((eu.wreg = '1') and (rd = eu.rd)) then lock := '1'; end if;
      if (std = '1') then
	if ((eu.wreg = '1')  and ((rd(4 downto 1) & '1') = eu.rd))
	then lock := '1'; end if;
      end if;
    else
      if ((eu.wreg = '1')  and (rd(4 downto 1) = eu.rd(4 downto 1))) or
	 ((eu.rreg1 = '1') and (rd(4 downto 1) = eu.rs1(4 downto 1))) or
	 ((eu.rreg2 = '1') and (rd(4 downto 1) = eu.rs2(4 downto 1)))
      then lock := '1'; end if;
    end if;
  end if;
  return(lock);
end;

function srccheck (rsin : std_logic_vector; dbl : std_logic; eu : unit_ctrl) 
  return std_logic is
variable lock : std_logic;
variable rs : std_logic_vector(4 downto 0);
begin
  lock := '0'; rs := rsin;
  if (eu.wreg = '1')  and (rs(4 downto 1) = eu.rd(4 downto 1)) then
    if ((dbl or eu.rdd) = '1') or (rs(0) = eu.rd(0)) then lock := '1'; end if;
  end if;
  return(lock);
end;

begin

  vcc <= '1'; gnd <= '1';

-- instruction decoding

  pipeline : process(cpi, ex, me, wr, eu, euin, r, rx, rfi1, rfi2, rfo1, rfo2,
		     holdn, xholdn,
			euo, rst, wb)
  variable op     : std_logic_vector(1 downto 0);
  variable op3    : std_logic_vector(5 downto 0);
  variable opc    : std_logic_vector(8 downto 0);
  variable stdata : std_logic_vector(31 downto 0);
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable ctrl   : pl_ctrl;
  variable ldlock : std_logic;
  variable wren   : std_logic_vector(1 downto 0);
  variable waddr  : std_logic_vector(3 downto 0);
  variable rtaddr : std_logic_vector(3 downto 0);
  variable wrdata : std_logic_vector(63 downto 0);
  variable rtdata : std_logic_vector(63 downto 0);
  variable rv : reg_type;
  variable rxv : regx_type;
  variable euv : unit_ctrl;
  variable euiv : cp_unit_in_type;
  variable ddep     : std_logic;
  variable cpexc    : std_logic;
  variable fpill    : std_logic;
  variable ccv      : std_logic;
  variable qne      : std_logic;
  variable wbv      : std_logic;
  variable op1      : std_logic_vector (63 downto 0); -- operand1
  variable op2      : std_logic_vector (63 downto 0); -- operand2
  variable opcode   : std_logic_vector (9 downto 0); -- FP opcode
  begin

-------------------------------------------------------------
-- decode stage
-------------------------------------------------------------
    op    := cpi.dinst(31 downto 30);
    op3   := cpi.dinst(24 downto 19);
    opc   := cpi.dinst(13 downto 5);
    rs1   := cpi.dinst(18 downto 14);
    rs2   := cpi.dinst(4 downto 0);
    rd    := cpi.dinst(29 downto 25);

    rv := r; rxv := rx;
    ctrl.cpins := none; ctrl.wreg := '0'; ctrl.rdd := '0';
    ctrl.wrcc := '0'; ctrl.acsr := '0'; ldlock := '0';
    ctrl.rreg1 := '0'; ctrl.rreg2 := '0';
    ctrl.rs1d := '0'; ctrl.rs2d := '0'; fpill := '0';
    stdata := (others => '-'); wren := "00"; cpexc := '0';
    ccv := '0'; rv.start := '0'; rxv.wbok := '0';
    rxv.start := '0';
    euv := eu;
    if eu.status /= free then qne := '1'; else qne := '0'; end if;

    euiv.opcode := cpi.ex.inst(19) & cpi.ex.inst(13 downto 5);
    euiv.start := '0'; euiv.load := '0';
    euiv.flush := eu.rst or euin.rst;
    wbv := '0';
    euv.rst := not rst;
    if (eu.status = started) and (euo.busy = '0') then 
      euv.status := ready;
    end if;
    if (eu.status > free) then ccv := ccv or eu.wrcc; end if;

    -- decode CP instructions
      case op is
      when FMT3 =>
        case op3 is
        when FPOP1 => 
	  if rx.state = exception then rxv.state := excpend; rxv.csr.tt := "100";
          elsif rx.state = nominal then
	    ctrl.cpins := cpop; ctrl.wreg := '1';
            case opc is
            when FMOVS | FABSS | FNEGS => ctrl.rreg2 := '1';
            when FITOS | FSTOI => ctrl.rreg2 := '1';
            when FITOD | FSTOD => ctrl.rreg2 := '1'; ctrl.rdd := '1';
            when FDTOI | FDTOS => ctrl.rreg2 := '1'; ctrl.rs2d  := '1';
            when FSQRTS => ctrl.rreg2 := '1';
            when FSQRTD => ctrl.rreg2 := '1'; ctrl.rs2d  := '1'; ctrl.rdd := '1';
            when FADDS | FSUBS | FMULS | FDIVS => 
	      ctrl.rreg1 := '1'; ctrl.rreg2 := '1';
            when FADDD | FSUBD | FMULD | FDIVD => 
	      ctrl.rreg1 := '1'; ctrl.rreg2 := '1'; ctrl.rs1d  := '1'; 
	      ctrl.rs2d  := '1'; ctrl.rdd := '1';
            when others => fpill := '1'; -- illegal instuction
            end case;
	  end if;
        when FPOP2 => 
	  if rx.state = exception then rxv.state := excpend; rxv.csr.tt := "100";
          elsif rx.state = nominal then
	    ctrl.cpins := cpop; ctrl.wrcc := '1';
	    ctrl.rreg1 := '1'; ctrl.rreg2 := '1';
            case opc is
            when FCMPD | FCMPED => 
	      ctrl.rs1d := '1'; ctrl.rs2d := '1';
            when others => fpill := '1'; -- illegal instuction
            end case;
	  end if;
        when others => null;
        end case;
        if (ex.cpins = load) and ((cpi.ex.annul or cpi.ex.trap) = '0') and
	  (ex.wreg = '1')
        then
	  if (ctrl.rreg1 = '1') and
	   (rs1(4 downto 1) = cpi.ex.inst(29 downto 26)) and
	   (((ctrl.rs1d or ex.rdd) = '1') or (rs1(0) = cpi.ex.inst(25)))
	  then ldlock := '1'; end if;
	  if (ctrl.rreg2 = '1') and
	   (rs2(4 downto 1) = cpi.ex.inst(29 downto 26)) and
	   (((ctrl.rs2d or ex.rdd) = '1') or (rs2(0) = cpi.ex.inst(25)))
	  then ldlock := '1'; end if;
        end if;
      when LDST =>
        case op3 is
        when LDF | LDDF =>
	  if rx.state = exception then rxv.state := excpend; rxv.csr.tt := "100";
          elsif rx.state = nominal then
	    ctrl.rdd := op3(1) and op3(0);
	    ctrl.cpins := load; ctrl.wreg := '1';
            -- dst interlock
	    ldlock := ldlock or ldcheck(rd, ctrl.rdd, euin);
 	  end if;
        when STF | STDF =>
	  -- check for CP register dependencies
	  if (ex.cpins = load) and ((cpi.ex.annul or cpi.ex.trap) = '0') and
	     (cpi.ex.cnt = "00") and 
	       ((rd = cpi.ex.inst(29 downto 25)) or
	       ((rd(4 downto 1) = cpi.ex.inst(29 downto 26)) and 
		  (ex.rdd = '1')))
	  then ldlock := '1'; end if;
          if rx.state = nominal then
	    ldlock := ldlock or stcheck(rd, (op3(1) and op3(0)), euin);
	  end if;
	  if (ldlock = '0') then ctrl.cpins := store; end if;
        when STFSR | LDFSR =>
	  if (rx.state = exception) and (op3 = LDFSR) then 
	    rxv.state := excpend;  rxv.csr.tt := "100";
          else
	    if (ex.cpins = load) and ((cpi.ex.annul or cpi.ex.trap) = '0') and
	     (cpi.ex.cnt = "00") and (op3 = STFSR) and (ex.acsr = '1')
	    then ldlock := '1'; end if;
	    if (rx.state = nominal) then 
	      if (((cpi.ex.annul or cpi.ex.trap) = '0') and (ex.cpins = cpop)) 
		or (eu.status > free) 
	      then ldlock := '1'; end if;
	    end if;
	  end if;
	  if (ldlock = '0') then
	    ctrl.acsr := '1';
	    if op3 = STFSR then ctrl.cpins := store; 
	    else ctrl.cpins := load; end if;
	  end if;
        when STDFQ => 
	  if (rx.state = nominal) then 
	    rxv.state := excpend; rxv.csr.tt := "100";
	  else ctrl.cpins := store; end if;
        when others => null;
        end case;
      when others => null;
      end case;
    if ((cpi.flush or cpi.dtrap or cpi.dannul or ldlock) = '1') then
      ctrl.cpins := none; ctrl.acsr := '0';
      rxv.state := rx.state; rxv.csr.tt := rx.csr.tt; 
    end if;
    if ((cpi.flush or cpi.dtrap or cpi.dannul) = '1') then
      ldlock := '0';
    end if;

-------------------------------------------------------------
-- execute stage
-------------------------------------------------------------

    -- generate regfile addresses
    if holdn = '0' then
      op  := cpi.me.inst(31 downto 30);
      rd  := cpi.me.inst(29 downto 25);
      op3 := cpi.me.inst(24 downto 19);
      rs1 := cpi.me.inst(18 downto 14);
      rs2 := cpi.me.inst(4 downto 0);
    else
      op  := cpi.ex.inst(31 downto 30);
      rd  := cpi.ex.inst(29 downto 25);
      op3 := cpi.ex.inst(24 downto 19);
      rs1 := cpi.ex.inst(18 downto 14);
      rs2 := cpi.ex.inst(4 downto 0);
    end if;

    if (op = LDST) and (op3(2) = '1') then rs1 := rd; end if;

    rfi1.rd1addr(3 downto 0) <= rs1(4 downto 1); rfi1.rd2addr(3 downto 0) <= rs2(4 downto 1);
    rfi2.rd1addr(3 downto 0) <= rs1(4 downto 1); rfi2.rd2addr(3 downto 0) <= rs2(4 downto 1);
    rfi1.ren1 <= '1'; rfi1.ren2 <= '1'; rfi2.ren1 <= '1'; rfi2.ren2 <= '1';
    cpo.ldlock <= ldlock;

    op1 := rfo1.data1(31 downto 0) & rfo2.data1(31 downto 0);
    op2 := rfo1.data2(31 downto 0) & rfo2.data2(31 downto 0);

    -- generate store data
    if  (cpi.ex.inst(20 downto 19) = "10") then  -- STDFQ
      if (cpi.ex.cnt /= "10") then stdata := eu.pc(31 downto 2) & "00";
      else stdata := eu.inst; end if;
    elsif  ((cpi.ex.inst(25) = '0') and (cpi.ex.cnt /= "10")) then  -- STF/STDF
      stdata := op1(63 downto 32);
    else stdata := op1(31 downto 0); end if;
    if (ex.cpins = store) and (ex.acsr = '1') then		-- STFSR
      stdata :=  rx.csr.rd & "00" & rx.csr.tem & "000" & 
      	std_logic_vector(FPUVER) & rx.csr.tt & qne & '0' & rx.csr.cc & 
	rx.csr.aexc & rx.csr.cexc;
    end if;
    cpo.data <= stdata;

    -- check if an execution unit is available
    if (ex.cpins = cpop) and (holdn = '1') and (cpi.ex.annul = '0') then
      ccv := ccv or ex.wrcc;
      if (eu.status = free) or ((eu.status = ready) and (wb = '1')) then
	rxv.start := '1'; 
        euiv.start := '1';
        if cpi.flush = '0' then euv.status := started; end if;
	euv.rd := cpi.ex.inst(29 downto 25);
        euv.rs1 := cpi.ex.inst(18 downto 14);
        euv.rs2 := cpi.ex.inst(4 downto 0);
	euv.wreg := ex.wreg;
	euv.rreg1 := ex.rreg1;
	euv.rreg2 := ex.rreg2;
	euv.rs1d := ex.rs1d;
	euv.rs2d := ex.rs2d;
	euv.rdd := ex.rdd;
	euv.wrcc := ex.wrcc;
      else rxv.holdn := '0'; rv.start := '1'; end if;
    end if;  
    if cpi.flush = '1' then
      rxv.start := '0'; euiv.start := '0';
    end if;

-------------------------------------------------------------
-- memory stage
-------------------------------------------------------------

    euiv.load := rx.start or rx.starty;
    if (rx.holdn = '0') and  (xholdn = '1') and (cpi.flush = '0') and
        (euo.busy = '0')
    then
      euiv.start := not rx.startx;
      euiv.opcode := cpi.me.inst(19) & cpi.me.inst(13 downto 5);
    end if;
    if (rx.holdn = '0') and ((eu.status <= free) or (wb = '1'))
    then
      euiv.load := rx.starty;
      euiv.start := not (rx.starty or rx.startx);
      euv.status := started;
      euv.rs1 := cpi.me.inst(18 downto 14);
      euv.rs2 := cpi.me.inst(4 downto 0);
      euv.rd := cpi.me.inst(29 downto 25);
      euv.wreg := me.wreg;
      euv.rreg1 := me.rreg1;
      euv.rreg2 := me.rreg2;
      euv.rs1d := me.rs1d;
      euv.rs2d := me.rs2d;
      euv.rdd := me.rdd;
      euv.wrcc := me.wrcc;
      euiv.opcode := cpi.me.inst(19) & cpi.me.inst(13 downto 5);
      rxv.holdn := '1';
    end if;
    euiv.start := euiv.start and not cpi.flush;
    rxv.starty := euiv.start;
    rxv.startx := (rx.startx or euiv.start) and (not holdn) and not cpi.flush;
    ccv := ccv or me.wrcc;
    if (cpi.flush = '1') or (rx.state /= nominal) then rxv.holdn := '1'; end if;
    if holdn = '0' then rxv.wbok := rx.wbok; end if;
    if (me.cpins = cpop) and (holdn = '1') then
      if ((cpi.flush and not eu.wbok) = '1') then euv.rst := '1';
      else rxv.wbok := not cpi.me.annul; end if;
    end if;

    -- regfile bypass
    if (rx.waddr = cpi.me.inst(18 downto 15)) then
      if (rx.wren(0) = '1') then op1(63 downto 32) := rx.res(63 downto 32); end if;
      if (rx.wren(1) = '1') then op1(31 downto 0) := rx.res(31 downto 0); end if;
    end if;
    if (rx.waddr = cpi.me.inst(4 downto 1)) then
      if (rx.wren(0) = '1') then op2(63 downto 32) := rx.res(63 downto 32); end if;
      if (rx.wren(1) = '1') then op2(31 downto 0) := rx.res(31 downto 0); end if;
    end if;

    -- optionally forward data from write stage
    if rfi1.wren = '1' then
      if cpi.me.inst(18 downto 15) = rfi1.wraddr(3 downto 0) then 
        op1(63 downto 32) := rfi1.wrdata(31 downto 0);
      end if;
      if cpi.me.inst(4 downto 1) = rfi1.wraddr(3 downto 0) then 
        op2(63 downto 32) := rfi1.wrdata(31 downto 0);
      end if;
    end if;
    if rfi2.wren = '1' then
      if cpi.me.inst(18 downto 15) = rfi2.wraddr(3 downto 0) then 
        op1(31 downto 0) := rfi2.wrdata(31 downto 0);
      end if;
      if cpi.me.inst(4 downto 1) = rfi2.wraddr(3 downto 0) then 
        op2(31 downto 0) := rfi2.wrdata(31 downto 0);
      end if;
    end if;


    -- align single operands
    if me.rs1d = '0' then
      if cpi.me.inst(14) = '0' then op1 := op1(63 downto 32) & op1(63 downto 32);
      else op1 := op1(31 downto 0) & op1(31 downto 0); end if;
    end if;
    if me.rs2d = '0' then
      if cpi.me.inst(0) = '0' then op2 := op2(63 downto 32) & op2(63 downto 32);
      else op2 := op2(31 downto 0) & op2(31 downto 0); end if;
    end if;

    -- drive EU operand inputs
    euiv.op1 := op1; euiv.op2 := op2;

    cpo.holdn <= rx.holdn;

-------------------------------------------------------------
-- write stage
-------------------------------------------------------------

    wrdata := cpi.lddata & cpi.lddata;
    if (cpi.wr.annul or cpi.flush) = '0' then
      case wr.cpins is
      when load =>
        if (wr.wreg = '1') then
          if cpi.wr.cnt = "00" then
            wren(0) := not cpi.wr.inst(25);
            wren(1) := cpi.wr.inst(25); 
	  else wren(1) := '1'; end if;
        end if;
	if (wr.acsr and holdn) = '1' then 
	  rxv.csr.cexc := cpi.lddata(4 downto 0);
	  rxv.csr.aexc := cpi.lddata(9 downto 5);
	  rxv.csr.cc  := cpi.lddata(11 downto 10);
	  rxv.csr.tem  := cpi.lddata(27 downto 23);
	  rxv.csr.rd   := cpi.lddata(31 downto 30);
        end if;
      when store =>
	if wr.acsr = '1' then rxv.csr.tt := (others => '0'); end if;
        if (cpi.wr.inst(20 downto 19) = "10") then  -- STDFQ
          if qne = '1'then
            euv.status := free; euv.rst := '1'; euv.wbok := '0';
	  else
	    rxv.state := nominal;
	  end if;
	end if;
      when cpop =>
	-- dont assign PC and inst until here in case previous cpop trapped
        if holdn = '1' then euv.wbok := rx.wbok; end if;
          euv.inst := cpi.wr.inst;
          euv.pc := cpi.wr.pc;
      when others => null;
      end case;
    end if;
    if (wr.cpins = cpop) and (holdn = '1') and (eu.wbok = '0') and
       ((cpi.flush or cpi.wr.annul) = '1') 
    then
      if rx.state = nominal then euv.status := free; end if;
      euv.rst := '1'; euv.wbok := '0';
    end if;

    waddr := cpi.wr.inst(29 downto 26);

-------------------------------------------------------------
-- retire stage
-------------------------------------------------------------

    rtaddr := eu.rd(4 downto 1);
    if eu.rdd = '1' then rtdata := euo.res;
    else 
      rtdata(63 downto 32) := euo.res(63) & 
	  euo.res(59 downto 29);
      rtdata(31 downto 0) := rtdata(63 downto 32);
    end if;

    wren := wren and (holdn & holdn);

    if ((euo.exc(4 downto 0) and rx.csr.tem) /= "00000") or
       (euo.exc(5) = '1')
    then 
      cpexc := '1';
    end if;
    if (wren = "00") and (eu.status = ready) and (rx.state = nominal) and
    ((eu.wbok = '1') or ((cpi.flush = '0') and (rx.wbok = '1')))
    then
      waddr := rtaddr; wrdata := rtdata;
      euv.wbok := '0';
      if (holdn = '0') then rxv.wbok := '0'; end if;
      if cpexc = '0' then
        if (eu.wreg) = '1' then
          if (eu.rdd) = '1' then wren := "11";
	  else
            wren(0) := not eu.rd(0);
            wren(1) := eu.rd(0);
	  end if;
        end if;
        if eu.wrcc = '1' then
	  rxv.csr.cc := euo.cc;
        end if;
        rxv.csr.aexc := rx.csr.aexc or euo.exc(4 downto 0);
        if euv.status = ready then
          euv.status := free; 
        end if;
        wbv := '1';
        rxv.csr.cexc := euo.exc(4 downto 0);
      else
	rxv.state := excpend;
        if (euo.exc(5) = '1') then rxv.csr.tt := "011";
        else rxv.csr.tt := "001"; end if;
      end if;
    end if;  

    if cpi.exack = '1' then rxv.state := exception; end if;
    if rxv.state = excpend then cpo.exc <= '1'; else cpo.exc <= '0'; end if;
    cpo.ccv   <= not ccv;
    cpo.cc    <= rx.csr.cc;

    rxv.res := wrdata;
    rxv.waddr := waddr;
    rxv.wren := wren;
    rfi1.wraddr(3 downto 0) <= waddr;
    rfi2.wraddr(3 downto 0) <= waddr;
    rfi1.wren <= wren(0);
    rfi2.wren <= wren(1);
    rfi1.wrdata(31 downto 0) <= wrdata(63 downto 32);
    rfi2.wrdata(31 downto 0) <= wrdata(31 downto 0);


-- reset
    if rst = '0' then
      rxv.holdn := '1'; rv.start := '0';
      rxv.state := nominal; rxv.csr.tt := (others => '0');
      rxv.startx := '0'; euv.status := free; euv.wbok := '0';
    end if;

    euin <= euv;
    eui <= euiv;
    exin <= ctrl;
    rin <= rv;
    rxin <= rxv;
    wb <= wbv;

  end process;

-- registers

  regs : process(clk)
  variable pc : std_logic_vector(31 downto 0);
  begin

    if rising_edge(clk) then

      if holdn = '1' then
        ex <= exin; me <= ex; wr <= me; r <= rin;
      end if;
      rx <= rxin; eu <= euin;
-- pragma translate_off
	if DEBUGFPU then
	  if (rfi1.wren = '1') then
	    print("0x" & tosth(cpi.wr.pc(31 downto 2) & "00") & ": %f" & 
		tostd(rfi1.wraddr(3 downto 0) & '0') &
		" = " & tosth(rfi1.wrdata(31 downto 0)));
	  end if;
	  if (rfi2.wren = '1') then
	    print("0x" & tosth(cpi.wr.pc(31 downto 2) & "00") & ": %f" & 
		tostd(rfi1.wraddr(3 downto 0) & '1') &
		" = " & tosth(rfi2.wrdata(31 downto 0)));
	  end if;
	end if;
-- pragma translate_on
    end if;
  end process;


-- regfile

  rf0: regfile_cp generic map (4, 32, 16)
       port map (rst, clk, rfi1, rfo1); 

  rf1: regfile_cp generic map (4, 32, 16)
       port map (rst, clk, rfi2, rfo2);

  fpu0 : fpu_core port map (
      clk   => clk,
      fpui.FpInst     => eui.opcode,
      fpui.FpOp       => eui.start,
      fpui.FpLd       => eui.load,
      fpui.Reset      => eui.flush,
      fpui.fprf_dout1 => eui.op1,
      fpui.fprf_dout2 => eui.op2,
      fpui.RoundingMode => rx.csr.rd,
      fpui.ss_scan_mode => gnd,
      fpui.fp_ctl_scan_in => gnd,
      fpui.fpuholdn => gnd,
      fpuo.FpBusy    => euo.busy,
      fpuo.FracResult => euo.res(51 downto 0),
      fpuo.ExpResult  => euo.res(62 downto 52),
      fpuo.SignResult => euo.res(63),
      fpuo.SNnotDB    => snnotdb,
      fpuo.Excep      => euo.exc,
      fpuo.ConditionCodes => euo.cc,
      fpuo.fp_ctl_scan_out => fp_ctl_scan_out);

end;


