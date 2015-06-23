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
use techmap.allclkgen.all;

entity leon3mp is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW
  );
  port (
    resetn	: in  std_logic;
    clk		: in  std_logic;
    errorn	: inout std_logic;
    wdogn  	: inout std_logic;

    address 	: out   std_logic_vector(27 downto 0);
    data	: inout std_logic_vector(31 downto 0);
    cb   	: inout std_logic_vector(7 downto 0);

    sdclk  	: out std_logic;
    sdcke  	: out std_logic_vector (1 downto 0);    -- sdram chip select
    sdcsn  	: out std_logic_vector (1 downto 0);    -- sdram chip select
    sdwen  	: out std_logic;                       -- sdram write enable
    sdrasn  	: out std_logic;                       -- sdram ras
    sdcasn  	: out std_logic;                       -- sdram cas
    sddqm   	: out std_logic_vector (3 downto 0);    -- sdram dqm
    dsutx  	: out std_logic; 			-- DSU tx data / scanout
    dsurx  	: in  std_logic;  			-- DSU rx data / scanin
    dsuen   	: in std_logic;
    dsubre  	: in std_logic;			-- DSU break / scanen
    dsuact  	: out std_logic;			-- DSU active / NT
    txd1   	: out std_logic; 			-- UART1 tx data
    rxd1   	: in  std_logic;  			-- UART1 rx data

    ramsn  	: out std_logic_vector (4 downto 0);
    ramoen 	: out std_logic_vector (4 downto 0);
    rwen   	: out std_logic_vector (3 downto 0);
    oen    	: out std_logic;
    writen 	: inout std_logic;
    read   	: out std_logic;
    iosn   	: out std_logic;
    romsn  	: out std_logic_vector (1 downto 0);
    brdyn  	: in  std_logic;
    bexcn  	: in  std_logic;
    gpio        : inout std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port

    emdio     	: inout std_logic;		-- ethernet PHY interface
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

    pci_rst     : in std_logic;		-- PCI bus
    pci_clk 	: in std_logic;
    pci_gnt     : in std_logic;
    pci_idsel   : in std_logic; 
    pci_ad 	: inout std_logic_vector(31 downto 0);
    pci_cbe 	: inout std_logic_vector(3 downto 0);
    pci_frame   : inout std_logic;
    pci_irdy 	: inout std_logic;
    pci_trdy 	: inout std_logic;
    pci_devsel  : inout std_logic;
    pci_stop 	: inout std_logic;
    pci_perr 	: inout std_logic;
    pci_par 	: inout std_logic;    
    pci_req 	: out std_logic;
    pci_host   	: in std_logic;

    pci_arb_req	: in  std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);
    pci_arb_gnt	: out std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);

    can_txd	: out std_logic_vector(0 to CFG_CAN_NUM-1);
    can_rxd	: in  std_logic_vector(0 to CFG_CAN_NUM-1);

--    spw_clk	: in  std_logic;
--    spw_rxd     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
--    spw_rxs     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
--    spw_txd     : out std_logic_vector(0 to CFG_SPW_NUM-1);
--    spw_txs     : out std_logic_vector(0 to CFG_SPW_NUM-1);

--    tck         : in std_logic;
--    tms         : in std_logic;
--    tdi         : in std_logic;
--    tdo         : out std_logic;

--    test       	: in  std_logic

    spw_clkp	  : in  std_logic;
    spw_clkn	  : in  std_logic;
    spw_rxdp      : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxdn      : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxsp      : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxsn      : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txdp      : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txdn      : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txsp      : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txsn      : out std_logic_vector(0 to CFG_SPW_NUM-1);
    pllref   	  : in  std_logic
	);
end;

architecture rtl of leon3mp is

signal lresetn	: std_logic;
signal lclk	: std_logic;
signal lerrorn	: std_logic;
signal laddress : std_logic_vector(27 downto 0);
signal datain	: std_logic_vector(31 downto 0);
signal dataout	: std_logic_vector(31 downto 0);
signal dataen 	: std_logic_vector(31 downto 0);
signal cbin   	: std_logic_vector(7 downto 0);
signal cbout   	: std_logic_vector(7 downto 0);
signal cben   	: std_logic_vector(7 downto 0);
signal lsdclk  	: std_logic;
--signal sdclk  	: std_logic;
signal lsdcsn  	: std_logic_vector (1 downto 0);    -- sdram chip select
signal lsdwen  	: std_logic;                       -- sdram write enable
signal lsdrasn  : std_logic;                       -- sdram ras
signal lsdcasn  : std_logic;                       -- sdram cas
signal lsddqm   : std_logic_vector (3 downto 0);    -- sdram dqm
signal ldsutx  	: std_logic; 			-- DSU tx data
signal ldsurx  	: std_logic;  			-- DSU rx data
signal ldsuen   : std_logic;
signal ldsubre  : std_logic;
signal ldsuact  : std_logic;
signal ltxd1   	: std_logic; 			-- UART1 tx data
signal lrxd1   	: std_logic;  			-- UART1 rx data
signal lramsn  	: std_logic_vector (4 downto 0);
signal lramoen 	: std_logic_vector (4 downto 0);
signal lrwen   	: std_logic_vector (3 downto 0);
signal loen    	: std_logic;
signal lwriten 	: std_logic;
signal lread   	: std_logic;
signal liosn   	: std_logic;
signal lromsn  	: std_logic_vector (1 downto 0);
signal lbrdyn  	: std_logic;
signal lbexcn  	: std_logic;
signal lwdogn  	: std_logic;
signal gpioin   : std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
signal gpioout  : std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
signal gpioen   : std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port

signal can_lrx, can_ltx   : std_logic_vector(0 to CFG_CAN_NUM-1);

signal lspw_clk	: std_logic;
signal spw_clkl	: std_logic;
signal lspw_rxd  : std_logic_vector(0 to CFG_SPW_NUM-1);
signal lspw_rxs  : std_logic_vector(0 to CFG_SPW_NUM-1);
signal lspw_txd  : std_logic_vector(0 to CFG_SPW_NUM-1);
signal lspw_txs  : std_logic_vector(0 to CFG_SPW_NUM-1);
signal lspw_ten  : std_logic_vector(0 to CFG_SPW_NUM-1);

signal ltest 	: std_logic;
constant OEPOL 	: integer := padoen_polarity(padtech);

signal lpciclk 	: std_logic;
signal pcii_rst 	: std_logic;
signal pcii_gnt 	: std_logic;
signal pcii_idsel 	: std_logic;
signal pcii_ad 	: std_logic_vector(31 downto 0);
signal pcii_cbe 	: std_logic_vector(3 downto 0);
signal pcii_frame	: std_logic;
signal pcii_irdy   : std_logic;
signal pcii_trdy   : std_logic;
signal pcii_devsel : std_logic;
signal pcii_stop   : std_logic;
signal pcii_perr   : std_logic;
signal pcii_par 	: std_logic;
signal pcii_host   : std_logic;
signal pcio_vaden   : std_logic_vector(31 downto 0);
signal pcio_cbeen   : std_logic_vector(3 downto 0);
signal pcio_frameen : std_logic;
signal pcio_irdyen  : std_logic;
signal pcio_trdyen  : std_logic;
signal pcio_devselen:  std_logic;
signal pcio_stopen : std_logic;
signal pcio_perren : std_logic;
signal pcio_paren 	: std_logic;
signal pcio_reqen	: std_logic;
signal pcio_locken : std_logic;
signal pcio_req    : std_logic;
signal pcio_ad 	: std_logic_vector(31 downto 0);
signal pcio_cbe : std_logic_vector(3 downto 0);
signal pcio_frame  : std_logic;
signal pcio_irdy   : std_logic;
signal pcio_trdy   : std_logic;
signal pcio_devsel : std_logic;
signal pcio_stop   : std_logic;
signal pcio_perr   : std_logic;
signal pcio_par    : std_logic;
signal pcii_arb_req: std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);
signal pcio_arb_gnt: std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);

signal ethi_mdio_i : std_logic;		-- ethernet PHY interface
signal etho_mdio_o : std_logic;
signal etho_mdio_oe: std_logic;
signal ethi_tx_clk : std_logic;
signal ethi_rx_clk : std_logic;
signal ethi_rxd    : std_logic_vector(3 downto 0);   
signal ethi_rx_dv  : std_logic; 
signal ethi_rx_er  : std_logic; 
signal ethi_rx_col : std_logic;
signal ethi_rx_crs : std_logic;
signal etho_txd    : std_logic_vector(3 downto 0);   
signal etho_tx_en  : std_logic; 
signal etho_tx_er  : std_logic; 
signal etho_mdc    : std_logic;
signal gnd         : std_logic_vector(3 downto 0);   

signal ltck, ltms, ltdi, ltrst, ltdo : std_logic;
signal lwritefb : std_logic;

begin

  gnd <= (others => '0');
  sdcke <= (others => '1');
  pads0 : entity work.pads
    generic map (padtech)
    port map (
      resetn, clk, errorn, address, data, cb, sdclk, sdcsn, 
      sdwen, sdrasn, sdcasn, sddqm, dsutx, dsurx, 
      dsuen, dsubre, dsuact, txd1, rxd1,
      ramsn, ramoen, rwen, oen, writen, read, iosn,
      romsn, brdyn, bexcn, wdogn, gpio, 
      emdio, etx_clk, erx_clk, erxd, erx_dv, erx_er,
      erx_col, erx_crs, etxd, etx_en, etx_er, emdc,

      pci_rst, pci_clk, pci_gnt, pci_idsel, pci_ad, pci_cbe,
      pci_frame, pci_irdy, pci_trdy, pci_devsel, pci_stop, pci_perr,
      pci_par, pci_req, pci_host, pci_arb_req, pci_arb_gnt,
      can_txd, can_rxd,
--      spw_clk, spw_rxd, spw_rxs, spw_txd, spw_txs, 
      gnd(0), gnd(CFG_SPW_NUM-1 downto 0), gnd(CFG_SPW_NUM-1 downto 0), open, open, 
--      tck, tms, tdi, tdo, trst, test,
      gnd(0), gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
      lresetn, lclk, lerrorn, laddress, datain,
      dataout, dataen, cbin, cbout, cben, lsdclk, lsdcsn, 
      lsdwen, lsdrasn, lsdcasn, lsddqm, ldsutx, ldsurx, 
      ldsuen, ldsubre, ldsuact, ltxd1, lrxd1,
      lramsn, lramoen, lrwen, loen, lwriten, lread, liosn,
      lromsn, lbrdyn, lbexcn, lwdogn, gpioin, gpioout, gpioen, lwritefb,


      ethi_mdio_i, etho_mdio_o, etho_mdio_oe, ethi_tx_clk, ethi_rx_clk, ethi_rxd,
      ethi_rx_dv, ethi_rx_er, ethi_rx_col, ethi_rx_crs, etho_txd, etho_tx_en,
      etho_tx_er, etho_mdc,

      lpciclk, pcii_rst, pcii_gnt, pcii_idsel, pcii_ad, pcii_cbe, pcii_frame,
      pcii_irdy, pcii_trdy, pcii_devsel, pcii_stop, pcii_perr, pcii_par, pcii_host,
      pcio_vaden, pcio_cbeen, pcio_frameen, pcio_irdyen, pcio_trdyen, pcio_devselen,
      pcio_stopen, pcio_perren, pcio_paren, pcio_reqen, pcio_locken, pcio_req,
      pcio_ad, pcio_cbe, pcio_frame, pcio_irdy, pcio_trdy, pcio_devsel, pcio_stop,
      pcio_perr, pcio_par, pcii_arb_req, pcio_arb_gnt, can_ltx, can_lrx,
--      lspw_clk, lspw_rxd, lspw_rxs, lspw_txd, lspw_txs, 
      open, open, open, gnd(CFG_SPW_NUM-1 downto 0), gnd(CFG_SPW_NUM-1 downto 0), 
--      ltck, ltms, ltdi, ltdo, ltest);
      open, open, open, gnd(0), open, open);

  core0 : entity work.core
    generic map (fabtech, memtech, padtech, clktech, disas, dbguart, pclow)
    port map (lresetn, lclk, lerrorn, laddress, datain,
      dataout, dataen, cbin, cbout, cben, lsdclk, lsdcsn, 
      lsdwen, lsdrasn, lsdcasn, lsddqm, ldsutx, ldsurx, 
      ldsuen, ldsubre, ldsuact, ltxd1, lrxd1,
      lramsn, lramoen, lrwen, loen, lwriten, lread, liosn,
      lromsn, lbrdyn, lbexcn, lwdogn, gpioin, gpioout, gpioen, lwritefb,


      ethi_mdio_i, etho_mdio_o, etho_mdio_oe, ethi_tx_clk, ethi_rx_clk, ethi_rxd,
      ethi_rx_dv, ethi_rx_er, ethi_rx_col, ethi_rx_crs, etho_txd, etho_tx_en,
      etho_tx_er, etho_mdc,

      lpciclk, pcii_rst, pcii_gnt, pcii_idsel, pcii_ad, pcii_cbe, pcii_frame,
      pcii_irdy, pcii_trdy, pcii_devsel, pcii_stop, pcii_perr, pcii_par, pcii_host,
      pcio_vaden, pcio_cbeen, pcio_frameen, pcio_irdyen, pcio_trdyen, pcio_devselen,
      pcio_stopen, pcio_perren, pcio_paren, pcio_reqen, pcio_locken, pcio_req,
      pcio_ad, pcio_cbe, pcio_frame, pcio_irdy, pcio_trdy, pcio_devsel, pcio_stop,
      pcio_perr, pcio_par, pcii_arb_req, pcio_arb_gnt, can_ltx, can_lrx,
      spw_clkl, --lspw_clk, 
      lspw_rxd, lspw_rxs, lspw_txd, lspw_txs, lspw_ten,
      ltck, ltms, ltdi, ltdo, ltrst, ltest, pllref);

  spw : if CFG_SPW_EN > 0 generate
   spw_clk_pad : clkpad_ds generic map (padtech, lvds, x25v)
	port map (spw_clkp, spw_clkn, spw_clkl); 
   swloop : for i in 0 to CFG_SPW_NUM-1 generate
     spw_rxd_pad : inpad_ds generic map (padtech, lvds, x25v)
	 port map (spw_rxdp(i), spw_rxdn(i), lspw_rxd(i));
     spw_rxs_pad : inpad_ds generic map (padtech, lvds, x25v)
	 port map (spw_rxsp(i), spw_rxsn(i), lspw_rxs(i));
     spw_txd_pad : outpad_ds generic map (padtech, lvds, x25v)
	 port map (spw_txdp(i), spw_txdn(i), lspw_txd(i), gnd(0));
     spw_txs_pad : outpad_ds generic map (padtech, lvds, x25v)
	 port map (spw_txsp(i), spw_txsn(i), lspw_txs(i), gnd(0));
   end generate;
--   spw_clk_gen: clkmul_virtex2 generic map (4, 2)
--   port map (lresetn, spw_clkl, lspw_clk, open);
  end generate;

end;
