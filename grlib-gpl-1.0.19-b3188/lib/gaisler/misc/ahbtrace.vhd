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
-- Entity: 	ahbtrace
-- File:	ahbtrace.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	AHB trace unit
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library gaisler;

entity ahbtrace is
  generic (
    hindex  : integer := 0;
    ioaddr  : integer := 16#000#;
    iomask  : integer := 16#E00#;
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 1); 
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type
  );
end; 

architecture rtl of ahbtrace is

constant TBUFABITS : integer := log2(kbytes) + 6;
constant TIMEBITS  : integer := 32;

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBTRACE, 0, 0, irq),
  4 => ahb_iobar (ioaddr, iomask),
  others => zero32);

type tracebuf_in_type is record 
  addr             : std_logic_vector(11 downto 0);
  data             : std_logic_vector(127 downto 0);
  enable           : std_logic;
  write            : std_logic_vector(3 downto 0);
end record;

type tracebuf_out_type is record 
  data             : std_logic_vector(127 downto 0);
end record;

type trace_break_reg is record
  addr          : std_logic_vector(31 downto 2);
  mask          : std_logic_vector(31 downto 2);
  read          : std_logic;
  write         : std_logic;
end record;

type regtype is record
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
  timer         : std_logic_vector(TIMEBITS-1 downto 0);
  aindex  	: std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index

  enable        : std_logic;	-- trace enable
  bahb          : std_logic;	-- break on AHB watchpoint hit
  bhit          : std_logic;	-- breakpoint hit
  dcnten        : std_logic;	-- delay counter enable
  delaycnt      : std_logic_vector(TBUFABITS - 1 downto 0); -- delay counter

  tbreg1	: trace_break_reg;
  tbreg2	: trace_break_reg;
end record;

signal tbi   : tracebuf_in_type;
signal tbo   : tracebuf_out_type;

signal enable : std_logic_vector(1 downto 0);

signal r, rin : regtype;

begin

  ctrl : process(rst, ahbmi, ahbsi, r, tbo)
  variable v : regtype;
  variable vabufi : tracebuf_in_type;
  variable regsd : std_logic_vector(31 downto 0);   -- data from registers
  variable aindex : std_logic_vector(TBUFABITS - 1 downto 0); -- buffer index
  variable bphit : std_logic;
  variable bufdata : std_logic_vector(127 downto 0);
  variable hirq : std_logic_vector(NAHBIRQ-1 downto 0); 

  begin

    v := r; regsd := (others => '0'); vabufi.enable := '0'; 
    vabufi.data := (others => '0'); vabufi.addr := (others => '0'); 
    vabufi.write := (others => '0'); bphit := '0'; 
    v.hready := r.hready2; v.hready2 := r.hready3; v.hready3 := '0'; 
    bufdata := tbo.data;
    hirq := (others => '0'); hirq(irq) := r.bhit;

-- trace buffer index and delay counters
    if r.enable = '1' then v.timer := r.timer + 1; end if;
    aindex := r.aindex + 1;

-- check for AHB watchpoints
    if (ahbsi.hready and r.ahbactive ) = '1' then
      if ((((r.tbreg1.addr xor r.haddr(31 downto 2)) and r.tbreg1.mask) = zero32(29 downto 0)) and
         (((r.tbreg1.read and not r.hwrite) or (r.tbreg1.write and r.hwrite)) = '1')) 
        or ((((r.tbreg2.addr xor r.haddr(31 downto 2)) and r.tbreg2.mask) = zero32(29 downto 0)) and
           (((r.tbreg2.read and not r.hwrite) or (r.tbreg2.write and r.hwrite)) = '1')) 
      then
	if (r.enable = '1') and (r.dcnten = '0') and 
	   (r.delaycnt /= zero32(TBUFABITS-1 downto 0))
        then v.dcnten := '1'; 
	else bphit := '1'; v.enable := '0'; end if;
      end if;
    end if;

-- generate buffer inputs
      vabufi.write := "0000";
      if r.enable = '1' then
        vabufi.addr(TBUFABITS-1 downto 0) := r.aindex;
        vabufi.data(127 downto 96) := r.timer; 
        vabufi.data(95) := bphit;
  	vabufi.data(94 downto 80) := ahbmi.hirq(15 downto 1);
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
      else
        vabufi.addr(TBUFABITS-1 downto 0) := r.haddr(TBUFABITS+3 downto 4);
        vabufi.data := ahbsi.hwdata & ahbsi.hwdata & 
		       ahbsi.hwdata & ahbsi.hwdata;
      end if;

-- write trace buffer

      if r.enable = '1' then 
        if (r.ahbactive and ahbsi.hready) = '1' then
          v.aindex := aindex;
          vabufi.enable := '1'; vabufi.write := "1111";
        end if;
      end if;

-- trace buffer delay counter handling

    if (r.dcnten = '1') then
      if (r.delaycnt = zero32(TBUFABITS-1 downto 0)) then
	v.enable := '0'; v.dcnten := '0';
      end if;
      v.delaycnt := r.delaycnt - 1;
    end if;

-- save AHB transfer parameters

    if (ahbsi.hready = '1' ) then
      v.haddr := ahbsi.haddr; v.hwrite := ahbsi.hwrite; v.htrans := ahbsi.htrans;
      v.hsize := ahbsi.hsize; v.hburst := ahbsi.hburst;
      v.hmaster := ahbsi.hmaster; v.hmastlock := ahbsi.hmastlock;
    end if;
    if r.hsel = '1' then v.hwdata := ahbsi.hwdata; end if;
    if ahbsi.hready = '1' then
      v.hsel := ahbsi.hsel(hindex);
      v.ahbactive := ahbsi.htrans(1);
    end if;

-- AHB slave access to DSU registers and trace buffers

    if (r.hsel and not r.hready) = '1' then
      if r.haddr(16) = '0' then		-- registers
        v.hready := '1';
        case r.haddr(4 downto 2) is
        when "000" =>
	  regsd((TBUFABITS + 15) downto 16) := r.delaycnt;
	  regsd(1 downto 0) := r.dcnten & r.enable;
	  if r.hwrite = '1' then
	    v.delaycnt := ahbsi.hwdata((TBUFABITS+ 15) downto 16); 
	    v.dcnten := ahbsi.hwdata(1);
	    v.enable := ahbsi.hwdata(0);
	  end if;
        when "001" =>
	    regsd((TBUFABITS - 1 + 4) downto 4) := r.aindex;
	    if r.hwrite = '1' then
	      v.aindex := ahbsi.hwdata((TBUFABITS- 1) downto 0); 
	    end if;
        when "010" =>
	  regsd((TIMEBITS - 1) downto 0) := r.timer; 
	  if r.hwrite = '1' then
	    v.timer := ahbsi.hwdata((TIMEBITS- 1) downto 0); 
	  end if;
        when "100" =>
	  regsd(31 downto 2) := r.tbreg1.addr; 
	  if r.hwrite = '1' then
	    v.tbreg1.addr := ahbsi.hwdata(31 downto 2); 
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
      else            	-- read/write access to trace buffer
          if r.hwrite = '1' then v.hready := '1'; else v.hready2 := not (r.hready2 or r.hready); end if;
          vabufi.enable := not r.enable;
	  bufdata := tbo.data;
          case r.haddr(3 downto 2) is
          when "00" =>
	    v.hwdata := bufdata(127 downto 96);
	    if r.hwrite = '1' then 
	      vabufi.write(3) := vabufi.enable;
	    end if;
          when "01" =>
	    v.hwdata := bufdata(95 downto 64);
	    if r.hwrite = '1' then 
	      vabufi.write(2) := vabufi.enable;
	    end if;
          when "10" =>
	    v.hwdata := bufdata(63 downto 32);
	    if r.hwrite = '1' then 
	      vabufi.write(1) := vabufi.enable;
	    end if;
          when others =>
	    v.hwdata := bufdata(31 downto 0);
	    if r.hwrite = '1' then 
	      vabufi.write(0) := vabufi.enable;
	    end if;
	  end case;
      end if;
    end if;

    if ((ahbsi.hsel(hindex) and ahbsi.hready) = '1') and 
          ((ahbsi.htrans = HTRANS_BUSY) or (ahbsi.htrans = HTRANS_IDLE))
    then v.hready := '1'; end if;

    if rst = '0' then
      v.ahbactive := '0'; v.enable := '0'; v.timer := (others => '0');
      v.hsel := '0'; v.dcnten := '0'; v.bhit := '0';
      v.tbreg1.read := '0'; v.tbreg1.write := '0';
      v.tbreg2.read := '0'; v.tbreg2.write := '0';
    end if;

    tbi <= vabufi;
    rin <= v;

    ahbso.hconfig <= hconfig;
    ahbso.hirq    <= hirq;
    ahbso.hsplit  <= (others => '0');
    ahbso.hcache  <= '0';
    ahbso.hrdata <= r.hwdata;
    ahbso.hready <= r.hready;
    ahbso.hindex <= hindex;

  end process;

  ahbso.hresp <= HRESP_OKAY;

  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

--  mem0 : tbufmem
--  generic map (tech => tech, tbuf => kbytes) port map (clk, tbi, tbo);

  enable <= tbi.enable & tbi.enable;
  mem0 : for i in 0 to 1 generate
    ram0 : syncram64 generic map (tech => tech, abits => TBUFABITS)
      port map (clk, tbi.addr(TBUFABITS-1 downto 0), tbi.data(((i*64)+63) downto (i*64)),
                 tbo.data(((i*64)+63) downto (i*64)), enable, tbi.write(i*2+1 downto i*2));
  end generate;

-- pragma translate_off
    bootmsg : report_version 
    generic map ("ahbtrace" & tost(hindex) &
    ": AHB Trace Buffer, " & tost(kbytes) & " kbytes");
-- pragma translate_on

end;


