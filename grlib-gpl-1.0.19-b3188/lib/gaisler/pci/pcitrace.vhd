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
-- Entity: 	pcitrace
-- File:	pcitrace.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	PCI trace buffer
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
use gaisler.pci.all;

entity pcitrace is
  generic (
    depth     : integer range 6 to 12 := 8; 
    iregs     : integer := 1;
    memtech   : integer := DEFMEMTECH;
    pindex    : integer := 0;
    paddr     : integer := 0;
    pmask     : integer := 16#f00#
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    pciclk : in  std_ulogic;
    pcii   : in  pci_in_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type
  );
end; 
 
architecture rtl of pcitrace is

constant REVISION : amba_version_type := 0;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_PCITRACE, 0, REVISION, 0),
  1 => apb_iobar(paddr, pmask));

type reg_type is record
  sample     : std_ulogic;
  armed      : std_ulogic;
  busy       : std_ulogic;
  timeout    : std_logic_vector(depth-1 downto 0);
  admask     : std_logic_vector(31 downto 0);
  adpattern  : std_logic_vector(31 downto 0);
  sigmask    : std_logic_vector(15 downto 0);
  sigpattern : std_logic_vector(15 downto 0);
  count      : std_logic_vector(7 downto 0);  
end record;
  
type pci_reg_type is record
  sample  : std_ulogic;
  armed   : std_ulogic;
  sync    : std_ulogic;
  start   : std_ulogic;
  timeout : std_logic_vector(depth-1 downto 0);
  baddr   : std_logic_vector(depth-1 downto 0);  
  count   : std_logic_vector(7 downto 0);  
end record;

signal r, rin : reg_type;
signal csad, csctrl : std_ulogic;
signal pr, prin : pci_reg_type;
signal bufout : std_logic_vector(47 downto 0);
signal pciad : std_logic_vector(31 downto 0);
signal vcc : std_ulogic;
signal pcictrlin, pcictrl : std_logic_vector(15 downto 0);

begin

  vcc <= '1';

  comb: process(pcii, apbi, rst, r, pr, bufout)
  variable v : reg_type;
  variable rdata : std_logic_vector(31 downto 0);
  variable paddr : std_logic_vector(3 downto 0);
  variable vcsad, vcssig : std_ulogic;
  begin
    v := r; vcsad := '0'; vcssig := '0'; rdata := (others => '0');
    v.sample := r.armed and not pr.armed; v.busy := pr.sample;
    if (r.sample and pr.armed) = '1' then v.armed := '0'; end if;

    --registers
    paddr := apbi.paddr(15) & apbi.paddr(4 downto 2);
    if apbi.penable = '1' then
      if (apbi.pwrite and apbi.psel(pindex)) = '1' then
        case paddr is
        when "0000" => v.admask := apbi.pwdata;
        when "0001" => v.sigmask := apbi.pwdata(15 downto 0);
        when "0010" => v.adpattern := apbi.pwdata;
        when "0011" => v.sigpattern := apbi.pwdata(15 downto 0);
        when "0100" => v.timeout := apbi.pwdata(depth-1 downto 0);
        when "0101" => v.armed  := '1';
        when "0111" => v.count  := apbi.pwdata(7 downto 0);
        when others =>
          if apbi.paddr(15 downto 14) = "10" then vcsad := '1';
          elsif apbi.paddr(15 downto 14) = "11" then vcssig := '1'; end if;
        end case;
      end if;
      case paddr is
      when "0000" => rdata := r.admask;
      when "0001" => rdata(15 downto 0) := r.sigmask;
      when "0010" => rdata := r.adpattern;
      when "0011" => rdata(15 downto 0) := r.sigpattern;
      when "0100" => rdata(depth-1 downto 0) := r.timeout;
      when "0101" => rdata(0) := r.busy;
      when "0110" => rdata(3 downto 0) := conv_std_logic_vector(depth, 4);
      when "0111" => 
        rdata(depth-1+16 downto 16) := pr.baddr;
        rdata(15 downto 0) := pr.count & r.count;
      when others =>
        if apbi.paddr(15 downto 14) = "10" then
          vcsad := '1'; rdata := bufout(31 downto 0);
        elsif apbi.paddr(15 downto 14) = "11" then
          vcssig := '1'; rdata(15 downto 0) := bufout(47 downto 32);
        end if;
      end case;
    end if;

    if rst = '0' then
      v.sample := '0'; v.armed := '0'; v.admask := (others => '0');
      v.sigmask := (others => '0'); v.adpattern := (others => '0');
      v.sigpattern := (others => '0'); v.timeout := (others => '0');
    end if;

    csad <= vcsad; csctrl <= vcssig; apbo.prdata <= rdata; rin <= v;
    
  end process;
  
  comb2 : process(r, pr, pciclk, pcii, pcictrl, rst)
  variable v : pci_reg_type;
  constant z : std_logic_vector(47 downto 0) := (others => '0');
  begin
    v := pr; v.sync := (r.sample and not pr.armed);
    if (pr.sample = '1') then
      v.baddr := pr.baddr + 1;
      if ((((pcii.ad & pcictrl) xor (r.adpattern & r.sigpattern)) and (r.admask & r.sigmask)) = z) then
        if pr.count = "00000000" then v.start  := '0';
        else v.count := pr.count -1; end if;
      end if;
      if (pr.start = '0') then
        v.timeout := pr.timeout  - 1;
        if (v.timeout(depth-1) and not pr.timeout(depth-1)) = '1' then
          v.sample := '0'; v.armed := '0';
        end if;
      end if;
    end if;

    if pr.sync = '1' then
      v.start := '1'; v.sample := '1'; v.armed := '1';
      v.timeout := r.timeout; v.count := r.count;
    end if;

    if rst = '0' then
      v.sample := '0'; v.armed := '0'; v.start := '0';
      v.timeout := (others => '0'); v.baddr := (others => '0');
      v.count := (others => '0');
    end if;
    prin <= v;
  end process ;
  
  pcictrlin <= pcii.rst & pcii.idsel & pcii.frame & pcii.trdy & pcii.irdy & 
	pcii.devsel & pcii.gnt & pcii.stop & pcii.lock & pcii.perr & 
	pcii.serr & pcii.par & pcii.cbe;

  apbo.pconfig <= pconfig;
  apbo.pindex  <= pindex;
  apbo.pirq    <= (others => '0');

  seq: process (clk)
  begin 
    if clk'event and clk = '1' then r <= rin; end if;
  end process seq;
    
  pseq: process (pciclk)
  begin  
    if pciclk'event and pciclk = '1' then pr <= prin; end if;
  end process ;
    
  ir : if iregs = 1 generate
    pseq: process (pciclk)
    begin  
      if pciclk'event and pciclk = '1' then 
	pcictrl <= pcictrlin; pciad <= pcii.ad;
      end if;
    end process ;
  end generate;    

  noir : if iregs = 0 generate
    pcictrl <= pcictrlin; pciad <= pcii.ad;
  end generate;    

  admem : syncram_2p generic map (tech => memtech, abits => depth, dbits => 32)
  port map (clk, csad, apbi.paddr(depth+1 downto 2), bufout(31 downto 0), 
	    pciclk, pr.sample, pr.baddr, pciad);

  ctrlmem : syncram_2p generic map (tech => memtech, abits => depth, dbits => 16)
  port map (clk, csctrl, apbi.paddr(depth+1 downto 2), bufout(47 downto 32), 
	    pciclk, pr.sample, pr.baddr, pcictrl);

end;        
