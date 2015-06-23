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
--  modified by Thomas Ameseder, Gleichmann Electronics 2004, 2005 to
--  support the use of an external AHB slave and different HPE board versions
------------------------------------------------------------------------------
--  further adapted from Hpe_compact to Hpe_mini (Feb. 2005)
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

use work.config.all;                    -- configuration
use work.debug.all; 
use std.textio.all;
library grlib;
use grlib.stdlib.all;
use grlib.stdio.all;
use grlib.devices.all;


entity testbench is
  generic (
    fabtech : integer := CFG_FABTECH;
    memtech : integer := CFG_MEMTECH;
    padtech : integer := CFG_PADTECH;
    clktech : integer := CFG_CLKTECH;
    disas   : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart : integer := CFG_DUART;     -- Print UART on console
    pclow   : integer := CFG_PCLOW;

    clkperiod : integer := 10;          -- system clock period
    romwidth  : integer := 16;          -- rom data width (8/32)
    romdepth  : integer := 16          -- rom address depth
    );
end;

architecture behav of testbench is

  constant promfile  : string := "prom.srec";   -- rom contents
  constant sdramfile : string := "sdram.srec";  -- sdram contents


  signal   clk : std_logic := '0';
  signal   Rst : std_logic := '0';      -- Reset
  constant ct  : integer   := clkperiod/2;

  signal address : std_logic_vector(22 downto 0);
  signal data    : std_logic_vector(31 downto 0);

  signal romsn  : std_logic_vector(1 downto 0);
  signal oen    : std_ulogic;
  signal writen : std_ulogic;
  signal iosn : std_ulogic;

  -- ddr memory  
  signal ddr_clk  	: std_logic;
  signal ddr_clkb  	: std_logic;
  signal ddr_clk_fb  : std_logic;
  signal ddr_cke  	: std_logic;
  signal ddr_csb  	: std_logic;
  signal ddr_web  	: std_ulogic;                       -- ddr write enable
  signal ddr_rasb  	: std_ulogic;                       -- ddr ras
  signal ddr_casb  	: std_ulogic;                       -- ddr cas
  signal ddr_dm   	: std_logic_vector (1 downto 0);    -- ddr dm
  signal ddr_dqs  	: std_logic_vector (1 downto 0);    -- ddr dqs
  signal ddr_ad      : std_logic_vector (12 downto 0);   -- ddr address
  signal ddr_ba      : std_logic_vector (1 downto 0);    -- ddr bank address
  signal ddr_dq  		: std_logic_vector (15 downto 0); -- ddr data

  signal brdyn                               : std_ulogic;
  signal bexcn                               : std_ulogic;
  signal wdog                                : std_ulogic;
  signal dsuen, dsutx, dsurx, dsubre, dsuact : std_ulogic;
  signal dsurst                              : std_ulogic;
  signal test                                : std_ulogic;
  signal rtsn, ctsn                          : std_ulogic;

  signal error : std_logic;

  signal pio  : std_logic_vector(15 downto 0);
  signal GND  : std_ulogic := '0';
  signal VCC  : std_ulogic := '1';
  signal NC   : std_ulogic := 'Z';
  signal clk2 : std_ulogic := '1';

  signal plllock : std_ulogic;

-- pulled up high, therefore std_logic
  signal txd1, rxd1 : std_logic;

  signal etx_clk, erx_clk, erx_dv, erx_er, erx_col, erx_crs, etx_en, etx_er : std_logic                    := '0';
  signal erxd, etxd                                                         : std_logic_vector(3 downto 0) := (others => '0');
  signal emdc, emdio                                                        : std_logic;  --dummy signal for the mdc,mdio in the phy which is not used

  constant lresp : boolean := false;

  signal resoutn : std_logic;
  signal dsubren : std_ulogic;
  signal dsuactn : std_ulogic;

begin
  
  dsubren <= not dsubre;

-- clock and reset

  clk     <= not clk after ct * 1 ns;
  rst     <= '1', '0' after 1000 ns;
  dsuen   <= '0'; dsubre <= '0'; rxd1 <= 'H';
  address(0) <= '0';
  ddr_dqs <= (others => 'L');
  d3 : entity work.leon3mp
    port map (
      resetn  => rst,
      resoutn => resoutn,
      clk_100mhz     => clk,
      errorn  => error,
      address => address(22 downto 1),
      data    => data(31 downto 16),
      testdata    => data(15 downto 0),

      ddr_clk0		=> ddr_clk,  	
      ddr_clk0b  	=> ddr_clkb,	
      ddr_clk_fb	=> ddr_clk_fb,  
      ddr_cke0   	=> ddr_cke,  
      ddr_cs0b   	=> ddr_csb,  
      ddr_web   	=> ddr_web,  
      ddr_rasb  	=> ddr_rasb,	
      ddr_casb  	=> ddr_casb,	
      ddr_dm    	=> ddr_dm,  
      ddr_dqs   	=> ddr_dqs,  
      ddr_ad    	=> ddr_ad,  
      ddr_ba    	=> ddr_ba,  
      ddr_dq 		=> ddr_dq,
      sertx   => dsutx,
      serrx   => dsurx,
      rtsn   => rtsn,
      ctsn   => ctsn,

      dsuen   => dsuen,
      dsubre => dsubre,
      dsuact => dsuactn,

      oen    => oen,
      writen => writen,
      iosn   => iosn,
      romsn  => romsn(0),

      emdio   => emdio,
      etx_clk => etx_clk,
      erx_clk => erx_clk,
      erxd    => erxd,
      erx_dv  => erx_dv,
      erx_er  => erx_er,
      erx_col => erx_col,
      erx_crs => erx_crs,
      etxd    => etxd,
      etx_en  => etx_en,
      etx_er => etx_er,
      emdc   => emdc

      );

  ddr_clk_fb <= ddr_clk;
  
  u1 : mt46v16m16 
    generic map (index => -1, fname => sdramfile)
    port map(
      Dq => ddr_dq(15 downto 0), Dqs => ddr_dqs(1 downto 0), Addr => ddr_ad,
      Ba => ddr_ba, Clk => ddr_clk,  Clk_n => ddr_clkb, Cke => ddr_cke,
      Cs_n => ddr_csb, Ras_n => ddr_rasb, Cas_n => ddr_casb, We_n => ddr_web,
      Dm => ddr_dm(1 downto 0));

  prom0 : for i in 0 to (romwidth/8)-1 generate
      sr0 : sram generic map (index => i+4, abits => romdepth, fname => promfile)
        port map (address(romdepth downto 1), data(31-i*8 downto 24-i*8), romsn(0),
                  writen, oen);
  end generate;


--  phy0 : if CFG_GRETH > 0 generate
--    p0 : phy
--      port map(rst, led_cfg, open, etx_clk, erx_clk, erxd, erx_dv,
--               erx_er, erx_col, erx_crs, etxd, etx_en, etx_er, emdc);
--  end generate;
  error <= 'H';                         -- ERROR pull-up

  iuerr : process
  begin
    wait for 5 us;
    assert (to_X01(error) = '1')
      report "*** IU in error mode, simulation halted ***"
      severity failure;
  end process;

  test0 :  grtestmod
    port map ( rst, clk, error, address(21 downto 2), data,
    	       iosn, oen, writen, brdyn);

  data <= buskeep(data) after 5 ns;

    dsucom : process
      procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
        variable w32 : std_logic_vector(31 downto 0);
        variable c8  : std_logic_vector(7 downto 0);
        constant txp : time := 160 * 1 ns;
      begin
        dsutx  <= '1';
        dsurst <= '1';
        wait;
        wait for 5000 ns;
        txc(dsutx, 16#55#, txp);        -- sync uart

--		  txc(dsutx, 16#c0#, txp);
--        txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
--        txa(dsutx, 16#00#, 16#00#, 16#00#, 16#ef#, txp);
--
--        txc(dsutx, 16#c0#, txp);
--        txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
--        txa(dsutx, 16#00#, 16#00#, 16#ff#, 16#ff#, txp);
--
--        txc(dsutx, 16#c0#, txp);
--        txa(dsutx, 16#90#, 16#40#, 16#00#, 16#48#, txp);
--        txa(dsutx, 16#00#, 16#00#, 16#00#, 16#12#, txp);
--
--        txc(dsutx, 16#c0#, txp);
--        txa(dsutx, 16#90#, 16#40#, 16#00#, 16#60#, txp);
--        txa(dsutx, 16#00#, 16#00#, 16#12#, 16#10#, txp);
--
--        txc(dsutx, 16#80#, txp);
--        txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
--        rxi(dsurx, w32, txp, lresp);
		
        txc(dsutx, 16#a0#, txp);
        txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
        rxi(dsurx, w32, txp, lresp);

      end;

    begin

      dsucfg(dsutx, dsurx);

      wait;
    end process;

end;


