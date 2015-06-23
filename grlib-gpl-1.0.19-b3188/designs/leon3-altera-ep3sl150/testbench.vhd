------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
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
--  Altera Stratix-III LEON3 Demonstration design test bench
--  Copyright (C) 2007 Jiri Gaisler, Gaisler Research
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

    clkperiod : integer := 20;		-- system clock period
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 23;		-- rom address depth
    sramwidth  : integer := 32;		-- ram data width (8/16/32)
    sramdepth  : integer := 20;		-- ram address depth
    srambanks  : integer := 1;		-- number of ram banks
    dbits      : integer := CFG_DDR2SP_DATAWIDTH
  );
end; 

architecture behav of testbench is

constant promfile  : string := "prom.srec";  -- rom contents
constant sramfile  : string := "sram.srec";  -- ram contents
constant sdramfile : string := "sdram.srec"; -- sdram contents
constant ct : integer := clkperiod/2;
constant lresp : boolean := false;

signal GND      : std_ulogic := '0';
signal VCC      : std_ulogic := '1';
signal NC       : std_ulogic := 'Z';
signal Rst    : std_logic := '0';			-- Reset
signal clk : std_logic := '0';
signal clk125 : std_logic := '0';

signal address  : std_logic_vector(25 downto 0);
signal data     : std_logic_vector(31 downto 0);
signal romsn    : std_ulogic;
signal iosn     : std_ulogic;
signal oen      : std_ulogic;
signal writen   : std_ulogic;
signal dsuen, dsutx, dsurx, dsubren, dsuact : std_ulogic;
signal dsurst   : std_ulogic;
signal error    : std_logic;
signal gpio	: std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);
signal txd1, rxd1 : std_ulogic;       
    
-- PSRAM and FLASH control
signal sram_advn   : std_logic;
signal sram_csn    : std_logic;
signal sram_wen    : std_logic;
signal sram_ben    : std_logic_vector (0 to 3);
signal sram_oen    : std_ulogic;
signal sram_clk    : std_ulogic;
signal sram_adscn  : std_ulogic;
signal sram_psn    : std_ulogic;
signal sram_adv_n  : std_ulogic;
signal sram_wait   : std_logic_vector(1 downto 0);
signal flash_clk, flash_cen, max_csn : std_logic;
signal flash_advn, flash_oen, flash_resetn, flash_wen : std_logic;

-- DDR2 memory  
signal ddr_clk  	: std_logic_vector(2 downto 0);
signal ddr_clkb  	: std_logic_vector(2 downto 0);
signal ddr_cke  	: std_logic_vector(1 downto 0);
signal ddr_csb  	: std_logic_vector(1 downto 0);
signal ddr_odt  	: std_logic_vector(1 downto 0);
signal ddr_web  	: std_ulogic;                       -- ddr write enable
signal ddr_rasb  	: std_ulogic;                       -- ddr ras
signal ddr_casb  	: std_ulogic;                       -- ddr cas
signal ddr_dm   	: std_logic_vector (8 downto 0);    -- ddr dm
signal ddr_dqsp  	: std_logic_vector (8 downto 0);    -- ddr dqs
signal ddr_dqsn  	: std_logic_vector (8 downto 0);    -- ddr dqs
signal ddr_rdqs  	: std_logic_vector (8 downto 0);    -- ddr dqs
signal ddr_ad      : std_logic_vector (15 downto 0);   -- ddr address
signal ddr_ba      : std_logic_vector (2 downto 0);    -- ddr bank address
signal ddr_dq  	: std_logic_vector (71 downto 0); -- ddr data
signal ddr_dq2  	: std_logic_vector (71 downto 0); -- ddr data

--signal ddra_cke  	: std_logic;
--signal ddra_csb  	: std_logic;
--signal ddra_web   : std_ulogic;                       -- ddr write enable
--signal ddra_rasb  : std_ulogic;                       -- ddr ras
--signal ddra_casb  : std_ulogic;                       -- ddr cas
--signal ddra_ad    : std_logic_vector (15 downto 0);   -- ddr address
--signal ddra_ba    : std_logic_vector (2 downto 0);    -- ddr bank address
--signal ddrb_cke  	: std_logic;
--signal ddrb_csb  	: std_logic;
--signal ddrb_web   : std_ulogic;                       -- ddr write enable
--signal ddrb_rasb  : std_ulogic;                       -- ddr ras
--signal ddrb_casb  : std_ulogic;                       -- ddr cas
--signal ddrb_ad    : std_logic_vector (15 downto 0);   -- ddr address
--signal ddrb_ba    : std_logic_vector (2 downto 0);    -- ddr bank address
--signal ddrab_clk  : std_logic_vector(1 downto 0);
--signal ddrab_clkb : std_logic_vector(1 downto 0);
--signal ddrab_odt  : std_logic_vector(1 downto 0);
--signal ddrab_dqsp : std_logic_vector(1 downto 0);   -- ddr dqs
--signal ddrab_dqsn : std_logic_vector(1 downto 0);   -- ddr dqs
--signal ddrab_dm   : std_logic_vector(1 downto 0);     -- ddr dm
--signal ddrab_dq   : std_logic_vector (15 downto 0);-- ddr data

-- Ethernet
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

begin

-- clock and reset
  clk <= not clk after ct * 1 ns;
  clk125 <= not clk125 after 4 * 1 ns;
  rst <= dsurst;
  dsubren <= '1'; rxd1 <= '1';
  address(0) <= '0';
  ddr_dq(71 downto dbits) <= (others => 'H');
  ddr_dq2(71 downto dbits) <= (others => 'H');
  ddr_dqsp(8 downto dbits/8) <= (others => 'H');
  ddr_dqsn(8 downto dbits/8) <= (others => 'H');
  ddr_rdqs(8 downto dbits/8) <= (others => 'H');
  ddr_dm(8 downto dbits/8) <= (others => 'H');

  d3 : entity work.leon3mp 
    generic map (fabtech, memtech, padtech, clktech, 
                 ncpu, disas, dbguart, pclow, 50000, dbits)
    port map (rst, clk, clk125, error, dsubren, dsuact, 
--      rxd1, txd1, 
      gpio, address(25 downto 1), data, open, 
      sram_advn, sram_csn, sram_wen, sram_ben, sram_oen, sram_clk, sram_psn, sram_wait,
      flash_clk, flash_advn, flash_cen, flash_oen, flash_resetn, flash_wen,  
      max_csn, iosn,
	    ddr_clk, ddr_clkb, ddr_cke, ddr_csb, ddr_odt, ddr_web,
      ddr_rasb, ddr_casb, ddr_dm, ddr_dqsp, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq,
      open, open,
--      ddra_cke, ddra_csb, ddra_web, ddra_rasb, ddra_casb, ddra_ad(14 downto 0), ddra_ba, ddrb_cke,
--      ddrb_csb, ddrb_web, ddrb_rasb, ddrb_casb, ddrb_ad(14 downto 0), ddrb_ba, ddrab_clk, ddrab_clkb,
--      ddrab_odt, ddrab_dqsp, ddrab_dqsn, ddrab_dm, ddrab_dq,
      phy_gtx_clk, phy_mii_data, phy_tx_clk, phy_rx_clk, 
      phy_rx_data, phy_dv, phy_rx_er,	phy_col, phy_crs, 
      phy_tx_data, phy_tx_en, phy_tx_er, phy_mii_clk,	phy_rst_n 
    ); 

  ddr2delay : entity work.delay_wire 
    generic map(data_width => dbits, delay_atob => 0.0, delay_btoa => 5.5)
    port map(a => ddr_dq(dbits-1 downto 0), b => ddr_dq2(dbits-1 downto 0));

  ddr2mem : for i in 0 to dbits/16-1 generate
    u1 : ddr2 generic map(DEBUG => 0) 
    PORT MAP(
      ck => ddr_clk(0), ck_n => ddr_clkb(0), cke => ddr_cke(0), cs_n => ddr_csb(0),
      ras_n => ddr_rasb, cas_n => ddr_casb, we_n => ddr_web, 
      dm_rdqs => ddr_dm(i*2+1 downto i*2), ba => ddr_ba(1 downto 0),
      addr => ddr_ad(12 downto 0), dq => ddr_dq2(i*16+15 downto i*16),
      dqs => ddr_dqsp(i*2+1 downto i*2), dqs_n => ddr_dqsn(i*2+1 downto i*2),
      rdqs_n => ddr_rdqs(i*2+1 downto i*2), odt => ddr_odt(0));
  end generate;

  -- 16 bit prom
  prom0 : sram16 generic map (index => 4, abits => romdepth, fname => promfile)
	port map (address(romdepth downto 1), data(31 downto 16), 
		  gnd, gnd, flash_cen, flash_wen, flash_oen);

--  -- 32 bit prom
--  prom0 : for i in 0 to 3 generate
--    sr0 : sram generic map (index => i, abits => romdepth, fname => promfile)
--       port map (address(romdepth+1 downto 2), data(31-i*8 downto 24-i*8), flash_cen,
--                 flash_wen, flash_oen);
--  end generate;

  sram0 : for i in 0 to (sramwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => sramdepth, fname => sramfile)
	port map (address(sramdepth+1 downto 2), data(31-i*8 downto 24-i*8), sram_csn,
		  sram_wen, sram_oen);
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

  test0 :  grtestmod
    port map ( rst, clk, error, address(21 downto 2), data,
    	       iosn, sram_oen, sram_wen, open);


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
end ;

