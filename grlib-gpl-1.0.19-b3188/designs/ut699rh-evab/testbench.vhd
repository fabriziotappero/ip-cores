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
library gaisler;
use gaisler.libdcom.all;
use gaisler.sim.all;
use work.debug.all;
use work.config.all;
library techmap;
use techmap.gencomp.all;
library micron;
use micron.components.all;

use work.config.all;	-- configuration

entity testbench is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;

    clkperiod : integer := 20;		-- system clock period
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 16;		-- rom address depth
    sramwidth  : integer := 32;		-- ram data width (8/16/32)
    sramdepth  : integer := 20;		-- ram address depth
    srambanks  : integer := 2		-- number of ram banks
  );
  port (
    pci_clk 	: inout std_logic := '0';
    pci_lock    : inout std_logic := 'H';
    pci_ad 	: inout std_logic_vector(31 downto 0) := (others => 'H');
    pci_cbe 	: inout std_logic_vector(3 downto 0) := (others => 'H');
    pci_frame   : inout std_logic := 'H';
    pci_irdy 	: inout std_logic := 'H';
    pci_trdy 	: inout std_logic := 'H';
    pci_devsel  : inout std_logic := 'H';
    pci_stop 	: inout std_logic := 'H';
    pci_perr 	: inout std_logic := 'H';
    pci_par 	: inout std_logic := 'H';
    pci_serr    : inout std_logic := 'H'

  );
end; 

architecture behav of testbench is

constant promfile  : string := "prom.srec";  -- rom contents
constant sramfile  : string := "sram.srec";  -- ram contents
constant sdramfile : string := "sdram.srec"; -- sdram contents

constant CFG_SDEN : integer := CFG_MCTRLFT_SDEN + CFG_MCTRL_SDEN;

signal pci_req 	: std_logic := 'H';
signal pci_arb_gnt : std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);
signal pci_rst : std_logic;	-- PCI bus
signal pci_gnt : std_logic;
signal pci_idsel : std_logic;  
signal pci_host : std_logic;
signal pci_arb_req : std_logic_vector(0 to CFG_PCI_ARB_NGNT-1);

signal clk : std_logic := '0';
signal Rst    : std_logic := '0';			-- Reset
constant ct : integer := clkperiod/2;

signal address  : std_logic_vector(27 downto 0);
signal data     : std_logic_vector(31 downto 0);
signal cb, scb  : std_logic_vector(15 downto 0);

signal ramsn    : std_logic_vector(4 downto 0);
signal ramoen   : std_logic_vector(4 downto 0);
signal rwen     : std_logic_vector(3 downto 0);
signal rwenx    : std_logic_vector(3 downto 0);
signal romsn    : std_logic_vector(1 downto 0);
signal iosn     : std_logic;
signal oen      : std_logic;
signal read     : std_logic;
signal writen   : std_logic;
signal brdyn    : std_logic;
signal bexcn    : std_logic;
signal wdogn    : std_logic;
signal dsuen, dsutx, dsurx, dsubre, dsuact : std_logic;
signal dsurst   : std_logic;
signal test     : std_logic;
signal error    : std_logic;
signal gpio	: std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);
signal GND      : std_logic := '0';
signal VCC      : std_logic := '1';
signal NC       : std_logic := 'Z';
signal clk2     : std_logic := '1';
    
signal sdcke    : std_logic_vector ( 1 downto 0);  -- clk en
signal sdcsn    : std_logic_vector ( 1 downto 0);  -- chip sel
signal sdwen    : std_logic;                       -- write en
signal sdrasn   : std_logic;                       -- row addr stb
signal sdcasn   : std_logic;                       -- col addr stb
signal sddqm    : std_logic_vector ( 3 downto 0);  -- data i/o mask
signal sdclk    : std_logic;       
signal plllock, pllref    : std_logic;       
signal txd1, rxd1 : std_logic;       
signal txd2, rxd2 : std_logic;       

signal etx_clk, erx_clk, erx_dv, erx_er, erx_col, erx_crs, etx_en, etx_er : std_logic:='0';
signal erxd, etxd: std_logic_vector(3 downto 0):=(others=>'0');  
signal emdc, emdio: std_logic; --dummy signal for the mdc,mdio in the phy which is not used

signal emddis 	: std_logic;    
signal epwrdwn 	: std_logic;
signal ereset 	: std_logic;
signal esleep 	: std_logic;
signal epause 	: std_logic;

signal led_cfg: std_logic_vector(2 downto 0);

constant lresp : boolean := false;

signal sa      	: std_logic_vector(14 downto 0);
signal sd   	: std_logic_vector(31 downto 0);

signal can_txd	: std_logic_vector(0 to CFG_CAN_NUM-1);
signal can_rxd	: std_logic_vector(0 to CFG_CAN_NUM-1);

signal can_stb	: std_logic;

signal spw_clkp	: std_logic := '0';
signal spw_clkn	: std_logic := '1';
signal spw_rxdp : std_logic_vector(0 to CFG_SPW_NUM-1) := (others => '0');
signal spw_rxdn : std_logic_vector(0 to CFG_SPW_NUM-1) := (others => '0');
signal spw_rxsp : std_logic_vector(0 to CFG_SPW_NUM-1) := (others => '0');
signal spw_rxsn : std_logic_vector(0 to CFG_SPW_NUM-1) := (others => '0');
signal spw_txdp : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txdn : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txsp : std_logic_vector(0 to CFG_SPW_NUM-1);
signal spw_txsn : std_logic_vector(0 to CFG_SPW_NUM-1);

begin

    pci_rst <= '0', '1' after 30*20 ns;
    pci_gnt <= 'H';
    pci_idsel <= 'L';
    pci_lock <= 'H';
    pci_ad <= (others => 'H');
    pci_cbe <= (others => 'H');
    pci_frame <= 'H';
    pci_irdy <= 'H';
    pci_trdy <= 'H';
    pci_devsel <= 'H';
    pci_stop <= 'H';
    pci_perr <= 'H';
    pci_par <= 'H';
    pci_req <= 'H';
    pci_serr <= 'H';
    pci_host <= 'L';
    pci_arb_req <= (others => 'H');

    pci_arb_req(1) <= pci_req;
    pci_gnt <= pci_arb_gnt(1);

-- clock and reset

  clk <= not clk after ct * 1 ns;
  pci_clk <= not pci_clk after 30 ns;
  spw_clkp <= not spw_clkp after 10 ns;
  spw_clkn <= not spw_clkn after 10 ns;
  rst <= dsurst;
  dsuen <= '1'; dsubre <= '0'; rxd1 <= '1';
  led_cfg<="000"; --put the phy in base10h mode
  can_rxd <= (others => 'H');  can_rxd <= can_txd;
  bexcn <= '1'; wdogn <= 'H';
  gpio(2 downto 0) <= "LHL"; 
  gpio(CFG_GRGPIO_WIDTH-1 downto 3) <= (others => 'H');
  pci_arb_req <= (others => 'H');
  pllref <= sdclk;
  -- spacewire loop-back
  spw_rxdp <= spw_txdp; spw_rxdn <= spw_txdn;
  spw_rxsp <= spw_txsp; spw_rxsn <= spw_txsn;

  d3 : entity work.leon3mp
        generic map ( fabtech, memtech, padtech, clktech, disas, dbguart, pclow )
        port map (rst, clk, error, wdogn, address(27 downto 0), data, 
	cb(7 downto 0), sdclk, sdcke, sdcsn, sdwen, sdrasn, sdcasn, sddqm, 
	dsutx, dsurx, dsuen, dsubre, dsuact, txd1, rxd1, --txd2, rxd2,
	ramsn, ramoen, rwen, oen, writen, read, iosn, romsn, brdyn, bexcn, gpio,
        emdio, etx_clk, erx_clk, erxd, erx_dv, erx_er, erx_col, erx_crs,
        etxd, etx_en, etx_er, emdc, 
    	pci_rst, pci_clk, pci_gnt, pci_idsel, --pci_lock, 
	pci_ad, pci_cbe, pci_frame, pci_irdy, pci_trdy, pci_devsel, pci_stop, 
	pci_perr, pci_par, pci_req, --pci_serr, 
	pci_host, --pci_66, 
        pci_arb_req, pci_arb_gnt,
	can_txd, can_rxd,
	spw_clkp, spw_clkn, spw_rxdp, spw_rxdn, spw_rxsp, spw_rxsn, spw_txdp, 
	spw_txdn, spw_txsp, spw_txsn, pllref
	);

-- optional sdram

  sd0 : if (CFG_SDEN = 1) and (CFG_MCTRLFT_SEPBUS = 0) generate
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
    fr : if CFG_MCTRLFT = 1 generate
      cb0: ftmt48lc16m16a2 generic map (index => 8, fname => sdramfile)
	PORT MAP(
            Dq => cb(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
      cb1: ftmt48lc16m16a2 generic map (index => 8, fname => sdramfile)
	PORT MAP(
            Dq => cb(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    end generate;
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

  prom0 : for i in 0 to (romwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => romdepth, fname => promfile)
	port map (address(romdepth+1 downto 2), data(31-i*8 downto 24-i*8), romsn(0),
		  rwen(i), oen);
  end generate;

  sram0 : for i in 0 to (sramwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), data(31-i*8 downto 24-i*8), ramsn(0),
		  rwen(0), ramoen(0));
  end generate;

  fr : if CFG_MCTRLFT = 1 generate
    sramcb0 : sramft generic map (index => 7, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), cb(7 downto 0), ramsn(0), rwen(0), ramoen(0));
  end generate;

--  phy0 : if (CFG_GRETH = 1) generate
--    p0: phy 
--      port map(rst, led_cfg, open, etx_clk, erx_clk, erxd, erx_dv,
--      erx_er, erx_col, erx_crs, etxd, etx_en, etx_er, emdc);
--  end generate;
  error <= 'H';			  -- ERROR pull-up

   iuerr : process
   begin
     wait for 2500 ns;
     if to_x01(error) = '1' then wait on error; end if;
     assert (to_x01(error) = '1') 
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  test0 :  grtestmod
    port map ( rst, clk, error, address(21 downto 2), data,
    	       iosn, oen, writen, brdyn);

  data <= buskeep(data), (others => 'H') after 250 ns;
  sd <= buskeep(sd), (others => 'H') after 250 ns;

  scb <= buskeep(scb), (others => 'H') after 250 ns;
  cb <= buskeep(cb), (others => 'H') after 250 ns;

  dsucom : process
    procedure dsucfg(signal dsurx : in std_logic; signal dsutx : out std_logic) is
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
end ;

