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
-- Author:      Jiri Gaisler - Gaisler Research
-- Modified:    Edvin Catovic - Gaisler Research
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

entity dcache is
  generic (
    dsu       : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 0;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6 := 0;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    ilram      : integer range 0 to 1 := 0;
    ilramstart : integer range 0 to 255 := 16#8e#;
    memtech    : integer range 0 to NTECH := 0;
    cached     : integer := 0);
  port (
    rst : in  std_ulogic;
    clk : in  std_ulogic;
    dci : in  dcache_in_type;
    dco : out dcache_out_type;
    ico : in  icache_out_type;
    mcdi : out memory_dc_in_type;
    mcdo : in  memory_dc_out_type;
    ahbsi : in  ahb_slv_in_type;
    dcrami : out dcram_in_type;
    dcramo : in  dcram_out_type;
    fpuholdn : in  std_ulogic;
    sclk : in std_ulogic
);
end; 

architecture rtl of dcache is


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
constant LOCAL_RAM_START : std_logic_vector(7 downto 0) := conv_std_logic_vector(dlramstart, 8);
constant ILRAM_START : std_logic_vector(7 downto 0) := conv_std_logic_vector(ilramstart, 8);
constant DREAD_FAST  : boolean := false;
constant DWRITE_FAST  : boolean := false;
constant DEST_RW      : boolean := (syncram_dp_dest_rw_collision(memtech) = 1);

type rdatatype is (dtag, ddata, dddata, icache, memory, sysr);  -- sources during cache read
type vmasktype is (clearone, clearall, merge, tnew);	-- valid bits operation

type valid_type is array (0 to DSETS-1) of std_logic_vector(dlinesize - 1 downto 0);

type write_buffer_type is record			-- write buffer 
  addr, data1, data2 : std_logic_vector(31 downto 0);
  size : std_logic_vector(1 downto 0);
  asi  : std_logic_vector(3 downto 0);
  read : std_ulogic;
  lock : std_ulogic;
end record;

type dcache_control_type is record			-- all registers
  read : std_ulogic;					-- access direction
  size : std_logic_vector(1 downto 0);			-- access size
  req, burst, holdn, nomds, stpend  : std_ulogic;
  xaddress : std_logic_vector(31 downto 0);		-- common address buffer
  faddr : std_logic_vector(DOFFSET_BITS - 1 downto 0);	-- flush address
  valid : valid_type; --std_logic_vector(dlinesize - 1 downto 0);	-- registered valid bits
  dstate : std_logic_vector(2 downto 0);			-- FSM vector
  hit : std_ulogic;
  flush		: std_ulogic;				-- flush in progress
  flush2	: std_ulogic;				-- flush in progress
  mexc 		: std_ulogic;				-- latched mexc
  wb 		: write_buffer_type;			-- write buffer
  asi  		: std_logic_vector(3 downto 0);
  icenable	: std_ulogic;				-- icache diag access
  rndcnt        : std_logic_vector(log2x(DSETS)-1 downto 0); -- replace counter
  setrepl       : std_logic_vector(log2x(DSETS)-1 downto 0); -- set to replace
  lrr           : std_ulogic;            
  dsuset        : std_logic_vector(log2x(DSETS)-1 downto 0);
  lock          : std_ulogic;
  lramrd : std_ulogic;
  ilramen : std_ulogic;
  cctrl		: cctrltype;
  cctrlwr       : std_ulogic;
  forcemiss 	: std_ulogic;
end record;

type snoop_reg_type is record			-- snoop control registers
  snoop   : std_ulogic;				-- snoop access to tags
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
  write : std_ulogic;
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

  dctrl : process(rst, r, rs, rh, rl, dci, mcdo, ico, dcramo, ahbsi, fpuholdn)
  variable dcramov : dcram_out_type;
  variable rdatasel : rdatatype;
  variable maddress : std_logic_vector(31 downto 0);
  variable maddrlow : std_logic_vector(1 downto 0);
  variable edata : std_logic_vector(31 downto 0);
  variable size : std_logic_vector(1 downto 0);
  variable read : std_ulogic;
  variable twrite, tdiagwrite, ddiagwrite, dwrite : std_ulogic;
  variable taddr : std_logic_vector(OFFSET_HIGH  downto LINE_LOW); -- tag address
  variable newtag : std_logic_vector(TAG_HIGH  downto TAG_LOW); -- new tag
  variable align_data : std_logic_vector(31 downto 0); -- aligned data
--  variable ddatain : std_logic_vector(31 downto 0);
  variable ddatainv, rdatav, align_datav : cdatatype;

  variable vmaskraw : std_logic_vector((dlinesize -1) downto 0);
  variable vmask : valid_type; --std_logic_vector((dlinesize -1) downto 0);
  variable ivalid : std_logic_vector((dlinesize -1) downto 0);
  variable vmaskdbl : std_logic_vector((dlinesize/2 -1) downto 0);
  variable enable, senable, scanen : std_logic_vector(0 to 3);
  variable mds : std_ulogic;
  variable mexc : std_ulogic;
  variable hit, valid, validraw, forcemiss : std_ulogic;
  variable flush    : std_ulogic;
  variable iflush   : std_ulogic;
  variable v : dcache_control_type;
  variable eholdn : std_ulogic;				-- external hold
  variable snoopwe  : std_ulogic;
  variable hcache   : std_ulogic;
  variable lramcs, lramen, lramrd, lramwr, ilramen  : std_ulogic;
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
  variable wlrr : std_logic_vector(0 to 3);
  variable vl : lru_reg_type;
  variable diagset : std_logic_vector(TAG_LOW + SETBITS -1 downto TAG_LOW);
  variable lock : std_logic_vector(0 to DSETS-1);
  variable wlock : std_logic_vector(0 to MAXSETS-1);
  variable snoophit : std_logic_vector(0 to DSETS-1);
  variable snoopval : std_ulogic;
  variable snoopset2 : integer range 0 to DSETS-1;
  variable laddr : std_logic_vector(31  downto 0); -- local ram addr
  variable tag : cdatatype; --std_logic_vector(31  downto 0);
  variable rlramrd : std_ulogic;
  variable readbp : std_logic_vector(0 to DSETS-1);
  variable rbphit, sidle : std_logic;
  
  begin

-- init local variables

    v := r; vs := rs; vh := rh; dcramov := dcramo; vl := rl;
    vl.write := '0'; lramen := '0'; lramrd := '0'; lramwr := '0'; 
    lramcs := '0'; laddr := (others => '0'); v.cctrlwr := '0';
    ilramen := '0'; sidle := '0';
    
    if ((dci.eenaddr or dci.enaddr) = '1') or (r.dstate /= "000") or 
       ((dsu = 1) and (dci.dsuen = '1')) or (r.flush = '1') or
	(is_fpga(memtech) = 1)
    then
      enable := (others => '1');
    else enable := (others => '0'); end if;

    mds := '1'; dwrite := '0'; twrite := '0'; 
    ddiagwrite := '0'; tdiagwrite := '0'; v.holdn := '1'; mexc := '0';
    flush := '0'; v.icenable := '0'; iflush := '0';
    eholdn := ico.hold and fpuholdn; ddset := 0; vset := (others => '0');
    vs.snoop := '0'; vs.writebp := (others => '0'); snoopwe := '0';
    snoopaddr := ahbsi.haddr(OFFSET_HIGH downto OFFSET_LOW);
    hcache := '0'; 
    validv := (others => '0'); validrawv := (others => '0');
    hitv := (others => '0'); ivalid := (others => '0');
    if (dlram = 1) then rlramrd := r.lramrd; else rlramrd := '0'; end if;
    ddatainv := (others => (others => '0')); tag := (others => (others => '0'));
    v.flush2 := r.flush;
    rdatasel := ddata;	-- read data from cache as default
    vs.readbpx := (others => '0'); rbphit := '0';
    senable := (others => '0'); scanen := (others => mcdo.scanen);

    set := 0; snoopset := 0;  csnoopwe := (others => '0');
    ctwrite := (others => '0'); cdwrite := (others => '0');
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
    if dsetlock = 1 then 
      for i in 0 to DSETS-1 loop lock(i) := dcramov.tag(i)(CTAG_LOCKPOS); end loop;
    end if;
    
-- AHB snoop handling

    if (DSNOOP /= 0) then

      -- snoop on NONSEQ or SEQ and first word in cache line
      -- do not snoop during own transfers or during cache flush
      if (ahbsi.hready and ahbsi.hwrite and not mcdo.bg) = '1' and
         ((ahbsi.htrans = HTRANS_NONSEQ) or 
	    ((ahbsi.htrans = HTRANS_SEQ) and 
	     (ahbsi.haddr(LINE_HIGH downto LINE_LOW) = LINE_ZERO)))
      then
	vs.snoop := r.cctrl.dsnoop; -- and hcache;
        vs.addr := ahbsi.haddr(TAG_HIGH downto OFFSET_LOW); 
      end if;

      for i in 0 to DSETS-1 loop senable(i) := vs.snoop or rs.snoop; end loop;
        
      readbp := (others => '0');
      if (r.xaddress(TAG_HIGH downto OFFSET_LOW) = rs.addr(TAG_HIGH downto OFFSET_LOW)) then rbphit := '1'; end if;    
      for i in 0 to DSETS-1 loop
        if (rs.readbpx(i) and rbphit) = '1' then readbp(i) := '1'; end if;
      end loop;
        
      -- clear valid bits on snoop hit (or set hit bits)
      for i in DSETS-1 downto 0 loop
        if ((rs.snoop and (not mcdo.ba) and not r.flush) = '1') 
          and ((dcramov.stag(i)(TAG_HIGH downto TAG_LOW) = rs.addr(TAG_HIGH downto TAG_LOW)) or (readbp(i) = '1'))
        then
          if DSNOOP = 2 then
            vh.hit(conv_integer(rs.addr(OFFSET_HIGH downto OFFSET_LOW)))(i) := '1';
--             vh.set := std_logic_vector(conv_unsigned(i, SETBITS));
          else
            snoopaddr := rs.addr(OFFSET_HIGH downto OFFSET_LOW);
            snoopwe := '1'; snoopset := i;        
          end if;
        end if;
      -- bypass tag data on read/write contention
        if (DSNOOP /= 2) and (rs.writebp(i) = '1') then 
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
      maddress := r.xaddress(31 downto 0);
      read := r.read; size := r.size; edata := dci.maddress;
    else
      maddress := dci.maddress(31 downto 0);
      read := dci.read; size := dci.size; edata := dci.edata;
    end if;

    newtag := dci.maddress(TAG_HIGH downto TAG_LOW);
    vl.waddr := maddress(OFFSET_HIGH downto OFFSET_LOW);  -- lru write address

-- generate cache hit and valid bits

    if cached /= 0 then hcache := ctbl(conv_integer(dci.maddress(31 downto 28)));
    else hcache := '1'; end if;

    forcemiss := not dci.asi(3); hit := '0'; set := 0; snoophit := (others => '0');
    snoopval := '1';
    for i in DSETS-1 downto 0 loop
      if DSNOOP = 2 then
        snoophit(i) := rh.hit(conv_integer(rh.taddr))(i);
      end if;
      if (dcramov.tag(i)(TAG_HIGH downto TAG_LOW) = dci.maddress(TAG_HIGH downto TAG_LOW)) 
      then hitv(i) := hcache; end if; 
      validrawv(i) := hitv(i) and (not r.flush) and (not r.flush2) and (not snoophit(i)) and
	genmux(dci.maddress(LINE_HIGH downto LINE_LOW), dcramov.tag(i)(dlinesize-1 downto 0));
      validv(i) :=  validrawv(i);
      snoopval := snoopval and not snoophit(i);
    end loop;

    hit := orv(hitv) and not r.flush and not r.flush2; validraw := orv(validrawv);
    valid := orv(validv);
    if DSETS > 1 then 
      for i in DSETS-1 downto 0 loop 
        if (hitv(i) = '1') then
	  vset := conv_std_logic_vector(i, SETBITS);
        end if;
      end loop;
      set := conv_integer(vset);
      if rlramrd = '1' then set := 1; end if;
    else set := 0; end if;

    if (dci.dsuen = '1') then diagset := r.xaddress(TAG_LOW+SETBITS-1 downto TAG_LOW);                                                
    else diagset := maddress(TAG_LOW + SETBITS - 1 downto TAG_LOW); end if;
    case DSETS is
    when 1 => ddset := 0;
    when 3 => if conv_integer(diagset) < 3 then ddset := conv_integer(diagset); end if;
    when others => ddset := conv_integer(diagset); 
    end case;

    if ((r.holdn and dci.enaddr) = '1')  and (r.dstate = "000") then
        v.hit := hit; v.xaddress := dci.maddress;
	v.read := dci.read; v.size := dci.size;
	v.asi := dci.asi(3 downto 0);
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
    if (mcdo.grant and not r.wb.read and r.req) = '1' then v.wb.lock := '0'; end if;
    
    if (dlram = 1) then
      if ((r.holdn) = '0') or ((dsu = 1) and (dci.dsuen = '1')) then
        laddr := r.xaddress;
      elsif ((dci.enaddr and not dci.read) = '1') or (eholdn = '0') then
        laddr := dci.maddress;
      else laddr := dci.eaddress; end if;
      if  (dci.enaddr = '1') and (dci.maddress(31 downto 24) = LOCAL_RAM_START)
      then lramen := '1'; end if;
      if  ((laddr(31 downto 24) = LOCAL_RAM_START)) or ((dci.dsuen = '1') and (dci.asi(4 downto 1) = "0101"))
      then lramcs := '1'; end if;      
    end if;
    
    if (ilram = 1) then 
      if  (dci.enaddr = '1') and (dci.maddress(31 downto 24) = ILRAM_START)  then ilramen := '1'; end if;
    end if;

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
    
-- main Dcache state machine

    case r.dstate is
    when "000" =>			-- Idle state
      v.nomds := r.nomds and not eholdn; 
      v.forcemiss := forcemiss; sidle := '1';
      if (snoopval = '1') then 
	for i in 0 to DSETS-1 loop
          v.valid(i) := dcramov.tag(i)(dlinesize-1 downto 0);
	end loop;
      else v.valid := (others => (others => '0')); end if;
      if (r.stpend  = '0') or ((mcdo.ready and not r.req)= '1') then -- wait for store queue
	v.wb.addr := dci.maddress; v.wb.size := dci.size; 
	v.wb.read := dci.read; v.wb.data1 := dci.edata; v.wb.lock := dci.lock;
	v.wb.asi := dci.asi(3 downto 0); 
      end if;
      if (eholdn and (not r.nomds)) = '1' then -- avoid false path through nullify
	case dci.asi(4 downto 0) is
 	when ASI_SYSR => rdatasel := sysr;	
	when ASI_DTAG => rdatasel := dtag;
	when ASI_DDATA => rdatasel := dddata;
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
	when ASI_ITAG | ASI_IDATA =>		-- Read/write Icache tags
	  if ico.flush = '1' then mexc := '1';
          else v.dstate := "101"; v.holdn := dci.dsuen; end if;
        when ASI_UINST | ASI_SINST =>
          if (ilram = 1) then v.dstate := "101"; v.ilramen := '1'; end if;
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
	when others =>
--          setrepl := std_logic_vector(conv_unsigned(set, SETBITS));
	  if dci.read = '1' then	-- read access
            if (dlram = 1) and (lramen = '1') then
	      lramrd := '1';
            elsif (ilram = 1) and (ilramen = '1') then
              if (ico.flush = '1') or (dci.size /= "10") then mexc := '1';
              else v.dstate := "101"; v.holdn := dci.dsuen; v.ilramen := '1'; end if;              
	    elsif dci.dsuen = '0' then
              if (not ((r.cctrl.dcs(0) = '1') and ((hit and valid and not forcemiss) = '1')))
              then	-- read miss
                v.holdn := '0'; v.dstate := "001"; 
                if ((r.stpend  = '0') or ((mcdo.ready and not r.req) = '1'))
                then	-- wait for store queue
                  v.req := '1'; 
                  v.burst := dci.size(1) and dci.size(0) and not dci.maddress(2);
                end if;
              else       -- read hit
                if (DSETS > 1) and (drepl = lru) then vl.write := '1'; end if;
              end if;
            end if;
            
	  else			-- write access
            if (dlram = 1) and (lramen = '1') then
              lramwr := '1';
	      if (dci.size = "11") then -- double store
                v.dstate := "100"; v.xaddress(2) := '1';
              end if; 
            elsif (ilram = 1) and (ilramen = '1') then
              if (ico.flush = '1') or (dci.size /= "10") then mexc := '1';
              else v.dstate := "101"; v.holdn := dci.dsuen; v.ilramen := '1'; end if;
            elsif dci.dsuen = '0' then
              if (r.stpend  = '0') or ((mcdo.ready and not r.req)= '1') then	-- wait for store queue
                v.req := '1'; v.stpend := '1'; 
                v.burst := dci.size(1) and dci.size(0);
                if (dci.size = "11") then v.dstate := "100"; end if; -- double store
              else		-- wait for store queue
                v.dstate := "110"; v.holdn := '0';
              end if;
--	    if (r.cctrl.dcs(0) = '1') and ((hit and (dci.size(1) or validraw)) = '1') 
              if (r.cctrl.dcs(0) = '1') and (((hit and dci.size(1)) or validraw) = '1') 
              then  -- write hit

                twrite := '1'; dwrite := '1';
                if (DSETS > 1) and (drepl = lru) then vl.write := '1'; end if;
                setrepl := conv_std_logic_vector(set, SETBITS);
                if DSNOOP /= 0 then
                  if ((dci.enaddr and not dci.read) = '1') or (eholdn = '0')
                  then v.xaddress := dci.maddress; else v.xaddress := dci.eaddress; end if;
                  vs.readbpx(set) := '1';
                end if;                                
              end if;
              if (dci.size = "11") then v.xaddress(2) := '1'; end if;
            end if;
	  end if;

          if (DSETS > 1) then
    	    vl.set := conv_std_logic_vector(set, SETBITS);
            v.setrepl := conv_std_logic_vector(set, SETBITS);
            if ((not hit) and (not r.flush)) = '1' then
              case drepl is
              when rnd =>
                if dsetlock = 1 then 
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
                if dsetlock = 1 then 
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

            if (dsetlock = 1) then
              if (hit and lock(set)) = '1' then v.lock := '1';
              else v.lock := '0'; end if;
            end if;
              
          end if;

        end case;
      end if;
    when "001" => 		-- read miss, wait for memory data
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW);
      newtag := r.xaddress(TAG_HIGH downto TAG_LOW);
      v.nomds := r.nomds and not eholdn;
      v.holdn := v.nomds; rdatasel := memory;
      for i in 0 to DSETS-1 loop wlock(i) := r.lock; end loop;
      for i in 0 to 3 loop wlrr(i) := r.lrr; end loop;
      if r.stpend = '0' then

        if mcdo.ready = '1' then
          mds := r.holdn or r.nomds; v.xaddress(2) := '1'; v.holdn := '1';
          if (r.cctrl.dcs = "01") then 
	    v.hit := mcdo.cache and r.hit; twrite := v.hit;
          elsif (r.cctrl.dcs(1) = '1') then 
	    v.hit := mcdo.cache and (r.hit or (r.asi(3) and not r.asi(2))); twrite := v.hit;
	  end if; 
          dwrite := twrite; rdatasel := memory;
          mexc := mcdo.mexc;

	  if r.req = '0' then

	    if (((dci.enaddr and not mds) = '1') or 
              ((dci.eenaddr and mds and eholdn) = '1')) and ((r.cctrl.dcs(0) = '1') or (dlram = 1)) then
	      v.dstate := "011"; v.holdn := '0';
	    else v.dstate := "000"; end if;
	  else v.nomds := '1'; end if;
        end if;
	v.mexc := mcdo.mexc; v.wb.data2 := mcdo.data;
      else
	if ((mcdo.ready and not r.req) = '1') then	-- wait for store queue
	  v.burst := r.size(1) and r.size(0) and not r.xaddress(2);
	  v.wb.addr := r.xaddress; v.wb.size := r.size; 
	  v.wb.read := r.read; v.wb.data1 := dci.maddress; v.req := '1'; 
	  v.wb.lock := dci.lock; v.wb.asi := r.asi; 
        end if;
      end if;
      if DSNOOP /= 0 then vs.readbpx(conv_integer(setrepl)) := '1'; end if;      
    when "011" =>		-- return from read miss with load pending
      taddr := dci.maddress(OFFSET_HIGH downto LINE_LOW);
      if (dlram = 1) then
        laddr := dci.maddress;
        if laddr(31 downto 24) = LOCAL_RAM_START then lramcs := '1'; end if;
      end if;
      v.dstate := "000"; 
    when "100" => 		-- second part of double store cycle
      v.dstate := "000";
      edata := dci.edata;  -- needed for STD store hit
      taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); 
      if (dlram = 1) and (rlramrd = '1') then
	laddr := r.xaddress; lramwr := '1';
      else
        if (r.cctrl.dcs(0) = '1') and (r.hit = '1') then dwrite := '1'; end if;
        v.wb.data2 := dci.edata; 
      end if;

    when "101" =>		-- icache diag and inst local ram access 
      rdatasel := icache; v.icenable := '1'; v.holdn := dci.dsuen;
      if  ico.diagrdy = '1' then
	v.dstate := "011"; v.icenable := '0'; mds := not r.read; v.ilramen := '0';
      end if;

    when "110" => 		-- wait for store buffer to empty (store access)
      edata := dci.edata;  -- needed for STD store hit

      if ((mcdo.ready and not r.req) = '1') then	-- store queue emptied

	if (r.cctrl.dcs(0) = '1') and (r.hit = '1') and (r.size = "11") then  -- write hit
          taddr := r.xaddress(OFFSET_HIGH downto LINE_LOW); dwrite := '1';
	end if;
        v.dstate := "000"; 

	v.req := '1'; v.burst := r.size(1) and r.size(0); v.stpend := '1';

	v.wb.addr := r.xaddress; v.wb.size := r.size;
	v.wb.read := r.read; v.wb.data1 := dci.maddress;
	v.wb.lock := dci.lock; v.wb.data2 := dci.edata;
	v.wb.asi := r.asi; 
	if r.size = "11" then v.wb.addr(2) := '0'; end if;
      else  -- hold cpu until buffer empty
        v.holdn := '0';
      end if;
    when others => v.dstate := "000";
    end case;

    if (dlram = 1) then v.lramrd := lramcs; end if; -- read local ram data 
    
-- select data to return on read access
-- align if byte/half word read from cache or memory.

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
      when ASI_DDATA =>
        ddiagwrite := not dci.eenaddr and dci.enaddr and dci.write;
        dwrite := not dci.eenaddr and dci.enaddr and dci.write;
        rdatasel := dddata;
       when ASI_UDATA | ASI_SDATA  =>
         lramwr := not dci.eenaddr and dci.enaddr and dci.write;
--       when ASI_UINST | ASI_SINST =>        
      when others =>
      end case;
    end if;
    
    rdatav := (others => (others => '0'));
    align_data := (others => '0'); align_datav := (others => (others => '0'));
    maddrlow := maddress(1 downto 0); -- stupid Synopsys VSS bug ...

    case rdatasel is
    when dddata => 
      rdatav := dcramov.data;
      if dci.dsuen = '1' then set := conv_integer(r.dsuset);
      else set := ddset; end if; 
    when dtag => 
      rdatav := dcramov.tag; 
      if dci.dsuen = '1' then set := conv_integer(r.dsuset);
      else set := ddset; end if; 
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
		dsnoop, dlram, dlramsize, dlramstart, 0);
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
--      ddatain := ddatainv(set);

-- handle double load with pipeline hold

    if (r.dstate = "000") and (r.nomds = '1') then
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
      for i in 0 to (dlinesize - 1) loop vmaskraw(i) := vmaskdbl(i/2); end loop;
    else
      vmaskraw := decode(maddress(LINE_HIGH downto LINE_LOW));
    end if;

    vmask := (others => vmaskraw);
    if r.hit = '1' then 
      for i in 0 to DSETS-1 loop vmask(i) := r.valid(i) or vmaskraw; end loop;
    end if;
    if r.dstate = "000" then 
--      vmask := dcramov.dtramout(set).valid or vmaskraw;
      for i in 0 to DSETS-1 loop
        vmask(i) := dcramov.tag(i)(dlinesize-1 downto 0) or vmaskraw;
      end loop;
    else
      for i in 0 to DSETS-1 loop tag(i)(dlinesize-1 downto 0) := vmask(i); end loop;
    end if;

    if (mcdo.mexc or r.flush) = '1' then twrite := '0'; dwrite := '0'; end if;
    if twrite = '1' then
      v.valid := vmask;
      if (DSETS>1) and (drepl = lru) and (tdiagwrite = '0') then
        vl.write := '1'; vl.set := setrepl;
      end if;
    end if;

    if (DSETS>1) and (drepl = lru) and (rl.write = '1') then
      vl.lru(conv_integer(rl.waddr)) :=
        lru_calc(rl.lru(conv_integer(rl.waddr)), conv_integer(rl.set));
    end if;

    if tdiagwrite = '1' then -- diagnostic tag write
      if (dsu = 1) and (dci.dsuen = '1') then
        vmask := (others => dci.maddress(dlinesize - 1 downto 0));
      else
        vmask := (others => dci.edata(dlinesize - 1 downto 0));
        newtag(TAG_HIGH downto TAG_LOW) := dci.edata(TAG_HIGH downto TAG_LOW);
        for i in 0 to 3 loop wlrr(i)  := dci.edata(CTAG_LRRPOS); end loop;
        for i in 0 to DSETS-1 loop wlock(i) := dci.edata(CTAG_LOCKPOS); end loop;
      end if;
    end if;

-- cache flush

    if ((dci.flush or flush) = '1') and (dcen /= 0) then
      v.flush := '1'; v.faddr := (others => '0');
    end if;

    if (r.flush = '1') and (dcen /= 0) then
      twrite := '1'; vmask := (others => (others => '0')); 
      v.faddr := r.faddr +1; newtag(TAG_HIGH downto TAG_LOW) := (others => '0');
      taddr(OFFSET_HIGH downto OFFSET_LOW) := r.faddr;
      wlrr := (others => '0');
      if (r.faddr(DOFFSET_BITS -1) and not v.faddr(DOFFSET_BITS -1)) = '1' then
	v.flush := '0';
      end if;
      if DSNOOP = 2 then
        vh.hit(conv_integer(taddr(OFFSET_HIGH downto OFFSET_LOW))) := (others => '0');
      end if;
    end if;

-- AHB snoop handling (2), bypass write data on read/write contention

    if DSNOOP /= 0 then
      if tdiagwrite = '1' then snoopset2 := ddset; 
      else snoopset2 := conv_integer(setrepl); end if;
      if DSNOOP = 2 then
        vh.taddr := taddr(OFFSET_HIGH downto OFFSET_LOW);
        vh.set := conv_std_logic_vector(set, SETBITS);
	if (twrite = '1') and (r.dstate /= "000") then
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
            if (snoopwe = '1') and (conv_integer(setrepl) = snoopset) then  -- avoid write/write contention
              twrite := '0';
              if DEST_RW then enable(snoopset) := '0'; end if;
            end if; 
	  end if;
	end if;
      end if;
      if (r.dstate = "001") and ((rbphit and rs.snoop) = '1') then v.hit := '0'; end if;
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
    if dwrite = '1' then
      if ddiagwrite = '1' then cdwrite(ddset) := '1';
      else cdwrite(conv_integer(setrepl)) := '1'; end if;
    end if;
      
    csnoopwe := (others => '0'); 
    if ((snoopwe and not mcdo.scanen) = '1') then csnoopwe(snoopset) := '1'; end if;

     if (r.flush and twrite) = '1' then   -- flush 
       ctwrite := (others => '1'); wlrr := (others => '0'); wlock := (others => '0');
     end if;

     if r.flush2 = '1' then
      vl.lru := (others => (others => '0'));
    end if;


-- reset

    if rst = '0' then 
      v.dstate := "000"; v.stpend  := '0'; v.req := '0'; v.burst := '0';
      v.read := '0'; v.flush := '0'; v.nomds := '0'; v.holdn := '1';
      v.rndcnt := (others => '0'); v.setrepl := (others => '0');
      v.dsuset := (others => '0'); v.flush2 := '1';
      v.lrr := '0'; v.lock := '0'; v.ilramen := '0';
      v.cctrl.dcs := "00"; v.cctrl.ics := "00";
      v.cctrl.burst := '0'; v.cctrl.dsnoop := '0'; 
    end if;

    if dsnoop = 0 then v.cctrl.dsnoop := '0'; end if;

-- Drive signals

    c <= v; cs <= vs;	ch <= vh; -- register inputs
    cl <= vl;

    
    -- tag ram inputs
    senable := senable and not scanen; enable := enable and not scanen;
    if mcdo.scanen = '1' then ctwrite := (others => '0'); end if;

    for i in 0 to DSETS-1 loop
      tag(i)(dlinesize-1 downto 0) := vmask(i);
      tag(i)(TAG_HIGH downto TAG_LOW) := newtag(TAG_HIGH downto TAG_LOW);
      tag(i)(CTAG_LRRPOS) := wlrr(i);
      tag(i)(CTAG_LOCKPOS) := wlock(i);
    end loop;
    dcrami.tag <= tag;
    dcrami.tenable   <= enable;
    dcrami.twrite    <= ctwrite;
    dcrami.flush    <= r.flush;
    dcrami.senable <= senable;--vs.snoop or rs.snoop;
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
    dcrami.ldramin.address(23 downto 2) <= laddr(23 downto 2);
    dcrami.ldramin.enable <= (lramcs or lramwr) and not mcdo.scanen;
    dcrami.ldramin.read   <= rlramrd;
    dcrami.ldramin.write  <= lramwr;
    dcrami.dpar <= (others => (others => '0'));
    dcrami.tpar <= (others => (others => '0'));
    dcrami.ctx <= (others => (others => '0'));
    dcrami.ptag <= (others => (others => '0'));
    dcrami.tpwrite <= (others => '0');

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

    -- diagnostic instruction cache access
    dco.icdiag.flush  <= iflush;
    dco.icdiag.read   <= read;
    dco.icdiag.tag    <= not r.asi(0);
    dco.icdiag.addr   <= r.xaddress;
    dco.icdiag.enable <= r.icenable;
    dco.icdiag.ilramen <= r.ilramen;    
    dco.icdiag.cctrl <= r.cctrl;
    dco.icdiag.scanen  <= mcdo.scanen;
    dco.icdiag.pflush <= '0';
    dco.icdiag.ctx <= '0';
    dco.icdiag.ilock <= (others => '0');
    dco.icdiag.pflushaddr <= (others => '0');
 
    -- IU data cache inputs
    dco.data <= rdatav;
    dco.mexc <= mexc;
    dco.set  <= conv_std_logic_vector(set, 2);
    dco.hold <= r.holdn;
    dco.mds  <= mds;
    dco.werr <= mcdo.werr;
    dco.idle <= sidle and not r.stpend;
    dco.scanen <= mcdo.scanen;
    dco.testen <= mcdo.testen;

  end process;

-- Local registers

    reg1 : process(clk)
    begin
      if rising_edge(clk) then
	r <= c;
	if rst = '0' then r.wb.lock <= '0'; end if;
	--sync reset for wb.lock  must be generated here to make
	--gate level simulations possible with some synthesis tools
      end if; 
    end process;

    sn2 : if DSNOOP /= 0 generate
      reg2 : process(sclk)
      begin if rising_edge(sclk ) then rs <= cs; end if; end process;
    end generate;

    nosn2 : if DSNOOP = 0 generate
      rs.snoop <= '0'; rs.writebp <= (others => '0');
      rs.addr <= (others => '0'); rs.readbpx <= (others => '0');
    end generate;

    sn3 : if DSNOOP = 2 generate
      reg3 : process(sclk)
      begin if rising_edge(sclk ) then rh <= ch; end if; end process;
    end generate;

    nosn3 : if DSNOOP /= 2 generate
      rh.hit <=  (others => (others => '0')); rh.taddr <=  (others => '0');
      rh.set <=  (others => '0');
    end generate;

    reg2 : if (DSETS>1) and (drepl = lru) generate
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
    assert not ((DSETS > 2) and (drepl = lrr)) report
	"Wrong data cache configuration detected: LRR replacement requires 2 sets"
    severity failure;
    wait;
  end process;
-- pragma translate_on

end ;

