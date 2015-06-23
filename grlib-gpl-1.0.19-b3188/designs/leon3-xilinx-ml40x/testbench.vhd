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
library cypress;
use cypress.components.all;
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

    clkperiod : integer := 10;		-- system clock period
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

signal sys_clk : std_logic := '0';
signal sys_rst_in : std_logic := '0';			-- Reset
constant ct : integer := clkperiod/2;

signal plb_error	: std_logic;
signal opb_error	: std_logic;
signal flash_a23	: std_ulogic;
signal sram_flash_addr : std_logic_vector(22 downto 0);
signal sram_flash_data : std_logic_vector(31 downto 0);
signal sram_cen  	: std_logic;
signal sram_bw   	: std_logic_vector (3 downto 0);
signal sram_flash_oe_n : std_ulogic;
signal sram_flash_we_n 	: std_ulogic;
signal flash_ce  	: std_logic;
signal sram_clk  	: std_ulogic;
signal sram_clk_fb	: std_ulogic; 
signal sram_mode 	: std_ulogic;
signal sram_adv_ld_n : std_ulogic;
signal sram_zz : std_ulogic;
signal iosn : std_ulogic;
signal ddr_clk  	: std_logic;
signal ddr_clkb  	: std_logic;
signal ddr_clk_fb  : std_logic;
signal ddr_cke  	: std_logic;
signal ddr_csb  	: std_logic;
signal ddr_web  	: std_ulogic;                       -- ddr write enable
signal ddr_rasb  	: std_ulogic;                       -- ddr ras
signal ddr_casb  	: std_ulogic;                       -- ddr cas
signal ddr_dm   	: std_logic_vector (3 downto 0);    -- ddr dm
signal ddr_dqs  	: std_logic_vector (3 downto 0);    -- ddr dqs
signal ddr_ad      : std_logic_vector (12 downto 0);   -- ddr address
signal ddr_ba      : std_logic_vector (1 downto 0);    -- ddr bank address
signal ddr_dq  : std_logic_vector (31 downto 0);   -- ddr data
signal txd1   	: std_ulogic; 			-- UART1 tx data
signal rxd1   	: std_ulogic;  			-- UART1 rx data
signal gpio         : std_logic_vector(26 downto 0); 	-- I/O port
signal phy_mii_data: std_logic;		-- ethernet PHY interface
signal phy_tx_clk 	: std_ulogic;
signal phy_rx_clk 	: std_ulogic;
signal phy_rx_data	: std_logic_vector(7 downto 0);   
signal phy_dv  	: std_ulogic; 
signal phy_rx_er	: std_ulogic; 
signal phy_col 	: std_ulogic;
signal phy_crs 	: std_ulogic;
signal phy_tx_data : std_logic_vector(7 downto 0);   
signal phy_tx_en 	: std_ulogic; 
signal phy_tx_er 	: std_ulogic; 
signal phy_mii_clk	: std_ulogic;
signal phy_rst_n	: std_ulogic;
signal phy_gtx_clk	: std_ulogic;
signal ps2_keyb_clk: std_logic;
signal ps2_keyb_data: std_logic;
signal ps2_mouse_clk: std_logic;
signal ps2_mouse_data: std_logic;
signal tft_lcd_clk : std_ulogic;
signal vid_blankn  : std_ulogic;
signal vid_syncn   : std_ulogic;
signal vid_hsync   : std_ulogic;
signal vid_vsync   : std_ulogic;
signal vid_r       : std_logic_vector(7 downto 0);
signal vid_g       : std_logic_vector(7 downto 0);
signal vid_b       : std_logic_vector(7 downto 0);
signal usb_csn : std_logic;
signal flash_cex : std_logic;  
signal iic_scl : std_logic;
signal iic_sda : std_logic;

signal GND      : std_ulogic := '0';
signal VCC      : std_ulogic := '1';
signal NC       : std_ulogic := 'Z';
signal spw_clk	: std_ulogic := '0';
signal spw_rxdp : std_logic_vector(0 to 2) := "000";
signal spw_rxdn : std_logic_vector(0 to 2) := "000";
signal spw_rxsp : std_logic_vector(0 to 2) := "000";
signal spw_rxsn : std_logic_vector(0 to 2) := "000";
signal spw_txdp : std_logic_vector(0 to 2);
signal spw_txdn : std_logic_vector(0 to 2);
signal spw_txsp : std_logic_vector(0 to 2);
signal spw_txsn : std_logic_vector(0 to 2);

signal datazz : std_logic_vector(0 to 3);
constant lresp : boolean := false;

begin

-- clock and reset

  sys_clk <= not sys_clk after ct * 1 ns;
  sys_rst_in <= '0', '1' after 200 ns; 
  rxd1 <= 'H';
  sram_clk_fb <= sram_clk; ddr_clk_fb <= ddr_clk;
  ps2_keyb_data <= 'H'; ps2_keyb_clk <= 'H';
  ps2_mouse_clk <= 'H'; ps2_mouse_data <= 'H';
  iic_scl <= 'H'; iic_sda <= 'H';
  flash_cex <= not flash_ce;

  cpu : entity work.leon3mp
      generic map ( fabtech, memtech, padtech, ncpu, disas, dbguart, pclow )
      port map ( sys_rst_in, sys_clk, plb_error, opb_error, flash_a23, sram_flash_addr,
	sram_flash_data, sram_cen, sram_bw, sram_flash_oe_n, sram_flash_we_n, 
	flash_ce, sram_clk, sram_clk_fb, sram_mode, sram_adv_ld_n, iosn,
	ddr_clk, ddr_clkb, ddr_clk_fb, ddr_cke, ddr_csb, ddr_web, ddr_rasb, 
	ddr_casb, ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq, 
	txd1, rxd1, gpio, phy_gtx_clk, phy_mii_data, phy_tx_clk, phy_rx_clk, 
	phy_rx_data, phy_dv, phy_rx_er,	phy_col, phy_crs, 
	phy_tx_data, phy_tx_en, phy_tx_er, phy_mii_clk,	phy_rst_n, ps2_keyb_clk,
	ps2_keyb_data, ps2_mouse_clk, ps2_mouse_data, tft_lcd_clk, vid_blankn, vid_syncn, 
	vid_hsync, vid_vsync, vid_r, vid_g, vid_b,
        usb_csn,
        iic_scl, iic_sda
	);

  datazz <= "HHHH";

  u0 : cy7c1354 generic map (fname => sramfile)
   port map(
      Dq(35 downto 32) => datazz, Dq(31 downto 0) => sram_flash_data,
      Addr => sram_flash_addr(17 downto 0), Mode => sram_mode, 
      Clk => sram_clk, CEN_n => gnd, AdvLd_n => sram_adv_ld_n, 
      Bwa_n => sram_bw(3), Bwb_n => sram_bw(2), 
      Bwc_n => sram_bw(1), Bwd_n => sram_bw(0),
      Rw_n => sram_flash_we_n, Oe_n => sram_flash_oe_n, 
      Ce1_n => sram_cen, 
      Ce2 => vcc, 
      Ce3_n => gnd, 
      Zz => sram_zz);

      sram_zz <= '0';

  u1 : mt46v16m16 
    generic map (index => 1, fname => sdramfile, bbits => 32)
    PORT MAP(
      Dq => ddr_dq(15 downto 0), Dqs => ddr_dqs(1 downto 0), Addr => ddr_ad(12 downto 0),
      Ba => ddr_ba, Clk => ddr_clk,  Clk_n => ddr_clkb, Cke => ddr_cke,
      Cs_n => ddr_csb, Ras_n => ddr_rasb, Cas_n => ddr_casb, We_n => ddr_web,
      Dm => ddr_dm(1 downto 0));

  u2 : mt46v16m16 
    generic map (index => 0, fname => sdramfile, bbits => 32)
    PORT MAP(
      Dq => ddr_dq(31 downto 16), Dqs => ddr_dqs(3 downto 2), Addr => ddr_ad(12 downto 0),
      Ba => ddr_ba, Clk => ddr_clk,  Clk_n => ddr_clkb, Cke => ddr_cke,
      Cs_n => ddr_csb, Ras_n => ddr_rasb, Cas_n => ddr_casb, We_n => ddr_web,
      Dm => ddr_dm(3 downto 2));

  prom0 : for i in 0 to (romwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => romdepth, fname => promfile)
	port map (sram_flash_addr(romdepth-1 downto 0), sram_flash_data(31-i*8 downto 24-i*8), 
	flash_cex, sram_bw(i), sram_flash_oe_n);
  end generate;

  phy_mii_data <= 'H';
    
  p0: phy
    port map(sys_rst_in, phy_mii_data, phy_tx_clk, phy_rx_clk, phy_rx_data, phy_dv,
             phy_rx_er, phy_col, phy_crs, phy_tx_data, phy_tx_en, phy_tx_er, phy_mii_clk, phy_gtx_clk);

  i0: i2c_slave_model
    port map (iic_scl, iic_sda);
  
  plb_error <= 'H';			  -- ERROR pull-up

   iuerr : process
   begin
     wait for 5000 ns;
     if to_x01(plb_error) = '1' then wait on plb_error; end if;
     assert (to_x01(plb_error) = '1') 
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  test0 :  grtestmod
    port map ( sys_rst_in, sys_clk, plb_error, sram_flash_addr(19 downto 0), sram_flash_data,
    	       iosn, sram_flash_oe_n, sram_bw(0), open);


  sram_flash_data <= buskeep(sram_flash_data), (others => 'H') after 250 ns;
  ddr_dq <= buskeep(ddr_dq), (others => 'H') after 250 ns;

end ;

