------------------------------------------------------------------------------
--  LEON3 Demonstration design test bench
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
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library gaisler;
use gaisler.libdcom.all;
use gaisler.sim.all;
use gaisler.jtagtst.all;
library techmap;
use techmap.gencomp.all;
library micron;
use micron.components.all;
use work.debug.all;

use work.config.all;	-- configuration

entity testbench is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    ncpu      : integer := CFG_NCPU;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;

    clkperiod : integer := 20;		-- system clock period
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 16;		-- rom address depth
    sramwidth  : integer := 32;		-- ram data width (8/16/32)
    sramdepth  : integer := 18;		-- ram address depth
    srambanks  : integer := 2		-- number of ram banks
  );
  port (
    pci_rst     : inout std_logic;	-- PCI bus
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
    pci_host   	: in std_ulogic;
    pci_66	: in std_ulogic
  );
end;

architecture behav of testbench is

constant promfile  : string := "prom.srec";  -- rom contents
constant sramfile  : string := "sram.srec";  -- ram contents
constant sdramfile : string := "sdram.srec"; -- sdram contents

component leon3mp
  generic (
    fabtech  : integer := CFG_FABTECH;
    memtech  : integer := CFG_MEMTECH;
    padtech  : integer := CFG_PADTECH;
    clktech  : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW
  );
  port (
    resetn	: in  std_ulogic;
    clk		: in  std_ulogic;
    pllref 	: in  std_ulogic;
    errorn	: out std_ulogic;
    address 	: out std_logic_vector(27 downto 0);
    data	: inout std_logic_vector(31 downto 0);
    sa      	: out std_logic_vector(14 downto 0);
    sd   	: inout std_logic_vector(63 downto 0);
    sdclk  	: out std_ulogic;
    sdcke  	: out std_logic_vector (1 downto 0);    -- sdram clock enable
    sdcsn  	: out std_logic_vector (1 downto 0);    -- sdram chip select
    sdwen  	: out std_ulogic;                       -- sdram write enable
    sdrasn  	: out std_ulogic;                       -- sdram ras
    sdcasn  	: out std_ulogic;                       -- sdram cas
    sddqm   	: out std_logic_vector (7 downto 0);    -- sdram dqm
    dsutx  	: out std_ulogic; 			-- DSU tx data
    dsurx  	: in  std_ulogic;  			-- DSU rx data
    dsuen   	: in std_ulogic;
    dsubre  	: in std_ulogic;
    dsuact  	: out std_ulogic;
    txd1   	: out std_ulogic; 			-- UART1 tx data
    rxd1   	: in  std_ulogic;  			-- UART1 rx data
    txd2   	: out std_ulogic; 			-- UART1 tx data
    rxd2   	: in  std_ulogic;  			-- UART1 rx data
    ramsn  	: out std_logic_vector (4 downto 0);
    ramoen 	: out std_logic_vector (4 downto 0);
    rwen   	: out std_logic_vector (3 downto 0);
    oen    	: out std_ulogic;
    writen 	: out std_ulogic;
    read   	: out std_ulogic;
    iosn   	: out std_ulogic;
    romsn  	: out std_logic_vector (1 downto 0);
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

    emddis 	: out std_logic;
    epwrdwn 	: out std_logic;
    ereset 	: out std_logic;
    esleep 	: out std_logic;
    epause 	: out std_logic;

    pci_rst     : inout std_logic;		-- PCI bus
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
    pci_host   	: in std_ulogic;
    pci_66	: in std_ulogic;
    pci_arb_req	: in  std_logic_vector(0 to 3);
    pci_arb_gnt	: out std_logic_vector(0 to 3);

    can_txd	: out std_ulogic;
    can_rxd	: in  std_ulogic;
    can_stb	: out std_ulogic;

    spw_clk	: in  std_ulogic;
    spw_rxd     : in  std_logic_vector(0 to 2);
    spw_rxdn    : in  std_logic_vector(0 to 2);
    spw_rxs     : in  std_logic_vector(0 to 2);
    spw_rxsn    : in  std_logic_vector(0 to 2);
    spw_txd     : out std_logic_vector(0 to 2);
    spw_txdn    : out std_logic_vector(0 to 2);
    spw_txs     : out std_logic_vector(0 to 2);
    spw_txsn    : out std_logic_vector(0 to 2);
    tck, tms, tdi : in std_ulogic;
    tdo         : out std_ulogic

	);
end component;

signal clk : std_logic := '0';
signal Rst    : std_logic := '0';			-- Reset
constant ct : integer := clkperiod/2;

signal address  : std_logic_vector(27 downto 0);
signal data     : std_logic_vector(31 downto 0);

signal ramsn    : std_logic_vector(4 downto 0);
signal ramoen   : std_logic_vector(4 downto 0);
signal rwen     : std_logic_vector(3 downto 0);
signal rwenx    : std_logic_vector(3 downto 0);
signal romsn    : std_logic_vector(1 downto 0);
signal iosn     : std_ulogic;
signal oen      : std_ulogic;
signal read     : std_ulogic;
signal writen   : std_ulogic;
signal brdyn    : std_ulogic;
signal bexcn    : std_ulogic;
signal wdog     : std_ulogic;
signal dsuen, dsutx, dsurx, dsubre, dsuact : std_ulogic;
signal dsurst   : std_ulogic;
signal test     : std_ulogic;
signal error    : std_logic;
signal gpio	: std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);
signal GND      : std_ulogic := '0';
signal VCC      : std_ulogic := '1';
signal NC       : std_ulogic := 'Z';
signal clk2     : std_ulogic := '1';

signal sdcke    : std_logic_vector ( 1 downto 0);  -- clk en
signal sdcsn    : std_logic_vector ( 1 downto 0);  -- chip sel
signal sdwen    : std_ulogic;                       -- write en
signal sdrasn   : std_ulogic;                       -- row addr stb
signal sdcasn   : std_ulogic;                       -- col addr stb
signal sddqm    : std_logic_vector ( 7 downto 0);  -- data i/o mask
signal sdclk    : std_ulogic;
signal plllock    : std_ulogic;
signal txd1, rxd1 : std_ulogic;
signal txd2, rxd2 : std_ulogic;

signal etx_clk, erx_clk, erx_dv, erx_er, erx_col, erx_crs, etx_en, etx_er : std_logic:='0';
signal erxd, etxd: std_logic_vector(3 downto 0):=(others=>'0');
signal erxdt, etxdt: std_logic_vector(7 downto 0):=(others=>'0');
signal emdc, emdio: std_logic;
signal gtx_clk : std_ulogic;

signal emddis 	: std_logic;
signal epwrdwn 	: std_logic;
signal ereset 	: std_logic;
signal esleep 	: std_logic;
signal epause 	: std_logic;

constant lresp : boolean := false;

signal sa      	: std_logic_vector(14 downto 0);
signal sd   	: std_logic_vector(63 downto 0);

signal pci_arb_req, pci_arb_gnt : std_logic_vector(0 to 3);

signal can_txd	: std_ulogic;
signal can_rxd	: std_ulogic;
signal can_stb	: std_ulogic;

signal spw_clk	: std_ulogic := '0';
signal spw_rxd  : std_logic_vector(0 to 2) := "000";
signal spw_rxdn : std_logic_vector(0 to 2) := "000";
signal spw_rxs  : std_logic_vector(0 to 2) := "000";
signal spw_rxsn : std_logic_vector(0 to 2) := "000";
signal spw_txd  : std_logic_vector(0 to 2);
signal spw_txdn : std_logic_vector(0 to 2);
signal spw_txs  : std_logic_vector(0 to 2);
signal spw_txsn : std_logic_vector(0 to 2);

signal tck, tms, tdi, tdo : std_ulogic;

constant CFG_SDEN : integer := CFG_SDCTRL + CFG_MCTRL_SDEN ;
constant CFG_SD64 : integer := CFG_SDCTRL_SD64 + CFG_MCTRL_SD64;

begin

-- clock and reset

  spw_clk <= not spw_clk after 20 ns;
  spw_rxd(0) <= spw_txd(0); spw_rxdn(0) <= spw_txdn(0);
  spw_rxs(0) <= spw_txs(0); spw_rxsn(0) <= spw_txsn(0);
  spw_rxd(1) <= spw_txd(1); spw_rxdn(1) <= spw_txdn(1);
  spw_rxs(1) <= spw_txs(1); spw_rxsn(1) <= spw_txsn(1);
  spw_rxd(2) <= spw_txd(0); spw_rxdn(2) <= spw_txdn(2);
  spw_rxs(2) <= spw_txs(0); spw_rxsn(2) <= spw_txsn(2);
  clk <= not clk after ct * 1 ns;
  rst <= dsurst;
  dsuen <= '1'; dsubre <= '0'; rxd1 <= '1';
  --## can_rxd <= '1';
  can_rxd <= can_txd; -- CAN LOOP BACK ##

  d3 : leon3mp
        generic map ( fabtech, memtech, padtech, clktech,
	disas, dbguart, pclow )
        port map (rst, clk, sdclk,  error, address(27 downto 0), data,
	sa, sd, sdclk, sdcke, sdcsn, sdwen, sdrasn, sdcasn, sddqm,
	dsutx, dsurx, dsuen, dsubre, dsuact, txd1, rxd1, txd2, rxd2,
	ramsn, ramoen, rwen, oen, writen, read, iosn, romsn, gpio,
        emdio, etx_clk, erx_clk, erxd, erx_dv, erx_er, erx_col, erx_crs,
        etxd, etx_en, etx_er, emdc, emddis, epwrdwn, ereset, esleep, epause,
    	pci_rst, pci_clk, pci_gnt, pci_idsel, pci_lock, pci_ad, pci_cbe,
    	pci_frame, pci_irdy, pci_trdy, pci_devsel, pci_stop, pci_perr, pci_par,
    	pci_req, pci_serr, pci_host, pci_66, pci_arb_req, pci_arb_gnt,
	can_txd, can_rxd, can_stb, spw_clk, spw_rxd, spw_rxdn, spw_rxs,
	spw_rxsn, spw_txd, spw_txdn, spw_txs, spw_txsn, tck, tms, tdi, tdo);

-- optional sdram

  sd0 : if (CFG_SDEN /= 0) and (CFG_MCTRL_SEPBUS = 0) generate
    u0: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => data(31 downto 16), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u1: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => data(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    u2: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => data(31 downto 16), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u3: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => data(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
  end generate;

  sd1 : if (CFG_SDEN /= 0) and (CFG_MCTRL_SEPBUS = 1) generate
    u0: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sd(31 downto 16), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u1: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sd(15 downto 0), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    u2: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sd(31 downto 16), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u3: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sd(15 downto 0), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    sd64 : if (CFG_SD64 /= 0) generate
      u4: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sd(63 downto 48), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(7 downto 6));
      u5: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sd(47 downto 32), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(5 downto 4));
      u6: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sd(63 downto 48), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(7 downto 6));
      u7: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sd(47 downto 32), Addr => sa(12 downto 0),
            Ba => sa(14 downto 13), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(5 downto 4));
    end generate;
  end generate;

    prom0 : for i in 0 to (romwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => romdepth, fname => promfile)
	port map (address(romdepth+1 downto 2), data(31-i*8 downto 24-i*8), romsn(0),
		  rwen(i), oen);
    end generate;

  sbanks : for k in 0 to srambanks-1 generate
    sram0 : for i in 0 to (sramwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), data(31-i*8 downto 24-i*8),
		ramsn(k), rwen(i), ramoen(k));
    end generate;
  end generate;

  phy0 : if (CFG_GRETH = 1) generate
    emdio <= 'H';
    erxd <= erxdt(3 downto 0);
    etxdt <= "0000" & etxd;
    
    p0: phy
      generic map(base1000_t_fd => 0, base1000_t_hd => 0)
      port map(rst, emdio, etx_clk, erx_clk, erxdt, erx_dv,
      erx_er, erx_col, erx_crs, etxdt, etx_en, etx_er, emdc, gtx_clk);
  end generate;
  error <= 'H';			  -- ERROR pull-up

   iuerr : process
   begin
     wait for 2500 ns;
     if to_x01(error) = '1' then wait on error; end if;
     assert (to_x01(error) = '1')
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  data <= buskeep(data), (others => 'H') after 250 ns;
  sd <= buskeep(sd), (others => 'H') after 250 ns;

  test0 :  grtestmod
    port map ( rst, clk, error, address(21 downto 2), data,
    	       iosn, oen, writen, brdyn);


  dsucom : process
    procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
    constant txp : time := 160 * 1 ns;
    begin
    dsutx <= '1';
    dsurst <= '0';
    wait for 500 ns;
    dsurst <= '1';
    wait;
    wait for 5000 ns;
    txc(dsutx, 16#55#, txp);		-- sync uart

--    txc(dsutx, 16#c0#, txp);
--    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
--    txa(dsutx, 16#00#, 16#00#, 16#02#, 16#ae#, txp);
--    txc(dsutx, 16#c0#, txp);
--    txa(dsutx, 16#91#, 16#00#, 16#00#, 16#00#, txp);
--    txa(dsutx, 16#00#, 16#00#, 16#06#, 16#ae#, txp);
--    txc(dsutx, 16#c0#, txp);
--    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#24#, txp);
--    txa(dsutx, 16#00#, 16#00#, 16#06#, 16#03#, txp);
--    txc(dsutx, 16#c0#, txp);
--    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
--    txa(dsutx, 16#00#, 16#00#, 16#06#, 16#fc#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#2f#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#91#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#6f#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#11#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#04#, txp);
    txa(dsutx, 16#00#, 16#02#, 16#20#, 16#01#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#02#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0f#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#43#, 16#10#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0f#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#91#, 16#40#, 16#00#, 16#24#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#24#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#91#, 16#70#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#03#, txp);





    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#ff#, 16#ff#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#48#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#12#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#60#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#12#, 16#10#, txp);

    txc(dsutx, 16#80#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    rxi(dsurx, w32, txp, lresp);

    txc(dsutx, 16#a0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
    rxi(dsurx, w32, txp, lresp);

    end;

  begin

    dsucfg(dsutx, dsurx);

    wait;
  end process;

  jtagproc : process
  begin
    wait;
    jtagcom(tdo, tck, tms, tdi, 100, 20, 16#40000000#, true);
    wait;
   end process;

end;
