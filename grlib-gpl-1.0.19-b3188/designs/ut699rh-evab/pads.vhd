-----------------------------------------------------------------------------
--  LEON3 Demonstration design
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
use work.config.all;
library techmap;
use techmap.gencomp.all;

entity pads is
  generic (
    padtech   : integer := CFG_PADTECH
  );
  port (
    resetn	: in  std_ulogic;
    clk		: in  std_ulogic;
    errorn	: inout std_ulogic;
    address 	: out std_logic_vector(27 downto 0);
    data	: inout std_logic_vector(31 downto 0);
    cb   	: inout std_logic_vector(7 downto 0);
    sdclk  	: out std_ulogic;
    sdcsn  	: out std_logic_vector (1 downto 0);    -- sdram chip select
    sdwen  	: out std_ulogic;                       -- sdram write enable
    sdrasn  	: out std_ulogic;                       -- sdram ras
    sdcasn  	: out std_ulogic;                       -- sdram cas
    sddqm   	: out std_logic_vector (3 downto 0);    -- sdram dqm
    dsutx  	: out std_ulogic; 			-- DSU tx data
    dsurx  	: in  std_ulogic;  			-- DSU rx data
    dsuen   	: in std_ulogic;
    dsubre  	: in std_ulogic;
    dsuact  	: out std_ulogic;
    txd1   	: out std_ulogic; 			-- UART1 tx data
    rxd1   	: in  std_ulogic;  			-- UART1 rx data
    ramsn  	: out std_logic_vector (4 downto 0);
    ramoen 	: out std_logic_vector (4 downto 0);
    rwen   	: out std_logic_vector (3 downto 0);
    oen    	: out std_ulogic;
    writen 	: inout std_ulogic;
    read   	: out std_ulogic;
    iosn   	: out std_ulogic;
    romsn  	: out std_logic_vector (1 downto 0);
    brdyn  	: in  std_ulogic;
    bexcn  	: in  std_ulogic;
    wdogn  	: inout std_ulogic;
    gpio        : inout std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port

    emdio     	: inout std_logic;		-- ethernet PHY interface
    etx_clk 	: in std_ulogic;
    erx_clk 	: in std_ulogic;
    erxd    	: in std_logic_vector(3 downto 0);   
    erx_dv  	: in std_ulogic; 
    erx_er  	: in std_ulogic; 
    erx_col 	: in std_ulogic;
    erx_crs 	: in std_ulogic;
    etxd 	: out std_logic_vector(3 downto 0);   
    etx_en 	: out std_ulogic; 
    etx_er 	: out std_ulogic; 
    emdc 	: out std_ulogic;

    pci_rst     : in std_ulogic;		-- PCI bus
    pci_clk 	: in std_ulogic;
    pci_gnt     : in std_ulogic;
    pci_idsel   : in std_ulogic; 
    pci_ad 	: inout std_logic_vector(31 downto 0);
    pci_cbe 	: inout std_logic_vector(3 downto 0);
    pci_frame   : inout std_ulogic;
    pci_irdy 	: inout std_ulogic;
    pci_trdy 	: inout std_ulogic;
    pci_devsel  : inout std_ulogic;
    pci_stop 	: inout std_ulogic;
    pci_perr 	: inout std_ulogic;
    pci_par 	: inout std_ulogic;    
    pci_req 	: out std_ulogic;
    pci_host   	: in std_ulogic;

    pci_arb_req	: in  std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);
    pci_arb_gnt	: out std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);

    can_txd	: out std_logic_vector(0 to CFG_CAN_NUM-1);
    can_rxd	: in  std_logic_vector(0 to CFG_CAN_NUM-1);

    spw_clk	: in  std_ulogic;
    spw_rxd     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxs     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txd     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txs     : out std_logic_vector(0 to CFG_SPW_NUM-1);

    tck         : in std_ulogic;
    tms         : in std_ulogic;
    tdi         : in std_ulogic;
    tdo         : out std_ulogic;
    trst        : in std_ulogic;

    test       	: in  std_ulogic;

    lresetn	: out std_ulogic;
    lclk	: out std_ulogic;
    lerrorn	: in std_ulogic;
    laddress 	: in std_logic_vector(27 downto 0);
    datain	: out std_logic_vector(31 downto 0);
    dataout	: in std_logic_vector(31 downto 0);
    dataen	: in std_logic_vector(31 downto 0);
    cbin   	: out std_logic_vector(7 downto 0);
    cbout   	: in std_logic_vector(7 downto 0);
    cben   	: in std_logic_vector(7 downto 0);
    lsdclk  	: in std_ulogic;
    lsdcsn  	: in std_logic_vector (1 downto 0);    -- sdram chip select
    lsdwen  	: in std_ulogic;                       -- sdram write enable
    lsdrasn  	: in std_ulogic;                       -- sdram ras
    lsdcasn  	: in std_ulogic;                       -- sdram cas
    lsddqm   	: in std_logic_vector (3 downto 0);    -- sdram dqm
    ldsutx  	: in std_ulogic; 			-- DSU tx data
    ldsurx  	: out std_ulogic;  			-- DSU rx data
    ldsuen   	: out std_ulogic;
    ldsubre  	: out std_ulogic;
    ldsuact  	: in std_ulogic;
    ltxd1   	: in std_ulogic; 			-- UART1 tx data
    lrxd1   	: out std_ulogic;  			-- UART1 rx data
    lramsn  	: in std_logic_vector (4 downto 0);
    lramoen 	: in std_logic_vector (4 downto 0);
    lrwen   	: in std_logic_vector (3 downto 0);
    loen    	: in std_ulogic;
    lwriten 	: in std_ulogic;
    lread   	: in std_ulogic;
    liosn   	: in std_ulogic;
    lromsn  	: in std_logic_vector (1 downto 0);
    lbrdyn  	: out std_ulogic;
    lbexcn  	: out std_ulogic;
    lwdogn  	: in std_ulogic;
    gpioin      : out std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    gpioout     : in std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    gpioen      : in std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    lwritefb 	: out std_ulogic;

    ethi_mdio_i : out std_logic;		-- ethernet PHY interface
    etho_mdio_o : in std_logic;
    etho_mdio_oe: in std_logic;
    ethi_tx_clk	: out std_ulogic;
    ethi_rx_clk	: out std_ulogic;
    ethi_rxd   	: out std_logic_vector(3 downto 0);   
    ethi_rx_dv 	: out std_ulogic; 
    ethi_rx_er 	: out std_ulogic; 
    ethi_rx_col	: out std_ulogic;
    ethi_rx_crs : out std_ulogic;
    etho_txd 	: in std_logic_vector(3 downto 0);   
    etho_tx_en 	: in std_ulogic; 
    etho_tx_er 	: in std_ulogic; 
    etho_mdc 	: in std_ulogic;

    lpciclk 	: out std_ulogic;
    pcii_rst 	: out std_ulogic;
    pcii_gnt 	: out std_ulogic;
    pcii_idsel 	: out std_ulogic;
    pcii_ad 	: out std_logic_vector(31 downto 0);
    pcii_cbe 	: out std_logic_vector(3 downto 0);
    pcii_frame	: out std_ulogic;
    pcii_irdy   : out std_ulogic;
    pcii_trdy   : out std_ulogic;
    pcii_devsel : out std_ulogic;
    pcii_stop   : out std_ulogic;
    pcii_perr   : out std_ulogic;
    pcii_par 	: out std_ulogic;
    pcii_host   : out std_ulogic;

    pcio_vaden   : in std_logic_vector(31 downto 0);
    pcio_cbeen   : in std_logic_vector(3 downto 0);
    pcio_frameen : in std_ulogic;
    pcio_irdyen  : in std_ulogic;
    pcio_trdyen  : in std_ulogic;
    pcio_devselen:  in std_ulogic;
    pcio_stopen : in std_ulogic;
    pcio_perren : in std_ulogic;
    pcio_paren 	: in std_ulogic;
    pcio_reqen	: in std_ulogic;
    pcio_locken : in std_ulogic;
    pcio_req    : in std_ulogic;
    pcio_ad 	: in std_logic_vector(31 downto 0);
    pcio_cbe 	: in std_logic_vector(3 downto 0);
    pcio_frame  : in std_ulogic;
    pcio_irdy   : in std_ulogic;
    pcio_trdy   : in std_ulogic;
    pcio_devsel : in std_ulogic;
    pcio_stop   : in std_ulogic;
    pcio_perr   : in std_ulogic;
    pcio_par    : in std_ulogic;

    pcii_arb_req: out std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);
    pcio_arb_gnt: in  std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);

    can_ltx	: in  std_logic_vector(0 to CFG_CAN_NUM-1);
    can_lrx	: out std_logic_vector(0 to CFG_CAN_NUM-1);

    lspw_clk	: out std_ulogic;
    lspw_rxd    : out std_logic_vector(0 to CFG_SPW_NUM-1);
    lspw_rxs    : out std_logic_vector(0 to CFG_SPW_NUM-1);
    lspw_txd    : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    lspw_txs    : in  std_logic_vector(0 to CFG_SPW_NUM-1);

    ltck        : out std_ulogic;
    ltms        : out std_ulogic;
    ltdi        : out std_ulogic;
    ltdo        : in  std_ulogic;
    ltrst       : out std_ulogic;

    ltest : out std_ulogic
	);
end;

architecture rtl of pads is

signal vcc, gnd : std_logic_vector(4 downto 0);
signal ltestenablex : std_ulogic;
signal oref, iref, refp, refn, wrdr : std_ulogic;
constant OEPOL : integer := padoen_polarity(padtech);
constant INSCLKPADS : integer := 1;
constant SCANTEST : integer := 1;
constant clkpadtech : integer := padtech * INSCLKPADS;
constant CFG_SDEN : integer := CFG_MCTRLFT_SDEN + CFG_MCTRL_SDEN;

begin

  vcc <= (others => '1'); gnd <= (others => '0');
  wrdr <= '1' when OEPOL = 1 else '0';
  ltest <= '0' when (is_fpga(padtech) = 1) or (SCANTEST = 0) else ltestenablex;
  testen_pad : inpad generic map (tech => padtech) port map (test, ltestenablex); 
  clk_pad : clkpad generic map (tech => clkpadtech) port map (clk, lclk); 
  spw_clk_pad : clkpad generic map (tech => clkpadtech) port map (spw_clk, lspw_clk); 

  resetn_pad : inpad generic map (tech => padtech, filter => schmitt) 
    port map (resetn, lresetn); 

  errorn_pad : odpad generic map (tech => padtech, strength => 2, oepol => OEPOL) 
    port map (errorn, lerrorn);

  dsuen_pad  : inpad  generic map (tech => padtech) port map (dsuen, ldsuen); 
  dsubre_pad : inpad  generic map (tech => padtech) port map (dsubre, ldsubre); 
  dsuact_pad : outpad generic map (tech => padtech, strength => 2) port map (dsuact, ldsuact);
  dsurx_pad  : inpad  generic map (tech => padtech) port map (dsurx, ldsurx); 
  dsutx_pad  : outpad generic map (tech => padtech, strength => 2) port map (dsutx, ldsutx);
  
  addr_pad : outpadv generic map (width => 28, tech => padtech, strength => 12) 
	port map (address, laddress(27 downto 0)); 
  rams_pad : outpadv generic map (width => 5, tech => padtech, strength => 12) 
	port map (ramsn, lramsn); 
  roms_pad : outpadv generic map (width => 2, tech => padtech, strength => 12) 
	port map (romsn, lromsn); 
  oen_pad  : outpad generic map (tech => padtech, strength => 12) 
	port map (oen, loen);
  rwen_pad : outpadv generic map (width => 4, tech => padtech, strength => 12) 
	port map (rwen, lrwen); 
  roen_pad : outpadv generic map (width => 5, tech => padtech, strength => 12) 
	port map (ramoen, lramoen);
  wri_pad  : iopad generic map (tech => padtech, strength => 12, oepol => OEPOL) 
	port map (writen, lwriten, wrdr, lwritefb );
  read_pad : outpad generic map (tech => padtech, strength => 12) 
	port map (read, lread); 
  iosn_pad : outpad generic map (tech => padtech, strength => 12) 
	port map (iosn, liosn);
  bdr : for i in 0 to 31 generate
      data_pad : iopad generic map (tech => padtech, strength => 12, oepol => OEPOL)
      port map (data(i), dataout(i), dataen(i), datain(i));
  end generate;
  sdpads : if CFG_SDEN /= 0 generate
    sdclk_pad : outpad generic map (tech => padtech, strength => 12, slew => 1) 
	port map (sdclk, lsdclk);
    sdwen_pad : outpad generic map (tech => padtech, strength => 12) 
	   port map (sdwen, lsdwen);
    sdras_pad : outpad generic map (tech => padtech, strength => 12) 
	   port map (sdrasn, lsdrasn);
    sdcas_pad : outpad generic map (tech => padtech, strength => 12) 
	   port map (sdcasn, lsdcasn);
    sddqm_pad : outpadv generic map (width => 4, tech => padtech, strength => 12) 
	   port map (sddqm, lsddqm);
    sdcsn_pad : outpadv generic map (width =>2, tech => padtech, strength => 12) 
	   port map (sdcsn, lsdcsn); 
  end generate;

  cdr : for i in 0 to 7 generate
      cb_pad : iopad generic map (tech => padtech, strength => 12, oepol => OEPOL)
      port map (cb(i), cbout(i), cben(i), cbin(i));
  end generate;

  brdyn_pad : inpad generic map (tech => padtech) port map (brdyn, lbrdyn); 
  bexcn_pad : inpad generic map (tech => padtech) port map (bexcn, lbexcn); 

  txd1_pad : outpad generic map (tech => padtech) port map (txd1, ltxd1);
  rxd1_pad : inpad generic map (tech => padtech) port map (rxd1, lrxd1); 

  wdogn_pad : odpad generic map (tech => padtech, strength => 2, oepol => OEPOL) port map (wdogn, lwdogn);

  pio_pads : for i in 0 to CFG_GRGPIO_WIDTH-1 generate
    pio_pad : iopad generic map (tech => padtech, strength => 12,  oepol => OEPOL)
      port map (gpio(i), gpioout(i), gpioen(i), gpioin(i));
  end generate;

  eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
      emdio_pad : iopad generic map (tech => padtech, oepol => OEPOL, strength => 2) 
      port map (emdio, etho_mdio_o, etho_mdio_oe, ethi_mdio_i);
      etxc_pad : clkpad generic map (tech => clkpadtech, arch => 1) 
	port map (etx_clk, ethi_tx_clk);
      erxc_pad : clkpad generic map (tech => clkpadtech, arch => 1) 
	port map (erx_clk, ethi_rx_clk);
      erxd_pad : inpadv generic map (tech => padtech, width => 4) 
	port map (erxd, ethi_rxd(3 downto 0));
      erxdv_pad : inpad generic map (tech => padtech) 
	port map (erx_dv, ethi_rx_dv);
      erxer_pad : inpad generic map (tech => padtech) 
	port map (erx_er, ethi_rx_er);
      erxco_pad : inpad generic map (tech => padtech) 
	port map (erx_col, ethi_rx_col);
      erxcr_pad : inpad generic map (tech => padtech) 
	port map (erx_crs, ethi_rx_crs);

      etxd_pad : outpadv generic map (tech => padtech, width => 4, strength => 2) 
	port map (etxd, etho_txd(3 downto 0));
      etxen_pad : outpad generic map (tech => padtech, strength => 2) 
	port map ( etx_en, etho_tx_en);
      etxer_pad : outpad generic map (tech => padtech, strength => 2) 
	port map (etx_er, etho_tx_er);
      emdc_pad : outpad generic map (tech => padtech, strength => 2) 
	port map (emdc, etho_mdc);
  end generate;


  pci_clk_pad : clkpad generic map (tech => clkpadtech, arch => 1) 
	port map (pci_clk, lpciclk);
  pad_pci_rst   : inpad generic map (padtech, pci33, 0) port map (pci_rst, pcii_rst);
  pad_pci_gnt   : inpad generic map (padtech) port map (pci_gnt, pcii_gnt);
  pad_pci_idsel : inpad generic map (padtech, pci33, 0) port map (pci_idsel, pcii_idsel);
  pad_pci_host  : inpad generic map (padtech) port map (pci_host, pcii_host);
  pad_pci_ad    : iopadvv generic map (tech => padtech, level => pci33, width => 32,
				      strength => 12, oepol => oepol)
	          port map (pci_ad, pcio_ad, pcio_vaden, pcii_ad);
  pad_pci_cbe0  : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_cbe(0), pcio_cbe(0), pcio_cbeen(0), pcii_cbe(0));
  pad_pci_cbe1  : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_cbe(1), pcio_cbe(1), pcio_cbeen(1), pcii_cbe(1));
  pad_pci_cbe2  : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_cbe(2), pcio_cbe(2), pcio_cbeen(2), pcii_cbe(2));
  pad_pci_cbe3  : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_cbe(3), pcio_cbe(3), pcio_cbeen(3), pcii_cbe(3));
  pad_pci_frame : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_frame, pcio_frame, pcio_frameen, pcii_frame);
  pad_pci_trdy  : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_trdy, pcio_trdy, pcio_trdyen, pcii_trdy);
  pad_pci_irdy  : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_irdy, pcio_irdy, pcio_irdyen, pcii_irdy);
  pad_pci_devsel: iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_devsel, pcio_devsel, pcio_devselen, pcii_devsel);
  pad_pci_stop  : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_stop, pcio_stop, pcio_stopen, pcii_stop);
  pad_pci_perr  : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_perr, pcio_perr, pcio_perren, pcii_perr);
  pad_pci_par   : iopad generic map (tech => padtech, level => pci33, oepol => oepol, strength => 12)
	          port map (pci_par, pcio_par, pcio_paren, pcii_par);
  pad_pci_req   : toutpad generic map (tech => padtech, strength => 4, oepol => oepol)
	          port map (pci_req, pcio_req, pcio_reqen);

  pci_arb_req_pad : inpadv generic map (tech => padtech, width => CFG_PCI_ARB_NGNT) 
	port map (pci_arb_req, pcii_arb_req);
  pci_arb_gnt_pad : outpadv generic map (tech => padtech, width => CFG_PCI_ARB_NGNT, strength => 4) 
	port map (pci_arb_gnt, pcio_arb_gnt);

  spw : if CFG_SPW_EN > 0 generate
    spw_pads : for i in 0 to CFG_SPW_NUM-1 generate
         spw_txd_pad : outpad generic map (tech => padtech, strength => 12)
            port map (spw_txd(i), lspw_txd(i));
         spw_txs_pad : outpad generic map (tech => padtech, strength => 12)
            port map (spw_txs(i), lspw_txs(i));
         spw_rxd_pad : inpad generic map (tech => padtech)
            port map (spw_rxd(i), lspw_rxd(i));
         spw_rxs_pad : inpad generic map (tech => padtech)
            port map (spw_rxs(i), lspw_rxs(i));
    end generate;
  end generate;

  can : if CFG_CAN = 1 generate 
     can_pads : for i in 0 to CFG_CAN_NUM-1 generate
         can_tx_pad : outpad generic map (tech => padtech, strength => 2)
            port map (can_txd(i), can_ltx(i));
         can_rx_pad : inpad generic map (tech => padtech)
            port map (can_rxd(i), can_lrx(i));
     end generate;
  end generate;

  jtag :if CFG_AHB_JTAG = 1 generate
    tck_pad : inpad generic map (tech => padtech) port map (tck, ltck);
    tms_pad : inpad generic map (tech => padtech) port map (tms, ltms);
    tdi_pad : inpad generic map (tech => padtech) port map (tdi, ltdi);
    tdo_pad : outpad generic map (tech => padtech, strength => 2) port map (tdo, ltdo);
    trst_pad : inpad generic map (tech => padtech) port map (trst, ltrst);
  end generate;


end;
