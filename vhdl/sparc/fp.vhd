
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
-- Description:	Parallel floating-point co-processor interface
-- The interface allows any number of parallel execution unit
-- As an example, two Meiko FPUs and two FMOVE units have been attached
------------------------------------------------------------------------------

-- FPU support unit - performs FMOVS, FNEGS, FABSS

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.conv_integer;
use work.leon_iface.all;

entity fpaux is
port (
    rst    : in  std_logic;			-- Reset
    clk    : in  std_logic;			-- clock
    eui    : in  cp_unit_in_type;		-- inputs
    euo    : out cp_unit_out_type		-- outputs
  );
end;

architecture rtl of fpaux is
type reg_type is record
  op       : std_logic_vector (31 downto 0); -- operand
  ins      : std_logic_vector (1 downto 0); -- operand
end record;

signal r, rin : reg_type;

begin

  comb: process(rst, eui, r)
  variable rv     : reg_type;
  variable ready  : std_logic;
  variable sign  : std_logic;
  begin

    rv := r;

    if eui.start = '1' then rv.ins := eui.opcode(3 downto 2); end if;
    if eui.load = '1' then rv.op := eui.op2(63 downto 32); end if;
    case r.ins is
    when "00" => sign := r.op(31);	-- fmovs
    when "01" => sign := not r.op(31); -- fnegs
    when others => sign := '0'; -- fabss
    end case;
    euo.res(63 downto 29) <= sign & "000" & r.op(30 downto 0);
    euo.res(28 downto 0) <= (others => '0');
    euo.busy <= '0';
    euo.exc <= (others => '0');
    euo.cc <= (others => '0');
    rin <= rv;
  end process;

-- registers

  regs : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process;
end;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.conv_integer;
use work.leon_config.all;
use work.leon_iface.all;
use work.sparcv8.all;
use work.ramlib.all;
use work.fpulib.all;
-- pragma translate_off
library MMS;
use MMS.stdioimp.all;
use STD.TEXTIO.all;
use work.debug.all;
-- pragma translate_on

entity fp is
port (
    rst    : in  std_logic;			-- Reset
    clk    : in  clk_type;			-- main clock	
    iuclk  : in  clk_type;			-- gated IU clock
    holdn  : in  std_logic;			-- pipeline hold
    xholdn : in  std_logic;			-- pipeline hold
    cpi    : in  cp_in_type;
    cpo    : out cp_out_type
  );
end;

architecture rtl of fp is

constant EUTYPES : integer := 1; -- number of execution unit types
--constant EUTYPES : integer := 1; -- number of execution unit types
constant EU1NUM  : integer := 2; -- number of execution unit 1 types
constant EU2NUM  : integer := 1; -- number of execution unit 2 types
constant EUMAX   : integer := 2; -- maximum number of any execution unit
--constant EUTOT   : integer := 2; -- total number of execution units
constant EUTOT   : integer := 2; -- total number of execution units
subtype euindex is integer range 0 to EUMAX-1;
subtype eumindex is integer range 0 to EUTOT-1;
subtype eutindex is integer range 0 to EUTYPES-1;
-- array to define how many execution units of each type
type euconf_arr is array (0 to 2) of euindex; -- one more than necessay to avoid modeltech bug
constant euconf : euconf_arr := (EU1NUM-1, EU2NUM-1,0);
--constant euconf : euconf_arr := (EU1NUM,1);
type eu_fifo_arr is array (0 to EUTOT-1) of eutindex;

type eu_fifo_type is record
    first : eumindex;
    last  : eumindex;
    fifo  : eu_fifo_arr;
end record;

type euq_type is record
    first : euindex;
    last  : euindex;
end record;

type euq_arr is array (0 to EUTYPES-1) of euq_type;

type rfi_type is record
    raddr1 : std_logic_vector (3 downto 0);
    raddr2 : std_logic_vector (3 downto 0);
    waddr  : std_logic_vector (3 downto 0);
    wdata  : std_logic_vector (63 downto 0);
    wren   : std_logic_vector(1 downto 0);
end record;

type rfo_type is record
    rdata1  : std_logic_vector (63 downto 0);
    rdata2  : std_logic_vector (63 downto 0);
end record;

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
  first    : euindex;
end record;

type unit_status_type is (exception, free, started, ready);
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
  wb       : std_logic;		-- result being written back
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
  eufirst  : euindex;
  eulast   : euindex;
  sdep     : std_logic;		-- data dependency ex/me/wr
  eut      : integer range 0 to EUTYPES-1; -- type EU to start
  eui      : integer range 0 to EUMAX-1; -- index EU to start
  start    : std_logic;		-- start EU
  weut     : integer range 0 to EUTYPES-1; -- write stage eut
  weui     : integer range 0 to EUMAX-1; -- write stage eui
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
  state    : execstate;		-- using rs1
end record;

type unit_ctrl_arr is array (0 to EUMAX-1) of unit_ctrl;
type unit_ctrl_arr_arr is array (0 to EUTYPES-1) of unit_ctrl_arr;
type eui_arr is array (0 to EUMAX-1) of cp_unit_in_type;
type euo_arr is array (0 to EUMAX-1) of cp_unit_out_type;
type eui_arr_arr is array (0 to EUTYPES) of eui_arr;
type euo_arr_arr is array (0 to EUTYPES) of euo_arr;
signal vcc, gnd : std_logic;
signal rfi : rfi_type;
signal rfo : rfo_type;
signal ex, exin, me, mein, wr, wrin : pl_ctrl;
signal r, rin  : reg_type;
signal rx, rxin  : regx_type;
signal eui : eui_arr_arr;
signal euo : euo_arr_arr;
signal eu, euin : unit_ctrl_arr_arr;
signal euq, euqin : euq_arr;
signal euf, eufin : eu_fifo_type;

component fpaux
port (
    rst    : in  std_logic;			-- Reset
    clk    : in  std_logic;			-- clock
    eui    : in  cp_unit_in_type;		-- inputs
    euo    : out cp_unit_out_type		-- outputs
  );
end component;

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

function ddepcheck (rs1, rs2 : std_logic_vector; 
	rreg1, rreg2, rs1d, rs2d : std_logic; eu : unit_ctrl_arr_arr; 
        euo : euo_arr_arr) return std_logic is
variable ddep : std_logic;
variable r1, r2 : std_logic_vector(4 downto 0);
begin
  ddep := '0'; r1 := rs1; r2 := rs2;
  for i in 0 to EUTYPES-1 loop
    for j in 0 to euconf(i) loop
      if (eu(i)(j).status = started) or (eu(i)(j).status = ready) then
        if rreg1 = '1' then ddep := ddep or srccheck(r1, rs1d, eu(i)(j)); end if;
        if rreg2 = '1' then ddep := ddep or srccheck(r2, rs2d, eu(i)(j)); end if;
      end if;
    end loop;
  end loop;
  return(ddep);
end;

begin

  vcc <= '1'; gnd <= '1';

-- instruction decoding

  pipeline : process(cpi, ex, me, wr, eu, euin, r, rx, rfi, rfo, holdn, xholdn,
			euo, euf, euq, rst)
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
  variable euv : unit_ctrl_arr_arr;
  variable euqv : euq_arr;
  variable euiv : eui_arr_arr;
  variable eufv : eu_fifo_type;
  variable euti : eumindex;
  variable euqi : euindex;
  variable ddep     : std_logic;
  variable cpexc    : std_logic;
  variable fpill    : std_logic;
  variable ccv      : std_logic;
  variable qne      : std_logic;
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

    rv := r; rxv := rx; ctrl.first := ex.first;
    ctrl.cpins := none; ctrl.wreg := '0'; ctrl.rdd := '0';
    ctrl.wrcc := '0'; ctrl.acsr := '0'; ldlock := '0';
    ctrl.rreg1 := '0'; ctrl.rreg2 := '0';
    ctrl.rs1d := '0'; ctrl.rs2d := '0'; fpill := '0';
    stdata := (others => '-'); wren := "00"; cpexc := '0';
    ccv := '0'; rv.start := '0';
    rv.weut := r.eut; rv.weui := r.eui;
    rxv.start := '0'; rv.eut := 0; rv.eui := 0; rv.sdep := '0';
    euv := eu; euqv := euq; eufv := euf;
    euti := euf.fifo(euf.last); euqi := euq(euti).last;
    if (euf.last /= euf.first) or (eu(euti)(euqi).status = exception)
    then qne := '1'; else qne := '0'; end if;

    for i in 0 to EUTYPES-1 loop
      for j in 0 to euconf(i) loop
        euiv(i)(j).opcode := cpi.ex.inst(19) & cpi.ex.inst(13 downto 5);
	euiv(i)(j).start := '0'; euiv(i)(j).load := '0';
	euiv(i)(j).flush := eu(i)(j).rst or euin(i)(j).rst;
	euv(i)(j).wb := '0';
	euv(i)(j).rst := not rst;
	if (eu(i)(j).status = started) and (euo(i)(j).busy = '0') then
	  euv(i)(j).status := ready;
	end if;
	if (eu(i)(j).status > free) then
	  ccv := ccv or eu(i)(j).wrcc;
	end if;
      end loop;
    end loop;

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
            for i in 0 to EUTYPES-1 loop	-- dst interlock
	      for j in 0 to euconf(i) loop
	        ldlock := ldlock or ldcheck(rd, ctrl.rdd, euin(i)(j));
 	      end loop;
            end loop;
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
	    for i in 0 to EUTYPES-1 loop
	      for j in 0 to euconf(i) loop
	        ldlock := ldlock or stcheck(rd, (op3(1) and op3(0)), euin(i)(j));
 	      end loop;
 	    end loop;
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
	      for i in 0 to EUTYPES-1 loop
	        for j in 0 to euconf(i) loop
                  if eu(i)(j).status > free then ldlock := '1'; end if;
 	        end loop;
 	      end loop;
	    end if;
	  end if;
-- FIX ME - add check for not yet commited cpins in pipeline
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
    if ((cpi.flush or cpi.dtrap or cpi.dannul) = '1') then
      ctrl.cpins := none;
      rxv.state := rx.state; rxv.csr.tt := rx.csr.tt;
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

    rfi.raddr1 <= rs1(4 downto 1); rfi.raddr2 <= rs2(4 downto 1);
    cpo.ldlock <= ldlock;

    op1 := rfo.rdata1; op2 := rfo.rdata2;

    -- generate store data
    if  (cpi.ex.inst(20 downto 19) = "10") then  -- STDFQ
      if (cpi.ex.cnt /= "10") then stdata := eu(euti)(euqi).pc;
      else stdata := eu(euti)(euqi).inst; end if;
    elsif  ((cpi.ex.inst(25) = '0') and (cpi.ex.cnt /= "10")) then  -- STF/STDF
      stdata := op1(63 downto 32);
    else stdata := op1(31 downto 0); end if;
    if (ex.cpins = store) and (ex.acsr = '1') then		-- STFSR
      stdata :=  rx.csr.rd & "00" & rx.csr.tem & "000" & FPUVER &
	rx.csr.tt & qne & '0' & rx.csr.cc & rx.csr.aexc & rx.csr.cexc;
    end if;
    cpo.data <= stdata;

    -- check for source operand dependency with scheduled instructions
    if (ex.cpins = cpop) then
      rv.sdep := ddepcheck(cpi.ex.inst(18 downto 14), cpi.ex.inst(4 downto 0),
		ex.rreg1, ex.rreg2, ex.rs1d, ex.rs2d, eu, euo);
    end if;

    -- select execution unit type
    if (cpi.ex.inst(12 downto 9) = "0000") and (EUTYPES > 1) then 
      rv.eut := EUTYPES-1;	-- use exection unit 1
    else 
      rv.eut := 0;	-- use exection unit 0
    end if;

    -- check if an execution unit is available
    if (ex.cpins = cpop) and (holdn = '1') and (cpi.flush = '0') then
      rv.eui := euq(rv.eut).first;
      ccv := ccv or ex.wrcc;
      if (rv.sdep = '0') and (eu(rv.eut)(euq(rv.eut).first).status = free) 
      then
	rxv.start := '1'; 
        euiv(rv.eut)(rv.eui).start := '1';
	euv(rv.eut)(rv.eui).status := started;
	euv(rv.eut)(rv.eui).rd := cpi.ex.inst(29 downto 25);
        euv(rv.eut)(rv.eui).rs1 := cpi.ex.inst(18 downto 14);
        euv(rv.eut)(rv.eui).rs2 := cpi.ex.inst(4 downto 0);
	euv(rv.eut)(rv.eui).wreg := ex.wreg;
	euv(rv.eut)(rv.eui).rreg1 := ex.rreg1;
	euv(rv.eut)(rv.eui).rreg2 := ex.rreg2;
	euv(rv.eut)(rv.eui).rs1d := ex.rs1d;
	euv(rv.eut)(rv.eui).rs2d := ex.rs2d;
	euv(rv.eut)(rv.eui).rdd := ex.rdd;
	euv(rv.eut)(rv.eui).wrcc := ex.wrcc;
      else rxv.holdn := '0'; rv.start := '1'; end if;
      ctrl.first := euf.first;
      eufv.fifo(euf.first) := rv.eut;
      if euq(rv.eut).first = euconf(rv.eut) then euqv(rv.eut).first := 0;
      else euqv(rv.eut).first := euqv(rv.eut).first + 1; end if;
      if euf.first = (EUTOT-1) then eufv.first := 0;
      else eufv.first := eufv.first + 1; end if;
    end if;  

-------------------------------------------------------------
-- memory stage
-------------------------------------------------------------

    ddep  := ddepcheck(cpi.me.inst(18 downto 14), cpi.me.inst(4 downto 0),
		me.rreg1, me.rreg2, me.rs1d, me.rs2d, eu, euo);

    euiv(r.eut)(r.eui).load := rx.start or rx.starty;
    if (rx.holdn = '0') and  (xholdn = '1') and (cpi.flush = '0') and
        ((r.sdep and ddep) = '0') and (euo(r.eut)(euq(r.eut).first).busy = '0')
    then
      euiv(r.eut)(r.eui).start := not rx.startx;
      euiv(r.eut)(r.eui).opcode := cpi.me.inst(19) & cpi.me.inst(13 downto 5);
    end if;
    if (rx.holdn = '0') and (cpi.flush = '0') and
	(not ((r.sdep = '1') and (ddep = '1'))) and
        ((eu(r.eut)(r.eui).status <= free) or
        (euin(r.eut)(r.eui).wb = '1'))
    then
      euiv(r.eut)(r.eui).load := rx.starty;
      euiv(r.eut)(r.eui).start := not (rx.starty or rx.startx);
      if eu(r.eut)(r.eui).status /= exception then
        euv(r.eut)(r.eui).status := started;
      end if;
      euv(r.eut)(r.eui).rs1 := cpi.me.inst(18 downto 14);
      euv(r.eut)(r.eui).rs2 := cpi.me.inst(4 downto 0);
      euv(r.eut)(r.eui).rd := cpi.me.inst(29 downto 25);
      euv(r.eut)(r.eui).wreg := me.wreg;
      euv(r.eut)(r.eui).rreg1 := me.rreg1;
      euv(r.eut)(r.eui).rreg2 := me.rreg2;
      euv(r.eut)(r.eui).rs1d := me.rs1d;
      euv(r.eut)(r.eui).rs2d := me.rs2d;
      euv(r.eut)(r.eui).rdd := me.rdd;
      euv(r.eut)(r.eui).wrcc := me.wrcc;
      euiv(r.eut)(r.eui).opcode := cpi.me.inst(19) & cpi.me.inst(13 downto 5);
      rxv.holdn := '1';
    end if;
    rxv.starty := euiv(r.eut)(r.eui).start;
    rxv.startx := (rx.startx or euiv(r.eut)(r.eui).start) and not holdn;
    ccv := ccv or me.wrcc;
    if cpi.flush = '1' then rxv.holdn := '1'; end if;

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
    if rfi.wren(0) = '1' then
      if cpi.me.inst(18 downto 15) = rfi.waddr then 
        op1(63 downto 32) := rfi.wdata(63 downto 32);
      end if;
      if cpi.me.inst(4 downto 1) = rfi.waddr then 
        op2(63 downto 32) := rfi.wdata(63 downto 32);
      end if;
    end if;
    if rfi.wren(1) = '1' then
      if cpi.me.inst(18 downto 15) = rfi.waddr then 
        op1(31 downto 0) := rfi.wdata(31 downto 0);
      end if;
      if cpi.me.inst(4 downto 1) = rfi.waddr then 
        op2(31 downto 0) := rfi.wdata(31 downto 0);
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
    for i in 0 to EUTYPES-1 loop
      for j in 0 to euconf(i) loop
        euiv(i)(j).op1 := op1; euiv(i)(j).op2 := op2;
      end loop;
    end loop;

    cpo.holdn <= rx.holdn;

-------------------------------------------------------------
-- write stage
-------------------------------------------------------------

    wrdata := cpi.lddata & cpi.lddata;
    if cpi.flush = '0' then
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
            euv(euti)(euqi).status := free;
            euv(euti)(euqi).rst := '1';
            if euq(euti).last = euconf(euti) then euqv(euti).last := 0;
            else euqv(euti).last := euqv(euti).last + 1; end if;
            if (euf.last /= euf.first) then
              if euf.last = (EUTOT-1) then eufv.last := 0;
              else eufv.last := eufv.last + 1; end if;
	    end if;
	  else
	    rxv.state := nominal;
	  end if;
	end if;
      when cpop =>
	-- dont assign PC and inst until here in case previous cpop trapped
        euv(r.weut)(r.weui).inst := cpi.wr.inst;
        euv(r.weut)(r.weui).pc := cpi.wr.pc;
      when others => null;
      end case;
    end if;

-- flush EU if trap was taken
    if ((holdn and cpi.flush) = '1') and (EUTOT > 1) then
      case wr.cpins is
      when cpop =>
        if eu(r.weut)(r.weui).status /= exception then
	  euv(r.weut)(r.weui).rst := '1';
	  euv(r.weut)(r.weui).status := free;
        end if;
      eufv.first := wr.first;
      euqv(r.eut).first := r.eut;
      euqv(r.weut).first := r.weut;
      when others => null;
      end case;
    end if;
    waddr := cpi.wr.inst(29 downto 26);

-------------------------------------------------------------
-- retire stage
-------------------------------------------------------------

    rtaddr := eu(euti)(euqi).rd(4 downto 1);
    if eu(euti)(euqi).rdd = '1' then rtdata := euo(euti)(euqi).res;
    else 
      rtdata(63 downto 32) := euo(euti)(euqi).res(63) & 
	  euo(euti)(euqi).res(59 downto 29);
      rtdata(31 downto 0) := rtdata(63 downto 32);
    end if;

    wren := wren and (holdn & holdn);

    if ((euo(euti)(euqi).exc(4 downto 0) and rx.csr.tem) /= "00000") or
       (euo(euti)(euqi).exc(5) = '1')
    then 
      cpexc := '1';
    end if;
    if (wren = "00") and (eu(euti)(euqi).status = ready) and 
      (rx.state = nominal) 
    then
      waddr := rtaddr; wrdata := rtdata;
      if cpexc = '0' then
        if (eu(euti)(euqi).wreg) = '1' then
          if (eu(euti)(euqi).rdd) = '1' then wren := "11";
	  else
            wren(0) := not eu(euti)(euqi).rd(0);
            wren(1) := eu(euti)(euqi).rd(0);
	  end if;
        end if;
        if eu(euti)(euqi).wrcc = '1' then
	  rxv.csr.cc := euo(euti)(euqi).cc;
        end if;
        rxv.csr.aexc := rx.csr.aexc or euo(euti)(euqi).exc(4 downto 0);
        if euv(euti)(euqi).status = ready then
          euv(euti)(euqi).status := free;
        end if;
        euv(euti)(euqi).wb := '1';
        rxv.csr.cexc := euo(euti)(euqi).exc(4 downto 0);
        if euq(euti).last = euconf(euti) then euqv(euti).last := 0;
        else euqv(euti).last := euqv(euti).last + 1; end if;
        if euf.last = (EUTOT-1) then eufv.last := 0;
        else eufv.last := eufv.last + 1; end if;
      else
        euv(euti)(euqi).status := exception;
	rxv.state := excpend;
        if (euo(euti)(euqi).exc(5) = '1') then rxv.csr.tt := "011";
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
    rfi.waddr <= waddr;
    rfi.wren <= wren;
    rfi.wdata <= wrdata;


-- reset
    if rst = '0' then
      for i in 0 to EUTYPES-1 loop
        for j in 0 to euconf(i) loop euv(i)(j).status := free; end loop;
        euqv(i).first := 0; euqv(i).last  := 0;
      end loop;
      eufv.first := 0; eufv.last := 0; rxv.holdn := '1'; rv.start := '0';
      rxv.state := nominal; rxv.csr.tt := (others => '0');
      rxv.startx := '0';
      ctrl.first := 0;
    end if;

    euin <= euv;
    eui <= euiv;
    eufin <= eufv;
    euqin <= euqv;
    exin <= ctrl;
    rin <= rv;
    rxin <= rxv;

  end process;

-- registers

  regs : process(clk)
  variable pc : std_logic_vector(31 downto 0);
  begin
    if rising_edge(clk(0)) then
      if holdn = '1' then
        ex <= exin; me <= ex; wr <= me; r <= rin;
      end if;
      euq <= euqin; euf <= eufin;
      rx <= rxin; eu <= euin;
-- pragma translate_off
	if DEBUGFPU then
          if euin(euf.fifo(euf.last))(euq(euf.fifo(euf.last)).last).wb = '1' then
            pc := eu(euf.fifo(euf.last))(euq(euf.fifo(euf.last)).last).pc;
	  else pc := cpi.wr.pc; end if;
	  if (rfi.wren(0) = '1') then
	    print(tost(pc) & ": %f" & tost("000" & rfi.waddr & '0') &
		" = " & tost(rfi.wdata(63 downto 32)));
	  end if;
	  if (rfi.wren(1) = '1') then
	    print(tost(pc) & ": %f" & tost("000" & rfi.waddr & '1') &
		" = " & tost(rfi.wdata(31 downto 0)));
	  end if;
	end if;
-- pragma translate_on
    end if;
  end process;

-- simple 3-port register file made up of 4 parallel dprams

  dp00: dpram_synp_ss generic map (4, 32, 16)
	port map (rfi.wdata(63 downto 32), rfi.raddr1, rfi.waddr, vcc, rfi.wren(0), 
		      clk(0), vcc, rfo.rdata1(63 downto 32));
  dp01: dpram_synp_ss generic map (4, 32, 16)
	port map (rfi.wdata(31 downto 0), rfi.raddr1, rfi.waddr, vcc, rfi.wren(1), 
		      clk(0), vcc, rfo.rdata1(31 downto 0));
  dp10: dpram_synp_ss generic map (4, 32, 16)
	port map (rfi.wdata(63 downto 32), rfi.raddr2, rfi.waddr, vcc, rfi.wren(0), 
		      clk(0), vcc, rfo.rdata2(63 downto 32));
  dp11: dpram_synp_ss generic map (4, 32, 16)
	port map (rfi.wdata(31 downto 0), rfi.raddr2, rfi.waddr, vcc, rfi.wren(1), 
		      clk(0), vcc, rfo.rdata2(31 downto 0));

  gl0 : for i in 0 to euconf(0) generate
      fpu0 : fpu port map (
      ss_clock   => clk(0),
      FpInst     => eui(0)(i).opcode,
      FpOp       => eui(0)(i).start,
      FpLd       => eui(0)(i).load,
      Reset      => eui(0)(i).flush,
      fprf_dout1 => eui(0)(i).op1,
      fprf_dout2 => eui(0)(i).op2,
      RoundingMode => rx.csr.rd,
      FpBusy    => euo(0)(i).busy,
      FracResult => euo(0)(i).res(51 downto 0),
      ExpResult  => euo(0)(i).res(62 downto 52),
      SignResult => euo(0)(i).res(63),
      SNnotDB    => open,
      Excep      => euo(0)(i).exc,
      ConditionCodes => euo(0)(i).cc,
      ss_scan_mode => gnd,
      fp_ctl_scan_in => gnd,
      fp_ctl_scan_out => open);
  end generate;

  fpauxgen : if EUTYPES > 1 generate
    gl1 : for i in 0 to euconf(1) generate
      eu1 : fpaux port map (rst, clk(0), eui(1)(i), euo(1)(i));
    end generate;
  end generate;

end;


