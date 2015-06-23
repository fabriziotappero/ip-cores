-----------------------------------------------------------------------------
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
    clkperiod : integer := 16;		-- system clock period
    comboard  : integer := 1		-- Comms. adapter board attached
  );
  port (
    pci_rst     : out std_logic;
    pci_clk 	: in std_logic;
    pci_gnt     : in std_logic;
    pci_idsel   : in std_logic;  
    pci_lock    : inout std_logic;
    pci_ad 	: inout std_logic_vector(31 downto 0);
    pci_cbe 	: inout std_logic_vector(3 downto 0);
    pci_frame   : inout std_logic;
    pci_irdy 	: inout std_logic;
    pci_trdy 	: inout std_logic;
    pci_devsel  : inout std_logic;
    pci_stop 	: inout std_logic;
    pci_perr 	: inout std_logic;
    pci_par 	: inout std_logic;    
    pci_req 	: inout std_logic;
    pci_serr    : inout std_logic;
    pci_host   	: in std_logic;
    pci_66	: in std_logic
  );
end; 

architecture behav of testbench is

constant promfile  : string := "prom.srec";  -- rom contents
constant sramfile  : string := "sram.srec";  -- ram contents
constant sdramfile : string := "sdram.srec"; -- sdram contents

component leon3mp
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;
    mezz      : integer := CFG_ADS_DAU_MEZZ
  );
  port (
    clk_66mhz	: in  std_logic;
    clk_socket	: in  std_logic;
    leds	: out std_logic_vector(7 downto 0);
    switches	: in  std_logic_vector(5 downto 0);

    sram_a	: out std_logic_vector(24 downto 0);
    sram_ben_l	: out std_logic_vector(0 to 3);
    sram_cs_l   : out std_logic_vector(1 downto 0);
    sram_oe_l   : out std_logic;
    sram_we_l   : out std_logic;
    sram_dq	: inout std_logic_vector(31 downto 0);
    flash_cs_l  : out std_logic;
    flash_rst_l : out std_logic;
    iosn        : out std_logic;
    sdclk       : out std_logic;
    rasn        : out std_logic;
    casn        : out std_logic;
    sdcke       : out std_logic;
    sdcsn       : out std_logic;

    tx          : out std_logic;
    rx          : in  std_logic;

    can_txd     : out std_logic;
    can_rxd     : in  std_logic;

    phy_txck 	: in std_logic;
    phy_rxck 	: in std_logic;
    phy_rxd    	: in std_logic_vector(3 downto 0);   
    phy_rxdv  	: in std_logic; 
    phy_rxer  	: in std_logic; 
    phy_col 	: in std_logic;
    phy_crs 	: in std_logic;
    phy_txd 	: out std_logic_vector(3 downto 0);   
    phy_txen 	: out std_logic; 
    phy_txer 	: out std_logic; 
    phy_mdc 	: out std_logic;
    phy_mdio   	: inout std_logic;		-- ethernet PHY interface
    phy_reset_l	: inout std_logic;

    video_clk 	: in std_logic;
    comp_sync 	: out std_logic;
    blank 	: out std_logic;
    video_out 	: out std_logic_vector(23 downto 0);   

    msclk   	: inout std_logic;
    msdata  	: inout std_logic;
    kbclk   	: inout std_logic;
    kbdata  	: inout std_logic;

    disp_seg1 	: out std_logic_vector(7 downto 0);   
    disp_seg2 	: out std_logic_vector(7 downto 0);   

    pci_clk 	: in std_logic;
    pci_gnt     : in std_logic;
    pci_idsel   : in std_logic; 
    pci_lock    : inout std_logic;
    pci_ad 	: inout std_logic_vector(31 downto 0);
    pci_cbe 	: inout std_logic_vector(3 downto 0);
    pci_frame   : inout std_logic;
    pci_irdy 	: inout std_logic;
    pci_trdy 	: inout std_logic;
    pci_devsel  : inout std_logic;
    pci_stop 	: inout std_logic;
    pci_perr 	: inout std_logic;
    pci_par 	: inout std_logic;    
    pci_req 	: inout std_logic;
    pci_serr    : inout std_logic;
    pci_host   	: in std_logic;
    pci_66	: in std_logic
	);
end component;

signal clk : std_logic := '0';
constant ct : integer := clkperiod/2;

signal gnd      : std_logic := '0';
signal vcc      : std_logic := '1';
    
signal sdcke    : std_logic;
signal sdcsn    : std_logic;
signal sdwen    : std_logic;                       -- write en
signal sdrasn   : std_logic;                       -- row addr stb
signal sdcasn   : std_logic;                       -- col addr stb
signal sddqm    : std_logic_vector ( 7 downto 0);  -- data i/o mask
signal sdclk    : std_logic;       
signal plllock  : std_logic;       
signal tx, rx   : std_logic;       
signal dsutx, dsurx   : std_logic;       

signal leds : std_logic_vector(7 downto 0);
signal switches : std_logic_vector(5 downto 0);

constant lresp : boolean := false;

signal sram_oe_l, sram_we_l : std_logic;
signal sram_cs_l : std_logic_vector(1 downto 0);
signal sram_ben_l : std_logic_vector(0 to 3);
signal sram_dq : std_logic_vector(31 downto 0);
signal flash_cs_l, flash_rst_l : std_logic;
signal iosn : std_logic;

signal phy_txck : std_logic;
signal phy_rxck : std_logic;
signal phy_rxd  : std_logic_vector(3 downto 0);
signal phy_rxdt : std_logic_vector(7 downto 0);   
signal phy_rxdv : std_logic; 
signal phy_rxer : std_logic; 
signal phy_col 	: std_logic;
signal phy_crs 	: std_logic;
signal phy_txd 	: std_logic_vector(3 downto 0);
signal phy_txdt : std_logic_vector(7 downto 0);   
signal phy_txen : std_logic; 
signal phy_txer : std_logic; 
signal phy_mdc 	: std_logic;
signal phy_mdio : std_logic;
signal phy_reset_l : std_logic;
signal phy_gtx_clk : std_logic := '0';

signal video_clk : std_logic := '0';
signal comp_sync : std_logic;
signal blank 	 : std_logic;
signal video_out : std_logic_vector(23 downto 0);   

signal msclk   	: std_logic;
signal msdata  	: std_logic;
signal kbclk   	: std_logic;
signal kbdata  	: std_logic;
signal dsurst  	: std_logic;

signal disp_seg1 : std_logic_vector(7 downto 0);   
signal disp_seg2 : std_logic_vector(7 downto 0);   

signal baddr : std_logic_vector(27 downto 0) := (others => '0');   

signal can_txd  : std_logic;
signal can_rxd  : std_logic;

begin

-- clock and reset

  clk <= not clk after ct * 1 ns;
  switches(0) <= '1'; 		-- DSUEN
  switches(4) <= not dsurst;	-- reset
  switches(5) <= '0'; 		-- DSUBRE
  dsutx <= tx; rx <= dsurx;
  pci_rst <= phy_reset_l;
  phy_reset_l <= 'H';
  video_clk <= not video_clk after 20 ns;

  can_rxd <= can_txd;
  sddqm(3) <= sram_ben_l(0); sddqm(2) <= sram_ben_l(1);
  sddqm(1) <= sram_ben_l(2); sddqm(0) <= sram_ben_l(3);
  cpu : leon3mp
	generic map (fabtech, memtech, padtech, clktech, 
	disas, dbguart, pclow )
        port map (clk, sdclk,  leds, switches, baddr(24 downto 0), 
	sram_ben_l, sram_cs_l, sram_oe_l, sram_we_l, sram_dq, 
	flash_cs_l, flash_rst_l, iosn, sdclk, sdrasn, sdcasn, sdcke, sdcsn, 
	tx, rx, can_txd, can_rxd, phy_txck, phy_rxck, phy_rxd, phy_rxdv, 
	phy_rxer, phy_col, phy_crs, phy_txd, phy_txen, phy_txer, phy_mdc,
	phy_mdio, phy_reset_l,
	video_clk, comp_sync, blank, video_out, 
	msclk, msdata, kbclk, kbdata, disp_seg1, disp_seg2, 
    	pci_clk, pci_gnt, pci_idsel, pci_lock, pci_ad, pci_cbe,
    	pci_frame, pci_irdy, pci_trdy, pci_devsel, pci_stop, pci_perr, pci_par,
    	pci_req, pci_serr, pci_host, pci_66);


-- One 32-bit SRAM bank on main board

  sram0 : for i in 0 to 1 generate
      sr0 : sram16 generic map (index => i*2, abits => 18, fname => sramfile)
	port map (baddr(17 downto 0), sram_dq(31-i*16 downto 16-i*16), 
		sram_ben_l(i*2), sram_ben_l(i*2+1), sram_cs_l(0), sram_we_l, sram_oe_l);
  end generate;

  phy_mdio <= 'H';
  phy_rxd <= phy_rxdt(3 downto 0);
  phy_txdt <= "0000" & phy_txd;
  
  p0: phy
    generic map(base1000_t_fd => 0, base1000_t_hd => 0)
    port map(dsurst, phy_mdio, phy_txck, phy_rxck, phy_rxdt, phy_rxdv,
      phy_rxer, phy_col, phy_crs, phy_txdt, phy_txen, phy_txer, phy_mdc, phy_gtx_clk);
  
-- optional communications adapter

  comms : if (comboard = 1) generate

    -- 32-bit flash prom
    flash0 : for i in 0 to 1 generate
      sr0 : sram16 generic map (index => i*2, abits => 18, fname => promfile)
	port map (baddr(19 downto 2), sram_dq(31-i*16 downto 16-i*16), 
		flash_cs_l, flash_cs_l, flash_cs_l, sram_we_l, sram_oe_l);
    end generate;

    -- second SRAM bank

    sram1 : for i in 0 to 1 generate
      sr0 : sram16 generic map (index => i*2, abits => 18, fname => sramfile)
	port map (baddr(19 downto 2), sram_dq(31-i*16 downto 16-i*16), 
	sram_ben_l(i*2), sram_ben_l(i*2+1), sram_cs_l(1), sram_we_l, sram_oe_l);
    end generate;

    sdwen <= sram_we_l;

  u0: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sram_dq(31 downto 16), Addr => baddr(14 downto 2),
            Ba => baddr(16 downto 15), Clk => sdclk, Cke => sdcke,
            Cs_n => sdcsn, Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
  u1: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sram_dq(15 downto 0), Addr => baddr(14 downto 2),
            Ba => baddr(16 downto 15), Clk => sdclk, Cke => sdcke,
            Cs_n => sdcsn, Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));

  end generate;

  test0 :  grtestmod
    port map ( dsurst, clk, leds(0), baddr(21 downto 2), sram_dq,
    	       iosn, sram_oe_l, sram_we_l, open);

  leds(0) <= 'H';			  -- ERROR pull-up

   iuerr : process
   begin
     wait for 2000 ns;
     if to_x01(leds(0)) = '0' then wait on leds; end if;
     assert (to_x01(leds(0)) = '0') 
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  sram_dq <= buskeep(sram_dq), (others => 'H') after 250 ns;

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

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#ef#, txp);

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

