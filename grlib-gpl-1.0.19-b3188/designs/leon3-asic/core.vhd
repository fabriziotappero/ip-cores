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
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.misc.all;
use work.config.all;

entity core is
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
    clksel 	: in  std_logic_vector (1 downto 0);
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
    wdogn  	: out std_ulogic;
    gpioin      : in std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    gpioout     : out std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    gpioen      : out std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port
    prom32	: in  std_ulogic;
    promedac	: in  std_ulogic;

    spw_clksel 	: in  std_logic_vector (1 downto 0);
    spw_clk	: in  std_ulogic;
    spw_rxd     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_rxs     : in  std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txd     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_txs     : out std_logic_vector(0 to CFG_SPW_NUM-1);
    spw_ten     : out std_logic_vector(0 to CFG_SPW_NUM-1);

    lclk2x      : in  std_ulogic;
    lclk4x      : in  std_ulogic;
    lclkdis     : out std_ulogic;
    lclklock    : in  std_ulogic;
    lock        : out std_ulogic;

    roen        : in  std_ulogic;
    roout       : out std_ulogic;
    nandout     : out std_ulogic;

    testen 	: in  std_ulogic;
    gnd         : out std_ulogic

	);
end;

architecture rtl of core is

  constant OEPOL : integer := padoen_polarity(padtech);

  signal lclk, lspw_clk, clklock : std_ulogic;
  signal llspw_clk, llclk : std_ulogic;
  signal scanen, testrst, testoen : std_ulogic;
  signal lgpioen : std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);

begin

  gnd <= '0';

  lclk <= clk     when clksel = "00" else
          spw_clk when clksel = "01" else
          lclk2x  when clksel = "10" else lclk4x;

  llclk <= clk when (testen = '1') else lclk;
	
  sdclk <= llclk;

  lspw_clk <= clk when spw_clksel = "00" else
          spw_clk when spw_clksel = "01" else
          lclk2x  when spw_clksel = "10" else lclk4x;

  llspw_clk <= clk when (testen = '1') else lspw_clk;

  lclkdis <= '1' when (testen = '1') or ((clksel(1) or spw_clksel(1)) = '0')
    else '0';

  clklock <= '1' when (testen = '1') or ((clksel(1) or spw_clksel(1)) = '0')
    else lclklock;

  lock <= lclklock;

  ringosc0 : ringosc generic map (fabtech) port map (roen, roout);

  scanen <= dsubre when (testen = '1') else '0';
  testrst <= dsuen when (testen = '1') else '1'; 
  testoen <= dsurx;

  gpioen <= lgpioen when (testen = '0') else (others => '0') when oepol = 1 
	else (others => '1');

  nandout <= nandtree(testen & brdyn & bexcn & roen & promedac & prom32 &
	spw_clksel & clksel & spw_rxs & spw_rxd & resetn & rxd2 & rxd1 &
	dsuen & dsubre & dsurx & datain & cbin & gpioin);

  leon3core0 : entity work.leon3core
    generic map ( fabtech, memtech, padtech, clktech, disas, dbguart, 
		pclow, scantest*(1 - is_fpga(fabtech)))
  port map (
    resetn, clksel, llclk, clklock, errorn, 
    address, datain, dataout, dataen, cbin, cbout, cben, 
    sdcsn, sdwen, sdrasn, sdcasn, sddqm,
    dsutx, dsurx, dsuen, dsubre, dsuact,
    txd1, rxd1, txd2, rxd2,
    ramsn, ramoen, rwen, oen, writen, read, iosn, romsn, brdyn, bexcn,
    wdogn, gpioin, gpioout, lgpioen, prom32, promedac, spw_clksel,
    llspw_clk, spw_rxd, spw_rxs, spw_txd, spw_txs, spw_ten,
    scanen, testen, testrst, testoen);

end;
