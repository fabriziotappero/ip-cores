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
    ncpu      : integer := CFG_NCPU;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW;

    clkperiod : integer := 25;		-- system clock period
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 16;		-- rom address depth
    sramwidth  : integer := 32;		-- ram data width (8/16/32)
    sramdepth  : integer := 18;		-- ram address depth
    srambanks  : integer := 2		-- number of ram banks
  );
  port (
    pci_rst     : inout std_logic;	-- PCI bus
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

signal sys_clk : std_logic := '0';
signal sys_rst_in : std_logic := '0';			-- Reset
constant ct : integer := clkperiod/2;

signal errorn	: std_logic;
signal address : std_logic_vector(27 downto 0);
signal data : std_logic_vector(15 downto 0);
signal xdata : std_logic_vector(31 downto 0);
signal romsn  	: std_logic;
signal iosn : std_logic;
signal writen, read 	: std_logic;
signal oen 	: std_logic;
signal flash_rstn  	: std_logic;
signal ddr_clk  	: std_logic_vector(1 downto 0);
signal ddr_clkb  	: std_logic_vector(1 downto 0);
signal ddr_clk_fb  : std_logic;
signal ddr_clk_fb_out  : std_logic;
signal ddr_cke  	: std_logic_vector(1 downto 0);
signal ddr_csb  	: std_logic_vector(1 downto 0);
signal ddr_web  	: std_logic;                       -- ddr write enable
signal ddr_rasb  	: std_logic;                       -- ddr ras
signal ddr_casb  	: std_logic;                       -- ddr cas
signal ddr_dm   	: std_logic_vector (7 downto 0);    -- ddr dm
signal ddr_dqs  	: std_logic_vector (7 downto 0);    -- ddr dqs
signal ddr_ad      : std_logic_vector (12 downto 0);   -- ddr address
signal ddr_ba      : std_logic_vector (1 downto 0);    -- ddr bank address
signal ddr_dq  : std_logic_vector (63 downto 0);   -- ddr data
signal txd1   	: std_logic; 			-- UART1 tx data
signal rxd1   	: std_logic;  			-- UART1 rx data
signal gpio         : std_logic_vector(31 downto 0); 	-- I/O port
signal flash_cex : std_logic;

signal clk125      : std_logic := '0';
signal GND      : std_logic := '0';
signal VCC      : std_logic := '1';
signal NC       : std_logic := 'Z';
constant lresp : boolean := false;

signal dsuen   	: std_logic;
signal dsubre  	: std_logic;
signal dsuact  	: std_logic;
begin

-- clock and reset

  sys_clk <= not sys_clk after ct * 1 ns;
  sys_rst_in <= '0', '1' after 200 ns; 
  rxd1 <= 'H'; errorn <= 'H';
  ddr_clk_fb <= ddr_clk_fb_out;

  clk125 <= not clk125 after 6.75 ns;

  cpu : entity work.leon3mp
      generic map ( fabtech, memtech, padtech, ncpu, disas, dbguart, pclow )
      port map ( sys_rst_in, sys_clk, clk125, errorn, flash_rstn, address,
	data, dsuen, dsubre, dsuact, oen, writen, read, iosn, romsn,
	ddr_clk, ddr_clkb, ddr_clk_fb, ddr_clk_fb_out, ddr_cke, ddr_csb, 
	ddr_web, ddr_rasb, ddr_casb, ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq, 
	txd1, rxd1, 
--	gpio,
	pci_rst, pci_clk, pci_gnt, pci_idsel, pci_lock, pci_ad, pci_cbe,
    	pci_frame, pci_irdy, pci_trdy, pci_devsel, pci_stop, pci_perr, pci_par,
    	pci_req, pci_serr, pci_host, pci_66
	);

  ddrmem : for i in 0 to 1 generate
    u3 : mt46v16m16 
    generic map (index => 3, fname => sdramfile, bbits => 64)
    PORT MAP(
      Dq => ddr_dq(15 downto 0), Dqs => ddr_dqs(1 downto 0), Addr => ddr_ad,
      Ba => ddr_ba, Clk => ddr_clk(i),  Clk_n => ddr_clkb(i), Cke => ddr_cke(i),
      Cs_n => ddr_csb(i), Ras_n => ddr_rasb, Cas_n => ddr_casb, We_n => ddr_web,
      Dm => ddr_dm(1 downto 0));

    u2 : mt46v16m16 
    generic map (index => 2, fname => sdramfile, bbits => 64)
    PORT MAP(
      Dq => ddr_dq(31 downto 16), Dqs => ddr_dqs(3 downto 2), Addr => ddr_ad,
      Ba => ddr_ba, Clk => ddr_clk(i),  Clk_n => ddr_clkb(i), Cke => ddr_cke(i),
      Cs_n => ddr_csb(i), Ras_n => ddr_rasb, Cas_n => ddr_casb, We_n => ddr_web,
      Dm => ddr_dm(3 downto 2));
    u1 : mt46v16m16 
    generic map (index => 1, fname => sdramfile, bbits => 64)
    PORT MAP(
      Dq => ddr_dq(47 downto 32), Dqs => ddr_dqs(5 downto 4), Addr => ddr_ad,
      Ba => ddr_ba, Clk => ddr_clk(i),  Clk_n => ddr_clkb(i), Cke => ddr_cke(i),
      Cs_n => ddr_csb(i), Ras_n => ddr_rasb, Cas_n => ddr_casb, We_n => ddr_web,
      Dm => ddr_dm(5 downto 4));

    u0 : mt46v16m16 
    generic map (index => 0, fname => sdramfile, bbits => 64)
    PORT MAP(
      Dq => ddr_dq(63 downto 48), Dqs => ddr_dqs(7 downto 6), Addr => ddr_ad,
      Ba => ddr_ba, Clk => ddr_clk(i),  Clk_n => ddr_clkb(i), Cke => ddr_cke(i),
      Cs_n => ddr_csb(i), Ras_n => ddr_rasb, Cas_n => ddr_casb, We_n => ddr_web,
      Dm => ddr_dm(7 downto 6));
  end generate;

  prom0 : sram16 generic map (index => 4, abits => romdepth, fname => promfile)
	port map (address(romdepth-1 downto 0), data,
		  gnd, gnd, romsn, writen, oen);

   iuerr : process
   begin
     wait for 5000 ns;
     if to_x01(errorn) = '1' then wait on errorn; end if;
     assert (to_x01(errorn) = '1') 
       report "*** IU in error mode, simulation halted ***"
         severity failure ;
   end process;

  xdata <= "0000000000000000" & data;
  test0 :  grtestmod
    port map ( sys_rst_in, sys_clk, errorn, address(20 downto 1), xdata,
    	       iosn, oen, writen, open);


  data <= buskeep(data), (others => 'H') after 250 ns;
  ddr_dq <= buskeep(ddr_dq), (others => 'H') after 250 ns;

end ;

