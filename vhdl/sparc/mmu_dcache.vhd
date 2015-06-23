-- todo: - disable cache if mmu is disabled



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
-- Entity:      dcache
-- File:        dcache.vhd
-- Author:      Jiri Gaisler - Gaisler Research, Konrad Eisele <eiselekd@web.de>
-- Description: This unit implements the data cache controller.
------------------------------------------------------------------------------  

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned.conv_integer;
use IEEE.std_logic_arith.conv_unsigned;
use work.amba.all;
use work.leon_target.all;
use work.leon_config.all;
use work.sparcv8.all;		-- ASI declarations
use work.leon_iface.all;
use work.macro.all;		-- xorv()
use work.mmuconfig.all;		

entity mmu_dcache is
  port (
    rst : in  std_logic;
    clk : in  clk_type;
    dci : in  dcache_in_type;
    dco : out dcache_out_type;
    ico : in  icache_out_type;
    mcdi : out memory_dc_in_type;
    mcdo : in  memory_dc_out_type;
    ahbsi : in  ahb_slv_in_type;
    dcrami : out dcram_in_type;
    dcramo : in  dcram_out_type;
    fpuholdn : in  std_logic;
    mmudci : out mmudc_in_type;
    mmudco : in mmudc_out_type
);
end; 

architecture rtl of mmu_dcache is

constant TAG_HIGH   : integer := DTAG_HIGH;
constant TAG_LOW    : integer := DOFFSET_BITS + DLINE_BITS + 2;
constant OFFSET_HIGH: integer := TAG_LOW - 1;
constant OFFSET_LOW : integer := DLINE_BITS + 2;
constant LINE_HIGH  : integer := OFFSET_LOW - 1;
constant LINE_LOW   : integer := 2;
constant LINE_ZERO  : std_logic_vector(DLINE_BITS-1 downto 0) := (others => '0');
constant SETBITS : integer := log2x(DSETS); 

type rdatatype is (dtag, ddata, dddata, dctx, icache, memory, misc);  -- sources during cache read
type vmasktype is (clearone, clearall, merge, tnew);	-- valid bits operation

type write_buffer_type is record			-- write buffer 
  addr, data1, data2 : std_logic_vector(31 downto 0);
  size : std_logic_vector(1 downto 0);
  asi  : std_logic_vector(3 downto 0);
  read : std_logic;
  lock : std_logic;
end record;

type dstatetype is (idle, wread, rtrans, wwrite, wtrans, wflush, 
                    asi_idtag,dblwrite, loadpend);
type dcache_control_type is record			-- all registers
  read : std_logic;					-- access direction
  signed : std_logic;					-- signed/unsigned read
  size : std_logic_vector(1 downto 0);			-- access size
  req, burst, holdn, nomds, stpend  : std_logic;
  xaddress : std_logic_vector(31 downto 0);		-- common address buffer
  paddress : std_logic_vector(31 downto 0);		-- physical address buffer
  faddr : std_logic_vector(DOFFSET_BITS - 1 downto 0);	-- flush address
  valid : std_logic_vector(DLINE_SIZE - 1 downto 0);	-- registered valid bits
  dstate : dstatetype; 			                -- FSM
  hit : std_logic;
  flush		: std_logic;				-- flush in progress
  mexc 		: std_logic;				-- latched mexc
  wb 		: write_buffer_type;			-- write buffer
  asi  		: std_logic_vector(4 downto 0);
  icenable	: std_logic;				-- icache diag access
  rndcnt        : std_logic_vector(log2x(DSETS)-1 downto 0); -- replace counter
  setrepl       : std_logic_vector(log2x(DSETS)-1 downto 0); -- set to replace
  lrr           : std_logic;            
  dsuset        : std_logic_vector(log2x(DSETS)-1 downto 0);
  lock          : std_logic;

  mmctrl1       : mmctrl_type1;
  pflush        : std_logic;
  pflushr       : std_logic;
  pflushaddr    : std_logic_vector(VA_I_U downto VA_I_D);
  pflushtyp     : std_logic;
  vaddr         : std_logic_vector(31 downto 0);
  ready         : std_logic;
  wbinit        : std_logic;
  cache         : std_logic;
  su            : std_logic;
  dblwdata      : std_logic;

  trans_op      : std_logic;
  flush_op      : std_logic;
  diag_op       : std_logic;
end record;

type snoop_reg_type is record			-- snoop control registers
  snoop   : std_logic;				-- snoop access to tags
  writebp : std_logic_vector(0 to DSETS-1);		-- snoop write bypass
  addr 	  : std_logic_vector(TAG_HIGH downto OFFSET_LOW);-- snoop tag
end record;

type snoop_hit_bits_type is array (0 to 2**DOFFSET_BITS-1) of std_logic_vector(0 to DSETS-1);

type snoop_hit_reg_type is record
  hit 	  : snoop_hit_bits_type;                              -- snoop hit bits  
  taddr	  : std_logic_vector(OFFSET_HIGH downto OFFSET_LOW);  -- saved tag address
  set     : std_logic_vector(log2x(DSETS)-1 downto 0);        -- saved set
end record;


subtype lru_type is std_logic_vector(DLRUBITS-1 downto 0);
type lru_array  is array (0 to 2**DOFFSET_BITS-1) of lru_type;  -- lru registers
type par_type is array (0 to DSETS-1) of std_logic_vector(1 downto 0);

type lru_reg_type is record
  write : std_logic;
  waddr : std_logic_vector(DOFFSET_BITS-1 downto 0);
  set   :  std_logic_vector(SETBITS-1 downto 0); --integer range 0 to DSETS-1;
  lru   : lru_array;
end record;


subtype lock_type is std_logic_vector(0 to DSETS-1);

function lru_set (lru : lru_type; lock : lock_type) return std_logic_vector is
variable xlru : std_logic_vector(4 downto 0);
variable set  : std_logic_vector(SETBITS-1 downto 0);
variable xset : std_logic_vector(1 downto 0);
variable unlocked : integer range 0 to DSETS-1;
begin
  set := (others => '0'); xlru := (others => '0');
  xlru(DLRUBITS-1 downto 0) := lru;

  if DCLOCK_BIT = 1 then 
    unlocked := DSETS-1;
    for i in DSETS-1 downto 0 loop
      if lock(i) = '0' then unlocked := i; end if;
    end loop;
  end if;

  case DSETS is
  when 2 =>
    if DCLOCK_BIT = 1 then
      if lock(0) = '1' then xset(0) := '1'; else xset(0) := xlru(0); end if;
    else xset(0) := xlru(0); end if;
  when 3 => 
    if DCLOCK_BIT = 1 then
      xset := std_logic_vector(conv_unsigned(lru3_repl_table(conv_integer(xlru)) (unlocked), 2));
    else
      xset := std_logic_vector(conv_unsigned(lru3_repl_table(conv_integer(xlru)) (0), 2));
    end if;
  when 4 =>
    if DCLOCK_BIT = 1 then
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
  xlru := (others => '0'); xlru(DLRUBITS-1 downto 0) := lru;
  case DSETS is
  when 2 => 
    if set = 0 then xnew_lru(0) := '1'; else xnew_lru(0) := '0'; end if;
  when 3 =>
    xnew_lru(2 downto 0) := lru_3set_table(conv_integer(lru))(set); 
  when 4 => 
    xnew_lru(4 downto 0) := lru_4set_table(conv_integer(lru))(set);
  when others => 
  end case;
  new_lru := xnew_lru(DLRUBITS-1 downto 0);
  return(new_lru);
end;

subtype word is std_logic_vector(31 downto 0);

signal r, c : dcache_control_type;	-- r is registers, c is combinational
signal rs, cs : snoop_reg_type;		-- rs is registers, cs is combinational
signal rh, ch : snoop_hit_reg_type;	-- rs is registers, cs is combinational
signal rl, cl : lru_reg_type;           -- rl is registers, cl is combinational


begin

  dctrl : process(rst, r, rs, rh, rl, dci, mcdo, ico, dcramo, ahbsi, fpuholdn, mmudco)
  type ddtype is array (0 to DSETS-1) of word;
  variable dcramov : dcram_out_type;
  variable rdatasel : rdatatype;
  variable maddress : std_logic_vector(31 downto 0);
  variable maddrlow : std_logic_vector(1 downto 0);
  variable edata : std_logic_vector(31 downto 0);
  variable size : std_logic_vector(1 downto 0);
  variable read : std_logic;
  variable twrite, tdiagwrite, ddiagwrite, dwrite : std_logic;
  variable taddr : std_logic_vector(OFFSET_HIGH  downto LINE_LOW); -- tag address
  variable newtag : std_logic_vector(TAG_HIGH  downto TAG_LOW); -- new tag
  variable align_data : std_logic_vector(31 downto 0); -- aligned data
  variable ddatain : std_logic_vector(31 downto 0);
  variable ddatainv, rdatav, align_datav : ddtype;
  variable rdata, mmudata : std_logic_vector(31 downto 0);

  variable vmaskraw, vmask : std_logic_vector((DLINE_SIZE -1) downto 0);
  variable ivalid : std_logic_vector((DLINE_SIZE -1) downto 0);
  variable vmaskdbl : std_logic_vector((DLINE_SIZE/2 -1) downto 0);
  variable enable : std_logic;
  variable mds : std_logic;
  variable mexc : std_logic;
  variable hit, valid, validraw, forcemiss : std_logic;
  variable signed   : std_logic;
  variable flush    : std_logic;
  variable iflush   : std_logic;
  variable v : dcache_control_type;
  variable eholdn : std_logic;				-- external hold
  variable tparerr, dparerr  : std_logic_vector(0 to DSETS-1);
  variable snoopwe : std_logic;
  variable hcache   : std_logic;
  variable snoopaddr: std_logic_vector(OFFSET_HIGH downto OFFSET_LOW);
  variable vs : snoop_reg_type;
  variable vh : snoop_hit_reg_type;
  variable dsudata   : std_logic_vector(31 downto 0);
  variable set : integer range 0 to DSETS-1;
  variable ddset : integer range 0 to MAXSETS-1;
  variable snoopset : integer range 0 to DSETS-1;
  variable validv, hitv, validrawv : std_logic_vector(0 to MAXSETS-1);
  variable csnoopwe : std_logic_vector(0 to MAXSETS-1);
  variable ctwrite, cdwrite : std_logic_vector(0 to MAXSETS-1);
  variable vset, setrepl  : std_logic_vector(log2x(DSETS)-1 downto 0);
  variable wlrr : std_logic_vector(0 to MAXSETS-1);
  variable vl : lru_reg_type;
  variable diagset : std_logic_vector(TAG_LOW + SETBITS -1 downto TAG_LOW);
  variable lock : std_logic_vector(0 to DSETS-1);
  variable wlock : std_logic_vector(0 to MAXSETS-1);
  variable snoopset2, rdsuset : integer range 0 to DSETS-1;
  variable snoophit : std_logic_vector(0 to DSETS-1);
  variable snoopval : std_logic;

  variable miscdata  : std_logic_vector(31 downto 0);
  variable mmudiagaddr  : std_logic_vector(2 downto 0);
  variable pflush : std_logic;
  variable pflushaddr : std_logic_vector(VA_I_U downto VA_I_D);
  variable pflushtyp : std_logic;
  variable pftag : std_logic_vector(31 downto 2);
  variable mmuwdata : std_logic_vector(31 downto 0);

  variable mmudci_fsread, tagclear : std_logic;
  variable mmudci_trans_op : std_logic;
  variable mmudci_flush_op : std_logic;
  variable mmudci_diag_op : std_logic;
  variable mmudci_su : std_logic;
  variable mmudci_read : std_logic;
  variable mmuregw, su : std_logic;
  variable mmuisdis : std_logic;
  begin

-- init local variables

    v := r; vs := rs; vh := rh; dcramov := dcramo; vl := rl;
    vl.write := '0'; tagclear := '0'; mmuisdis := '0';
    if (not M_EN) or ((r.asi(4 downto 0) = ASI_MMU_BP) or (r.mmctrl1.e = '0')) then
      mmuisdis := '1';
    end if;

    
    mds := '1'; dwrite := '0'; twrite := '0'; 
    ddiagwrite := '0'; tdiagwrite := '0'; v.holdn := '1'; mexc := '0';
    flush := '0'; v.icenable := '0'; iflush := '0';
    eholdn := ico.hold and fpuholdn; ddset := 0; vset := (others => '0');
    tparerr  := (others => '0'); dparerr  := (others => '0'); 
    vs.snoop := '0'; vs.writebp := (others => '0'); snoopwe := '0';
    snoopaddr := ahbsi.haddr(OFFSET_HIGH downto OFFSET_LOW);
    hcache := '0'; rdsuset := 0; enable := '1';
    validv := (others => '0'); validrawv := (others => '0');
    hitv := (others => '0'); ivalid := (others => '0');
    miscdata := (others => '0'); pflush := '0';
    pflushaddr := dci.maddress(VA_I_U downto VA_I_D); pflushtyp := PFLUSH_PAGE;
    pftag := (others => '0'); mmudata := (others => '0'); 
    mmudiagaddr := (others => '0'); mmuregw := '0'; mmuwdata := (others => '0');
    mmudci_fsread := '0';
    
    v.trans_op := r.trans_op and (not mmudco.grant);
    v.flush_op := r.flush_op and (not mmudco.grant);
    v.diag_op := r.diag_op and (not mmudco.grant);
    mmudci_trans_op := r.trans_op;
    mmudci_flush_op := r.flush_op;
    mmudci_diag_op := r.diag_op;
    
    mmudci_su := '0'; mmudci_read := '0'; su := '0';
    if (not M_EN) or (r.mmctrl1.e = '0') then v.cache := '1'; end if;
    
    rdatasel := ddata;	-- read data from cache as default

    set := 0; snoopset := 0;  csnoopwe := (others => '0');
    ctwrite := (others => '0'); cdwrite := (others => '0');
    wlock := (others => '0');
    for i in 0 to DSETS-1 loop wlock(i) := dcramov.dtramout(i).lock; end loop; 
    wlrr := (others => '0');
    for i in 0 to 1 loop wlrr(i) := dcramov.dtramout(i).lrr; end loop; 
    
    if (DSETS > 1) then setrepl := r.setrepl; else setrepl := (others => '0'); end if;
    
-- random replacement counter
    if DSETS > 1 then
-- pragma translate_off
      if not is_x(r.rndcnt) then
-- pragma translate_on
        if conv_integer(r.rndcnt) = (DSETS - 1) then v.rndcnt := (others => '0');
        else v.rndcnt := r.rndcnt + 1; end if;
-- pragma translate_off
      end if;
-- pragma translate_on
    end if;

-- generate lock bits
    lock := (others => '0');
    if DCLOCK_BIT = 1 then 
      for i in 0 to DSETS-1 loop lock(i) := dcramov.dtramout(i).lock; end loop;
    end if;
    
-- AHB snoop handling

    if DSNOOP then
      hcache := is_cacheable(ahbsi.haddr(31 downto 24));
      -- snoop on NONSEQ or SEQ and first word in cache line
      -- do not snoop during own transfers or during cache flush
      if (ahbsi.hready and ahbsi.hwrite and not mcdo.bg) = '1' and
         ((ahbsi.htrans = HTRANS_NONSEQ) or 
	    ((ahbsi.htrans = HTRANS_SEQ) and 
	     (ahbsi.haddr(LINE_HIGH downto LINE_LOW) = LINE_ZERO))) 
      then
	vs.snoop := mcdo.dsnoop and hcache;
        vs.addr := ahbsi.haddr(TAG_HIGH downto OFFSET_LOW); 
      end if;
      -- clear valid bits on snoop hit (or set hit bits)
      for i in DSETS-1 downto 0 loop
        if ((rs.snoop and (not mcdo.ba) and not r.flush) = '1') 
          and (dcramov.dtramoutsn(i).tag = rs.addr(TAG_HIGH downto TAG_LOW))
        then
          if DSNOOP_FAST then
-- pragma translate_off
            if not is_x(rs.addr(OFFSET_HIGH downto OFFSET_LOW)) then
-- pragma translate_on
            vh.hit(conv_integer(rs.addr(OFFSET_HIGH downto OFFSET_LOW)))(i) := '1';
--             vh.set := std_logic_vector(conv_unsigned(i, SETBITS));
-- pragma translate_off
            end if;
-- pragma translate_on
          else
            snoopaddr := rs.addr(OFFSET_HIGH downto OFFSET_LOW);
            snoopwe := '1'; snoopset := i;        
          end if;
        end if;
      -- bypass tag data on read/write contention
        if (not DSNOOP_FAST) and (rs.writebp(i) = '1') then 
          dcramov.dtramout(i).tag   := rs.addr(TAG_HIGH downto TAG_LOW);
          dcramov.dtramout(i).valid := (others => '0');
        end if;
      end loop;
    end if;

-- generate access parameters during pipeline stall

    if ((r.holdn) = '0') or (DEBUG_UNIT and (dci.dsuen = '1')) then
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW);
      --if r.dsuwren = '0' then v.dsuwren := '1'; end if;
    elsif ((dci.enaddr and not dci.read) = '1') or (eholdn = '0')
    then
      taddr := dci.maddress(OFFSET_HIGH downto LINE_LOW);
    else
      taddr := dci.eaddress(OFFSET_HIGH downto LINE_LOW);
    end if;

    if (dci.write or not r.holdn) = '1' then
      maddress := r.xaddress(31 downto 0); signed := r.signed; 
      read := r.read; size := r.size; edata := dci.maddress;
      mmudci_su := r.su; mmudci_read := r.read;
    else
      maddress := dci.maddress(31 downto 0); signed := dci.signed; 
      read := dci.read; size := dci.size; edata := dci.edata;
      mmudci_su := dci.msu; mmudci_read := dci.read;
    end if;

    newtag := dci.maddress(TAG_HIGH downto TAG_LOW);
    vl.waddr := maddress(OFFSET_HIGH downto OFFSET_LOW);  -- lru write address

-- generate cache hit and valid bits

    forcemiss := not dci.asi(3); hit := '0'; set := 0; 
    snoophit := (others => '0'); snoopval := '1';
    for i in DSETS-1 downto 0 loop
      if DSNOOP and DSNOOP_FAST then
-- pragma translate_off
        if not is_x(rh.taddr) then
-- pragma translate_on        
          snoophit(i) := rh.hit(conv_integer(rh.taddr))(i);
-- pragma translate_off
        end if;
-- pragma translate_on
      end if;
      if (dcramov.dtramout(i).tag = dci.maddress(TAG_HIGH downto TAG_LOW)) and (tparerr(i) = '0') and
        (((dcramov.dtramout(i).ctx = r.mmctrl1.ctx) or (r.mmctrl1.e = '0')) or (not M_EN))  
      then hitv(i) := '1'; end if; -- not r.flush; set := i; end if;
      validrawv(i) := hitv(i) and (not r.flush) and (not snoophit(i)) and
	genmux(dci.maddress(LINE_HIGH downto LINE_LOW), dcramov.dtramout(i).valid);
      validv(i) :=  validrawv(i) and not dparerr(i);
      if (hitv(i) and not snoophit(i)) = '1' then ivalid := ivalid or dcramov.dtramout(i).valid; end if;
      snoopval := snoopval and not snoophit(i);
    end loop;
              
    hit := orv(hitv) and not r.flush;

    -- cache hit disabled if mmu-enabled but off or BYPASS
    if (M_EN) and (dci.asi(4 downto 0) = ASI_MMU_BP) then  -- or (r.mmctrl1.e = '0')
      hit := '0';
    end if;
    
    validraw := orv(validrawv);
    valid := orv(validv);
    if DSETS > 1 then 
      for i in DSETS-1 downto 0 loop 
        if hitv(i) = '1' then
	  vset := vset or std_logic_vector(conv_unsigned(i, SETBITS));
        end if;
      end loop;
      set := conv_integer(vset);
    else set := 0; end if;

    if (dci.dsuen and (not r.holdn)) = '1' then diagset := r.xaddress(TAG_LOW+SETBITS-1 downto TAG_LOW);
    else diagset := maddress(TAG_LOW + SETBITS - 1 downto TAG_LOW); end if;
-- pragma translate_off
    if not is_x(diagset) then
-- pragma translate_on
      case DSETS is
      when 1 => ddset := 0;
      when 3 => if conv_integer(diagset) < 3 then ddset := conv_integer(diagset); end if;
      when others => ddset := conv_integer(diagset); 
      end case;
-- pragma translate_off
    end if;
--pragma translate_on

    
    if ((r.holdn and dci.enaddr) = '1')  and (r.dstate = idle) then
        v.hit := hit; v.xaddress := dci.maddress;
	v.read := dci.read; v.size := dci.size;
	v.asi := dci.asi(4 downto 0);  
	v.signed := dci.signed; v.su := dci.msu;
    end if;

-- Store buffer

--    wdata := r.wb.data1;
    if mcdo.ready = '1' then
      v.wb.addr(2) := r.wb.addr(2) or (r.wb.size(0) and r.wb.size(1));
      if r.stpend = '1' then
        v.stpend := r.req; v.wb.data1 := r.wb.data2; 
	v.wb.lock := r.wb.lock and r.req;
      end if;
    end if;
    if mcdo.grant = '1' then v.req := r.burst; v.burst := '0'; end if;

-- main Dcache state machine

    case r.dstate is
    when idle =>			-- Idle state
      if (snoopval = '1') then v.valid := dcramov.dtramout(set).valid;
      else v.valid := (others => '0'); end if;
      v.nomds := r.nomds and not eholdn; v.valid := dcramov.dtramout(set).valid;
      if (r.stpend  = '0') or ((mcdo.ready and not r.req)= '1') then -- wait for store queue
	v.wb.addr := dci.maddress; v.wb.size := dci.size; 
	v.wb.read := dci.read; v.wb.data1 := dci.edata; v.wb.lock := dci.lock;
	v.wb.asi := dci.asi(3 downto 0); 
      end if;
      if (eholdn and (not r.nomds)) = '1' then -- avoid false path through nullify
	if dci.asi(4 downto 0) = ASI_DTAG then rdatasel := dtag; end if;
	if dci.asi(4 downto 0) = ASI_DDATA then rdatasel := dddata; end if;
	if dci.asi(4 downto 0) = ASI_DCTX then rdatasel := dctx; end if;
      end if;
      if (dci.enaddr and eholdn and (not r.nomds) and not dci.nullify) = '1' then
	case dci.asi(4 downto 0) is
	when ASI_ITAG | ASI_IDATA | ASI_ICTX =>		-- Read/write Icache tags
          -- CTX write has to be done through ctxnr & ASI_ITAG
	  if (ico.flush = '1') or (dci.asi(4) = '1') then mexc := '1';
 	 else v.dstate := asi_idtag; v.holdn := '0'; end if;
 	when ASI_IFLUSH =>		-- flush instruction cache
	  if dci.read = '0' then iflush := '1'; end if;
 	when ASI_DFLUSH =>		-- flush data cache
	  if dci.read = '0' then flush := '1'; end if;
 	when ASI_DDATA =>		-- Read/write Dcache data
 	  if (dci.size /= "10") or (r.flush = '1') then -- only word access is allowed
 	    mexc := '1';
 	  elsif (dci.read = '0') then
 	    dwrite := '1'; ddiagwrite := '1';
 	  end if;
 	when ASI_DTAG =>		-- Read/write Dcache tags
 	  if (dci.size /= "10") or (r.flush = '1') then -- allow only word access
 	    mexc := '1';
 	  elsif (dci.read = '0') then
 	    twrite := '1'; tdiagwrite := '1';
 	  end if;
        when ASI_DCTX =>
          -- write has to be done through ctxnr & ASI_DTAG
          if (dci.size /= "10") or (r.flush = '1') or (dci.read = '0') then -- allow only word access
 	    mexc := '1';
 	  end if;
        when ASI_FLUSH_PAGE => -- i/dcache flush page
          if M_EN then
            if dci.read = '0' then
              flush := '1'; iflush := '1'; pflush := '1'; pflushtyp := PFLUSH_PAGE;
            end if;
 	  end if;
        when ASI_FLUSH_CTX => -- i/dcache flush ctx
          if M_EN then
            if dci.read = '0' then
              flush := '1'; iflush := '1'; pflush := '1'; pflushtyp := PFLUSH_CTX;
            end if;
          end if;
        when ASI_MMUFLUSHPROBE =>
          if M_EN then
            if dci.read = '0' then      -- flush
              mmudci_flush_op := '1';
              v.flush_op := not mmudco.grant;
              v.dstate := wflush;
              v.vaddr := dci.maddress; v.holdn := '0'; flush := '1'; iflush := '1';
            end if;
          end if;
        when ASI_MMU_DIAG =>
          -- ASI_MMU_DIAG is not needed,
          if M_EN and M_EN_DIAG then
            if dci.read = '0' then      -- diag access
              mmudci_diag_op := '1';
              v.diag_op := not mmudco.grant;
              v.vaddr := dci.maddress;
            end if;
          end if;  
        when ASI_MMU_DSU =>
        when ASI_MMUREGS =>
          if M_EN then
            rdatasel := misc; mmuregw := not dci.read;
            -- clean fault valid bit
            if dci.read = '1' then
              case dci.maddress(CNR_U downto CNR_D) is
                when CNR_F =>
                  mmudci_fsread := '1';
                when others => null;
              end case;
            end if;
          end if;
	when others =>
--          setrepl := std_logic_vector(conv_unsigned(set, SETBITS));
	  if dci.read = '1' then	-- read access
	    if (not ((mcdo.dcs(0) = '1') 
	       and ((hit and valid and not forcemiss) = '1')))

	    then	-- read miss
	      v.holdn := '0'; v.dstate := wread; v.ready := '0'; v.cache := '1';
              if (not M_EN) or
                ((dci.asi(4 downto 0) = ASI_MMU_BP) or (r.mmctrl1.e = '0'))
              then
                -- cache disabled if mmu-enabled but off or BYPASS
                if (M_EN) then v.cache := '0'; end if;
                
                if ((r.stpend  = '0') or ((mcdo.ready and not r.req) = '1'))
                then	-- wait for store queue
                  
                  v.req := '1';
                  v.burst := dci.size(1) and dci.size(0) and not dci.maddress(2);
                end if;
              else
                -- ## mmu case >
                if (r.stpend  = '0') or ((mcdo.ready and not r.req)= '1')
                then
                  v.wbinit := '1';     -- wb init in idle
                  v.burst := dci.size(1) and dci.size(0) and not dci.maddress(2);
                else
                  v.wbinit := '0';
                end if;
                
                mmudci_trans_op := '1';  -- start translation
                v.trans_op := not mmudco.grant;
                v.vaddr := dci.maddress; 
                v.dstate := rtrans;
                -- ## < mmu case 
              end if;
              
            else       -- read hit
              if (DSETS > 1) and (DCREPLACE = lru) then vl.write := '1'; end if;
            end if;
            
	  else			-- write access
            v.ready := '0';
            if (not M_EN) or
              ((dci.asi(4 downto 0) = ASI_MMU_BP) or (r.mmctrl1.e = '0')) then
                            
              if (r.stpend  = '0') or ((mcdo.ready and not r.req)= '1') then

                v.req := '1'; v.stpend := '1'; 
                v.burst := dci.size(1) and dci.size(0);

                if (dci.size = "11") then v.dstate := dblwrite; end if; -- double store	      
              else		-- wait for store queue
                v.dstate := wwrite; v.holdn := '0';
              end if;
            else
              -- ## mmu case >
              if (r.stpend  = '0') or ((mcdo.ready and not r.req)= '1')
              then
                v.wbinit := '1';     -- wb init in idle
                v.burst := dci.size(1) and dci.size(0);              
              else
                v.wbinit := '0';
              end if;  
              mmudci_trans_op := '1';  -- start translation
              v.trans_op := not mmudco.grant; 
              v.vaddr := dci.maddress; v.holdn := '0';
              v.dstate := wtrans;
              v.dblwdata := dci.size(0) or dci.size(1);  -- "11"
              -- ## < mmu case 
            end if;

            -- note: cache hit disabled if BYPASS
            if (mcdo.dcs(0) = '1') and ((hit and (dci.size(1) or validraw)) = '1') 
            then  -- write hit
              
              twrite := '1'; dwrite := '1';
              if (DSETS > 1) and (DCREPLACE = lru) then vl.write := '1'; end if;
              setrepl := std_logic_vector(conv_unsigned(set, SETBITS));
            end if;

	    if (dci.size = "11") then v.xaddress(2) := '1'; end if;
	  end if;

          if (DSETS > 1) then
    	    vl.set := std_logic_vector(conv_unsigned(set, SETBITS));
            v.setrepl := std_logic_vector(conv_unsigned(set, SETBITS));
            if ((not hit) and (not dparerr(set)) and (not r.flush)) = '1' then
              case DCREPLACE is
              when rnd =>
                if DCLOCK_BIT = 1 then 
                  if lock(conv_integer(r.rndcnt)) = '0' then v.setrepl := r.rndcnt;
                  else
                    v.setrepl := std_logic_vector(conv_unsigned(DSETS-1, SETBITS));
                    for i in DSETS-1 downto 0 loop
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
      		if not is_x(dci.maddress(OFFSET_HIGH downto OFFSET_LOW)) then
-- pragma translate_on        
                  v.setrepl := lru_set(rl.lru(conv_integer(dci.maddress(OFFSET_HIGH downto OFFSET_LOW))), lock(0 to DSETS-1));
-- pragma translate_off
      		end if;
-- pragma translate_on        
              when lrr =>
                v.setrepl := (others => '0');
                if DCLOCK_BIT = 1 then 
                  if lock(0) = '1' then v.setrepl(0) := '1';
                  else
                    v.setrepl(0) := dcramov.dtramout(0).lrr xor dcramov.dtramout(1).lrr;
                  end if;
                else
                  v.setrepl(0) := dcramov.dtramout(0).lrr xor dcramov.dtramout(1).lrr;
                end if;
                if v.setrepl(0) = '0' then
                  v.lrr := not dcramov.dtramout(0).lrr;
                else
                  v.lrr := dcramov.dtramout(0).lrr;
                end if;
              end case;
            end if;

            if (DCLOCK_BIT = 1) then
              if (hit and (not dparerr(set)) and lock(set)) = '1' then v.lock := '1';
              else v.lock := '0'; end if;
            end if;
              
          end if;

        end case;
      end if;
    when rtrans =>
      if M_EN then
        if r.stpend = '1' then
          if ((mcdo.ready and not r.req) = '1') then	
            v.ready := '1';       -- buffer store finish
          end if;
        end if;
        
        v.holdn := '0';
        if mmudco.transdata.finish = '1' then
          -- translation error, i.e. page fault
          if (mmudco.transdata.accexc) = '1' then
            v.holdn := '1'; v.dstate := idle;
            mds := '0'; mexc := not r.mmctrl1.nf;
          else
            v.dstate := wread;
            v.cache := r.cache and mmudco.transdata.cache;
            --v.xaddress := mmudco.data;
            v.paddress := mmudco.transdata.data;
            if v.wbinit = '1' then
              v.wb.addr := mmudco.transdata.data;
              v.req := '1';
            end if;
          end if;
        else
          --mmudci_trans_op := '1';  -- start translation
        end if;
      end if;

    when wread => 		-- read miss, wait for memory data
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW);
      newtag := r.xaddress(TAG_HIGH downto TAG_LOW);
      v.nomds := r.nomds and not eholdn;
      v.holdn := v.nomds; rdatasel := memory;
      for i in 0 to DSETS-1 loop wlock(i) := r.lock; end loop;
      for i in 0 to 1 loop wlrr(i) := r.lrr; end loop;
      if (r.stpend = '0') and (r.ready = '0') then

        if mcdo.ready = '1' then
          mds := r.holdn or r.nomds; v.xaddress(2) := '1'; v.holdn := '1';
          if (mcdo.dcs = "01") then 
	    v.hit := mcdo.cache and r.hit and r.cache; twrite := v.hit;
          elsif (mcdo.dcs(1) = '1') then 
	    v.hit := mcdo.cache and (r.hit or not r.asi(2)) and r.cache; twrite := v.hit;
	  end if; 
          dwrite := twrite; rdatasel := memory;
          mexc := mcdo.mexc;

	  if r.req = '0' then

	    if (((dci.enaddr and not mds) = '1') or 
              ((dci.eenaddr and mds and eholdn) = '1')) and (mcdo.dcs(0) = '1') then
	      v.dstate := loadpend; v.holdn := '0';
	    else v.dstate := idle; end if;
	  else v.nomds := '1'; end if;
        end if;
	v.mexc := mcdo.mexc; v.wb.data2 := mcdo.data;
      else
	if (r.ready or (mcdo.ready and not r.req)) = '1' then	-- wait for store queue
	  v.burst := r.size(1) and r.size(0) and not r.xaddress(2);
          if (mmuisdis = '1') then
            v.wb.addr := r.xaddress;
          else
            v.wb.addr := r.paddress;
          end if;

          v.wb.size := r.size; 
	  v.wb.read := r.read; v.wb.data1 := dci.maddress; v.req := '1'; 
	  v.wb.lock := dci.lock; v.wb.asi := r.asi(3 downto 0); v.ready := '0';
        end if;
      end if;
    when loadpend =>		-- return from read miss with load pending
      taddr := dci.maddress(OFFSET_HIGH downto LINE_LOW);
      v.dstate := idle; 
    when dblwrite => 		-- second part of double store cycle
      v.dstate := idle; v.wb.data2 := dci.edata; 
      edata := dci.edata;  -- needed for STD store hit
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); 
      if (mcdo.dcs(0) = '1') and (r.hit = '1') then dwrite := '1'; end if;

    when asi_idtag =>		-- icache diag access
      rdatasel := icache; v.icenable := '1'; v.holdn := '0';
      if  ico.diagrdy = '1' then
	v.dstate := loadpend; v.icenable := '0'; mds := not r.read;
      end if;
      
    when wtrans =>
      edata := dci.edata;  -- needed for STD store hit
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); 
          
      if M_EN then
        if r.stpend = '1' then
          if ((mcdo.ready and not r.req) = '1') then	
            v.ready := '1';       -- buffer store finish
          end if;
        end if;

        -- fetch dblwrite data 2, does the same as state dblwrite,
        -- except that init of data2 is omitted to end of translation or in wwrite
        if ((r.dblwdata) = '1') and ((r.size) = "11") then  
          v.dblwdata := '0';
          --if (mcdo.dcs(0) = '1') and (r.hit = '1') then dwrite := '1'; end if;
        end if;
        
        v.holdn := '0';
        if mmudco.transdata.finish = '1' then        
          if (mmudco.transdata.accexc) = '1' then
            v.holdn := '1'; v.dstate := idle;
            mds := '0'; mexc := not r.mmctrl1.nf;
            
            tagclear := mcdo.dcs(0) and r.hit;
            twrite := tagclear;
            
	    if (twrite = '1') and (((dci.enaddr and not mds) = '1') or 
              ((dci.eenaddr and mds and eholdn) = '1')) and (mcdo.dcs(0) = '1') then
	      v.dstate := loadpend; v.holdn := '0';
	    end if;
            
          else
            v.dstate := wwrite;
            v.cache := mmudco.transdata.cache;
            --v.xaddress := mmudco.data;
            v.paddress := mmudco.transdata.data;
            
            if (r.wbinit) = '1' then
              v.wb.data2 := dci.edata; 
              v.wb.addr := mmudco.transdata.data;
              v.dstate := idle;  v.holdn := '1'; 
              v.req := '1'; v.stpend := '1';
              v.burst := r.size(1) and r.size(0) and not v.wb.addr(2);

              if (mcdo.dcs(0) = '1') and (r.hit = '1') and (r.size = "11")  then  -- write hit
                dwrite := '1';
              end if;
            end if;
          end if;
        else
          -- mmudci_trans_op := '1';  -- start translation
        end if;

      end if;
        
    when wwrite => 		-- wait for store buffer to empty (store access)
      edata := dci.edata;  -- needed for STD store hit

      if (v.ready or (mcdo.ready and not r.req)) = '1' then	-- store queue emptied

        --if (mmuisdis = '1') then
          if (mcdo.dcs(0) = '1') and (r.hit = '1') and (r.size = "11")  then  -- write hit
            taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); dwrite := '1';
          end if;
        --end if;
        v.dstate := idle; 

	v.req := '1'; v.burst := r.size(1) and r.size(0); v.stpend := '1';

        if (mmuisdis = '1') then
          v.wb.addr := r.xaddress;
        else
          v.wb.addr := r.paddress;
        end if;
        
	--v.wb.addr := r.xaddress;
        v.wb.size := r.size;
	v.wb.read := r.read; v.wb.data1 := dci.maddress;
	v.wb.lock := dci.lock; v.wb.data2 := dci.edata;
	v.wb.asi := r.asi(3 downto 0); 
	if r.size = "11" then v.wb.addr(2) := '0'; end if;
      else  -- hold cpu until buffer empty
        v.holdn := '0';
      end if;
      
    when wflush => 
      v.holdn := '0';
      if mmudco.transdata.finish = '1' then        
        v.dstate := idle; v.holdn := '1';
      end if;
      
    when others => v.dstate := idle;
    end case;

    if M_EN then
      if DEBUG_UNIT and dci.dsuen = '1' then 
	mmudiagaddr := r.xaddress(4 downto 2); 
	mmuregw := dci.write and not dci.eenaddr; mmuwdata := dci.maddress;
      else 
	mmudiagaddr := dci.maddress(CNR_U downto CNR_D); mmuwdata := dci.edata;
      end if;
      case mmudiagaddr is
      when CNR_CTRL => 
        mmudata(MMCTRL_E) := r.mmctrl1.e; 
        mmudata(MMCTRL_NF) := r.mmctrl1.nf; 
        mmudata(MMCTRL_PSO) := r.mmctrl1.pso;
        mmudata(MMCTRL_VER_U downto MMCTRL_VER_D) := "0000";
        mmudata(MMCTRL_IMPL_U downto MMCTRL_IMPL_D) := "0000";
        mmudata(23 downto 21) := std_logic_vector(conv_unsigned(M_ENT_ILOG,3));
        mmudata(20 downto 18) := std_logic_vector(conv_unsigned(M_ENT_DLOG,3));
	if M_TLB_TYPE = splittlb then mmudata(17) := '1'; else
          mmudata(23 downto 21) := std_logic_vector(conv_unsigned(M_ENT_CLOG,3));
          mmudata(20 downto 18) := (others => '0');
	end if;
        mmudata(MMCTRL_TLBDIS) := r.mmctrl1.tlbdis;
        --custom 
      when CNR_CTXP =>
        mmudata(MMCTXP_U downto MMCTXP_D) := r.mmctrl1.ctxp; 
      when CNR_CTX => 
        mmudata(MMCTXNR_U downto MMCTXNR_D) := r.mmctrl1.ctx; 
      when CNR_F =>
        mmudata(FS_OW) := mmudco.mmctrl2.fs.ow;
        mmudata(FS_FAV) := mmudco.mmctrl2.fs.fav;
        mmudata(FS_FT_U downto FS_FT_D) := mmudco.mmctrl2.fs.ft;
        mmudata(FS_AT_LS) := mmudco.mmctrl2.fs.at_ls;
        mmudata(FS_AT_ID) := mmudco.mmctrl2.fs.at_id;
        mmudata(FS_AT_SU) := mmudco.mmctrl2.fs.at_su;
        mmudata(FS_L_U downto FS_L_D) := mmudco.mmctrl2.fs.l;
        mmudata(FS_EBE_U downto FS_EBE_D) := mmudco.mmctrl2.fs.ebe;
      when CNR_FADDR => 
        mmudata(VA_I_U downto VA_I_D) := mmudco.mmctrl2.fa; 
      when others => null; 
      end case;
      if mmuregw = '1' then
        case mmudiagaddr is
        when CNR_CTRL =>
          v.mmctrl1.e      := mmuwdata(MMCTRL_E);
          v.mmctrl1.nf     := mmuwdata(MMCTRL_NF);
          v.mmctrl1.pso    := mmuwdata(MMCTRL_PSO);
          v.mmctrl1.tlbdis := mmuwdata(MMCTRL_TLBDIS);
          --custom 
          -- Note: before tlb disable tlb flush is required !!!  
        when CNR_CTXP =>
          v.mmctrl1.ctxp := mmuwdata(MMCTXP_U downto MMCTXP_D);
        when CNR_CTX =>
          v.mmctrl1.ctx  := mmuwdata(MMCTXNR_U downto MMCTXNR_D);
        when CNR_F => null;
        when CNR_FADDR => null;
        when others => null;
        end case;
      end if;
      miscdata := mmudata;
    end if;

    dsudata := (others => '0');
    if DEBUG_UNIT and dci.dsuen = '1' then
      if (DSETS > 1) then
-- pragma translate_off
        if not is_x(r.xaddress) then
-- pragma translate_on          
          v.dsuset := r.xaddress(TAG_LOW+SETBITS-1 downto TAG_LOW);
-- pragma translate_off          
        end if;
        if not is_x(r.dsuset) then
-- pragma translate_on          
        rdsuset := conv_integer(r.dsuset);
-- pragma translate_off          
        end if;
-- pragma translate_on          

      end if;
      case dci.asi(4 downto 0) is
      when ASI_ITAG | ASI_IDATA =>		-- Read/write Icache tags
	v.icenable := not ico.diagrdy;
        dsudata := ico.diagdata;
      when ASI_DTAG  => 
	if dci.write = '1' then 
	  twrite := not dci.eenaddr; tdiagwrite := '1';
        end if;
        dsudata(TAG_HIGH downto TAG_LOW) := dcramov.dtramout(rdsuset).tag;
        dsudata(DLINE_SIZE -1 downto 0)  := dcramov.dtramout(rdsuset).valid;
        dsudata(DCTAG_LRRPOS)  := dcramov.dtramout(rdsuset).lrr;
        dsudata(DCTAG_LOCKPOS) := dcramov.dtramout(rdsuset).lock;
      when ASI_DCTX =>
        dsudata(M_CTX_SZ-1 downto 0) := dcramov.dtramout(rdsuset).ctx;
      when ASI_DDATA =>
	--if (dci.write and r.dsuwren) = '1' then dwrite := '1'; ddiagwrite := '1'; end if;
        if dci.write = '1' then
          dwrite := not dci.eenaddr; ddiagwrite := '1';
        end if;
        dsudata := dcramov.ddramout(rdsuset).data;
--      when ASI_MMUREGS =>
      when ASI_MMU_DSU =>
   	if M_EN then dsudata := mmudata; end if;
      when others =>
      end case;
    end if;

-- select data to return on read access
-- align if byte/half word read from cache or memory.

    rdata := (others => '0'); rdatav := (others => (others => '0'));
    align_data := (others => '0'); align_datav := (others => (others => '0'));
    maddrlow := maddress(1 downto 0); -- stupid Synopsys VSS bug ...

    case rdatasel is
    when misc =>
      if M_EN then
        rdata := miscdata;
      end if;
    when dddata => 
      rdata := dcramov.ddramout(ddset).data;
    when dtag => 
      rdata(TAG_HIGH downto TAG_LOW) := dcramov.dtramout(ddset).tag;
      rdata(DLINE_SIZE -1 downto 0) := dcramov.dtramout(ddset).valid;
      rdata(DCTAG_LRRPOS)  := dcramov.dtramout(ddset).lrr;
      rdata(DCTAG_LOCKPOS) := dcramov.dtramout(ddset).lock;
    when dctx =>
      rdata(M_CTX_SZ-1 downto 0) := dcramov.dtramout(ddset).ctx;
    when icache => rdata := ico.diagdata;       
    when ddata | memory =>
      if DREAD_FAST then
        if rdatasel = memory then
        case size is
        when "00" => 			-- byte read
          case maddrlow is
	  when "00" => 
	    rdata(7 downto 0) := mcdo.data(31 downto 24);
	    if signed = '1' then rdata(31 downto 8) := (others => mcdo.data(31)); end if;
	  when "01" => 
	    rdata(7 downto 0) := mcdo.data(23 downto 16);
	    if signed = '1' then rdata(31 downto 8) := (others => mcdo.data(23)); end if;
	  when "10" => 
	    rdata(7 downto 0) := mcdo.data(15 downto 8);
	    if signed = '1' then rdata(31 downto 8) := (others => mcdo.data(15)); end if;
	  when others => 
	    rdata(7 downto 0) := mcdo.data(7 downto 0);
	    if signed = '1' then rdata(31 downto 8) := (others => mcdo.data(7)); end if;
          end case;
        when "01" => 			-- half-word read
          if maddress(1) = '1' then 
	    rdata(15 downto 0) := mcdo.data(15 downto 0);
	    if signed = '1' then rdata(31 downto 15) := (others => mcdo.data(15)); end if;
	  else
	    rdata(15 downto 0) := mcdo.data(31 downto 16);
	    if signed = '1' then rdata(31 downto 15) := (others => mcdo.data(31)); end if;
	  end if;
        when others => 			-- single and double word read
	  rdata := mcdo.data;
        end case;
        else
        rdata := (others => '0');
	for i in 0 to DSETS-1 loop
          case size is
          when "00" => 			-- byte read
            case maddrlow is
	    when "00" => 
	      rdatav(i)(7 downto 0) := dcramov.ddramout(i).data(31 downto 24);
	      if signed = '1' then rdatav(i)(31 downto 8) := (others => dcramov.ddramout(i).data(31)); end if;
	    when "01" => 
	      rdatav(i)(7 downto 0) := dcramov.ddramout(i).data(23 downto 16);
	      if signed = '1' then rdatav(i)(31 downto 8) := (others => dcramov.ddramout(i).data(23)); end if;
	    when "10" => 
	      rdatav(i)(7 downto 0) := dcramov.ddramout(i).data(15 downto 8);
	      if signed = '1' then rdatav(i)(31 downto 8) := (others => dcramov.ddramout(i).data(15)); end if;
	    when others => 
	      rdatav(i)(7 downto 0) := dcramov.ddramout(i).data(7 downto 0);
	      if signed = '1' then rdatav(i)(31 downto 8) := (others => dcramov.ddramout(i).data(7)); end if;
            end case;
          when "01" => 			-- half-word read
            if maddress(1) = '1' then 
	      rdatav(i)(15 downto 0) := dcramov.ddramout(i).data(15 downto 0);
	      if signed = '1' then rdatav(i)(31 downto 15) := (others => dcramov.ddramout(i).data(15)); end if;
	    else
	      rdatav(i)(15 downto 0) := dcramov.ddramout(i).data(31 downto 16);
	      if signed = '1' then rdatav(i)(31 downto 15) := (others => dcramov.ddramout(i).data(31)); end if;
	    end if;
          when others => 			-- single and double word read
	    rdatav(i) := dcramov.ddramout(i).data;
          end case;
          if validrawv(i) = '1' then rdata := rdata or rdatav(i); end if;
        end loop;
        end if;
      else
        if rdatasel = ddata then align_data := dcramov.ddramout(set).data;
        else align_data := mcdo.data; end if;
        case size is
        when "00" => 			-- byte read
          case maddrlow is
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
          if maddress(1) = '1' then 
	    rdata(15 downto 0) := align_data(15 downto 0);
	    if signed = '1' then rdata(31 downto 15) := (others => align_data(15)); end if;
	  else
	    rdata(15 downto 0) := align_data(31 downto 16);
	    if signed = '1' then rdata(31 downto 15) := (others => align_data(31)); end if;
	  end if;
        when others => 			-- single and double word read
	  rdata := align_data;
        end case;
      end if;
    end case;

-- select which data to update the data cache with

    if DWRITE_FAST then
      for i in 0 to DSETS-1 loop
        case size is		-- merge data during partial write
        when "00" =>
          case maddrlow is
          when "00" =>
	    ddatainv(i) := edata(7 downto 0) & dcramov.ddramout(i).data(23 downto 0);
          when "01" =>
	    ddatainv(i) := dcramov.ddramout(i).data(31 downto 24) & edata(7 downto 0) & 
		     dcramov.ddramout(i).data(15 downto 0);
          when "10" =>
	    ddatainv(i) := dcramov.ddramout(i).data(31 downto 16) & edata(7 downto 0) & 
		     dcramov.ddramout(i).data(7 downto 0);
          when others =>
	    ddatainv(i) := dcramov.ddramout(i).data(31 downto 8) & edata(7 downto 0); 
          end case;
        when "01" =>
          if maddress(1) = '0' then
            ddatainv(i) := edata(15 downto 0) & dcramov.ddramout(i).data(15 downto 0);
          else
            ddatainv(i) := dcramov.ddramout(i).data(31 downto 16) & edata(15 downto 0);
          end if;
        when others => 
          ddatainv(i) := edata;
        end case;

      end loop;
      ddatain := ddatainv(set);

    else
      case size is		-- merge data during partial write
      when "00" =>
        case maddrlow is
        when "00" =>
	  ddatain := edata(7 downto 0) & dcramov.ddramout(set).data(23 downto 0);
        when "01" =>
	  ddatain := dcramov.ddramout(set).data(31 downto 24) & edata(7 downto 0) & 
		     dcramov.ddramout(set).data(15 downto 0);
        when "10" =>
	  ddatain := dcramov.ddramout(set).data(31 downto 16) & edata(7 downto 0) & 
		     dcramov.ddramout(set).data(7 downto 0);
        when others =>
	  ddatain := dcramov.ddramout(set).data(31 downto 8) & edata(7 downto 0); 
        end case;
      when "01" =>
        if maddress(1) = '0' then
          ddatain := edata(15 downto 0) & dcramov.ddramout(set).data(15 downto 0);
        else
          ddatain := dcramov.ddramout(set).data(31 downto 16) & edata(15 downto 0);
        end if;
      when others => 
        ddatain := edata;
      end case;

    end if;

-- handle double load with pipeline hold

    if (r.dstate = idle) and (r.nomds = '1') then
      rdata := r.wb.data2; mexc := r.mexc;
    end if;

-- Handle AHB retry. Re-generate bus request and burst

    if mcdo.retry = '1' then
      v.req := '1';
      v.burst := r.wb.size(0) and r.wb.size(1) and not r.wb.addr(2);
    end if;

-- Generate new valid bits

    vmaskdbl := decode(maddress(LINE_HIGH downto LINE_LOW+1));
    if (size = "11") and (read = '0') then 
      for i in 0 to (DLINE_SIZE - 1) loop vmaskraw(i) := vmaskdbl(i/2); end loop;
    else
      vmaskraw := decode(maddress(LINE_HIGH downto LINE_LOW));
    end if;

    vmask := vmaskraw;
    if r.hit = '1' then vmask := r.valid or vmaskraw; end if;
    if r.dstate = idle then 
--      vmask := dcramov.dtramout(set).valid or vmaskraw;
      vmask := ivalid or vmaskraw;

    end if;

    if (mcdo.mexc or r.flush) = '1' then twrite := '0'; dwrite := '0'; end if;
    if twrite = '1' then
      if tagclear = '1' then vmask := (others => '0'); end if;
      v.valid := vmask;
      if (DSETS>1) and (DCREPLACE = lru) and (tdiagwrite = '0') then
        vl.write := '1'; vl.set := setrepl;
      end if;
    end if;

    if (DSETS>1) and (DCREPLACE = lru) and (rl.write = '1') then
      vl.lru(conv_integer(rl.waddr)) :=
        lru_calc(rl.lru(conv_integer(rl.waddr)), conv_integer(rl.set));
    end if;

    if tdiagwrite = '1' then -- diagnostic tag write
      if DEBUG_UNIT and (dci.dsuen = '1') then
        vmask := dci.maddress(DLINE_SIZE - 1 downto 0);
      else
        vmask := dci.edata(DLINE_SIZE - 1 downto 0);
        newtag(TAG_HIGH downto TAG_LOW) := dci.edata(TAG_HIGH downto TAG_LOW);
        for i in 0 to 1 loop wlrr(i)  := dci.edata(DCTAG_LRRPOS); end loop;
        for i in 0 to DSETS-1 loop wlock(i) := dci.edata(DCTAG_LOCKPOS); end loop;
      end if;
    end if;

-- cache flush

    if (dci.flush or flush or mcdo.dflush) = '1' then
      v.flush := '1'; v.faddr := (others => '0'); v.pflush := pflush;
      v.pflushr := '1';
      v.pflushaddr := pflushaddr;
      v.pflushtyp := pflushtyp;
    end if;
    
    if r.flush = '1' then      
      twrite := '1'; vmask := (others => '0'); v.faddr := r.faddr +1; 
      newtag(TAG_HIGH downto TAG_LOW) := (others => '0');
      taddr(OFFSET_HIGH downto OFFSET_LOW) := r.faddr;
      wlrr := (others => '0');
      if (r.faddr(DOFFSET_BITS -1) and not v.faddr(DOFFSET_BITS -1)) = '1' then
	v.flush := '0';
      end if;      
    end if;

-- AHB snoop handling (2), bypass write data on read/write contention

    if DSNOOP then
-- pragma translate_off
      if not is_x(setrepl) then
-- pragma translate_on
        if tdiagwrite = '1' then snoopset2 := ddset; 
	else snoopset2 := conv_integer(setrepl); end if;
-- pragma translate_off
      end if;
-- pragma translate_on
      if DSNOOP_FAST then
        vh.taddr := taddr(OFFSET_HIGH downto OFFSET_LOW);
        vh.set := std_logic_vector(conv_unsigned(set, SETBITS));
	if twrite = '1' then 
-- pragma translate_off
          if not is_x(taddr(OFFSET_HIGH downto OFFSET_LOW)) then
-- pragma translate_on
	    vh.hit(conv_integer(taddr(OFFSET_HIGH downto OFFSET_LOW)))(snoopset2) := '0';
-- pragma translate_off
          end if;
-- pragma translate_on
	end if;
      else
        if rs.addr(OFFSET_HIGH  downto OFFSET_LOW) = 
	  r.xaddress(OFFSET_HIGH  downto OFFSET_LOW) 
	then 
	  if twrite = '0' then 
            if snoopwe = '1' then vs.writebp(snoopset) := '1'; end if;
	  else
            if snoopwe = '1' then twrite := '0'; end if; -- avoid write/write contention
	  end if;
	end if;
      end if;
    end if;

-- update cache with memory data during read miss

    if read = '1' then ddatain := mcdo.data; end if;

-- cache write signals

    if twrite = '1' then
      if tdiagwrite = '1' then ctwrite(ddset) := '1';
      else ctwrite(conv_integer(setrepl)) := '1'; end if;
    end if;
    if dwrite = '1' then
      if ddiagwrite = '1' then cdwrite(ddset) := '1';
      else cdwrite(conv_integer(setrepl)) := '1'; end if;
    end if;
      
    csnoopwe := (others => '0'); if (snoopwe = '1') then csnoopwe(snoopset) := '1'; end if;

     if (r.flush and twrite) = '1' then   -- flush 
       ctwrite := (others => '1'); wlrr := (others => '0'); wlock := (others => '0');
       
       -- precise flush, ASI_FLUSH_PAGE & ASI_FLUSH_CTX
      if M_EN then
        if r.pflush = '1' then
          twrite := '0'; ctwrite := (others => '0');
          for i in DSETS-1 downto 0 loop
            wlrr(i) := dcramov.dtramout(i).lrr; 
            wlock(i) := dcramov.dtramout(i).lock;
          end loop;
          if r.pflushr = '0' then
            for i in DSETS-1 downto 0 loop
              pftag(OFFSET_HIGH downto OFFSET_LOW) := r.faddr;
              pftag(TAG_HIGH downto TAG_LOW) := dcramo.dtramout(i).tag;
              if (dcramo.dtramout(i).ctx = r.mmctrl1.ctx) and
                 ((pftag(VA_I_U downto VA_I_D) = r.pflushaddr(VA_I_U downto VA_I_D)) or
                  (r.pflushtyp = '1')) then
                ctwrite(i) := '1';
                wlrr(i) := '0';
                wlock(i) := '0';
              end if;
            end loop;
          else
            v.faddr := r.faddr;
          end if;
          v.pflushr := not r.pflushr;
        end if;
      end if;

     end if;

     if (r.flush or (not rst)) = '1' then
      vl.lru := (others => (others => '0'));
    end if;
    
    
-- reset

    if rst = '0' then 
      v.dstate := idle; v.stpend  := '0'; v.req := '0'; v.burst := '0';
      v.read := '0'; v.flush := '0'; v.nomds := '0';
      v.rndcnt := (others => '0'); v.setrepl := (others => '0');
      v.dsuset := (others => '0');
      v.lrr := '0'; v.lock := '0';
      if M_EN then
        v.mmctrl1.e := '0'; v.mmctrl1.nf := '0'; v.mmctrl1.ctx := (others => '0');
        v.mmctrl1.tlbdis := '0';
        v.trans_op := '0'; 
        v.flush_op := '0'; 
        v.diag_op := '0'; 
      end if;
    end if;


-- Drive signals

    c <= v; cs <= vs;	ch <= vh; -- register inputs
    cl <= vl;

    
    -- tag ram inputs
    dcrami.dtramin.valid    <= vmask;
    dcrami.dtramin.tag      <= newtag(TAG_HIGH downto TAG_LOW);
    dcrami.dtramin.lrr      <= wlrr;
    dcrami.dtramin.lock     <= wlock;
    dcrami.dtramin.enable   <= enable;
    dcrami.dtramin.write    <= ctwrite;
    dcrami.dtramin.flush    <= r.flush;
    dcrami.dtramin.ctx      <= r.mmctrl1.ctx;
    dcrami.dtraminsn.enable <= vs.snoop or rs.snoop;
    dcrami.dtraminsn.write  <= csnoopwe;
    dcrami.dtraminsn.address<= snoopaddr;
    dcrami.dtraminsn.tag    <= rs.addr(TAG_HIGH downto TAG_LOW);

    
    -- data ram inputs
    dcrami.ddramin.enable   <= enable;
    dcrami.ddramin.address  <= taddr;
    dcrami.ddramin.data     <= ddatain;
    dcrami.ddramin.write    <= cdwrite;

    -- memory controller inputs
    mcdi.address  <= r.wb.addr;
    mcdi.data     <= r.wb.data1;
    mcdi.burst    <= r.burst;
    mcdi.size     <= r.wb.size;
    mcdi.read     <= r.wb.read;
    mcdi.asi      <= r.wb.asi;
    mcdi.lock     <= r.wb.lock or dci.lock;
    mcdi.req      <= r.req;
    mcdi.flush    <= r.flush;

    -- diagnostic instruction cache access
    dco.icdiag.flush  <= iflush or mcdo.iflush;
    dco.icdiag.pflush <= pflush;
    dco.icdiag.pflushaddr <= pflushaddr;
    dco.icdiag.pflushtyp <= pflushtyp;
    dco.icdiag.read   <= read;
    dco.icdiag.tag    <= (not r.asi(0)) and (not r.asi(4));
    dco.icdiag.ctx    <= r.asi(4); --ASI_ICTX "10101"
    dco.icdiag.addr   <= r.xaddress;
    dco.icdiag.enable <= r.icenable;
    dco.dsudata       <= dsudata;	-- debug unit
--    dco.mmctrl1       <= r.mmctrl1;
    
    -- IU data cache inputs
    dco.data  <= rdata;
    dco.mexc  <= mexc;
    dco.hold  <= r.holdn;
    dco.mds   <= mds;
    dco.werr  <= mcdo.werr;
    
    -- MMU
    mmudci.trans_op <= mmudci_trans_op;    
    mmudci.transdata.data <= r.vaddr;
    mmudci.transdata.su <= mmudci_su;
    mmudci.transdata.read <= mmudci_read;
    mmudci.transdata.isid <= id_dcache;
    
    mmudci.flush_op <= mmudci_flush_op;
    mmudci.diag_op <= mmudci_diag_op;
    mmudci.fsread <= mmudci_fsread;
    mmudci.mmctrl1 <= r.mmctrl1;

  end process;

-- Local registers

    reg1 : process(clk)
    begin if rising_edge(clk ) then r <= c; end if; end process;
    sn2 : if DSNOOP generate
      reg2 : process(clk)
      begin if rising_edge(clk ) then rs <= cs; end if; end process;
    end generate;
    sn3 : if DSNOOP_FAST generate
      reg3 : process(clk)
      begin if rising_edge(clk ) then rh <= ch; end if; end process;
    end generate;

    reg2 : if (DSETS>1) and (DCREPLACE = lru) generate
      reg2 : process(clk)
      begin if rising_edge(clk ) then rl <= cl; end if; end process;
    end generate;   

    
-- pragma translate_off
  chk : process
  begin
    assert not ((DSETS > 2) and (DCREPLACE = lrr)) report
	"Wrong data cache configuration detected: LRR replacement requires 2 sets"
    severity failure;
    wait;
  end process;
-- pragma translate_on

end ;

