



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
-- Entity: 	dsu
-- File:	dsu.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Debug support unit. 
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.amba.all;
use work.tech_map.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";


entity dsu is
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    dsui   : in  dsu_in_type;
    dsuo   : out dsu_out_type;
    dbgi   : in  iu_debug_out_type;
    dbgo   : out iu_debug_in_type;
    irqo   : in  irq_out_type;
    dmi    : out dsumem_in_type;
    dmo    : in  dsumem_out_type
  );
end; 

architecture rtl of dsu is

-- constant dsuconfig : debug_config_type := leon_config_table(cfgindex).debug;

constant TTIMEBITS : integer := 30; -- timer bits

type dsu_config_reg is record
  tenable       : std_logic;	-- trace enable
  tmode         : std_logic;	-- trace delay counter mode
  btrapa        : std_logic;	-- break on any IU trap
  btrape        : std_logic;	-- break on all IU traps but 3,4,5,6,0x11-0x1f
  berror        : std_logic;	-- break on IU error mode
  bwatch        : std_logic;	-- break on IU watchpoint
  bsoft         : std_logic;	-- break on software breakpoint (TA 1)
  bahb          : std_logic;	-- break on AHB watchpoint hit
  btrace        : std_logic;	-- break on trace freeze
  ftimer        : std_logic;	-- freeze timer on break
  rerror        : std_logic;	-- reset error mode
  step          : std_logic;	-- single step
  lresp         : std_logic;	-- link response enable
  dresp         : std_logic;	-- debug response enable
  dbreak        : std_logic;	-- force CPU in debug mode (write-only)
  dcnten        : std_logic;	-- delay counter enable
  delaycnt      : std_logic_vector(TBUFABITS - 1 downto 0); -- delay counter
end record;

type trace_ctrl_reg is record
  aindex  	: std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
  pindex  	: std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
  tproc         : std_logic;	-- trace processor enable
  tahb          : std_logic;	-- trace AHB enable
end record;

type trace_break_reg is record
  addr          : std_logic_vector(31 downto 2);
  mask          : std_logic_vector(31 downto 2);
  read          : std_logic;
  write         : std_logic;
  exec          : std_logic;
end record;

type regtype is record
-- AHB signals
  haddr         : std_logic_vector(31 downto 0);
  hwrite        : std_logic;
  htrans	: std_logic_vector(1 downto 0);
  hsize         : std_logic_vector(2 downto 0);
  hburst        : std_logic_vector(2 downto 0);
  hwdata        : std_logic_vector(31 downto 0);
  hmaster       : std_logic_vector(3 downto 0);
  hmastlock     : std_logic;
  hsel          : std_logic;
  hready        : std_logic;
  hready2       : std_logic;
  hready3       : std_logic;
  ahbactive     : std_logic;

  timer     	: std_logic_vector(TTIMEBITS - 1 downto 0); -- timer
  dsubre    	: std_logic_vector(2 downto 0); -- external DSUBRE signal
  dsuen     	: std_logic_vector(2 downto 0); -- external DSUBRE signal
  dsuact        : std_logic;

  dsucfg        : dsu_config_reg;
  tbreg1	: trace_break_reg;
  tbreg2	: trace_break_reg;
  tctrl 	: trace_ctrl_reg;
end record;

signal r, rin : regtype;
constant zero30 : std_logic_vector(29 downto 0) := (others => '0');

begin

  ctrl : process(rst, ahbmi, ahbsi, dsui, irqo, dbgi, r, dmo)
  variable v : regtype;
  variable vpbufi, vabufi : tracebuf_in_type;
  variable regsd : std_logic_vector(31 downto 0);   -- data from registers
  variable pindex, aindex : std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
  variable denable, ldst_cycle, bphit, bphit2 : std_logic;
  variable bufdata : std_logic_vector(127 downto 0);
  variable pbufo, abufo : tracebuf_out_type;

  begin

    v := r; regsd := (others => '0'); vpbufi.enable := '0'; vabufi.enable := '0'; 
    vpbufi.data := (others => '0'); vabufi.data := (others => '0'); 
    vpbufi.addr := (others => '0'); vabufi.addr := (others => '0'); 
    vpbufi.write := (others => '0'); vabufi.write := (others => '0'); 
    denable := '0'; bphit := '0'; bphit2 := '0';
    v.hready := r.hready2; v.hready2 := r.hready3; v.hready3 := '0'; 
    pbufo := dmo.pbufo; abufo := dmo.abufo;
    bufdata := pbufo.data;
    ldst_cycle := dbgi.wr.inst(31) and dbgi.wr.inst(30); 
    v.dsubre := r.dsubre(1 downto 0) & dsui.dsubre;
    v.dsuen := r.dsuen(1 downto 0) & dsui.dsuen;
    v.dsucfg.dbreak := r.dsucfg.dbreak or 
	(r.dsubre(1) and not r.dsubre(2)) or dbgi.dmode;
    v.dsuact := dbgi.dmode; v.dsucfg.rerror := '0';

-- trace buffer index and delay counters
    if DSUTRACE then
-- pragma translate_off
      if not is_x(r.timer) then
-- pragma translate_on
        if (r.dsucfg.tenable and not dbgi.dmode2) = '1' then 
	  v.timer := r.timer + 1; 
        end if;
-- pragma translate_off
      end if;
-- pragma translate_on
-- pragma translate_off
      if not is_x(r.tctrl.pindex) then
-- pragma translate_on
        pindex := r.tctrl.pindex + 1;
-- pragma translate_off
      end if;
-- pragma translate_on
      if DSUMIXED then
-- pragma translate_off
        if not is_x(r.tctrl.aindex) then
-- pragma translate_on
          aindex := r.tctrl.aindex + 1;
-- pragma translate_off
        end if;
-- pragma translate_on
      end if;
    end if;

-- check for AHB watchpoints
    if (ahbsi.hready and r.ahbactive ) = '1' then
      if ((((r.tbreg1.addr xor r.haddr(31 downto 2)) and r.tbreg1.mask) = zero30) and
         (((r.tbreg1.read and not r.hwrite) or (r.tbreg1.write and r.hwrite)) = '1')) 
        or ((((r.tbreg2.addr xor r.haddr(31 downto 2)) and r.tbreg2.mask) = zero30) and
           (((r.tbreg2.read and not r.hwrite) or (r.tbreg2.write and r.hwrite)) = '1')) 
      then
	bphit := '1';
	if (r.dsucfg.dcnten = '0') and ((r.tctrl.tahb or r.tctrl.tproc) = '1') and
	   (r.dsucfg.delaycnt /= zero30(TBUFABITS-1 downto 0))
        then v.dsucfg.dcnten := '1'; end if;
	if r.dsucfg.bahb = '1' then v.dsucfg.dbreak := '1'; end if;
      end if;
    end if;

-- check for IU trace breakpoints
    if (dbgi.holdn and dbgi.wr.pv and

	 not dbgi.wr.annul) = '1'

    then
      if ((((r.tbreg1.addr xor dbgi.wr.pc(31 downto 2)) and r.tbreg1.mask) = zero30) and
         (r.tbreg1.exec = '1')) 
        or ((((r.tbreg2.addr xor dbgi.wr.pc(31 downto 2)) and r.tbreg2.mask) = zero30) and
           (r.tbreg2.exec = '1')) 
      then
	bphit2 := '1';
	if (r.dsucfg.tenable = '1') and (r.dsucfg.dcnten = '0') and
	     (r.dsucfg.delaycnt /= zero30(TBUFABITS-1 downto 0))
        then v.dsucfg.dcnten := '1'; end if;
	if r.dsucfg.bahb = '1' then v.dsucfg.dbreak := '1'; end if;
      end if;
    end if;

-- generate buffer inputs
    if DSUTRACE then
      vpbufi.write := "0000"; vabufi.write := "0000";
      if r.dsucfg.tenable = '1' then
	vpbufi.addr := '0' & r.tctrl.pindex;
        vabufi.addr := '0' & r.tctrl.aindex;
        vabufi.data(125 downto 96) := r.timer; 
	vpbufi.data(125 downto 96) := r.timer;
        vabufi.data(127) := bphit;
  	vabufi.data(95 downto 92) := irqo.irl;
  	vabufi.data(91 downto 88) := dbgi.psrpil;
  	vabufi.data(87 downto 80) := dbgi.psrtt;
 	vabufi.data(79) := r.hwrite;
  	vabufi.data(78 downto 77) := r.htrans;
  	vabufi.data(76 downto 74) := r.hsize;
  	vabufi.data(73 downto 71) := r.hburst;
  	vabufi.data(70 downto 67) := r.hmaster;
  	vabufi.data(66) := r.hmastlock;
  	vabufi.data(65 downto 64) := ahbmi.hresp;
        if r.hwrite = '1' then
          vabufi.data(63 downto 32) := ahbsi.hwdata;
        else
          vabufi.data(63 downto 32) := ahbmi.hrdata;
        end if; 
        vabufi.data(31 downto 0) := r.haddr;
        vpbufi.data(127) := bphit2;
        vpbufi.data(126) := not dbgi.wr.pv;
        vpbufi.data(95 downto 64) := dbgi.result;
        vpbufi.data(63 downto 32) := dbgi.wr.pc(31 downto 2) & 
			            dbgi.trap & dbgi.error;
        vpbufi.data(31 downto 0) := dbgi.wr.inst;
      else
        vpbufi.addr := '0' & r.haddr(TBUFABITS+3 downto 4);
        vabufi.addr := '1' & r.haddr(TBUFABITS+3 downto 4);
        vpbufi.data := ahbsi.hwdata & ahbsi.hwdata & ahbsi.hwdata & ahbsi.hwdata;
        vabufi.data := vpbufi.data;
      end if;

-- write trace buffer
      if r.dsucfg.tenable = '1' then 
        if (r.tctrl.tahb and r.ahbactive and ahbsi.hready) = '1' then
	  if DSUMIXED then
	    v.tctrl.aindex := aindex;
            vabufi.enable := '1'; vabufi.write := "1111"; 
	  elsif (r.tctrl.tproc = '0') then 
	    v.tctrl.pindex := pindex;
            vpbufi.enable := '1'; vpbufi.write := "1111"; 
	  end if;
        end if;
        if (r.tctrl.tproc and dbgi.holdn and 
	 (dbgi.wr.pv or dbgi.write_reg or ldst_cycle)

	  and (not dbgi.vdmode) and not dbgi.wr.annul) = '1'

        then
          vpbufi.enable := '1'; vpbufi.write := "1111"; 
	  v.tctrl.pindex := pindex;
        end if;
	if ((r.tctrl.tahb xor r.tctrl.tproc) = '1') and 
	    DSUMIXED and not DSUDPRAM 
	then
	  if r.tctrl.tahb = '1' then vpbufi := vabufi;
          else vabufi := vpbufi; end if;
	  vabufi.enable := vabufi.enable and vabufi.addr(TBUFABITS-1);
	  vpbufi.enable := vpbufi.enable and not vpbufi.addr(TBUFABITS-1);
	end if;
	if ((r.tctrl.tahb and not r.tctrl.tproc) = '1') and not DSUMIXED then
	  vpbufi.data := vabufi.data;
	end if;
      end if;
    end if;

-- trace buffer delay counter handling
    if (r.dsucfg.dcnten = '1') then
      if (r.dsucfg.delaycnt = zero30(TBUFABITS-1 downto 0)) then
	v.dsucfg.tenable := '0'; v.dsucfg.dcnten := '0';
	v.dsucfg.dbreak := v.dsucfg.dbreak or r.dsucfg.btrace;
      end if;
-- pragma translate_off
      if not is_x(r.dsucfg.delaycnt) then
-- pragma translate_on
        if ((vpbufi.enable and not r.dsucfg.tmode) or
           (vabufi.enable and r.dsucfg.tmode)) = '1' 
	then 
	  v.dsucfg.delaycnt := r.dsucfg.delaycnt - 1;
	end if;
-- pragma translate_off
      end if;
-- pragma translate_on
    end if;

-- save AHB transfer parameters
    if (ahbsi.hready = '1' ) and ((ahbsi.hsel = '1') or (r.dsucfg.bahb = '1') or
	(DSUTRACE and ((r.tctrl.tahb and r.dsucfg.tenable) = '1')))
    then
      v.haddr := ahbsi.haddr; v.hwrite := ahbsi.hwrite; v.htrans := ahbsi.htrans;
      v.hsize := ahbsi.hsize; v.hburst := ahbsi.hburst;
      v.hmaster := ahbsi.hmaster; v.hmastlock := ahbsi.hmastlock;
    end if;
    if r.hsel = '1' then v.hwdata := ahbsi.hwdata; end if;
    if ahbsi.hready = '1' then
      v.hsel := ahbsi.hsel;
      v.ahbactive := ahbsi.htrans(1);
    end if;

-- AHB slave access to DSU registers and trace buffers
    if (r.hsel and not r.hready) = '1' then
      case r.haddr(20 downto 16) is
      when "00000" =>	-- DSU control register access
        v.hready := '1';
        case r.haddr(4 downto 2) is
        when "000" =>
	  regsd((TBUFABITS + 19) downto 20) := r.dsucfg.delaycnt;
	  regsd(18 downto 1) := 
	    r.dsucfg.dresp & r.dsucfg.lresp &
	    r.dsucfg.step & dbgi.error &
	    r.dsuen(2) & r.dsubre(2) & r.dsuact &
	    r.dsucfg.dcnten & r.dsucfg.btrape & r.dsucfg.btrapa &
	    r.dsucfg.bahb & r.dsucfg.dbreak & r.dsucfg.bsoft &
	    r.dsucfg.bwatch & r.dsucfg.berror & r.dsucfg.ftimer &
	    r.dsucfg.btrace &  r.dsucfg.tmode;
	    if DSUTRACE then regsd(0) := r.dsucfg.tenable;
	    end if;
	  if r.hwrite = '1' then
	    v.dsucfg.delaycnt := ahbsi.hwdata((TBUFABITS+ 19) downto 20); 
	    v.dsucfg.rerror := ahbsi.hwdata(19);
	    v.dsucfg.dresp := ahbsi.hwdata(18);
	    v.dsucfg.lresp := ahbsi.hwdata(17);
	    v.dsucfg.step := ahbsi.hwdata(16);
	    v.dsucfg.dcnten := ahbsi.hwdata(11);
	    v.dsucfg.btrape  := ahbsi.hwdata(10);
	    v.dsucfg.btrapa  := ahbsi.hwdata(9);
	    v.dsucfg.bahb := ahbsi.hwdata(8);
	    v.dsucfg.dbreak := ahbsi.hwdata(7);
	    v.dsucfg.bsoft := ahbsi.hwdata(6);
	    v.dsucfg.bwatch := ahbsi.hwdata(5);
	    v.dsucfg.berror := ahbsi.hwdata(4);
	    v.dsucfg.ftimer := ahbsi.hwdata(3);
	    v.dsucfg.btrace := ahbsi.hwdata(2);
	    v.dsucfg.tmode := ahbsi.hwdata(1);
	    if DSUTRACE then
	      v.dsucfg.tenable := ahbsi.hwdata(0);
	    end if;
	  end if;
        when "001" =>
	  if DSUTRACE then
	    regsd((TBUFABITS - 1) downto 0) := r.tctrl.pindex;
	    if DSUMIXED then
	      regsd((TBUFABITS - 1 + 12) downto 12) := r.tctrl.aindex;
	    end if;
	    regsd(24) := r.tctrl.tproc; regsd(25) := r.tctrl.tahb;
	    if r.hwrite = '1' then
	      v.tctrl.pindex := ahbsi.hwdata((TBUFABITS- 1) downto 0); 
	      if DSUMIXED then
	        v.tctrl.aindex := ahbsi.hwdata((TBUFABITS- 1 + 12) downto 12); 
	      end if;
	      v.tctrl.tproc  := ahbsi.hwdata(24); 
	      v.tctrl.tahb   := ahbsi.hwdata(25); 
	    end if;
	  end if;
        when "010" =>
	  if DSUTRACE then
	    regsd((TTIMEBITS - 1) downto 0) := r.timer; 
	    if r.hwrite = '1' then
	      v.timer := ahbsi.hwdata((TTIMEBITS- 1) downto 0); 
	    end if;
	  end if;
        when "100" =>
	  regsd(31 downto 2) := r.tbreg1.addr; 
	  if r.hwrite = '1' then
	    v.tbreg1.addr := ahbsi.hwdata(31 downto 2); 
	    v.tbreg1.exec := ahbsi.hwdata(0); 
	  end if;
        when "101" =>
	  regsd := r.tbreg1.mask & r.tbreg1.read & r.tbreg1.write; 
	  if r.hwrite = '1' then
	    v.tbreg1.mask := ahbsi.hwdata(31 downto 2); 
	    v.tbreg1.read := ahbsi.hwdata(1); 
	    v.tbreg1.write := ahbsi.hwdata(0); 
	  end if;
        when "110" =>
	  regsd(31 downto 2) := r.tbreg2.addr; 
	  if r.hwrite = '1' then
	    v.tbreg2.addr := ahbsi.hwdata(31 downto 2); 
	    v.tbreg2.exec := ahbsi.hwdata(0); 
	  end if;
        when others =>
	  regsd := r.tbreg2.mask & r.tbreg2.read & r.tbreg2.write; 
	  if r.hwrite = '1' then
	    v.tbreg2.mask := ahbsi.hwdata(31 downto 2); 
	    v.tbreg2.read := ahbsi.hwdata(1); 
	    v.tbreg2.write := ahbsi.hwdata(0); 
	  end if;
	end case;
	v.hwdata := regsd;
      when "00001" =>	-- read/write access to trace buffer
        if r.hwrite = '1' then v.hready := '1'; else v.hready2 := not (r.hready2 or r.hready); end if;
	if DSUTRACE then
	  if DSUMIXED and not DSUDPRAM then
            vabufi.enable := (not r.dsucfg.tenable) and r.haddr(TBUFABITS+3); 
	    vpbufi.enable := (not r.dsucfg.tenable) and not r.haddr(TBUFABITS+3);
	    if  r.haddr(TBUFABITS+3) = '1' then bufdata := abufo.data;
	    else bufdata := pbufo.data; end if;
          else
            vpbufi.enable := not r.dsucfg.tenable; 
	    if not DSUMIXED then vabufi.enable := vpbufi.enable; end if;
	  end if;
          case r.haddr(3 downto 2) is
          when "00" =>
	    v.hwdata := bufdata(127 downto 96);
	    if r.hwrite = '1' then 
	      vpbufi.write(3) := vpbufi.enable;
	      vabufi.write(3) := vabufi.enable;
	    end if;
          when "01" =>
	    v.hwdata := bufdata(95 downto 64);
	    if r.hwrite = '1' then 
	      vpbufi.write(2) := vpbufi.enable;
	      vabufi.write(2) := vabufi.enable;
	    end if;
          when "10" =>
	    v.hwdata := bufdata(63 downto 32);
	    if r.hwrite = '1' then 
	      vpbufi.write(1) := vpbufi.enable;
	      vabufi.write(1) := vabufi.enable;
	    end if;
          when others =>
	    v.hwdata := bufdata(31 downto 0);
	    if r.hwrite = '1' then 
	      vpbufi.write(0) := vpbufi.enable;
	      vabufi.write(0) := vabufi.enable;
	    end if;
	  end case;
	end if;
      when others => 	-- IU/cache diagnostic access
	if r.hwrite = '0' then v.hwdata := dbgi.ddata(31 downto 0); end if;
	if r.haddr(20) = '0' then	-- IU registers
            v.hready3 := not (r.hready2 or r.hready3);
	    denable := r.hready2 or r.hready3;
	else
	  denable := '1';
          if r.haddr(19) = '0' then	-- icache
	    if r.hwrite = '0' then v.hready := dbgi.diagrdy and not r.hready;
	    else v.hready2 := not (r.hready2 or r.hready); end if;
  	  else				-- dcache
	    if r.hwrite = '1' then v.hready2 := not (r.hready2 or r.hready);
	    else
	      v.hready2 := not r.hready2; v.hready3 := r.hready2 or r.hready3;
	      v.hready := r.hready2 and r.hready3;
	      if v.hready = '1' then v.hready2 := '0'; v.hready3 := '0'; end if;
	    end if;
	  end if;
	end if;
      end case;
    end if;

    if ((ahbsi.hsel and ahbsi.hready) = '1') and 
          ((ahbsi.htrans = HTRANS_BUSY) or (ahbsi.htrans = HTRANS_IDLE))
    then v.hready := '1'; end if;


    if DSUMIXED then
      if ((r.tctrl.tahb and r.tctrl.tproc and r.dsucfg.tenable) = '1') then
        v.tctrl.aindex(TBUFABITS-1) := '1'; v.tctrl.pindex(TBUFABITS-1) := '0';
      end if;
    else vabufi := vpbufi; end if;
    vpbufi.addr(TBUFABITS) := '0'; vabufi.addr(TBUFABITS) := '1';

    dsuo.freezetime <= r.dsucfg.ftimer and dbgi.dmode2;
    dsuo.ntrace <= r.dsucfg.tenable and not v.dsucfg.tenable;
    dsuo.dsuact <= r.dsuact;
    dsuo.dsuen <= r.dsuen(2);
    dsuo.dsubre <= r.dsubre(2);
    dsuo.lresp <= r.dsucfg.lresp;
    dsuo.dresp <= r.dsucfg.dresp;

    if rst = '0' then
      v.ahbactive := '0'; v.dsucfg.tenable := '0'; 
      v.timer := (others => '0');
      v.hsel := '0'; v.dsucfg.dcnten := '0'; v.dsucfg.dbreak := r.dsubre(2);
      v.dsucfg.btrape := r.dsubre(2); v.dsucfg.berror := r.dsubre(2); 
      v.dsucfg.bwatch := r.dsubre(2); v.dsucfg.bsoft := '0'; 
      v.dsucfg.btrapa := r.dsubre(2); v.dsucfg.lresp := '0'; 
      v.dsucfg.step := '0';
      v.dsucfg.dresp := '0'; v.dsucfg.ftimer := '0'; v.dsucfg.btrace := '0'; 
      v.dsucfg.bahb := '0';
      v.tbreg1.read := '0'; v.tbreg1.write := '0'; v.tbreg1.exec := '0';
      v.tbreg2.read := '0'; v.tbreg2.write := '0'; v.tbreg2.exec := '0';
    end if;

    rin <= v;
    dmi.pbufi <= vpbufi;
    dmi.abufi <= vabufi;
    ahbso.hrdata <= r.hwdata;
    ahbso.hready <= r.hready;
    dbgo.btrapa <= r.dsucfg.btrapa;
    dbgo.btrape <= r.dsucfg.btrape;
    dbgo.berror <= r.dsucfg.berror;
    dbgo.bwatch <= r.dsucfg.bwatch;
    dbgo.bsoft <= r.dsucfg.bsoft;
    dbgo.dbreak <= r.dsucfg.dbreak;
    dbgo.rerror <= r.dsucfg.rerror;
    dbgo.dsuen <= r.dsuen(2);
    dbgo.daddr <= r.haddr(21 downto 2);
    dbgo.dwrite <= r.hwrite;
    dbgo.ddata <= r.hwdata;
    dbgo.denable <= denable;
    dbgo.step  <= r.dsucfg.step ;
  end process;

  ahbso.hresp <= HRESP_OKAY;


  memstatregs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;



end;


