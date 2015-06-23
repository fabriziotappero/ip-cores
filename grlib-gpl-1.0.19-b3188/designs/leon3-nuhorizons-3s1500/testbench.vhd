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

use work.config.all;	-- configuration
use work.debug.all;

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
    pb_sw  	: in  std_logic_vector (4 downto 1); 	-- push buttons
    pll_clk	: in  std_ulogic;			-- PLL clock
    led    	: out std_logic_vector(8 downto 1);
    flash_a 	: out std_logic_vector(20 downto 0);
    flash_d	: inout std_logic_vector(15 downto 0);
    sdram_a    	: out std_logic_vector(11 downto 0);
    sdram_d   	: inout std_logic_vector(31 downto 0);
    sdram_ba   	: out std_logic_vector(3 downto 0);
    sdram_dqm  	: out std_logic_vector(3 downto 0);
    sdram_clk  	: inout std_ulogic;
    sdram_cke  	: out std_ulogic;    			-- sdram clock enable
    sdram_csn  	: out std_ulogic;    			-- sdram chip select
    sdram_wen  	: out std_ulogic;                       -- sdram write enable
    sdram_rasn  : out std_ulogic;                       -- sdram ras
    sdram_casn  : out std_ulogic;                       -- sdram cas

    uart1_txd  	: out std_ulogic;
    uart1_rxd  	: in  std_ulogic;
    uart1_rts  	: out std_ulogic;
    uart1_cts  	: in  std_ulogic;

    uart2_txd  	: out std_ulogic;
    uart2_rxd  	: in  std_ulogic;
    uart2_rts  	: out std_ulogic;
    uart2_cts  	: in  std_ulogic;

    flash_oen  	: out std_ulogic;
    flash_wen 	: out std_ulogic;
    flash_cen  	: out std_ulogic;
    flash_byte 	: out std_ulogic;
    flash_ready	: in  std_ulogic;
    flash_rpn  	: out std_ulogic;
    flash_wpn 	: out std_ulogic;

    phy_mii_data: inout std_logic;		-- ethernet PHY interface
    phy_tx_clk 	: in std_ulogic;
    phy_rx_clk 	: in std_ulogic;
    phy_rx_data	: in std_logic_vector(3 downto 0);   
    phy_dv  	: in std_ulogic; 
    phy_rx_er  	: in std_ulogic; 
    phy_col 	: in std_ulogic;
    phy_crs 	: in std_ulogic;
    phy_tx_data : out std_logic_vector(3 downto 0);   
    phy_tx_en 	: out std_ulogic; 
    phy_mii_clk : out std_ulogic;
    phy_100 	: in std_ulogic;		-- 100 Mbit indicator
    phy_rst_n 	: out std_ulogic;

    gpio        : inout std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);   

--    lcd_data 	: inout std_logic_vector(7 downto 0);
--    lcd_rs	: out std_ulogic;
--    lcd_rw	: out std_ulogic;
--    lcd_en	: out std_ulogic;
--    lcd_backl	: out std_ulogic;

    can_txd	: out std_ulogic;
    can_rxd	: in  std_ulogic;

    smsc_addr 	: out std_logic_vector(14 downto 0);
    smsc_data 	: inout std_logic_vector(31 downto 0);
    smsc_nbe  	: out std_logic_vector(3 downto 0);
    smsc_resetn	: out std_ulogic;
    smsc_ardy  	: in  std_ulogic;
--    smsc_intr  	: in  std_ulogic;
    smsc_nldev 	: in  std_ulogic;
    smsc_nrd   	: out std_ulogic;
    smsc_nwr   	: out std_ulogic;
    smsc_ncs   	: out std_ulogic;
    smsc_aen   	: out std_ulogic;
    smsc_lclk  	: out std_ulogic;
    smsc_wnr   	: out std_ulogic;
    smsc_rdyrtn	: out std_ulogic;
    smsc_cycle 	: out std_ulogic;
    smsc_nads  	: out std_ulogic
  );

end component;

signal clk : std_logic := '0';
signal Rst : std_logic := '0';			-- Reset
constant ct : integer := clkperiod/2;

signal address  : std_logic_vector(21 downto 0);
signal flash_d  : std_logic_vector(15 downto 0);

signal romsn    : std_ulogic;
signal oen      : std_ulogic;
signal writen   : std_ulogic;
signal dsuen, dsutx, dsurx, dsubre, dsuact : std_ulogic;
signal dsurst   : std_ulogic;
signal test     : std_ulogic;
signal error    : std_logic;
signal GND      : std_ulogic := '0';
signal VCC      : std_ulogic := '1';
signal NC       : std_ulogic := 'Z';
signal clk2     : std_ulogic := '1';
    
signal sdcke    : std_ulogic; 			    -- clk en
signal sdcsn    : std_ulogic;			    -- chip sel
signal sdwen    : std_ulogic;                       -- write en
signal sdrasn   : std_ulogic;                       -- row addr stb
signal sdcasn   : std_ulogic;                       -- col addr stb
signal sddqm    : std_logic_vector ( 3 downto 0);   -- data i/o mask
signal sdclk    : std_ulogic;       
signal txd1, rxd1 : std_ulogic;       
signal txd2, rxd2 : std_ulogic;       

signal etx_clk, erx_clk, erx_dv, erx_er, erx_col, erx_crs, etx_en, etx_er : std_logic:='0';
signal erxd, etxd: std_logic_vector(3 downto 0):=(others=>'0');
signal erxdt, etxdt: std_logic_vector(7 downto 0):=(others=>'0');  
signal emdc, emdio: std_logic;
signal gtx_clk : std_ulogic;

signal ereset 	: std_logic;

signal led     : std_logic_vector(8 downto 1);

constant lresp : boolean := false;

signal sa      	: std_logic_vector(14 downto 0);
signal ba     	: std_logic_vector(3 downto 0);
signal sd   	: std_logic_vector(31 downto 0);

signal pb_sw  	: std_logic_vector(4 downto 1);
signal lcd_data : std_logic_vector(7 downto 0);
signal lcd_rs	: std_ulogic;
signal lcd_rw	: std_ulogic;
signal lcd_en	: std_ulogic;
signal lcd_backl: std_ulogic;
signal can_txd	: std_ulogic;
signal can_rxd	: std_ulogic;

signal gpio 	: std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);

signal smsc_addr 	: std_logic_vector(21 downto 0);
signal smsc_data 	: std_logic_vector(31 downto 0);
signal smsc_nbe  	: std_logic_vector(3 downto 0);
signal smsc_resetn	: std_ulogic;
signal smsc_ardy  	: std_ulogic;
signal smsc_intr  	: std_ulogic;
signal smsc_nldev 	: std_ulogic;
signal smsc_nrd   	: std_ulogic;
signal smsc_nwr   	: std_ulogic;
signal smsc_ncs   	: std_ulogic;
signal smsc_aen   	: std_ulogic;
signal smsc_lclk  	: std_ulogic;
signal smsc_wnr   	: std_ulogic;
signal smsc_rdyrtn	: std_ulogic;
signal smsc_cycle  	: std_ulogic;
signal smsc_nads  	: std_ulogic;

begin

-- clock and reset

  clk <= not clk after ct * 1 ns;
  rst <= dsurst;
  dsuen <= '1'; dsubre <= '0'; rxd1 <= '1';
  can_rxd <= '1'; error <= led(8); sa(14 downto 12) <= "000";
  pb_sw <= rst & "00" & dsubre;
  cpu : leon3mp
      generic map ( fabtech, memtech, padtech, clktech, 
	disas, dbguart, pclow )
      port map (pb_sw, clk, led, address(21 downto 1), flash_d, 
	sa(11 downto 0), sd, ba, sddqm, sdclk, sdcke, sdcsn, sdwen, sdrasn, 
	sdcasn, txd1, rxd1, open, gnd, dsutx, dsurx, open, gnd,
	oen, writen, romsn, open, vcc, open, open,
        emdio, etx_clk, erx_clk, erxd, erx_dv, erx_er, erx_col, erx_crs,
        etxd, etx_en, emdc, gnd, ereset, gpio,
--	lcd_data, lcd_rs, lcd_rw, lcd_en, lcd_backl, 
	can_txd, can_rxd,
	smsc_addr(14 downto 0), smsc_data, smsc_nbe, smsc_resetn, smsc_ardy,-- smsc_intr,
	smsc_nldev, smsc_nrd, smsc_nwr, smsc_ncs, smsc_aen, smsc_lclk,
	smsc_wnr, smsc_rdyrtn, smsc_cycle, smsc_nads);

  u0: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => sd(31 downto 16), Addr => sa(12 downto 0),
            Ba => ba(1 downto 0), Clk => sdclk, Cke => sdcke,
            Cs_n => sdcsn, Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
  u1: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => sd(15 downto 0), Addr => sa(12 downto 0),
            Ba => ba(3 downto 2), Clk => sdclk, Cke => sdcke,
            Cs_n => sdcsn, Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
  prom0 : sram generic map (index => 6, abits => romdepth, fname => promfile)
	port map (address(romdepth-1 downto 0), flash_d(7 downto 0), romsn,
		  writen, oen);

  emdio <= 'H';
  erxd <= erxdt(3 downto 0);
  etxdt <= "0000" & etxd;
  
  p0: phy
    generic map(base1000_t_fd => 0, base1000_t_hd => 0)
    port map(rst, emdio, etx_clk, erx_clk, erxdt, erx_dv,
      erx_er, erx_col, erx_crs, etxdt, etx_en, etx_er, emdc, gtx_clk);
  error <= 'H';			  -- ERROR pull-up
  address(0) <= flash_d(15);

   iuerr : process
   begin
     wait for 2000 ns;
     if to_x01(error) = '1' then wait on error; end if;
     assert (to_x01(error) = '1') 
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  flash_d <= buskeep(flash_d) after 5 ns;
  sd <= buskeep(sd) after 5 ns;
  smsc_data <= buskeep(smsc_data) after 5 ns;
  smsc_addr(21 downto 15) <= (others => '0');
  test0 :  grtestmod
    port map ( rst, clk, error, address(21 downto 2), smsc_data,
    	       smsc_ncs, oen, writen, open);

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

    txc(dsutx, 16#c0#, txp);
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

    dsucfg(dsutx, dsurx);

    wait;
  end process;
end ;

