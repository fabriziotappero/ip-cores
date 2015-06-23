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
-- Entity: 	grspwc
-- File:	grspwc.vhd
-- Author:	Marko Isomaki - Gaisler Research 
-- Description: Provides a link interface to a SpaceWire network
--              with an AHB host interface and RMAP support.  
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity grspwc_net is
  generic(
    tech         : integer := 0;
    sysfreq      : integer := 40000;
    usegen       : integer range 0 to 1  := 1;
    nsync        : integer range 1 to 2  := 1; 
    rmap         : integer range 0 to 1  := 0;
    rmapcrc      : integer range 0 to 1  := 0;
    fifosize1    : integer range 4 to 32 := 32;
    fifosize2    : integer range 16 to 64 := 64;
    rxunaligned  : integer range 0 to 1 := 0;
    rmapbufs     : integer range 2 to 8 := 4;
    scantest     : integer range 0 to 1 := 0
  );
  port(
    rst          : in  std_ulogic;
    clk          : in  std_ulogic;
    txclk        : in  std_ulogic;
    --ahb mst in
    hgrant       : in  std_ulogic;
    hready       : in  std_ulogic;   
    hresp        : in  std_logic_vector(1 downto 0);
    hrdata       : in  std_logic_vector(31 downto 0); 
    --ahb mst out
    hbusreq      : out  std_ulogic;        
    hlock        : out  std_ulogic;
    htrans       : out  std_logic_vector(1 downto 0);
    haddr        : out  std_logic_vector(31 downto 0);
    hwrite       : out  std_ulogic;
    hsize        : out  std_logic_vector(2 downto 0);
    hburst       : out  std_logic_vector(2 downto 0);
    hprot        : out  std_logic_vector(3 downto 0);
    hwdata       : out  std_logic_vector(31 downto 0);
    --apb slv in 
    psel	 : in   std_ulogic;
    penable	 : in   std_ulogic;
    paddr	 : in   std_logic_vector(31 downto 0);
    pwrite	 : in   std_ulogic;
    pwdata	 : in   std_logic_vector(31 downto 0);
    --apb slv out
    prdata	 : out  std_logic_vector(31 downto 0);
    --spw in
    di 		 : in std_logic_vector(1 downto 0);
    si 		 : in std_logic_vector(1 downto 0);
    --spw out
    do 		 : out std_logic_vector(1 downto 0);
    so 		 : out std_logic_vector(1 downto 0);
    --time iface
    tickin       : in   std_ulogic;
    tickout      : out  std_ulogic;
    --irq
    irq          : out  std_logic;
    --misc     
    clkdiv10     : in   std_logic_vector(7 downto 0);
    dcrstval     : in   std_logic_vector(9 downto 0);
    timerrstval  : in   std_logic_vector(11 downto 0);
    --rmapen
    rmapen       : in   std_ulogic;
    --clk bufs
    rxclki       : in std_logic_vector(1 downto 0);
    nrxclki      : in std_logic_vector(1 downto 0);
    rxclko       : out std_logic_vector(1 downto 0);
    --rx ahb fifo
    rxrenable    : out  std_ulogic;
    rxraddress   : out  std_logic_vector(4 downto 0);
    rxwrite      : out  std_ulogic;
    rxwdata      : out  std_logic_vector(31 downto 0);
    rxwaddress   : out  std_logic_vector(4 downto 0);
    rxrdata      : in   std_logic_vector(31 downto 0);    
    --tx ahb fifo
    txrenable    : out  std_ulogic;
    txraddress   : out  std_logic_vector(4 downto 0);
    txwrite      : out  std_ulogic;
    txwdata      : out  std_logic_vector(31 downto 0);
    txwaddress   : out  std_logic_vector(4 downto 0);
    txrdata      : in   std_logic_vector(31 downto 0);    
    --nchar fifo
    ncrenable    : out  std_ulogic;
    ncraddress   : out  std_logic_vector(5 downto 0);
    ncwrite      : out  std_ulogic;
    ncwdata      : out  std_logic_vector(8 downto 0);
    ncwaddress   : out  std_logic_vector(5 downto 0);
    ncrdata      : in   std_logic_vector(8 downto 0);
    --rmap buf
    rmrenable    : out  std_ulogic;
    rmraddress   : out  std_logic_vector(7 downto 0);
    rmwrite      : out  std_ulogic;
    rmwdata      : out  std_logic_vector(7 downto 0);
    rmwaddress   : out  std_logic_vector(7 downto 0);
    rmrdata      : in   std_logic_vector(7 downto 0);
    linkdis      : out  std_ulogic;
    testclk      : in   std_ulogic := '0';
    testrst      : in   std_ulogic := '0';
    testen       : in   std_ulogic := '0'
  );
end entity;

architecture rtl of grspwc_net is

component grspwc_unisim
  generic(
    sysfreq      : integer := 40000;
    usegen       : integer range 0 to 1  := 1;
    nsync        : integer range 1 to 2  := 1; 
    rmap         : integer range 0 to 1  := 0;
    rmapcrc      : integer range 0 to 1  := 0;
    fifosize1    : integer range 4 to 32 := 32;
    fifosize2    : integer range 16 to 64 := 64;
    rxunaligned  : integer range 0 to 1 := 0;
    rmapbufs     : integer range 2 to 8 := 4;
    scantest     : integer range 0 to 1 := 0
  );
  port(
    rst          : in  std_ulogic;
    clk          : in  std_ulogic;
    txclk        : in  std_ulogic;
    --ahb mst in
    hgrant       : in  std_ulogic;
    hready       : in  std_ulogic;   
    hresp        : in  std_logic_vector(1 downto 0);
    hrdata       : in  std_logic_vector(31 downto 0); 
    --ahb mst out
    hbusreq      : out  std_ulogic;        
    hlock        : out  std_ulogic;
    htrans       : out  std_logic_vector(1 downto 0);
    haddr        : out  std_logic_vector(31 downto 0);
    hwrite       : out  std_ulogic;
    hsize        : out  std_logic_vector(2 downto 0);
    hburst       : out  std_logic_vector(2 downto 0);
    hprot        : out  std_logic_vector(3 downto 0);
    hwdata       : out  std_logic_vector(31 downto 0);
    --apb slv in 
    psel	 : in   std_ulogic;
    penable	 : in   std_ulogic;
    paddr	 : in   std_logic_vector(31 downto 0);
    pwrite	 : in   std_ulogic;
    pwdata	 : in   std_logic_vector(31 downto 0);
    --apb slv out
    prdata	 : out  std_logic_vector(31 downto 0);
    --spw in
    di 		 : in std_logic_vector(1 downto 0);
    si 		 : in std_logic_vector(1 downto 0);
    --spw out
    do 		 : out std_logic_vector(1 downto 0);
    so 		 : out std_logic_vector(1 downto 0);
    --time iface
    tickin       : in   std_ulogic;
    tickout      : out  std_ulogic;
    --irq
    irq          : out  std_logic;
    --misc     
    clkdiv10     : in   std_logic_vector(7 downto 0);
    dcrstval     : in   std_logic_vector(9 downto 0);
    timerrstval  : in   std_logic_vector(11 downto 0);
    --rmapen
    rmapen       : in   std_ulogic;
    --clk bufs
    rxclki       : in std_logic_vector(1 downto 0);
    nrxclki      : in std_logic_vector(1 downto 0);
    rxclko       : out std_logic_vector(1 downto 0);
    --rx ahb fifo
    rxrenable    : out  std_ulogic;
    rxraddress   : out  std_logic_vector(4 downto 0);
    rxwrite      : out  std_ulogic;
    rxwdata      : out  std_logic_vector(31 downto 0);
    rxwaddress   : out  std_logic_vector(4 downto 0);
    rxrdata      : in   std_logic_vector(31 downto 0);    
    --tx ahb fifo
    txrenable    : out  std_ulogic;
    txraddress   : out  std_logic_vector(4 downto 0);
    txwrite      : out  std_ulogic;
    txwdata      : out  std_logic_vector(31 downto 0);
    txwaddress   : out  std_logic_vector(4 downto 0);
    txrdata      : in   std_logic_vector(31 downto 0);    
    --nchar fifo
    ncrenable    : out  std_ulogic;
    ncraddress   : out  std_logic_vector(5 downto 0);
    ncwrite      : out  std_ulogic;
    ncwdata      : out  std_logic_vector(8 downto 0);
    ncwaddress   : out  std_logic_vector(5 downto 0);
    ncrdata      : in   std_logic_vector(8 downto 0);
    --rmap buf
    rmrenable    : out  std_ulogic;
    rmraddress   : out  std_logic_vector(7 downto 0);
    rmwrite      : out  std_ulogic;
    rmwdata      : out  std_logic_vector(7 downto 0);
    rmwaddress   : out  std_logic_vector(7 downto 0);
    rmrdata      : in   std_logic_vector(7 downto 0);
    linkdis      : out  std_ulogic;
    testclk      : in   std_ulogic := '0';
    testrst      : in   std_ulogic := '0';
    testen       : in   std_ulogic := '0'
  );
end component;

component grspwc_axcelerator
  generic(
    sysfreq      : integer := 40000;
    usegen       : integer range 0 to 1  := 1;
    nsync        : integer range 1 to 2  := 1; 
    rmap         : integer range 0 to 1  := 0;
    rmapcrc      : integer range 0 to 1  := 0;
    fifosize1    : integer range 4 to 32 := 32;
    fifosize2    : integer range 16 to 64 := 64;
    rxunaligned  : integer range 0 to 1 := 0;
    rmapbufs     : integer range 2 to 8 := 4;
    scantest     : integer range 0 to 1 := 0
  );
  port(
    rst          : in  std_ulogic;
    clk          : in  std_ulogic;
    txclk        : in  std_ulogic;
    --ahb mst in
    hgrant       : in  std_ulogic;
    hready       : in  std_ulogic;   
    hresp        : in  std_logic_vector(1 downto 0);
    hrdata       : in  std_logic_vector(31 downto 0); 
    --ahb mst out
    hbusreq      : out  std_ulogic;        
    hlock        : out  std_ulogic;
    htrans       : out  std_logic_vector(1 downto 0);
    haddr        : out  std_logic_vector(31 downto 0);
    hwrite       : out  std_ulogic;
    hsize        : out  std_logic_vector(2 downto 0);
    hburst       : out  std_logic_vector(2 downto 0);
    hprot        : out  std_logic_vector(3 downto 0);
    hwdata       : out  std_logic_vector(31 downto 0);
    --apb slv in 
    psel	 : in   std_ulogic;
    penable	 : in   std_ulogic;
    paddr	 : in   std_logic_vector(31 downto 0);
    pwrite	 : in   std_ulogic;
    pwdata	 : in   std_logic_vector(31 downto 0);
    --apb slv out
    prdata	 : out  std_logic_vector(31 downto 0);
    --spw in
    di : in std_logic_vector(1 downto 0);
    si : in std_logic_vector(1 downto 0);
    --spw out
    do : out std_logic_vector(1 downto 0);
    so : out std_logic_vector(1 downto 0);
    --time iface
    tickin       : in   std_ulogic;
    tickout      : out  std_ulogic;
    --irq
    irq          : out  std_logic;
    --misc     
    clkdiv10     : in   std_logic_vector(7 downto 0);
    dcrstval     : in   std_logic_vector(9 downto 0);
    timerrstval  : in   std_logic_vector(11 downto 0);
    --rmapen
    rmapen       : in   std_ulogic;
    --clk bufs
    rxclki : in std_logic_vector(1 downto 0);
    nrxclki : in std_logic_vector(1 downto 0);
    rxclko : out std_logic_vector(1 downto 0);
    --rx ahb fifo
    rxrenable    : out  std_ulogic;
    rxraddress   : out  std_logic_vector(4 downto 0);
    rxwrite      : out  std_ulogic;
    rxwdata      : out  std_logic_vector(31 downto 0);
    rxwaddress   : out  std_logic_vector(4 downto 0);
    rxrdata      : in   std_logic_vector(31 downto 0);    
    --tx ahb fifo
    txrenable    : out  std_ulogic;
    txraddress   : out  std_logic_vector(4 downto 0);
    txwrite      : out  std_ulogic;
    txwdata      : out  std_logic_vector(31 downto 0);
    txwaddress   : out  std_logic_vector(4 downto 0);
    txrdata      : in   std_logic_vector(31 downto 0);    
    --nchar fifo
    ncrenable    : out  std_ulogic;
    ncraddress   : out  std_logic_vector(5 downto 0);
    ncwrite      : out  std_ulogic;
    ncwdata      : out  std_logic_vector(8 downto 0);
    ncwaddress   : out  std_logic_vector(5 downto 0);
    ncrdata      : in   std_logic_vector(8 downto 0);
    --rmap buf
    rmrenable    : out  std_ulogic;
    rmraddress   : out  std_logic_vector(7 downto 0);
    rmwrite      : out  std_ulogic;
    rmwdata      : out  std_logic_vector(7 downto 0);
    rmwaddress   : out  std_logic_vector(7 downto 0);
    rmrdata      : in   std_logic_vector(7 downto 0);
    linkdis      : out  std_ulogic;
    testclk      : in   std_ulogic := '0';
    testrst      : in   std_ulogic := '0';
    testen       : in   std_ulogic := '0'
  );
end component;

begin

  ax : if tech = axcel generate
    grspwc0 : grspwc_axcelerator 
    generic map (sysfreq, usegen, nsync, rmap, rmapcrc, fifosize1, fifosize2,
		 rxunaligned, rmapbufs, scantest)
    port map(
      rst          => rst,
      clk          => clk,
      txclk        => txclk,
      --ahb mst in
      hgrant       => hgrant,
      hready       => hready,   
      hresp        => hresp,
      hrdata       => hrdata,
      --ahb mst out
      hbusreq      => hbusreq,
      hlock        => hlock,
      htrans       => htrans,
      haddr        => haddr,
      hwrite       => hwrite,
      hsize        => hsize,
      hburst       => hburst,
      hprot        => hprot,
      hwdata       => hwdata,
      --apb slv in 
      psel	   => psel,
      penable	   => penable,
      paddr	   => paddr,
      pwrite	   => pwrite,
      pwdata	   => pwdata,
      --apb slv out
      prdata       => prdata,
      --spw in
      di           => di,
      si           => si,
      --spw out
      do           => do,
      so           => so,
      --time iface
      tickin       => tickin,
      tickout      => tickout,
      --clk bufs
      rxclki       => rxclki,
      nrxclki      => nrxclki,
      rxclko       => rxclko,
      --irq
      irq          => irq,
      --misc     
      clkdiv10     => clkdiv10,
      dcrstval     => dcrstval,
      timerrstval  => timerrstval,
      --rmapen    
      rmapen       => rmapen, 
      --rx ahb fifo
      rxrenable    => rxrenable,
      rxraddress   => rxraddress, 
      rxwrite      => rxwrite,
      rxwdata      => rxwdata, 
      rxwaddress   => rxwaddress,
      rxrdata      => rxrdata,  
      --tx ahb fifo
      txrenable    => txrenable,
      txraddress   => txraddress, 
      txwrite      => txwrite,
      txwdata      => txwdata, 
      txwaddress   => txwaddress,
      txrdata      => txrdata,  
      --nchar fifo
      ncrenable    => ncrenable,
      ncraddress   => ncraddress, 
      ncwrite      => ncwrite,
      ncwdata      => ncwdata, 
      ncwaddress   => ncwaddress,
      ncrdata      => ncrdata,  
      --rmap buf
      rmrenable    => rmrenable,
      rmraddress   => rmraddress, 
      rmwrite      => rmwrite,
      rmwdata      => rmwdata, 
      rmwaddress   => rmwaddress,
      rmrdata      => rmrdata,
      linkdis      => linkdis,
      testclk      => testclk,
      testrst      => testrst,
      testen       => testen
      );
  end generate;

  xil : if (tech = virtex2) or (tech = virtex4) or (tech = virtex5) or
	(tech = spartan3) or (tech = spartan3e) generate
    grspwc0 : grspwc_unisim 
    generic map (sysfreq, usegen, nsync, rmap, rmapcrc, fifosize1, fifosize2,
		 rxunaligned, rmapbufs, scantest)
    port map(
      rst          => rst,
      clk          => clk,
      txclk        => txclk,
      --ahb mst in
      hgrant       => hgrant,
      hready       => hready,   
      hresp        => hresp,
      hrdata       => hrdata,
      --ahb mst out
      hbusreq      => hbusreq,
      hlock        => hlock,
      htrans       => htrans,
      haddr        => haddr,
      hwrite       => hwrite,
      hsize        => hsize,
      hburst       => hburst,
      hprot        => hprot,
      hwdata       => hwdata,
      --apb slv in 
      psel	   => psel,
      penable	   => penable,
      paddr	   => paddr,
      pwrite	   => pwrite,
      pwdata	   => pwdata,
      --apb slv out
      prdata       => prdata,
      --spw in
      di           => di,
      si           => si,
      --spw out
      do           => do,
      so           => so,
      --time iface
      tickin       => tickin,
      tickout      => tickout,
      --clk bufs
      rxclki       => rxclki,
      nrxclki      => nrxclki,
      rxclko       => rxclko,
      --irq
      irq          => irq,
      --misc     
      clkdiv10     => clkdiv10,
      dcrstval     => dcrstval,
      timerrstval  => timerrstval,
      --rmapen    
      rmapen       => rmapen, 
      --rx ahb fifo
      rxrenable    => rxrenable,
      rxraddress   => rxraddress, 
      rxwrite      => rxwrite,
      rxwdata      => rxwdata, 
      rxwaddress   => rxwaddress,
      rxrdata      => rxrdata,  
      --tx ahb fifo
      txrenable    => txrenable,
      txraddress   => txraddress, 
      txwrite      => txwrite,
      txwdata      => txwdata, 
      txwaddress   => txwaddress,
      txrdata      => txrdata,  
      --nchar fifo
      ncrenable    => ncrenable,
      ncraddress   => ncraddress, 
      ncwrite      => ncwrite,
      ncwdata      => ncwdata, 
      ncwaddress   => ncwaddress,
      ncrdata      => ncrdata,  
      --rmap buf
      rmrenable    => rmrenable,
      rmraddress   => rmraddress, 
      rmwrite      => rmwrite,
      rmwdata      => rmwdata, 
      rmwaddress   => rmwaddress,
      rmrdata      => rmrdata,
      linkdis      => linkdis,
      testclk      => testclk,
      testrst      => testrst,
      testen       => testen
      );
  end generate;

-- pragma translate_off
  nonet : if not ((tech = virtex2) or (tech = virtex4) or (tech = virtex5) or
	(tech = spartan3) or (tech = spartan3e) or (tech = axcel))
  generate
    err : process 
    begin
      assert false report "ERROR : No GRSPWC netlist available for this process!"
      severity failure;
      wait;
    end process;
  end generate;

-- pragma translate_on

end architecture;
