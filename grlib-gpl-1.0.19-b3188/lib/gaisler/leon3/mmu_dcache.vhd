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
-- Entity:      dcache
-- File:        dcache.vhd
-- Author:      Jiri Gaisler, Konrad Eisele - Gaisler Research
-- Description: This unit implements the data cache controller.
------------------------------------------------------------------------------  

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
library grlib;
use grlib.amba.all;
use grlib.sparc.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.libiu.all;
use gaisler.libcache.all;
use gaisler.mmuconfig.all;		
use gaisler.mmuiface.all;		

entity mmu_dcache is
  generic (
    dsu       : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 0;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6 := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3 := 1;
    memtech   : integer range 0 to NTECH := 0;
    cached    : integer := 0);
  port (
    rst : in  std_logic;
    clk : in  std_logic;
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
    mmudco : in mmudc_out_type;
    sclk : in std_ulogic
);
end; 

architecture rtl of mmu_dcache is

constant DSNOOP2        : integer := conv_integer(conv_std_logic_vector(dsnoop,3) and conv_std_logic_vector(3,3));
constant DSNOOP4        : integer := conv_integer(conv_std_logic_vector(dsnoop,3) and conv_std_logic_vector(4,3));
  
constant M_TLB_TYPE     : integer range 0 to 1 := conv_integer(conv_std_logic_vector(tlb_type,2) and conv_std_logic_vector(1,2));  -- eather split or combined
constant M_TLB_FASTWRITE : integer range 0 to 3 := conv_integer(conv_std_logic_vector(tlb_type,2) and conv_std_logic_vector(2,2));   -- fast writebuffer

constant M_ENT_I        : integer range 2 to 64 := itlbnum;   -- icache tlb entries: number
constant M_ENT_ILOG     : integer := log2(M_ENT_I);     -- icache tlb entries: address bits

constant M_ENT_D        : integer range 2 to 64 := dtlbnum;   -- dcache tlb entries: number
constant M_ENT_DLOG     : integer := log2(M_ENT_D);     -- dcache tlb entries: address bits

constant M_ENT_C        : integer range 2 to 64 := M_ENT_I;   -- i/dcache tlb entries: number
constant M_ENT_CLOG     : integer := M_ENT_ILOG;     -- i/dcache tlb entries: address bits
  
constant DLINE_BITS   : integer := log2(dlinesize);
constant DOFFSET_BITS : integer := 8 +log2(dsetsize) - DLINE_BITS;
constant LRR_BIT      : integer := TAG_HIGH + 1;
constant TAG_LOW    : integer := DOFFSET_BITS + DLINE_BITS + 2;

constant OFFSET_HIGH: integer := TAG_LOW - 1;
constant OFFSET_LOW : integer := DLINE_BITS + 2;
constant LINE_HIGH  : integer := OFFSET_LOW - 1;
constant LINE_LOW   : integer := 2;
constant LINE_ZERO  : std_logic_vector(DLINE_BITS-1 downto 0) := (others => '0');
constant SETBITS : integer := log2x(DSETS); 
constant DLRUBITS  : integer := lru_table(DSETS);

constant lram      : integer range 0 to 1 := 0;
constant lramsize  : integer range 1 to 64 := 1;
constant lramstart : integer range 0 to 255 := 16#00#;
    
constant LOCAL_RAM_START : std_logic_vector(7 downto 0) := conv_std_logic_vector(lramstart, 8);
constant DREAD_FAST  : boolean := false;
constant DWRITE_FAST  : boolean := false;
constant DCLOCK_BIT : integer := dsetlock;
constant M_EN : boolean := true;
constant DCREPLACE  : integer range 0 to 2  :=    drepl;

constant DLINE_SIZE : integer := dlinesize;
constant DEST_RW      : boolean := (syncram_dp_dest_rw_collision(memtech) = 1);

type rdatatype is (dtag, ddata, dddata, dctx, icache, memory, sysr , misc, mmusnoop_dtag);  -- sources during cache read
type vmasktype is (clearone, clearall, merge, tnew);	-- valid bits operation

type valid_type is array (0 to DSETS-1) of std_logic_vector(dlinesize - 1 downto 0);

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
  size : std_logic_vector(1 downto 0);			-- access size
  req, burst, holdn, nomds, stpend  : std_logic;
  xaddress : std_logic_vector(31 downto 0);		-- common address buffer
  paddress : std_logic_vector(31 downto 0);		-- physical address buffer
  faddr : std_logic_vector(DOFFSET_BITS - 1 downto 0);	-- flush address
  valid : valid_type; --std_logic_vector(DLINE_SIZE - 1 downto 0);	-- registered valid bits
  dstate : dstatetype; 			                -- FSM
  hit : std_logic;
  flush		: std_logic;				-- flush in progress
  flush2	: std_logic;				-- flush in progress
  mexc 		: std_logic;				-- latched mexc
  wb 		: write_buffer_type;			-- write buffer
  asi  		: std_logic_vector(4 downto 0);
  icenable	: std_logic;				-- icache diag access
  rndcnt        : std_logic_vector(log2x(DSETS)-1 downto 0); -- replace counter
  setrepl       : std_logic_vector(log2x(DSETS)-1 downto 0); -- set to replace
  lrr           : std_logic;            
  dsuset        : std_logic_vector(log2x(DSETS)-1 downto 0);
  lock          : std_logic;
  lramrd : std_ulogic;
  cctrl		   : cctrltype;
  cctrlwr       : std_ulogic;

  mmctrl1       : mmctrl_type1;
  mmctrl1wr       : std_ulogic;
  
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
  readbpx  : std_logic_vector(0 to DSETS-1);  -- possible write/read contention
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
  set := (others => '0'); xlru := (others => '0'); xset := (others => '0');
  xlru(DLRUBITS-1 downto 0) := lru;

  if dsetlock = 1 then 
    unlocked := DSETS-1;
    for i in DSETS-1 downto 0 loop
      if lock(i) = '0' then unlocked := i; end if;
    end loop;
  end if;

  case DSETS is
  when 2 =>
    if dsetlock = 1 then
      if lock(0) = '1' then xset(0) := '1'; else xset(0) := xlru(0); end if;
    else xset(0) := xlru(0); end if;
  when 3 => 
    if dsetlock = 1 then
      xset := conv_std_logic_vector(lru3_repl_table(conv_integer(xlru)) (unlocked), 2);
    else
      xset := conv_std_logic_vector(lru3_repl_table(conv_integer(xlru)) (0), 2);
    end if;
  when 4 =>
    if dsetlock = 1 then
      xset := conv_std_logic_vector(lru4_repl_table(conv_integer(xlru)) (unlocked), 2);
    else
      xset := conv_std_logic_vector(lru4_repl_table(conv_integer(xlru)) (0), 2);
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

constant ctbl : std_logic_vector(15 downto 0) :=  conv_std_logic_vector(cached, 16);

begin

  dctrl : process(rst, r, rs, rh, rl, dci, mcdo, ico, dcramo, ahbsi, fpuholdn, mmudco)
  variable dcramov : dcram_out_type;
  variable rdatasel : rdatatype;
  variable maddress : std_logic_vector(31 downto 0);
  variable maddrlow : std_logic_vector(1 downto 0);
  variable edata : std_logic_vector(31 downto 0);
  variable size : std_logic_vector(1 downto 0);
  variable read : std_logic;
  variable twrite, tpwrite, tdiagwrite, ddiagwrite, dwrite : std_logic;
  variable taddr : std_logic_vector(OFFSET_HIGH  downto LINE_LOW); -- tag address
  variable newtag : std_logic_vector(TAG_HIGH  downto TAG_LOW); -- new tag
  variable newptag : std_logic_vector(TAG_HIGH  downto TAG_LOW); -- new tag
  variable align_data : std_logic_vector(31 downto 0); -- aligned data
  variable ddatainv, rdatav, align_datav : cdatatype;
  variable rdata : std_logic_vector(31 downto 0);

  variable vmaskraw : std_logic_vector((dlinesize -1) downto 0);
  variable vmask : valid_type; --std_logic_vector((dlinesize -1) downto 0);
  variable ivalid : std_logic_vector((dlinesize -1) downto 0);
  variable vmaskdbl : std_logic_vector((dlinesize/2 -1) downto 0);
  variable enable, senable, scanen : std_logic_vector(0 to 3);
  variable mds : std_logic;
  variable mexc : std_logic;
  variable hit, valid, validraw, forcemiss : std_logic;
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
  variable ctwrite, ctpwrite, cdwrite : std_logic_vector(0 to MAXSETS-1);
  variable vset, setrepl  : std_logic_vector(log2x(DSETS)-1 downto 0);
  variable wlrr : std_logic_vector(0 to MAXSETS-1);
  variable vl : lru_reg_type;
  variable diagset : std_logic_vector(TAG_LOW + SETBITS -1 downto TAG_LOW);
  variable lock : std_logic_vector(0 to DSETS-1);
  variable wlock : std_logic_vector(0 to MAXSETS-1);
  variable snoopset2, rdsuset : integer range 0 to DSETS-1;
  variable snoophit : std_logic_vector(0 to DSETS-1);
  variable snoopval : std_logic;
  variable tag : cdatatype; --std_logic_vector(31  downto 0);
  variable ptag : cdatatype; --std_logic_vector(31  downto 0);
  variable ctx : ctxdatatype;

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
  variable mmudci_wb_op : std_logic;
  variable mmudci_diag_op : std_logic;
  variable mmudci_su : std_logic;
  variable mmudci_read : std_logic;
  variable mmuregw, su : std_logic;
  variable mmuisdis : std_logic;
  variable readbp : std_logic_vector(0 to DSETS-1);
  variable rbphit, sidle : std_logic;

  variable mmudci_transdata_data : std_logic_vector(31 downto 0);
  variable paddress : std_logic_vector(31 downto 0);		-- physical address buffer

  begin

-- init local variables

    v := r; vs := rs; vh := rh; dcramov := dcramo; vl := rl;
    vl.write := '0'; v.cctrlwr := '0'; v.mmctrl1wr := '0';
    v.flush2 := r.flush; sidle := '0';

    if ((dci.eenaddr or dci.enaddr) = '1') or (r.dstate /= idle) or 
       ((dsu = 1) and (dci.dsuen = '1')) or (r.flush = '1')  or
	(is_fpga(memtech) = 1)
    then
      enable := (others => '1');
    else enable := (others => '0'); end if;

    tagclear := '0'; mmuisdis := '0';
    if (not M_EN) or ((r.asi(4 downto 0) = ASI_MMU_BP) or (r.mmctrl1.e = '0')) then
      mmuisdis := '1';
    end if;
    
    if (mmuisdis = '1') then paddress := r.xaddress;
    else paddress := r.paddress; end if;

    mds := '1'; dwrite := '0'; twrite := '0'; tpwrite := '0'; 
    ddiagwrite := '0'; tdiagwrite := '0'; v.holdn := '1'; mexc := '0';
    flush := '0'; v.icenable := '0'; iflush := '0';
    eholdn := ico.hold and fpuholdn; ddset := 0; vset := (others => '0');
    tparerr  := (others => '0'); dparerr  := (others => '0'); 
    vs.snoop := '0'; vs.writebp := (others => '0'); snoopwe := '0';
    snoopaddr := ahbsi.haddr(OFFSET_HIGH downto OFFSET_LOW);
    hcache := '0'; rdsuset := 0; 
    validv := (others => '0'); validrawv := (others => '0');
    hitv := (others => '0'); ivalid := (others => '0');
    miscdata := (others => '0'); pflush := '0';
    pflushaddr := dci.maddress(VA_I_U downto VA_I_D); pflushtyp := PFLUSH_PAGE;
    pftag := (others => '0');  
    mmudiagaddr := (others => '0'); mmuregw := '0'; mmuwdata := (others => '0');
    mmudci_fsread := '0';
    ddatainv := (others => (others => '0')); tag := (others => (others => '0')); ptag := (others => (others => '0'));
    ctx := (others => (others => '0')); vs.readbpx := (others => '0'); rbphit := '0';
    newptag(TAG_HIGH downto TAG_LOW) := (others => '0');
    
    v.trans_op := r.trans_op and (not mmudco.grant);
    v.flush_op := r.flush_op and (not mmudco.grant);
    v.diag_op := r.diag_op and (not mmudco.grant);
    mmudci_trans_op := r.trans_op;
    mmudci_flush_op := r.flush_op;
    mmudci_diag_op := r.diag_op;
    mmudci_wb_op := '0';
    mmudci_transdata_data := r.vaddr;
    
    mmudci_su := '0'; mmudci_read := '0'; su := '0';
    if (not M_EN) or (r.mmctrl1.e = '0') then v.cache := '1'; end if;
    
    rdatasel := ddata;	-- read data from cache as default
    senable := (others => '0'); scanen := (others => mcdo.scanen);
    
    set := 0; snoopset := 0;  csnoopwe := (others => '0');
    ctwrite := (others => '0'); ctpwrite := (others => '0'); cdwrite := (others => '0');
    wlock := (others => '0');
    for i in 0 to DSETS-1 loop wlock(i) := dcramov.tag(i)(CTAG_LOCKPOS); end loop; 
    wlrr := (others => '0');
    for i in 0 to 3 loop wlrr(i) := dcramov.tag(i)(CTAG_LRRPOS); end loop; 
    
    if (DSETS > 1) then setrepl := r.setrepl; else setrepl := (others => '0'); end if;
    
-- random replacement counter
    if DSETS > 1 then
      if conv_integer(r.rndcnt) = (DSETS - 1) then v.rndcnt := (others => '0');
      else v.rndcnt := r.rndcnt + 1; end if;
    end if;

-- generate lock bits
    lock := (others => '0');
    if DCLOCK_BIT = 1 then 
      for i in 0 to DSETS-1 loop lock(i) := dcramov.tag(i)(CTAG_LOCKPOS); end loop;
    end if;
    
-- AHB snoop handling

    if DSNOOP2 /= 0 then
      -- snoop on NONSEQ or SEQ and first word in cache line
      -- do not snoop during own transfers or during cache flush
      if (ahbsi.hready and ahbsi.hwrite and not mcdo.bg) = '1' and
         ((ahbsi.htrans = HTRANS_NONSEQ) or 
	    ((ahbsi.htrans = HTRANS_SEQ) and 
	     (ahbsi.haddr(LINE_HIGH downto LINE_LOW) = LINE_ZERO))) 
      then
	vs.snoop := r.cctrl.dsnoop;-- and not r.mmctrl1.e;
        vs.addr := ahbsi.haddr(TAG_HIGH downto OFFSET_LOW); 
      end if;

      for i in 0 to DSETS-1 loop senable(i) := vs.snoop or rs.snoop; end loop;
        
      readbp := (others => '0');
      if (paddress(TAG_HIGH downto OFFSET_LOW) = rs.addr(TAG_HIGH downto OFFSET_LOW)) then rbphit := '1'; end if;
      for i in 0 to DSETS-1 loop
        if (rs.readbpx(i) and rbphit) = '1' then readbp(i) := '1'; end if;
      end loop;
        
      -- clear valid bits on snoop hit (or set hit bits)
      for i in DSETS-1 downto 0 loop
        if ((rs.snoop and (not mcdo.ba) and not r.flush) = '1') 
          and ((dcramov.stag(i)(TAG_HIGH downto TAG_LOW) = rs.addr(TAG_HIGH downto TAG_LOW)) or (readbp(i) = '1'))
        then
          if DSNOOP2 = 2 then
            vh.hit(conv_integer(rs.addr(OFFSET_HIGH downto OFFSET_LOW)))(i) := '1';
          else
            snoopaddr := rs.addr(OFFSET_HIGH downto OFFSET_LOW);
            snoopwe := '1'; snoopset := i;        
          end if;
        end if;
      -- bypass tag data on read/write contention
        if (DSNOOP2 /= 2) and (rs.writebp(i) = '1') then 
          dcramov.tag(i)(TAG_HIGH downto TAG_LOW) := rs.addr(TAG_HIGH downto TAG_LOW);
          dcramov.tag(i)(dlinesize-1 downto 0) := zero32(dlinesize-1 downto 0);
        end if;
      end loop;
    end if;

-- generate access parameters during pipeline stall

    if ((r.holdn) = '0') or ((dsu = 1) and (dci.dsuen = '1')) then
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW);
    elsif ((dci.enaddr and not dci.read) = '1') or (eholdn = '0')
    then
      taddr := dci.maddress(OFFSET_HIGH downto LINE_LOW);
    else
      taddr := dci.eaddress(OFFSET_HIGH downto LINE_LOW);
    end if;
    
    if (dci.write or not r.holdn) = '1' then
      maddress := r.xaddress(31 downto 0); --signed := r.signed; 
      read := r.read; size := r.size; edata := dci.maddress;
      mmudci_su := r.su; mmudci_read := r.read;
    else
      maddress := dci.maddress(31 downto 0); --signed := dci.signed; 
      read := dci.read; size := dci.size; edata := dci.edata;
      mmudci_su := dci.msu; mmudci_read := dci.read;
    end if;

    newtag := dci.maddress(TAG_HIGH downto TAG_LOW);
    newptag := dci.maddress(TAG_HIGH downto TAG_LOW);
    vl.waddr := maddress(OFFSET_HIGH downto OFFSET_LOW);  -- lru write address

-- generate cache hit and valid bits

    if cached /= 0 then hcache := ctbl(conv_integer(dci.maddress(31 downto 28)));
    else hcache := '1'; end if;

    forcemiss := not dci.asi(3); hit := '0'; set := 0; 
    snoophit := (others => '0'); snoopval := '1';
    for i in DSETS-1 downto 0 loop
      if DSNOOP2 = 2 then
        snoophit(i) := rh.hit(conv_integer(rh.taddr))(i);
      end if;
      if (dcramov.tag(i)(TAG_HIGH downto TAG_LOW) = dci.maddress(TAG_HIGH downto TAG_LOW))
        and ((dcramov.ctx(i) = r.mmctrl1.ctx) or (r.mmctrl1.e = '0'))
      then hitv(i) := hcache; end if;
      validrawv(i) := hitv(i) and (not r.flush) and (not r.flush2) and (not snoophit(i)) and
	genmux(dci.maddress(LINE_HIGH downto LINE_LOW), dcramov.tag(i)(dlinesize-1 downto 0));
      validv(i) :=  validrawv(i);
      snoopval := snoopval and not snoophit(i);
    end loop;
              
    hit := orv(hitv) and not r.flush and (not r.flush2);

    -- cache hit disabled if mmu-enabled but off or BYPASS
    if (M_EN) and (dci.asi(4 downto 0) = ASI_MMU_BP) then  -- or (r.mmctrl1.e = '0')
      hit := '0';
    end if;
    
    validraw := orv(validrawv);
    valid := orv(validv);
    if DSETS > 1 then 
      for i in DSETS-1 downto 0 loop 
        if hitv(i) = '1' then
	  vset := conv_std_logic_vector(i, SETBITS);
        end if;
      end loop;
      set := conv_integer(vset);
    else set := 0; end if;

    if (dci.dsuen = '1') then diagset := r.xaddress(TAG_LOW+SETBITS-1 downto TAG_LOW);                                                
    else diagset := maddress(TAG_LOW + SETBITS - 1 downto TAG_LOW); end if;
    case DSETS is
    when 1 => ddset := 0;
    when 3 => if conv_integer(diagset) < 3 then ddset := conv_integer(diagset); end if;
    when others => ddset := conv_integer(diagset); 
    end case;
    
    if ((r.holdn and dci.enaddr) = '1')  and (r.dstate = idle) then
        v.hit := hit; v.xaddress := dci.maddress;
	v.read := dci.read; v.size := dci.size;
	v.asi := dci.asi(4 downto 0);  
	--v.signed := dci.signed;
        v.su := dci.msu;
    end if;

-- Store buffer

    if mcdo.ready = '1' then
      v.wb.addr(2) := r.wb.addr(2) or (r.wb.size(0) and r.wb.size(1));
      if r.stpend = '1' then
        v.stpend := r.req; v.wb.data1 := r.wb.data2; 
	v.wb.lock := r.wb.lock and r.req;
      end if;
    end if;
    if mcdo.grant = '1' then v.req := r.burst; v.burst := '0'; end if;
    if (mcdo.grant and not r.wb.read and r.req) = '1' then v.wb.lock := '0'; end if;

    -- cache freeze operation
    if (r.cctrl.ifrz and dci.intack and r.cctrl.ics(0)) = '1' then
      v.cctrl.ics := "01";
    end if;
    if (r.cctrl.dfrz and dci.intack and r.cctrl.dcs(0)) = '1' then
      v.cctrl.dcs := "01";
    end if;    
    
    if r.cctrlwr = '1' then
    if (r.xaddress(7 downto 2) = "000000") and (dci.read = '0') then
      v.cctrl.dsnoop := dci.maddress(23);
      flush        := dci.maddress(22);
      iflush       := dci.maddress(21);
      v.cctrl.burst:= dci.maddress(16);
      v.cctrl.dfrz := dci.maddress(5);
      v.cctrl.ifrz := dci.maddress(4);
      v.cctrl.dcs  := dci.maddress(3 downto 2);
      v.cctrl.ics  := dci.maddress(1 downto 0);              
    end if;
    end if;

    if (dsu = 1) and (dci.dsuen = '1') then
      mmuwdata := dci.maddress;
    else
      mmuwdata := dci.edata;
    end if;
      
    mmudiagaddr := dci.maddress(CNR_U downto CNR_D);
    if r.mmctrl1wr = '1' then
      mmudiagaddr := r.xaddress(CNR_U downto CNR_D);  -- defer match sram out
      if (dci.read = '0') then
        mmuwdata := dci.maddress;
        mmuregw := '1';  
      end if;
    end if;
    
-- main Dcache state machine

    case r.dstate is
    when idle =>			-- Idle state
      if (M_TLB_FASTWRITE /= 0) then
        mmudci_transdata_data := dci.maddress;
      end if;
      sidle := '1';
      if (snoopval = '1') then
        for i in 0 to DSETS-1 loop
          v.valid(i) := dcramov.tag(i)(dlinesize-1 downto 0);
	end loop;
      else v.valid := (others => (others => '0')); end if;
      v.nomds := r.nomds and not eholdn; --v.valid := dcramov.dtramout(set).valid;
      if (r.stpend  = '0') or ((mcdo.ready and not r.req)= '1') then -- wait for store queue
	v.wb.addr := dci.maddress; v.wb.size := dci.size; 
	v.wb.read := dci.read; v.wb.data1 := dci.edata; v.wb.lock := dci.lock;
	v.wb.asi := dci.asi(3 downto 0); 
        if ((M_EN) and (dci.asi(4 downto 0) /= ASI_MMU_BP) and (r.mmctrl1.e = '1') and (M_TLB_FASTWRITE /= 0) ) then
          v.wb.addr := mmudco.wbtransdata.data;
          newptag := mmudco.wbtransdata.data(TAG_HIGH downto TAG_LOW);
        end if;
      end if;
      if (eholdn and (not r.nomds)) = '1' then -- avoid false path through nullify
	case dci.asi(4 downto 0) is
 	when ASI_SYSR => rdatasel := sysr;	
	when ASI_DTAG => rdatasel := dtag;
	when ASI_DDATA => rdatasel := dddata;
	when ASI_DCTX => rdatasel := dctx;
        when ASI_MMUREGS => rdatasel := misc;  
	when ASI_MMUSNOOP_DTAG => rdatasel := mmusnoop_dtag;
	when others =>
	end case;
      end if;
      if (dci.enaddr and eholdn and (not r.nomds) and not dci.nullify) = '1' then
	case dci.asi(4 downto 0) is
	when ASI_SYSR =>		-- system registers
          if (dsu = 0) or (dci.dsuen = '0') then
            if (dci.maddress(7 downto 2) = "000000") and (dci.read = '0') then
              v.cctrl.dsnoop := dci.edata(23);
              flush        := dci.edata(22);
              iflush       := dci.edata(21);
              v.cctrl.burst:= dci.edata(16);
              v.cctrl.dfrz := dci.edata(5);
              v.cctrl.ifrz := dci.edata(4);
              v.cctrl.dcs  := dci.edata(3 downto 2);
              v.cctrl.ics  := dci.edata(1 downto 0);
            end if;
          else
            v.cctrlwr := not dci.read;
          end if;
        when ASI_MMUREGS =>
          if (dsu = 0) or dci.dsuen = '0' then
            if M_EN then
--              rdatasel := misc; 
              -- clean fault valid bit
              if dci.read = '1' then
                case dci.maddress(CNR_U downto CNR_D) is
                  when CNR_F =>
                    mmudci_fsread := '1';
                  when others => null;
                end case;
              else
                mmuregw := '1';
              end if;
            end if;
          else
            v.mmctrl1wr := not dci.read and not (r.mmctrl1wr and dci.dsuen);
          end if;
	when ASI_ITAG | ASI_IDATA | ASI_ICTX =>		-- Read/write Icache tags
          -- CTX write has to be done through ctxnr & ASI_ITAG
	  if (ico.flush = '1') or (dci.asi(4) = '1') then mexc := '1';
 	 else v.dstate := asi_idtag; v.holdn := '0'; end if;
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
        when ASI_MMUSNOOP_DTAG =>	-- Read/write MMU physical snoop tags
          if M_EN then
          snoopaddr := taddr(OFFSET_HIGH downto OFFSET_LOW);
          if (dci.size /= "10") or (r.flush = '1') then -- allow only word access
 	    mexc := '1';
 	  elsif (dci.read = '0') then
 	    tpwrite := '1'; tdiagwrite := '1';
 	  end if;
 	  end if;
        when ASI_DCTX =>
          -- write has to be done through ctxnr & ASI_DTAG
          if (dci.size /= "10") or (r.flush = '1') or (dci.read = '0') then -- allow only word access
 	    mexc := '1';
 	  end if;
        when ASI_FLUSH_PAGE => -- i/dcache flush page
          if M_EN then
            if dci.read = '0' then
              flush := '1'; iflush := '1'; --pflush := '1'; pflushtyp := PFLUSH_PAGE;
            end if;
 	  end if;
        when ASI_FLUSH_CTX => -- i/dcache flush ctx
          if M_EN then
            if dci.read = '0' then
              flush := '1'; iflush := '1'; --pflush := '1'; pflushtyp := PFLUSH_CTX;
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
          if dci.read = '0' then      -- diag access
            mmudci_diag_op := '1';
            v.diag_op := not mmudco.grant;
            v.vaddr := dci.maddress;
          end if;
        when others =>
	  if dci.read = '1' then	-- read access
            --if (not ((mcdo.dcs(0) = '1') 
            if (not ((r.cctrl.dcs(0) = '1') 
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
              -- ## mmu case >  false and
              --if  ((r.stpend  = '0') or ((mcdo.ready and not r.req)= '1')) and ( mmudco.wbtransdata.accexc = '0' ) and (dci.size /= "11") and (M_TLB_FASTWRITE /= 0) 
              if  ((r.stpend  = '0') or ((mcdo.ready and not r.req)= '1')) and ( mmudco.wbtransdata.accexc = '0' ) and (M_TLB_FASTWRITE /= 0) 
              then
                v.req := '1'; v.stpend := '1'; 
                v.burst := dci.size(1) and dci.size(0);
                if (dci.size = "11") then v.dstate := dblwrite; end if; -- double store	      
              else
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
            end if;

            -- note: cache hit disabled if BYPASS
            if (r.cctrl.dcs(0) = '1') and ((hit and (dci.size(1) or validraw)) = '1') 
            then  -- write hit
              twrite := '1'; dwrite := '1';
              if (DSETS > 1) and (DCREPLACE = lru) then vl.write := '1'; end if;
              setrepl := conv_std_logic_vector(set, SETBITS);
              if DSNOOP2 /= 0 then
                if ((dci.enaddr and not dci.read) = '1') or (eholdn = '0')
                then v.xaddress := dci.maddress; else v.xaddress := dci.eaddress; end if;
                vs.readbpx(set) := '1';
              end if;              
            end if;
	    if (dci.size = "11") then v.xaddress(2) := '1'; end if;
	  end if;

          if (DSETS > 1) then
    	    vl.set := conv_std_logic_vector(set, SETBITS);
            v.setrepl := conv_std_logic_vector(set, SETBITS);
            if ((not hit) and (not dparerr(set)) and (not r.flush)) = '1' then
              case DCREPLACE is
              when rnd =>
                if DCLOCK_BIT = 1 then 
                  if lock(conv_integer(r.rndcnt)) = '0' then v.setrepl := r.rndcnt;
                  else
                    v.setrepl := conv_std_logic_vector(DSETS-1, SETBITS);
                    for i in DSETS-1 downto 0 loop
                      if (lock(i) = '0') and (i>conv_integer(r.rndcnt)) then
                        v.setrepl := conv_std_logic_vector(i, SETBITS);
                      end if;
                    end loop;
                  end if;
                else
                  v.setrepl := r.rndcnt;
                end if;
              when lru =>
                v.setrepl := lru_set(rl.lru(conv_integer(dci.maddress(OFFSET_HIGH downto OFFSET_LOW))), lock(0 to DSETS-1));
              when lrr =>
                v.setrepl := (others => '0');
                if DCLOCK_BIT = 1 then 
                  if lock(0) = '1' then v.setrepl(0) := '1';
                  else
                    v.setrepl(0) := dcramov.tag(0)(CTAG_LRRPOS) xor dcramov.tag(1)(CTAG_LRRPOS);
                  end if;
                else
                  v.setrepl(0) := dcramov.tag(0)(CTAG_LRRPOS) xor dcramov.tag(1)(CTAG_LRRPOS);
                end if;
                if v.setrepl(0) = '0' then
                  v.lrr := not dcramov.tag(0)(CTAG_LRRPOS);
                else
                  v.lrr := dcramov.tag(0)(CTAG_LRRPOS);
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
        end if;
      end if;

    when wread => 		-- read miss, wait for memory data
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW);
      newtag := r.xaddress(TAG_HIGH downto TAG_LOW);
      newptag := paddress(TAG_HIGH downto TAG_LOW);
      v.nomds := r.nomds and not eholdn;
      v.holdn := v.nomds; rdatasel := memory;
      for i in 0 to DSETS-1 loop wlock(i) := r.lock; end loop;
      for i in 0 to 1 loop wlrr(i) := r.lrr; end loop;
      if (r.stpend = '0') and (r.ready = '0') then

        if mcdo.ready = '1' then
          mds := r.holdn or r.nomds; v.xaddress(2) := '1'; v.holdn := '1';
          if (r.cctrl.dcs = "01") then 
	    v.hit := mcdo.cache and r.hit and r.cache; twrite := v.hit;
          elsif (r.cctrl.dcs(1) = '1') then 
	    v.hit := mcdo.cache and (r.hit or (r.asi(3) and not r.asi(2))) and r.cache; twrite := v.hit;
	  end if; 
          dwrite := twrite; rdatasel := memory;
          mexc := mcdo.mexc;
          tpwrite := twrite;
          
	  if r.req = '0' then

	    if (((dci.enaddr and not mds) = '1') or 
              ((dci.eenaddr and mds and eholdn) = '1')) and (r.cctrl.dcs(0) = '1') then
	      v.dstate := loadpend; v.holdn := '0';
	    else v.dstate := idle; end if;
	  else v.nomds := '1'; end if;
        end if;
	v.mexc := mcdo.mexc; v.wb.data2 := mcdo.data;
      else
	if (r.ready or (mcdo.ready and not r.req)) = '1' then	-- wait for store queue
	  v.burst := r.size(1) and r.size(0) and not r.xaddress(2);
          v.wb.addr := paddress;
          v.wb.size := r.size; 
	  v.wb.read := r.read; v.wb.data1 := dci.maddress; v.req := '1'; 
	  v.wb.lock := dci.lock; v.wb.asi := r.asi(3 downto 0); v.ready := '0';
        end if;
      end if;
      if DSNOOP2 /= 0 then vs.readbpx(conv_integer(setrepl)) := '1'; end if;
    when loadpend =>		-- return from read miss with load pending
      taddr := dci.maddress(OFFSET_HIGH downto LINE_LOW);
      v.dstate := idle; 
    when dblwrite => 		-- second part of double store cycle
      v.dstate := idle; v.wb.data2 := dci.edata; 
      edata := dci.edata;  -- needed for STD store hit
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); 
        if (r.cctrl.dcs(0) = '1') and (r.hit = '1') then dwrite := '1'; end if;

    when asi_idtag =>		-- icache diag access
      rdatasel := icache; v.icenable := '1'; v.holdn := dci.dsuen;
      if  ico.diagrdy = '1' then
	v.dstate := loadpend; v.icenable := '0'; mds := not r.read;
      end if;
      
    when wtrans =>
      edata := dci.edata;  -- needed for STD store hit
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); 
      newtag := r.xaddress(TAG_HIGH downto TAG_LOW);
          
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
        end if;
        
        v.holdn := '0';
        if mmudco.transdata.finish = '1' then        
          if (mmudco.transdata.accexc) = '1' then
            v.holdn := '1'; v.dstate := idle;
            mds := '0'; mexc := not r.mmctrl1.nf;
            
              tagclear := r.cctrl.dcs(0) and r.hit;
            
            twrite := tagclear;
            
	    if (twrite = '1') and (((dci.enaddr and not mds) = '1') or 
	        ((dci.eenaddr and mds and eholdn) = '1')) and (r.cctrl.dcs(0) = '1') then
	      v.dstate := loadpend; v.holdn := '0';
	    end if;
            
          else
            v.dstate := wwrite;
            v.cache := mmudco.transdata.cache;
            v.paddress := mmudco.transdata.data;
            
            if (r.wbinit) = '1' then
              v.wb.data2 := dci.edata; 
              v.wb.addr := mmudco.transdata.data;
              v.dstate := idle;  v.holdn := '1'; 
              v.req := '1'; v.stpend := '1';
              v.burst := r.size(1) and r.size(0) and not v.wb.addr(2);

              --if (mcdo.dcs(0) = '1') and (r.hit = '1') and (r.size = "11")  then  -- write hit
              if (r.cctrl.dcs(0) = '1') and (r.hit = '1') and (r.size = "11")  then  -- write hit
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

          if (r.cctrl.dcs(0) = '1') and (r.hit = '1') and (r.size = "11")  then  -- write hit
            taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); dwrite := '1';
          end if;
        v.dstate := idle; 

	v.req := '1'; v.burst := r.size(1) and r.size(0); v.stpend := '1';

        v.wb.addr := paddress;
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

-- select data to return on read access
-- align if byte/half word read from cache or memory.

    --mmudiagaddr := dci.maddress(CNR_U downto CNR_D); mmuwdata := dci.edata;
    if (dsu = 1) and (dci.dsuen = '1') then
      v.dsuset := conv_std_logic_vector(ddset, SETBITS); 
      case dci.asi(4 downto 0) is
      when ASI_ITAG | ASI_IDATA =>
        v.icenable := not ico.diagrdy;
        rdatasel := icache;
      when ASI_DTAG =>
        tdiagwrite := not dci.eenaddr and dci.enaddr and dci.write;
        twrite := not dci.eenaddr and dci.enaddr and dci.write;
        rdatasel := dtag; 
      when ASI_MMUSNOOP_DTAG =>
        if M_EN then
        tdiagwrite := not dci.eenaddr and dci.enaddr and dci.write;
        tpwrite := not dci.eenaddr and dci.enaddr and dci.write;
        rdatasel := mmusnoop_dtag;
        end if;
      when ASI_DDATA =>
        ddiagwrite := not dci.eenaddr and dci.enaddr and dci.write;
        dwrite := not dci.eenaddr and dci.enaddr and dci.write;
        rdatasel := dddata; 
      when ASI_MMUREGS =>
        mmuregw := not dci.eenaddr and dci.enaddr and dci.write;
        rdatasel := misc;  
      when others =>
      end case;
    end if;

    -- note: mmudiagaddr is (10 downto 8) (000,001, ...)
    -- read
    case mmudiagaddr is
      when CNR_CTRL => 
        miscdata(MMCTRL_E) := r.mmctrl1.e; 
        miscdata(MMCTRL_NF) := r.mmctrl1.nf; 
        miscdata(MMCTRL_PSO) := r.mmctrl1.pso;
        miscdata(MMCTRL_VER_U downto MMCTRL_VER_D) := "0000";
        miscdata(MMCTRL_IMPL_U downto MMCTRL_IMPL_D) := "0000";
        miscdata(23 downto 21) := conv_std_logic_vector(M_ENT_ILOG,3);
        miscdata(20 downto 18) := conv_std_logic_vector(M_ENT_DLOG,3);
        if M_TLB_TYPE = 0 then miscdata(17) := '1'; else
          miscdata(23 downto 21) := conv_std_logic_vector(M_ENT_CLOG,3);
          miscdata(20 downto 18) := (others => '0');
        end if;
        miscdata(MMCTRL_TLBDIS) := r.mmctrl1.tlbdis;
        --custom 
      when CNR_CTXP =>
        miscdata(MMCTXP_U downto MMCTXP_D) := r.mmctrl1.ctxp; 
      when CNR_CTX => 
        miscdata(MMCTXNR_U downto MMCTXNR_D) := r.mmctrl1.ctx; 
      when CNR_F =>
        miscdata(FS_OW) := mmudco.mmctrl2.fs.ow;
        miscdata(FS_FAV) := mmudco.mmctrl2.fs.fav;
        miscdata(FS_FT_U downto FS_FT_D) := mmudco.mmctrl2.fs.ft;
        miscdata(FS_AT_LS) := mmudco.mmctrl2.fs.at_ls;
        miscdata(FS_AT_ID) := mmudco.mmctrl2.fs.at_id;
        miscdata(FS_AT_SU) := mmudco.mmctrl2.fs.at_su;
        miscdata(FS_L_U downto FS_L_D) := mmudco.mmctrl2.fs.l;
        miscdata(FS_EBE_U downto FS_EBE_D) := mmudco.mmctrl2.fs.ebe;
      when CNR_FADDR => 
        miscdata(VA_I_U downto VA_I_D) := mmudco.mmctrl2.fa; 
      when others => null; 
    end case;
    

    
    rdata := (others => '0'); rdatav := (others => (others => '0'));
    align_data := (others => '0'); align_datav := (others => (others => '0'));
    maddrlow := maddress(1 downto 0); -- stupid Synopsys VSS bug ...

    case rdatasel is
    when misc =>
      set := 0;
      rdatav(0) := miscdata;
    when dddata => 
      rdatav := dcramov.data;
      if dci.dsuen = '1' then set := conv_integer(r.dsuset);
      else set := ddset; end if; 
    when dtag => 
      rdatav := dcramov.tag; 
      if dci.dsuen = '1' then set := conv_integer(r.dsuset);
      else set := ddset; end if; 
    when mmusnoop_dtag => 
      rdatav := dcramov.stag; 
      if dci.dsuen = '1' then set := conv_integer(r.dsuset);
      else set := ddset; end if; 
    when dctx =>
      --rdata(M_CTX_SZ-1 downto 0) := dcramov.dtramout(ddset).ctx;
    when icache => 
      rdatav(0) := ico.diagdata; set := 0;
    when ddata | memory =>
        if rdatasel = memory then
	  rdatav(0) := mcdo.data; set := 0; --FIXME
        else
	  for i in 0 to DSETS-1 loop rdatav(i) := dcramov.data(i); end loop;
        end if;
    when sysr => 
      set := 0;
      case dci.maddress(3 downto 2) is
      when "00" | "01" =>
        rdatav(0)(23) := r.cctrl.dsnoop;
        rdatav(0)(16 downto 14) := r.cctrl.burst & ico.flush & r.flush;
        rdatav(0)(5 downto 0) := 
            r.cctrl.dfrz & r.cctrl.ifrz & r.cctrl.dcs & r.cctrl.ics;
      when "10" =>
	rdatav(0) := ico.cfg;
      when others =>
	rdatav(0) := cache_cfg(drepl, dsets, dlinesize, dsetsize, dsetlock, 
		dsnoop, lram, lramsize, lramstart, 1);
      end case;
    end case;

-- select which data to update the data cache with

       for i in 0 to DSETS-1 loop
        case size is		-- merge data during partial write
        when "00" =>
          case maddrlow is
          when "00" =>
	    ddatainv(i) := edata(7 downto 0) & dcramov.data(i)(23 downto 0);
          when "01" =>
	    ddatainv(i) := dcramov.data(i)(31 downto 24) & edata(7 downto 0) & 
		     dcramov.data(i)(15 downto 0);
          when "10" =>
	    ddatainv(i) := dcramov.data(i)(31 downto 16) & edata(7 downto 0) & 
		     dcramov.data(i)(7 downto 0);
          when others =>
	    ddatainv(i) := dcramov.data(i)(31 downto 8) & edata(7 downto 0); 
          end case;
        when "01" =>
          if maddress(1) = '0' then
            ddatainv(i) := edata(15 downto 0) & dcramov.data(i)(15 downto 0);
          else
            ddatainv(i) := dcramov.data(i)(31 downto 16) & edata(15 downto 0);
          end if;
        when others => 
          ddatainv(i) := edata;
        end case;

      end loop;

-- handle double load with pipeline hold

    if (r.dstate = idle) and (r.nomds = '1') then
      rdatav(0) := r.wb.data2; mexc := r.mexc; set := 0; --FIXME
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

    vmask := (others => vmaskraw);
    if r.hit = '1' then 
      for i in 0 to DSETS-1 loop vmask(i) := r.valid(i) or vmaskraw; end loop;
    end if;
    if r.dstate = idle then 
      for i in 0 to DSETS-1 loop
        vmask(i) := dcramov.tag(i)(dlinesize-1 downto 0) or vmaskraw;
      end loop;

    end if;

    if (mcdo.mexc or r.flush) = '1' then twrite := '0'; dwrite := '0'; end if;
    if twrite = '1' then
      if tagclear = '1' then vmask := (others => (others => '0')); end if;
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
      if (dsu = 1) and (dci.dsuen = '1') then
        vmask := (others => dci.maddress(dlinesize - 1 downto 0));        
      else
         vmask := (others => dci.edata(dlinesize - 1 downto 0));
        newtag(TAG_HIGH downto TAG_LOW) := dci.edata(TAG_HIGH downto TAG_LOW);
        newptag(TAG_HIGH downto TAG_LOW) := dci.edata(TAG_HIGH downto TAG_LOW);
        for i in 0 to 3 loop wlrr(i)  := dci.edata(CTAG_LRRPOS); end loop;
        for i in 0 to DSETS-1 loop wlock(i) := dci.edata(CTAG_LOCKPOS); end loop;
      end if;
    end if;

    -- mmureg write
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
    
    
    

-- cache flush

    --if (dci.flush or flush or mcdo.dflush) = '1' then
    if (dci.flush or flush ) = '1' then
      v.flush := '1'; v.faddr := (others => '0'); v.pflush := pflush;
      v.pflushr := '1';
      v.pflushaddr := pflushaddr;
      v.pflushtyp := pflushtyp;
    end if;
    
    if r.flush = '1' then      
      twrite := '1'; vmask := (others=>(others => '0')); v.faddr := r.faddr +1; 
      newtag(TAG_HIGH downto TAG_LOW) := (others => '0');
      newptag(TAG_HIGH downto TAG_LOW) := (others => '0');
      taddr(OFFSET_HIGH downto OFFSET_LOW) := r.faddr;
      wlrr := (others => '0'); v.lrr := '0'; 
      if (r.faddr(DOFFSET_BITS -1) and not v.faddr(DOFFSET_BITS -1)) = '1' then
	v.flush := '0';
      end if;      
      if DSNOOP2 = 2 then
        vh.hit(conv_integer(taddr(OFFSET_HIGH downto OFFSET_LOW))) := (others => '0');
      end if;
    end if;

-- AHB snoop handling (2), bypass write data on read/write contention

    if DSNOOP2 /= 0 then
      if tdiagwrite = '1' then snoopset2 := ddset; 
      else snoopset2 := conv_integer(setrepl); end if;
      if DSNOOP2 = 2 then
        vh.taddr := taddr(OFFSET_HIGH downto OFFSET_LOW);
        vh.set := conv_std_logic_vector(set, SETBITS);
	if (twrite = '1') and (r.dstate /= idle) then 
	  vh.hit(conv_integer(taddr(OFFSET_HIGH downto OFFSET_LOW)))(snoopset2) := '0';
	end if;
      else
        if rs.addr(OFFSET_HIGH  downto OFFSET_LOW) = 
	  taddr(OFFSET_HIGH  downto OFFSET_LOW) 
	then 
	  if twrite = '0' then 
            if snoopwe = '1' then
              vs.writebp(snoopset) := '1';
              if DEST_RW then enable(snoopset) := '0'; end if;              
            end if;
	  else
            if (snoopwe = '1') and (conv_integer(setrepl) = snoopset) then -- avoid write/write contention
              twrite := '0';
              if DEST_RW then enable(snoopset) := '0'; end if;              
            end if; 
	  end if;
	end if;
      end if;
      if (r.dstate = wread) and ((rbphit and rs.snoop) = '1') then v.hit := '0'; end if;
      if DEST_RW then
        -- disable snoop read enable on write/read contention
        if taddr(OFFSET_HIGH downto OFFSET_LOW) = ahbsi.haddr(OFFSET_HIGH  downto OFFSET_LOW) then
          for i in 0 to DSETS-1 loop
            if (twrite and senable(i)) = '1' then senable(i) := '0'; end if;
          end loop;
        end if;
      end if;
    end if;

-- update cache with memory data during read miss

    if read = '1' then
      for i in 0 to DSETS-1 loop ddatainv(i) := mcdo.data; end loop;
    end if;

-- cache write signals

    if twrite = '1' then
      if tdiagwrite = '1' then ctwrite(ddset) := '1';
      else ctwrite(conv_integer(setrepl)) := '1'; end if;
    end if;
    if M_EN then
    if tpwrite = '1' then
      if tdiagwrite = '1' then ctpwrite(ddset) := '1';
      else ctpwrite(conv_integer(setrepl)) := '1'; end if;
    end if;
    end if;
    if dwrite = '1' then
      if ddiagwrite = '1' then cdwrite(ddset) := '1';
      else cdwrite(conv_integer(setrepl)) := '1'; end if;
    end if;
      
    csnoopwe := (others => '0');
    if ((snoopwe and not mcdo.scanen) = '1') then csnoopwe(snoopset) := '1'; end if;

     if (r.flush and twrite) = '1' then   -- flush 
       ctwrite := (others => '1'); wlrr := (others => '0'); wlock := (others => '0');
       if M_EN then
         ctpwrite := (others => '1');
       end if;
       
       -- precise flush, ASI_FLUSH_PAGE & ASI_FLUSH_CTX
       if false then                    -- 
      if M_EN then
        if r.pflush = '1' then
          twrite := '0'; ctwrite := (others => '0');
          for i in DSETS-1 downto 0 loop
            wlrr(i) := dcramov.tag(i)(CTAG_LRRPOS); 
            wlock(i) := dcramov.tag(i)(CTAG_LOCKPOS);
          end loop;
          if r.pflushr = '0' then
            for i in DSETS-1 downto 0 loop
              pftag(OFFSET_HIGH downto OFFSET_LOW) := r.faddr;
              pftag(TAG_HIGH downto TAG_LOW) := dcramov.tag(i)(TAG_HIGH downto TAG_LOW);
              if ((pftag(VA_I_U downto VA_I_D) = r.pflushaddr(VA_I_U downto VA_I_D)) or
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

     end if;

     if r.flush2 = '1' then
      vl.lru := (others => (others => '0'));
    end if;
    
    
-- reset

    if rst = '0' then 
      v.dstate := idle; v.stpend  := '0'; v.req := '0'; v.burst := '0';
      v.read := '0'; v.flush := '0'; v.nomds := '0'; v.holdn := '1';
      v.rndcnt := (others => '0'); v.setrepl := (others => '0');
      v.dsuset := (others => '0');
      v.lrr := '0'; v.lock := '0'; v.flush2 := '1';
      v.cctrl.dcs := "00"; v.cctrl.ics := "00";
      v.cctrl.burst := '0'; v.cctrl.dsnoop := '0';
      v.mmctrl1.e := '0'; v.mmctrl1.nf := '0'; v.mmctrl1.ctx := (others => '0');
      v.mmctrl1.tlbdis := '0';
      v.mmctrl1.pso := '0';
      v.trans_op := '0'; 
      v.flush_op := '0'; 
      v.diag_op := '0';
      v.pflush := '0';
      v.pflushr := '0';
      v.mmctrl1.bar := (others => '0');
    end if;

    if dsnoop = 0 then v.cctrl.dsnoop := '0'; end if;

-- Drive signals

    c <= v; cs <= vs;	ch <= vh; -- register inputs
    cl <= vl;

    -- tag ram inputs
    senable := senable and not scanen; enable := enable and not scanen;
    if mcdo.scanen = '1' then ctpwrite := (others => '0'); end if;

    for i in 0 to DSETS-1 loop
      tag(i)(dlinesize-1 downto 0) := vmask(i);
      tag(i)(TAG_HIGH downto TAG_LOW) := newtag(TAG_HIGH downto TAG_LOW);
      tag(i)(CTAG_LRRPOS) := wlrr(i);
      tag(i)(CTAG_LOCKPOS) := wlock(i);
      ctx(i) := r.mmctrl1.ctx;
      ptag(i)(TAG_HIGH downto TAG_LOW) := newptag(TAG_HIGH downto TAG_LOW);
    end loop;
    dcrami.tag <= tag;
    dcrami.ptag <= ptag;
    dcrami.ctx <= ctx;
    dcrami.tenable   <= enable;
    dcrami.twrite    <= ctwrite;
    dcrami.tpwrite   <= ctpwrite;
    dcrami.flush    <= r.flush;
    dcrami.senable <= senable; --vs.snoop or rs.snoop;
    dcrami.swrite  <= csnoopwe;
    dcrami.saddress(19 downto (OFFSET_HIGH - OFFSET_LOW +1)) <= 
    	zero32(19 downto (OFFSET_HIGH - OFFSET_LOW +1));
    dcrami.saddress(OFFSET_HIGH - OFFSET_LOW downto 0) <= snoopaddr;
    dcrami.stag(31 downto (TAG_HIGH - TAG_LOW +1)) <=
    	zero32(31 downto (TAG_HIGH - TAG_LOW +1));
    dcrami.stag(TAG_HIGH - TAG_LOW downto 0) <= rs.addr(TAG_HIGH downto TAG_LOW);
    dcrami.tdiag <= mcdo.testen & "000";
    dcrami.ddiag <= mcdo.testen & "000";

    -- data ram inputs
    dcrami.denable   <= enable;
    dcrami.address(19 downto (OFFSET_HIGH - LINE_LOW + 1)) <= zero32(19 downto (OFFSET_HIGH - LINE_LOW + 1));
    dcrami.address(OFFSET_HIGH - LINE_LOW downto 0) <= taddr;
    dcrami.data <= ddatainv;
    dcrami.dwrite    <= cdwrite;

    -- memory controller inputs
    mcdi.address  <= r.wb.addr;
    mcdi.data     <= r.wb.data1;
    mcdi.burst    <= r.burst;
    mcdi.size     <= r.wb.size;
    mcdi.read     <= r.wb.read;
    mcdi.asi      <= r.wb.asi;
    mcdi.lock     <= r.wb.lock;
    mcdi.req      <= r.req;
    mcdi.cache    <= orv(r.cctrl.dcs);

    --mcdi.flush    <= r.flush;

    -- diagnostic instruction cache access
    dco.icdiag.flush  <= iflush;-- or mcdo.iflush;
    dco.icdiag.pflush <= pflush;
    dco.icdiag.pflushaddr <= pflushaddr;
    dco.icdiag.pflushtyp <= pflushtyp;
    dco.icdiag.read   <= read;
    dco.icdiag.tag    <= (not r.asi(0));-- and (not r.asi(4));
    dco.icdiag.ctx    <= r.asi(4); --ASI_ICTX "10101"
    dco.icdiag.addr   <= r.xaddress;
    dco.icdiag.enable <= r.icenable;
    dco.icdiag.cctrl <= r.cctrl;
    dco.icdiag.scanen  <= mcdo.scanen;
   
    -- IU data cache inputs
    dco.data  <= rdatav;
    dco.mexc  <= mexc;
    dco.set   <= conv_std_logic_vector(set, 2);
    dco.hold  <= r.holdn;
    dco.mds   <= mds;
    dco.werr  <= mcdo.werr;
    dco.idle  <= sidle and not r.stpend;
    dco.scanen  <= mcdo.scanen;
    dco.testen  <= mcdo.testen;
    
    -- MMU
    mmudci.trans_op <= mmudci_trans_op;    
    mmudci.transdata.data <= mmudci_transdata_data; --r.vaddr;
    mmudci.transdata.su <= mmudci_su;
    mmudci.transdata.read <= mmudci_read;
    mmudci.transdata.isid <= id_dcache;
    mmudci.transdata.wb_data <= dci.maddress;
    
    mmudci.flush_op <= mmudci_flush_op;
    mmudci.wb_op <= mmudci_wb_op;
    mmudci.diag_op <= mmudci_diag_op;
    mmudci.fsread <= mmudci_fsread;
    mmudci.mmctrl1 <= r.mmctrl1;

  end process;

-- Local registers

    reg1 : process(clk)
    begin if rising_edge(clk ) then r <= c; end if; end process;
  
    sn2 : if DSNOOP2 /= 0 generate
      reg2 : process(sclk)
      begin if rising_edge(sclk ) then rs <= cs; end if; end process;
    end generate;
  
    nosn2 : if DSNOOP2 = 0 generate
      rs.snoop <= '0'; rs.writebp <= (others => '0');
      rs.addr <= (others => '0'); rs.readbpx <= (others => '0');
    end generate;
  
    sn3 : if DSNOOP2 = 2 generate
      reg3 : process(sclk)
      begin if rising_edge(sclk ) then rh <= ch; end if; end process;
    end generate;
    sn3no : if DSNOOP2 /= 2 generate
      rh.hit <= (others => (others => '0'));
      rh.taddr <= (others => '0');
      rh.set <= (others => '0');
    end generate;

    reg2 : if (DSETS>1) and (DCREPLACE = lru) generate
      reg2 : process(clk)
      begin if rising_edge(clk ) then rl <= cl; end if; end process;
    end generate;   

    noreg2 : if (DSETS = 1) or (drepl /= lru) generate
      rl.write <= '0'; rl.waddr <= (others => '0');
      rl.set <= (others => '0'); rl.lru <= (others => (others => '0'));
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

