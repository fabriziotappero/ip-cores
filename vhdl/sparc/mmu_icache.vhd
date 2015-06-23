



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 2003  Gaisler Research
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------   
-- Entity:      icache
-- File:        icache.vhd
-- Author:      Jiri Gaisler - Gaisler Research, Konrad Eisele <eiselekd@web.de>
-- Description: This unit implements the instruction cache controller.
------------------------------------------------------------------------------  

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned.conv_integer;
use IEEE.std_logic_arith.conv_unsigned;
use work.leon_config.all;
use work.sparcv8.all;		-- ASI declarations
use work.leon_iface.all;
use work.macro.all;		-- xorv()
use work.amba.all;
use work.leon_target.all;
use work.mmuconfig.all;

entity mmu_icache is
  port (
    rst : in  std_logic;
    clk : in  clk_type;
    ici : in  icache_in_type;
    ico : out icache_out_type;
    dci : in  dcache_in_type;
    dco : in  dcache_out_type;
    mcii : out memory_ic_in_type;
    mcio : in  memory_ic_out_type;
    icrami : out icram_in_type;
    icramo : in  icram_out_type;
    fpuholdn : in  std_logic;
    mmudci : in  mmudc_in_type;
    mmuici : out mmuic_in_type;
    mmuico : in mmuic_out_type
);
end; 

architecture rtl of mmu_icache is

constant TAG_HIGH   : integer := ITAG_HIGH;
constant TAG_LOW    : integer := IOFFSET_BITS + ILINE_BITS + 2;
constant OFFSET_HIGH: integer := TAG_LOW - 1;
constant OFFSET_LOW : integer := ILINE_BITS + 2;
constant LINE_HIGH  : integer := OFFSET_LOW - 1;
constant LINE_LOW   : integer := 2;
constant LRR_BIT    : integer := TAG_HIGH + 1;

constant lline : std_logic_vector((ILINE_BITS -1) downto 0) := (others=>'1');

constant SETBITS : integer := log2x(ISETS); 
subtype lru_type is std_logic_vector(ILRUBITS-1 downto 0);
type lru_array  is array (0 to 2**IOFFSET_BITS-1) of lru_type;  -- lru registers
type rdatatype is (itag, idata, memory);	-- sources during cache read

type lru_table_vector_type is array(0 to 3) of std_logic_vector(4 downto 0);
type lru_table_type is array (0 to 2**IOFFSET_BITS-1) of lru_table_vector_type;

subtype lock_type is std_logic_vector(0 to ISETS-1);
type par_type is array (0 to ISETS-1) of std_logic_vector(1 downto 0);

function lru_set (lru : lru_type; lock : lock_type) return std_logic_vector is
variable xlru : std_logic_vector(4 downto 0);
variable set  : std_logic_vector(SETBITS-1 downto 0);
variable xset : std_logic_vector(1 downto 0);
variable unlocked : integer range 0 to ISETS-1;
begin

  set := (others => '0'); xlru := (others => '0'); xset := (others => '0');
  xlru(ILRUBITS-1 downto 0) := lru;
  
  if ICLOCK_BIT = 1 then 
    unlocked := ISETS-1;
    for i in ISETS-1 downto 0 loop
      if lock(i) = '0' then unlocked := i; end if;
    end loop;
  end if;
    
  case ISETS is
  when 2 =>
    if ICLOCK_BIT = 1 then
      if lock(0) = '1' then xset(0) := '1'; else xset(0) := xlru(0); end if;
    else xset(0) := xlru(0); end if;
  when 3 =>
    if ICLOCK_BIT = 1 then
      xset := std_logic_vector(conv_unsigned(lru3_repl_table(conv_integer(xlru)) (unlocked), 2));
    else
      xset := std_logic_vector(conv_unsigned(lru3_repl_table(conv_integer(xlru)) (0), 2));
    end if;
  when 4 =>
    if ICLOCK_BIT = 1 then
      xset := std_logic_vector(conv_unsigned(lru4_repl_table(conv_integer(xlru)) (unlocked), 2));
    else
      xset := std_logic_vector(conv_unsigned(lru4_repl_table(conv_integer(xlru)) (0), 2));
    end if;
  when others => 
  end case;
  set := xset(SETBITS-1 downto 0);
  return(set);
end;

function lru_calc (lru : lru_type; set : integer) return lru_type is
variable new_lru : lru_type;
variable xnew_lru: std_logic_vector(4 downto 0);
variable xlru : std_logic_vector(4 downto 0);
begin
  new_lru := (others => '0'); xnew_lru := (others => '0');
  xlru := (others => '0'); xlru(ILRUBITS-1 downto 0) := lru;
  case ISETS is
  when 2 => 
    if set = 0 then xnew_lru(0) := '1'; else xnew_lru(0) := '0'; end if;
  when 3 =>
    xnew_lru(2 downto 0) := lru_3set_table(conv_integer(lru))(set); 
  when 4 => 
    xnew_lru(4 downto 0) := lru_4set_table(conv_integer(lru))(set);
  when others => 
  end case;
  new_lru := xnew_lru(ILRUBITS-1 downto 0);
  return(new_lru);
end;

type istatetype is (idle, trans, streaming, stop);
type icache_control_type is record			-- all registers
  req, burst, holdn : std_logic;
  overrun       : std_logic;			-- 
  underrun      : std_logic;			-- 
  istate 	: istatetype;	  	        -- FSM
  waddress      : std_logic_vector(31 downto PCLOW); -- write address buffer
  vaddress      : std_logic_vector(31 downto PCLOW); -- virtual address buffer
  valid         : std_logic_vector(ILINE_SIZE-1 downto 0); -- valid bits
  hit           : std_logic;
  su 		: std_logic;
  flush		: std_logic;				-- flush in progress
  flush2	: std_logic;				-- flush in progress
  faddr 	: std_logic_vector(IOFFSET_BITS - 1 downto 0);	-- flush address
  diagrdy  	: std_logic;
  rndcnt        : std_logic_vector(log2x(ISETS)-1 downto 0); -- replace counter
  lrr           : std_logic;
  setrepl       : std_logic_vector(log2x(ISETS)-1 downto 0); -- set to replace
  diagset       : std_logic_vector(log2x(ISETS)-1 downto 0);
  lock          : std_logic;

  pflush        : std_logic;
  pflushr       : std_logic;
  pflushaddr    : std_logic_vector(VA_I_U downto VA_I_D);
  pflushtyp     : std_logic;
  cache         : std_logic;
  trans_op      : std_logic;
end record;

type lru_reg_type is record
  write : std_logic;
  waddr : std_logic_vector(IOFFSET_BITS-1 downto 0);
  set   : std_logic_vector(SETBITS-1 downto 0); --integer range 0 to ISETS-1;
  lru   : lru_array;
end record;

signal r, c : icache_control_type;	-- r is registers, c is combinational
signal rl, cl : lru_reg_type;           -- rl is registers, cl is combinational


begin

  ictrl : process(rst, r, rl, mcio, ici, dci, dco, icramo, fpuholdn, mmuico, mmudci)
  variable rdatasel : rdatatype;
  variable twrite, diagen, dwrite : std_logic;
  variable taddr : std_logic_vector(TAG_HIGH  downto LINE_LOW); -- tag address
  variable wtag : std_logic_vector(TAG_HIGH downto TAG_LOW); -- write tag value
  variable ddatain : std_logic_vector(31 downto 0);
  variable rdata : std_logic_vector(31 downto 0);
  variable diagdata : std_logic_vector(31 downto 0);
  variable vmaskraw, vmask : std_logic_vector((ILINE_SIZE -1) downto 0);
  variable xaddr_inc : std_logic_vector((ILINE_BITS -1) downto 0);
  variable lastline, nlastline, nnlastline : std_logic;
  variable enable : std_logic;
  variable error : std_logic;
  variable whit, hit, valid : std_logic;
  variable cacheon  : std_logic;
  variable v : icache_control_type;
  variable branch  : std_logic;
  variable eholdn  : std_logic;
  variable mds, write  : std_logic;
  variable tparerr, dparerr  : std_logic_vector(0 to ISETS-1);
  variable memaddr : std_logic_vector(31 downto PCLOW);
  variable set     : integer range 0 to MAXSETS-1;
  variable setrepl : std_logic_vector(log2x(ISETS)-1 downto 0); -- set to replace
  variable ctwrite, cdwrite, validv : std_logic_vector(0 to MAXSETS-1);
  variable wlrr : std_logic;
  variable vl : lru_reg_type;
  variable vdiagset, rdiagset : integer range 0 to ISETS-1;
  variable lock : std_logic_vector(0 to ISETS-1);
  variable wlock : std_logic;

  variable pftag : std_logic_vector(31 downto 2);
  variable mmuici_trans_op : std_logic;
  variable mmuici_su : std_logic;
  begin

-- init local variables

    v := r; vl := rl; vl.write := '0'; vl.set := r.setrepl;
    vl.waddr := r.waddress(OFFSET_HIGH downto OFFSET_LOW);

    mds := '1'; dwrite := '0'; twrite := '0'; diagen := '0'; error := '0';
    write := mcio.ready; v.diagrdy := '0'; v.holdn := '1'; 

    cacheon := mcio.ics(0) and not r.flush;
    enable := '1'; branch := '0';
    eholdn := dco.hold and fpuholdn;

    rdatasel := idata;	-- read data from cache as default
    ddatain := mcio.data;	-- load full word from memory
    --if M_EN and (mmudci.mmctrl1.e = '1') then wtag := r.vaddress(TAG_HIGH downto TAG_LOW);
    --else wtag := r.waddress(TAG_HIGH downto TAG_LOW); end if;
    wtag := r.vaddress(TAG_HIGH downto TAG_LOW);
    wlrr := r.lrr; wlock := r.lock;
    
    tparerr := (others => '0'); dparerr := (others => '0');

    set := 0; ctwrite := (others => '0'); cdwrite := (others => '0');
    vdiagset := 0; rdiagset := 0; lock := (others => '0');
    pftag := (others => '0');

    v.trans_op := r.trans_op and (not mmuico.grant);
    mmuici_trans_op := r.trans_op;
    
    
    mmuici_su := ici.su;
              
-- random replacement counter
    if ISETS > 1 then
-- pragma translate_off
      if not is_x(r.rndcnt) then
-- pragma translate_on
        if conv_integer(r.rndcnt) = (ISETS - 1) then v.rndcnt := (others => '0');
        else v.rndcnt := r.rndcnt + 1; end if;
-- pragma translate_off
      end if;
-- pragma translate_on
    end if;


-- generate lock bits
    if ICLOCK_BIT = 1 then 
      for i in 0 to ISETS-1 loop lock(i) := icramo.itramout(i).lock; end loop;
    end if;
      
-- generate cache hit and valid bits    
    hit := '0';
    for i in ISETS-1 downto 0 loop
      if (icramo.itramout(i).tag = ici.fpc(TAG_HIGH downto TAG_LOW)) and (tparerr(i) = '0') and
        ((icramo.itramout(i).ctx = mmudci.mmctrl1.ctx or (mmudci.mmctrl1.e = '0')) or (not M_EN))
      then hit := not r.flush; set := i; end if;
      validv(i) := genmux(ici.fpc(LINE_HIGH downto LINE_LOW), 
		          icramo.itramout(i).valid);
    end loop;

    -- cache hit disabled if mmu-enabled but off
    --if (M_EN) and ((mmudci.mmctrl1.e = '0')) then
    --  hit := '0';
    --end if;

    if ici.fpc(LINE_HIGH downto LINE_LOW) = lline then lastline := '1';
    else lastline := '0'; end if;

    if r.waddress(LINE_HIGH downto LINE_LOW) = lline((ILINE_BITS -1) downto 0) then
      nlastline := '1';
    else nlastline := '0'; end if;

    if r.waddress(LINE_HIGH downto LINE_LOW+1) = lline((ILINE_BITS -1) downto 1) then
      nnlastline := '1';
    else nnlastline := '0'; end if;

-- pragma translate_off
    if not is_x(ici.fpc(LINE_HIGH downto LINE_LOW)) then
-- pragma translate_on
      valid := validv(set);
-- pragma translate_off
    end if;
-- pragma translate_on

-- pragma translate_off
    if not is_x(r.waddress) then
-- pragma translate_on
      xaddr_inc := r.waddress(LINE_HIGH downto LINE_LOW) + 1;
-- pragma translate_off
    end if;
-- pragma translate_on

    if mcio.ready = '1' then 
      v.waddress(LINE_HIGH downto LINE_LOW) := xaddr_inc;
    end if;


-- pragma translate_off
    if not is_x(r.vaddress) then
-- pragma translate_on
      xaddr_inc := r.vaddress(LINE_HIGH downto LINE_LOW) + 1;
-- pragma translate_off
    end if;
-- pragma translate_on

    if mcio.ready = '1' then 
      v.vaddress(LINE_HIGH downto LINE_LOW) := xaddr_inc;
    end if;

    
    taddr := ici.rpc(TAG_HIGH downto LINE_LOW);

-- main Icache state machine

    case r.istate is
    when idle =>	-- main state and cache hit
      v.valid := icramo.itramout(set).valid;
      v.hit := hit; v.su := ici.su;

      if (ici.nullify or eholdn)  = '0' then 
        taddr := ici.fpc(TAG_HIGH downto LINE_LOW);
      else taddr := ici.rpc(TAG_HIGH downto LINE_LOW); end if;
      v.burst := mcio.burst and not lastline;
      if (eholdn and not ici.nullify ) = '1' then
	if not ((cacheon and hit and valid) and not dparerr(set)) = '1' then  
	  v.istate := streaming;  
          v.holdn := '0'; v.overrun := '1';
          
          if M_EN and ((mmudci.mmctrl1.e) = '1') then 
            v.istate := trans; 
            mmuici_trans_op := '1';
            v.trans_op := not mmuico.grant;
            v.cache := '0';
            --v.req := '0';
          else                          
            v.req := '1'; 
            v.cache := '1';
          end if;
          
	else
          if (ISETS > 1) and (ICREPLACE = lru) then vl.write := '1'; end if;
        end if;
        v.waddress := ici.fpc(31 downto PCLOW);
        v.vaddress := ici.fpc(31 downto PCLOW);
            
      end if;
      if dco.icdiag.enable = '1' then
	diagen := '1';
      end if;
      ddatain := dci.maddress;
      if (ISETS > 1) then
        if (ICREPLACE = lru) then
	  vl.set := std_logic_vector(conv_unsigned(set, SETBITS)); 
	  vl.waddr := ici.fpc(OFFSET_HIGH downto OFFSET_LOW);
	end if;
        v.setrepl := std_logic_vector(conv_unsigned(set, SETBITS));
 	if (((not hit) and (not dparerr(set)) and (not r.flush)) = '1') then
          case ICREPLACE is
	  when rnd =>
            if ICLOCK_BIT = 1 then 
              if lock(conv_integer(r.rndcnt)) = '0' then v.setrepl := r.rndcnt;
              else
                v.setrepl := std_logic_vector(conv_unsigned(ISETS-1, SETBITS));
                for i in ISETS-1 downto 0 loop
                  if (lock(i) = '0') and (i>conv_integer(r.rndcnt)) then
                    v.setrepl := std_logic_vector(conv_unsigned(i, SETBITS));
                  end if;
                end loop;
              end if;
            else
              v.setrepl := r.rndcnt;
            end if;
          when lru =>
-- pragma translate_off
            if not is_x(ici.fpc) then
-- pragma translate_on
              v.setrepl :=  lru_set(rl.lru(conv_integer(ici.fpc(OFFSET_HIGH downto OFFSET_LOW))), lock(0 to ISETS-1));
-- pragma translate_off
            end if;
-- pragma translate_on
          when lrr =>
            v.setrepl := (others => '0');
            if ICLOCK_BIT = 1 then
              if lock(0) = '1' then v.setrepl(0) := '1';
              else
                v.setrepl(0) := icramo.itramout(0).lrr xor icramo.itramout(1).lrr;
              end if;
            else
              v.setrepl(0) := icramo.itramout(0).lrr xor icramo.itramout(1).lrr;
            end if;
            if v.setrepl(0) = '0' then v.lrr := not icramo.itramout(0).lrr;
            else v.lrr := icramo.itramout(0).lrr; end if;
          end case;  
        end if;  
        if (ICLOCK_BIT = 1) then
          if (hit and (not dparerr(set)) and lock(set)) = '1' then v.lock := '1';
          else v.lock := '0'; end if;
        end if;
      end if;
    when trans =>

      if M_EN then
        v.holdn := '0';
        
        if (mmuico.transdata.finish = '1') then
          if (mmuico.transdata.accexc) = '1' and ((mmudci.mmctrl1.nf) /= '1' or (r.su) = '1') then 
            -- if su then always do mexc
            error := '1'; mds := '0';
            v.holdn := '1'; v.istate := idle; v.burst := '0';
          else
            v.cache := mmuico.transdata.cache;
            v.waddress := mmuico.transdata.data(31 downto PCLOW);
            --v.vaddress := r.waddress;
            v.istate := streaming; v.req := '1'; 
          end if;
        end if;
      end if;
      
    when streaming =>		-- streaming: update cache and send data to IU
      rdatasel := memory;
      --taddr(TAG_HIGH downto LINE_LOW) := r.waddress(TAG_HIGH downto LINE_LOW);
      
      taddr(TAG_HIGH downto LINE_LOW) := r.vaddress(TAG_HIGH downto LINE_LOW);
      branch := (ici.fbranch and r.overrun) or
		      (ici.rbranch and (not r.overrun));
      v.underrun := r.underrun or 
        (write and ((ici.nullify or not eholdn) and (mcio.ready and not (r.overrun and not r.underrun))));
      v.overrun := (r.overrun or (eholdn and not ici.nullify)) and 
		    not (write or r.underrun);
      if mcio.ready = '1' then
--        mds := not (v.overrun and not r.underrun);
        mds := not (r.overrun and not r.underrun);
--        v.req := r.burst; 
        v.burst := v.req and not nnlastline;
      end if;
      if mcio.grant = '1' then 
        v.req := mcio.burst and r.burst and 
	         (not (nnlastline and mcio.ready)) and (mcio.burst or (not branch)) and
		 not (v.underrun and not cacheon);
        v.burst := v.req and not nnlastline;
      end if;
      v.underrun := (v.underrun or branch) and not v.overrun;
      v.holdn := not (v.overrun or v.underrun);
      if (mcio.ready = '1') and (r.req = '0') then --(v.burst = '0') then
        v.underrun := '0'; v.overrun := '0';
        if (mcio.ics(0) and not r.flush2) = '1' then
	  v.istate := stop; v.holdn := '0';
	else
          v.istate := idle; v.flush := r.flush2; v.holdn := '1';
	  if r.overrun = '1' then taddr := ici.fpc(TAG_HIGH downto LINE_LOW);
	  else taddr := ici.rpc(TAG_HIGH downto LINE_LOW); end if;
	end if;
      end if;
    when stop => 		-- return to main
      taddr := ici.fpc(TAG_HIGH downto LINE_LOW);
      v.istate := idle; v.flush := r.flush2;
    when others => v.istate := idle;
    end case;

    if mcio.retry = '1' then v.req := '1'; end if;

-- Generate new valid bits write strobe

    vmaskraw := decode(r.waddress(LINE_HIGH downto LINE_LOW));
    twrite := write;
    if cacheon = '0' then
      twrite := '0'; vmask := (others => '0');
    elsif (mcio.ics = "01") then
      twrite := twrite and r.hit;
      vmask := icramo.itramout(set).valid or vmaskraw;
    else
      if r.hit = '1' then vmask := r.valid or vmaskraw;
      else vmask := vmaskraw; end if;
    end if; 
    if (mcio.mexc or (not mcio.cache) or (not r.cache)) = '1' then 
      twrite := '0'; dwrite := '0';
    else dwrite := twrite; end if;
    if twrite = '1' then
      v.valid := vmask; v.hit := '1';
      if (ISETS > 1) and (ICREPLACE = lru) then vl.write := '1'; end if;
    end if;

    if (ISETS > 1) and (ICREPLACE = lru) and (rl.write = '1') then
      vl.lru(conv_integer(rl.waddr)) :=
	  lru_calc(rl.lru(conv_integer(rl.waddr)), conv_integer(rl.set));
    end if;

-- cache write signals
    
    if ISETS > 1 then setrepl := r.setrepl; else setrepl := (others => '0'); end if;
-- pragma translate_off
    if not is_x(setrepl) then
-- pragma translate_on
      if twrite = '1' then ctwrite(conv_integer(setrepl)) := '1'; end if;
      if dwrite = '1' then cdwrite(conv_integer(setrepl)) := '1'; end if;
-- pragma translate_off
    end if;
-- pragma translate_on
    
-- diagnostic cache access

    if diagen = '1' then
     if (ISETS /= 1) then 
       v.diagset := dco.icdiag.addr(SETBITS -1 + TAG_LOW downto TAG_LOW);
     end if;
   end if;
     
    if (ISETS /= 1) then 
-- pragma translate_off
      if not is_x(r.diagset) then
-- pragma translate_on
        rdiagset := conv_integer(r.diagset);
-- pragma translate_off
      end if;
-- pragma translate_on
-- pragma translate_off
      if not is_x(v.diagset) then
-- pragma translate_on
        vdiagset := conv_integer(v.diagset);
-- pragma translate_off
      end if;
-- pragma translate_on
    end if;

    diagdata := icramo.idramout(rdiagset).data;
    if diagen = '1' then -- diagnostic access
      taddr(OFFSET_HIGH downto LINE_LOW) := dco.icdiag.addr(OFFSET_HIGH downto LINE_LOW);
      wtag(TAG_HIGH downto TAG_LOW) := dci.maddress(TAG_HIGH downto TAG_LOW);
      wlrr := dci.maddress(ICTAG_LRRPOS);
      wlock := dci.maddress(ICTAG_LOCKPOS);
      if dco.icdiag.tag = '1' then
	twrite := not dco.icdiag.read; dwrite := '0';
        ctwrite := (others => '0'); cdwrite := (others => '0');
	ctwrite(vdiagset) := not dco.icdiag.read;
        diagdata := (others => '0');
        diagdata(TAG_HIGH downto TAG_LOW) := icramo.itramout(rdiagset).tag(ITAG_BITS - ILINE_SIZE - 1 downto 0);
        diagdata(ILINE_SIZE -1 downto 0) := icramo.itramout(rdiagset).valid;
        diagdata(ICTAG_LRRPOS) := icramo.itramout(rdiagset).lrr;
        diagdata(ICTAG_LOCKPOS) := icramo.itramout(rdiagset).lock;
      else
        if dco.icdiag.ctx = '1' then
          twrite := '0'; dwrite := '0';
          ctwrite := (others => '0'); cdwrite := (others => '0');
          diagdata := (others => '0');
          diagdata(M_CTX_SZ-1 downto 0) := icramo.itramout(rdiagset).ctx;
	else
          dwrite := not dco.icdiag.read; twrite := '0';
          cdwrite := (others => '0'); cdwrite(vdiagset) := not dco.icdiag.read;
          ctwrite := (others => '0');
        end if;
      end if;
      vmask := dci.maddress(ILINE_SIZE -1 downto 0);
      v.diagrdy := '1';
    end if;

-- select data to return on read access

    case rdatasel is
    when memory => rdata := mcio.data;
    when others => rdata := icramo.idramout(set).data;
    end case;

-- cache flush

    if (ici.flush or dco.icdiag.flush) = '1' then
      v.flush := '1'; v.flush2 := '1'; v.faddr := (others => '0');
      v.pflush := dco.icdiag.pflush; wtag := (others => '0');
      v.pflushr := '1';
      v.pflushaddr := dco.icdiag.pflushaddr;
      v.pflushtyp := dco.icdiag.pflushtyp;
    end if;

    if r.flush2 = '1' then
      twrite := '1'; ctwrite := (others => '1'); vmask := (others => '0'); v.faddr := r.faddr +1; 
      taddr(OFFSET_HIGH downto OFFSET_LOW) := r.faddr; wlrr := '0'; wlock := '0';
      if (r.faddr(IOFFSET_BITS -1) and not v.faddr(IOFFSET_BITS -1)) = '1' then
	v.flush2 := '0';
      end if;
      
      -- precise flush, ASI_FLUSH_PAGE & ASI_FLUSH_CTX
      if M_EN then
        if r.pflush = '1' then
          twrite := '0'; ctwrite := (others => '0');
          v.pflushr := not r.pflushr;
          if r.pflushr = '0' then
            for i in ISETS-1 downto 0 loop
              pftag(OFFSET_HIGH downto OFFSET_LOW) := r.faddr;
              pftag(TAG_HIGH downto TAG_LOW) := icramo.itramout(i).tag;
              if (icramo.itramout(i).ctx = mmudci.mmctrl1.ctx) and
                 ((pftag(VA_I_U downto VA_I_D) = r.pflushaddr(VA_I_U downto VA_I_D)) or
                  (r.pflushtyp = '1')) then
                ctwrite(i) := '1';
              end if;
            end loop;
          end if;
        end if;
      end if;
    end if;

-- reset

    if rst = '0' then 
      v.istate := idle; v.req := '0'; v.burst := '0'; v.holdn := '1';
      v.flush := '0'; v.flush2 := '0'; v.overrun := '0'; v.underrun := '0';
      v.rndcnt := (others => '0'); v.lrr := '0'; v.setrepl := (others => '0');
      v.diagset := (others => '0'); v.lock := '0';
    end if;

    if (not rst or r.flush) = '1' then  
      vl.lru := (others => (others => '0'));
    end if;
    
-- Drive signals

    c  <= v;	   -- register inputs
    cl <= vl;  -- lru register inputs

    -- tag ram inputs
    icrami.itramin.valid    <= vmask;
    icrami.itramin.tag      <= wtag(TAG_HIGH downto TAG_LOW);
    icrami.itramin.lrr      <= wlrr;
    icrami.itramin.lock     <= wlock;
    icrami.itramin.enable   <= enable;
    icrami.itramin.write    <= ctwrite;
    icrami.itramin.flush    <= r.flush2;
    icrami.itramin.ctx      <= mmudci.mmctrl1.ctx;

    -- data ram inputs
    icrami.idramin.enable   <= enable;
    icrami.idramin.address  <= taddr(OFFSET_HIGH downto LINE_LOW);
    icrami.idramin.data     <= ddatain;
    icrami.idramin.write    <= cdwrite; 
    
    -- memory controller inputs
    mcii.address(31 downto 2)  <= r.waddress(31 downto 2);
    mcii.address(1 downto 0)  <= "00";
    mcii.su       <= r.su;
    mcii.burst    <= r.burst;
    mcii.req      <= r.req;
    mcii.flush    <= r.flush;

    -- mmu <-> icache
    mmuici.trans_op <= mmuici_trans_op;
    mmuici.transdata.data <= r.waddress(31 downto 2) & "00";
    mmuici.transdata.su   <= r.su;
    mmuici.transdata.isid <= id_icache;
    mmuici.transdata.read <= '1';
    
  
    -- IU data cache inputs
    ico.data      <= rdata;
    ico.exception <= mcio.mexc or error;
    ico.hold      <= r.holdn;
    ico.mds       <= mds;
    ico.flush     <= r.flush;
    ico.diagdata  <= diagdata;
    ico.diagrdy   <= r.diagrdy;

  end process;

-- Local registers


  regs1 : process(clk)
  begin if rising_edge(clk) then r <= c; end if; end process;

  regs2gen : if (ISETS > 1) and (ICREPLACE = lru) generate
    regs2 : process(clk)
    begin if rising_edge(clk) then rl <= cl; end if; end process;
  end generate;


-- pragma translate_off
  chk : process
  begin
    assert not ((ISETS > 2) and (ICREPLACE = lrr)) report
	"Wrong instruction cache configuration detected: LRR replacement requires 2 sets"
    severity failure;
    wait;
  end process;
-- pragma translate_on
      
end ;

