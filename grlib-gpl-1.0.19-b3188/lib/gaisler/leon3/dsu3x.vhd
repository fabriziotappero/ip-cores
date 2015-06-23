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
-- Entity: 	dsu
-- File:	dsu.vhd
-- Author:	Jiri Gaisler, Edvin Catovic - Gaisler Research
-- Description:	Combined LEON3 debug support and AHB trace unit
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.leon3.all;
use gaisler.libiu.all;
use gaisler.libcache.all;
library techmap;
use techmap.gencomp.all;

entity dsu3x is
  generic (
    hindex  : integer := 0;
    haddr : integer := 16#900#;
    hmask : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0;
    clk2x   : integer range 0 to 1 := 0
  );
  port (
    rst    : in  std_ulogic;
    hclk   : in  std_ulogic;
    cpuclk : in std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    dbgi   : in l3_debug_out_vector(0 to NCPU-1);
    dbgo   : out l3_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu_in_type;
    dsuo   : out dsu_out_type;
    hclken : in std_ulogic
  );
end; 

architecture rtl of dsu3x is

  constant TBUFABITS : integer := log2(kbytes) + 6;
  constant NBITS  : integer := log2x(ncpu);
  constant PROC_H : integer := 24+NBITS-1;
  constant PROC_L : integer := 24;
  constant AREA_H : integer := 23;
  constant AREA_L : integer := 20;
  constant HBITS : integer := 28;

  constant DSU3_VERSION : integer := 1;

  constant hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LEON3DSU, 0, DSU3_VERSION, 0),
    4 => ahb_membar(haddr, '0', '0', hmask),
    others => zero32);
  
  type slv_reg_type is record
    hsel     : std_ulogic;
    haddr    : std_logic_vector(PROC_H downto 0);
    hwrite   : std_ulogic;
    hwdata   : std_logic_vector(31 downto 0);
    hrdata   : std_logic_vector(31 downto 0);    
    hready  : std_ulogic;
    hready2 : std_ulogic;
  end record;                   

  type reg_type is record
    slv  : slv_reg_type;
    en  : std_logic_vector(0 to NCPU-1);
    te  : std_logic_vector(0 to NCPU-1);
    be  : std_logic_vector(0 to NCPU-1);
    bw  : std_logic_vector(0 to NCPU-1);
    bs  : std_logic_vector(0 to NCPU-1);
    bx  : std_logic_vector(0 to NCPU-1);
    bz  : std_logic_vector(0 to NCPU-1);
    halt  : std_logic_vector(0 to NCPU-1);
    reset : std_logic_vector(0 to NCPU-1);
    bn    : std_logic_vector(NCPU-1 downto 0);
    ss    : std_logic_vector(NCPU-1 downto 0);
    bmsk  : std_logic_vector(NCPU-1 downto 0);
    dmsk  : std_logic_vector(NCPU-1 downto 0);
    cnt   : std_logic_vector(2 downto 0);
    dsubre : std_logic_vector(2 downto 0);
    dsuen : std_logic_vector(2 downto 0);
    act   : std_ulogic;
    timer : std_logic_vector(tbits-1 downto 0);
    pwd   : std_logic_vector(NCPU-1 downto 0);    
    tstop : std_ulogic;
  end record;
                     
  type trace_break_reg is record
    addr          : std_logic_vector(31 downto 2);
    mask          : std_logic_vector(31 downto 2);
    read          : std_logic;
    write         : std_logic;
  end record;

  type tregtype is record
    haddr         : std_logic_vector(31 downto 0);
    hwrite        : std_logic;
    htrans	  : std_logic_vector(1 downto 0);
    hsize         : std_logic_vector(2 downto 0);
    hburst        : std_logic_vector(2 downto 0);
    hwdata        : std_logic_vector(31 downto 0);
    hmaster       : std_logic_vector(3 downto 0);
    hmastlock     : std_logic;
    hsel          : std_logic;
    ahbactive     : std_logic;
    aindex  	  : std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
    enable        : std_logic;	-- trace enable
    bphit         : std_logic;	-- AHB breakpoint hit
    bphit2        : std_logic;  -- delayed bphit
    dcnten        : std_logic;	-- delay counter enable
    delaycnt      : std_logic_vector(TBUFABITS - 1 downto 0); -- delay counter
    tbreg1	  : trace_break_reg;
    tbreg2	  : trace_break_reg;
    tbwr          : std_logic;	-- trace buffer write enable
    break         : std_logic;	-- break CPU when AHB tracing stops    
  end record;

  type hclk_reg_type is record
    irq  : std_ulogic;
    oen  : std_ulogic;
  end record;                          
  
  constant TRACEN : boolean := (kbytes /= 0);
  signal tbi   : tracebuf_in_type;
  signal tbo   : tracebuf_out_type;

  signal tr, trin : tregtype;
  signal r, rin : reg_type;

  signal rh, rhin : hclk_reg_type;
  signal ahbsi2 : ahb_slv_in_type;
  signal hrdata2x : std_logic_vector(31 downto 0);
  
begin

  comb: process(rst, r, ahbsi, ahbsi2, dbgi, dsui, ahbmi, tr, tbo, hclken, rh, hrdata2x)
                
    variable v : reg_type;
    variable iuacc : std_ulogic;
    variable dbgmode, tstop : std_ulogic;
    variable rawindex : integer range 0 to (2**NBITS)-1;
    variable index : natural range 0 to NCPU-1;
    variable hasel1 : std_logic_vector(AREA_H-1 downto AREA_L);
    variable hasel2 : std_logic_vector(6 downto 2);
    variable tv : tregtype;
    variable vabufi : tracebuf_in_type;
    variable aindex : std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
    variable hirq : std_logic_vector(NAHBIRQ-1 downto 0);
    variable cpwd : std_logic_vector(15 downto 0);     
    variable hrdata : std_logic_vector(31 downto 0);
    variable bphit1, bphit2 : std_ulogic;    
    variable vh : hclk_reg_type;    
    
  begin
    
    v := r;
    iuacc := '0'; --v.slv.hready := '0';
    dbgmode := '0'; tstop := '1';
    v.dsubre := r.dsubre(1 downto 0) & dsui.break;
    v.dsuen := r.dsuen(1 downto 0) & dsui.enable;
    hrdata := r.slv.hrdata; 
    
    tv := tr; vabufi.enable := '0'; tv.bphit := '0';  tv.tbwr := '0';
    if (clk2x /= 0) then tv.bphit2 := tr.bphit; else tv.bphit2 := '0'; end if;
    vabufi.data := (others => '0'); vabufi.addr := (others => '0'); 
    vabufi.write := (others => '0'); aindex := (others => '0');
    hirq := (others => '0'); v.reset := (others => '0');
    if TRACEN then 
      aindex := tr.aindex + 1;
      if (clk2x /= 0) then vh.irq := tr.bphit or tr.bphit2; hirq(irq) := rh.irq;
      else hirq(irq) := tr.bphit; end if;
    end if;
    if hclken = '1' then
      v.slv.hready := '0'; v.act := '0';
    end if; 
    
-- check for AHB watchpoints
    bphit1 := '0'; bphit2 := '0';
    if TRACEN and ((ahbsi2.hready and tr.ahbactive) = '1') then
      if ((((tr.tbreg1.addr xor tr.haddr(31 downto 2)) and tr.tbreg1.mask) = zero32(29 downto 0)) and
         (((tr.tbreg1.read and not tr.hwrite) or (tr.tbreg1.write and tr.hwrite)) = '1')) 
      then bphit1 := '1'; end if;
      if ((((tr.tbreg2.addr xor tr.haddr(31 downto 2)) and tr.tbreg2.mask) = zero32(29 downto 0)) and
         (((tr.tbreg2.read and not tr.hwrite) or (tr.tbreg2.write and tr.hwrite)) = '1')) 
      then bphit2 := '1'; end if;
      if (bphit1 or bphit2) = '1' then
	if ((tr.enable and not r.act) = '1') and (tr.dcnten = '0') and 
	   (tr.delaycnt /= zero32(TBUFABITS-1 downto 0))
        then tv.dcnten := '1'; 
	else tv.enable := '0'; tv.bphit := tr.break; end if;
      end if;
    end if;    

-- generate AHB buffer inputs

    vabufi.write := "0000";
    if TRACEN then
      if (tr.enable = '1') and (r.act = '0') then
        vabufi.addr(TBUFABITS-1 downto 0) := tr.aindex;
        vabufi.data(127) := bphit1 or bphit2;
        vabufi.data(96+tbits-1 downto 96) := r.timer; 
        vabufi.data(94 downto 80) := ahbmi.hirq(15 downto 1);
        vabufi.data(79) := tr.hwrite;
        vabufi.data(78 downto 77) := tr.htrans;
        vabufi.data(76 downto 74) := tr.hsize;
        vabufi.data(73 downto 71) := tr.hburst;
        vabufi.data(70 downto 67) := tr.hmaster;
        vabufi.data(66) := tr.hmastlock;
        vabufi.data(65 downto 64) := ahbmi.hresp;
        if tr.hwrite = '1' then
          vabufi.data(63 downto 32) := ahbsi2.hwdata;
        else
          vabufi.data(63 downto 32) := ahbmi.hrdata;
        end if; 
        vabufi.data(31 downto 0) := tr.haddr;
      else
        vabufi.addr(TBUFABITS-1 downto 0) := tr.haddr(TBUFABITS+3 downto 4);
        vabufi.data := ahbsi2.hwdata & ahbsi2.hwdata & ahbsi2.hwdata & ahbsi2.hwdata;
      end if;

-- write trace buffer

      if (tr.enable and not r.act) = '1' then 
        if (tr.ahbactive and ahbsi2.hready) = '1' then
	    tv.aindex := aindex; tv.tbwr := '1';
            vabufi.enable := '1'; vabufi.write := "1111"; 
        end if;
      end if;

-- trace buffer delay counter handling

      if (tr.dcnten = '1') then
        if (tr.delaycnt = zero32(TBUFABITS-1 downto 0)) then
	  tv.enable := '0'; tv.dcnten := '0'; tv.bphit := tr.break;
          end if;
        if tr.tbwr = '1' then tv.delaycnt := tr.delaycnt - 1; end if;          
      end if;

-- save AHB transfer parameters

      if (ahbsi2.hready = '1' ) then
        tv.haddr := ahbsi2.haddr; tv.hwrite := ahbsi2.hwrite; tv.htrans := ahbsi2.htrans;
        tv.hsize := ahbsi2.hsize; tv.hburst := ahbsi2.hburst;
        tv.hmaster := ahbsi2.hmaster; tv.hmastlock := ahbsi2.hmastlock;
      end if;
      if tr.hsel = '1' then tv.hwdata := ahbsi2.hwdata; end if;
      if ahbsi2.hready = '1' then
        tv.hsel := ahbsi2.hsel(hindex);
        tv.ahbactive := ahbsi2.htrans(1);
      end if;
    end if;

    if r.slv.hsel  = '1' then
      if (clk2x = 0) then
        v.cnt := r.cnt - 1;
      else
        if (r.cnt /= "111") or (hclken = '1') then v.cnt := r.cnt - 1; end if; 
      end if;                          
    end if;
    
    if (r.slv.hready and hclken) = '1' then
      v.slv.hsel := '0'; --v.slv.act := '0';
    end if;
    
    for i in 0 to NCPU-1 loop
      if dbgi(i).dsumode = '1' then
        if r.dmsk(i) = '0' then
          dbgmode := '1';
          if hclken = '1' then v.act := '1'; end if;
        end if;
        v.bn(i) := '1';
      else
        tstop := '0';
      end if;
    end loop;

    if tstop = '0' then v.timer := r.timer + 1; end if;
    if (clk2x /= 0) then
      if hclken = '1' then v.tstop := tstop; end if;
      tstop := r.tstop;
    end if;

    cpwd := (others => '0');    
    for i in 0 to NCPU-1 loop
      v.bn(i) := v.bn(i) or (dbgmode and r.bmsk(i)) or (r.dsubre(1) and not r.dsubre(2));
      if TRACEN then v.bn(i) := v.bn(i) or (tr.bphit and not r.ss(i) and not r.act); end if;
      v.pwd(i) := dbgi(i).idle and (not dbgi(i).ipend) and not v.bn(i);
    end loop;
    cpwd(NCPU-1 downto 0) := r.pwd;  

    if (ahbsi2.hready and ahbsi2.hsel(hindex)) = '1' then
      if (ahbsi2.htrans(1) = '1') then
        v.slv.hsel := '1';      
        v.slv.haddr := ahbsi2.haddr(PROC_H downto 0);
        v.slv.hwrite := ahbsi2.hwrite;
        v.cnt := "111";
      end if;
    end if;


    
    for i in 0 to NCPU-1 loop
      v.en(i) := r.dsuen(2) and dbgi(i).dsu;
    end loop;

    rawindex := conv_integer(r.slv.haddr(PROC_H downto PROC_L));    
    if ncpu = 1 then index := 0; else
      if rawindex > ncpu then index := ncpu-1; else index := rawindex; end if;
    end if;

    hasel1 := r.slv.haddr(AREA_H-1 downto AREA_L);
    hasel2 := r.slv.haddr(6 downto 2);
    if r.slv.hsel = '1' then
      case hasel1 is 
        
        when "000" =>  -- DSU registers
          if r.cnt(2 downto 0) = "110" then
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;          
          end if;
          hrdata := (others => '0');          
          case hasel2 is
            when "00000" =>
              if (r.slv.hwrite and hclken) = '1' then
                v.te(index) := ahbsi2.hwdata(0);
                v.be(index) := ahbsi2.hwdata(1);
                v.bw(index) := ahbsi2.hwdata(2);
                v.bs(index) := ahbsi2.hwdata(3);
                v.bx(index) := ahbsi2.hwdata(4);                
                v.bz(index) := ahbsi2.hwdata(5);                
                v.reset(index) := ahbsi2.hwdata(9);                
                v.halt(index) := ahbsi2.hwdata(10);                
              else
                hrdata(0) := r.te(index);
                hrdata(1) := r.be(index);
                hrdata(2) := r.bw(index);
                hrdata(3) := r.bs(index);
                hrdata(4) := r.bx(index);
                hrdata(5) := r.bz(index);
                hrdata(6) := dbgi(index).dsumode;
                hrdata(7) := r.dsuen(2);
                hrdata(8) := r.dsubre(2);
                hrdata(9) := not dbgi(index).error;
                hrdata(10) := dbgi(index).halt;
                hrdata(11) := dbgi(index).pwd;
              end if;
            when "00010" =>  -- timer
              if (r.slv.hwrite and hclken) = '1' then
                v.timer := ahbsi2.hwdata(tbits-1 downto 0);
              else
                hrdata(tbits-1 downto 0) := r.timer;
              end if;
            when "01000" =>
              if (r.slv.hwrite and hclken) = '1' then
                v.bn := ahbsi2.hwdata(NCPU-1 downto 0);
                v.ss := ahbsi2.hwdata(16+NCPU-1 downto 16);
              else
                hrdata(NCPU-1 downto 0) := r.bn;
                hrdata(16+NCPU-1 downto 16) := r.ss; 
              end if;
            when "01001" =>
              if (r.slv.hwrite and hclken) = '1' then
                v.bmsk(NCPU-1 downto 0) := ahbsi2.hwdata(NCPU-1 downto 0);
                v.dmsk(NCPU-1 downto 0) := ahbsi2.hwdata(NCPU-1+16 downto 16);
              else
                hrdata(NCPU-1 downto 0) := r.bmsk;
                hrdata(NCPU-1+16 downto 16) := r.dmsk;
              end if;
            when "10000" =>
	      if TRACEN then
	        hrdata((TBUFABITS + 15) downto 16) := tr.delaycnt;
	        hrdata(2 downto 0) := tr.break & tr.dcnten & tr.enable;
	        if (r.slv.hwrite and hclken) = '1' then
	          tv.delaycnt := ahbsi2.hwdata((TBUFABITS+ 15) downto 16);
	          tv.break  := ahbsi2.hwdata(2);                  
	          tv.dcnten := ahbsi2.hwdata(1);
	          tv.enable := ahbsi2.hwdata(0);
	        end if;
	      end if;
            when "10001" =>
	      if TRACEN then
	        hrdata((TBUFABITS - 1 + 4) downto 4) := tr.aindex;
	        if (r.slv.hwrite and hclken) = '1' then
		  tv.aindex := ahbsi2.hwdata((TBUFABITS - 1 + 4) downto 4);
	        end if;
	      end if;
            when "10100" =>
	      if TRACEN then
	        hrdata(31 downto 2) := tr.tbreg1.addr; 
	        if (r.slv.hwrite and hclken) = '1' then
	          tv.tbreg1.addr := ahbsi2.hwdata(31 downto 2); 
	        end if;
	      end if;
            when "10101" =>
	      if TRACEN then
	        hrdata := tr.tbreg1.mask & tr.tbreg1.read & tr.tbreg1.write; 
	        if (r.slv.hwrite and hclken) = '1' then
	          tv.tbreg1.mask := ahbsi2.hwdata(31 downto 2); 
	          tv.tbreg1.read := ahbsi2.hwdata(1); 
	          tv.tbreg1.write := ahbsi2.hwdata(0); 
	        end if;
	      end if;
            when "10110" =>
	      if TRACEN then
	        hrdata(31 downto 2) := tr.tbreg2.addr; 
	        if (r.slv.hwrite and hclken) = '1' then
	          tv.tbreg2.addr := ahbsi2.hwdata(31 downto 2); 
	        end if;
	      end if;
            when "10111" =>
	      if TRACEN then
	        hrdata := tr.tbreg2.mask & tr.tbreg2.read & tr.tbreg2.write; 
	        if (r.slv.hwrite and hclken) = '1' then
	          tv.tbreg2.mask := ahbsi2.hwdata(31 downto 2); 
	          tv.tbreg2.read := ahbsi2.hwdata(1); 
	          tv.tbreg2.write := ahbsi2.hwdata(0); 
	        end if;
	      end if;
            when others =>
          end case;

        when "010"  =>  -- AHB tbuf
	  if TRACEN then
            if r.cnt(2 downto 0) = "101" then
              if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
            end if;
            vabufi.enable := not (tr.enable and not r.act);
            case tr.haddr(3 downto 2) is
            when "00" =>
	      hrdata := tbo.data(127 downto 96);
	      if (r.slv.hwrite and hclken) = '1' then 
	        vabufi.write(3) := vabufi.enable and v.slv.hready;
	      end if;
            when "01" =>
	      hrdata := tbo.data(95 downto 64);
	      if (r.slv.hwrite and hclken) = '1' then 
	        vabufi.write(2) := vabufi.enable and v.slv.hready;
	      end if;
            when "10" =>
	      hrdata := tbo.data(63 downto 32);
	      if (r.slv.hwrite and hclken) = '1' then 
	        vabufi.write(1) := vabufi.enable and v.slv.hready;
	      end if;
            when others =>
	      hrdata := tbo.data(31 downto 0);
	      if (r.slv.hwrite and hclken) = '1' then 
	        vabufi.write(0) := vabufi.enable and v.slv.hready;
	      end if;
	    end case;
	  else
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
	  end if;
        when "011" | "001"  =>  -- IU reg file, IU tbuf
          iuacc := '1';
          hrdata := dbgi(index).data;
          if r.cnt(2 downto 0) = "101" then
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
          end if;
        when "100" =>  -- IU reg access
          iuacc := '1';
          hrdata := dbgi(index).data;
          if r.cnt(1 downto 0) = "11" then
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
          end if;
        when "111" => -- DSU ASI
          if r.cnt(2 downto 1) = "11" then iuacc := '1'; else iuacc := '0'; end if;
          if (dbgi(index).crdy = '1') or (r.cnt = "000") then
            if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
          end if;
          hrdata := dbgi(index).data;          
        when others =>
          if hclken = '1' then v.slv.hready := '1'; else v.slv.hready2 := '1'; end if;
      end case;
      if (r.slv.hready and hclken and not v.slv.hsel) = '1' then v.slv.hready := '0'; end if;
      if (clk2x /= 0) and (r.slv.hready2 and hclken) = '1' then v.slv.hready := '1'; end if;
    end if;

    if r.slv.hsel = '1' then
      if (r.slv.hwrite and hclken) = '1' then v.slv.hwdata := ahbsi2.hwdata; end if;
      if (clk2x = 0) or ((r.slv.hready or r.slv.hready2) = '0') then
        v.slv.hrdata := hrdata;
      end if;
    end if;    
        
    if ((ahbsi2.hready and ahbsi2.hsel(hindex)) = '1') and (ahbsi2.htrans(1) = '0') then
      if (clk2x = 0) or (r.slv.hsel = '0') then  
        v.slv.hready := '1';
      end if;
    end if;

    if (clk2x /= 0) and (r.slv.hready = '1') then v.slv.hready2 := '0'; end if;
    if v.slv.hsel = '0' then v.slv.hready := '1'; end if;
   
    vh.oen := '0';
    if (clk2x /= 0) then
      if (hclken and r.slv.hsel and (r.slv.hready2 or v.slv.hready)) = '1'
      then vh.oen := '1'; end if;
      if (r.slv.hsel = '1') and (r.cnt = "111") and (hclken = '0') then iuacc := '0'; end if;
    end if;

    
    if rst = '0' then
      v.bn := (others => r.dsubre(2)); v.bmsk := (others => '0');
      v.dmsk := (others => '0');
      v.ss := (others => '0'); v.timer := (others => '0'); v.slv.hsel := '0';
      for i in 0 to NCPU-1 loop
        v.bw(i) := r.dsubre(2); v.be(i) := r.dsubre(2); 
        v.bx(i) := r.dsubre(2); v.bz(i) := r.dsubre(2); 
        v.bs(i) := '0'; v.te(i) := '0';
      end loop;
      tv.ahbactive := '0'; tv.enable := '0';
      tv.hsel := '0'; tv.dcnten := '0';
      tv.tbreg1.read := '0'; tv.tbreg1.write := '0';
      tv.tbreg2.read := '0'; tv.tbreg2.write := '0';
      v.slv.hready := '1'; v.halt := (others => '0');
    end if;
    vabufi.enable := vabufi.enable and not ahbsi.scanen;
    vabufi.diag := ahbsi.testen & "000";
    rin <= v; trin <= tv; tbi <= vabufi;

    for i in 0 to NCPU-1 loop
      dbgo(i).tenable <= r.te(i);
      dbgo(i).dsuen <= r.en(i);  
      dbgo(i).dbreak <= r.bn(i); -- or (dbgmode and r.bmsk(i));
      if conv_integer(r.slv.haddr(PROC_H downto PROC_L)) = i then
        dbgo(i).denable <= iuacc;
      else
        dbgo(i).denable <= '0';
      end if;
      dbgo(i).step <= r.ss(i);    
      dbgo(i).berror <= r.be(i);
      dbgo(i).bsoft <= r.bs(i);
      dbgo(i).bwatch <= r.bw(i);
      dbgo(i).btrapa <= r.bx(i);
      dbgo(i).btrape <= r.bz(i);
      dbgo(i).daddr <= r.slv.haddr(PROC_L-1 downto 2);
      dbgo(i).ddata <= r.slv.hwdata;    
      dbgo(i).dwrite <= r.slv.hwrite;
      dbgo(i).halt <= r.halt(i);
      dbgo(i).reset <= r.reset(i);
      dbgo(i).timer(tbits-1 downto 0) <= r.timer; 
      dbgo(i).timer(30 downto tbits) <= (others => '0');      
    end loop;
    
    ahbso.hconfig <= hconfig;
    ahbso.hresp <= HRESP_OKAY;
    ahbso.hready <= r.slv.hready;
    if (clk2x = 0) then 
      ahbso.hrdata <= r.slv.hrdata;
    else
      ahbso.hrdata <= hrdata2x;
    end if;
    ahbso.hsplit <= (others => '0');
    ahbso.hcache <= '0';
    ahbso.hirq   <= hirq;
    ahbso.hindex <= hindex;    

    dsuo.active <= r.act;
    dsuo.tstop <= tstop;
    dsuo.pwd   <= cpwd;
    
    rhin <= vh;
    
  end process;   

  comb2gen0 : if (clk2x /= 0) generate    
    ag0 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hmastlock, hclken, ahbsi2.hmastlock);
    ag1 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hwrite, hclken, ahbsi2.hwrite);
    ag2 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hready, hclken, ahbsi2.hready);
    gen3 : for i in ahbsi.haddr'range generate
      ag3 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.haddr(i), hclken, ahbsi2.haddr(i));
    end generate;
    gen4 : for i in ahbsi.htrans'range generate 
      ag4 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.htrans(i), hclken, ahbsi2.htrans(i));
    end generate;
    gen5 : for i in ahbsi.hwdata'range generate
      ag5 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hwdata(i), hclken, ahbsi2.hwdata(i));
    end generate;
    gen6 : for i in ahbsi.hsize'range generate 
      ag6 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hsize(i), hclken, ahbsi2.hsize(i));
    end generate;
    gen7 : for i in ahbsi.hburst'range generate
      ag7 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hburst(i), hclken, ahbsi2.hburst(i));
    end generate;
    gen8 : for i in ahbsi.hmaster'range generate
      ag8 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hmaster(i), hclken, ahbsi2.hmaster(i));
    end generate;
    gen9 : for i in ahbsi.hsel'range generate
      ag9 : clkand generic map (tech => 0, ren => 0) port map (ahbsi.hsel(i), hclken, ahbsi2.hsel(i));
    end generate;

    gen10 : for i in hrdata2x'range generate
      ag10 : clkand generic map (tech => 0, ren => 0) port map (r.slv.hrdata(i), rh.oen, hrdata2x(i)); 
    end generate;
    
    reg2 : process(hclk)
    begin
      if rising_edge(hclk) then rh <= rhin; end if;
    end process;
  end generate;

  comb2gen1 : if (clk2x = 0) generate
    ahbsi2 <= ahbsi; rh.irq <= '0'; rh.oen <= '0'; hrdata2x <= (others => '0');
  end generate;
    
  reg : process(cpuclk)
  begin
    if rising_edge(cpuclk) then r <= rin; end if;
  end process;

    
  tb0 : if TRACEN generate
    treg : process(cpuclk)
    begin if rising_edge(cpuclk) then tr <= trin; end if; end process;
    mem0 : tbufmem
    generic map (tech => tech, tbuf => kbytes) port map (cpuclk, tbi, tbo);
-- pragma translate_off
    bootmsg : report_version 
    generic map ("dsu3_" & tost(hindex) &
    ": LEON3 Debug support unit + AHB Trace Buffer, " & tost(kbytes) & " kbytes");
-- pragma translate_on
  end generate;
    
  notb : if not TRACEN generate
-- pragma translate_off
    bootmsg : report_version 
    generic map ("dsu3_" & tost(hindex) &
    ": LEON3 Debug support unit");
-- pragma translate_on
  end generate;

end;
