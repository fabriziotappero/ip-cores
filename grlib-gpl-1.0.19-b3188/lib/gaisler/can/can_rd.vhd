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
-- Entity:      can_oc
-- File:        can_oc.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: AHB interface for the OpenCores CAN MAC
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
use gaisler.can.all;

entity can_rd is                   
   generic (
    slvndx    : integer := 0;
    ioaddr    : integer := 16#000#;
    iomask    : integer := 16#FF0#;
    irq       : integer := 0;
    memtech   : integer := DEFMEMTECH;
    syncrst   : integer := 0;
    dmap      : integer := 0);
   port (                          
      resetn  : in  std_logic;        
      clk     : in  std_logic;        
      ahbsi   : in  ahb_slv_in_type; 
      ahbso   : out ahb_slv_out_type;
      can_rxi : in  std_logic_vector(1 downto 0);      
      can_txo : out std_logic_vector(1 downto 0)
   );                           
end;                               

architecture rtl of can_rd is 

constant ncores : integer := 1;
constant sepirq : integer := 0;
constant REVISION : amba_version_type := ncores-1;

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_CANAHB, 0, REVISION, irq),
  4 => ahb_iobar(ioaddr, iomask), others => zero32);

type ahbregs is record
  hsel      : std_ulogic;
  hwrite    : std_ulogic;
  hwrite2   : std_ulogic;
  htrans    : std_logic_vector(1 downto 0);
  haddr     : std_logic_vector(10 downto 0);
  hwdata    : std_logic_vector(7 downto 0);
  herr      : std_ulogic;
  hready    : std_ulogic;
  ws        : std_logic_vector(1 downto 0);
  irqi      : std_logic_vector(ncores-1 downto 0);
  irqo      : std_logic_vector(ncores-1 downto 0);
  muxsel    : std_logic;
  writemux  : std_logic;
end record;

subtype cdata is std_logic_vector(7 downto 0);
type cdataarr is array (0 to 7) of cdata;
signal data_out : cdataarr;
signal reset : std_logic;   
signal irqo : std_logic_vector(ncores-1 downto 0);
signal addr : std_logic_vector(7 downto 0); 

signal vcc, gnd : std_ulogic;

signal r, rin : ahbregs;
signal can_lrxi, can_ltxo : std_logic;
begin

  gnd <= '0'; vcc <= '1'; reset <= not resetn;
  
  comb : process(ahbsi, r, resetn, data_out, irqo)
  variable v : ahbregs;
  variable hresp : std_logic_vector(1 downto 0);
  variable dataout : std_logic_vector(7 downto 0);    
  variable irqvec : std_logic_vector(NAHBIRQ-1 downto 0);
  variable vmuxreg : std_logic;
  begin

    v := r;
    if (r.hsel = '1' ) and (r.ws /= "11") then v.ws := r.ws + 1; end if;

    if ahbsi.hready = '1' then
      v.hsel := ahbsi.hsel(slvndx);
      v.haddr := ahbsi.haddr(10 downto 0);
      v.htrans := ahbsi.htrans;
      v.hwrite := ahbsi.hwrite;
      v.herr := orv(ahbsi.hsize) and ahbsi.hwrite;
      v.ws := "00";
    end if;

    v.hready := (r.hsel and r.ws(1) and not r.ws(0)) or not resetn 
	or (ahbsi.hready and not ahbsi.htrans(1));

    vmuxreg := not r.haddr(7) and r.haddr(6);

    --v.hwrite2 := r.hwrite and r.hsel and r.htrans(1) and r.ws(1) 
--	and not r.ws(0) and not r.herr;
    v.hwrite2 := r.hwrite and r.hsel and r.htrans(1) and r.ws(1) 
	and not r.ws(0) and not r.herr and not vmuxreg;
    v.writemux := r.hwrite and r.hsel and r.htrans(1) and r.ws(1) 
	and not r.ws(0) and vmuxreg;

    if (r.herr and r.ws(1)) = '1' then hresp := HRESP_ERROR; 
    else hresp := HRESP_OKAY; end if;

    case r.haddr(1 downto 0) is
    when "00" => v.hwdata := ahbsi.hwdata(31 downto 24);
    when "01" => v.hwdata := ahbsi.hwdata(23 downto 16);
    when "10" => v.hwdata := ahbsi.hwdata(15 downto 8);
    when others => v.hwdata := ahbsi.hwdata(7 downto 0);
    end case;

    --dataout := data_out(0);
    if r.haddr(7 downto 6) = "01" then
       dataout := (others => r.muxsel);
       if r.writemux = '1' then
          v.muxsel := r.hwdata(0);
       end if;
    else
       dataout := data_out(0);
    end if;

    -- Interrupt goes to low when appeard and is normal high
    -- but the irq controller from leon is active high and the interrupt should appear only
    -- for 1 Clk cycle,

    v.irqi := irqo; v.irqo:= (r.irqi and not irqo);
    irqvec := (others => '0');
    if sepirq = 1 then irqvec(ncores-1+irq downto irq) := r.irqo;
    else irqvec(irq) := orv(r.irqo); end if;


    ahbso.hirq <= irqvec;
    ahbso.hrdata  <= dataout & dataout & dataout & dataout;
    ahbso.hresp <= hresp; rin <= v;

  end process;

  -- Double mapping of registers [byte (offset 0), word (offset 0x80)]
  dmap0 : if dmap = 0 generate
    addr <= r.haddr(7 downto 0);
  end generate;
  dmap1 : if dmap = 1 generate
    addr <= "000"&r.haddr(6 downto 2) when r.haddr(7) = '1' else
            r.haddr(7 downto 0);
  end generate;
  
  reg : process(clk)
  begin if clk'event and clk = '1' then r <= rin; end if; end process;

  cmod : can_mod generic map (memtech, syncrst)
    --port map (reset, clk, r.hsel, r.hwrite2, r.haddr(7 downto 0), r.hwdata, 
    port map (reset, clk, r.hsel, r.hwrite2, addr, r.hwdata, 
	data_out(0), irqo(0), can_lrxi, can_ltxo, ahbsi.testen);
    
  cmux : canmux port map (r.muxsel, can_lrxi, can_ltxo, can_rxi, can_txo);

    ahbso.hconfig <= hconfig;
    ahbso.hindex  <= slvndx; 
    ahbso.hsplit  <= (others => '0');
    ahbso.hcache  <= '0';
    ahbso.hready  <= r.hready;
    
    
-- pragma translate_off
  bootmsg : report_version 
  generic map (
	"can_oc" & tost(slvndx) & 
	": SJA1000 Compatible CAN MAC, revision " & tost(REVISION) & 
	", irq " & tost(irq));
-- pragma translate_on
   
end;
