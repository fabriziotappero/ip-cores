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
-----------------------------------------------------------------------------
-- Entity: 	greth_gbit_gen
-- File:	greth_gbit_gen.vhd
-- Author:	Marko Isomaki 
-- Description:	Generic Gigabit Ethernet MAC 
------------------------------------------------------------------------------
library ieee;
library grlib;
use ieee.std_logic_1164.all;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library eth;
use eth.ethcomp.all;

entity greth_gbit_gen is
  generic(
    memtech        : integer := 0;
    ifg_gap        : integer := 24; 
    attempt_limit  : integer := 16;
    backoff_limit  : integer := 10;
    slot_time      : integer := 128;
    mdcscaler      : integer range 0 to 255 := 25; 
    nsync          : integer range 1 to 2 := 2;
    edcl           : integer range 0 to 1 := 0;
    edclbufsz      : integer range 1 to 64 := 1;
    burstlength    : integer range 4 to 128 := 32;
    macaddrh       : integer := 16#00005E#;
    macaddrl       : integer := 16#000000#;
    ipaddrh        : integer := 16#c0a8#;
    ipaddrl        : integer := 16#0035#;
    phyrstadr      : integer range 0 to 32 := 0;
    sim            : integer range 0 to 1 := 0;
    oepol          : integer range 0 to 1 := 0;
    scanen         : integer range 0 to 1 := 0);
  port(
    rst            : in  std_ulogic;
    clk            : in  std_ulogic;
    --ahb mst in
    hgrant         : in  std_ulogic;
    hready         : in  std_ulogic;   
    hresp          : in  std_logic_vector(1 downto 0);
    hrdata         : in  std_logic_vector(31 downto 0); 
    --ahb mst out
    hbusreq        : out  std_ulogic;        
    hlock          : out  std_ulogic;
    htrans         : out  std_logic_vector(1 downto 0);
    haddr          : out  std_logic_vector(31 downto 0);
    hwrite         : out  std_ulogic;
    hsize          : out  std_logic_vector(2 downto 0);
    hburst         : out  std_logic_vector(2 downto 0);
    hprot          : out  std_logic_vector(3 downto 0);
    hwdata         : out  std_logic_vector(31 downto 0);
    --apb slv in 
    psel	   : in   std_ulogic;
    penable	   : in   std_ulogic;
    paddr	   : in   std_logic_vector(31 downto 0);
    pwrite	   : in   std_ulogic;
    pwdata	   : in   std_logic_vector(31 downto 0);
    --apb slv out
    prdata	   : out  std_logic_vector(31 downto 0);
    --irq
    irq            : out  std_logic;
    --ethernet input signals
    gtx_clk        : in   std_ulogic;                     
    tx_clk         : in   std_ulogic;
    rx_clk         : in   std_ulogic;
    rxd            : in   std_logic_vector(7 downto 0);   
    rx_dv          : in   std_ulogic; 
    rx_er          : in   std_ulogic; 
    rx_col         : in   std_ulogic;
    rx_crs         : in   std_ulogic;
    mdio_i         : in   std_ulogic;
    phyrstaddr     : in   std_logic_vector(4 downto 0);
    --ethernet output signals
    reset          : out  std_ulogic;
    txd            : out  std_logic_vector(7 downto 0);   
    tx_en          : out  std_ulogic; 
    tx_er          : out  std_ulogic; 
    mdc            : out  std_ulogic;    
    mdio_o         : out  std_ulogic; 
    mdio_oe        : out  std_ulogic;
    --scantest
    testrst        : in   std_ulogic;
    testen         : in   std_ulogic
    );
end entity;
  
architecture rtl of greth_gbit_gen is
  --host constants
  constant fifosize        : integer := 512;
  constant fabits          : integer := log2(fifosize);
  constant fsize           : std_logic_vector(fabits downto 0) :=
    conv_std_logic_vector(fifosize, fabits+1);
  
  --edcl constants
  type szvct is array (0 to 6) of integer;
  constant ebuf : szvct := (64, 128, 128, 256, 256, 256, 256);
  constant eabits: integer := log2(edclbufsz) + 8;
  constant ebufsize : integer := ebuf(log2(edclbufsz));

  --rx ahb fifo
  signal rxrenable      : std_ulogic;
  signal rxraddress     : std_logic_vector(8 downto 0);
  signal rxwrite        : std_ulogic;
  signal rxwdata        : std_logic_vector(31 downto 0);
  signal rxwaddress     : std_logic_vector(8 downto 0);
  signal rxrdata        : std_logic_vector(31 downto 0);    
  --tx ahb fifo  
  signal txrenable      : std_ulogic;
  signal txraddress     : std_logic_vector(8 downto 0);
  signal txwrite        : std_ulogic;
  signal txwdata        : std_logic_vector(31 downto 0);
  signal txwaddress     : std_logic_vector(8 downto 0);
  signal txrdata        : std_logic_vector(31 downto 0);    
  --edcl buf     
  signal erenable       : std_ulogic;
  signal eraddress      : std_logic_vector(15 downto 0);
  signal ewritem        : std_ulogic;
  signal ewritel        : std_ulogic;
  signal ewaddressm     : std_logic_vector(15 downto 0);
  signal ewaddressl     : std_logic_vector(15 downto 0);
  signal ewdata         : std_logic_vector(31 downto 0);
  signal erdata         : std_logic_vector(31 downto 0);

begin
  gtxc0: greth_gbitc
    generic map(
      ifg_gap        => ifg_gap, 
      attempt_limit  => attempt_limit,
      backoff_limit  => backoff_limit,
      slot_time      => slot_time,
      mdcscaler      => mdcscaler,
      nsync          => nsync,
      edcl           => edcl,
      edclbufsz      => edclbufsz,
      burstlength    => burstlength,
      macaddrh       => macaddrh,
      macaddrl       => macaddrl,
      ipaddrh        => ipaddrh,
      ipaddrl        => ipaddrl,
      phyrstadr      => phyrstadr,
      sim            => sim,
      oepol          => oepol,
      scanen         => scanen)
    port map(
      rst            => rst,
      clk            => clk,
      --ahb mst in   
      hgrant         => hgrant,
      hready         => hready,
      hresp          => hresp,
      hrdata         => hrdata,
      --ahb mst out  
      hbusreq        => hbusreq,
      hlock          => hlock,
      htrans         => htrans,
      haddr          => haddr,
      hwrite         => hwrite,
      hsize          => hsize,
      hburst         => hburst,
      hprot          => hprot,
      hwdata         => hwdata,
      --apb slv in 
      psel	     => psel,
      penable	     => penable,
      paddr	     => paddr,
      pwrite	     => pwrite,
      pwdata	     => pwdata,
      --apb slv out
      prdata	     => prdata,
      --irq
      irq            => irq,
      --rx ahb fifo
      rxrenable      => rxrenable,
      rxraddress     => rxraddress,
      rxwrite        => rxwrite,
      rxwdata        => rxwdata,
      rxwaddress     => rxwaddress,
      rxrdata        => rxrdata,
      --tx ahb fifo  
      txrenable      => txrenable,
      txraddress     => txraddress,
      txwrite        => txwrite,
      txwdata        => txwdata,
      txwaddress     => txwaddress,
      txrdata        => txrdata,   
      --edcl buf
      erenable       => erenable,
      eraddress      => eraddress,
      ewritem        => ewritem,
      ewritel        => ewritel,
      ewaddressm     => ewaddressm,
      ewaddressl     => ewaddressl,
      ewdata         => ewdata,
      erdata         => erdata,
      --ethernet input signals
      gtx_clk        => gtx_clk,  
      tx_clk         => tx_clk,
      rx_clk         => rx_clk,
      rxd            => rxd,  
      rx_dv          => rx_dv,
      rx_er          => rx_er,
      rx_col         => rx_col,
      rx_crs         => rx_crs,
      mdio_i         => mdio_i,
      phyrstaddr     => phyrstaddr,
      --ethernet output signals
      reset          => reset,
      txd            => txd,
      tx_en          => tx_en,
      tx_er          => tx_er,
      mdc            => mdc,   
      mdio_o         => mdio_o,
      mdio_oe        => mdio_oe,
      --scantest     
      testrst        => testrst,
      testen         => testen);

-------------------------------------------------------------------------------
-- FIFOS ----------------------------------------------------------------------
-------------------------------------------------------------------------------
  tx_fifo0 : syncram_2p generic map(tech => memtech, abits => fabits,
    dbits => 32, sepclk => 0)
    port map(clk, txrenable, txraddress(fabits-1 downto 0), txrdata, clk,
    txwrite, txwaddress(fabits-1 downto 0), txwdata);

  rx_fifo0 : syncram_2p generic map(tech => memtech, abits => fabits,
    dbits => 32, sepclk => 0)
    port map(clk, rxrenable, rxraddress(fabits-1 downto 0), rxrdata, clk,
    rxwrite, rxwaddress(fabits-1 downto 0), rxwdata);

-------------------------------------------------------------------------------
-- EDCL buffer ram ------------------------------------------------------------
-------------------------------------------------------------------------------
  edclram : if (edcl = 1) generate
    rloopm : for i in 0 to 1 generate
      r0 : syncram_2p generic map (memtech, eabits, 8) port map (
	clk, erenable, eraddress(eabits-1 downto 0), erdata(i*8+23 downto i*8+16), clk,
        ewritem, ewaddressm(eabits-1 downto 0), ewdata(i*8+23 downto i*8+16)); 
    end generate;
    rloopl : for i in 0 to 1 generate
      r0 : syncram_2p generic map (memtech, eabits, 8) port map (
	clk, erenable, eraddress(eabits-1 downto 0), erdata(i*8+7 downto i*8), clk,
        ewritel, ewaddressl(eabits-1 downto 0), ewdata(i*8+7 downto i*8)); 
    end generate;
  end generate;
  
end architecture;
