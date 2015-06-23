-----------------------------------------------------------------------------
--  Ethernet/PCI bridge Demonstration design
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
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
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.pci.all;
use gaisler.net.all;
use gaisler.jtag.all;
use work.config.all;

entity netcard is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH
  );
  port (
    resetn	: in  std_ulogic;
    clk		: in  std_ulogic;
    dsutx  	: out std_ulogic; 			-- DSU tx data
    dsurx  	: in  std_ulogic;  			-- DSU rx data

    emdio     	: inout std_logic;
    etx_clk 	: in std_logic;
    erx_clk 	: in std_logic;
    erxd    	: in std_logic_vector(3 downto 0);   
    erx_dv  	: in std_logic; 
    erx_er  	: in std_logic; 
    erx_col 	: in std_logic;
    erx_crs 	: in std_logic;
    etxd 	: out std_logic_vector(3 downto 0);   
    etx_en 	: out std_logic; 
    etx_er 	: out std_logic; 
    emdc 	: out std_logic;

    pci_rst     : in std_ulogic;		-- PCI bus
    pci_clk 	: in std_ulogic;
    pci_gnt     : in std_ulogic;
    pci_idsel   : in std_ulogic; 
    pci_lock    : inout std_ulogic; 
    pci_ad 	: inout std_logic_vector(31 downto 0);
    pci_cbe 	: inout std_logic_vector(3 downto 0);
    pci_frame   : inout std_ulogic;
    pci_irdy 	: inout std_ulogic;
    pci_trdy 	: inout std_ulogic;
    pci_devsel  : inout std_ulogic;
    pci_stop 	: inout std_ulogic;
    pci_perr 	: inout std_ulogic;
    pci_par 	: inout std_ulogic;    
    pci_req 	: inout std_ulogic;
    pci_serr    : inout std_ulogic;
    pci_irq     : out std_ulogic;
    pci_host   	: in std_ulogic;
    pci_66	: in std_ulogic
  );
end;

architecture rtl of netcard is

signal apbi : apb_slv_in_type;
signal apbo : apb_slv_out_vector := (others => apb_none);
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
signal ahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);
signal clkm, rstn, pciclk : std_ulogic;
signal cgi : clkgen_in_type;
signal cgo : clkgen_out_type;

signal dui : uart_in_type;
signal duo : uart_out_type;

signal pcii : pci_in_type;
signal pcio : pci_out_type;

signal ethi : eth_in_type;
signal etho : eth_out_type;
signal tck, tms, tdi, tdo : std_ulogic;

signal irqn, lclk, gnd : std_logic;

constant blength : integer := 12;
constant fifodepth : integer := 8;

constant maxahb : integer := CFG_AHB_UART+
	CFG_GRETH+CFG_AHB_JTAG+log2x(CFG_PCI);

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  gnd <= '0';
  cgi.pllctrl <= "00"; cgi.pllrst <= resetn; cgi.pllref <= '0';

  clkgen0 : clkgen  		-- clock generator
  generic map (clktech, CFG_CLKMUL, CFG_CLKDIV, 0, 
	0, CFG_PCI, CFG_PCIDLL, CFG_PCISYSCLK)
  port map (lclk, pci_clk, clkm, open, open, open, pciclk, cgi, cgo);
  clk_pad : clkpad generic map (tech => padtech) port map (clk, lclk); 

  rst0 : rstgen			-- reset generator
  port map (resetn, clkm, cgo.clklock, rstn);

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl 		-- AHB arbiter/multiplexer
  generic map (nahbm => maxahb, nahbs => 4, ioen => 0)
  port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
    e0 : greth generic map(hindex => log2x(CFG_PCI),
	pindex => 0, paddr => 11, pirq => 11, memtech => memtech)
     port map( rst => rstn, clk => clk, ahbmi => ahbmi, ahbmo => ahbmo(log2x(CFG_PCI)), 
	apbi => apbi, apbo => apbo(0), ethi => ethi, etho => etho); 

      emdio_pad : iopad generic map (tech => padtech) 
      port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
      etxc_pad : clkpad generic map (tech => padtech, arch => 1) 
	port map (etx_clk, ethi.tx_clk);
      erxc_pad : clkpad generic map (tech => padtech, arch => 1) 
	port map (erx_clk, ethi.rx_clk);
      erxd_pad : inpadv generic map (tech => padtech, width => 4) 
	port map (erxd, ethi.rxd(3 downto 0));
      erxdv_pad : inpad generic map (tech => padtech) 
	port map (erx_dv, ethi.rx_dv);
      erxer_pad : inpad generic map (tech => padtech) 
	port map (erx_er, ethi.rx_er);
      erxco_pad : inpad generic map (tech => padtech) 
	port map (erx_col, ethi.rx_col);
      erxcr_pad : inpad generic map (tech => padtech) 
	port map (erx_crs, ethi.rx_crs);

      etxd_pad : outpadv generic map (tech => padtech, width => 4) 
	port map (etxd, etho.txd(3 downto 0));
      etxen_pad : outpad generic map (tech => padtech) 
	port map ( etx_en, etho.tx_en);
      etxer_pad : outpad generic map (tech => padtech) 
	port map (etx_er, etho.tx_er);
      emdc_pad : outpad generic map (tech => padtech) 
	port map (emdc, etho.mdc);

  end generate;

  irqn        <= ahbso(3).hirq(11);

  irq_pad : odpad generic map (tech => padtech, level => pci33)
  port map (pci_irq, irqn);

----------------------------------------------------------------------
---  AHB/APB Bridge  -------------------------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl			-- AHB/APB bridge
  generic map (hindex => 0, haddr => 16#800#)
  port map (rstn, clkm, ahbsi, ahbso(0), apbi, apbo );

----------------------------------------------------------------------
---  AHB RAM  --------------------------------------------------------
----------------------------------------------------------------------


  ram0 : if CFG_AHBRAMEN = 1 generate 
    ahbram0 : ahbram generic map (hindex => 2, haddr => CFG_AHBRADDR, 
	tech => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
    port map ( rstn, clkm, ahbsi, ahbso(2));
  end generate;

-----------------------------------------------------------------------
---  PCI   ------------------------------------------------------------
-----------------------------------------------------------------------

  pp : if CFG_PCI /= 0 generate

    pci_gr0 : if CFG_PCI = 1 generate	-- simple target-only
      pci0 : pci_target generic map (hindex => 0,
	device_id => 16#0210#, vendor_id => 16#16E3#)
      port map (rstn, clkm, pciclk, pcii, pcio, ahbmi, ahbmo(0));
    end generate;

    pci_mtf0 : if CFG_PCI = 2 generate	-- master/target with fifo
      pci0 : pci_mtf generic map (memtech => memtech, hmstndx => 0, 
	  fifodepth => 6, device_id => 16#0210#, vendor_id => 16#16E3#,
	  hslvndx => 1, pindex => 6, paddr => 2, haddr => 16#E00#,
	  ioaddr => 16#400#, nsync => 2)
      port map (rstn, clkm, pciclk, pcii, pcio, apbi, apbo(6),
	ahbmi, ahbmo(0), ahbsi, ahbso(1));
    end generate;

    pci_dma : if CFG_PCI = 3 generate	-- master/target with fifo and DMA
      dma : pcidma generic map (memtech => memtech, dmstndx => 1, 
	  dapbndx => 5, dapbaddr => 5, blength => blength, mstndx => 0,
	  fifodepth => log2(fifodepth), device_id => CFG_PCIDID, vendor_id => CFG_PCIVID,
	  slvndx => 4, apbndx => 4, apbaddr => 4, haddr => 16#E00#, ioaddr => 16#800#, 
	  nsync => 1)
      	port map (rstn, clkm, pciclk, pcii, pcio, apbo(5),  ahbmo(1), 
 	  apbi, apbo(4), ahbmi, ahbmo(0), ahbsi, ahbso(4));
    end generate;

    pci_trc0 : if CFG_PCITBUFEN /= 0 generate	-- PCI trace buffer
      pt0 : pcitrace generic map (memtech => memtech, pindex  => 3, 
			     paddr => 16#100#, pmask => 16#f00#)
            port map ( rstn, clkm, pciclk, pcii, apbi, apbo(3));
    end generate;
    pcipads0 : pcipads generic map (padtech)
    port map ( pci_rst, pci_gnt, pci_idsel, pci_lock, pci_ad, pci_cbe,
      pci_frame, pci_irdy, pci_trdy, pci_devsel, pci_stop, pci_perr,
      pci_par, pci_req, pci_serr, pci_host, pci_66, pcii, pcio );
  end generate;

----------------------------------------------------------------------
---  Optional DSU UARTs ----------------------------------------------
----------------------------------------------------------------------

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0: ahbuart		-- Debug UART
    generic map (hindex => log2x(CFG_PCI)+CFG_GRETH, pindex => 1, paddr => 1)
    port map (rstn, clkm, dui, duo, apbi, apbo(1), ahbmi, ahbmo(log2x(CFG_PCI)+CFG_GRETH));
    dsurx_pad : inpad generic map (tech => padtech) port map (dsurx, dui.rxd); 
    dsutx_pad : outpad generic map (tech => padtech) port map (dsutx, duo.txd);
  end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, 
	hindex => log2x(CFG_PCI)+CFG_GRETH+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, 
	ahbmo(log2x(CFG_PCI)+CFG_GRETH+CFG_AHB_UART), open, open, open, 
	open, open, open, open, gnd);
  end generate;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "Ethernet/PCI Network Card Demonstration design",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );

-- pragma translate_on
end;
