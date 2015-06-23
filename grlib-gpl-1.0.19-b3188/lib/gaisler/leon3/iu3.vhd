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
-- Entity: 	iu3
-- File:	iu3.vhd
-- Author:	Jiri Gaisler, Edvin Catovic, Gaisler Research
-- Description:	LEON3 7-stage integer pipline
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.sparc.all;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.leon3.all;
use gaisler.libiu.all;
use gaisler.arith.all;
-- pragma translate_off
use grlib.sparc_disas.all;
-- pragma translate_on

entity iu3 is
  generic (
    nwin     : integer range 2 to 32 := 8;
    isets    : integer range 1 to 4 := 1;
    dsets    : integer range 1 to 4 := 1;
    fpu      : integer range 0 to 15 := 0;
    v8       : integer range 0 to 63 := 0;
    cp, mac  : integer range 0 to 1 := 0;
    dsu      : integer range 0 to 1 := 0;
    nwp      : integer range 0 to 4 := 0;
    pclow    : integer range 0 to 2 := 2;
    notag    : integer range 0 to 1 := 0;
    index    : integer range 0 to 15:= 0;
    lddel    : integer range 1 to 2 := 2;
    irfwt    : integer range 0 to 1 := 0;
    disas    : integer range 0 to 2 := 0;
    tbuf     : integer range 0 to 64 := 0;  -- trace buf size in kB (0 - no trace buffer)
    pwd      : integer range 0 to 2 := 0;   -- power-down
    svt      : integer range 0 to 1 := 0;   -- single-vector trapping
    rstaddr  : integer := 16#00000#;        -- reset vector MSB address
    smp      : integer range 0 to 15 := 0;  -- support SMP systems
    fabtech  : integer range 0 to NTECH := 0;
    clk2x    : integer := 0
  );
  port (
    clk   : in  std_ulogic;
    rstn  : in  std_ulogic;
    holdn : in  std_ulogic;
    ici   : out icache_in_type;
    ico   : in  icache_out_type;
    dci   : out dcache_in_type;
    dco   : in  dcache_out_type;
    rfi   : out iregfile_in_type;
    rfo   : in  iregfile_out_type;
    irqi  : in  l3_irq_in_type;
    irqo  : out l3_irq_out_type;
    dbgi  : in  l3_debug_in_type;
    dbgo  : out l3_debug_out_type;
    muli  : out mul32_in_type;
    mulo  : in  mul32_out_type;
    divi  : out div32_in_type;
    divo  : in  div32_out_type;
    fpo   : in  fpc_out_type;
    fpi   : out fpc_in_type;
    cpo   : in  fpc_out_type;
    cpi   : out fpc_in_type;
    tbo   : in  tracebuf_out_type;
    tbi   : out tracebuf_in_type;
    sclk   : in  std_ulogic
    );
end;

architecture rtl of iu3 is

  constant ISETMSB : integer := log2x(isets)-1;
  constant DSETMSB : integer := log2x(dsets)-1;
  constant RFBITS : integer range 6 to 10 := log2(NWIN+1) + 4;
  constant NWINLOG2   : integer range 1 to 5 := log2(NWIN);
  constant CWPOPT : boolean := (NWIN = (2**NWINLOG2));
  constant CWPMIN : std_logic_vector(NWINLOG2-1 downto 0) := (others => '0');
  constant CWPMAX : std_logic_vector(NWINLOG2-1 downto 0) := 
  	conv_std_logic_vector(NWIN-1, NWINLOG2);
  constant FPEN   : boolean := (fpu /= 0);
  constant CPEN   : boolean := (cp = 1);
  constant MULEN  : boolean := (v8 /= 0);
  constant MULTYPE: integer := (v8 / 16);
  constant DIVEN  : boolean := (v8 /= 0);
  constant MACEN  : boolean := (mac = 1);
  constant MACPIPE: boolean := (mac = 1) and (v8/2 = 1);
  constant IMPL   : integer := 15;
  constant VER    : integer := 3;
  constant DBGUNIT : boolean := (dsu = 1);
  constant TRACEBUF   : boolean := (tbuf /= 0);
  constant TBUFBITS : integer := 10 + log2(tbuf) - 4;
  constant PWRD1  : boolean := false; --(pwd = 1) and not (index /= 0);
  constant PWRD2  : boolean := pwd /= 0; --(pwd = 2) or (index /= 0);
  constant RS1OPT : boolean := (is_fpga(FABTECH) /= 0);
  constant DYNRST : boolean := (rstaddr = 16#FFFFF#);
  
  subtype word is std_logic_vector(31 downto 0);
  subtype pctype is std_logic_vector(31 downto PCLOW);
  subtype rfatype is std_logic_vector(RFBITS-1 downto 0);
  subtype cwptype is std_logic_vector(NWINLOG2-1 downto 0);
  type icdtype is array (0 to isets-1) of word;
  type dcdtype is array (0 to dsets-1) of word;

  type dc_in_type is record
    signed, enaddr, read, write, lock , dsuen : std_ulogic;
    size : std_logic_vector(1 downto 0);
    asi  : std_logic_vector(7 downto 0);    
  end record;
  
  type pipeline_ctrl_type is record
    pc    : pctype;
    inst  : word;
    cnt   : std_logic_vector(1 downto 0);
    rd    : rfatype;
    tt    : std_logic_vector(5 downto 0);
    trap  : std_ulogic;
    annul : std_ulogic;
    wreg  : std_ulogic;
    wicc  : std_ulogic;
    wy    : std_ulogic;
    ld    : std_ulogic;
    pv    : std_ulogic;
    rett  : std_ulogic;
  end record;
  
  type fetch_reg_type is record
    pc     : pctype;
    branch : std_ulogic;
  end record;
  
  type decode_reg_type is record
    pc    : pctype;
    inst  : icdtype;
    cwp   : cwptype;
    set   : std_logic_vector(ISETMSB downto 0);
    mexc  : std_ulogic;
    cnt   : std_logic_vector(1 downto 0);
    pv    : std_ulogic;
    annul : std_ulogic;
    inull : std_ulogic;
    step  : std_ulogic;        
  end record;
  
  type regacc_reg_type is record
    ctrl  : pipeline_ctrl_type;
    rs1   : std_logic_vector(4 downto 0);
    rfa1, rfa2 : rfatype;
    rsel1, rsel2 : std_logic_vector(2 downto 0);
    rfe1, rfe2 : std_ulogic;
    cwp   : cwptype;
    imm   : word;
    ldcheck1 : std_ulogic;
    ldcheck2 : std_ulogic;
    ldchkra : std_ulogic;
    ldchkex : std_ulogic;
    su : std_ulogic;
    et : std_ulogic;
    wovf : std_ulogic;
    wunf : std_ulogic;
    ticc : std_ulogic;
    jmpl : std_ulogic;
    step  : std_ulogic;            
    mulstart : std_ulogic;            
    divstart : std_ulogic;            
  end record;
  
  type execute_reg_type is record
    ctrl   : pipeline_ctrl_type;
    op1    : word;
    op2    : word;
    aluop  : std_logic_vector(2 downto 0);  	-- Alu operation
    alusel : std_logic_vector(1 downto 0);  	-- Alu result select
    aluadd : std_ulogic;
    alucin : std_ulogic;
    ldbp1, ldbp2 : std_ulogic;
    invop2 : std_ulogic;
    shcnt  : std_logic_vector(4 downto 0);  	-- shift count
    sari   : std_ulogic;				-- shift msb
    shleft : std_ulogic;				-- shift left/right
    ymsb   : std_ulogic;				-- shift left/right
    rd 	   : std_logic_vector(4 downto 0);
    jmpl   : std_ulogic;
    su     : std_ulogic;
    et     : std_ulogic;
    cwp    : cwptype;
    icc    : std_logic_vector(3 downto 0);
    mulstep: std_ulogic;            
    mul    : std_ulogic;            
    mac    : std_ulogic;
  end record;
  
  type memory_reg_type is record
    ctrl   : pipeline_ctrl_type;
    result : word;
    y      : word;
    icc    : std_logic_vector(3 downto 0);
    nalign : std_ulogic;
    dci	   : dc_in_type;
    werr   : std_ulogic;
    wcwp   : std_ulogic;
    irqen  : std_ulogic;
    irqen2 : std_ulogic;
    mac    : std_ulogic;
    divz   : std_ulogic;
    su     : std_ulogic;
    mul    : std_ulogic;
  end record;

  type exception_state is (run, trap, dsu1, dsu2);
  
  type exception_reg_type is record
    ctrl   : pipeline_ctrl_type;
    result : word;
    y      : word;
    icc    : std_logic_vector( 3 downto 0);
    annul_all : std_ulogic;
    data   : dcdtype;
    set    : std_logic_vector(DSETMSB downto 0);
    mexc   : std_ulogic;
    dci	   : dc_in_type;
    laddr  : std_logic_vector(1 downto 0);
    rstate : exception_state;
    npc    : std_logic_vector(2 downto 0);
    intack : std_ulogic;
    ipend  : std_ulogic;
    mac    : std_ulogic;
    debug  : std_ulogic;
    nerror : std_ulogic;
  end record;

  type dsu_registers is record
    tt      : std_logic_vector(7 downto 0);
    err     : std_ulogic;
    tbufcnt : std_logic_vector(TBUFBITS-1 downto 0);
    asi     : std_logic_vector(7 downto 0);
    crdy    : std_logic_vector(2 downto 1);  -- diag cache access ready
  end record;

  type irestart_register is record
    addr   : pctype;
    pwd    : std_ulogic;
  end record;
  
  type pwd_register_type is record
    pwd    : std_ulogic;
    error  : std_ulogic;
  end record;

  type special_register_type is record
    cwp    : cwptype;                             -- current window pointer
    icc    : std_logic_vector(3 downto 0);	  -- integer condition codes
    tt     : std_logic_vector(7 downto 0);	  -- trap type
    tba    : std_logic_vector(19 downto 0);	  -- trap base address
    wim    : std_logic_vector(NWIN-1 downto 0);   -- window invalid mask
    pil    : std_logic_vector(3 downto 0);	  -- processor interrupt level
    ec     : std_ulogic;			   -- enable CP 
    ef     : std_ulogic;			   -- enable FP 
    ps     : std_ulogic;			   -- previous supervisor flag
    s      : std_ulogic;			   -- supervisor flag
    et     : std_ulogic;			   -- enable traps
    y      : word;
    asr18  : word;
    svt    : std_ulogic;			   -- enable traps
    dwt    : std_ulogic;			   -- disable write error trap
  end record;
  
  type write_reg_type is record
    s      : special_register_type;
    result : word;
    wa     : rfatype;
    wreg   : std_ulogic;
    except : std_ulogic;
  end record;

  type registers is record
    f  : fetch_reg_type;
    d  : decode_reg_type;
    a  : regacc_reg_type;
    e  : execute_reg_type;
    m  : memory_reg_type;
    x  : exception_reg_type;
    w  : write_reg_type;
  end record;

  type exception_type is record
    pri   : std_ulogic;
    ill   : std_ulogic;
    fpdis : std_ulogic;
    cpdis : std_ulogic;
    wovf  : std_ulogic;
    wunf  : std_ulogic;
    ticc  : std_ulogic;
  end record;

  type watchpoint_register is record
    addr    : std_logic_vector(31 downto 2);  -- watchpoint address
    mask    : std_logic_vector(31 downto 2);  -- watchpoint mask
    exec    : std_ulogic;			    -- trap on instruction
    load    : std_ulogic;			    -- trap on load
    store   : std_ulogic;			    -- trap on store
  end record;

  type watchpoint_registers is array (0 to 3) of watchpoint_register;

  constant wpr_none : watchpoint_register := (
	zero32(31 downto 2), zero32(31 downto 2), '0', '0', '0');

  function dbgexc(r  : registers; dbgi : l3_debug_in_type; trap : std_ulogic; tt : std_logic_vector(7 downto 0)) return std_ulogic is
    variable dmode : std_ulogic;
  begin
    dmode := '0';
    if (not r.x.ctrl.annul and trap) = '1' then
      if (((tt = "00" & TT_WATCH) and (dbgi.bwatch = '1')) or
          ((dbgi.bsoft = '1') and (tt = "10000001")) or
          (dbgi.btrapa = '1') or
          ((dbgi.btrape = '1') and not ((tt(5 downto 0) = TT_PRIV) or 
	    (tt(5 downto 0) = TT_FPDIS) or (tt(5 downto 0) = TT_WINOF) or
            (tt(5 downto 0) = TT_WINUF) or (tt(5 downto 4) = "01") or (tt(7) = '1'))) or 
          (((not r.w.s.et) and dbgi.berror) = '1')) then
        dmode := '1';
      end if;
    end if;
    return(dmode);
  end;
                    
  function dbgerr(r : registers; dbgi : l3_debug_in_type;
                  tt : std_logic_vector(7 downto 0))
  return std_ulogic is
    variable err : std_ulogic;
  begin
    err := not r.w.s.et;
    if (((dbgi.dbreak = '1') and (tt = ("00" & TT_WATCH))) or
        ((dbgi.bsoft = '1') and (tt = ("10000001")))) then
      err := '0';
    end if;
    return(err);
  end;
  
  procedure diagwr(r    : in registers;
                   dsur : in dsu_registers;
                   ir   : in irestart_register;
                   dbg  : in l3_debug_in_type;
                   wpr  : in watchpoint_registers;
                   s    : out special_register_type;
                   vwpr : out watchpoint_registers;
                   asi : out std_logic_vector(7 downto 0);
                   pc, npc  : out pctype;
                   tbufcnt : out std_logic_vector(TBUFBITS-1 downto 0);
                   wr : out std_ulogic;
                   addr : out std_logic_vector(9 downto 0);
                   data : out word;
                   fpcwr : out std_ulogic) is
  variable i : integer range 0 to 3;
  begin
    s := r.w.s; pc := r.f.pc; npc := ir.addr; wr := '0';
    vwpr := wpr; asi := dsur.asi; addr := (others => '0');
    data := dbg.ddata;
    tbufcnt := dsur.tbufcnt; fpcwr := '0';
      if (dbg.dsuen and dbg.denable and dbg.dwrite) = '1' then
        case dbg.daddr(23 downto 20) is
          when "0001" =>
            if (dbg.daddr(16) = '1') and TRACEBUF then -- trace buffer control reg
              tbufcnt := dbg.ddata(TBUFBITS-1 downto 0);
            end if;
          when "0011" => -- IU reg file
            if dbg.daddr(12) = '0' then
              wr := '1';
              addr := (others => '0');
              addr(RFBITS-1 downto 0) := dbg.daddr(RFBITS+1 downto 2);
            else  -- FPC
              fpcwr := '1';
            end if;
          when "0100" => -- IU special registers
            case dbg.daddr(7 downto 6) is
              when "00" => -- IU regs Y - TBUF ctrl reg
                case dbg.daddr(5 downto 2) is
                  when "0000" => -- Y
                    s.y := dbg.ddata;
                  when "0001" => -- PSR
                    s.cwp := dbg.ddata(NWINLOG2-1 downto 0);
                    s.icc := dbg.ddata(23 downto 20);
                    s.ec  := dbg.ddata(13);
                    if FPEN then s.ef := dbg.ddata(12); end if;
                    s.pil := dbg.ddata(11 downto 8);
                    s.s   := dbg.ddata(7);
                    s.ps  := dbg.ddata(6);
                    s.et  := dbg.ddata(5);
                  when "0010" => -- WIM
                    s.wim := dbg.ddata(NWIN-1 downto 0);
                  when "0011" => -- TBR
                    s.tba := dbg.ddata(31 downto 12);
                    s.tt  := dbg.ddata(11 downto 4);
                  when "0100" => -- PC
                    pc := dbg.ddata(31 downto PCLOW);
                  when "0101" => -- NPC
                    npc := dbg.ddata(31 downto PCLOW);
                  when "0110" => --FSR
                    fpcwr := '1';
                  when "0111" => --CFSR
                  when "1001" => -- ASI reg
                    asi := dbg.ddata(7 downto 0);
                  --when "1001" => -- TBUF ctrl reg
                  --  tbufcnt := dbg.ddata(TBUFBITS-1 downto 0);
                  when others =>
                end case;
              when "01" => -- ASR16 - ASR31
		case dbg.daddr(5 downto 2) is
		when "0001" =>	-- %ASR17
	    	  s.dwt := dbg.ddata(14);
	    	  s.svt := dbg.ddata(13);
		when "0010" =>	-- %ASR18
		  if MACEN then s.asr18 := dbg.ddata; end if;
		when "1000" => 		-- %ASR24 - %ASR31
                  vwpr(0).addr := dbg.ddata(31 downto 2);
                  vwpr(0).exec := dbg.ddata(0); 
		when "1001" =>
                  vwpr(0).mask := dbg.ddata(31 downto 2);
                  vwpr(0).load := dbg.ddata(1);
                  vwpr(0).store := dbg.ddata(0);              
		when "1010" =>
                  vwpr(1).addr := dbg.ddata(31 downto 2);
                  vwpr(1).exec := dbg.ddata(0); 
		when "1011" =>
                  vwpr(1).mask := dbg.ddata(31 downto 2);
                  vwpr(1).load := dbg.ddata(1);
                  vwpr(1).store := dbg.ddata(0);              
		when "1100" =>
                  vwpr(2).addr := dbg.ddata(31 downto 2);
                  vwpr(2).exec := dbg.ddata(0); 
		when "1101" =>
                  vwpr(2).mask := dbg.ddata(31 downto 2);
                  vwpr(2).load := dbg.ddata(1);
                  vwpr(2).store := dbg.ddata(0);              
		when "1110" =>
                  vwpr(3).addr := dbg.ddata(31 downto 2);
                  vwpr(3).exec := dbg.ddata(0); 
		when "1111" => -- 
                  vwpr(3).mask := dbg.ddata(31 downto 2);
                  vwpr(3).load := dbg.ddata(1);
                  vwpr(3).store := dbg.ddata(0);              
		when others => -- 
		end case;
-- disabled due to bug in XST
--                  i := conv_integer(dbg.daddr(4 downto 3)); 
--                  if dbg.daddr(2) = '0' then
--                    vwpr(i).addr := dbg.ddata(31 downto 2);
--                    vwpr(i).exec := dbg.ddata(0); 
--                  else
--                    vwpr(i).mask := dbg.ddata(31 downto 2);
--                    vwpr(i).load := dbg.ddata(1);
--                    vwpr(i).store := dbg.ddata(0);              
--                  end if;                    
              when others =>
            end case;
          when others =>
        end case;
      end if;
  end;

  function asr17_gen ( r : in registers) return word is
  variable asr17 : word;
  variable fpu2 : integer range 0 to 3;
  begin
    asr17 := zero32;    
    asr17(31 downto 28) := conv_std_logic_vector(index, 4);
    if (clk2x > 8) then
      asr17(16 downto 15) := conv_std_logic_vector(clk2x-8, 2);
      asr17(17) := '1'; 
    elsif (clk2x > 0) then
      asr17(16 downto 15) := conv_std_logic_vector(clk2x, 2);
    end if;
    asr17(14) := r.w.s.dwt;
    if svt = 1 then asr17(13) := r.w.s.svt; end if;
    if lddel = 2 then asr17(12) := '1'; end if;
    if (fpu > 0) and (fpu < 8) then fpu2 := 1;
    elsif (fpu >= 8) and (fpu < 15) then fpu2 := 3;                          
    elsif fpu = 15 then fpu2 := 2;
    else fpu2 := 0; end if; 
    asr17(11 downto 10) := conv_std_logic_vector(fpu2, 2);                       
    if mac = 1 then asr17(9) := '1'; end if;
    if v8 /= 0 then asr17(8) := '1'; end if;
    asr17(7 downto 5) := conv_std_logic_vector(nwp, 3);                       
    asr17(4 downto 0) := conv_std_logic_vector(nwin-1, 5);       
    return(asr17);
  end;

  procedure diagread(dbgi   : in l3_debug_in_type;
                     r      : in registers;
                     dsur   : in dsu_registers;
                     ir     : in irestart_register;
                     wpr    : in watchpoint_registers;
                     dco   : in  dcache_out_type;                          
                     tbufo  : in tracebuf_out_type;
                     data : out word) is
    variable cwp : std_logic_vector(4 downto 0);
    variable rd : std_logic_vector(4 downto 0);
    variable i : integer range 0 to 3;    
  begin
    data := (others => '0'); cwp := (others => '0');
    cwp(NWINLOG2-1 downto 0) := r.w.s.cwp;
      case dbgi.daddr(22 downto 20) is
        when "001" => -- trace buffer
	  if TRACEBUF then
            if dbgi.daddr(16) = '1' then -- trace buffer control reg
              if TRACEBUF then data(TBUFBITS-1 downto 0) := dsur.tbufcnt; end if;
            else
              case dbgi.daddr(3 downto 2) is
              when "00" => data := tbufo.data(127 downto 96);
              when "01" => data := tbufo.data(95 downto 64);
              when "10" => data := tbufo.data(63 downto 32);
              when others => data := tbufo.data(31 downto 0);
              end case;
            end if;
          end if;
        when "011" => -- IU reg file
          if dbgi.daddr(12) = '0' then
            data := rfo.data1(31 downto 0); 
            if (dbgi.daddr(11) = '1') and (is_fpga(fabtech) = 0) then 
	      data := rfo.data2(31 downto 0);
	    end if;
          else data := fpo.dbg.data; end if;
        when "100" => -- IU regs
          case dbgi.daddr(7 downto 6) is
            when "00" => -- IU regs Y - TBUF ctrl reg
              case dbgi.daddr(5 downto 2) is
                when "0000" =>
                  data := r.w.s.y;
                when "0001" =>
                  data := conv_std_logic_vector(IMPL, 4) & conv_std_logic_vector(VER, 4) &
                          r.w.s.icc & "000000" & r.w.s.ec & r.w.s.ef & r.w.s.pil &
                          r.w.s.s & r.w.s.ps & r.w.s.et & cwp;
                when "0010" =>
                  data(NWIN-1 downto 0) := r.w.s.wim;
                when "0011" =>
                  data := r.w.s.tba & r.w.s.tt & "0000";
                when "0100" =>
                  data(31 downto PCLOW) := r.f.pc;
                when "0101" =>
                  data(31 downto PCLOW) := ir.addr;
                when "0110" => -- FSR
                  data := fpo.dbg.data;
                when "0111" => -- CPSR
                when "1000" => -- TT reg
                  data(12 downto 4) := dsur.err & dsur.tt;
                when "1001" => -- ASI reg
                  data(7 downto 0) := dsur.asi;
                when others =>
              end case;
            when "01" =>
              if dbgi.daddr(5) = '0' then -- %ASR17
                if dbgi.daddr(4 downto 2) = "001" then -- %ASR17
		  data := asr17_gen(r);
		elsif MACEN and  dbgi.daddr(4 downto 2) = "010" then -- %ASR18
		  data := r.w.s.asr18;
		end if;
              else  -- %ASR24 - %ASR31
                i := conv_integer(dbgi.daddr(4 downto 3));                                           -- 
                if dbgi.daddr(2) = '0' then
                  data(31 downto 2) := wpr(i).addr;
                  data(0) := wpr(i).exec;
                else
                  data(31 downto 2) := wpr(i).mask;
                  data(1) := wpr(i).load;
                  data(0) := wpr(i).store; 
                end if;
              end if;
            when others =>
          end case;
        when "111" =>
          data := r.x.data(conv_integer(r.x.set));
        when others =>
      end case;
  end;
  

  procedure itrace(r    : in registers;
                   dsur : in dsu_registers;
                   vdsu : in dsu_registers;
                   res  : in word;
                   exc  : in std_ulogic;
                   dbgi : in l3_debug_in_type;
                   error : in std_ulogic;
                   trap  : in std_ulogic;                          
                   tbufcnt : out std_logic_vector(TBUFBITS-1 downto 0); 
                   di  : out tracebuf_in_type) is
  variable meminst : std_ulogic;
  begin
    di.addr := (others => '0'); di.data := (others => '0');
    di.enable := '0'; di.write := (others => '0');
    tbufcnt := vdsu.tbufcnt;
    meminst := r.x.ctrl.inst(31) and r.x.ctrl.inst(30);
    if TRACEBUF then
      di.addr(TBUFBITS-1 downto 0) := dsur.tbufcnt;
      di.data(127) := '0';
      di.data(126) := not r.x.ctrl.pv;
      di.data(125 downto 96) := dbgi.timer(29 downto 0);
      di.data(95 downto 64) := res;
      di.data(63 downto 34) := r.x.ctrl.pc(31 downto 2);
      di.data(33) := trap;
      di.data(32) := error;
      di.data(31 downto 0) := r.x.ctrl.inst;
      if (dbgi.tenable = '0') or (r.x.rstate = dsu2) then
        if ((dbgi.dsuen and dbgi.denable) = '1') and (dbgi.daddr(23 downto 20) & dbgi.daddr(16) = "00010") then
          di.enable := '1'; 
          di.addr(TBUFBITS-1 downto 0) := dbgi.daddr(TBUFBITS-1+4 downto 4);
          if dbgi.dwrite = '1' then            
            case dbgi.daddr(3 downto 2) is
              when "00" => di.write(3) := '1';
              when "01" => di.write(2) := '1';
              when "10" => di.write(1) := '1';
              when others => di.write(0) := '1';
            end case;
            di.data := dbgi.ddata & dbgi.ddata & dbgi.ddata & dbgi.ddata;
          end if;
        end if;
      elsif (not r.x.ctrl.annul and (r.x.ctrl.pv or meminst) and not r.x.debug) = '1' then        
        di.enable := '1'; di.write := (others => '1');
        tbufcnt := dsur.tbufcnt + 1;
      end if;
      di.diag := dco.testen & "000";
      if dco.scanen = '1' then di.enable := '0'; end if;
    end if;
  end;

  procedure dbg_cache(holdn    : in std_ulogic;
                      dbgi     :  in l3_debug_in_type;
                      r        : in registers;
                      dsur     : in dsu_registers;
                      mresult  : in word;
                      dci      : in dc_in_type;
                      mresult2 : out word;
                      dci2     : out dc_in_type
                      ) is
  begin
    mresult2 := mresult; dci2 := dci; dci2.dsuen := '0'; 
    if DBGUNIT then
      if r.x.rstate = dsu2 then
        dci2.asi := dsur.asi;
        if (dbgi.daddr(22 downto 20) = "111") and (dbgi.dsuen = '1') then
          dci2.dsuen := (dbgi.denable or r.m.dci.dsuen) and not dsur.crdy(2);
          dci2.enaddr := dbgi.denable;
          dci2.size := "10"; dci2.read := '1'; dci2.write := '0';
          if (dbgi.denable and not r.m.dci.enaddr) = '1' then            
            mresult2 := (others => '0'); mresult2(19 downto 2) := dbgi.daddr(19 downto 2);
          else
            mresult2 := dbgi.ddata;            
          end if;
          if dbgi.dwrite = '1' then
            dci2.read := '0'; dci2.write := '1';
          end if;
        end if;
      end if;
    end if;
  end;
    
  procedure fpexack(r : in registers; fpexc : out std_ulogic) is
  begin
    fpexc := '0';
    if FPEN then 
      if r.x.ctrl.tt = TT_FPEXC then fpexc := '1'; end if;
    end if;
  end;

  procedure diagrdy(denable : in std_ulogic;
                    dsur : in dsu_registers;
                    dci   : in dc_in_type;
                    mds : in std_ulogic;
                    ico : in icache_out_type;
                    crdy : out std_logic_vector(2 downto 1)) is                   
  begin
    crdy := dsur.crdy(1) & '0';    
    if dci.dsuen = '1' then
      case dsur.asi(4 downto 0) is
        when ASI_ITAG | ASI_IDATA | ASI_UINST | ASI_SINST =>
          crdy(2) := ico.diagrdy and not dsur.crdy(2);
        when ASI_DTAG | ASI_MMUSNOOP_DTAG | ASI_DDATA | ASI_UDATA | ASI_SDATA =>
          crdy(1) := not denable and dci.enaddr and not dsur.crdy(1);
        when others =>
          crdy(2) := dci.enaddr and denable;
      end case;
    end if;
  end;

  
  signal r, rin : registers;
  signal wpr, wprin : watchpoint_registers;
  signal dsur, dsuin : dsu_registers;
  signal ir, irin : irestart_register;
  signal rp, rpin : pwd_register_type;

-- execute stage operations

  constant EXE_AND   : std_logic_vector(2 downto 0) := "000";
  constant EXE_XOR   : std_logic_vector(2 downto 0) := "001"; -- must be equal to EXE_PASS2
  constant EXE_OR    : std_logic_vector(2 downto 0) := "010";
  constant EXE_XNOR  : std_logic_vector(2 downto 0) := "011";
  constant EXE_ANDN  : std_logic_vector(2 downto 0) := "100";
  constant EXE_ORN   : std_logic_vector(2 downto 0) := "101";
  constant EXE_DIV   : std_logic_vector(2 downto 0) := "110";

  constant EXE_PASS1 : std_logic_vector(2 downto 0) := "000";
  constant EXE_PASS2 : std_logic_vector(2 downto 0) := "001";
  constant EXE_STB   : std_logic_vector(2 downto 0) := "010";
  constant EXE_STH   : std_logic_vector(2 downto 0) := "011";
  constant EXE_ONES  : std_logic_vector(2 downto 0) := "100";
  constant EXE_RDY   : std_logic_vector(2 downto 0) := "101";
  constant EXE_SPR   : std_logic_vector(2 downto 0) := "110";
  constant EXE_LINK  : std_logic_vector(2 downto 0) := "111";

  constant EXE_SLL   : std_logic_vector(2 downto 0) := "001";
  constant EXE_SRL   : std_logic_vector(2 downto 0) := "010";
  constant EXE_SRA   : std_logic_vector(2 downto 0) := "100";

  constant EXE_NOP   : std_logic_vector(2 downto 0) := "000";

-- EXE result select

  constant EXE_RES_ADD   : std_logic_vector(1 downto 0) := "00";
  constant EXE_RES_SHIFT : std_logic_vector(1 downto 0) := "01";
  constant EXE_RES_LOGIC : std_logic_vector(1 downto 0) := "10";
  constant EXE_RES_MISC  : std_logic_vector(1 downto 0) := "11";

-- Load types

  constant SZBYTE    : std_logic_vector(1 downto 0) := "00";
  constant SZHALF    : std_logic_vector(1 downto 0) := "01";
  constant SZWORD    : std_logic_vector(1 downto 0) := "10";
  constant SZDBL     : std_logic_vector(1 downto 0) := "11";

-- calculate register file address

  procedure regaddr(cwp : std_logic_vector; reg : std_logic_vector(4 downto 0);
	 rao : out rfatype) is
  variable ra : rfatype;
  constant globals : std_logic_vector(RFBITS-5  downto 0) := 
	conv_std_logic_vector(NWIN, RFBITS-4);
  begin
    ra := (others => '0'); ra(4 downto 0) := reg;
    if reg(4 downto 3) = "00" then ra(RFBITS -1 downto 4) := globals;
    else
      ra(NWINLOG2+3 downto 4) := cwp + ra(4);
      if ra(RFBITS-1 downto 4) = globals then
        ra(RFBITS-1 downto 4) := (others => '0');
      end if;
    end if;
    rao := ra;
  end;

-- branch adder

  function branch_address(inst : word; pc : pctype) return std_logic_vector is
  variable baddr, caddr, tmp : pctype;
  begin
    caddr := (others => '0'); caddr(31 downto 2) := inst(29 downto 0);
    caddr(31 downto 2) := caddr(31 downto 2) + pc(31 downto 2);
    baddr := (others => '0'); baddr(31 downto 24) := (others => inst(21)); 
    baddr(23 downto 2) := inst(21 downto 0);
    baddr(31 downto 2) := baddr(31 downto 2) + pc(31 downto 2);
    if inst(30) = '1' then tmp := caddr; else tmp := baddr; end if;
    return(tmp);
  end;

-- evaluate branch condition

  function branch_true(icc : std_logic_vector(3 downto 0); inst : word) 
	return std_ulogic is
  variable n, z, v, c, branch : std_ulogic;
  begin
    n := icc(3); z := icc(2); v := icc(1); c := icc(0);
    case inst(27 downto 25) is
    when "000" =>  branch := inst(28) xor '0';			-- bn, ba
    when "001" =>  branch := inst(28) xor z;      		-- be, bne
    when "010" =>  branch := inst(28) xor (z or (n xor v));     -- ble, bg
    when "011" =>  branch := inst(28) xor (n xor v); 	        -- bl, bge
    when "100" =>  branch := inst(28) xor (c or z);   	        -- bleu, bgu
    when "101" =>  branch := inst(28) xor c;		        -- bcs, bcc 
    when "110" =>  branch := inst(28) xor n;		        -- bneg, bpos
    when others => branch := inst(28) xor v;		        -- bvs, bvc   
    end case;
    return(branch);
  end;

-- detect RETT instruction in the pipeline and set the local psr.su and psr.et

  procedure su_et_select(r : in registers; xc_ps, xc_s, xc_et : in std_ulogic;
		       su, et : out std_ulogic) is
  begin
   if ((r.a.ctrl.rett or r.e.ctrl.rett or r.m.ctrl.rett or r.x.ctrl.rett) = '1')
     and (r.x.annul_all = '0')
   then su := xc_ps; et := '1';
   else su := xc_s; et := xc_et; end if;
  end;

-- detect watchpoint trap

  function wphit(r : registers; wpr : watchpoint_registers; debug : l3_debug_in_type)
    return std_ulogic is
  variable exc : std_ulogic;
  begin
    exc := '0';
    for i in 1 to NWP loop
      if ((wpr(i-1).exec and r.a.ctrl.pv and not r.a.ctrl.annul) = '1') then
         if (((wpr(i-1).addr xor r.a.ctrl.pc(31 downto 2)) and wpr(i-1).mask) = Zero32(31 downto 2)) then
           exc := '1';
	 end if;
      end if;
    end loop;

   if DBGUNIT then
     if (debug.dsuen and not r.a.ctrl.annul) = '1' then
       exc := exc or (r.a.ctrl.pv and ((debug.dbreak and debug.bwatch) or r.a.step));
     end if;
   end if;
    return(exc);
  end;

-- 32-bit shifter

  function shift3(r : registers; aluin1, aluin2 : word) return word is
  variable shiftin : unsigned(63 downto 0);
  variable shiftout : unsigned(63 downto 0);
  variable cnt : natural range 0 to 31;
  begin

    cnt := conv_integer(r.e.shcnt);
    if r.e.shleft = '1' then
      shiftin(30 downto 0) := (others => '0');
      shiftin(63 downto 31) := '0' & unsigned(aluin1);
    else
      shiftin(63 downto 32) := (others => r.e.sari);
      shiftin(31 downto 0) := unsigned(aluin1);
    end if;
    shiftout := SHIFT_RIGHT(shiftin, cnt);
    return(std_logic_vector(shiftout(31 downto 0)));
     
  end;

  function shift2(r : registers; aluin1, aluin2 : word) return word is
  variable ushiftin : unsigned(31 downto 0);
  variable sshiftin : signed(32 downto 0);
  variable cnt : natural range 0 to 31;
  begin

    cnt := conv_integer(r.e.shcnt);
    ushiftin := unsigned(aluin1);
    sshiftin := signed('0' & aluin1);
    if r.e.shleft = '1' then
      return(std_logic_vector(SHIFT_LEFT(ushiftin, cnt)));
    else
      if r.e.sari = '1' then sshiftin(32) := aluin1(31); end if;
      sshiftin := SHIFT_RIGHT(sshiftin, cnt);
      return(std_logic_vector(sshiftin(31 downto 0)));
--      else 
--	ushiftin := SHIFT_RIGHT(ushiftin, cnt);
--        return(std_logic_vector(ushiftin));
--      end if;
    end if;
     
  end;

  function shift(r : registers; aluin1, aluin2 : word;
	         shiftcnt : std_logic_vector(4 downto 0); sari : std_ulogic ) return word is
  variable shiftin : std_logic_vector(63 downto 0);
  begin
    shiftin := zero32 & aluin1;
    if r.e.shleft = '1' then
      shiftin(31 downto 0) := zero32; shiftin(63 downto 31) := '0' & aluin1;
    else shiftin(63 downto 32) := (others => sari); end if;
    if shiftcnt (4) = '1' then shiftin(47 downto 0) := shiftin(63 downto 16); end if;
    if shiftcnt (3) = '1' then shiftin(39 downto 0) := shiftin(47 downto 8); end if;
    if shiftcnt (2) = '1' then shiftin(35 downto 0) := shiftin(39 downto 4); end if;
    if shiftcnt (1) = '1' then shiftin(33 downto 0) := shiftin(35 downto 2); end if;
    if shiftcnt (0) = '1' then shiftin(31 downto 0) := shiftin(32 downto 1); end if;
    return(shiftin(31 downto 0));
  end;

-- Check for illegal and privileged instructions

procedure exception_detect(r : registers; wpr : watchpoint_registers; dbgi : l3_debug_in_type;
        trapin : in std_ulogic; ttin : in std_logic_vector(5 downto 0); 
	trap : out std_ulogic; tt : out std_logic_vector(5 downto 0)) is
variable illegal_inst, privileged_inst : std_ulogic;
variable cp_disabled, fp_disabled, fpop : std_ulogic;
variable op : std_logic_vector(1 downto 0);
variable op2 : std_logic_vector(2 downto 0);
variable op3 : std_logic_vector(5 downto 0);
variable rd  : std_logic_vector(4 downto 0);
variable inst : word;
variable wph : std_ulogic;
begin
  inst := r.a.ctrl.inst; trap := trapin; tt := ttin;
  if r.a.ctrl.annul = '0' then
    op  := inst(31 downto 30); op2 := inst(24 downto 22);
    op3 := inst(24 downto 19); rd  := inst(29 downto 25);
    illegal_inst := '0'; privileged_inst := '0'; cp_disabled := '0'; 
    fp_disabled := '0'; fpop := '0';
    case op is
    when CALL => null;
    when FMT2 =>
      case op2 is
      when SETHI | BICC => null;
      when FBFCC => 
	if FPEN then fp_disabled := not r.w.s.ef; else fp_disabled := '1'; end if;
      when CBCCC =>
	if (not CPEN) or (r.w.s.ec = '0') then cp_disabled := '1'; end if;
      when others => illegal_inst := '1';
      end case;
    when FMT3 =>
      case op3 is
      when IAND | ANDCC | ANDN | ANDNCC | IOR | ORCC | ORN | ORNCC | IXOR |
        XORCC | IXNOR | XNORCC | ISLL | ISRL | ISRA | MULSCC | IADD | ADDX |
	ADDCC | ADDXCC | ISUB | SUBX | SUBCC | SUBXCC | FLUSH | JMPL | TICC | 
	SAVE | RESTORE | RDY => null;
      when TADDCC | TADDCCTV | TSUBCC | TSUBCCTV => 
	if notag = 1 then illegal_inst := '1'; end if;
      when UMAC | SMAC => 
	if not MACEN then illegal_inst := '1'; end if;
      when UMUL | SMUL | UMULCC | SMULCC => 
	if not MULEN then illegal_inst := '1'; end if;
      when UDIV | SDIV | UDIVCC | SDIVCC => 
	if not DIVEN then illegal_inst := '1'; end if;
      when RETT => illegal_inst := r.a.et; privileged_inst := not r.a.su;
      when RDPSR | RDTBR | RDWIM => privileged_inst := not r.a.su;
      when WRY  => null;
      when WRPSR => 
	privileged_inst := not r.a.su; 
      when WRWIM | WRTBR  => privileged_inst := not r.a.su;
      when FPOP1 | FPOP2 => 
	if FPEN then fp_disabled := not r.w.s.ef; fpop := '1';
	else fp_disabled := '1'; fpop := '0'; end if;
      when CPOP1 | CPOP2 =>
	if (not CPEN) or (r.w.s.ec = '0') then cp_disabled := '1'; end if;
      when others => illegal_inst := '1';
      end case;
    when others =>	-- LDST
      case op3 is
      when LDD | ISTD => illegal_inst := rd(0);	-- trap if odd destination register
      when LD | LDUB | LDSTUB | LDUH | LDSB | LDSH | ST | STB | STH | SWAP =>
	null;
      when LDDA | STDA =>
	illegal_inst := inst(13) or rd(0); privileged_inst := not r.a.su;
      when LDA | LDUBA| LDSTUBA | LDUHA | LDSBA | LDSHA | STA | STBA | STHA |
	   SWAPA => 
	illegal_inst := inst(13); privileged_inst := not r.a.su;
      when LDDF | STDF | LDF | LDFSR | STF | STFSR => 
	if FPEN then fp_disabled := not r.w.s.ef;
	else fp_disabled := '1'; end if;
      when STDFQ => 
	privileged_inst := not r.a.su; 
	if (not FPEN) or (r.w.s.ef = '0') then fp_disabled := '1'; end if;
      when STDCQ => 
	privileged_inst := not r.a.su;
	if (not CPEN) or (r.w.s.ec = '0') then cp_disabled := '1'; end if;
      when LDC | LDCSR | LDDC | STC | STCSR | STDC => 
	if (not CPEN) or (r.w.s.ec = '0') then cp_disabled := '1'; end if;
      when others => illegal_inst := '1';
      end case;
    end case;

    wph := wphit(r, wpr, dbgi);
    
    trap := '1';
    if r.a.ctrl.trap = '1' then tt := TT_IAEX;
    elsif privileged_inst = '1' then tt := TT_PRIV; 
    elsif illegal_inst = '1' then tt := TT_IINST;
    elsif fp_disabled = '1' then tt := TT_FPDIS;
    elsif cp_disabled = '1' then tt := TT_CPDIS;
    elsif wph = '1' then tt := TT_WATCH;
    elsif r.a.wovf= '1' then tt := TT_WINOF;
    elsif r.a.wunf= '1' then tt := TT_WINUF;
    elsif r.a.ticc= '1' then tt := TT_TICC;
    else trap := '0'; tt:= (others => '0'); end if;
  end if;
end;

-- instructions that write the condition codes (psr.icc)

procedure wicc_y_gen(inst : word; wicc, wy : out std_ulogic) is
begin
  wicc := '0'; wy := '0';
  if inst(31 downto 30) = FMT3 then
    case inst(24 downto 19) is
    when SUBCC | TSUBCC | TSUBCCTV | ADDCC | ANDCC | ORCC | XORCC | ANDNCC |
	 ORNCC | XNORCC | TADDCC | TADDCCTV | ADDXCC | SUBXCC | WRPSR => 
      wicc := '1';
    when WRY =>
      if r.d.inst(conv_integer(r.d.set))(29 downto 25) = "00000" then wy := '1'; end if;
    when MULSCC =>
      wicc := '1'; wy := '1';
    when  UMAC | SMAC  =>
      if MACEN then wy := '1'; end if;
    when UMULCC | SMULCC => 
      if MULEN and (((mulo.nready = '1') and (r.d.cnt /= "00")) or (MULTYPE /= 0)) then
        wicc := '1'; wy := '1';
      end if;
    when UMUL | SMUL => 
      if MULEN and (((mulo.nready = '1') and (r.d.cnt /= "00")) or (MULTYPE /= 0)) then
        wy := '1';
      end if;
    when UDIVCC | SDIVCC => 
      if DIVEN and (divo.nready = '1') and (r.d.cnt /= "00") then
        wicc := '1';
      end if;
    when others =>
    end case;
  end if;
end;

-- select cwp 

procedure cwp_gen(r, v : registers; annul, wcwp : std_ulogic; ncwp : cwptype;
		  cwp : out cwptype) is
begin
  if (r.x.rstate = trap) or (r.x.rstate = dsu2) or (rstn = '0') then cwp := v.w.s.cwp;
  elsif (wcwp = '1') and (annul = '0') then cwp := ncwp;
  elsif r.m.wcwp = '1' then cwp := r.m.result(NWINLOG2-1 downto 0);
  else cwp := r.d.cwp; end if;
end;

-- generate wcwp in ex stage

procedure cwp_ex(r : in  registers; wcwp : out std_ulogic) is
begin
  if (r.e.ctrl.inst(31 downto 30) = FMT3) and 
     (r.e.ctrl.inst(24 downto 19) = WRPSR)
  then wcwp := not r.e.ctrl.annul; else wcwp := '0'; end if;
end;

-- generate next cwp & window under- and overflow traps

procedure cwp_ctrl(r : in registers; xc_wim : in std_logic_vector(NWIN-1 downto 0);
	inst : word; de_cwp : out cwptype; wovf_exc, wunf_exc, wcwp : out std_ulogic) is
variable op : std_logic_vector(1 downto 0);
variable op3 : std_logic_vector(5 downto 0);
variable wim : word;
variable ncwp : cwptype;
begin
  op := inst(31 downto 30); op3 := inst(24 downto 19); 
  wovf_exc := '0'; wunf_exc := '0'; wim := (others => '0'); 
  wim(NWIN-1 downto 0) := xc_wim; ncwp := r.d.cwp; wcwp := '0';

  if (op = FMT3) and ((op3 = RETT) or (op3 = RESTORE) or (op3 = SAVE)) then
    wcwp := '1';
    if (op3 = SAVE) then
      if (not CWPOPT) and (r.d.cwp = CWPMIN) then ncwp := CWPMAX;
      else ncwp := r.d.cwp - 1 ; end if;
    else
      if (not CWPOPT) and (r.d.cwp = CWPMAX) then ncwp := CWPMIN;
      else ncwp := r.d.cwp + 1; end if;
    end if;
    if wim(conv_integer(ncwp)) = '1' then
      if op3 = SAVE then wovf_exc := '1'; else wunf_exc := '1'; end if;
    end if;
  end if;
  de_cwp := ncwp;
end;

-- generate register read address 1

procedure rs1_gen(r : registers; inst : word;  rs1 : out std_logic_vector(4 downto 0);
	rs1mod : out std_ulogic) is
variable op : std_logic_vector(1 downto 0);
variable op3 : std_logic_vector(5 downto 0);
begin
  op := inst(31 downto 30); op3 := inst(24 downto 19); 
  rs1 := inst(18 downto 14); rs1mod := '0';
  if (op = LDST) then
    if ((r.d.cnt = "01") and ((op3(2) and not op3(3)) = '1')) or
        (r.d.cnt = "10") 
    then rs1mod := '1'; rs1 := inst(29 downto 25); end if;
    if ((r.d.cnt = "10") and (op3(3 downto 0) = "0111")) then
      rs1(0) := '1';
    end if;
  end if;
end;

-- load/icc interlock detection

  procedure lock_gen(r : registers; rs2, rd : std_logic_vector(4 downto 0);
	rfa1, rfa2, rfrd : rfatype; inst : word; fpc_lock, mulinsn, divinsn : std_ulogic;
        lldcheck1, lldcheck2, lldlock, lldchkra, lldchkex : out std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable cond : std_logic_vector(3 downto 0);
  variable rs1  : std_logic_vector(4 downto 0);
  variable i, ldcheck1, ldcheck2, ldchkra, ldchkex, ldcheck3 : std_ulogic;
  variable ldlock, icc_check, bicc_hold, chkmul, y_check : std_ulogic;
  variable lddlock : boolean;
  begin
    op := inst(31 downto 30); op3 := inst(24 downto 19); 
    op2 := inst(24 downto 22); cond := inst(28 downto 25); 
    rs1 := inst(18 downto 14); lddlock := false; i := inst(13);
    ldcheck1 := '0'; ldcheck2 := '0'; ldcheck3 := '0'; ldlock := '0';
    ldchkra := '1'; ldchkex := '1'; icc_check := '0'; bicc_hold := '0';
    y_check := '0';

    if (r.d.annul = '0') then
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
        when RDY => 
          ldcheck1 := '0'; ldcheck2 := '0';
	  if MACPIPE then y_check := '1'; end if;
        when RDWIM | RDTBR => 
          ldcheck1 := '0'; ldcheck2 := '0';
        when RDPSR => 
          ldcheck1 := '0'; ldcheck2 := '0'; icc_check := '1';
	  if MULEN then icc_check := '1'; end if;
--	when ADDX | ADDXCC | SUBX | SUBXCC =>
--	  if MULEN then icc_check := '1'; end if;
	when SDIV | SDIVCC | UDIV | UDIVCC =>
	  if DIVEN then y_check := '1'; end if;
        when FPOP1 | FPOP2 => ldcheck1:= '0'; ldcheck2 := '0';
        when others => 
        end case;
      when LDST =>
        ldcheck1 := '1'; ldchkra := '0';
	case r.d.cnt is
	when "00" =>
          if (lddel = 2) and (op3(2) = '1') then ldcheck3 := '1'; end if; 
          ldcheck2 := not i; ldchkra := '1';
	when "01" => ldcheck2 := not i;
	when others => ldchkex := '0';
        end case;
        if  (op3(2 downto 0) = "011") then lddlock := true; end if;
      when others => null;
      end case;
    end if;

    if MULEN or DIVEN then 
      chkmul := mulinsn;
      bicc_hold := bicc_hold or (icc_check and r.m.ctrl.wicc and (r.m.ctrl.cnt(0) or r.m.mul));
    else chkmul := '0'; end if;
    if DIVEN then 
      bicc_hold := bicc_hold or (y_check and (r.a.ctrl.wy or r.e.ctrl.wy));
      chkmul := chkmul or divinsn;
    end if;

    bicc_hold := bicc_hold or (icc_check and (r.a.ctrl.wicc or r.e.ctrl.wicc));

    if (((r.a.ctrl.ld or chkmul) and r.a.ctrl.wreg and ldchkra) = '1') and
       (((ldcheck1 = '1') and (r.a.ctrl.rd = rfa1)) or
        ((ldcheck2 = '1') and (r.a.ctrl.rd = rfa2)) or
        ((ldcheck3 = '1') and (r.a.ctrl.rd = rfrd)))
    then ldlock := '1'; end if;

    if (((r.e.ctrl.ld or r.e.mac) and r.e.ctrl.wreg and ldchkex) = '1') and 
        ((lddel = 2) or (MACPIPE and (r.e.mac = '1')) or ((MULTYPE = 3) and (r.e.mul = '1'))) and
       (((ldcheck1 = '1') and (r.e.ctrl.rd = rfa1)) or
        ((ldcheck2 = '1') and (r.e.ctrl.rd = rfa2)))
    then ldlock := '1'; end if;

    ldlock := ldlock or bicc_hold or fpc_lock;

    lldcheck1 := ldcheck1; lldcheck2:= ldcheck2; lldlock := ldlock;
    lldchkra := ldchkra; lldchkex := ldchkex;
  end;

  procedure fpbranch(inst : in word; fcc  : in std_logic_vector(1 downto 0);
                      branch : out std_ulogic) is
  variable cond : std_logic_vector(3 downto 0);
  variable fbres : std_ulogic;
  begin
    cond := inst(28 downto 25);
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
    branch := cond(3) xor fbres;     
  end;

-- PC generation

  procedure ic_ctrl(r : registers; inst : word; annul_all, ldlock, branch_true, 
	fbranch_true, cbranch_true, fccv, cccv : in std_ulogic; 
	cnt : out std_logic_vector(1 downto 0); 
	de_pc : out pctype; de_branch, ctrl_annul, de_annul, jmpl_inst, inull, 
	de_pv, ctrl_pv, de_hold_pc, ticc_exception, rett_inst, mulstart,
	divstart : out std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable cond : std_logic_vector(3 downto 0);
  variable hold_pc, annul_current, annul_next, branch, annul, pv : std_ulogic;
  variable de_jmpl : std_ulogic;
  begin
    branch := '0'; annul_next := '0'; annul_current := '0'; pv := '1';
    hold_pc := '0'; ticc_exception := '0'; rett_inst := '0';
    op := inst(31 downto 30); op3 := inst(24 downto 19); 
    op2 := inst(24 downto 22); cond := inst(28 downto 25); 
    annul := inst(29); de_jmpl := '0'; cnt := "00";
    mulstart := '0'; divstart := '0'; 
    if r.d.annul = '0' then
      case inst(31 downto 30) is
      when CALL =>
        branch := '1';
	if r.d.inull = '1' then 
	  hold_pc := '1'; annul_current := '1';
 	end if;
      when FMT2 =>
        if (op2 = BICC) or (FPEN and (op2 = FBFCC)) or (CPEN and (op2 = CBCCC)) then
          if (FPEN and (op2 = FBFCC)) then 
	    branch := fbranch_true;
	    if fccv /= '1' then hold_pc := '1'; annul_current := '1'; end if;
          elsif (CPEN and (op2 = CBCCC)) then 
	    branch := cbranch_true;
	    if cccv /= '1' then hold_pc := '1'; annul_current := '1'; end if;
	  else branch := branch_true; end if;
	  if hold_pc = '0' then
  	    if (branch = '1') then
              if (cond = BA) and (annul = '1') then annul_next := '1'; end if;
            else annul_next := annul; end if;
	    if r.d.inull = '1' then -- contention with JMPL
	      hold_pc := '1'; annul_current := '1'; annul_next := '0';
	    end if;
	  end if;
        end if;
      when FMT3 =>
        case op3 is
        when UMUL | SMUL | UMULCC | SMULCC =>
	  if MULEN and (MULTYPE /= 0) then mulstart := '1'; end if;
	  if MULEN and (MULTYPE = 0) then
            case r.d.cnt is
            when "00" =>
 	      cnt := "01"; hold_pc := '1'; pv := '0'; mulstart := '1';
            when "01" =>
 	      if mulo.nready = '1' then cnt := "00";
              else cnt := "01"; pv := '0'; hold_pc := '1'; end if;
            when others => null;
	    end case;
	  end if;
        when UDIV | SDIV | UDIVCC | SDIVCC =>
	  if DIVEN then
            case r.d.cnt is
            when "00" =>
 	      cnt := "01"; hold_pc := '1'; pv := '0';
	      divstart := '1';
            when "01" =>
 	      if divo.nready = '1' then cnt := "00"; 
              else cnt := "01"; pv := '0'; hold_pc := '1'; end if;
            when others => null;
	    end case;
	  end if;
        when TICC =>
	  if branch_true = '1' then ticc_exception := '1'; end if;
        when RETT =>
          rett_inst := '1'; --su := sregs.ps; 
        when JMPL =>
          de_jmpl := '1';
        when WRY =>
          if PWRD1 then 
            if inst(29 downto 25) = "10011" then -- %ASR19
              case r.d.cnt is
              when "00" =>
                pv := '0'; cnt := "00"; hold_pc := '1';
                if r.x.ipend = '1' then cnt := "01"; end if;              
              when "01" =>
                cnt := "00";
              when others =>
              end case;
            end if;
          end if;
        when others => null;
        end case;
      when others =>  -- LDST 
        case r.d.cnt is
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
      end case;
    end if;

    if ldlock = '1' then
      cnt := r.d.cnt; annul_next := '0'; pv := '1';
    end if;
    hold_pc := (hold_pc or ldlock) and not annul_all;

    if hold_pc = '1' then de_pc := r.d.pc; else de_pc := r.f.pc; end if;

    annul_current := (annul_current or ldlock or annul_all);
    ctrl_annul := r.d.annul or annul_all or annul_current;
    pv := pv and not ((r.d.inull and not hold_pc) or annul_all);
    jmpl_inst := de_jmpl and not annul_current;
    annul_next := (r.d.inull and not hold_pc) or annul_next or annul_all;
    if (annul_next = '1') or (rstn = '0') then
      cnt := (others => '0'); 
    end if;

    de_hold_pc := hold_pc; de_branch := branch; de_annul := annul_next;
    de_pv := pv; ctrl_pv := r.d.pv and 
	not ((r.d.annul and not r.d.pv) or annul_all or annul_current);
    inull := (not rstn) or r.d.inull or hold_pc or annul_all;

  end;

-- register write address generation

  procedure rd_gen(r : registers; inst : word; wreg, ld : out std_ulogic; 
	rdo : out std_logic_vector(4 downto 0)) is
  variable write_reg : std_ulogic;
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable rd  : std_logic_vector(4 downto 0);
  begin

    op    := inst(31 downto 30);
    op2   := inst(24 downto 22);
    op3   := inst(24 downto 19);

    write_reg := '0'; rd := inst(29 downto 25); ld := '0';

    case op is
    when CALL =>
        write_reg := '1'; rd := "01111";    -- CALL saves PC in r[15] (%o7)
    when FMT2 => 
        if (op2 = SETHI) then write_reg := '1'; end if;
    when FMT3 =>
        case op3 is
	when UMUL | SMUL | UMULCC | SMULCC => 
	  if MULEN then
	    if (((mulo.nready = '1') and (r.d.cnt /= "00")) or (MULTYPE /= 0)) then
	      write_reg := '1'; 
	    end if;
	  else write_reg := '1'; end if;
	when UDIV | SDIV | UDIVCC | SDIVCC => 
	  if DIVEN then
	    if (divo.nready = '1') and (r.d.cnt /= "00") then
	      write_reg := '1'; 
	    end if;
	  else write_reg := '1'; end if;
        when RETT | WRPSR | WRY | WRWIM | WRTBR | TICC | FLUSH => null;
	when FPOP1 | FPOP2 => null;
	when CPOP1 | CPOP2 => null;
        when others => write_reg := '1';
        end case;
      when others =>   -- LDST
        ld := not op3(2);
        if (op3(2) = '0') and not ((CPEN or FPEN) and (op3(5) = '1')) 
        then write_reg := '1'; end if;
        case op3 is
        when SWAP | SWAPA | LDSTUB | LDSTUBA =>
	  if r.d.cnt = "00" then write_reg := '1'; ld := '1'; end if;
        when others => null;
        end case;
        if r.d.cnt = "01" then
	  case op3 is
	  when LDD | LDDA | LDDC | LDDF => rd(0) := '1';
          when others =>
          end case;
      	end if;
    end case;

    if (rd = "00000") then write_reg := '0'; end if;
    wreg := write_reg; rdo := rd;
  end;

-- immediate data generation

  function imm_data (r : registers; insn : word) 
	return word is
  variable immediate_data, inst : word;
  begin
    immediate_data := (others => '0'); inst := insn;
    case inst(31 downto 30) is
    when FMT2 =>
      immediate_data := inst(21 downto 0) & "0000000000";
    when others =>	-- LDST
      immediate_data(31 downto 13) := (others => inst(12));
      immediate_data(12 downto 0) := inst(12 downto 0);
    end case;
    return(immediate_data);
  end;

-- read special registers
  function get_spr (r : registers) return word is
  variable spr : word;
  begin
    spr := (others => '0');
      case r.e.ctrl.inst(24 downto 19) is
      when RDPSR => spr(31 downto 5) := conv_std_logic_vector(IMPL,4) &
        conv_std_logic_vector(VER,4) & r.m.icc & "000000" & r.w.s.ec & r.w.s.ef & 
	r.w.s.pil & r.e.su & r.w.s.ps & r.e.et;
	spr(NWINLOG2-1 downto 0) := r.e.cwp;
      when RDTBR => spr(31 downto 4) := r.w.s.tba & r.w.s.tt;
      when RDWIM => spr(NWIN-1 downto 0) := r.w.s.wim;
      when others =>
      end case;
    return(spr);
  end;

-- immediate data select

  function imm_select(inst : word) return boolean is
  variable imm : boolean;
  begin
    imm := false;
    case inst(31 downto 30) is
    when FMT2 =>
      case inst(24 downto 22) is
      when SETHI => imm := true;
      when others => 
      end case;
    when FMT3 =>
      case inst(24 downto 19) is
      when RDWIM | RDPSR | RDTBR => imm := true;
      when others => if (inst(13) = '1') then imm := true; end if;
      end case;
    when LDST => 
      if (inst(13) = '1') then imm := true; end if;
    when others => 
    end case;
    return(imm);
  end;

-- EXE operation

  procedure alu_op(r : in registers; iop1, iop2 : in word; me_icc : std_logic_vector(3 downto 0);
	my, ldbp : std_ulogic; aop1, aop2 : out word; aluop  : out std_logic_vector(2 downto 0);
	alusel : out std_logic_vector(1 downto 0); aluadd : out std_ulogic;
	shcnt : out std_logic_vector(4 downto 0); sari, shleft, ymsb, 
	mulins, divins, mulstep, macins, ldbp2, invop2 : out std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable rd  : std_logic_vector(4 downto 0);
  variable icc : std_logic_vector(3 downto 0);
  variable y0  : std_ulogic;
  begin

    op   := r.a.ctrl.inst(31 downto 30);
    op2  := r.a.ctrl.inst(24 downto 22);
    op3  := r.a.ctrl.inst(24 downto 19);
    aop1 := iop1; aop2 := iop2; ldbp2 := ldbp;
    aluop := EXE_NOP; alusel := EXE_RES_MISC; aluadd := '1'; 
    shcnt := iop2(4 downto 0); sari := '0'; shleft := '0'; invop2 := '0';
    ymsb := iop1(0); mulins := '0'; divins := '0'; mulstep := '0';
    macins := '0';

    if r.e.ctrl.wy = '1' then y0 := my;
    elsif r.m.ctrl.wy = '1' then y0 := r.m.y(0);
    elsif r.x.ctrl.wy = '1' then y0 := r.x.y(0);
    else y0 := r.w.s.y(0); end if;

    if r.e.ctrl.wicc = '1' then icc := me_icc;
    elsif r.m.ctrl.wicc = '1' then icc := r.m.icc;
    elsif r.x.ctrl.wicc = '1' then icc := r.x.icc;
    else icc := r.w.s.icc; end if;

    case op is
    when CALL =>
      aluop := EXE_LINK;
    when FMT2 =>
      case op2 is
      when SETHI => aluop := EXE_PASS2;
      when others =>
      end case;
    when FMT3 =>
      case op3 is
      when IADD | ADDX | ADDCC | ADDXCC | TADDCC | TADDCCTV | SAVE | RESTORE |
	   TICC | JMPL | RETT  => alusel := EXE_RES_ADD;
      when ISUB | SUBX | SUBCC | SUBXCC | TSUBCC | TSUBCCTV  => 
	alusel := EXE_RES_ADD; aluadd := '0'; aop2 := not iop2; invop2 := '1';
      when MULSCC => alusel := EXE_RES_ADD;
	aop1 := (icc(3) xor icc(1)) & iop1(31 downto 1);
	if y0 = '0' then aop2 := (others => '0'); ldbp2 := '0'; end if;
	mulstep := '1';
      when UMUL | UMULCC | SMUL | SMULCC => 
	if MULEN then mulins := '1'; end if;
      when UMAC | SMAC => 
	if MACEN then mulins := '1'; macins := '1'; end if;
      when UDIV | UDIVCC | SDIV | SDIVCC => 
	if DIVEN then 
	  aluop := EXE_DIV; alusel := EXE_RES_LOGIC; divins := '1';
        end if;
      when IAND | ANDCC => aluop := EXE_AND; alusel := EXE_RES_LOGIC;
      when ANDN | ANDNCC => aluop := EXE_ANDN; alusel := EXE_RES_LOGIC;
      when IOR | ORCC  => aluop := EXE_OR; alusel := EXE_RES_LOGIC;
      when ORN | ORNCC  => aluop := EXE_ORN; alusel := EXE_RES_LOGIC;
      when IXNOR | XNORCC  => aluop := EXE_XNOR; alusel := EXE_RES_LOGIC;
      when XORCC | IXOR | WRPSR | WRWIM | WRTBR | WRY  => 
	aluop := EXE_XOR; alusel := EXE_RES_LOGIC;
      when RDPSR | RDTBR | RDWIM => aluop := EXE_SPR;
      when RDY => aluop := EXE_RDY;
      when ISLL => aluop := EXE_SLL; alusel := EXE_RES_SHIFT; shleft := '1'; 
		   shcnt := not iop2(4 downto 0); invop2 := '1';
      when ISRL => aluop := EXE_SRL; alusel := EXE_RES_SHIFT; 
      when ISRA => aluop := EXE_SRA; alusel := EXE_RES_SHIFT; sari := iop1(31);
      when FPOP1 | FPOP2 =>
      when others =>
      end case;
    when others =>	-- LDST
      case r.a.ctrl.cnt is
      when "00" =>
        alusel := EXE_RES_ADD;
      when "01" =>
	case op3 is
	when LDD | LDDA | LDDC => alusel := EXE_RES_ADD;
	when LDDF => alusel := EXE_RES_ADD;
	when SWAP | SWAPA | LDSTUB | LDSTUBA => alusel := EXE_RES_ADD;
	when STF | STDF =>
	when others =>
          aluop := EXE_PASS1;
	  if op3(2) = '1' then 
	    if op3(1 downto 0) = "01" then aluop := EXE_STB;
	    elsif op3(1 downto 0) = "10" then aluop := EXE_STH; end if;
          end if;
        end case;
      when "10" =>
        aluop := EXE_PASS1;
        if op3(2) = '1' then  -- ST
          if (op3(3) and not op3(1))= '1' then aluop := EXE_ONES; end if; -- LDSTUB/A
        end if;
      when others =>
      end case;
    end case;
  end;

  function ra_inull_gen(r, v : registers) return std_ulogic is
  variable de_inull : std_ulogic;
  begin
    de_inull := '0';
    if ((v.e.jmpl or v.e.ctrl.rett) and not v.e.ctrl.annul and not (r.e.jmpl and not r.e.ctrl.annul)) = '1' then de_inull := '1'; end if;
    if ((v.a.jmpl or v.a.ctrl.rett) and not v.a.ctrl.annul and not (r.a.jmpl and not r.a.ctrl.annul)) = '1' then de_inull := '1'; end if;
    return(de_inull);
  end;

-- operand generation

  procedure op_mux(r : in registers; rfd, ed, md, xd, im : in word; 
	rsel : in std_logic_vector(2 downto 0); 
	ldbp : out std_ulogic; d : out word) is
  begin
    ldbp := '0';
    case rsel is
    when "000" => d := rfd;
    when "001" => d := ed;
    when "010" => d := md; if lddel = 1 then ldbp := r.m.ctrl.ld; end if;
    when "011" => d := xd;
    when "100" => d := im;
    when "101" => d := (others => '0');
    when "110" => d := r.w.result;
    when others => d := (others => '-');
    end case;
  end;

  procedure op_find(r : in registers; ldchkra : std_ulogic; ldchkex : std_ulogic;
	 rs1 : std_logic_vector(4 downto 0); ra : rfatype; im : boolean; rfe : out std_ulogic; 
	osel : out std_logic_vector(2 downto 0); ldcheck : std_ulogic) is
  begin
    rfe := '0';
    if im then osel := "100";
    elsif rs1 = "00000" then osel := "101";	-- %g0
    elsif ((r.a.ctrl.wreg and ldchkra) = '1') and (ra = r.a.ctrl.rd) then osel := "001";
    elsif ((r.e.ctrl.wreg and ldchkex) = '1') and (ra = r.e.ctrl.rd) then osel := "010";
    elsif r.m.ctrl.wreg = '1' and (ra = r.m.ctrl.rd) then osel := "011";
    elsif (irfwt = 0) and r.x.ctrl.wreg = '1' and (ra = r.x.ctrl.rd) then osel := "110";
    else  osel := "000"; rfe := ldcheck; end if;
  end;

-- generate carry-in for alu

  procedure cin_gen(r : registers; me_cin : in std_ulogic; cin : out std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable ncin : std_ulogic;
  begin

    op := r.a.ctrl.inst(31 downto 30); op3 := r.a.ctrl.inst(24 downto 19);
    if r.e.ctrl.wicc = '1' then ncin := me_cin;
    else ncin := r.m.icc(0); end if;
    cin := '0';
    case op is
    when FMT3 =>
      case op3 is
      when ISUB | SUBCC | TSUBCC | TSUBCCTV => cin := '1';
      when ADDX | ADDXCC => cin := ncin; 
      when SUBX | SUBXCC => cin := not ncin; 
      when others => null;
      end case;
    when others => null;
    end case;
  end;

  procedure logic_op(r : registers; aluin1, aluin2, mey : word; 
	ymsb : std_ulogic; logicres, y : out word) is
  variable logicout : word;
  begin
    case r.e.aluop is
    when EXE_AND   => logicout := aluin1 and aluin2;
    when EXE_ANDN  => logicout := aluin1 and not aluin2;
    when EXE_OR    => logicout := aluin1 or aluin2;
    when EXE_ORN   => logicout := aluin1 or not aluin2;
    when EXE_XOR   => logicout := aluin1 xor aluin2;
    when EXE_XNOR  => logicout := aluin1 xor not aluin2;
    when EXE_DIV   => 
      if DIVEN then logicout := aluin2;
      else logicout := (others => '-'); end if;
    when others => logicout := (others => '-');
    end case;
    if (r.e.ctrl.wy and r.e.mulstep) = '1' then 
      y := ymsb & r.m.y(31 downto 1); 
    elsif r.e.ctrl.wy = '1' then y := logicout;
    elsif r.m.ctrl.wy = '1' then y := mey; 
    elsif MACPIPE and (r.x.mac = '1') then y := mulo.result(63 downto 32);
    elsif r.x.ctrl.wy = '1' then y := r.x.y; 
    else y := r.w.s.y; end if;
    logicres := logicout;
  end;

  procedure misc_op(r : registers; wpr : watchpoint_registers; 
	aluin1, aluin2, ldata, mey : word; 
	mout, edata : out word) is
  variable miscout, bpdata, stdata : word;
  variable wpi : integer;
  begin
    wpi := 0; miscout := r.e.ctrl.pc(31 downto 2) & "00"; 
    edata := aluin1; bpdata := aluin1;
    if ((r.x.ctrl.wreg and r.x.ctrl.ld and not r.x.ctrl.annul) = '1') and
       (r.x.ctrl.rd = r.e.ctrl.rd) and (r.e.ctrl.inst(31 downto 30) = LDST) and
	(r.e.ctrl.cnt /= "10")
    then bpdata := ldata; end if;

    case r.e.aluop is
    when EXE_STB   => miscout := bpdata(7 downto 0) & bpdata(7 downto 0) &
			     bpdata(7 downto 0) & bpdata(7 downto 0);
		      edata := miscout;
    when EXE_STH   => miscout := bpdata(15 downto 0) & bpdata(15 downto 0);
		      edata := miscout;
    when EXE_PASS1 => miscout := bpdata; edata := miscout;
    when EXE_PASS2 => miscout := aluin2;
    when EXE_ONES  => miscout := (others => '1');
		      edata := miscout;
    when EXE_RDY  => 
      if MULEN and (r.m.ctrl.wy = '1') then miscout := mey;
      else miscout := r.m.y; end if;
      if (NWP > 0) and (r.e.ctrl.inst(18 downto 17) = "11") then
 	wpi := conv_integer(r.e.ctrl.inst(16 downto 15));
 	if r.e.ctrl.inst(14) = '0' then miscout := wpr(wpi).addr & '0' & wpr(wpi).exec;
 	else miscout := wpr(wpi).mask & wpr(wpi).load & wpr(wpi).store; end if;
      end if;
      if (r.e.ctrl.inst(18 downto 17) = "10") and (r.e.ctrl.inst(14) = '1') then --%ASR17
        miscout := asr17_gen(r);
      end if;
      if MACEN then
        if (r.e.ctrl.inst(18 downto 14) = "10010") then --%ASR18
          if ((r.m.mac = '1') and not MACPIPE) or ((r.x.mac = '1') and MACPIPE) then
            miscout := mulo.result(31 downto 0);	-- data forward of asr18
	  else miscout := r.w.s.asr18; end if;
        else
          if ((r.m.mac = '1') and not MACPIPE) or ((r.x.mac = '1') and MACPIPE) then
            miscout := mulo.result(63 downto 32);   -- data forward Y
	  end if;
        end if;
      end if;
    when EXE_SPR  => 
      miscout := get_spr(r);
    when others => null;
    end case;
    mout := miscout;
  end;

  procedure alu_select(r : registers; addout : std_logic_vector(32 downto 0);
	op1, op2 : word; shiftout, logicout, miscout : word; res : out word; 
	me_icc : std_logic_vector(3 downto 0);
	icco : out std_logic_vector(3 downto 0); divz : out std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable icc : std_logic_vector(3 downto 0);
  variable aluresult : word;
  begin
    op   := r.e.ctrl.inst(31 downto 30); op3  := r.e.ctrl.inst(24 downto 19);
    icc := (others => '0');
    case r.e.alusel is
    when EXE_RES_ADD => 
      aluresult := addout(32 downto 1);
      if r.e.aluadd = '0' then
        icc(0) := ((not op1(31)) and not op2(31)) or 	-- Carry
		 (addout(32) and ((not op1(31)) or not op2(31)));
        icc(1) := (op1(31) and (op2(31)) and not addout(32)) or 	-- Overflow
                 (addout(32) and (not op1(31)) and not op2(31));
      else
        icc(0) := (op1(31) and op2(31)) or 	-- Carry
		 ((not addout(32)) and (op1(31) or op2(31)));
        icc(1) := (op1(31) and op2(31) and not addout(32)) or 	-- Overflow
		 (addout(32) and (not op1(31)) and (not op2(31)));
      end if;
      if notag = 0 then
        case op is 
        when FMT3 =>
          case op3 is
          when TADDCC | TADDCCTV =>
            icc(1) := op1(0) or op1(1) or op2(0) or op2(1) or icc(1);
          when TSUBCC | TSUBCCTV =>
            icc(1) := op1(0) or op1(1) or (not op2(0)) or (not op2(1)) or icc(1);
          when others => null;
          end case;
        when others => null;
        end case;
      end if;

      if aluresult = zero32 then icc(2) := '1'; end if;
    when EXE_RES_SHIFT => aluresult := shiftout;
    when EXE_RES_LOGIC => aluresult := logicout;
      if aluresult = zero32 then icc(2) := '1'; end if;
    when others => aluresult := miscout;
    end case;
    if r.e.jmpl = '1' then aluresult := r.e.ctrl.pc(31 downto 2) & "00"; end if;
    icc(3) := aluresult(31); divz := icc(2);
    if r.e.ctrl.wicc = '1' then
      if (op = FMT3) and (op3 = WRPSR) then icco := logicout(23 downto 20);
      else icco := icc; end if;
    elsif r.m.ctrl.wicc = '1' then icco := me_icc;
    elsif r.x.ctrl.wicc = '1' then icco := r.x.icc;
    else icco := r.w.s.icc; end if;
    res := aluresult;
  end;

  procedure dcache_gen(r, v : registers; dci : out dc_in_type; 
	link_pc, jump, force_a2, load : out std_ulogic) is
  variable op : std_logic_vector(1 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable su : std_ulogic;
  begin
    op := r.e.ctrl.inst(31 downto 30); op3 := r.e.ctrl.inst(24 downto 19);
    dci.signed := '0'; dci.lock := '0'; dci.dsuen := '0'; dci.size := SZWORD;
    if op = LDST then
    case op3 is
      when LDUB | LDUBA => dci.size := SZBYTE;
      when LDSTUB | LDSTUBA => dci.size := SZBYTE; dci.lock := '1'; 
      when LDUH | LDUHA => dci.size := SZHALF;
      when LDSB | LDSBA => dci.size := SZBYTE; dci.signed := '1';
      when LDSH | LDSHA => dci.size := SZHALF; dci.signed := '1';
      when LD | LDA | LDF | LDC => dci.size := SZWORD;
      when SWAP | SWAPA => dci.size := SZWORD; dci.lock := '1'; 
      when LDD | LDDA | LDDF | LDDC => dci.size := SZDBL;
      when STB | STBA => dci.size := SZBYTE;
      when STH | STHA => dci.size := SZHALF;
      when ST | STA | STF => dci.size := SZWORD;
      when ISTD | STDA => dci.size := SZDBL;
      when STDF | STDFQ => if FPEN then dci.size := SZDBL; end if;
      when STDC | STDCQ => if CPEN then dci.size := SZDBL; end if;
      when others => dci.size := SZWORD; dci.lock := '0'; dci.signed := '0';
    end case;
    end if;
    
    link_pc := '0'; jump:= '0'; force_a2 := '0'; load := '0';
    dci.write := '0'; dci.enaddr := '0'; dci.read := not op3(2);

-- load/store control decoding

    if (r.e.ctrl.annul = '0') then
      case op is
      when CALL => link_pc := '1';
      when FMT3 =>
        case op3 is
        when JMPL => jump := '1'; link_pc := '1'; 
        when RETT => jump := '1';
        when others => null;
        end case;
      when LDST =>
          case r.e.ctrl.cnt is
	  when "00" =>
            dci.read := op3(3) or not op3(2);	-- LD/LDST/SWAP
            load := op3(3) or not op3(2);
	    dci.enaddr := '1';
          when "01" =>
            force_a2 := not op3(2);	-- LDD
            load := not op3(2); dci.enaddr := not op3(2);
            if op3(3 downto 2) = "01" then		-- ST/STD
	      dci.write := '1';
            end if;
            if op3(3 downto 2) = "11" then		-- LDST/SWAP
	      dci.enaddr := '1';
            end if;
          when "10" => 					-- STD/LDST/SWAP
            dci.write := '1';
          when others => null;
	  end case;
	if (r.e.ctrl.trap or (v.x.ctrl.trap and not v.x.ctrl.annul)) = '1' then
	  dci.enaddr := '0';
	end if;
      when others => null;
      end case;
    end if;

    if ((r.x.ctrl.rett and not r.x.ctrl.annul) = '1') then su := r.w.s.ps;
    else su := r.w.s.s; end if;
    if su = '1' then dci.asi := "00001011"; else dci.asi := "00001010"; end if;
    if (op3(4) = '1') and ((op3(5) = '0') or not CPEN) then
      dci.asi := r.e.ctrl.inst(12 downto 5);
    end if;

  end;

  procedure fpstdata(r : in registers; edata, eres : in word; fpstdata : in std_logic_vector(31 downto 0);
                       edata2, eres2 : out word) is
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
  begin
    edata2 := edata; eres2 := eres;
    op := r.e.ctrl.inst(31 downto 30); op3 := r.e.ctrl.inst(24 downto 19);
    if FPEN then
      if FPEN and (op = LDST) and  ((op3(5 downto 4) & op3(2)) = "101") and (r.e.ctrl.cnt /= "00") then
        edata2 := fpstdata; eres2 := fpstdata;
      end if;
    end if;
  end;
  
  function ld_align(data : dcdtype; set : std_logic_vector(DSETMSB downto 0);
	size, laddr : std_logic_vector(1 downto 0); signed : std_ulogic) return word is
  variable align_data, rdata : word;
  begin
    align_data := data(conv_integer(set)); rdata := (others => '0');
    case size is
    when "00" => 			-- byte read
      case laddr is
      when "00" => 
	rdata(7 downto 0) := align_data(31 downto 24);
	if signed = '1' then rdata(31 downto 8) := (others => align_data(31)); end if;
      when "01" => 
	rdata(7 downto 0) := align_data(23 downto 16);
	if signed = '1' then rdata(31 downto 8) := (others => align_data(23)); end if;
      when "10" => 
	rdata(7 downto 0) := align_data(15 downto 8);
	if signed = '1' then rdata(31 downto 8) := (others => align_data(15)); end if;
      when others => 
	rdata(7 downto 0) := align_data(7 downto 0);
	if signed = '1' then rdata(31 downto 8) := (others => align_data(7)); end if;
      end case;
    when "01" => 			-- half-word read
      if  laddr(1) = '1' then 
	rdata(15 downto 0) := align_data(15 downto 0);
	if signed = '1' then rdata(31 downto 15) := (others => align_data(15)); end if;
      else
	rdata(15 downto 0) := align_data(31 downto 16);
	if signed = '1' then rdata(31 downto 15) := (others => align_data(31)); end if;
      end if;
    when others => 			-- single and double word read
      rdata := align_data;
    end case;
    return(rdata);
  end;

  procedure mem_trap(r : registers; wpr : watchpoint_registers;
                     annul, holdn : in std_ulogic;
                     trapout, iflush, nullify, werrout : out std_ulogic;
                     tt : out std_logic_vector(5 downto 0)) is
  variable cwp   : std_logic_vector(NWINLOG2-1 downto 0);
  variable cwpx  : std_logic_vector(5 downto NWINLOG2);
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable nalign_d : std_ulogic;
  variable trap, werr : std_ulogic;
  begin
    op := r.m.ctrl.inst(31 downto 30); op2  := r.m.ctrl.inst(24 downto 22);
    op3 := r.m.ctrl.inst(24 downto 19);
    cwpx := r.m.result(5 downto NWINLOG2); cwpx(5) := '0';
    iflush := '0'; trap := r.m.ctrl.trap; nullify := annul;
    tt := r.m.ctrl.tt; werr := (dco.werr or r.m.werr) and not r.w.s.dwt;
    nalign_d := r.m.nalign or r.m.result(2); 
    if ((annul or trap) /= '1') and (r.m.ctrl.pv = '1') then
      if (werr and holdn) = '1' then
	trap := '1'; tt := TT_DSEX; werr := '0';
        if op = LDST then nullify := '1'; end if;
      end if;
    end if;
    if ((annul or trap) /= '1') then      
      case op is
      when FMT2 =>
        case op2 is
        when FBFCC => 
          if FPEN and (fpo.exc = '1') then trap := '1'; tt := TT_FPEXC; end if;
        when CBCCC =>
    	  if CPEN and (cpo.exc = '1') then trap := '1'; tt := TT_CPEXC; end if;
        when others => null;
        end case;
      when FMT3 =>
        case op3 is
	when WRPSR =>
	  if (orv(cwpx) = '1') then trap := '1'; tt := TT_IINST; end if;
	when UDIV | SDIV | UDIVCC | SDIVCC =>
    	  if DIVEN then 
	    if r.m.divz = '1' then trap := '1'; tt := TT_DIV; end if;
          end if;
	when JMPL | RETT =>
	  if r.m.nalign = '1' then trap := '1'; tt := TT_UNALA; end if;
        when TADDCCTV | TSUBCCTV =>
	  if (notag = 0) and (r.m.icc(1) = '1') then
	    trap := '1'; tt := TT_TAG;
	  end if;
	when FLUSH => iflush := '1';
	when FPOP1 | FPOP2 =>
          if FPEN and (fpo.exc = '1') then trap := '1'; tt := TT_FPEXC; end if;
	when CPOP1 | CPOP2 =>
    	  if CPEN and (cpo.exc = '1') then trap := '1'; tt := TT_CPEXC; end if;
        when others => null;
        end case;
      when LDST =>
        if r.m.ctrl.cnt = "00" then
          case op3 is
            when LDDF | STDF | STDFQ =>
	    if FPEN then
	      if nalign_d = '1' then
	        trap := '1'; tt := TT_UNALA; nullify := '1';
              elsif (fpo.exc and r.m.ctrl.pv) = '1' 
              then trap := '1'; tt := TT_FPEXC; nullify := '1'; end if;
	    end if;
	  when LDDC | STDC | STDCQ =>
	    if CPEN then
	      if nalign_d = '1' then
	        trap := '1'; tt := TT_UNALA; nullify := '1';
    	      elsif ((cpo.exc and r.m.ctrl.pv) = '1') 
    	      then trap := '1'; tt := TT_CPEXC; nullify := '1'; end if;
	    end if;
	  when LDD | ISTD | LDDA | STDA =>
	    if r.m.result(2 downto 0) /= "000" then
	      trap := '1'; tt := TT_UNALA; nullify := '1';
	    end if;
 	  when LDF | LDFSR | STFSR | STF =>
	    if FPEN and (r.m.nalign = '1') then
	      trap := '1'; tt := TT_UNALA; nullify := '1';
            elsif FPEN and ((fpo.exc and r.m.ctrl.pv) = '1')
            then trap := '1'; tt := TT_FPEXC; nullify := '1'; end if;
 	  when LDC | LDCSR | STCSR | STC =>
	    if CPEN and (r.m.nalign = '1') then 
	      trap := '1'; tt := TT_UNALA; nullify := '1';
    	    elsif CPEN and ((cpo.exc and r.m.ctrl.pv) = '1') 
    	    then trap := '1'; tt := TT_CPEXC; nullify := '1'; end if;
 	  when LD | LDA | ST | STA | SWAP | SWAPA =>
	    if r.m.result(1 downto 0) /= "00" then
	      trap := '1'; tt := TT_UNALA; nullify := '1';
	    end if;
          when LDUH | LDUHA | LDSH | LDSHA | STH | STHA =>
	    if r.m.result(0) /= '0' then
	      trap := '1'; tt := TT_UNALA; nullify := '1';
	    end if;
          when others => null;
          end case;
          for i in 1 to NWP loop
            if ((((wpr(i-1).load and not op3(2)) or (wpr(i-1).store and op3(2))) = '1') and
                (((wpr(i-1).addr xor r.m.result(31 downto 2)) and wpr(i-1).mask) = zero32(31 downto 2)))
            then trap := '1'; tt := TT_WATCH; nullify := '1'; end if;
          end loop;
	end if;
      when others => null;
      end case;
    end if;
    if (rstn = '0') or (r.x.rstate = dsu2) then werr := '0'; end if;
    trapout := trap; werrout := werr;
  end;

  procedure irq_trap(r       : in registers;
                     ir      : in irestart_register;
                     irl     : in std_logic_vector(3 downto 0);
                     annul   : in std_ulogic;
                     pv      : in std_ulogic;
                     trap    : in std_ulogic;
                     tt      : in std_logic_vector(5 downto 0);
                     nullify : in std_ulogic;
                     irqen   : out std_ulogic;
                     irqen2  : out std_ulogic;
                     nullify2 : out std_ulogic;
                     trap2, ipend  : out std_ulogic;
                     tt2      : out std_logic_vector(5 downto 0)) is
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
    variable pend : std_ulogic;
  begin
    nullify2 := nullify; trap2 := trap; tt2 := tt; 
    op := r.m.ctrl.inst(31 downto 30); op3 := r.m.ctrl.inst(24 downto 19);
    irqen := '1'; irqen2 := r.m.irqen;

    if (annul or trap) = '0' then
      if ((op = FMT3) and (op3 = WRPSR)) then irqen := '0'; end if;    
    end if;

    if (irl = "1111") or (irl > r.w.s.pil) then
      pend := r.m.irqen and r.m.irqen2 and r.w.s.et and not ir.pwd;
    else pend := '0'; end if;
    ipend := pend;

    if ((not annul) and pv and (not trap) and pend) = '1' then
      trap2 := '1'; tt2 := "01" & irl;
      if op = LDST then nullify2 := '1'; end if;
    end if;
  end;

  procedure irq_intack(r : in registers; holdn : in std_ulogic; intack: out std_ulogic) is 
  begin
    intack := '0';
    if r.x.rstate = trap then 
      if r.w.s.tt(7 downto 4) = "0001" then intack := '1'; end if;
    end if;
  end;
  
-- write special registers

  procedure sp_write (r : registers; wpr : watchpoint_registers;
        s : out special_register_type; vwpr : out watchpoint_registers) is
  variable op : std_logic_vector(1 downto 0);
  variable op2 : std_logic_vector(2 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  variable rd  : std_logic_vector(4 downto 0);
  variable i   : integer range 0 to 3;
  begin

    op  := r.x.ctrl.inst(31 downto 30);
    op2 := r.x.ctrl.inst(24 downto 22);
    op3 := r.x.ctrl.inst(24 downto 19);
    s   := r.w.s;
    rd  := r.x.ctrl.inst(29 downto 25);
    vwpr := wpr;
    
      case op is
      when FMT3 =>
        case op3 is
        when WRY =>
          if rd = "00000" then
            s.y := r.x.result;
          elsif MACEN and (rd = "10010") then
	    s.asr18 := r.x.result;
          elsif (rd = "10001") then
	    s.dwt := r.x.result(14);
            if (svt = 1) then s.svt := r.x.result(13); end if;
          elsif rd(4 downto 3) = "11" then -- %ASR24 - %ASR31
	    case rd(2 downto 0) is
	    when "000" => 
              vwpr(0).addr := r.x.result(31 downto 2);
              vwpr(0).exec := r.x.result(0); 
	    when "001" => 
              vwpr(0).mask := r.x.result(31 downto 2);
              vwpr(0).load := r.x.result(1);
              vwpr(0).store := r.x.result(0);              
	    when "010" => 
              vwpr(1).addr := r.x.result(31 downto 2);
              vwpr(1).exec := r.x.result(0); 
	    when "011" => 
              vwpr(1).mask := r.x.result(31 downto 2);
              vwpr(1).load := r.x.result(1);
              vwpr(1).store := r.x.result(0);              
	    when "100" => 
              vwpr(2).addr := r.x.result(31 downto 2);
              vwpr(2).exec := r.x.result(0); 
	    when "101" => 
              vwpr(2).mask := r.x.result(31 downto 2);
              vwpr(2).load := r.x.result(1);
              vwpr(2).store := r.x.result(0);              
	    when "110" => 
              vwpr(3).addr := r.x.result(31 downto 2);
              vwpr(3).exec := r.x.result(0); 
	    when others =>   -- "111"
              vwpr(3).mask := r.x.result(31 downto 2);
              vwpr(3).load := r.x.result(1);
              vwpr(3).store := r.x.result(0);              
            end case;
          end if;
        when WRPSR =>
          s.cwp := r.x.result(NWINLOG2-1 downto 0);
          s.icc := r.x.result(23 downto 20);
          s.ec  := r.x.result(13);
          if FPEN then s.ef  := r.x.result(12); end if;
          s.pil := r.x.result(11 downto 8);
          s.s   := r.x.result(7);
          s.ps  := r.x.result(6);
          s.et  := r.x.result(5);
        when WRWIM =>
          s.wim := r.x.result(NWIN-1 downto 0);
        when WRTBR =>
          s.tba := r.x.result(31 downto 12);
        when SAVE =>
          if (not CWPOPT) and (r.w.s.cwp = CWPMIN) then s.cwp := CWPMAX;
          else s.cwp := r.w.s.cwp - 1 ; end if;
        when RESTORE =>
          if (not CWPOPT) and (r.w.s.cwp = CWPMAX) then s.cwp := CWPMIN;
          else s.cwp := r.w.s.cwp + 1; end if;
        when RETT =>
          if (not CWPOPT) and (r.w.s.cwp = CWPMAX) then s.cwp := CWPMIN;
          else s.cwp := r.w.s.cwp + 1; end if;
          s.s := r.w.s.ps;
          s.et := '1';
        when others => null;
        end case;
      when others => null;
      end case;
      if r.x.ctrl.wicc = '1' then s.icc := r.x.icc; end if;
      if r.x.ctrl.wy = '1' then s.y := r.x.y; end if;
      if MACPIPE and (r.x.mac = '1') then 
        s.asr18 := mulo.result(31 downto 0);
	s.y := mulo.result(63 downto 32);
      end if;
  end;

  function npc_find (r : registers) return std_logic_vector is
  variable npc : std_logic_vector(2 downto 0);
  begin
    npc := "011";
    if r.m.ctrl.pv = '1' then npc := "000";
    elsif r.e.ctrl.pv = '1' then npc := "001";
    elsif r.a.ctrl.pv = '1' then npc := "010";
    elsif r.d.pv = '1' then npc := "011";
    elsif v8 /= 0 then npc := "100"; end if;
    return(npc);
  end;

  function npc_gen (r : registers) return word is
  variable npc : std_logic_vector(31 downto 0);
  begin
    npc :=  r.a.ctrl.pc(31 downto 2) & "00";
    case r.x.npc is
    when "000" => npc(31 downto 2) := r.x.ctrl.pc(31 downto 2);
    when "001" => npc(31 downto 2) := r.m.ctrl.pc(31 downto 2);
    when "010" => npc(31 downto 2) := r.e.ctrl.pc(31 downto 2);
    when "011" => npc(31 downto 2) := r.a.ctrl.pc(31 downto 2);
    when others => 
	if v8 /= 0 then npc(31 downto 2) := r.d.pc(31 downto 2); end if;
    end case;
    return(npc);
  end;

  procedure mul_res(r : registers; asr18in : word; result, y, asr18 : out word; 
	  icc : out std_logic_vector(3 downto 0)) is
  variable op  : std_logic_vector(1 downto 0);
  variable op3 : std_logic_vector(5 downto 0);
  begin
    op    := r.m.ctrl.inst(31 downto 30); op3   := r.m.ctrl.inst(24 downto 19);
    result := r.m.result; y := r.m.y; icc := r.m.icc; asr18 := asr18in;
    case op is
    when FMT3 =>
      case op3 is
      when UMUL | SMUL =>
    	if MULEN then 
	  result := mulo.result(31 downto 0);
          y := mulo.result(63 downto 32);
        end if;
      when UMULCC | SMULCC =>
    	if MULEN then 
          result := mulo.result(31 downto 0); icc := mulo.icc;
          y := mulo.result(63 downto 32);
        end if;
      when UMAC | SMAC =>
	if MACEN and not MACPIPE then
	  result := mulo.result(31 downto 0);
	  asr18  := mulo.result(31 downto 0);
          y := mulo.result(63 downto 32);
	end if;
      when UDIV | SDIV =>
    	if DIVEN then 
          result := divo.result(31 downto 0);
        end if;
      when UDIVCC | SDIVCC =>
    	if DIVEN then 
          result := divo.result(31 downto 0); icc := divo.icc;
        end if;
      when others => null;
      end case;
    when others => null;
    end case;
  end;

  function powerdwn(r : registers; trap : std_ulogic; rp : pwd_register_type) return std_ulogic is
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
    variable rd  : std_logic_vector(4 downto 0);
    variable pd  : std_ulogic;
  begin
    op := r.x.ctrl.inst(31 downto 30);
    op3 := r.x.ctrl.inst(24 downto 19);
    rd  := r.x.ctrl.inst(29 downto 25);    
    pd := '0';
    if (not (r.x.ctrl.annul or trap) and r.x.ctrl.pv) = '1' then
      if ((op = FMT3) and (op3 = WRY) and (rd = "10011")) then pd := '1'; end if;
      pd := pd or rp.pwd;
    end if;
    return(pd);
  end;
  
  signal dummy : std_ulogic;
  signal cpu_index : std_logic_vector(3 downto 0);
  signal disasen : std_ulogic;

begin

  comb : process(ico, dco, rfo, r, wpr, ir, dsur, rstn, holdn, irqi, dbgi, fpo, cpo, tbo,
		 mulo, divo, dummy, rp)

  variable v 	: registers;
  variable vp 	: pwd_register_type;
  variable vwpr : watchpoint_registers;
  variable vdsu : dsu_registers;
  variable npc 	: std_logic_vector(31 downto PCLOW);
  variable de_raddr1, de_raddr2 : std_logic_vector(9 downto 0);
  variable de_rs2, de_rd : std_logic_vector(4 downto 0);
  variable de_hold_pc, de_branch, de_fpop, de_ldlock : std_ulogic;
  variable de_cwp, de_cwp2 : cwptype;
  variable de_inull : std_ulogic;
  variable de_ren1, de_ren2 : std_ulogic;
  variable de_wcwp : std_ulogic;
  variable de_inst : word;
  variable de_branch_address : pctype;
  variable de_icc : std_logic_vector(3 downto 0);
  variable de_fbranch, de_cbranch : std_ulogic;
  variable de_rs1mod : std_ulogic;

  variable ra_op1, ra_op2 : word;
  variable ra_div : std_ulogic;

  variable ex_jump, ex_link_pc : std_ulogic;
  variable ex_jump_address : pctype;
  variable ex_add_res : std_logic_vector(32 downto 0);
  variable ex_shift_res, ex_logic_res, ex_misc_res : word;
  variable ex_edata, ex_edata2 : word;
  variable ex_dci : dc_in_type;
  variable ex_force_a2, ex_load, ex_ymsb : std_ulogic;
  variable ex_op1, ex_op2, ex_result, ex_result2, mul_op2 : word;
  variable ex_shcnt : std_logic_vector(4 downto 0);
  variable ex_dsuen : std_ulogic;
  variable ex_ldbp2 : std_ulogic;
  variable ex_sari : std_ulogic;
  
  variable me_inull, me_nullify, me_nullify2 : std_ulogic;
  variable me_iflush : std_ulogic;
  variable me_newtt : std_logic_vector(5 downto 0);
  variable me_asr18 : word;
  variable me_signed : std_ulogic;
  variable me_size, me_laddr : std_logic_vector(1 downto 0);
  variable me_icc : std_logic_vector(3 downto 0);

  
  variable xc_result : word;
  variable xc_df_result : word;
  variable xc_waddr : std_logic_vector(9 downto 0);
  variable xc_exception, xc_wreg : std_ulogic;
  variable xc_trap_address : pctype;
  variable xc_vectt : std_logic_vector(7 downto 0);
  variable xc_trap : std_ulogic;
  variable xc_fpexack : std_ulogic;
  variable xc_rstn, xc_halt : std_ulogic;
  
--  variable wr_rf1_data, wr_rf2_data : word;
  variable diagdata : word;
  variable tbufi : tracebuf_in_type;
  variable dbgm : std_ulogic;
  variable fpcdbgwr : std_ulogic;
  variable vfpi : fpc_in_type;
  variable dsign : std_ulogic;
  variable pwrd, sidle : std_ulogic;
  variable vir : irestart_register;
  variable icnt : std_ulogic;
  variable tbufcntx : std_logic_vector(TBUFBITS-1 downto 0);
  
  begin

    v := r; vwpr := wpr; vdsu := dsur; vp := rp;
    xc_fpexack := '0'; sidle := '0';
    fpcdbgwr := '0'; vir := ir; xc_rstn := rstn;
    
-----------------------------------------------------------------------
-- WRITE STAGE
-----------------------------------------------------------------------

--    wr_rf1_data := rfo.data1; wr_rf2_data := rfo.data2;
--    if irfwt = 0 then
--      if r.w.wreg = '1' then
--	if r.a.rfa1 = r.w.wa then wr_rf1_data := r.w.result; end if;
--	if r.a.rfa2 = r.w.wa then wr_rf2_data := r.w.result; end if;
--      end if;
--    end if;

-----------------------------------------------------------------------
-- EXCEPTION STAGE
-----------------------------------------------------------------------

    xc_exception := '0'; xc_halt := '0'; icnt := '0';
    xc_waddr := (others => '0');
    xc_waddr(RFBITS-1 downto 0) := r.x.ctrl.rd(RFBITS-1 downto 0);
    xc_trap := r.x.mexc or r.x.ctrl.trap;
    v.x.nerror := rp.error;
    
    if r.x.mexc = '1' then xc_vectt := "00" & TT_DAEX;
    elsif r.x.ctrl.tt = TT_TICC then
      xc_vectt := '1' & r.x.result(6 downto 0);
    else xc_vectt := "00" & r.x.ctrl.tt; end if;
    if r.w.s.svt = '0' then
      xc_trap_address(31 downto 4) := r.w.s.tba & xc_vectt; 
    else
      xc_trap_address(31 downto 4) := r.w.s.tba & "00000000"; 
    end if;
    xc_trap_address(3 downto PCLOW) := (others => '0');
    xc_wreg := '0'; v.x.annul_all := '0'; 
    if (r.x.ctrl.ld = '1') then 
      if (lddel = 2) then 
        xc_result := ld_align(r.x.data, r.x.set, r.x.dci.size, r.x.laddr, r.x.dci.signed);
      else xc_result := r.x.data(0); end if;
    elsif MACEN and MACPIPE and (r.x.mac = '1') then
      xc_result := mulo.result(31 downto 0);
    else xc_result := r.x.result; end if;
    xc_df_result := xc_result;
    if DBGUNIT then 
      dbgm := dbgexc(r, dbgi, xc_trap, xc_vectt);
      if (dbgi.dsuen and dbgi.dbreak) = '0'then v.x.debug := '0'; end if;
    else dbgm := '0'; v.x.debug := '0'; end if;
    if PWRD2 then pwrd := powerdwn(r, xc_trap, rp); else pwrd := '0'; end if;
    
    case r.x.rstate is
    when run =>
      if (not r.x.ctrl.annul and r.x.ctrl.pv and not r.x.debug) = '1' then
	icnt := holdn;
      end if;
      if dbgm = '1' then        
        v.x.annul_all := '1'; vir.addr := r.x.ctrl.pc;
        v.x.rstate := dsu1; v.x.debug := '1';
        v.x.npc := npc_find(r);
        vdsu.tt := xc_vectt; vdsu.err := dbgerr(r, dbgi, xc_vectt);
      elsif (pwrd = '1') and (ir.pwd = '0') then
        v.x.annul_all := '1'; vir.addr := r.x.ctrl.pc;
        v.x.rstate := dsu1; v.x.npc := npc_find(r); vp.pwd := '1';
      elsif (r.x.ctrl.annul or xc_trap) = '0' then
        xc_wreg := r.x.ctrl.wreg;
        sp_write (r, wpr, v.w.s, vwpr);        
        vir.pwd := '0';
      elsif ((not r.x.ctrl.annul) and xc_trap) = '1' then
        xc_exception := '1'; xc_result := r.x.ctrl.pc(31 downto 2) & "00";
        xc_wreg := '1'; v.w.s.tt := xc_vectt; v.w.s.ps := r.w.s.s;
        v.w.s.s := '1'; v.x.annul_all := '1'; v.x.rstate := trap;
        xc_waddr := (others => '0');
        xc_waddr(NWINLOG2 + 3  downto 0) :=  r.w.s.cwp & "0001";
	v.x.npc := npc_find(r);
        fpexack(r, xc_fpexack);
        if r.w.s.et = '0' then
--	  v.x.rstate := dsu1; xc_wreg := '0'; vp.error := '1';
	   xc_wreg := '0';
        end if;
      end if;
    when trap =>
      xc_result := npc_gen(r); xc_wreg := '1';
      xc_waddr := (others => '0');
      xc_waddr(NWINLOG2 + 3  downto 0) :=  r.w.s.cwp & "0010";
      if (r.w.s.et = '1') then
	v.w.s.et := '0'; v.x.rstate := run;
        if (not CWPOPT) and (r.w.s.cwp = CWPMIN) then v.w.s.cwp := CWPMAX;
        else v.w.s.cwp := r.w.s.cwp - 1 ; end if;
      else
	v.x.rstate := dsu1; xc_wreg := '0'; vp.error := '1';
      end if;
    when dsu1 =>
      xc_exception := '1'; v.x.annul_all := '1';
      xc_trap_address(31 downto PCLOW) := r.f.pc;        
      if DBGUNIT or PWRD2 or (smp /= 0) then 
        xc_trap_address(31 downto PCLOW) := ir.addr; 
        vir.addr := npc_gen(r)(31 downto PCLOW);
        v.x.rstate := dsu2;
      end if;
      if DBGUNIT then v.x.debug := r.x.debug; end if;
    when dsu2 =>      
      xc_exception := '1'; v.x.annul_all := '1';
      xc_trap_address(31 downto PCLOW) := r.f.pc;        
      if DBGUNIT or PWRD2 or (smp /= 0) then
	sidle := (rp.pwd or rp.error) and ico.idle and dco.idle and not r.x.debug;
        if DBGUNIT then
	  if dbgi.reset = '1' then 
	    if smp /=0 then vp.pwd := not irqi.run; else vp.pwd := '0'; end if;
	    vp.error := '0';
	  end if;
          if (dbgi.dsuen and dbgi.dbreak) = '1'then v.x.debug := '1'; end if;
          diagwr(r, dsur, ir, dbgi, wpr, v.w.s, vwpr, vdsu.asi, xc_trap_address,
            vir.addr, vdsu.tbufcnt, xc_wreg, xc_waddr, xc_result, fpcdbgwr);
	  xc_halt := dbgi.halt;
        end if;
	if r.x.ipend = '1' then vp.pwd := '0'; end if;
        if (rp.error or rp.pwd or r.x.debug or xc_halt) = '0' then
	  v.x.rstate := run; v.x.annul_all := '0'; vp.error := '0';
          xc_trap_address(31 downto PCLOW) := ir.addr; v.x.debug := '0';
          vir.pwd := '1';
        end if;
        if (smp /= 0) and (irqi.rst = '1') then 
	  vp.pwd := '0'; vp.error := '0';
	end if;
      end if;
    when others =>
    end case;

    irq_intack(r, holdn, v.x.intack);          
    itrace(r, dsur, vdsu, xc_result, xc_exception, dbgi, rp.error, xc_trap, tbufcntx, tbufi);
    vdsu.tbufcnt := tbufcntx;

    v.w.except := xc_exception; v.w.result := xc_result;
    if (r.x.rstate = dsu2) then v.w.except := '0'; end if;
    v.w.wa := xc_waddr(RFBITS-1 downto 0); v.w.wreg := xc_wreg and holdn;

    rfi.wdata <= xc_result; rfi.waddr <= xc_waddr;
    rfi.wren <= (xc_wreg and holdn) and not dco.scanen;
    irqo.intack <= r.x.intack and holdn;
    irqo.irl <= r.w.s.tt(3 downto 0);
    irqo.pwd <= rp.pwd;
    dbgo.halt <= xc_halt;
    dbgo.pwd <= rp.pwd;
    dbgo.idle <= sidle;
    dbgo.icnt <= icnt;
    dci.intack <= r.x.intack and holdn;
    
    if (xc_rstn = '0') then 
      v.w.except := '0'; v.w.s.et := '0'; v.w.s.svt := '0'; v.w.s.dwt := '0';
      v.x.annul_all := '1'; v.x.rstate := run; vir.pwd := '0'; 
      vp.pwd := '0'; v.x.debug := '0'; --vp.error := '0';
      v.x.nerror := '0';
      if svt = 1 then  v.w.s.tt := (others => '0'); end if;
      if DBGUNIT then
        if (dbgi.dsuen and dbgi.dbreak) = '1' then
          v.x.rstate := dsu1; v.x.debug := '1';
        end if;
      end if;
      if (smp /= 0) and (irqi.run = '0') and (rstn = '0') then 
	v.x.rstate := dsu1; vp.pwd := '1';
      end if;
    end if;
    
    if not FPEN then v.w.s.ef := '0'; end if;

-----------------------------------------------------------------------
-- MEMORY STAGE
-----------------------------------------------------------------------

    v.x.ctrl := r.m.ctrl; v.x.dci := r.m.dci;
    v.x.ctrl.rett := r.m.ctrl.rett and not r.m.ctrl.annul;
    v.x.mac := r.m.mac; v.x.laddr := r.m.result(1 downto 0);
    v.x.ctrl.annul := r.m.ctrl.annul or v.x.annul_all; 
    
    mul_res(r, v.w.s.asr18, v.x.result, v.x.y, me_asr18, me_icc);
    mem_trap(r, wpr, v.x.ctrl.annul, holdn, v.x.ctrl.trap, me_iflush,
	     me_nullify, v.m.werr, v.x.ctrl.tt);
    me_newtt := v.x.ctrl.tt;

    irq_trap(r, ir, irqi.irl, v.x.ctrl.annul, v.x.ctrl.pv, v.x.ctrl.trap, me_newtt, me_nullify,
             v.m.irqen, v.m.irqen2, me_nullify2, v.x.ctrl.trap,
	     v.x.ipend, v.x.ctrl.tt);   
    
    if (r.m.ctrl.ld or not dco.mds) = '1' then 
      for i in 0 to dsets-1 loop v.x.data(i) := dco.data(i); end loop;
      v.x.set := dco.set(DSETMSB downto 0);
      if dco.mds = '0' then
	me_size := r.x.dci.size; me_laddr := r.x.laddr; me_signed := r.x.dci.signed;
      else
	me_size := v.x.dci.size; me_laddr := v.x.laddr; me_signed := v.x.dci.signed;
      end if;
      if lddel /= 2 then
        v.x.data(0) := ld_align(v.x.data, v.x.set, me_size, me_laddr, me_signed);
      end if;
    end if;
    v.x.mexc := dco.mexc;

    v.x.icc := me_icc;
    v.x.ctrl.wicc := r.m.ctrl.wicc and not v.x.annul_all;
    
    if MACEN and ((v.x.ctrl.annul or v.x.ctrl.trap) = '0') then
      v.w.s.asr18 := me_asr18;
    end if;

    if (r.x.rstate = dsu2) then
      me_nullify2 := '0'; v.x.set := dco.set(DSETMSB downto 0);
    end if;
    
    dci.maddress <= r.m.result;
    dci.enaddr   <= r.m.dci.enaddr;
    dci.asi      <= r.m.dci.asi;
    dci.size     <= r.m.dci.size;
    dci.nullify  <= me_nullify2;
    dci.lock     <= r.m.dci.lock and not r.m.ctrl.annul;
    dci.read     <= r.m.dci.read;
    dci.write    <= r.m.dci.write;
    dci.flush    <= me_iflush;
    dci.dsuen    <= r.m.dci.dsuen;
    dci.msu    <= r.m.su;
    dci.esu    <= r.e.su;
    dbgo.ipend <= v.x.ipend;

-----------------------------------------------------------------------
-- EXECUTE STAGE
-----------------------------------------------------------------------

    v.m.ctrl := r.e.ctrl; ex_op1 := r.e.op1; ex_op2 := r.e.op2;
    v.m.ctrl.rett := r.e.ctrl.rett and not r.e.ctrl.annul;
    v.m.ctrl.wreg := r.e.ctrl.wreg and not v.x.annul_all;    
    ex_ymsb := r.e.ymsb; mul_op2 := ex_op2; ex_shcnt := r.e.shcnt;
    v.e.cwp := r.a.cwp; ex_sari := r.e.sari;
    v.m.su := r.e.su;
    if MULTYPE = 3 then v.m.mul := r.e.mul; else v.m.mul := '0'; end if;

    if lddel = 1 then
      if r.e.ldbp1 = '1' then 
	ex_op1 := r.x.data(0); 
	ex_sari := r.x.data(0)(31) and r.e.ctrl.inst(19) and r.e.ctrl.inst(20);
      end if;
      if r.e.ldbp2 = '1' then 
	ex_op2 := r.x.data(0); ex_ymsb := r.x.data(0)(0); 
	mul_op2 := ex_op2; ex_shcnt := r.x.data(0)(4 downto 0);
	if r.e.invop2 = '1' then 
	  ex_op2 := not ex_op2; ex_shcnt := not ex_shcnt;
        end if;
      end if;
    end if;

    ex_add_res := (ex_op1 & '1') + (ex_op2 & r.e.alucin);

    if ex_add_res(2 downto 1) = "00" then v.m.nalign := '0';
    else v.m.nalign := '1'; end if;

    dcache_gen(r, v, ex_dci, ex_link_pc, ex_jump, ex_force_a2, ex_load );
    ex_jump_address := ex_add_res(32 downto PCLOW+1);
    logic_op(r, ex_op1, ex_op2, v.x.y, ex_ymsb, ex_logic_res, v.m.y);
    ex_shift_res := shift(r, ex_op1, ex_op2, ex_shcnt, ex_sari);
    misc_op(r, wpr, ex_op1, ex_op2, xc_df_result, v.x.y, ex_misc_res, ex_edata);
    ex_add_res(3):= ex_add_res(3) or ex_force_a2;    
    alu_select(r, ex_add_res, ex_op1, ex_op2, ex_shift_res, ex_logic_res,
	ex_misc_res, ex_result, me_icc, v.m.icc, v.m.divz);    
    dbg_cache(holdn, dbgi, r, dsur, ex_result, ex_dci, ex_result2, v.m.dci);
    fpstdata(r, ex_edata, ex_result2, fpo.data, ex_edata2, v.m.result);
    cwp_ex(r, v.m.wcwp);    
    
    v.m.ctrl.annul := v.m.ctrl.annul or v.x.annul_all;
    v.m.ctrl.wicc := r.e.ctrl.wicc and not v.x.annul_all; 
    v.m.mac := r.e.mac;
    if (DBGUNIT and (r.x.rstate = dsu2)) then v.m.ctrl.ld := '1'; end if;
    dci.eenaddr  <= v.m.dci.enaddr;
    dci.eaddress <= ex_add_res(32 downto 1);
    dci.edata <= ex_edata2;
    
-----------------------------------------------------------------------
-- REGFILE STAGE
-----------------------------------------------------------------------

    v.e.ctrl := r.a.ctrl; v.e.jmpl := r.a.jmpl;
    v.e.ctrl.annul := r.a.ctrl.annul or v.x.annul_all;
    v.e.ctrl.rett := r.a.ctrl.rett and not r.a.ctrl.annul;
    v.e.ctrl.wreg := r.a.ctrl.wreg and not v.x.annul_all;    
    v.e.su := r.a.su; v.e.et := r.a.et;
    v.e.ctrl.wicc := r.a.ctrl.wicc and not v.x.annul_all;
    
    exception_detect(r, wpr, dbgi, r.a.ctrl.trap, r.a.ctrl.tt, 
		     v.e.ctrl.trap, v.e.ctrl.tt);
    op_mux(r, rfo.data1, v.m.result, v.x.result, xc_df_result, zero32, 
	r.a.rsel1, v.e.ldbp1, ra_op1);
    op_mux(r, rfo.data2,  v.m.result, v.x.result, xc_df_result, r.a.imm, 
	r.a.rsel2, ex_ldbp2, ra_op2);
    alu_op(r, ra_op1, ra_op2, v.m.icc, v.m.y(0), ex_ldbp2, v.e.op1, v.e.op2,
	   v.e.aluop, v.e.alusel, v.e.aluadd, v.e.shcnt, v.e.sari, v.e.shleft,
	   v.e.ymsb, v.e.mul, ra_div, v.e.mulstep, v.e.mac, v.e.ldbp2, v.e.invop2);
    cin_gen(r, v.m.icc(0), v.e.alucin);

-----------------------------------------------------------------------
-- DECODE STAGE
-----------------------------------------------------------------------

    if ISETS > 1 then de_inst := r.d.inst(conv_integer(r.d.set));
    else de_inst := r.d.inst(0); end if;

    de_icc := r.m.icc; v.a.cwp := r.d.cwp;
    su_et_select(r, v.w.s.ps, v.w.s.s, v.w.s.et, v.a.su, v.a.et);
    wicc_y_gen(de_inst, v.a.ctrl.wicc, v.a.ctrl.wy);
    cwp_ctrl(r, v.w.s.wim, de_inst, de_cwp, v.a.wovf, v.a.wunf, de_wcwp);
    rs1_gen(r, de_inst, v.a.rs1, de_rs1mod); 
    de_rs2 := de_inst(4 downto 0);
    de_raddr1 := (others => '0'); de_raddr2 := (others => '0');
    
    if RS1OPT then
      if de_rs1mod = '1' then
        regaddr(r.d.cwp, de_inst(29 downto 26) & v.a.rs1(0), de_raddr1(RFBITS-1 downto 0));
      else
        regaddr(r.d.cwp, de_inst(18 downto 15) & v.a.rs1(0), de_raddr1(RFBITS-1 downto 0));
      end if;
    else
      regaddr(r.d.cwp, v.a.rs1, de_raddr1(RFBITS-1 downto 0));
    end if;
    regaddr(r.d.cwp, de_rs2, de_raddr2(RFBITS-1 downto 0));
    v.a.rfa1 := de_raddr1(RFBITS-1 downto 0); 
    v.a.rfa2 := de_raddr2(RFBITS-1 downto 0); 

    rd_gen(r, de_inst, v.a.ctrl.wreg, v.a.ctrl.ld, de_rd);
    regaddr(de_cwp, de_rd, v.a.ctrl.rd);
    
    fpbranch(de_inst, fpo.cc, de_fbranch);
    fpbranch(de_inst, cpo.cc, de_cbranch);
    v.a.imm := imm_data(r, de_inst);
    lock_gen(r, de_rs2, de_rd, v.a.rfa1, v.a.rfa2, v.a.ctrl.rd, de_inst, 
	fpo.ldlock, v.e.mul, ra_div, v.a.ldcheck1, v.a.ldcheck2, de_ldlock, 
	v.a.ldchkra, v.a.ldchkex);
    ic_ctrl(r, de_inst, v.x.annul_all, de_ldlock, branch_true(de_icc, de_inst), 
	de_fbranch, de_cbranch, fpo.ccv, cpo.ccv, v.d.cnt, v.d.pc, de_branch,
	v.a.ctrl.annul, v.d.annul, v.a.jmpl, de_inull, v.d.pv, v.a.ctrl.pv,
	de_hold_pc, v.a.ticc, v.a.ctrl.rett, v.a.mulstart, v.a.divstart);

    cwp_gen(r, v, v.a.ctrl.annul, de_wcwp, de_cwp, v.d.cwp);    
    
    v.d.inull := ra_inull_gen(r, v);

    op_find(r, v.a.ldchkra, v.a.ldchkex, v.a.rs1, v.a.rfa1, 
	    false, v.a.rfe1, v.a.rsel1, v.a.ldcheck1);
    op_find(r, v.a.ldchkra, v.a.ldchkex, de_rs2, v.a.rfa2, 
	    imm_select(de_inst), v.a.rfe2, v.a.rsel2, v.a.ldcheck2);

    de_branch_address := branch_address(de_inst, r.d.pc);

    v.a.ctrl.annul := v.a.ctrl.annul or v.x.annul_all;    
    v.a.ctrl.wicc := v.a.ctrl.wicc and not v.a.ctrl.annul;
    v.a.ctrl.wreg := v.a.ctrl.wreg and not v.a.ctrl.annul;
    v.a.ctrl.rett := v.a.ctrl.rett and not v.a.ctrl.annul;
    v.a.ctrl.wy := v.a.ctrl.wy and not v.a.ctrl.annul;

    v.a.ctrl.trap := r.d.mexc;
    v.a.ctrl.tt := "000000";
    v.a.ctrl.inst := de_inst;
    v.a.ctrl.pc := r.d.pc;
    v.a.ctrl.cnt := r.d.cnt;
    v.a.step := r.d.step;

    if holdn = '0' then 
      de_raddr1(RFBITS-1 downto 0) := r.a.rfa1;
      de_raddr2(RFBITS-1 downto 0) := r.a.rfa2;
      de_ren1 := r.a.rfe1; de_ren2 := r.a.rfe2;
    else
      de_ren1 := v.a.rfe1; de_ren2 := v.a.rfe2;
    end if;

    if DBGUNIT then
      if ((dbgi.denable and not dbgi.dwrite) = '1') and (r.x.rstate = dsu2) then        
        de_raddr1(RFBITS-1 downto 0) := dbgi.daddr(RFBITS+1 downto 2); de_ren1 := '1';
      end if;
      v.d.step := dbgi.step and not r.d.annul;      
    end if;

    rfi.raddr1 <= de_raddr1; rfi.raddr2 <= de_raddr2;
    rfi.ren1 <= de_ren1 and not dco.scanen;
    rfi.ren2 <= de_ren2 and not dco.scanen;
    rfi.diag <= dco.testen & "000";
    ici.inull <= de_inull;
    ici.flush <= me_iflush;
    if (xc_rstn = '0') then v.d.cnt := (others => '0'); end if;

-----------------------------------------------------------------------
-- FETCH STAGE
-----------------------------------------------------------------------

    npc := r.f.pc;
    if (xc_rstn = '0') then
      v.f.pc := (others => '0'); v.f.branch := '0';
      if DYNRST then v.f.pc(31 downto 12) := irqi.rstvec;
      else
        v.f.pc(31 downto 12) := conv_std_logic_vector(rstaddr, 20);
      end if;
    elsif xc_exception = '1' then	-- exception
      v.f.branch := '1'; v.f.pc := xc_trap_address;
      npc := v.f.pc;
--    elsif (not ra_inull and de_hold_pc) = '1' then
    elsif de_hold_pc = '1' then
      v.f.pc := r.f.pc; v.f.branch := r.f.branch;
      if ex_jump = '1' then
        v.f.pc := ex_jump_address; v.f.branch := '1';
        npc := v.f.pc;
      end if;
    elsif ex_jump = '1' then
      v.f.pc := ex_jump_address; v.f.branch := '1';
      npc := v.f.pc;
    elsif de_branch = '1' then
      v.f.pc := branch_address(de_inst, r.d.pc); v.f.branch := '1';
      npc := v.f.pc;
    else
      v.f.branch := '0';
      v.f.pc(31 downto 2) := r.f.pc(31 downto 2) + 1;    -- Address incrementer
      npc := v.f.pc;
    end if;

    ici.dpc <= r.d.pc(31 downto 2) & "00";
    ici.fpc <= r.f.pc(31 downto 2) & "00";
    ici.rpc <= npc(31 downto 2) & "00";
    ici.fbranch <= r.f.branch;
    ici.rbranch <= v.f.branch;
    ici.su <= v.a.su;
    ici.fline <= (others => '0');
    ici.flushl <= '0';

    if (ico.mds and de_hold_pc) = '0' then 
      for i in 0 to isets-1 loop
        v.d.inst(i) := ico.data(i);			-- latch instruction
      end loop;
      v.d.set := ico.set(ISETMSB downto 0);             -- latch instruction
      v.d.mexc := ico.mexc;				-- latch instruction
    end if;

-----------------------------------------------------------------------
-----------------------------------------------------------------------

    if DBGUNIT then -- DSU diagnostic read    
      diagread(dbgi, r, dsur, ir, wpr, dco, tbo, diagdata);
      diagrdy(dbgi.denable, dsur, r.m.dci, dco.mds, ico, vdsu.crdy);
    end if;
    
-----------------------------------------------------------------------
-- OUTPUTS
-----------------------------------------------------------------------

    rin <= v; wprin <= vwpr; dsuin <= vdsu; irin <= vir;
    muli.start <= r.a.mulstart and not r.a.ctrl.annul;
    muli.signed <= r.e.ctrl.inst(19);
    muli.op1 <= (ex_op1(31) and r.e.ctrl.inst(19)) & ex_op1;
    muli.op2 <= (mul_op2(31) and r.e.ctrl.inst(19)) & mul_op2;
    muli.mac <= r.e.ctrl.inst(24);
    if MACPIPE then muli.acc(39 downto 32) <= r.w.s.y(7 downto 0);
    else muli.acc(39 downto 32) <= r.x.y(7 downto 0); end if;
    muli.acc(31 downto 0) <= r.w.s.asr18;
    muli.flush <= r.x.annul_all;
    divi.start <= r.a.divstart and not r.a.ctrl.annul;
    divi.signed <= r.e.ctrl.inst(19);
    divi.flush <= r.x.annul_all;
    divi.op1 <= (ex_op1(31) and r.e.ctrl.inst(19)) & ex_op1;
    divi.op2 <= (ex_op2(31) and r.e.ctrl.inst(19)) & ex_op2;
    if (r.a.divstart and not r.a.ctrl.annul) = '1' then 
      dsign :=  r.a.ctrl.inst(19);
    else dsign := r.e.ctrl.inst(19); end if;
    divi.y <= (r.m.y(31) and dsign) & r.m.y;
    rpin <= vp;

    if DBGUNIT then
      dbgo.dsu <= '1'; dbgo.dsumode <= r.x.debug; dbgo.crdy <= dsur.crdy(2);
      dbgo.data <= diagdata;
      if TRACEBUF then tbi <= tbufi; else
        tbi.addr <= (others => '0'); tbi.data <= (others => '0');
        tbi.enable <= '0'; tbi.write <= (others => '0'); tbi.diag <= "0000";
      end if;
    else
      dbgo.dsu <= '0'; dbgo.data <= (others => '0'); dbgo.crdy  <= '0';
      dbgo.dsumode <= '0';
      tbi.addr <= (others => '0'); tbi.data <= (others => '0');
      tbi.enable <= '0'; tbi.write <= (others => '0'); tbi.diag <= "0000";
    end if;
    dbgo.error <= dummy and not r.x.nerror;

-- pragma translate_off
    if FPEN then
-- pragma translate_on
      vfpi.flush := v.x.annul_all; vfpi.exack := xc_fpexack; vfpi.a_rs1 := r.a.rs1; vfpi.d.inst := de_inst;
      vfpi.d.cnt := r.d.cnt; vfpi.d.annul := v.x.annul_all or r.d.annul; vfpi.d.trap := r.d.mexc;
      vfpi.d.pc(1 downto 0) := (others => '0'); vfpi.d.pc(31 downto PCLOW) := r.d.pc(31 downto PCLOW); 
      vfpi.d.pv := r.d.pv;
      vfpi.a.pc(1 downto 0) := (others => '0'); vfpi.a.pc(31 downto PCLOW) := r.a.ctrl.pc(31 downto PCLOW); 
      vfpi.a.inst := r.a.ctrl.inst; vfpi.a.cnt := r.a.ctrl.cnt; vfpi.a.trap := r.a.ctrl.trap;
      vfpi.a.annul := r.a.ctrl.annul; vfpi.a.pv := r.a.ctrl.pv;
      vfpi.e.pc(1 downto 0) := (others => '0'); vfpi.e.pc(31 downto PCLOW) := r.e.ctrl.pc(31 downto PCLOW); 
      vfpi.e.inst := r.e.ctrl.inst; vfpi.e.cnt := r.e.ctrl.cnt; vfpi.e.trap := r.e.ctrl.trap; vfpi.e.annul := r.e.ctrl.annul;
      vfpi.e.pv := r.e.ctrl.pv;
      vfpi.m.pc(1 downto 0) := (others => '0'); vfpi.m.pc(31 downto PCLOW) := r.m.ctrl.pc(31 downto PCLOW); 
      vfpi.m.inst := r.m.ctrl.inst; vfpi.m.cnt := r.m.ctrl.cnt; vfpi.m.trap := r.m.ctrl.trap; vfpi.m.annul := r.m.ctrl.annul;
      vfpi.m.pv := r.m.ctrl.pv;
      vfpi.x.pc(1 downto 0) := (others => '0'); vfpi.x.pc(31 downto PCLOW) := r.x.ctrl.pc(31 downto PCLOW); 
      vfpi.x.inst := r.x.ctrl.inst; vfpi.x.cnt := r.x.ctrl.cnt; vfpi.x.trap := xc_trap;
      vfpi.x.annul := r.x.ctrl.annul; vfpi.x.pv := r.x.ctrl.pv; vfpi.lddata := xc_df_result;--xc_result;
      if r.x.rstate = dsu2 then vfpi.dbg.enable := dbgi.denable;
      else vfpi.dbg.enable := '0'; end if;      
      vfpi.dbg.write := fpcdbgwr;
      vfpi.dbg.fsr := dbgi.daddr(22); -- IU reg access
      vfpi.dbg.addr := dbgi.daddr(6 downto 2);
      vfpi.dbg.data := dbgi.ddata;
      fpi <= vfpi;
      cpi <= vfpi;  -- dummy, just to kill some warnings ...
-- pragma translate_off
    end if;
-- pragma translate_on

  end process;

  preg : process (sclk)
  begin 
    if rising_edge(sclk) then 
      rp <= rpin; 
      if rstn = '0' then rp.error <= '0'; end if;
    end if;
  end process;

  reg : process (clk)
  begin
    if rising_edge(clk) then
      if (holdn = '1') then
        r <= rin;
      else
	r.x.ipend <= rin.x.ipend;
	r.m.werr <= rin.m.werr;
	if (holdn or ico.mds) = '0' then
          r.d.inst <= rin.d.inst; r.d.mexc <= rin.d.mexc; 
          r.d.set <= rin.d.set;
        end if;
	if (holdn or dco.mds) = '0' then
          r.x.data <= rin.x.data; r.x.mexc <= rin.x.mexc; 
          r.x.set <= rin.x.set;
        end if;
      end if;
      if rstn = '0' then
        r.w.s.s <= '1';
        if fabtech = axcel then
          r.d.inst <= (others => (others => '0'));
        end if;
      end if; 
    end if;
  end process;


  dsugen : if DBGUNIT generate
    dsureg : process(clk) begin
      if rising_edge(clk) then 
	if holdn = '1' then
          dsur <= dsuin;
        else
          dsur.crdy <= dsuin.crdy;
        end if;
      end if;
    end process;
  end generate;

  nodsugen : if not DBGUNIT generate
    dsur.err <= '0'; dsur.tbufcnt <= (others => '0'); dsur.tt <= (others => '0');
    dsur.asi <= (others => '0'); dsur.crdy <= (others => '0');
  end generate;

  irreg : if (DBGUNIT or PWRD2) generate
    dsureg : process(clk) begin
      if rising_edge(clk) then 
	if holdn = '1' then ir <= irin; end if;
      end if;
    end process;
  end generate;

  nirreg : if not (DBGUNIT or PWRD2) generate
    ir.pwd <= '0'; ir.addr <= (others => '0');
  end generate;
  
  wpgen : for i in 0 to 3 generate
    wpg0 : if nwp > i generate
      wpreg : process(clk) begin
        if rising_edge(clk) then
          if holdn = '1' then wpr(i) <= wprin(i); end if;
          if rstn = '0' then 
	    wpr(i).exec <= '0'; wpr(i).load <= '0'; wpr(i).store <= '0';
	  end if;
        end if;
      end process;
    end generate;
    wpg1 : if nwp <= i generate
      wpr(i) <= wpr_none;
    end generate;
  end generate;

-- pragma translate_off
  dis1 : if disas = 1 generate
    trc : process(clk)
      variable valid : boolean;
      variable op : std_logic_vector(1 downto 0);
      variable op3 : std_logic_vector(5 downto 0);
      variable fpins, fpld : boolean;    
    begin
    if (disas = 1) and rising_edge(clk) and (rstn = '1') then
      if (fpu /= 0) then
        op := r.x.ctrl.inst(31 downto 30); op3 := r.x.ctrl.inst(24 downto 19);
        fpins := (op = FMT3) and ((op3 = FPOP1) or (op3 = FPOP2));
        fpld := (op = LDST) and ((op3 = LDF) or (op3 = LDDF) or (op3 = LDFSR));
      else
        fpins := false; fpld := false;
      end if;
      valid := (((not r.x.ctrl.annul) and r.x.ctrl.pv) = '1') and 
	(not ((fpins or fpld) and (r.x.ctrl.trap = '0')));
      valid := valid and (holdn = '1');
      if rising_edge(clk) and (rstn = '1') then
        print_insn (index, r.x.ctrl.pc(31 downto 2) & "00", r.x.ctrl.inst, 
                  rin.w.result, valid, r.x.ctrl.trap = '1', rin.w.wreg = '1', false);
      end if;
    end if;
    end process;
  end generate;
-- pragma translate_on

  dis0 : if disas < 2 generate dummy <= '1'; end generate;

  dis2 : if disas > 1 generate
      disasen <= '1' when disas /= 0 else '0';
      cpu_index <= conv_std_logic_vector(index, 4);
      x0 : cpu_disasx
      port map (clk, rstn, dummy, r.x.ctrl.inst, r.x.ctrl.pc(31 downto 2),
	rin.w.result, cpu_index, rin.w.wreg, r.x.ctrl.annul, holdn,
	r.x.ctrl.pv, r.x.ctrl.trap, disasen);
  end generate;
end;
