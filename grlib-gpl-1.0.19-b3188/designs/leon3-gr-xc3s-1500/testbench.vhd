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
    pclow     : integer := CFG_PCLOW
  );
  port (
    resetn	: in  std_ulogic;
    clk		: in  std_ulogic;
    clk3	: in  std_ulogic;
    pllref 	: in  std_ulogic; 
    errorn	: out std_ulogic;
    wdogn 	: out std_ulogic;

    address 	: out std_logic_vector(27 downto 0);
    data	: inout std_logic_vector(31 downto 0);
    ramsn  	: out std_logic_vector (4 downto 0);
    ramoen 	: out std_logic_vector (4 downto 0);
    rwen   	: out std_logic_vector (3 downto 0);
    oen    	: out std_ulogic;
    writen 	: out std_ulogic;
    read   	: out std_ulogic;
    iosn   	: out std_ulogic;
    bexcn  	: in  std_ulogic;  			-- DSU rx data
    brdyn  	: in  std_ulogic;  			-- DSU rx data
    romsn  	: out std_logic_vector (1 downto 0);
    sdclk  	: out std_ulogic;
    sdcsn  	: out std_logic_vector (1 downto 0);    -- sdram chip select
    sdwen  	: out std_ulogic;                       -- sdram write enable
    sdrasn  	: out std_ulogic;                       -- sdram ras
    sdcasn  	: out std_ulogic;                       -- sdram cas
    sddqm   	: out std_logic_vector (3 downto 0);    -- sdram dqm

    dsuen   	: in std_ulogic;
    dsubre  	: in std_ulogic;
    dsuact  	: out std_ulogic;

    txd1   	: out std_ulogic; 			-- UART1 tx data
    rxd1   	: in  std_ulogic;  			-- UART1 rx data
    ctsn1  	: in  std_ulogic;  			-- UART1 rx data
    rtsn1  	: out std_ulogic;  			-- UART1 rx data
    txd2   	: out std_ulogic; 			-- UART2 tx data
    rxd2   	: in  std_ulogic;  			-- UART2 rx data
    ctsn2  	: in  std_ulogic;  			-- UART1 rx data
    rtsn2  	: out std_ulogic;  			-- UART1 rx data

    pio         : inout std_logic_vector(17 downto 0); 	-- I/O port

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

    ps2clk      : inout std_logic_vector(1 downto 0);
    ps2data     : inout std_logic_vector(1 downto 0);

    vid_clock   : out std_ulogic;
    vid_blankn  : out std_ulogic;
    vid_syncn   : out std_ulogic;
    vid_hsync   : out std_ulogic;
    vid_vsync   : out std_ulogic;
    vid_r       : out std_logic_vector(7 downto 0);
    vid_g       : out std_logic_vector(7 downto 0);
    vid_b       : out std_logic_vector(7 downto 0);

    spw_clk	: in  std_ulogic;
    spw_rxdp    : in  std_logic_vector(0 to 2);
    spw_rxdn    : in  std_logic_vector(0 to 2);
    spw_rxsp    : in  std_logic_vector(0 to 2);
    spw_rxsn    : in  std_logic_vector(0 to 2);
    spw_txdp    : out std_logic_vector(0 to 2);
    spw_txdn    : out std_logic_vector(0 to 2);
    spw_txsp    : out std_logic_vector(0 to 2);
    spw_txsn    : out std_logic_vector(0 to 2);

    usb_clkout    : in std_ulogic;
    usb_d         : inout std_logic_vector(15 downto 0);
    usb_linestate : in std_logic_vector(1 downto 0);
    usb_opmode    : out std_logic_vector(1 downto 0);
    usb_reset     : out std_ulogic;
    usb_rxactive  : in std_ulogic;
    usb_rxerror   : in std_ulogic;
    usb_rxvalid   : in std_ulogic;
    usb_suspend   : out std_ulogic;
    usb_termsel   : out std_ulogic;
    usb_txready   : in std_ulogic;
    usb_txvalid   : out std_ulogic;
    usb_validh    : inout std_ulogic;
    usb_xcvrsel   : out std_ulogic;
    usb_vbus      : in std_ulogic;

    ata_rstn  : out std_logic; 
    ata_data  : inout std_logic_vector(15 downto 0);
    ata_da    : out std_logic_vector(2 downto 0);  
    ata_cs0   : out std_logic;
    ata_cs1   : out std_logic;
    ata_dior  : out std_logic;
    ata_diow  : out std_logic;
    ata_iordy : in std_logic;
    ata_intrq : in std_logic;
    ata_dmarq : in std_logic; 
    ata_dmack : out std_logic;
    --ata_dasp  : in std_logic;
    ata_csel  : out std_logic

  );

end component;

signal clk : std_logic := '0';
signal Rst : std_logic := '0';			-- Reset
constant ct : integer := clkperiod/2;

signal address  : std_logic_vector(27 downto 0);
signal data     : std_logic_vector(31 downto 0);
signal pio     	: std_logic_vector(17 downto 0);
signal romsn  	: std_logic_vector(1 downto 0);
signal ramsn  	: std_logic_vector(4 downto 0);
signal ramoen 	: std_logic_vector(4 downto 0);
signal rwen 	: std_logic_vector(3 downto 0);
signal oen      : std_ulogic;
signal writen   : std_ulogic;
signal read   	: std_ulogic;
signal iosn   	: std_ulogic;
signal bexcn   	: std_ulogic;
signal brdyn   	: std_ulogic;
signal dsuen, dsutx, dsurx, dsubre, dsuact : std_ulogic;
signal dsurst   : std_ulogic;
signal GND      : std_ulogic := '0';
signal VCC      : std_ulogic := '1';
signal NC       : std_ulogic := 'Z';
signal clk2     : std_ulogic := '1';
signal wdogn    : std_logic;
    
signal sdcke    : std_ulogic; 			    -- clk en
signal sdcsn    : std_logic_vector ( 1 downto 0); 
signal sdwen    : std_ulogic;                       -- write en
signal sdrasn   : std_ulogic;                       -- row addr stb
signal sdcasn   : std_ulogic;                       -- col addr stb
signal sddqm    : std_logic_vector ( 3 downto 0);   -- data i/o mask
signal sdclk    : std_ulogic;       
signal pllref   : std_ulogic;       
signal txd1, rxd1 : std_logic;       
signal txd2, rxd2 : std_logic;       
signal ctsn1, rtsn1 : std_ulogic;       
signal ctsn2, rtsn2 : std_ulogic;       
signal errorn   : std_logic;       

signal etx_clk, erx_clk, erx_dv, erx_er, erx_col, erx_crs, etx_en, etx_er : std_logic:='0';
signal erxd, etxd: std_logic_vector(3 downto 0):=(others=>'0');
signal erxdt, etxdt : std_logic_vector(7 downto 0);
signal emdc, emdio: std_logic; --dummy signal for the mdc,mdio in the phy which is not used
signal eth_macclk : std_ulogic := '0';

signal ps2clk      : std_logic_vector(1 downto 0);
signal ps2data     : std_logic_vector(1 downto 0);

signal vid_clock   : std_ulogic;
signal vid_blankn  : std_ulogic;
signal vid_syncn   : std_ulogic;
signal vid_hsync   : std_ulogic;
signal vid_vsync   : std_ulogic;
signal vid_r       : std_logic_vector(7 downto 0);
signal vid_g       : std_logic_vector(7 downto 0);
signal vid_b       : std_logic_vector(7 downto 0);
signal clk3        : std_ulogic := '0';

signal spw_clk	: std_ulogic := '0';
signal spw_rxdp : std_logic_vector(0 to 2) := "000";
signal spw_rxdn : std_logic_vector(0 to 2) := "000";
signal spw_rxsp : std_logic_vector(0 to 2) := "000";
signal spw_rxsn : std_logic_vector(0 to 2) := "000";
signal spw_txdp : std_logic_vector(0 to 2);
signal spw_txdn : std_logic_vector(0 to 2);
signal spw_txsp : std_logic_vector(0 to 2);
signal spw_txsn : std_logic_vector(0 to 2);

signal usb_clkout    : std_ulogic := '0';
signal usb_d         : std_logic_vector(15 downto 0);
signal usb_linestate : std_logic_vector(1 downto 0);
signal usb_opmode    : std_logic_vector(1 downto 0);
signal usb_reset     : std_ulogic;
signal usb_rxactive  : std_ulogic;
signal usb_rxerror   : std_ulogic;
signal usb_rxvalid   : std_ulogic;
signal usb_suspend   : std_ulogic;
signal usb_termsel   : std_ulogic;
signal usb_txready   : std_ulogic;
signal usb_txvalid   : std_ulogic;
signal usb_validh    : std_logic;
signal usb_xcvrsel   : std_ulogic;
signal usb_vbus      : std_ulogic;
signal rhvalid       : std_ulogic;

signal ata_data  : std_logic_vector(15 downto 0);
signal ata_da    : std_logic_vector(2 downto 0);  
signal ata_cs0   : std_logic;
signal ata_cs1   : std_logic;
signal ata_dior  : std_logic;
signal ata_diow  : std_logic;
signal ata_iordy : std_logic;
signal ata_intrq : std_logic;
signal ata_dmarq : std_logic; 
signal ata_dmack : std_logic;
signal ata_rstn  : std_logic;
signal ata_csel  : std_logic;

signal from_ata : ata_out_type := ATAO_RESET_VECTOR;
signal to_ata : ata_in_type := ATAI_RESET_VECTOR;

constant lresp : boolean := false;

begin

-- clock and reset

  clk  <= not clk after ct * 1 ns;
  clk3 <= not clk3 after 20 ns;
  rst <= dsurst and wdogn; 
  dsuen <= '1'; dsubre <= '0'; 
  rxd1 <= 'H'; ctsn1 <= '0';
  rxd2 <= 'H'; ctsn2 <= '0'; pllref <= sdclk;
  ps2clk <= "HH"; ps2data <= "HH";
  pio(4) <= pio(5); pio(1) <= pio(2); pio <= (others => 'H');
  wdogn <= 'H';
  usb_clkout  <= not usb_clkout after 8.33 ns;     -- ~60MHz

  spw_rxdp <= spw_txdp; spw_rxdn <= spw_txdn;
  spw_rxsp <= spw_txsp; spw_rxsn <= spw_txsn;

  ata_iordy <= 'H'; ata_intrq <= 'H'; ata_dmarq <= 'H';
  ata_data <= (others => 'H');

  cpu : leon3mp
      generic map ( fabtech, memtech, padtech, clktech, 
	disas, dbguart, pclow )
      port map (rst, clk, clk3, pllref, errorn, wdogn, address(27 downto 0), data, 
	ramsn, ramoen, rwen, oen, writen, read, iosn, bexcn, brdyn, romsn,
	sdclk, sdcsn, sdwen, sdrasn, sdcasn, sddqm, 
	dsuen, dsubre, dsuact, 
	txd1, rxd1, ctsn1, rtsn1, txd2, rxd2, ctsn2, rtsn2, pio,
        emdio, etx_clk, erx_clk, erxd, erx_dv, erx_er, erx_col, erx_crs,
        etxd, etx_en, etx_er, emdc, ps2clk, ps2data, vid_clock, vid_blankn, vid_syncn,
        vid_hsync, vid_vsync, vid_r, vid_g, vid_b, spw_clk, spw_rxdp, spw_rxdn,
        spw_rxsp,  spw_rxsn, spw_txdp, spw_txdn, spw_txsp, spw_txsn, usb_clkout,
        usb_d, usb_linestate, usb_opmode, usb_reset, usb_rxactive, usb_rxerror,
        usb_rxvalid, usb_suspend, usb_termsel, usb_txready, usb_txvalid, usb_validh,
        usb_xcvrsel, usb_vbus, ata_rstn, ata_data, ata_da, ata_cs0, ata_cs1, 
	ata_dior, ata_diow, ata_iordy, ata_intrq, ata_dmarq, ata_dmack, ata_csel
      );

  u0: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => data(31 downto 16), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => vcc,
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
  u1: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => data(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => vcc,
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));

  prom0 : sram generic map (index => 6, abits => romdepth, fname => promfile)
	port map (address(romdepth-1 downto 0), data(31 downto 24), romsn(0),
		  writen, oen);

  disk: ata_device
    generic map( sector_length => 512, log2_size => 14)
    port map( clk => clk, rst => rst, d => ata_data, atai => to_ata,
      atao => from_ata
    );
  to_ata.cs(0)<=ata_cs0; to_ata.cs(1)<=ata_cs1;
  to_ata.da<=ata_da; to_ata.dmack<=ata_dmack;
  to_ata.dior<=ata_dior; to_ata.diow<=ata_diow; to_ata.reset<=ata_rstn;
  ata_dmarq<=from_ata.dmarq; ata_intrq<=from_ata.intrq; ata_iordy<=from_ata.iordy;


  phy0 : if (CFG_GRETH = 1) generate
    emdio <= 'H';
    erxd <= erxdt(3 downto 0);
    etxdt <= "0000" & etxd;
    p0: phy
      generic map(base1000_t_fd => 0, base1000_t_hd => 0)
      port map(rst, emdio, etx_clk, erx_clk, erxdt, erx_dv,
        erx_er, erx_col, erx_crs, etxdt, etx_en, etx_er, emdc, eth_macclk);
  end generate;
  
  errorn <= 'H';			  -- ERROR pull-up

   iuerr : process
   begin
     wait for 5000000 ns;
     if to_x01(errorn) = '1' then wait on errorn; end if;
     assert (to_x01(errorn) = '1') 
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  test0 :  grtestmod
    port map ( rst, clk, errorn, address(21 downto 2), data,
    	       iosn, oen, writen, brdyn);


  data <= buskeep(data) after 5 ns;

dsucom : process
    procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
   constant txp : time := 320 * 1 ns;
   begin
   dsutx <= '1';
   dsurst <= '0';
   wait for 2500 ns;
   dsurst <= '1';
   wait;
   wait for 5000 ns;
   txc(dsutx, 16#55#, txp);		-- sync uart

   txc(dsutx, 16#c0#, txp);
   txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
   txa(dsutx, 16#00#, 16#00#, 16#20#, 16#2e#, txp);

    wait for 25000 ns;
   txc(dsutx, 16#c0#, txp);
 txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#01#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#24#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0D#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#70#, 16#11#, 16#78#, txp);
    txa(dsutx, 16#91#, 16#00#, 16#00#, 16#0D#, txp);

    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#44#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#20#, 16#00#, txp);

    txc(dsutx, 16#80#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#44#, txp);

    wait;
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#0a#, 16#aa#, txp);
    txa(dsutx, 16#00#, 16#55#, 16#00#, 16#55#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#0a#, 16#a0#, txp);
    txa(dsutx, 16#01#, 16#02#, 16#09#, 16#33#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#2e#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#91#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#2e#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0f#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#00#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#80#, 16#00#, 16#02#, 16#10#, txp);
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

    dsucfg(txd2, rxd2);

  wait;
 end process;
end ;

