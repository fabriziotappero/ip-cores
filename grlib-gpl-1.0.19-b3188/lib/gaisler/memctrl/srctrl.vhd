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
-- Entity: 	srctrl
-- File:	srctrl.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Modified:    Marko Isomaki - Gaisler Research
-- Description:	32-bit SRAM memory controller with read-modify-write
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use grlib.devices.all;
use gaisler.memctrl.all;

entity srctrl is
  generic (
    hindex  : integer := 0;
    romaddr : integer := 0;
    rommask : integer := 16#ff0#;
    ramaddr : integer := 16#400#;
    rammask : integer := 16#ff0#;
    ioaddr  : integer := 16#200#;
    iomask  : integer := 16#ff0#;
    ramws   : integer := 0;
    romws   : integer := 2;
    iows    : integer := 2;
    rmw     : integer := 0;		-- read-modify-write enable
    prom8en : integer := 0;
    oepol   : integer := 0;
    srbanks : integer range 1 to 5  := 1;
    banksz  : integer range 0 to 13 := 13;
    romasel : integer range 0 to 28 := 19
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    sri     : in  memory_in_type;
    sro     : out memory_out_type;
    sdo     : out sdctrl_out_type
  );
end;

architecture rtl of srctrl is

constant VERSION : amba_version_type := 0;
constant hconfig : ahb_config_type := (
  0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_SRCTRL, 0, VERSION, 0),
  4 => ahb_membar(romaddr, '1', '1', rommask),
  5 => ahb_membar(ramaddr, '1', '1', rammask),
  6 => ahb_membar(ioaddr, '0', '0', iomask),
  others => zero32);

type srcycletype is (idle, read1, read2, write1, write2, rmw1, rmw2, rmw3);
type prom8cycletype is (idle, read1, read2);

function byteswap (rdata, wdata, addr, size : std_logic_vector) return std_logic_vector is
variable tmp : std_logic_vector(31 downto 0);
variable a : std_logic_vector(1 downto 0);
begin
  tmp := rdata; a := addr(1 downto 0);
  if size(0) = '0' then
    case a is
    when "00" => tmp(31 downto 24) := wdata(31 downto 24);
    when "01" => tmp(23 downto 16) := wdata(23 downto 16);
    when "10" => tmp(15 downto 8) := wdata(15 downto 8);
    when others => tmp(7 downto 0) := wdata(7 downto 0);
    end case;
  else
    if addr(1) = '0' then tmp(31 downto 16) := wdata(31 downto 16);
    else tmp(15 downto 0) := wdata(15 downto 0); end if;
  end if;
  return(tmp);
end;

-- local registers

type reg_type is record
  hready        : std_ulogic;
  hsel          : std_ulogic;
  hmbsel	: std_logic_vector(0 to 2);
  bdrive        : std_ulogic;
  nbdrive       : std_ulogic;
  srstate	: srcycletype;
  haddr         : std_logic_vector(31 downto 0);
  hrdata        : std_logic_vector(31 downto 0);
  hwdata        : std_logic_vector(31 downto 0);
  hwrite        : std_ulogic;
  htrans        : std_logic_vector(1 downto 0);
  hburst        : std_logic_vector(2 downto 0);
  hresp 	: std_logic_vector(1 downto 0);
  size		: std_logic_vector(1 downto 0);
  read  	: std_ulogic;
  oen   	: std_ulogic;
  ramsn         : std_ulogic;
  romsn         : std_ulogic;
  vramsn 	: std_logic_vector(4 downto 0);
  ramoen	: std_logic_vector(4 downto 0);
  vromsn 	: std_logic_vector(1 downto 0);
  writen	: std_ulogic;
  wen   	: std_logic_vector(3 downto 0);
  mben		: std_logic_vector(3 downto 0);
  ws    	: std_logic_vector(3 downto 0);
  iosn   	: std_ulogic;
-- 8-bit prom access
  pr8state      : prom8cycletype;
  data8         : std_logic_vector(23 downto 0);
  ready8        : std_ulogic;
  bwidth        : std_logic_vector(1 downto 0);
end record;

signal r, ri : reg_type;

-- vectored output enable to data pads
signal rbdrive, ribdrive : std_logic_vector(31 downto 0);
attribute syn_preserve : boolean;
attribute syn_preserve of rbdrive : signal is true;

begin

  ctrl : process(rst, ahbsi, r, sri, rbdrive)
  variable v       : reg_type;		-- local variables for registers
  variable dqm     : std_logic_vector(3 downto 0);
  variable adec    : std_logic_vector(1 downto 0);
  variable rams    : std_logic_vector(4 downto 0);
  variable roms    : std_logic_vector(1 downto 0);
  variable haddr   : std_logic_vector(31 downto 0);
  variable hrdata  : std_logic_vector(31 downto 0);
  variable hsize   : std_logic_vector(1 downto 0);
  variable hwrite  : std_ulogic;
  variable htrans  : std_logic_vector(1 downto 0);
  variable vramws, vromws, viows : std_logic_vector(3 downto 0);
-- 8-bit prom access
  variable romsn   : std_ulogic;
  variable bdrive  : std_ulogic;
  variable oen     : std_ulogic;
  variable writen  : std_ulogic;
  variable hready  : std_ulogic;
  variable ws      : std_logic_vector(3 downto 0);
  variable hwdata  : std_logic_vector(31 downto 0);
  variable prom8sel : std_ulogic;
  variable vbdrive : std_logic_vector(31 downto 0);
  variable sbdrive  : std_ulogic;
  begin

-- Variable default settings to avoid latches

    v := r; v.hresp := HRESP_OKAY; v.hrdata := sri.data; hrdata := r.hrdata;
    vramws := conv_std_logic_vector(ramws, 4); vbdrive := rbdrive;
    vromws := conv_std_logic_vector(romws, 4);
    viows := conv_std_logic_vector(iows, 4);
    v.bwidth := sri.bwidth;
    if (prom8en = 1) and (r.bwidth = "00") then prom8sel := '1';
    else prom8sel := '0'; end if;

    if (ahbsi.hready = '1') then
      if (ahbsi.hsel(hindex) and ahbsi.htrans(1)) = '1' then
        v.size := ahbsi.hsize(1 downto 0); v.hwrite := ahbsi.hwrite;
        v.htrans := ahbsi.htrans; v.hburst := ahbsi.hburst;
	v.hsel := '1'; v.hmbsel := ahbsi.hmbsel(0 to 2);
        v.haddr := ahbsi.haddr; v.hready := '0';
      else
	v.hsel := '0';
      end if;
    end if;

    if (r.hsel = '1') and (ahbsi.hready = '0') then
      haddr := r.haddr;  hsize := r.size;
      htrans := r.htrans; hwrite := r.hwrite;
    else
      haddr := ahbsi.haddr;  hsize := ahbsi.hsize(1 downto 0);
      htrans := ahbsi.htrans; hwrite := ahbsi.hwrite;
    end if;

-- chip-select decoding
   adec := haddr(banksz+14 downto banksz+13);

   rams := '0' & decode(adec);

   case srbanks is
   when 1 => rams := "00001";
   when 2 => rams := "000" & (rams(3 downto 2) or rams(1 downto 0));
   when others => null;
   end case;
   roms := haddr(romasel) & not haddr(romasel);

-- generate write strobes

    if rmw = 1 then dqm := "0000"; else
      case r.size is
      when "00" =>
        case r.haddr(1 downto 0) is
        when "00" => dqm := "1110";
        when "01" => dqm := "1101";
        when "10" => dqm := "1011";
        when others => dqm := "0111";
        end case;
      when "01" =>
        if r.haddr(1) = '0' then dqm := "1100"; else  dqm := "0011"; end if;
      when others => dqm := "0000";
      end case;
    end if;

-- main FSM

    case r.srstate is
    when idle =>
      if (v.hsel = '1') and not
	(((v.ramsn or r.romsn) = '0') or ((v.romsn or r.ramsn) = '0')) and not
	((v.hmbsel(0) and not hwrite and prom8sel) = '1' and prom8en = 1)
      then
        v.hready := '0';
	v.ramsn := not v.hmbsel(1); v.romsn := not v.hmbsel(0);
	v.iosn := not v.hmbsel(2);
	v.read := not hwrite;
	if hwrite = '1' then
	  if (rmw = 1) and (hsize(1) = '0') and (v.hmbsel(1) = '1') then
	    v.srstate := rmw1; v.read := '1';
	  else v.srstate := write1; end if;
	elsif ahbsi.htrans = "10" then v.srstate := read1;
	else v.srstate := read2; end if;
	v.oen := not v.read;
      else
	v.ramsn := '1'; v.romsn := '1'; v.bdrive := '1'; v.oen := '1';
	 v.iosn := '1';
      end if;
      if v.romsn = '0' then v.ws := vromws;
      elsif v.iosn = '0' then v.ws := viows;
      else v.ws := vramws; end if;
    when read1 =>
      v.srstate := read2;
    when read2 =>
      v.ws := r.ws -1; v.oen := '0';
      if r.ws = "0000" then
	v.srstate := idle; v.hready := '1'; v.haddr := ahbsi.haddr;
	v.ramsn := not (ahbsi.hmbsel(1) and ahbsi.htrans(1));
	v.romsn := not (ahbsi.hmbsel(0) and ahbsi.htrans(1));
	v.oen := not (ahbsi.hsel(hindex) and ahbsi.htrans(1) and not ahbsi.hwrite);
      end if;
    when write1 =>
      if r.romsn = '0' then v.ws := vromws;
      elsif v.iosn = '0' then v.ws := viows;
      else v.ws := vramws; end if;
      v.srstate := write2; v.bdrive := '0'; v.wen := dqm; v.writen := '0';
      v.hwdata := ahbsi.hwdata;
    when write2 =>
      if r.ws = "0000" then
        v.srstate := idle; v.bdrive := '1'; v.wen := "1111"; v.writen := '1';
        v.hready := '1';
      end if;
      v.ws := r.ws -1;
    when rmw1 =>
      if (rmw = 1) then v.oen := '0';
        v.srstate := rmw2;
        v.hwdata := ahbsi.hwdata;
      end if;
    when rmw2 =>
      if (rmw = 1) then
        v.ws := r.ws -1;
        if r.ws = "0000" then v.oen := '1'; v.srstate := rmw3; end if;
      end if;
    when rmw3 =>
      if (rmw = 1) then
        v.hwdata := byteswap(r.hrdata, r.hwdata, r.haddr, r.size);
        v.srstate := write2; v.bdrive := '0'; v.wen := dqm; v.writen := '0';
      end if;
      if r.romsn = '0' then v.ws := vromws; else v.ws := vramws; end if;
    end case;

    if (ahbsi.hready and ahbsi.hsel(hindex) ) = '1' then
      if ahbsi.htrans(1) = '0' then v.hready := '1'; end if;
    end if;

-- 8-bit PROM access FSM
    if prom8en = 1 then
      hready := '0'; ws := v.ws; v.ready8 := '0';
      bdrive := '1'; oen := '1'; writen := '1'; romsn := '1';

      if r.ready8 = '1' then
	v.data8 := r.data8(15 downto 0) & r.hrdata(31 downto 24);
	case r.size is
	when "00" => hrdata :=  r.hrdata(31 downto 24) &
	  r.hrdata(31 downto 24) &  r.hrdata(31 downto 24) &  r.hrdata(31 downto 24);
	when "01" => hrdata := r.data8(7 downto 0) &  r.hrdata(31 downto 24) &
		r.data8(7 downto 0) & r.hrdata(31 downto 24);
	when others => hrdata := r.data8 & r.hrdata(31 downto 24);
	end case;
      end if;

      case r.pr8state is
	when idle =>
	  if ( (v.hsel and v.hmbsel(0) and not hwrite and prom8sel) = '1')
          then
	    romsn := '0'; v.pr8state := read1; oen := '0';
	  end if;
     	when read1 =>
	  oen := '0'; romsn := '0'; v.pr8state := read2; ws := vromws;
	when read2 =>
	  oen := '0'; ws := r.ws - 1; romsn := '0';
	  if r.ws = "0000" then
	    v.haddr(1 downto 0) := r.haddr(1 downto 0) + 1;
	    if (r.size = "00") or ((r.size = "01") and  (r.haddr(0) = '1'))
	      or r.haddr(1 downto 0) = "11"
	    then
	      hready := '1'; v.pr8state := idle; oen := '1';
	    else
	      v.pr8state := read1;
	    end if;
	    v.ready8 := '1';
	  end if;
	when others =>
	  v.pr8state := idle;
      end case;

      v.romsn := v.romsn and romsn; v.bdrive := v.bdrive and bdrive;
      v.oen := v.oen and oen; v.writen := v.writen and writen;
      v.hready := v.hready or hready; v.ws := ws;
    end if;

    if (v.oen or v.ramsn) = '0' then v.ramoen := not rams;
    else v.ramoen := (others => '1'); end if;

    if v.romsn = '0' then v.vromsn := not roms;
    else v.vromsn := (others => '1'); end if;

    if v.ramsn = '0' then v.vramsn := not rams;
    else v.vramsn := (others => '1'); end if;

    if v.read = '1' then v.mben := "0000"; else v.mben := v.wen; end if;

    v.nbdrive := not v.bdrive;

    if oepol = 1 then sbdrive := r.nbdrive; vbdrive := (others => v.nbdrive);
    else sbdrive := r.bdrive; vbdrive := (others => v.bdrive);  end if;

-- reset

    if rst = '0' then
      v.srstate	:= idle; v.hsel := '0'; v.writen := '1';
      v.wen := (others => '1'); v.hready := '1'; v.read := '1';
      v.ws := (others => '0');
      if prom8en = 1 then v.pr8state := idle; end if;
    end if;

    ribdrive <= vbdrive;
    ri <= v;

    sro.address  <= r.haddr;
    sro.bdrive   <= (others => sbdrive);
    sro.vbdrive  <= rbdrive;
    sro.ramsn    <= "111" & r.vramsn;
    sro.ramoen   <= "111" & r.ramoen;
    sro.romsn    <= "111111" & r.vromsn;
    sro.iosn     <= r.iosn;
    sro.wrn      <= r.wen;
    sro.oen      <= r.oen;
    sro.read     <= r.read;
    sro.data     <= r.hwdata;
    sro.writen   <= r.writen;
    sro.ramn     <= r.ramsn;
    sro.romn     <= r.romsn;

    ahbso.hready  <= r.hready;
    ahbso.hresp   <= r.hresp;
    ahbso.hrdata  <= hrdata;
    ahbso.hconfig <= hconfig;
    ahbso.hcache  <= '1';
    ahbso.hirq    <= (others => '0');
    ahbso.hindex  <= hindex;
    ahbso.hsplit  <= (others => '0');

  end process;

  sdo.sdcsn <= "11";
  sdo.sdcke <= "11";
  sdo.sdwen <= '1';
  sdo.rasn  <= '1';
  sdo.casn  <= '1';
  sdo.dqm   <= (others => '1');
  sdo.address  <= (others => '0');
  sdo.data  <= (others => '0');
  sro.mben  <= r.mben;

  regs : process(clk,rst)
  begin

    if rising_edge(clk) then r <= ri; rbdrive <= ribdrive; end if;

    if rst = '0' then
      r.ramsn  <= '1';
      r.romsn  <= '1'; r.oen    <= '1';
      r.bdrive <= '1'; r.nbdrive <= '0';
      r.vramsn <= (others => '1'); r.vromsn <= (others => '1');
      if oepol  = 0 then rbdrive <= (others => '1');
      else rbdrive <= (others => '0'); end if;
    end if;
  end process;

-- pragma translate_off
  bootmsg : report_version
  generic map ("srctrl" & tost(hindex) &
	": 32-bit PROM/SRAM controller rev " & tost(VERSION));
-- pragma translate_on

end;

