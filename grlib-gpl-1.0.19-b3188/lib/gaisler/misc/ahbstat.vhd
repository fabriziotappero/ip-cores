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
-------------------------------------------------------------------------------

library ieee;
library grlib;
library gaisler;

use ieee.std_logic_1164.all;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
use gaisler.misc.all;

entity ahbstat is
  generic(
    pindex : integer := 0;
    paddr  : integer := 0;
    pmask  : integer := 16#FFF#;
    pirq   : integer := 0;
    nftslv : integer range 1 to NAHBSLV - 1 := 3);
  port(
    rst   : in std_ulogic;
    clk   : in std_ulogic;
    ahbmi : in ahb_mst_in_type;
    ahbsi : in ahb_slv_in_type;
    stati : in ahbstat_in_type;
    apbi  : in apb_slv_in_type;
    apbo  : out apb_slv_out_type
  );
end entity;

architecture rtl of ahbstat is
  type reg_type is record
    addr    : std_logic_vector(31 downto 0); --failing address
    hsize   : std_logic_vector(2 downto 0);  --ahb signals for failing op.
    hmaster : std_logic_vector(3 downto 0);
    hwrite  : std_ulogic;
    hresp   : std_logic_vector(1 downto 0);
    newerr  : std_ulogic; --new error detected
    cerror  : std_ulogic; --correctable error detected
    pirq    : std_ulogic; 
  end record;

  signal r, rin : reg_type;

  constant VERSION : integer := 0;
  
  constant pconfig : apb_config_type := (
  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_AHBSTAT, 0, VERSION, pirq),
  1 => apb_iobar(paddr, pmask));

begin

  comb : process(rst, ahbmi, ahbsi, stati, apbi, r) is
  variable v       : reg_type;
  variable prdata  : std_logic_vector(31 downto 0);
  variable vpirq   : std_logic_vector(NAHBIRQ - 1 downto 0);
  variable ce      : std_ulogic; --correctable error
  begin
    v := r; vpirq := (others => '0'); prdata := (others => '0'); v.pirq := '0';

    ce := orv(stati.cerror(0 to nftslv-1));

    case apbi.paddr(2) is
    when '0' => --status values
      prdata(2 downto 0) := r.hsize;
      prdata(6 downto 3) := r.hmaster;
      prdata(7) := r.hwrite;
      prdata(8) := r.newerr;
      prdata(9) := r.cerror;
    when others => --failing address
      prdata := r.addr;
    end case;
    --writes. data is written in setup cycle so that r.newerr is updated
    --when hready = '1'
    if (apbi.psel(pindex) and not apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(2) is 
      when '0' =>
	v.newerr := apbi.pwdata(8);
	v.cerror := apbi.pwdata(9);
      when others => null;
      end case;
    end if;
      
    v.hresp := ahbmi.hresp;
    
    if (ahbsi.hready = '1') and  (r.newerr = '0') then
      if (r.hresp = HRESP_ERROR) or (ce = '1') then v.newerr := '1';
    	v.cerror := ce;
      else
        v.addr := ahbsi.haddr;
	v.hsize := ahbsi.hsize;
	v.hmaster := ahbsi.hmaster;
	v.hwrite := ahbsi.hwrite;
      end if;
    end if;
   
    --irq generation
    v.pirq := v.newerr and not r.newerr;
    vpirq(pirq) := r.pirq;
        
    --reset
    if rst = '0' then
      v.newerr := '0'; v.cerror := '0';
    end if;
    
    rin <= v;
    apbo.prdata <= prdata;
    apbo.pirq <= vpirq;
  end process;

  apbo.pconfig <= pconfig;
  apbo.pindex <= pindex;
  
  regs : process(clk) is
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process;

-- boot message

-- pragma translate_off
    bootmsg : report_version 
    generic map ("ahbstat" & tost(pindex) & 
	": AHB status unit rev " & tost(VERSION) & 
	", irq " & tost(pirq));
-- pragma translate_on

end architecture;
