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

entity leon3mp is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;
    scantest  : integer := CFG_SCAN
  );
  port (
    resetn	: in  std_ulogic;
    clksel      : in  std_logic_vector(1 downto 0);
    clka	: in  std_ulogic;
    lock 	: out std_ulogic;
    errorn	: inout std_ulogic;
    wdogn  	: inout std_ulogic;

    address 	: out std_logic_vector(27 downto 0);
    data	: inout std_logic_vector(31 downto 0);
    cb   	: inout std_logic_vector(7 downto 0);

    sdclk  	: out std_ulogic;
    sdcsn  	: out std_logic_vector (1 downto 0);    -- sdram chip select
    sdwen  	: out std_ulogic;                       -- sdram write enable
    sdrasn  	: out std_ulogic;                       -- sdram ras
    sdcasn  	: out std_ulogic;                       -- sdram cas
    sddqm   	: out std_logic_vector (3 downto 0);    -- sdram dqm
    dsutx  	: out std_ulogic; 			-- DSU tx data / scanout
    dsurx  	: in  std_ulogic;  			-- DSU rx data / scanin
    dsuen   	: in std_ulogic;
    dsubre  	: in std_ulogic;			-- DSU break / scanen
    dsuact  	: out std_ulogic;			-- DSU active / NT
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
    gpio        : inout std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    prom32	: in  std_ulogic;
    promedac   	: in  std_ulogic;

    spw_clksel  : in  std_logic_vector(1 downto 0);
    clkb       	: in  std_ulogic;
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
    nandout     : out std_ulogic;

    testen       	: in  std_ulogic
	);
end;

architecture rtl of leon3mp is

signal lresetn	: std_ulogic;
signal lclksel  : std_logic_vector (1 downto 0);
signal lclk	: std_ulogic;
signal lerrorn	: std_ulogic;
signal laddress : std_logic_vector(27 downto 0);
signal datain	: std_logic_vector(31 downto 0);
signal dataout	: std_logic_vector(31 downto 0);
signal dataen 	: std_logic_vector(31 downto 0);
signal cbin   	: std_logic_vector(7 downto 0);
signal cbout   	: std_logic_vector(7 downto 0);
signal cben   	: std_logic_vector(7 downto 0);
signal lsdclk  	: std_ulogic;
--signal sdclk  	: std_ulogic;
signal lsdcsn  	: std_logic_vector (1 downto 0);    -- sdram chip select
signal lsdwen  	: std_ulogic;                       -- sdram write enable
signal lsdrasn  : std_ulogic;                       -- sdram ras
signal lsdcasn  : std_ulogic;                       -- sdram cas
signal lsddqm   : std_logic_vector (3 downto 0);    -- sdram dqm
signal ldsutx  	: std_ulogic; 			-- DSU tx data
signal ldsurx  	: std_ulogic;  			-- DSU rx data
signal ldsuen   : std_ulogic;
signal ldsubre  : std_ulogic;
signal ldsuact  : std_ulogic;
signal ltxd1   	: std_ulogic; 			-- UART1 tx data
signal lrxd1   	: std_ulogic;  			-- UART1 rx data
signal ltxd2   	: std_ulogic; 			-- UART1 tx data
signal lrxd2   	: std_ulogic;  			-- UART1 rx data
signal lramsn  	: std_logic_vector (4 downto 0);
signal lramoen 	: std_logic_vector (4 downto 0);
signal lrwen   	: std_logic_vector (3 downto 0);
signal loen    	: std_ulogic;
signal lwriten 	: std_ulogic;
signal lread   	: std_ulogic;
signal liosn   	: std_ulogic;
signal lromsn  	: std_logic_vector (1 downto 0);
signal lbrdyn  	: std_ulogic;
signal lbexcn  	: std_ulogic;
signal lwdogn  	: std_ulogic;
signal lnandout : std_ulogic;
signal gpioin   : std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
signal gpioout  : std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
signal gpioen   : std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
signal lprom32 : std_ulogic;
signal lpromedac : std_ulogic;

signal lspw_clksel : std_logic_vector (1 downto 0);
signal lspw_clk	: std_ulogic;
signal lspw_rxd  : std_logic_vector(0 to CFG_SPW_NUM-1);
signal lspw_rxs  : std_logic_vector(0 to CFG_SPW_NUM-1);
signal lspw_txd  : std_logic_vector(0 to CFG_SPW_NUM-1);
signal lspw_txs  : std_logic_vector(0 to CFG_SPW_NUM-1);
signal lspw_ten  : std_logic_vector(0 to CFG_SPW_NUM-1);

signal llock, lroen, lroout : std_ulogic;

signal ltest, gnd : std_ulogic;
signal lclk2x, lclk4x, lclkdis, lclklock : std_ulogic;
constant OEPOL 	: integer := padoen_polarity(padtech);
--attribute DONT_TOUCH : boolean;
--attribute DONT_TOUCH of pads0 : label is TRUE;
begin

  pads0 : entity work.pads
    generic map (clktech, padtech)
    port map (
      resetn, clksel, clka, lock, errorn, address, data, cb, sdclk, sdcsn, 
      sdwen, sdrasn, sdcasn, sddqm, dsutx, dsurx, 
      dsuen, dsubre, dsuact, txd1, rxd1, txd2, rxd2,
      ramsn, ramoen, rwen, oen, writen, read, iosn,
      romsn, brdyn, bexcn, wdogn, gpio, prom32, promedac,
      spw_clksel, clkb, spw_rxdp, spw_rxdn, spw_rxsp, spw_rxsn, spw_txdp, spw_txdn, 
      spw_txsp, spw_txsn, lvdsref, roen, roout, nandout, testen,
      lresetn, lclksel, lclk, lerrorn, laddress, datain,
      dataout, dataen, cbin, cbout, cben, lsdclk, lsdcsn, 
      lsdwen, lsdrasn, lsdcasn, lsddqm, ldsutx, ldsurx, 
      ldsuen, ldsubre, ldsuact, ltxd1, lrxd1, ltxd2, lrxd2,
      lramsn, lramoen, lrwen, loen, lwriten, lread, liosn,
      lromsn, lbrdyn, lbexcn, lwdogn, gpioin, gpioout, gpioen, lprom32, lpromedac,
      lspw_clksel, lspw_clk, lspw_rxd, lspw_rxs, lspw_txd, lspw_txs, lspw_ten,
      lclk2x, lclk4x, lclkdis, lclklock, llock, lroen, lroout, lnandout, ltest, gnd);

  core0 : entity work.core
    generic map (fabtech, memtech, padtech, clktech, disas, dbguart, pclow, scantest)
    port map (lresetn, lclksel, lclk, lerrorn, laddress, datain,
      dataout, dataen, cbin, cbout, cben, lsdclk, lsdcsn, 
      lsdwen, lsdrasn, lsdcasn, lsddqm, ldsutx, ldsurx, 
      ldsuen, ldsubre, ldsuact, ltxd1, lrxd1, ltxd2, lrxd2,
      lramsn, lramoen, lrwen, loen, lwriten, lread, liosn,
      lromsn, lbrdyn, lbexcn, lwdogn, gpioin, gpioout, gpioen, lprom32, lpromedac,
      lspw_clksel, lspw_clk, lspw_rxd, lspw_rxs, lspw_txd, lspw_txs, lspw_ten,
      lclk2x, lclk4x, lclkdis, lclklock, llock, lroen, lroout, lnandout, ltest, gnd);

end;
