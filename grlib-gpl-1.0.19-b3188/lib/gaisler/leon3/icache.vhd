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
-- Entity:      icache
-- File:        icache.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Modified:    Edvin Catovic - Gaisler Research
-- Description: This unit implements the instruction cache controller.
------------------------------------------------------------------------------  

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.libiu.all;
use gaisler.libcache.all;

entity icache is
  generic (
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 0;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    lram      : integer range 0 to 1 := 0;
    lramsize  : integer range 1 to 512 := 1;
    lramstart : integer range 0 to 255 := 16#8e#);    
  port (
    rst : in  std_ulogic;
    clk : in  std_ulogic;
    ici : in  icache_in_type;
    ico : out icache_out_type;
    dci : in  dcache_in_type;
    dco : in  dcache_out_type;
    mcii : out memory_ic_in_type;
    mcio : in  memory_ic_out_type;
    icrami : out icram_in_type;
    icramo : in  icram_out_type;
    fpuholdn : in  std_ulogic
);
end; 

architecture rtl of icache is

constant ILINE_BITS   : integer := log2(ilinesize);
constant IOFFSET_BITS : integer := 8 +log2(isetsize) - ILINE_BITS;
constant TAG_LOW      : integer := IOFFSET_BITS + ILINE_BITS + 2;
constant OFFSET_HIGH  : integer := TAG_LOW - 1;
constant OFFSET_LOW   : integer := ILINE_BITS + 2;
constant LINE_HIGH    : integer := OFFSET_LOW - 1;
constant LINE_LOW     : integer := 2;
constant LRR_BIT      : integer := TAG_HIGH + 1;

constant lline : std_logic_vector((ILINE_BITS -1) downto 0) := (others=>'1');
constant fline : std_logic_vector((ILINE_BITS -1) downto 0) := (others=>'0');

constant SETBITS : integer := log2x(ISETS); 
constant ILRUBITS  : integer := lru_table(ISETS);
constant LRAM_START : std_logic_vector(7 downto 0) := conv_std_logic_vector(lramstart, 8);
constant LRAM_BITS : integer := log2(lramsize) + 10;
constant LRAMCS_EN  : boolean := false;
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
  
  if isetlock = 1 then 
    unlocked := ISETS-1;
    for i in ISETS-1 downto 0 loop
      if lock(i) = '0' then unlocked := i; end if;
    end loop;
  end if;
    
  case ISETS is
  when 2 =>
    if isetlock = 1 then
      if lock(0) = '1' then xset(0) := '1'; else xset(0) := xlru(0); end if;
    else xset(0) := xlru(0); end if;
  when 3 =>
    if isetlock = 1 then
      xset := conv_std_logic_vector(lru3_repl_table(conv_integer(xlru)) (unlocked), 2);
    else
      xset := conv_std_logic_vector(lru3_repl_table(conv_integer(xlru)) (0), 2);
    end if;
  when 4 =>
    if isetlock = 1 then
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

type icache_control_type is record			-- all registers
  req, burst, holdn : std_ulogic;
  overrun       : std_ulogic;			-- 
  underrun      : std_ulogic;			-- 
  istate 	: std_logic_vector(1 downto 0);		-- FSM vector
  waddress      : std_logic_vector(31 downto 2); -- write address buffer
  valid         : std_logic_vector(ilinesize-1 downto 0); -- valid bits
  hit           : std_ulogic;
  su 		: std_ulogic;
  flush		: std_ulogic;				-- flush in progress
  flush2	: std_ulogic;				-- flush in progress
  flush3	: std_ulogic;				-- flush in progress
  faddr 	: std_logic_vector(IOFFSET_BITS - 1 downto 0);	-- flush address
  diagrdy  	: std_ulogic;
  rndcnt        : std_logic_vector(log2x(ISETS)-1 downto 0); -- replace counter
  lrr           : std_ulogic;
  setrepl       : std_logic_vector(log2x(ISETS)-1 downto 0); -- set to replace
  diagset       : std_logic_vector(log2x(ISETS)-1 downto 0);
  lock          : std_ulogic;
end record;

type lru_reg_type is record
  write : std_ulogic;
  waddr : std_logic_vector(IOFFSET_BITS-1 downto 0);
  set   : std_logic_vector(SETBITS-1 downto 0); --integer range 0 to ISETS-1;
  lru   : lru_array;
end record;

signal r, c : icache_control_type;	-- r is registers, c is combinational
signal rl, cl : lru_reg_type;           -- rl is registers, cl is combinational

constant icfg : std_logic_vector(31 downto 0) := 
	cache_cfg(irepl, isets, ilinesize, isetsize, isetlock, 0, lram, lramsize, lramstart, 0);

begin

  ictrl : process(rst, r, rl, mcio, ici, dci, dco, icramo, fpuholdn)
  variable rdatasel : rdatatype;
  variable twrite, diagen, dwrite : std_ulogic;
  variable taddr : std_logic_vector(TAG_HIGH  downto LINE_LOW); -- tag address
  variable wtag : std_logic_vector(TAG_HIGH downto TAG_LOW); -- write tag value
  variable ddatain : std_logic_vector(31 downto 0);
  variable rdata : cdatatype;
  variable diagdata : std_logic_vector(31 downto 0);
  variable vmaskraw, vmask : std_logic_vector((ilinesize -1) downto 0);
  variable xaddr_inc : std_logic_vector((ILINE_BITS -1) downto 0);
  variable lastline, nlastline, nnlastline : std_ulogic;
  variable enable : std_ulogic;
  variable error : std_ulogic;
  variable whit, hit, valid : std_ulogic;
  variable cacheon  : std_ulogic;
  variable v : icache_control_type;
  variable branch  : std_ulogic;
  variable eholdn  : std_ulogic;
  variable mds, write  : std_ulogic;
  variable memaddr : std_logic_vector(31 downto 2);
  variable set     : integer range 0 to MAXSETS-1;
  variable setrepl : std_logic_vector(log2x(ISETS)-1 downto 0); -- set to replace
  variable ctwrite, cdwrite, validv : std_logic_vector(0 to MAXSETS-1);
  variable wlrr : std_ulogic;
  variable vl : lru_reg_type;
  variable vdiagset, rdiagset : integer range 0 to ISETS-1;
  variable lock : std_logic_vector(0 to ISETS-1);
  variable wlock, sidle : std_ulogic;
  variable tag : cdatatype; --std_logic_vector(31  downto 0);
  variable lramacc, ilramwr, lramcs  : std_ulogic;
  
  begin

-- init local variables

    v := r; vl := rl; vl.write := '0'; vl.set := r.setrepl;
    vl.waddr := r.waddress(OFFSET_HIGH downto OFFSET_LOW);

    mds := '1'; dwrite := '0'; twrite := '0'; diagen := '0'; error := '0';
    write := mcio.ready; v.diagrdy := '0'; v.holdn := '1'; 
    v.flush3 := r.flush2; sidle := '0';

    if icen /= 0 then
      cacheon := dco.icdiag.cctrl.ics(0) and not r.flush;
    else cacheon := '0'; end if;
    enable := '1'; branch := '0';
    eholdn := dco.hold and fpuholdn;

    rdatasel := idata;	-- read data from cache as default
    ddatain := mcio.data;	-- load full word from memory
    wtag(TAG_HIGH downto TAG_LOW) := r.waddress(TAG_HIGH downto TAG_LOW);
    wlrr := r.lrr; wlock := r.lock;
    
    set := 0; ctwrite := (others => '0'); cdwrite := (others => '0');
    vdiagset := 0; rdiagset := 0; lock := (others => '0'); ilramwr := '0';
    lramacc := '0'; lramcs := '0';
    
-- random replacement counter
    if ISETS > 1 then
      if conv_integer(r.rndcnt) = (ISETS - 1) then v.rndcnt := (others => '0');
      else v.rndcnt := r.rndcnt + 1; end if;
    end if;


-- generate lock bits
    if isetlock = 1 then 
      for i in 0 to ISETS-1 loop lock(i) := icramo.tag(i)(CTAG_LOCKPOS); end loop;
    end if;
    
    --local ram access
    if (lram = 1) and (ici.fpc(31 downto 24) = LRAM_START) then lramacc := '1'; end if;
    
-- generate cache hit and valid bits    
    hit := '0';
    for i in ISETS-1 downto 0 loop
      if (icramo.tag(i)(TAG_HIGH downto TAG_LOW) = ici.fpc(TAG_HIGH downto TAG_LOW)) 
      then hit := not r.flush; set := i; end if;
      validv(i) := genmux(ici.fpc(LINE_HIGH downto LINE_LOW), 
		          icramo.tag(i)(ilinesize -1 downto 0));
    end loop;

    if (lramacc = '1') and (ISETS > 1) then set := 1; end if;
    
    if ici.fpc(LINE_HIGH downto LINE_LOW) = lline then lastline := '1';
    else lastline := '0'; end if;

    if r.waddress(LINE_HIGH downto LINE_LOW) = lline((ILINE_BITS -1) downto 0) then
      nlastline := '1';
    else nlastline := '0'; end if;

    if r.waddress(LINE_HIGH downto LINE_LOW+1) = lline((ILINE_BITS -1) downto 1) then
      nnlastline := '1';
    else nnlastline := '0'; end if;

    valid := validv(set);
    xaddr_inc := r.waddress(LINE_HIGH downto LINE_LOW) + 1;

    if mcio.ready = '1' then 
      v.waddress(LINE_HIGH downto LINE_LOW) := xaddr_inc;
    end if;

    taddr := ici.rpc(TAG_HIGH downto LINE_LOW);
    
-- main state machine

    case r.istate is
    when "00" =>	-- main state and cache hit
      v.valid := icramo.tag(set)(ilinesize-1 downto 0);
      v.hit := hit; v.su := ici.su; sidle := '1';

--      if (ici.inull or eholdn)  = '0' then 
      if eholdn  = '0' then 
        taddr := ici.fpc(TAG_HIGH downto LINE_LOW);
      else taddr := ici.rpc(TAG_HIGH downto LINE_LOW); end if;
      v.burst := dco.icdiag.cctrl.burst and not lastline;
      if (eholdn and not (ici.inull or lramacc)) = '1' then
	if not (cacheon and hit and valid) = '1' then  
	  v.istate := "01"; v.req := '1'; 
          v.holdn := '0'; v.overrun := '1';
	else
          if (ISETS > 1) and (irepl = lru) then vl.write := '1'; end if;
        end if;
        v.waddress := ici.fpc(31 downto 2);

      end if;
      if dco.icdiag.enable = '1' then
	diagen := '1';
      end if;
      ddatain := dci.maddress;
      if (ISETS > 1) then
        if (irepl = lru) then
	  vl.set := conv_std_logic_vector(set, SETBITS); 
	  vl.waddr := ici.fpc(OFFSET_HIGH downto OFFSET_LOW);
	end if;
        v.setrepl := conv_std_logic_vector(set, SETBITS);
 	if (((not hit) and (not r.flush)) = '1') then
          case irepl is
	  when rnd =>
            if isetlock = 1 then 
              if lock(conv_integer(r.rndcnt)) = '0' then v.setrepl := r.rndcnt;
              else
                v.setrepl := conv_std_logic_vector(ISETS-1, SETBITS);
                for i in ISETS-1 downto 0 loop
                  if (lock(i) = '0') and (i>conv_integer(r.rndcnt)) then
                    v.setrepl := conv_std_logic_vector(i, SETBITS);
                  end if;
                end loop;
              end if;
            else
              v.setrepl := r.rndcnt;
            end if;
          when lru =>
            v.setrepl :=  lru_set(rl.lru(conv_integer(ici.fpc(OFFSET_HIGH downto OFFSET_LOW))), lock(0 to ISETS-1));
          when lrr =>
            v.setrepl := (others => '0');
            if isetlock = 1 then
              if lock(0) = '1' then v.setrepl(0) := '1';
              else
                v.setrepl(0) := icramo.tag(0)(CTAG_LRRPOS) xor icramo.tag(1)(CTAG_LRRPOS);
              end if;
            else
              v.setrepl(0) := icramo.tag(0)(CTAG_LRRPOS) xor icramo.tag(1)(CTAG_LRRPOS);
            end if;
            if v.setrepl(0) = '0' then v.lrr := not icramo.tag(0)(CTAG_LRRPOS);
            else v.lrr := icramo.tag(0)(CTAG_LRRPOS); end if;
          end case;  
        end if;  
        if (isetlock = 1) then
          if (hit and lock(set)) = '1' then v.lock := '1';
          else v.lock := '0'; end if;
        end if;
      end if;
    when "01" =>		-- streaming: update cache and send data to IU
      rdatasel := memory;
      taddr(TAG_HIGH downto LINE_LOW) := r.waddress(TAG_HIGH downto LINE_LOW);
      branch := (ici.fbranch and r.overrun) or
		      (ici.rbranch and (not r.overrun));
      v.underrun := r.underrun or 
        (write and ((ici.inull or not eholdn) and (mcio.ready and not (r.overrun and not r.underrun))));
      v.overrun := (r.overrun or (eholdn and not ici.inull)) and 
		    not (write or r.underrun);
      if mcio.ready = '1' then
--        mds := not (v.overrun and not r.underrun);
        mds := not (r.overrun and not r.underrun);
--        v.req := r.burst; 
        v.burst := v.req and not (nnlastline and mcio.ready);        
      end if;
      if mcio.grant = '1' then 
        v.req := dco.icdiag.cctrl.burst and r.burst and 
	         (not (nnlastline and mcio.ready)) and (dco.icdiag.cctrl.burst or (not branch)) and
		 not (v.underrun and not cacheon);
        v.burst := v.req and not (nnlastline and mcio.ready);
      end if;
      v.underrun := (v.underrun or branch) and not v.overrun;
      v.holdn := not (v.overrun or v.underrun); 
      if (mcio.ready = '1') and (r.req = '0') then --(v.burst = '0') then        
        v.underrun := '0'; v.overrun := '0';
        if (dco.icdiag.cctrl.ics(0) and not r.flush2) = '1' then
	  v.istate := "10"; v.holdn := '0';
	else
          v.istate := "00"; v.flush := r.flush2; v.holdn := '1';
	  if r.overrun = '1' then taddr := ici.fpc(TAG_HIGH downto LINE_LOW);
	  else taddr := ici.rpc(TAG_HIGH downto LINE_LOW); end if;
	end if;
      end if;
    when "10" => 		-- return to main
      taddr := ici.fpc(TAG_HIGH downto LINE_LOW);
      v.istate := "00"; v.flush := r.flush2;
    when others => v.istate := "00";
    end case;

    if mcio.retry = '1' then v.req := '1'; end if;

    if lram = 1 then
      if LRAMCS_EN then
        if taddr(31 downto 24) = LRAM_START then lramcs := '1'; else lramcs := '0'; end if;
      else
        lramcs := '1';
      end if;
    end if;

    
-- Generate new valid bits write strobe

    vmaskraw := decode(r.waddress(LINE_HIGH downto LINE_LOW));
    twrite := write;
    if cacheon = '0' then
      twrite := '0'; vmask := (others => '0');
    elsif (dco.icdiag.cctrl.ics = "01") then
      twrite := twrite and r.hit;
      vmask := icramo.tag(set)(ilinesize-1 downto 0) or vmaskraw;
    else
      if r.hit = '1' then vmask := r.valid or vmaskraw;
      else vmask := vmaskraw; end if;
    end if; 
    if (mcio.mexc or not mcio.cache) = '1' then 
      twrite := '0'; dwrite := '0';
    else dwrite := twrite; end if;
    if twrite = '1' then
      v.valid := vmask; v.hit := '1';
      if (ISETS > 1) and (irepl = lru) then vl.write := '1'; end if;
    end if;

    if (ISETS > 1) and (irepl = lru) and (rl.write = '1') then
      vl.lru(conv_integer(rl.waddr)) :=
	  lru_calc(rl.lru(conv_integer(rl.waddr)), conv_integer(rl.set));
    end if;

-- cache write signals
    
    if ISETS > 1 then setrepl := r.setrepl; else setrepl := (others => '0'); end if;
    if twrite = '1' then ctwrite(conv_integer(setrepl)) := '1'; end if;
    if dwrite = '1' then cdwrite(conv_integer(setrepl)) := '1'; end if;
    
-- diagnostic cache access

    if diagen = '1' then
     if (ISETS /= 1) then
       if (dco.icdiag.ilramen = '1') and (lram = 1) then
         v.diagset := conv_std_logic_vector(1, SETBITS);
       else
         v.diagset := dco.icdiag.addr(SETBITS -1 + TAG_LOW downto TAG_LOW);
       end if;
     end if;
    end if;
     
    case ISETS is
      when 1 =>
        vdiagset := 0; rdiagset := 0;
      when 3 =>
        if conv_integer(v.diagset) < 3 then vdiagset := conv_integer(v.diagset); end if;
        if conv_integer(r.diagset) < 3 then rdiagset := conv_integer(r.diagset); end if;
      when others =>
        vdiagset := conv_integer(v.diagset); 
        rdiagset := conv_integer(r.diagset); 
    end case;
    
    diagdata := icramo.data(rdiagset);
    if diagen = '1' then -- diagnostic or local ram access
      taddr(TAG_HIGH downto LINE_LOW) := dco.icdiag.addr(TAG_HIGH downto LINE_LOW);
      wtag(TAG_HIGH downto TAG_LOW) := dci.maddress(TAG_HIGH downto TAG_LOW);
      wlrr := dci.maddress(CTAG_LRRPOS);
      wlock := dci.maddress(CTAG_LOCKPOS);
      if (dco.icdiag.ilramen = '1') and (lram = 1) then
        ilramwr := not dco.icdiag.read;
      elsif dco.icdiag.tag = '1' then
	twrite := not dco.icdiag.read; dwrite := '0';
        ctwrite := (others => '0'); cdwrite := (others => '0');
	ctwrite(vdiagset) := not dco.icdiag.read;
        diagdata := icramo.tag(rdiagset);
      else
	dwrite := not dco.icdiag.read; twrite := '0';
        cdwrite := (others => '0'); cdwrite(vdiagset) := not dco.icdiag.read;
        ctwrite := (others => '0');
      end if;
      vmask := dci.maddress(ilinesize -1 downto 0);
      v.diagrdy := '1';
    end if;

    
-- select data to return on read access

    rdata := icramo.data;
    case rdatasel is
    when memory => rdata(0) := mcio.data; set := 0;
    when others => 
    end case;

-- cache flush

    if ((ici.flush or dco.icdiag.flush) = '1') and (icen /= 0) then
      v.flush := '1'; v.flush2 := '1'; v.faddr := (others => '0');
    end if;

    if (r.flush2 = '1') and (icen /= 0) then
      twrite := '1'; ctwrite := (others => '1'); vmask := (others => '0');
      v.faddr := r.faddr +1; taddr(OFFSET_HIGH downto OFFSET_LOW) := r.faddr;
      wlrr := '0'; wlock := '0'; wtag := (others => '0'); v.lrr := '0';
      if (r.faddr(IOFFSET_BITS -1) and not v.faddr(IOFFSET_BITS -1)) = '1' then
	v.flush2 := '0';
      end if;
    end if;

-- reset

    if rst = '0' then 
      v.istate := "00"; v.req := '0'; v.burst := '0'; v.holdn := '1';
      v.flush := '0'; v.flush2 := '0'; v.overrun := '0'; v.underrun := '0';
      v.rndcnt := (others => '0'); v.lrr := '0'; v.setrepl := (others => '0');
      v.diagset := (others => '0'); v.lock := '0'; v.flush3 := '1';
      v.waddress := ici.fpc(31 downto 2); v.lrr := '0';
    end if;

    if r.flush3 = '1' then  
      vl.lru := (others => (others => '0'));
    end if;
    
-- Drive signals

    c  <= v;	   -- register inputs
    cl <= vl;  -- lru register inputs

    -- tag ram inputs
    enable := enable and not dco.icdiag.scanen;
    for i in 0 to ISETS-1 loop
      tag(i) := (others => '0');
      tag(i)(ilinesize-1 downto 0) := vmask;
      tag(i)(TAG_HIGH downto TAG_LOW) := wtag;
      tag(i)(CTAG_LRRPOS) := wlrr;
      tag(i)(CTAG_LOCKPOS) := wlock;
    end loop;
    icrami.tag <= tag;
    icrami.tenable   <= enable;
    icrami.twrite    <= ctwrite;
    icrami.flush    <= r.flush2;
    icrami.dpar    <= (others => '0');
    icrami.tpar    <= (others => (others => '0'));
    icrami.ctx    <= (others => '0');

    -- data ram inputs
    icrami.denable  <= enable;
    icrami.address  <= taddr(19+LINE_LOW downto LINE_LOW);
    icrami.data     <= ddatain;
    icrami.dwrite   <= cdwrite; 

    -- local ram inputs
    icrami.ldramin.enable <= (dco.icdiag.ilramen or lramcs or lramacc) and not dco.icdiag.scanen;
    icrami.ldramin.read  <= dco.icdiag.ilramen or lramacc;
    icrami.ldramin.write <= ilramwr;
    
    -- memory controller inputs
    mcii.address(31 downto 2)  <= r.waddress(31 downto 2);
    mcii.address(1 downto 0)  <= "00";
    mcii.su       <= r.su;
    mcii.burst    <= r.burst;
    mcii.req      <= r.req;
    mcii.flush    <= r.flush;

    -- IU data cache inputs
    ico.data      <= rdata;
    ico.mexc      <= mcio.mexc or error;
    ico.hold      <= r.holdn;
    ico.mds       <= mds;
    ico.flush     <= r.flush;
    ico.diagdata  <= diagdata;
    ico.diagrdy   <= r.diagrdy;
    ico.set       <= conv_std_logic_vector(set, 2);
    ico.cfg  	  <= icfg;
    ico.idle 	  <= sidle;

  end process;

-- Local registers


  regs1 : process(clk)
  begin if rising_edge(clk) then r <= c; end if; end process;

  regs2 : if (ISETS > 1) and (irepl = lru) generate
    regs2 : process(clk)
    begin if rising_edge(clk) then rl <= cl; end if; end process;
  end generate;

  nolru : if (ISETS = 1) or (irepl /= lru) generate
    rl.write <= '0'; rl.waddr <= (others => '0');
    rl.set <= (others => '0'); rl.lru <= (others => (others => '0'));
  end generate;

-- pragma translate_off
  chk : process
  begin
    assert not ((ISETS > 2) and (irepl = lrr)) report
	"Wrong instruction cache configuration detected: LRR replacement requires 2 sets"
    severity failure;
    wait;
  end process;
-- pragma translate_on
      
end ;

