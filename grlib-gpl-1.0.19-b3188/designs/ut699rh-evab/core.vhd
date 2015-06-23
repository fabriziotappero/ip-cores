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
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.pci.all;
use gaisler.net.all;
use gaisler.jtag.all;
use gaisler.spacewire.all;
library esa;
use esa.memoryctrl.all;
use esa.pcicomp.all;
use work.config.all;
use work.config.all;

entity core is
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
    resetn	: in  std_ulogic;
    clk		: in  std_ulogic;
    errorn	: out std_ulogic;
    address 	: out std_logic_vector(27 downto 0);
    datain	: in std_logic_vector(31 downto 0);
    dataout	: out std_logic_vector(31 downto 0);
    dataen 	: out std_logic_vector(31 downto 0);
    cbin   	: in std_logic_vector(7 downto 0);
    cbout   	: out std_logic_vector(7 downto 0);
    cben   	: out std_logic_vector(7 downto 0);
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
    writen 	: out std_ulogic;
    read   	: out std_ulogic;
    iosn   	: out std_ulogic;
    romsn  	: out std_logic_vector (1 downto 0);
    brdyn  	: in  std_ulogic;
    bexcn  	: in  std_ulogic;
    wdogn  	: out std_ulogic;
    gpioin      : in std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    gpioout     : out std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    gpioen      : out std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    writefb	: in  std_ulogic;

    emdi     	: in    std_logic;		-- ethernet PHY interface
    emdo     	: out std_logic;		-- ethernet PHY interface
    emden     	: out std_logic;		-- ethernet PHY interface
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

    pciclk 	: in std_ulogic;
    pcii_rst 	: in std_ulogic;
    pcii_gnt 	: in std_ulogic;
    pcii_idsel 	: in std_ulogic;
    pcii_ad 	: in std_logic_vector(31 downto 0);
    pcii_cbe 	: in std_logic_vector(3 downto 0);
    pcii_frame	: in std_ulogic;
    pcii_irdy   : in std_ulogic;
    pcii_trdy   : in std_ulogic;
    pcii_devsel : in std_ulogic;
    pcii_stop   : in std_ulogic;
    pcii_perr   : in std_ulogic;
    pcii_par 	: in std_ulogic;
    pcii_host   : in std_ulogic;

    pcio_vaden   : out std_logic_vector(31 downto 0);
    pcio_cbeen   : out std_logic_vector(3 downto 0);
    pcio_frameen : out std_ulogic;
    pcio_irdyen  : out std_ulogic;
    pcio_trdyen  : out std_ulogic;
    pcio_devselen:  out std_ulogic;
    pcio_stopen : out std_ulogic;
    pcio_perren : out std_ulogic;
    pcio_paren 	: out std_ulogic;
    pcio_reqen	: out std_ulogic;
    pcio_locken : out std_ulogic;
    pcio_req    : out std_ulogic;
    pcio_ad 	: out std_logic_vector(31 downto 0);
    pcio_cbe 	: out std_logic_vector(3 downto 0);
    pcio_frame  : out std_ulogic;
    pcio_irdy   : out std_ulogic;
    pcio_trdy   : out std_ulogic;
    pcio_devsel : out std_ulogic;
    pcio_stop   : out std_ulogic;
    pcio_perr   : out std_ulogic;
    pcio_par    : out std_ulogic;

    pcii_arb_req: in  std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);
    pcio_arb_gnt: out std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);

    can_tx      : out std_logic_vector(0 to CFG_CAN_NUM-1);
    can_rx      : in  std_logic_vector(0 to CFG_CAN_NUM-1);

    spw_clk	: in  std_ulogic;
    spw_rxd     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxs     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txd     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txs     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_ten     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    tck         : in std_ulogic;
    tms         : in std_ulogic;
    tdi         : in std_ulogic;
    tdo         : out std_ulogic;
    trst        : in std_ulogic;

    test 	: in  std_ulogic;
    pllref	: in  std_ulogic
	);
end;

architecture rtl of core is

  constant ISASIC : boolean := (is_fpga(fabtech) = 0);
  signal lclk, lspw_clk, lpciclk : std_ulogic;
  signal letx_clk, lerx_clk, ltck : std_ulogic;
  signal lletx_clk, llerx_clk, llspw_clk, llpciclk : std_ulogic;
  signal gclk, pwd, lpwd : std_logic_vector(0 to 0);
  signal scanin, scanout, scanen, ldsutx, testrst : std_ulogic;

  signal ldataen       : std_logic_vector(31 downto 0);
  signal lcben         : std_logic_vector(7 downto 0);
  signal lemden        : std_ulogic;
  signal lpcio_vaden   : std_logic_vector(31 downto 0);
  signal lpcio_cbeen   : std_logic_vector(3 downto 0);
  signal lpcio_frameen : std_ulogic;
  signal lpcio_irdyen  : std_ulogic;
  signal lpcio_trdyen  : std_ulogic;
  signal lpcio_devselen: std_ulogic;
  signal lpcio_stopen  : std_ulogic;
  signal lpcio_perren  : std_ulogic;
  signal lpcio_paren   : std_ulogic;
  signal lpcio_reqen   : std_ulogic;
  signal lpcio_locken  : std_ulogic;

begin

  ltck <= clk when (test = '1') and ISASIC else tck;
  lspw_clk <= clk when (test = '1') and ISASIC else spw_clk;
  sclk : techbuf generic map (tech => fabtech) port map (lspw_clk, llspw_clk);
  lpciclk <= clk when (test = '1') and ISASIC else pciclk;
  pclk : techbuf generic map (tech => fabtech) port map (lpciclk, llpciclk);
  letx_clk <= clk when (test = '1') and ISASIC else etx_clk;
  etclk : techbuf generic map (tech => fabtech) port map (letx_clk, lletx_clk);
  lerx_clk <= clk when (test = '1') and ISASIC else erx_clk;
  erclk : techbuf generic map (tech => fabtech) port map (lerx_clk, llerx_clk);
  dataen <= (others => rxd1) when (test = '1') and ISASIC else ldataen;
  cben <= (others => rxd1) when (test = '1') and ISASIC else lcben;
  emden <= rxd1 when (test = '1') and ISASIC else lemden;
  pcio_vaden <= (others => rxd1) when (test = '1') and ISASIC else lpcio_vaden;
  pcio_cbeen <= (others => rxd1) when (test = '1') and ISASIC else lpcio_cbeen;
  pcio_frameen <= rxd1 when (test = '1') and ISASIC else lpcio_frameen;
  pcio_irdyen <= rxd1 when (test = '1') and ISASIC else lpcio_irdyen;
  pcio_trdyen <= rxd1 when (test = '1') and ISASIC else lpcio_trdyen;
  pcio_devselen <= rxd1 when (test = '1') and ISASIC else lpcio_devselen;
  pcio_stopen <= rxd1 when (test = '1') and ISASIC else lpcio_stopen;
  pcio_perren <= rxd1 when (test = '1') and ISASIC else lpcio_perren;
  pcio_paren <= rxd1 when (test = '1') and ISASIC else lpcio_paren;
  pcio_reqen <= rxd1 when (test = '1') and ISASIC else lpcio_reqen;
  pcio_locken <= rxd1 when (test = '1') and ISASIC else lpcio_locken;

  dsutx  <= scanout when test = '1' else ldsutx;
  scanin <= dsurx when test = '1' else '0';
  scanen <= dsubre when test = '1' else '0';
  testrst <= dsuen when test = '1' else '0';

  leon3core0 : entity work.leon3core
    generic map ( fabtech, memtech, padtech, clktech, disas, dbguart, 
		pclow, 1 - is_fpga(fabtech) )
  port map (
    resetn, clk, errorn, 
    address, datain, dataout, ldataen, cbin, cbout, lcben, 
    sdcsn, sdwen, sdrasn, sdcasn, sddqm,
    ldsutx, dsurx, dsuen, dsubre, dsuact,
    txd1, rxd1,
    ramsn, ramoen, rwen, oen, writen, read, iosn, romsn, brdyn, bexcn,
    wdogn, gpioin, gpioout, gpioen, writefb,
    emdi, emdo, lemden, lletx_clk, llerx_clk, erxd, erx_dv, erx_er,
    erx_col, erx_crs, etxd, etx_en, etx_er, emdc, 
    llpciclk, pcii_rst, pcii_gnt, pcii_idsel, pcii_ad, pcii_cbe, pcii_frame,
    pcii_irdy, pcii_trdy, pcii_devsel, pcii_stop, pcii_perr, pcii_par, pcii_host,
    lpcio_vaden, lpcio_cbeen, lpcio_frameen, lpcio_irdyen, lpcio_trdyen,
    lpcio_devselen, lpcio_stopen, lpcio_perren, lpcio_paren, lpcio_reqen,
    lpcio_locken, pcio_req, pcio_ad, pcio_cbe, pcio_frame, pcio_irdy,
    pcio_trdy, pcio_devsel, pcio_stop, pcio_perr, pcio_par,
    pcii_arb_req, pcio_arb_gnt, can_tx, can_rx,
    llspw_clk, spw_rxd, spw_rxs, spw_txd, spw_txs, spw_ten,
    ltck, tms, tdi, tdo, trst, 
    scanin, scanen, test, testrst, scanout, sdclk, pllref);
end;
