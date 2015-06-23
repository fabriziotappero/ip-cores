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
-- Entity: 	grspw_gen
-- File:	grspw_gen.vhd
-- Author:	Marko Isomaki - Gaisler Research 
-- Description: Generic GRSPW core
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library spw;
use spw.spwcomp.all;

entity grspw_gen is
  generic(
    tech         : integer := 0;
    sysfreq      : integer := 10000;
    usegen       : integer range 0 to 1  := 1;
    nsync        : integer range 1 to 2  := 1; 
    rmap         : integer range 0 to 1  := 0;
    rmapcrc      : integer range 0 to 1  := 0;
    fifosize1    : integer range 4 to 32 := 32;
    fifosize2    : integer range 16 to 64 := 64;
    rxclkbuftype : integer range 0 to 2 := 0;
    rxunaligned  : integer range 0 to 1 := 0;
    rmapbufs     : integer range 2 to 8 := 4;
    ft           : integer range 0 to 2 := 0;
    scantest     : integer range 0 to 1 := 0;
    techfifo     : integer range 0 to 1 := 1;
    ports        : integer range 1 to 2 := 1;
    memtech      : integer := 0
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
    di           : in   std_logic_vector(1 downto 0);
    si           : in   std_logic_vector(1 downto 0);
    --spw out
    do           : out  std_logic_vector(1 downto 0);
    so           : out  std_logic_vector(1 downto 0);
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
    linkdis      : out  std_ulogic;
    testclk      : in   std_ulogic := '0';
    testrst      : in   std_ulogic := '0';
    testen       : in   std_ulogic := '0'
    );
end entity;

architecture rtl of grspw_gen is
  constant fabits1      : integer := log2(fifosize1);
  constant fabits2      : integer := log2(fifosize2);
  constant rfifo        : integer := 5 + log2(rmapbufs);

  signal rxclki, nrxclki, rxclko : std_logic_vector(1 downto 0);
  
  --rx ahb fifo
  signal rxrenable    : std_ulogic;
  signal rxraddress   : std_logic_vector(4 downto 0);
  signal rxwrite      : std_ulogic;
  signal rxwdata      : std_logic_vector(31 downto 0);
  signal rxwaddress   : std_logic_vector(4 downto 0);
  signal rxrdata      : std_logic_vector(31 downto 0);    
  --tx ahb fifo
  signal txrenable    : std_ulogic;
  signal txraddress   : std_logic_vector(4 downto 0);
  signal txwrite      : std_ulogic;
  signal txwdata      : std_logic_vector(31 downto 0);
  signal txwaddress   : std_logic_vector(4 downto 0);
  signal txrdata      : std_logic_vector(31 downto 0);    
  --nchar fifo
  signal ncrenable    : std_ulogic;
  signal ncraddress   : std_logic_vector(5 downto 0);
  signal ncwrite      : std_ulogic;
  signal ncwdata      : std_logic_vector(8 downto 0);
  signal ncwaddress   : std_logic_vector(5 downto 0);
  signal ncrdata      : std_logic_vector(8 downto 0);
  --rmap buf
  signal rmrenable    : std_ulogic;
  signal rmrenablex   : std_ulogic;
  signal rmraddress   : std_logic_vector(7 downto 0);
  signal rmwrite      : std_ulogic;
  signal rmwdata      : std_logic_vector(7 downto 0);
  signal rmwaddress   : std_logic_vector(7 downto 0);
  signal rmrdata      : std_logic_vector(7 downto 0);
  --misc
  signal rxclk, nrxclk : std_logic_vector(ports-1 downto 0);

  attribute syn_netlist_hierarchy : boolean;
  attribute syn_netlist_hierarchy of rtl : architecture is false;
  
begin  

  grspwc0 : grspwc 
    generic map(
      sysfreq      => sysfreq,
      usegen       => usegen,
      nsync        => nsync,
      rmap         => rmap,
      rmapcrc      => rmapcrc,
      fifosize1    => fifosize1,
      fifosize2    => fifosize2,
      rxunaligned  => rxunaligned,
      rmapbufs     => rmapbufs,
      scantest     => scantest,
      ports        => ports,
      tech         => tech)
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
      testclk      => clk,
      testrst      => testrst,
      testen       => testen
      );
 

  ntst: if scantest = 0 generate
    cloop : for i in 0 to ports-1 generate
      rx_clkbuf : techbuf generic map(tech => tech, buftype => rxclkbuftype)
        port map(i => rxclko(i), o => rxclki(i));
    end generate;
    rmrenablex <= rmrenable;
  end generate;
  tst: if scantest = 1 generate
    cloop : for i in 0 to ports-1 generate
      rxclk(i) <= clk when testen = '1' else rxclko(i);
      nrxclk(i) <= clk when testen = '1' else not rxclko(i);
      rx_clkbuf : techbuf generic map(tech => tech, buftype => rxclkbuftype)
        port map(i => rxclk(i), o => rxclki(i));
      nrx_clkbuf : techbuf generic map(tech => tech, buftype => rxclkbuftype)
        port map(i => nrxclk(i), o => nrxclki(i));
    end generate;
    rmrenablex <= rmrenable and not testen;
  end generate;

  ------------------------------------------------------------------------------
  -- FIFOS ---------------------------------------------------------------------
  ------------------------------------------------------------------------------

  nft : if ft = 0 generate
    --receiver AHB FIFO
    rx_ram0 : syncram_2p generic map(memtech*techfifo, fabits1, 32)
    port map(clk, rxrenable, rxraddress(fabits1-1 downto 0),
      rxrdata, clk, rxwrite,
      rxwaddress(fabits1-1 downto 0), rxwdata);
  
    --receiver nchar FIFO
    rx_ram1 : syncram_2p generic map(memtech*techfifo, fabits2, 9)
    port map(clk, ncrenable, ncraddress(fabits2-1 downto 0),
      ncrdata, clk, ncwrite,
      ncwaddress(fabits2-1 downto 0), ncwdata);
    
    --transmitter FIFO
    tx_ram0 : syncram_2p generic map(memtech*techfifo, fabits1, 32)
    port map(clk, txrenable, txraddress(fabits1-1 downto 0),
      txrdata, clk, txwrite, txwaddress(fabits1-1 downto 0), txwdata);

    --RMAP Buffer
    rmap_ram : if (rmap = 1) generate
      ram0 : syncram_2p generic map(memtech, rfifo, 8)
      port map(clk, rmrenablex, rmraddress(rfifo-1 downto 0),
        rmrdata, clk, rmwrite, rmwaddress(rfifo-1 downto 0),
        rmwdata);
    end generate;
  end generate;

  ft1 : if ft /= 0 generate
    --receiver AHB FIFO
    rx_ram0 : syncram_2pft generic map(memtech*techfifo, fabits1, 32, 0, 0, ft*techfifo)
    port map(clk, rxrenable, rxraddress(fabits1-1 downto 0),
      rxrdata, clk, rxwrite,
      rxwaddress(fabits1-1 downto 0), rxwdata);
  
    --receiver nchar FIFO
    rx_ram1 : syncram_2pft generic map(memtech*techfifo, fabits2, 9, 0, 0, 2*techfifo)
    port map(clk, ncrenable, ncraddress(fabits2-1 downto 0),
      ncrdata, clk, ncwrite,
      ncwaddress(fabits2-1 downto 0), ncwdata);
    
    --transmitter FIFO
    tx_ram0 : syncram_2pft generic map(memtech*techfifo, fabits1, 32, 0, 0, ft*techfifo)
    port map(clk, txrenable, txraddress(fabits1-1 downto 0),
      txrdata, clk, txwrite, txwaddress(fabits1-1 downto 0), txwdata);

    --RMAP Buffer
    rmap_ram : if (rmap = 1) generate
      ram0 : syncram_2pft generic map(memtech, rfifo, 8, 0, 0, 2)
      port map(clk, rmrenablex, rmraddress(rfifo-1 downto 0),
        rmrdata, clk, rmwrite, rmwaddress(rfifo-1 downto 0),
        rmwdata);
    end generate;
  end generate;
 
end architecture;
