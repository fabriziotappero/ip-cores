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
-- Entity: 	grspw
-- File:	grspw.vhd
-- Author:	Marko Isomaki - Gaisler Research 
-- Description: GRLIB wrapper for grspw core
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;
use techmap.netcomp.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.spacewire.all;
library spw;
use spw.spwcomp.all;

entity grspw is
  generic(
    tech         : integer range 0 to NTECH := DEFFABTECH;
    hindex       : integer range 0 to NAHBMST-1 := 0;
    pindex       : integer range 0 to NAPBSLV-1 := 0;
    paddr        : integer range 0 to 16#FFF#   := 0;
    pmask        : integer range 0 to 16#FFF#   := 16#FFF#;
    pirq         : integer range 0 to NAHBIRQ-1 := 0;
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
    netlist      : integer range 0 to 1 := 0;
    ports        : integer range 1 to 2 := 1;
    memtech      : integer range 0 to NTECH := DEFMEMTECH
  );
  port(
    rst        : in  std_ulogic;
    clk        : in  std_ulogic;
    txclk      : in  std_ulogic;
    ahbmi      : in  ahb_mst_in_type;
    ahbmo      : out ahb_mst_out_type;
    apbi       : in  apb_slv_in_type;
    apbo       : out apb_slv_out_type;
    swni       : in  grspw_in_type;
    swno       : out grspw_out_type
  );
end entity;

architecture rtl of grspw is
  constant fabits1      : integer := log2(fifosize1);
  constant fabits2      : integer := log2(fifosize2);
  constant rfifo        : integer := 5 + log2(rmapbufs);
  constant REVISION     : integer := 0; 
  constant pconfig      : apb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_SPW, 0, REVISION, pirq),
    1 => apb_iobar(paddr, pmask));

  constant hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_SPW, 0, REVISION, pirq),
  others => zero32);

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
  signal irq          : std_ulogic;
  signal rxclk, nrxclk : std_logic_vector(ports-1 downto 0);
  signal testin       : std_logic_vector(3 downto 0);
  
begin  

  testin <= ahbmi.testen & "000";

rtl : if netlist = 0 generate
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
      hgrant       => ahbmi.hgrant(hindex),
      hready       => ahbmi.hready,   
      hresp        => ahbmi.hresp,
      hrdata       => ahbmi.hrdata,
      --ahb mst out
      hbusreq      => ahbmo.hbusreq,
      hlock        => ahbmo.hlock,
      htrans       => ahbmo.htrans,
      haddr        => ahbmo.haddr,
      hwrite       => ahbmo.hwrite,
      hsize        => ahbmo.hsize,
      hburst       => ahbmo.hburst,
      hprot        => ahbmo.hprot,
      hwdata       => ahbmo.hwdata,
      --apb slv in 
      psel	   => apbi.psel(pindex),
      penable	   => apbi.penable,
      paddr	   => apbi.paddr,
      pwrite	   => apbi.pwrite,
      pwdata	   => apbi.pwdata,
      --apb slv out
      prdata       => apbo.prdata,
      --spw in
      di           => swni.d,
      si           => swni.s,
      --spw out
      do           => swno.d,
      so           => swno.s,
      --time iface
      tickin       => swni.tickin,
      tickout      => swno.tickout,
      --clk bufs
      rxclki       => rxclki,
      nrxclki      => nrxclki,
      rxclko       => rxclko,
      --irq
      irq          => irq,
      --misc     
      clkdiv10     => swni.clkdiv10,
      dcrstval     => swni.dcrstval,
      timerrstval  => swni.timerrstval,
      --rmapen    
      rmapen       => swni.rmapen, 
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
      linkdis      => swno.linkdis,
      testclk      => clk,
      testrst      => ahbmi.testrst,
      testen       => ahbmi.testen
      );
end generate;

struct : if netlist = 1 generate
  grspwc0 : grspwc_net 
    generic map(
      tech         => tech,
      sysfreq      => sysfreq,
      usegen       => usegen,
      nsync        => nsync,
      rmap         => rmap,
      rmapcrc      => rmapcrc,
      fifosize1    => fifosize1,
      fifosize2    => fifosize2,
      rxunaligned  => rxunaligned,
      rmapbufs     => rmapbufs,
      scantest     => scantest)
    port map(
      rst          => rst,
      clk          => clk,
      txclk        => txclk,
      --ahb mst in
      hgrant       => ahbmi.hgrant(hindex),
      hready       => ahbmi.hready,   
      hresp        => ahbmi.hresp,
      hrdata       => ahbmi.hrdata,
      --ahb mst out
      hbusreq      => ahbmo.hbusreq,
      hlock        => ahbmo.hlock,
      htrans       => ahbmo.htrans,
      haddr        => ahbmo.haddr,
      hwrite       => ahbmo.hwrite,
      hsize        => ahbmo.hsize,
      hburst       => ahbmo.hburst,
      hprot        => ahbmo.hprot,
      hwdata       => ahbmo.hwdata,
      --apb slv in 
      psel	   => apbi.psel(pindex),
      penable	   => apbi.penable,
      paddr	   => apbi.paddr,
      pwrite	   => apbi.pwrite,
      pwdata	   => apbi.pwdata,
      --apb slv out
      prdata       => apbo.prdata,
      --spw in
      di           => swni.d,
      si           => swni.s,
      --spw out
      do           => swno.d,
      so           => swno.s,
      --time iface
      tickin       => swni.tickin,
      tickout      => swno.tickout,
      --clk bufs
      rxclki       => rxclki,
      nrxclki      => nrxclki,
      rxclko       => rxclko,
      --irq
      irq          => irq,
      --misc     
      clkdiv10     => swni.clkdiv10,
      dcrstval     => swni.dcrstval,
      timerrstval  => swni.timerrstval,
      --rmapen    
      rmapen       => swni.rmapen, 
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
      linkdis      => swno.linkdis,
      testclk      => clk,
      testrst      => ahbmi.testrst,
      testen       => ahbmi.testen
      );
end generate;

  irqdrv : process(irq)
  begin
    apbo.pirq        <= (others => '0');
    apbo.pirq(pirq)  <= irq;
  end process;

  ahbmo.hirq   	   <= (others => '0');
  ahbmo.hconfig    <= hconfig;
  ahbmo.hindex     <= hindex;
  
  apbo.pconfig <= pconfig;
  apbo.pindex  <= pindex;

  ntst: if scantest = 0 generate
    cloop : for i in 0 to ports-1 generate
      rx_clkbuf : techbuf generic map(tech => tech, buftype => rxclkbuftype)
        port map(i => rxclko(i), o => rxclki(i));
    end generate;
    rmrenablex <= rmrenable;
  end generate;
  tst: if scantest = 1 generate
    cloop : for i in 0 to ports-1 generate
      rxclk(i) <= clk when ahbmi.testen = '1' else rxclko(i);
      nrxclk(i) <= clk when ahbmi.testen = '1' else not rxclko(i);
      rx_clkbuf : techbuf generic map(tech => tech, buftype => rxclkbuftype)
        port map(i => rxclk(i), o => rxclki(i));
      nrx_clkbuf : techbuf generic map(tech => tech, buftype => rxclkbuftype)
        port map(i => nrxclk(i), o => nrxclki(i));
    end generate;
    rmrenablex <= rmrenable and not ahbmi.testen;
  end generate;

  ------------------------------------------------------------------------------
  -- FIFOS ---------------------------------------------------------------------
  ------------------------------------------------------------------------------

  nft : if ft = 0 generate
    --receiver AHB FIFO
    rx_ram0 : syncram_2p generic map(memtech*techfifo, fabits1, 32)
    port map(clk, rxrenable, rxraddress(fabits1-1 downto 0), rxrdata, clk, 
	rxwrite, rxwaddress(fabits1-1 downto 0), rxwdata, testin);
  
    --receiver nchar FIFO
    rx_ram1 : syncram_2p generic map(memtech*techfifo, fabits2, 9)
    port map(clk, ncrenable, ncraddress(fabits2-1 downto 0), ncrdata, clk, 
	ncwrite, ncwaddress(fabits2-1 downto 0), ncwdata, testin);
    
    --transmitter FIFO
    tx_ram0 : syncram_2p generic map(memtech*techfifo, fabits1, 32)
    port map(clk, txrenable, txraddress(fabits1-1 downto 0), txrdata, clk, 
	txwrite, txwaddress(fabits1-1 downto 0), txwdata, testin);

    --RMAP Buffer
    rmap_ram : if (rmap = 1) generate
      ram0 : syncram_2p generic map(memtech, rfifo, 8)
      port map(clk, rmrenablex, rmraddress(rfifo-1 downto 0), rmrdata, clk, 
	rmwrite, rmwaddress(rfifo-1 downto 0), rmwdata, testin);
    end generate;
  end generate;

  ft1 : if ft /= 0 generate
    --receiver AHB FIFO
    rx_ram0 : syncram_2pft generic map(memtech*techfifo, fabits1, 32, 0, 0, ft*techfifo)
    port map(clk, rxrenable, rxraddress(fabits1-1 downto 0), rxrdata, clk, 
	rxwrite, rxwaddress(fabits1-1 downto 0), rxwdata, open, testin);
  
    --receiver nchar FIFO
    rx_ram1 : syncram_2pft generic map(memtech*techfifo, fabits2, 9, 0, 0, 2*techfifo)
    port map(clk, ncrenable, ncraddress(fabits2-1 downto 0),
      ncrdata, clk, ncwrite,
      ncwaddress(fabits2-1 downto 0), ncwdata, open, testin);
    
    --transmitter FIFO
    tx_ram0 : syncram_2pft generic map(memtech*techfifo, fabits1, 32, 0, 0, ft*techfifo)
    port map(clk, txrenable, txraddress(fabits1-1 downto 0),
      txrdata, clk, txwrite, txwaddress(fabits1-1 downto 0), txwdata, open, testin);

    --RMAP Buffer
    rmap_ram : if (rmap = 1) generate
      ram0 : syncram_2pft generic map(memtech, rfifo, 8, 0, 0, 2)
      port map(clk, rmrenablex, rmraddress(rfifo-1 downto 0),
        rmrdata, clk, rmwrite, rmwaddress(rfifo-1 downto 0),
        rmwdata, open, testin);
    end generate;
  end generate;

-- pragma translate_off
    msg0 : if (rmap = 0) generate
      bootmsg : report_version
        generic map ("grspw" & tost(pindex) &
	  ": Spacewire link rev " & tost(REVISION) & ", AHB fifos 2x" &
          tost(fifosize1*4)  & " bytes, rx fifo " & tost(fifosize2) &
         " bytes, irq " & tost(pirq));
    end generate;

    msg1 : if (rmap = 1) generate
      bootmsg : report_version
        generic map ("grspw" & tost(pindex) &
	  ": Spacewire link rev " & tost(REVISION) & ", AHB fifos 2x " &
          tost(fifosize1*4)  & " bytes, rx fifo " & tost(fifosize2) &
         " bytes, irq " & tost(pirq) & " , RMAP Buffer " &
         tost(rmapbufs*32) & " bytes");
    end generate;

    pr0 : process is
    begin
      wait for 100 ns;
      if sysfreq < 10000 then
        print("WARNING: System frequency too low for GRSPW");
      end if;
      wait;
    end process;
  
-- pragma translate_on
 
end architecture;
