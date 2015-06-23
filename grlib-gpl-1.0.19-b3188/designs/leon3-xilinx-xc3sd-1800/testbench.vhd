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

use work.config.all;
use work.debug.all;
use std.textio.all;
library grlib;
use grlib.stdlib.all;
use grlib.stdio.all;
use grlib.devices.all;

entity testbench is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;   -- Enable disassembly to console
    dbguart   : integer := CFG_DUART;   -- Print UART on console
    pclow     : integer := CFG_PCLOW;
    clkperiod : integer := 8            -- system clock period
    );
end;

architecture behav of testbench is
  constant promfile : string  := "prom.srec";        -- rom contents
  constant sramfile : string  := "sram.srec";        -- sram contents
  constant lresp    : boolean := false;
  constant ct       : integer := clkperiod/2;

  signal clk        : std_logic := '0';
  signal clk_vga    : std_logic := '0';
  signal rst        : std_logic := '0';
  signal rstn1      : std_logic;
  signal rstn2      : std_logic;
  signal error      : std_logic;

  -- PROM flash
  signal address    : std_logic_vector(23 downto 0);
  signal data       : std_logic_vector(31 downto 0);
  signal romsn      : std_logic;
  signal oen        : std_ulogic;
  signal writen     : std_ulogic;
  signal iosn       : std_ulogic;

  -- SRAM only for simulation
  signal ramoen     : std_ulogic;
  signal ramwrn     : std_ulogic;
  signal ramsn      : std_ulogic;

  -- DDR2 memory
  signal ddr_clk    : std_logic_vector(1 downto 0);
  signal ddr_clkb   : std_logic_vector(1 downto 0);
  signal ddr_clk_fb : std_logic;
  signal ddr_cke    : std_logic;
  signal ddr_csb    : std_logic;
  signal ddr_we     : std_ulogic;                       -- write enable
  signal ddr_ras    : std_ulogic;                       -- ras
  signal ddr_cas    : std_ulogic;                       -- cas
  signal ddr_dm     : std_logic_vector(3 downto 0);     -- dm
  signal ddr_dqs    : std_logic_vector(3 downto 0);     -- dqs
  signal ddr_dqsn   : std_logic_vector(3 downto 0);     -- dqsn
  signal ddr_ad     : std_logic_vector(12 downto 0);    -- address
  signal ddr_ba     : std_logic_vector(1 downto 0);     -- bank address
  signal ddr_dq     : std_logic_vector(31 downto 0);    -- data
  signal ddr_odt    : std_logic;

  signal ddr_rdqs   : std_logic_vector (3 downto 0);    -- floating signal
  
  -- Debug support unit
  signal dsubre     : std_ulogic;

  -- AHB Uart
  signal dsurx      : std_ulogic;
  signal dsutx      : std_ulogic;

  -- APB Uart
  signal urxd       : std_ulogic;
  signal utxd       : std_ulogic;

  -- Ethernet signals
  signal etx_clk    : std_ulogic;
  signal erx_clk    : std_ulogic;
  signal erxdt      : std_logic_vector(7 downto 0);
  signal erx_dv     : std_ulogic;
  signal erx_er     : std_ulogic;
  signal erx_col    :  std_ulogic;
  signal erx_crs    : std_ulogic;
  signal etxdt      : std_logic_vector(7 downto 0);
  signal etx_en     : std_ulogic;
  signal etx_er     : std_ulogic;
  signal emdc       : std_ulogic;
  signal emdio      : std_logic;
  signal gtx_clk    : std_logic := '0';

  -- SVGA signals
  signal vid_hsync  : std_ulogic;
  signal vid_vsync  : std_ulogic;
  signal vid_r      : std_logic_vector(3 downto 0);
  signal vid_g      : std_logic_vector(3 downto 0);
  signal vid_b      : std_logic_vector(3 downto 0);

  -- Select signal for SPI flash
  signal spi       : std_ulogic;

  -- Output signals for LEDs
  signal led       : std_logic_vector(2 downto 0);

  signal brdyn     : std_ulogic;
begin
  -- clock and reset
  clk        <= not clk after ct * 1 ns;
  clk_vga    <= not clk_vga after 20 ns;
  rst        <= '1', '0' after 100 ns;
  dsubre     <= '0';
  ddr_dqs    <= (others => 'L');
  
  d3 : entity work.leon3mp
    generic map (
      memmask  => 16#F80#,
      ddraddr  => 16#600#,
      ddrdelay => 0,
      ddrskew  => 128)
    port map (
      reset     => rst,
      reset_o1  => rstn1,
      reset_o2  => rstn2,
      clk_in    => clk,
      clk_vga   => clk_vga,
      errorn    => error,

      -- PROM
      address   => address(23 downto 0),
      data      => data(31 downto 24),
      romsn     => romsn,
      oen       => oen,
      writen    => writen,
      iosn      => iosn,
      ramsn     => ramsn,
      ramoen    => ramoen,
      ramwrn    => ramwrn,
      testdata  => data(23 downto 0),

      -- DDR2
      ddr_clk        => ddr_clk,
      ddr_clkb       => ddr_clkb,
      ddr_clk_fb_out => ddr_clk_fb,
      ddr_clk_fb     => ddr_clk_fb,
      ddr_cke        => ddr_cke,
      ddr_csb        => ddr_csb,
      ddr_we         => ddr_we,
      ddr_ras        => ddr_ras,
      ddr_cas        => ddr_cas,
      ddr_dm         => ddr_dm,
      ddr_dqs        => ddr_dqs,
      ddr_dqsn       => ddr_dqsn,
      ddr_ad         => ddr_ad,
      ddr_ba         => ddr_ba,
      ddr_dq         => ddr_dq,
      ddr_odt        => ddr_odt,
      
      -- Debug Unit
      dsubre    => dsubre,

      -- AHB Uart
      dsutx     => dsutx,
      dsurx     => dsurx,

      -- PHY
      etx_clk   => etx_clk,
      erx_clk   => erx_clk,
      erxd      => erxdt(3 downto 0),
      erx_dv    => erx_dv,
      erx_er    => erx_er,
      erx_col   => erx_col,
      erx_crs   => erx_crs,
      etxd      => etxdt(3 downto 0),
      etx_en    => etx_en,
      etx_er    => etx_er,
      emdc      => emdc,
      emdio     => emdio,

      -- SVGA
      vid_hsync => vid_hsync,
      vid_vsync => vid_vsync,
      vid_r     => vid_r,
      vid_g     => vid_g,
      vid_b     => vid_b,

      -- SPI flash select
      spi       => spi,
      -- Output signals for LEDs
      led       => led
      );

  ddr2mem : if (CFG_DDR2SP /= 0) generate 
    ddr2mem0 : for i in 0 to 1 generate
      u1 : ddr2 
        port map(
          ck      => ddr_clk(i),
          ck_n    => ddr_clkb(i),
          cke     => ddr_cke,
          cs_n    => ddr_csb,
          ras_n   => ddr_ras,
          cas_n   => ddr_cas,
          we_n    => ddr_we, 
          dm_rdqs => ddr_dm(i*2+1 downto i*2),
          ba      => ddr_ba,
          addr    => ddr_ad(12 downto 0),
          dq      => ddr_dq(i*16+15 downto i*16),
          dqs     => ddr_dqs(i*2+1 downto i*2),
          dqs_n   => ddr_dqsn(i*2+1 downto i*2),
          rdqs_n  => ddr_rdqs(i*2+1 downto i*2),
          odt     => ddr_odt
          );
    end generate;
  end generate;

  prom0 : sram
    generic map (index => 6, abits => 24, fname => promfile)
    port map (address(23 downto 0), data(31 downto 24), romsn, writen, oen);

  -- This is only for simulation
  sram0 : for i in 0 to 1 generate
      sr0 : sram generic map (index => i+4, abits => 23, fname => sramfile)
        port map (address(23 downto 1), data(31-i*8 downto 24-i*8), ramsn, ramwrn, ramoen);
  end generate;

  phy0 : if (CFG_GRETH = 1) generate
    emdio <= 'H';
    etxdt(7 downto 4) <= "0000";
    p0: phy
      generic map(base1000_t_fd => 0, base1000_t_hd => 0)
      port map(rst, emdio, etx_clk, erx_clk, erxdt, erx_dv, erx_er,
               erx_col, erx_crs, etxdt, etx_en, etx_er, emdc, gtx_clk);
  end generate;

  error <= 'H';                         -- ERROR pull-up

  iuerr : process
  begin
    wait for 5 us;
    assert (to_X01(error) = '1')
      report "*** IU in error mode, simulation halted ***"
      severity failure;
  end process;

  test0 : grtestmod
    port map ( rst, clk, error, address(21 downto 2), data, iosn, oen, writen, brdyn);

  data <= buskeep(data) after 5 ns;

  dsucom : process
    procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
      variable w32 : std_logic_vector(31 downto 0);
      variable c8  : std_logic_vector(7 downto 0);
      constant txp : time := 160 * 1 ns;
    begin
      dsutx  <= '1';
      wait;
      wait for 5000 ns;
      txc(dsutx, 16#55#, txp);          -- sync uart
      txc(dsutx, 16#a0#, txp);
      txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
      rxi(dsurx, w32, txp, lresp);

-- txc(dsutx, 16#c0#, txp);
-- txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
-- txa(dsutx, 16#00#, 16#00#, 16#00#, 16#ef#, txp);
--
-- txc(dsutx, 16#c0#, txp);
-- txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
-- txa(dsutx, 16#00#, 16#00#, 16#ff#, 16#ff#, txp);
--
-- txc(dsutx, 16#c0#, txp);
-- txa(dsutx, 16#90#, 16#40#, 16#00#, 16#48#, txp);
-- txa(dsutx, 16#00#, 16#00#, 16#00#, 16#12#, txp);
--
-- txc(dsutx, 16#c0#, txp);
-- txa(dsutx, 16#90#, 16#40#, 16#00#, 16#60#, txp);
-- txa(dsutx, 16#00#, 16#00#, 16#12#, 16#10#, txp);
--
-- txc(dsutx, 16#80#, txp);
-- txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
-- rxi(dsurx, w32, txp, lresp);
    end;
  begin
    dsucfg(dsutx, dsurx);
    wait;
  end process;
end;


