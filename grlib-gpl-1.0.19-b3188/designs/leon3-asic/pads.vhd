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
    clktech   : integer := CFG_CLKTECH;
    padtech   : integer := CFG_PADTECH
  );
  port (
    resetn	: in  std_ulogic;
    clksel 	: in  std_logic_vector (1 downto 0);
    clk		: in  std_ulogic;
    lock    	: out std_ulogic;
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
    txd2   	: out std_ulogic; 			-- UART2 tx data
    rxd2   	: in  std_ulogic;  			-- UART2 rx data
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
    wdogn  	: inout std_ulogic;
    gpio        : inout std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    prom32	: in std_ulogic;
    promedac	: in std_ulogic;

    spw_clksel 	: in  std_logic_vector (1 downto 0);
    spw_clk    	: in  std_ulogic;
    spw_rxdp    : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxdn    : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxsp    : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxsn    : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txdp    : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txdn    : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txsp    : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txsn    : out std_logic_vector(0 to CFG_SPW_NUM-1);
    lvdsref    	: in  std_ulogic;

    roen        : in  std_ulogic;
    roout       : out std_ulogic;
    nandout	: out std_ulogic;
    test       	: in  std_ulogic;

    lresetn	: out std_ulogic;
    lclksel 	: out std_logic_vector (1 downto 0);
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
    ltxd2   	: in std_ulogic; 			-- UART2 tx data
    lrxd2   	: out std_ulogic;  			-- UART2 rx data
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
    lprom32	: out std_ulogic;
    lpromedac	: out std_ulogic;

    lspw_clksel	: out std_logic_vector (1 downto 0);
    lspw_clk    : out std_ulogic;
    spw_rxd     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxs     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txd     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txs     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_ten     : in  std_logic_vector(0 to CFG_SPW_NUM-1);

    lclk2x      : out std_ulogic;
    lclk4x      : out std_ulogic;
    lclkdis     : in  std_ulogic;
    lclklock    : out std_ulogic;
    llock    	: in std_ulogic;

    lroen       : out std_ulogic;
    lroout      : in  std_ulogic;
    lnandout	: in  std_ulogic;
    ltest       : out std_ulogic;
    gnd       	: in  std_ulogic

	);
end;

architecture rtl of pads is

signal ltestenablex : std_ulogic;
signal clkin, spw_clkin : std_ulogic;
signal oref, iref, refp, refn : std_ulogic;
constant OEPOL : integer := padoen_polarity(padtech);
constant INSCLKPADS : integer := 1;
constant SCANTEST : integer := 1;
constant clkpadtech : integer := padtech * INSCLKPADS;

signal cgi   : clkgen_in_type;
signal cgo   : clkgen_out_type;

signal clk1xu, pllfb  : std_logic;

begin

  ltest <= '0' when (is_fpga(padtech) = 1) or (SCANTEST = 0) else ltestenablex;
  testen_pad : inpad generic map (tech => padtech, filter => pulldown) port map (test, ltestenablex); 
  roen_pad : inpad generic map (tech => padtech, filter => pullup) port map (roen, lroen); 
  roout_pad : outpad generic map (tech => padtech, strength => 4) 
    port map (roout, lroout);
  nandout_pad : outpad generic map (tech => padtech, strength => 4) 
    port map (nandout, lnandout);
  clk_pad : inpad generic map (tech => clkpadtech, filter => schmitt) port map (clk, clkin); 
  spw_clk_pad : inpad generic map (tech => clkpadtech, filter => schmitt) port map (spw_clk, lspw_clk); 
  resetn_pad : inpad generic map (tech => padtech, filter => schmitt) 
    port map (resetn, lresetn); 

  clksel_pad : inpadv generic map (tech => padtech, width => 2) port map (clksel, lclksel); 
  spw_clksel_pad : inpadv generic map (tech => padtech, width => 2) port map (spw_clksel, lspw_clksel); 
  errorn_pad : toutpad generic map (tech => padtech, strength => 4, oepol => OEPOL) 
    port map (errorn, gnd, lerrorn);

  dsuen_pad  : inpad  generic map (tech => padtech) port map (dsuen, ldsuen); 
  dsubre_pad : inpad  generic map (tech => padtech) port map (dsubre, ldsubre); 
  dsuact_pad : outpad generic map (tech => padtech, strength => 4) port map (dsuact, ldsuact);
  dsurx_pad  : inpad  generic map (tech => padtech) port map (dsurx, ldsurx); 
  dsutx_pad  : outpad generic map (tech => padtech, strength => 4) port map (dsutx, ldsutx);
  
  addrh_pad : outpadv generic map (width => 7, tech => padtech, strength => 4) 
	port map (address(27 downto 21), laddress(27 downto 21)); 
  addr_pad : outpadv generic map (width => 19, tech => padtech, strength => 12) 
	port map (address(20 downto 2), laddress(20 downto 2)); 
  addrl_pad : outpadv generic map (width => 2, tech => padtech, strength => 4) 
	port map (address(1 downto 0), laddress(1 downto 0)); 
  rams_pad : outpadv generic map (width => 5, tech => padtech, strength => 4) 
	port map (ramsn, lramsn); 
  roms_pad : outpadv generic map (width => 2, tech => padtech, strength => 4) 
	port map (romsn, lromsn); 
  oen_pad  : outpad generic map (tech => padtech, strength => 4)
	port map (oen, loen);
  rwen_pad : outpadv generic map (width => 4, tech => padtech, strength => 4) 
	port map (rwen, lrwen); 
  ramoen_pad : outpadv generic map (width => 5, tech => padtech, strength => 4) 
	port map (ramoen, lramoen);
  wri_pad  : outpad generic map (tech => padtech, strength => 4) 
	port map (writen, lwriten);
  read_pad : outpad generic map (tech => padtech, strength => 4) 
	port map (read, lread); 
  iosn_pad : outpad generic map (tech => padtech, strength => 4) 
	port map (iosn, liosn);
  bdr : for i in 0 to 31 generate
      data_pad : iopad generic map (tech => padtech, strength => 4, oepol => OEPOL)
      port map (data(i), dataout(i), dataen(i), datain(i));
  end generate;
  sdpads : if CFG_MCTRL_SDEN = 1 generate
    sdclk_pad : outpad generic map (tech => padtech, strength => 12) 
	port map (sdclk, lsdclk);
    sdwen_pad : outpad generic map (tech => padtech, strength => 4) 
	   port map (sdwen, lsdwen);
    sdras_pad : outpad generic map (tech => padtech, strength => 4) 
	   port map (sdrasn, lsdrasn);
    sdcas_pad : outpad generic map (tech => padtech, strength => 4) 
	   port map (sdcasn, lsdcasn);
    sddqm_pad : outpadv generic map (width => 4, tech => padtech, strength => 4) 
	   port map (sddqm, lsddqm);
    sdcsn_pad : outpadv generic map (width =>2, tech => padtech, strength => 4) 
	   port map (sdcsn, lsdcsn); 
  end generate;

  cdr : for i in 0 to 7 generate
      cb_pad : iopad generic map (tech => padtech, strength => 4, oepol => OEPOL)
      port map (cb(i), cbout(i), cben(i), cbin(i));
  end generate;

  brdyn_pad : inpad generic map (tech => padtech, filter => pullup) port map (brdyn, lbrdyn); 
  bexcn_pad : inpad generic map (tech => padtech, filter => pullup) port map (bexcn, lbexcn); 

  txd1_pad : outpad generic map (tech => padtech, strength => 4) port map (txd1, ltxd1);
  rxd1_pad : inpad generic map (tech => padtech) port map (rxd1, lrxd1); 
  txd2_pad : outpad generic map (tech => padtech, strength => 4) port map (txd2, ltxd2);
  rxd2_pad : inpad generic map (tech => padtech) port map (rxd2, lrxd2); 

  wdogn_pad : toutpad generic map (tech => padtech, strength => 4, oepol => OEPOL) 
	port map (wdogn, gnd, lwdogn);

  pio_pads : for i in 0 to CFG_GRGPIO_WIDTH-1 generate
    pio_pad : iopad generic map (tech => padtech, strength => 4,  oepol => OEPOL)
      port map (gpio(i), gpioout(i), gpioen(i), gpioin(i));
  end generate;

  prom32_pad : inpad generic map (tech => padtech) port map (prom32, lprom32); 
  promedac_pad : inpad generic map (tech => padtech) port map (promedac, lpromedac); 
  lock_pad : outpad generic map (tech => padtech, strength => 4) port map (lock, llock);

  spw : if CFG_SPW_EN > 0 generate
   lvds_pads : lvds_combo generic map (tech => padtech, width => CFG_SPW_NUM)
   port map (
	spw_txdp, spw_txdn, spw_txsp, spw_txsn, spw_txd, spw_txs, spw_ten,
	spw_rxdp, spw_rxdn, spw_rxsp, spw_rxsn, spw_rxd, spw_rxs, lvdsref);
  end generate;

  cgi.pllctrl <= '0' & lclkdis; lclklock <= cgo.clklock;
  cgi.pllref <= clk1xu;
  lclk <= clkin;
  clkgen0 : clkgen  		-- clock generator
      generic map (clktech) --, CFG_CLKMUL, CFG_CLKDIV, CFG_SDEN, CFG_INVCLK, 0, CFG_PCIDLL, CFG_PCISYSCLK, BOARD_FREQ)
      port map (clkin, clkin, open, open, lclk2x, open, open, cgi, cgo,
	lclk4x, clk1xu);

end;
